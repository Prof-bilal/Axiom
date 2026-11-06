#!/usr/bin/env python3
"""Axiom desktop-identity acceptance driver (QEMU/KVM).

    tests/phase3-desktop.py <iso> [outdir] [--res 1920x1080] [--short]

Boots the Phase 3 ISO with an EDID-advertised resolution and a USB tablet, then
drives the real desktop with keyboard *and* pointer input:

  empty desktop -> Axiom (penguin) menu + search -> terminal (greeting) ->
  second terminal (cascade) -> Files launched from the dock -> maximize ->
  workspace switch by clicking the panel -> status menu -> session menu ->
  shutdown armed but not confirmed -> shell log check -> confirmed shutdown
  through the session menu (must power the guest off cleanly).

`--short` stops after the terminal and menu captures and powers off over IPC
(used for additional resolutions). No networking, no host shares.
"""
import json, os, re, socket, subprocess, sys, threading, time

args = [a for a in sys.argv[1:]]
ISO = args[0] if args else ""
OUT = args[1] if len(args) > 1 and not args[1].startswith("--") else "iso/out-phase3/evidence/desktop"
RES = "1920x1080"
SHORT = "--short" in args
for i, a in enumerate(args):
    if a == "--res" and i + 1 < len(args):
        RES = args[i + 1]
W, H = (int(v) for v in RES.split("x"))
OUT = os.path.join(OUT, RES)

if not os.path.isfile(ISO):
    print("usage: phase3-desktop.py <iso> [outdir] [--res WxH] [--short]"); sys.exit(2)

OVMF_CODE = "/usr/share/edk2/x64/OVMF_CODE.4m.fd"
OVMF_VARS = "/usr/share/edk2/x64/OVMF_VARS.4m.fd"
QS = "qs ipc --any-display -p /usr/local/share/axiom/shell call axiom"
os.makedirs(OUT, exist_ok=True)
SER = os.path.join(OUT, "serial.sock")
MON = os.path.join(OUT, "monitor.sock")
QMP = os.path.join(OUT, "qmp.sock")
for p in (SER, MON, QMP):
    if os.path.exists(p):
        os.unlink(p)
VARS = os.path.join(OUT, "OVMF_VARS.fd")
subprocess.run(["cp", OVMF_VARS, VARS], check=True)

failures = []
def ok(msg):  print("PASS:", msg, flush=True)
def bad(msg): print("FAIL:", msg, flush=True); failures.append(msg)

qemu = subprocess.Popen([
    "qemu-system-x86_64", "-enable-kvm", "-machine", "q35", "-cpu", "host",
    "-m", "2048", "-smp", "2",
    "-drive", f"if=pflash,format=raw,readonly=on,file={OVMF_CODE}",
    "-drive", f"if=pflash,format=raw,file={VARS}",
    "-vga", "none", "-device", f"VGA,edid=on,xres={W},yres={H}",
    "-device", "qemu-xhci", "-device", "usb-tablet",
    "-display", "none",
    "-cdrom", ISO, "-boot", "order=d", "-nic", "none",
    "-serial", f"unix:{SER},server,nowait",
    "-monitor", f"unix:{MON},server,nowait",
    "-qmp", f"unix:{QMP},server,nowait",
], stdout=open(os.path.join(OUT, "qemu.out"), "wb"), stderr=subprocess.STDOUT)

ser = None
for _ in range(400):
    if os.path.exists(SER):
        try:
            ser = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM); ser.connect(SER); break
        except OSError:
            ser = None
    time.sleep(0.1)
if ser is None:
    print("no serial socket"); qemu.kill(); sys.exit(2)
ser.settimeout(0.5)
raw = bytearray()
serial_log = open(os.path.join(OUT, "serial.log"), "wb")
stop = threading.Event()

def reader():
    while not stop.is_set():
        try:
            data = ser.recv(65536)
        except socket.timeout:
            continue
        except OSError:
            break
        if not data:
            break
        raw.extend(data); serial_log.write(data); serial_log.flush()
threading.Thread(target=reader, daemon=True).start()

def wait_for(needle, timeout, start=0):
    end = time.monotonic() + timeout
    while time.monotonic() < end:
        if needle.encode() in bytes(raw[start:]):
            return True
        if qemu.poll() is not None:
            return False
        time.sleep(0.3)
    return False

def monitor(cmd, settle=0.3):
    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    s.settimeout(10); s.connect(MON); time.sleep(0.15)
    s.sendall((cmd + "\n").encode()); time.sleep(settle)
    try: s.recv(65536)
    except OSError: pass
    s.close()

def shot(name):
    ppm = os.path.join(OUT, name + ".ppm")
    if os.path.exists(ppm):
        os.unlink(ppm)
    monitor(f"screendump {ppm}", settle=1.2)
    if not os.path.exists(ppm) or os.path.getsize(ppm) == 0:
        bad(f"screendump {name} produced no file"); return
    subprocess.run(["magick", ppm, os.path.join(OUT, name + ".png")],
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    os.unlink(ppm)
    ok(f"captured {name}")

def key(combo, settle=1.2):
    monitor(f"sendkey {combo}"); time.sleep(settle)

def type_text(text):
    names = {" ": "spc", "-": "minus", ".": "dot", "/": "slash", "\n": "ret"}
    for ch in text:
        monitor("sendkey " + names.get(ch, ch), settle=0.08)

# Pointer input goes through QMP input-send-event: HMP mouse_move only sends
# relative motion, which the absolute usb-tablet ignores.
_qmp = None
def qmp(cmd, **arguments):
    global _qmp
    if _qmp is None:
        _qmp = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        _qmp.settimeout(10); _qmp.connect(QMP)
        _qmp.recv(65536)                                   # greeting
        _qmp.sendall(b'{"execute":"qmp_capabilities"}\n'); _qmp.recv(65536)
    msg = {"execute": cmd}
    if arguments:
        msg["arguments"] = arguments
    _qmp.sendall((json.dumps(msg) + "\n").encode())
    time.sleep(0.05)
    try: _qmp.recv(65536)
    except OSError: pass

def point(x, y):
    qmp("input-send-event", events=[
        {"type": "abs", "data": {"axis": "x", "value": int(x * 32767 / (W - 1))}},
        {"type": "abs", "data": {"axis": "y", "value": int(y * 32767 / (H - 1))}}])
    time.sleep(0.4)

def click(x, y, settle=1.5):
    point(x, y)
    qmp("input-send-event", events=[{"type": "btn", "data": {"down": True, "button": "left"}}])
    time.sleep(0.08)
    qmp("input-send-event", events=[{"type": "btn", "data": {"down": False, "button": "left"}}])
    time.sleep(settle)

ANSI = re.compile(r"\x1b\[[0-9;?]*[A-Za-z]|\x1b[()][A-Z0-9]|\x1b[=>]|\r")
def serial_cmd(cmd, marker, timeout=15):
    """Run cmd on the root serial shell; return its cleaned output or None.
    Waits for MARKER=<digits>: the echoed command line only shows MARKER=$?."""
    start = len(raw)
    ser.sendall((cmd + f"; echo {marker}=$?\n").encode())
    end = time.monotonic() + timeout
    while time.monotonic() < end:
        text = ANSI.sub("", bytes(raw[start:]).decode(errors="replace"))
        if re.search(rf"^{marker}=\d+", text, re.M):
            return text
        if qemu.poll() is not None:
            return None
        time.sleep(0.3)
    return None

# --- geometry derived from the shell's tokens (Theme.qml) -------------------
PANEL_H = 40
PANEL_Y = PANEL_H // 2
def ws_chip(n):            # 4 tiles, 30 px wide, 6 px apart, centred on the output
    x0 = W // 2 - (4 * 30 + 3 * 6) // 2
    return x0 + (n - 1) * 36 + 15, PANEL_Y
POWER = (W - 8 - 16, PANEL_Y)
def dock_item(i, count=6):  # launcher + 5 pinned; 66 px items, 4 px gap, 7 px padding, 12 px edge gap
    width = count * 66 + (count - 1) * 4 + 14
    x0 = (W - width) // 2 + 7
    return x0 + i * 70 + 33, H - 12 - (66 + 14) // 2

# --- run ---------------------------------------------------------------------
# Readiness is checked from inside the guest as root over the serial console:
# the session's own AXIOM_SHELL_READY marker cannot reach /dev/ttyS0 because
# the serial getty owns that device with mode 0600.
def shell_ready(timeout):
    if not wait_for("login:", timeout):
        return False
    ser.sendall(b"root\n"); time.sleep(3)
    end = time.monotonic() + timeout
    while time.monotonic() < end:
        out = serial_cmd("su axiom -s /bin/sh -c 'XDG_RUNTIME_DIR=/run/user/1000 qs ipc --any-display -p /usr/local/share/axiom/shell show' "
                         "2>/dev/null | grep -c 'target axiom'", "READY", timeout=10)
        if out and re.search(r"^\s*[1-9]\d*\s*$", out, re.M):
            return True
        time.sleep(3)
    return False

# Known host/QEMU flake (see tests/qemu-session.sh): firmware hands off to the
# boot loader and the guest never starts. Exit 3 so the caller can retry; it
# is not a desktop defect.
if not wait_for("systemd", 240):
    shot("00-firmware-stall"); print("STALL: firmware stage produced no kernel/systemd output")
    qemu.kill(); sys.exit(3)
if not shell_ready(330):
    shot("00-failure"); bad("session did not become ready"); qemu.kill(); sys.exit(1)
ok(f"session ready at {RES} (shell config loaded)")
time.sleep(4)
point(W // 2, H // 2 - 200)            # park the pointer on the desktop
shot("01-empty-desktop")

key("meta_l-a"); shot("02-axiom-menu")
type_text("fire"); time.sleep(0.8); shot("03-axiom-menu-search"); key("esc")

key("meta_l-ret", settle=4); shot("04-terminal-focused")
type_text("uname -r\n"); time.sleep(1)

if SHORT:
    key("meta_l-d"); shot("05-launcher"); key("esc")
    key("meta_l-c"); shot("06-status-menu"); key("esc")
else:
    key("meta_l-ret", settle=3.5); shot("05-two-terminals-cascade")
    click(*dock_item(2), settle=5); shot("06-files-from-dock-terminal-unfocused")
    key("meta_l-m", settle=2); shot("07-maximized")
    key("meta_l-h", settle=2); shot("07b-minimized")
    click(*dock_item(2), settle=2)
    key("meta_l-m", settle=1.5)
    click(*ws_chip(2), settle=2); shot("08-workspace-2-by-click")
    click(*ws_chip(1), settle=2)
    key("meta_l-c"); shot("09-status-menu"); key("esc")
    click(*dock_item(0), settle=2); shot("10-apps-grid"); key("esc")
    key("meta_l-s", settle=2); shot("10b-activities"); key("esc")
    key("meta_l-d"); shot("10c-launcher-search"); key("esc")
    click(*POWER, settle=1.5); shot("11-session-menu")

# --- shell log over the serial console --------------------------------------
ser.sendall(b"\n"); time.sleep(1.5)
if b"login:" in bytes(raw[-4000:]):
    ser.sendall(b"root\n"); time.sleep(3)
serial_cmd("su axiom -s /bin/sh -c 'XDG_RUNTIME_DIR=/run/user/1000 qs log --any-display -p /usr/local/share/axiom/shell' 2>&1 | tail -5", "QSDUMP")
loaded = serial_cmd("su axiom -s /bin/sh -c 'XDG_RUNTIME_DIR=/run/user/1000 qs log --any-display -p /usr/local/share/axiom/shell' "
                    "2>&1 | grep -c 'Configuration Loaded'", "QSLOADED")
if not loaded or not re.search(r"^\s*[1-9]\d*\s*$", loaded, re.M):
    bad("shell log unreadable or shell config never loaded")
out = serial_cmd("su axiom -s /bin/sh -c 'XDG_RUNTIME_DIR=/run/user/1000 qs log --any-display -p /usr/local/share/axiom/shell' "
                 "2>&1 | sed 's/\\x1b\\[[0-9;]*m//g' | grep -E '\\.qml:[0-9]|TypeError|ReferenceError' | head -20", "QSLOG")
if out is None:
    bad("could not read the shell log")
else:
    errs = [l for l in out.splitlines()
            if re.search(r"\.qml:\d+|TypeError|ReferenceError", l) and "grep" not in l]
    if errs:
        bad("QML errors in shell log:\n  " + "\n  ".join(errs))
    else:
        ok("no QML errors in the shell log")
osr = serial_cmd("grep PRETTY_NAME /etc/os-release", "OSR")
if osr and "Axiom Linux" in osr:
    ok("os-release reports Axiom Linux")
else:
    bad("os-release does not report Axiom Linux")
fonts = serial_cmd("fc-list : family | grep -cE '^(Inter|JetBrains Mono)'", "FC")
if fonts and re.search(r"^\s*[1-9]\d*\s*$", fonts, re.M):
    ok("Inter and JetBrains Mono installed")
else:
    bad("UI/terminal fonts missing")

# --- power off ----------------------------------------------------------------
# Log root out first: with a second (root) session open, logind treats the
# request as a multi-session power-off, which polkit reserves for admins.
if not SHORT:
    ser.sendall(b"exit\n"); time.sleep(3)
if SHORT:
    # Power off from the still-open root serial shell: the polkit rule in
    # /etc/polkit-1/rules.d lets the desktop user's active session do so even
    # though another (root) session exists.
    # The UART drops bytes when a long line arrives in one burst; pace it.
    _line = f"su axiom -s /bin/sh -c 'XDG_RUNTIME_DIR=/run/user/1000 {QS} powerOff'\n".encode()
    for _i in range(0, len(_line), 24):
        ser.sendall(_line[_i:_i + 24]); time.sleep(0.08)
else:
    # Session menu is still open: the first click only arms Shut Down.
    # Row y follows the 88 px mascot above the menu rows (see 12-shutdown-armed.png).
    shut_down = (W - 8 - 230 + 8 + 115, 261)
    click(*shut_down, settle=1.0); shot("12-shutdown-armed")
    if qemu.poll() is None:
        ok("single click on Shut Down did not power off (confirmation required)")
    else:
        bad("Shut Down fired without confirmation")
    # The row disarms after 4 s (MenuItem). A screendump plus pointer move can
    # take that long on a loaded host, so a confirming click that lands after
    # the timeout only re-arms; click once more, as a user would.
    click(*shut_down, settle=3.0)
    if qemu.poll() is None:
        click(*shut_down, settle=0.5)
try:
    qemu.wait(timeout=120); ok("guest powered off cleanly")
except subprocess.TimeoutExpired:
    bad("guest did not power off within 120s"); qemu.kill()

stop.set(); serial_log.close()
print("RESULT:", "PASS" if not failures else f"FAIL ({len(failures)})")
sys.exit(0 if not failures else 1)
