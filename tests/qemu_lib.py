"""Shared QEMU/KVM guest control for Axiom acceptance drivers.

    from qemu_lib import Guest
    g = Guest(iso, outdir, "1920x1080")
    g.start(); g.wait_login(); g.login_root(); g.wait_shell_ready(); g.prepare_env()
    rc, out = g.sh("uname -r")            # root shell on the serial console
    rc, out = g.user("gio mime text/plain")   # as the desktop user, in its session
    g.key("ctrl-l"); g.type("/home/axiom\\n"); g.click(960, 540); g.shot("name")

Design notes (each learned the hard way):
  * The 16550 UART drops bytes when a long line arrives in one burst, so every
    serial write is paced (24 bytes, 80 ms) and the socket is drained while
    writing; an undrained socket stalls the guest's console.
  * Terminals and apps started from the serial shell lack the desktop session's
    private D-Bus address (dbus-run-session), so `user()` sources an env file
    built from the running Quickshell's environment.
  * HMP `mouse_move` is relative and ignored by the absolute USB tablet; pointer
    input goes through QMP `input-send-event`.
  * `pkill -x` cannot match names over 15 characters ("qemu-system-x86_64").
No networking and no host shares are ever attached.
"""
import itertools
import json
import os
import re
import shlex
import socket
import subprocess
import threading
import time

OVMF_CODE = "/usr/share/edk2/x64/OVMF_CODE.4m.fd"
OVMF_VARS = "/usr/share/edk2/x64/OVMF_VARS.4m.fd"
QS = "qs ipc --any-display -p /usr/local/share/axiom/shell"
ANSI = re.compile(r"\x1b\[[0-9;?]*[A-Za-z]|\x1b[()][A-Z0-9]|\x1b[=>]|\x1b\][^\x07\x1b]*(?:\x07|\x1b\\)|\r")
KEYNAMES = {" ": "spc", "-": "minus", ".": "dot", "/": "slash", "\n": "ret", ";": "semicolon",
            "=": "equal", "@": "shift-2", "!": "shift-1", "#": "shift-3", "+": "shift-equal", ":": "shift-semicolon", "_": "shift-minus", ",": "comma", "~": "shift-grave"}


class Guest:
    def __init__(self, iso, outdir, res="1920x1080", mem=2048, smp=2, extra=()):
        self.extra = list(extra)
        self.iso, self.out, self.res, self.mem, self.smp = iso, outdir, res, mem, smp
        self.w, self.h = (int(v) for v in res.split("x"))
        os.makedirs(outdir, exist_ok=True)
        self.p = lambda n: os.path.join(outdir, n)
        self.raw = bytearray()
        self.ser = None
        self.qemu = None
        self._stop = threading.Event()
        self._n = itertools.count(1)
        self._qmp = None
        self.failures = []
        self.duser = "axiom"  # desktop account (installed systems use the installer-created user)
        self._transcript = None

    # ---- results ------------------------------------------------------------
    def ok(self, msg):
        print("PASS:", msg, flush=True)

    def bad(self, msg):
        print("FAIL:", msg, flush=True)
        self.failures.append(msg)

    def check(self, cond, msg):
        (self.ok if cond else self.bad)(msg)
        return bool(cond)

    # ---- lifecycle ------------------------------------------------------------
    def start(self):
        for n in ("serial.sock", "mon.sock", "qmp.sock"):
            if os.path.exists(self.p(n)):
                os.unlink(self.p(n))
        vars_copy = self.p("OVMF_VARS.fd")
        subprocess.run(["cp", getattr(self, "vars_src", None) or OVMF_VARS, vars_copy], check=True)
        self.qemu = subprocess.Popen([
            "qemu-system-x86_64", "-enable-kvm", "-machine", "q35", "-cpu", "host",
            "-m", str(self.mem), "-smp", str(self.smp),
            "-drive", f"if=pflash,format=raw,readonly=on,file={OVMF_CODE}",
            "-drive", f"if=pflash,format=raw,file={vars_copy}",
            "-vga", "none", "-device", f"VGA,edid=on,xres={self.w},yres={self.h}",
            "-device", "qemu-xhci", "-device", "usb-tablet", "-display", "none",
        ] + (["-cdrom", self.iso, "-boot", "order=d"] if self.iso else []) + [
            "-nic", "none",
            "-serial", f"unix:{self.p('serial.sock')},server,nowait",
            "-monitor", f"unix:{self.p('mon.sock')},server,nowait",
            "-qmp", f"unix:{self.p('qmp.sock')},server,nowait",
        ] + self.extra, stdout=open(self.p("qemu.out"), "wb"), stderr=subprocess.STDOUT)
        for _ in range(400):
            if os.path.exists(self.p("serial.sock")):
                try:
                    self.ser = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
                    self.ser.connect(self.p("serial.sock"))
                    break
                except OSError:
                    self.ser = None
            time.sleep(0.1)
        if self.ser is None:
            raise RuntimeError("no serial socket")
        self.ser.settimeout(0.5)
        log = open(self.p("serial.log"), "wb")

        def reader():
            while not self._stop.is_set():
                try:
                    d = self.ser.recv(65536)
                except socket.timeout:
                    continue
                except OSError:
                    break
                if not d:
                    break
                self.raw.extend(d)
                log.write(d)
                log.flush()
        threading.Thread(target=reader, daemon=True).start()

    def alive(self):
        return self.qemu is not None and self.qemu.poll() is None

    def kill(self):
        self._stop.set()
        if self.alive():
            self.qemu.kill()

    # ---- serial -----------------------------------------------------------------
    def _text(self, start=0):
        return ANSI.sub("", bytes(self.raw[start:]).decode(errors="replace"))

    def wait_for(self, needle, timeout, start=0):
        end = time.monotonic() + timeout
        while time.monotonic() < end:
            if needle in self._text(start):
                return True
            if not self.alive():
                return False
            time.sleep(0.3)
        return False

    def _write(self, text):
        data = text.encode()
        for i in range(0, len(data), 24):
            self.ser.sendall(data[i:i + 24])
            time.sleep(0.08)

    def wait_login(self, timeout=240):
        """False means the known firmware-stage stall (no kernel output): retry the boot."""
        if not self.wait_for("systemd", timeout):
            return False
        return self.wait_for("login:", 240)

    def login_root(self):
        """Log in on the serial console. Retries when the first attempt lands on a 'Password:' prompt
        (the prompt can appear if login starts before the system is fully up)."""
        for _ in range(3):
            mark = len(self.raw)
            self._write("root\n")
            time.sleep(3)
            if "Password:" in self._text(mark):
                self._write("\n")  # empty password fails; getty offers a fresh login prompt
                self.wait_for("login:", 30, mark)
                time.sleep(2)
                continue
            self._write("exec sh\n")
            time.sleep(2)
            self._write("stty -echo; PS1=; PS2=\n")
            time.sleep(1.5)
            rc, _ = self.sh("true", 15)
            if rc == 0:
                return True
        return False

    def sh(self, cmd, timeout=30):
        """Run cmd in the root serial shell; return (exit code, output) or (None, partial).

        The output is delimited by explicit begin/end markers, so prompts and
        other console noise never leak into it."""
        n = next(self._n)
        begin, end_m = f"__B{n}__", f"__E{n}__"
        start = len(self.raw)
        self._write(f"echo {begin}\n{cmd}\necho {end_m}$?\n")
        deadline = time.monotonic() + timeout
        rc, out = None, None
        while time.monotonic() < deadline:
            text = self._text(start)
            m = re.search(rf"{begin}\n(.*?){end_m}(\d+)", text, re.S)
            if m:
                rc, out = int(m.group(2)), m.group(1)
                break
            if not self.alive():
                break
            time.sleep(0.25)
        if out is None:
            text = self._text(start)
            i = text.find(begin)
            out = text[i + len(begin):] if i >= 0 else text
        out = re.sub(r"(?m)^(?:sh-[\d.]+# ?)+", "", out).strip("\n")
        self._log(cmd, rc, out)
        return rc, out

    def _log(self, cmd, rc, out):
        """Append every root-shell command with its exit code and output to transcript.txt."""
        if self._transcript is None:
            self._transcript = open(self.p("transcript.txt"), "w")
        self._transcript.write(f"$ {cmd}\n[rc={rc}]\n{out[:4000]}\n\n")
        self._transcript.flush()

    def prepare_env(self):
        """Write the session environment (Wayland, runtime dir, private D-Bus) for user()."""
        self.sh("D=$(tr '\\0' '\\n' < /proc/$(pgrep -xo quickshell)/environ | grep ^DBUS_SESSION_BUS_ADDRESS=); "
                "printf 'export XDG_RUNTIME_DIR=/run/user/1000 WAYLAND_DISPLAY=wayland-0 %s\\n' \"$D\" > /tmp/axiom-env.sh; "
                "chmod 644 /tmp/axiom-env.sh", 20)

    def user(self, cmd, timeout=30, shell="/bin/sh"):
        """Run cmd as the desktop user, in the session environment."""
        inner = f". /tmp/axiom-env.sh; {cmd}"
        return self.sh(f"su {self.duser} -s {shell} -c {shlex.quote(inner)}", timeout)

    def put_file(self, path, content, mode="644"):
        """Create a small file in the guest (base64 in chunks over the serial console)."""
        import base64
        b = base64.b64encode(content.encode()).decode()
        self.sh(f"rm -f /tmp/put.b64; mkdir -p $(dirname {shlex.quote(path)})", 15)
        for i in range(0, len(b), 1500):
            self.sh(f"printf %s '{b[i:i + 1500]}' >> /tmp/put.b64", 40)
        self.sh(f"base64 -d /tmp/put.b64 > {shlex.quote(path)}; chmod {mode} {shlex.quote(path)}", 20)

    def shell_ready(self, timeout=330):
        end = time.monotonic() + timeout
        while time.monotonic() < end:
            rc, out = self.sh(f"su axiom -s /bin/sh -c 'XDG_RUNTIME_DIR=/run/user/1000 {QS} show' 2>/dev/null | grep -c 'target axiom'", 20)
            if rc is not None and re.search(r"^\s*[1-9]\d*\s*$", out, re.M):
                return True
            time.sleep(3)
        return False

    # ---- monitor / QMP input ----------------------------------------------------------
    def monitor(self, cmd, settle=0.3):
        s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        s.settimeout(10)
        s.connect(self.p("mon.sock"))
        time.sleep(0.15)
        s.sendall((cmd + "\n").encode())
        time.sleep(settle)
        try:
            s.recv(65536)
        except OSError:
            pass
        s.close()

    def key(self, combo, settle=1.0):
        self.monitor(f"sendkey {combo}")
        time.sleep(settle)

    def type(self, text, settle=0.8):
        for ch in text:
            name = ("shift-" + ch.lower()) if ch.isupper() else KEYNAMES.get(ch, ch)
            self.monitor("sendkey " + name, 0.12)
        time.sleep(settle)

    def _qmp_send(self, events):
        if self._qmp is None:
            self._qmp = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            self._qmp.settimeout(10)
            self._qmp.connect(self.p("qmp.sock"))
            self._qmp.recv(65536)
            self._qmp.sendall(b'{"execute":"qmp_capabilities"}\n')
            self._qmp.recv(65536)
        self._qmp.sendall((json.dumps({"execute": "input-send-event", "arguments": {"events": events}}) + "\n").encode())
        time.sleep(0.06)
        try:
            self._qmp.recv(65536)
        except OSError:
            pass

    def move(self, x, y):
        self._qmp_send([{"type": "abs", "data": {"axis": "x", "value": int(x * 32767 / (self.w - 1))}},
                        {"type": "abs", "data": {"axis": "y", "value": int(y * 32767 / (self.h - 1))}}])
        time.sleep(0.4)

    def _button(self, button, times=1):
        for _ in range(times):
            self._qmp_send([{"type": "btn", "data": {"down": True, "button": button}}])
            time.sleep(0.06)
            self._qmp_send([{"type": "btn", "data": {"down": False, "button": button}}])
            time.sleep(0.08)

    def click(self, x, y, settle=1.2):
        self.move(x, y)
        self._button("left")
        time.sleep(settle)

    def dclick(self, x, y, settle=1.5):
        self.move(x, y)
        self._button("left", 2)
        time.sleep(settle)

    def rclick(self, x, y, settle=1.2):
        self.move(x, y)
        self._button("right")
        time.sleep(settle)

    def shot(self, name):
        ppm = self.p(name + ".ppm")
        if os.path.exists(ppm):
            os.unlink(ppm)
        self.monitor(f"screendump {ppm}", settle=1.2)
        if not os.path.exists(ppm) or os.path.getsize(ppm) == 0:
            self.bad(f"screendump {name} produced no file")
            return None
        png = self.p(name + ".png")
        subprocess.run(["magick", ppm, png], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        os.unlink(ppm)
        return png

    def mean_brightness(self, png, geometry):
        """Mean pixel value (0..1) of a WxH+X+Y crop; used for objective toast/overlay checks."""
        r = subprocess.run(["magick", png, "-crop", geometry, "+repage", "-colorspace", "Gray", "-format", "%[fx:mean]", "info:"],
                           capture_output=True, text=True)
        try:
            return float(r.stdout.strip())
        except ValueError:
            return 0.0

    # ---- geometry shared with the Phase 3 drivers ---------------------------------------------
    def dock_item(self, i, count=6):
        """Centre of dock item i (launcher is 0); 66 px items, 4 px gap, 7 px padding, 12 px edge gap."""
        width = count * 66 + (count - 1) * 4 + 14
        x0 = (self.w - width) // 2 + 7
        return x0 + i * 70 + 33, self.h - 12 - (66 + 14) // 2

    def power_off(self, timeout=120):
        self.user(f"{QS} call axiom powerOff", 20)
        try:
            self.qemu.wait(timeout=timeout)
            return True
        except subprocess.TimeoutExpired:
            return False
