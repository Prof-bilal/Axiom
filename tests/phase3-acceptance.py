#!/usr/bin/env python3
"""Axiom Phase 3 acceptance driver (QEMU/KVM).

    tests/phase3-acceptance.py <iso> [outdir] [--action powerOff|reboot|logout]

Boots the Phase 3 ISO, waits for the session readiness marker on the serial
console, drives the real UI with keyboard input, verifies notifications
end-to-end with `notify-send`, invokes a session action through the shell's
service boundary, captures display evidence and asserts a clean result.

Constraints: no host shares, no host home, `-nic none` (no networking).
"""
import os, re, socket, subprocess, sys, threading, time

ISO = sys.argv[1] if len(sys.argv) > 1 else ""
OUT = sys.argv[2] if len(sys.argv) > 2 else "iso/out-phase3/evidence/acceptance"
ACTION = "powerOff"
for i, a in enumerate(sys.argv):
    if a == "--action" and i + 1 < len(sys.argv):
        ACTION = sys.argv[i + 1]

OVMF_CODE = "/usr/share/edk2/x64/OVMF_CODE.4m.fd"
OVMF_VARS = "/usr/share/edk2/x64/OVMF_VARS.4m.fd"
MEM, SMP = "2048", "2"
os.makedirs(OUT, exist_ok=True)
SER = os.path.join(OUT, "serial.sock")
MON = os.path.join(OUT, "monitor.sock")
for p in (SER, MON):
    if os.path.exists(p):
        os.unlink(p)
VARS = os.path.join(OUT, "OVMF_VARS.fd")
subprocess.run(["cp", OVMF_VARS, VARS], check=True)

failures = []
def ok(msg):  print("PASS:", msg, flush=True)
def bad(msg): print("FAIL:", msg, flush=True); failures.append(msg)

qemu = subprocess.Popen([
    "qemu-system-x86_64", "-enable-kvm", "-machine", "q35", "-cpu", "host",
    "-m", MEM, "-smp", SMP,
    "-drive", f"if=pflash,format=raw,readonly=on,file={OVMF_CODE}",
    "-drive", f"if=pflash,format=raw,file={VARS}",
    "-vga", "std", "-display", "none",
    "-cdrom", ISO, "-boot", "order=d", "-nic", "none",
    "-serial", f"unix:{SER},server,nowait",
    "-monitor", f"unix:{MON},server,nowait",
    "-pidfile", os.path.join(OUT, "qemu.pid"),
], stdout=open(os.path.join(OUT, "qemu.out"), "wb"), stderr=subprocess.STDOUT)

# ---- serial reader -------------------------------------------------------
ser = None
for _ in range(400):
    if os.path.exists(SER):
        try:
            ser = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            ser.connect(SER); break
        except OSError:
            pass
    time.sleep(0.1)
if ser is None:
    print("no serial socket"); qemu.kill(); sys.exit(2)
ser.settimeout(0.5)
lock = threading.Lock()
raw = bytearray()
markers = {}
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
        with lock:
            raw.extend(data); serial_log.write(data); serial_log.flush()
        for mk in (b"AXIOM_SESSION_START", b"AXIOM_SHELL_READY"):
            if mk not in markers and mk in bytes(raw[-200000:]):
                markers[mk.decode()] = time.monotonic()
threading.Thread(target=reader, daemon=True).start()

def wait_for(needle, timeout):
    end = time.monotonic() + timeout
    while time.monotonic() < end:
        if needle.encode() in bytes(raw):
            return True
        if qemu.poll() is not None:
            return False
        time.sleep(0.3)
    return False

def serial_send(text):
    ser.sendall(text.encode())

# ---- monitor -------------------------------------------------------------
def monitor(cmd, settle=0.4):
    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    s.settimeout(10); s.connect(MON); time.sleep(0.2)
    s.sendall((cmd + "\n").encode()); time.sleep(settle)
    try: s.recv(65536)
    except OSError: pass
    s.close()

def shot(name):
    ppm = os.path.join(OUT, name + ".ppm")
    if os.path.exists(ppm): os.unlink(ppm)
    monitor(f"screendump {ppm}", settle=1.2)
    if not os.path.exists(ppm) or os.path.getsize(ppm) == 0:
        bad(f"screendump {name} produced no file"); return None
    subprocess.run(["magick", ppm, os.path.join(OUT, name + ".png")],
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    ok(f"captured {name}")
    return ppm

def key(combo, settle=1.5):
    monitor(f"sendkey {combo}"); time.sleep(settle)

# ---- steps ---------------------------------------------------------------
t0 = time.monotonic()
if not wait_for("AXIOM_SHELL_READY", 330):
    shot("00-failure")
    tail = bytes(raw[-4000:]).decode(errors="replace")
    print("--- serial tail ---\n" + re.sub(r"\x1b\[[0-9;]*[A-Za-z]", "", tail)[-2500:])
    bad("session did not become ready")
    qemu.kill(); sys.exit(1)
startup = markers.get("AXIOM_SHELL_READY", time.monotonic()) - markers.get("AXIOM_SESSION_START", t0)
ok(f"session ready (start->shell {startup:.1f}s)")

time.sleep(3)
shot("01-desktop")

key("meta_l-d"); shot("02-launcher"); key("esc")
key("meta_l-ret", settle=3.5); shot("03-terminal")
key("meta_l-2"); shot("04-workspace-2"); key("meta_l-1")
key("meta_l-c"); shot("05-control-center"); key("esc")
key("meta_l-shift-e"); shot("06-session-menu"); key("esc")

# ---- notifications over the serial console ------------------------------
ser.sendall(b"\n"); time.sleep(1.5)
if b"login:" in bytes(raw[-4000:]):
    serial_send("root\n"); time.sleep(3)
serial_send("su axiom -s /bin/sh -c 'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus "
            "notify-send -a Axiom \"Phase 3\" \"Notifications are working\"'; echo NS_RC=$?\n")
time.sleep(3)
if b"NS_RC=0" in bytes(raw):
    ok("notify-send accepted by the session notification server")
else:
    bad("notify-send failed (see serial.log)")
time.sleep(1.0)
shot("07-notification-toast")
serial_send("su axiom -s /bin/sh -c 'XDG_RUNTIME_DIR=/run/user/1000 qs ipc --any-display -p /usr/local/share/axiom/shell call axiom toggleNotificationCenter'\n")
time.sleep(2.5)
shot("08-notification-center")

# ---- session action through the shell service boundary ------------------
serial_send(f"su axiom -s /bin/sh -c 'XDG_RUNTIME_DIR=/run/user/1000 qs ipc --any-display -p /usr/local/share/axiom/shell call axiom {ACTION}'\n")
if ACTION == "reboot":
    if wait_for("AXIOM_SHELL_READY", 240):
        ok("reboot reached a fresh graphical session")
        serial_send("su axiom -s /bin/sh -c 'XDG_RUNTIME_DIR=/run/user/1000 qs ipc --any-display -p /usr/local/share/axiom/shell call axiom powerOff'\n")
    else:
        bad("reboot did not return to a session")
else:
    try:
        qemu.wait(timeout=120); ok(f"{ACTION} powered the guest off cleanly")
    except subprocess.TimeoutExpired:
        bad(f"{ACTION} did not power off within 120s")

stop.set(); serial_log.close()
tail = bytes(raw[-20000:]).decode(errors="replace")
tail = re.sub(r"\x1b\[[0-9;]*[A-Za-z]", "", tail)
failed = sorted(set(l.strip() for l in tail.splitlines()
                    if "Failed to start" in l or "Failed to mount" in l))
allowed = os.environ.get("AXIOM_ALLOWED_UNITS")
unallowed = [l for l in failed if not (allowed and re.search(allowed, l))]
if unallowed:
    print("failed units:"); [print("  " + l) for l in unallowed]
    bad("unallowlisted failed units")

print("RESULT:", "PASS" if not failures else f"FAIL ({len(failures)})")
sys.exit(0 if not failures else 1)
