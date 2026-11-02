#!/usr/bin/env python3
"""Axiom Phase 3 measurement driver (QEMU/KVM).

    tests/phase3-perf.py <iso> [outdir] [--res 1920x1080]

Boots the Phase 3 ISO, waits for the shell, lets the desktop idle, then reads
real numbers from inside the guest over the root serial console:

  - boot timeline: kernel/userspace (systemd-analyze) and guest-monotonic
    timestamps for the session and shell start (journal + process start time)
  - idle memory (RSS/PSS) of quickshell, labwc and the whole session
  - idle CPU of quickshell and labwc over a fixed window (/proc deltas)
  - shell-surface latency: launcher toggle and notification round trip,
    timed in the guest against the real IPC/D-Bus paths

Results are written to <outdir>/perf.json and printed. These are numbers for a
KVM guest with software rendering (pixman); they are not hardware claims.
No networking, no host shares.
"""
import json, os, re, socket, subprocess, sys, threading, time

args = sys.argv[1:]
ISO = args[0] if args else ""
OUT = args[1] if len(args) > 1 and not args[1].startswith("--") else "iso/out-phase3/evidence/perf"
RES = "1920x1080"
for i, a in enumerate(args):
    if a == "--res" and i + 1 < len(args):
        RES = args[i + 1]
W, H = (int(v) for v in RES.split("x"))
if not os.path.isfile(ISO):
    print("usage: phase3-perf.py <iso> [outdir] [--res WxH]"); sys.exit(2)

OVMF_CODE = "/usr/share/edk2/x64/OVMF_CODE.4m.fd"
OVMF_VARS = "/usr/share/edk2/x64/OVMF_VARS.4m.fd"
os.makedirs(OUT, exist_ok=True)
SER = os.path.join(OUT, "serial.sock")
if os.path.exists(SER):
    os.unlink(SER)
VARS = os.path.join(OUT, "OVMF_VARS.fd")
subprocess.run(["cp", OVMF_VARS, VARS], check=True)

qemu = subprocess.Popen([
    "qemu-system-x86_64", "-enable-kvm", "-machine", "q35", "-cpu", "host",
    "-m", "2048", "-smp", "2",
    "-drive", f"if=pflash,format=raw,readonly=on,file={OVMF_CODE}",
    "-drive", f"if=pflash,format=raw,file={VARS}",
    "-vga", "none", "-device", f"VGA,edid=on,xres={W},yres={H}",
    "-display", "none", "-cdrom", ISO, "-boot", "order=d", "-nic", "none",
    "-serial", f"unix:{SER},server,nowait",
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
log = open(os.path.join(OUT, "serial.log"), "wb")
stop = threading.Event()

def reader():
    while not stop.is_set():
        try:
            d = ser.recv(65536)
        except socket.timeout:
            continue
        except OSError:
            break
        if not d:
            break
        raw.extend(d); log.write(d); log.flush()
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

ANSI = re.compile(r"\x1b\[[0-9;?]*[A-Za-z]|\x1b[()][A-Z0-9]|\x1b[=>]|\r")
def run(cmd, marker, timeout=40):
    """Run cmd on the root serial shell; return cleaned output between echo and marker."""
    start = len(raw)
    for i in range(0, len(cmd), 40):          # the UART drops bytes if fed too fast
        ser.sendall(cmd[i:i + 40].encode()); time.sleep(0.04)
    ser.sendall(f"; echo {marker}=$?\n".encode())
    end = time.monotonic() + timeout
    while time.monotonic() < end:
        text = ANSI.sub("", bytes(raw[start:]).decode(errors="replace"))
        m = re.search(rf"^{marker}=\d+", text, re.M)
        if m:
            return text[:m.start()]
        if qemu.poll() is not None:
            return None
        time.sleep(0.3)
    return None

QS = "qs ipc --any-display -p /usr/local/share/axiom/shell"
t_host0 = time.monotonic()
if not wait_for("login:", 240):
    print("STALL: no login prompt (firmware-stage flake)"); qemu.kill(); sys.exit(3)
t_login = time.monotonic() - t_host0
ser.sendall(b"root\n"); time.sleep(3)
ready = False
end = time.monotonic() + 330
while time.monotonic() < end and not ready:
    out = run(f"su axiom -s /bin/sh -c 'XDG_RUNTIME_DIR=/run/user/1000 {QS} show' 2>/dev/null | grep -c 'target axiom'", "RDY", 20)
    ready = bool(out and re.search(r"^\s*[1-9]\d*\s*$", out, re.M))
    if not ready:
        time.sleep(3)
if not ready:
    print("FAIL: shell never became ready"); qemu.kill(); sys.exit(1)
t_ready = time.monotonic() - t_host0
print(f"shell ready {t_ready:.1f}s after QEMU start (login prompt at {t_login:.1f}s)")

R = {"resolution": RES, "host_wall_s": {"to_login_prompt": round(t_login, 1), "to_shell_ready": round(t_ready, 1)}}

def grab(label, cmd, marker):
    out = run(cmd, marker)
    R[label] = out.strip() if out else None
    return out

grab("systemd_analyze", "systemd-analyze 2>&1 | head -2", "SA")
# Guest-monotonic timeline (seconds since kernel start) from /proc and the journal.
grab("session_timeline",
     "for p in labwc quickshell; do pid=$(pgrep -xo $p); "
     "[ -n \"$pid\" ] && echo $p start_s=$(awk -v t=$(awk '{print $22}' /proc/$pid/stat) -v h=$(getconf CLK_TCK) 'BEGIN{printf \"%.1f\", t/h}'); done; "
     "echo uptime_s=$(cut -d' ' -f1 /proc/uptime)", "TL")
print("idle for 40 s before sampling ...")
time.sleep(40)

grab("memory_kb",
     "for p in quickshell labwc foot Xwayland; do for pid in $(pgrep -x $p); do "
     "echo $p rss_kb=$(awk '/VmRSS/{print $2}' /proc/$pid/status) pss_kb=$(awk '/^Pss:/{print $2}' /proc/$pid/smaps_rollup); done; done; "
     "echo mem_used_kb=$(awk '/MemTotal/{t=$2}/MemAvailable/{a=$2}END{print t-a}' /proc/meminfo)", "MEM")

# Idle CPU: utime+stime delta of each process over a 20 s window, as % of one core.
cpu = run(
    "for p in quickshell labwc; do pid=$(pgrep -xo $p); "
    "a=$(awk '{print $14+$15}' /proc/$pid/stat); echo $p $pid $a; done > /tmp/c1; sleep 20; "
    "while read p pid a; do b=$(awk '{print $14+$15}' /proc/$pid/stat); "
    "echo $p cpu_pct=$(awk -v a=$a -v b=$b -v h=$(getconf CLK_TCK) 'BEGIN{printf \"%.2f\", (b-a)/h/20*100}'); done < /tmp/c1", "CPU", 60)
R["idle_cpu_pct_of_one_core_over_20s"] = cpu.strip() if cpu else None

# Interaction latency, measured in the guest against the real IPC and D-Bus paths.
lat = run(
    f"su axiom -s /bin/sh -c 'XDG_RUNTIME_DIR=/run/user/1000; export XDG_RUNTIME_DIR; "
    f"eval export $(tr \"\\0\" \"\\n\" < /proc/$(pgrep -xo quickshell)/environ | grep ^DBUS_SESSION_BUS_ADDRESS=); "
    f"for i in 1 2 3 4 5; do s=$(date +%s%N); {QS} call axiom toggleLauncher >/dev/null; e=$(date +%s%N); echo ipc_toggle_ms=$(( (e-s)/1000000 )); {QS} call axiom closeOverlays >/dev/null; done; "
    f"for i in 1 2 3; do s=$(date +%s%N); notify-send -a Axiom perf msg$i; e=$(date +%s%N); echo notify_ms=$(( (e-s)/1000000 )); done'",
    "LAT", 90)
R["latency_ms"] = lat.strip() if lat else None

grab("versions",
     "echo qemu_guest_kernel=$(uname -r); pacman -Q quickshell labwc qt6-base foot 2>/dev/null | tr '\\n' ' '; echo; "
     "echo renderer=$(su axiom -s /bin/sh -c 'tr \"\\0\" \"\\n\" < /proc/$(pgrep -xo labwc)/environ | grep -E ^WLR_RENDERER' 2>/dev/null)", "VER")

host = subprocess.run(["qemu-system-x86_64", "--version"], capture_output=True, text=True).stdout.splitlines()[0]
R["environment"] = {"qemu": host, "kvm": True, "guest_ram_mib": 2048, "vcpus": 2, "gpu": "VGA (software rendering)",
                    "iso": os.path.basename(ISO)}

# Clean power off: log root out first so logind treats the request as single-session.
_line = f"su axiom -s /bin/sh -c 'XDG_RUNTIME_DIR=/run/user/1000 {QS} call axiom powerOff'\n".encode()
for _i in range(0, len(_line), 24):            # the UART drops bytes on long bursts
    ser.sendall(_line[_i:_i + 24]); time.sleep(0.08)
try:
    qemu.wait(timeout=120); R["poweroff"] = "clean"
except subprocess.TimeoutExpired:
    R["poweroff"] = "timeout"; qemu.kill()
stop.set(); log.close()
json.dump(R, open(os.path.join(OUT, "perf.json"), "w"), indent=2)
print(json.dumps(R, indent=2))
sys.exit(0 if R["poweroff"] == "clean" else 1)
