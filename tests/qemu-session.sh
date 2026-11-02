#!/usr/bin/env bash
# QEMU acceptance test for the Axiom Phase 3 graphical session.
#
#   tests/qemu-session.sh iso/out-phase3/<image>.iso [outdir]
#
# Boots the Phase 3 ISO in UEFI QEMU/KVM with a virtual GPU, waits for the
# session's serial readiness marker, drives real keyboard input, captures
# display evidence at each step and verifies a clean shutdown.
#
# Environment: OVMF_CODE, OVMF_VARS_SRC, QEMU_MEM, QEMU_SMP, SESSION_TIMEOUT,
#              POWEROFF_TIMEOUT, AXIOM_SUMS, AXIOM_ALLOWED_UNITS
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ISO="${1:-}"
OUT="${2:-$ROOT/iso/out-phase3/evidence/qemu-session}"
OVMF_CODE="${OVMF_CODE:-/usr/share/edk2/x64/OVMF_CODE.4m.fd}"
OVMF_VARS_SRC="${OVMF_VARS_SRC:-/usr/share/edk2/x64/OVMF_VARS.4m.fd}"
MEM="${QEMU_MEM:-2048}"
SMP="${QEMU_SMP:-2}"
SESSION_TIMEOUT="${SESSION_TIMEOUT:-300}"
POWEROFF_TIMEOUT="${POWEROFF_TIMEOUT:-120}"

die() { echo "qemu-session: $*" >&2; exit 1; }

[ -n "$ISO" ] || die "usage: $0 <path-to.iso> [outdir]"
[ -f "$ISO" ] || die "ISO not found: $ISO"
[ -e /dev/kvm ] || die "/dev/kvm unavailable; accelerated tests are required"
[ -f "$OVMF_CODE" ] || die "OVMF code not found: $OVMF_CODE"
[ -f "$OVMF_VARS_SRC" ] || die "OVMF vars not found: $OVMF_VARS_SRC"
command -v qemu-system-x86_64 >/dev/null 2>&1 || die "qemu-system-x86_64 not found"

SUM_FILE="${AXIOM_SUMS:-$ROOT/iso/out-phase3/evidence/sha256sums.txt}"
if [ -f "$SUM_FILE" ]; then
  base="$(basename "$ISO")"
  expected="$(awk -v f="$base" '{p=$2; sub(/^\*/, "", p); sub(/^\.\//, "", p); if (p==f) {print $1; exit}}' "$SUM_FILE")"
  if [ -n "$expected" ]; then
    actual="$(sha256sum "$ISO" | awk '{print $1}')"
    [ "$expected" = "$actual" ] || die "ISO checksum mismatch"
    echo "qemu-session: checksum OK"
  fi
fi

mkdir -p "$OUT"
MON="$OUT/monitor.sock"
SERIAL="$OUT/serial.log"
rm -f "$MON" "$SERIAL"
cp "$OVMF_VARS_SRC" "$OUT/OVMF_VARS.4m.fd"

monitor() {
  python3 - "$MON" "$1" <<'PY'
import socket, sys, time
sock_path, cmd = sys.argv[1], sys.argv[2]
s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
s.settimeout(10)
s.connect(sock_path)
time.sleep(0.2)
s.sendall((cmd + "\n").encode())
time.sleep(0.4)
try:
    s.recv(65536)
except OSError:
    pass
s.close()
PY
}

# Monitor command that needs a longer settle time (screendump writes a file).
monitor_wait() {
  monitor "$1"
  sleep 1
}

screenshot() {
  local name="$1"
  monitor_wait "screendump $OUT/$name.ppm"
  if [ -s "$OUT/$name.ppm" ]; then
    if command -v magick >/dev/null 2>&1; then
      magick "$OUT/$name.ppm" "$OUT/$name.png" 2>/dev/null || true
    elif command -v convert >/dev/null 2>&1; then
      convert "$OUT/$name.ppm" "$OUT/$name.png" 2>/dev/null || true
    fi
    echo "qemu-session: captured $name"
  else
    echo "qemu-session: WARNING: screendump $name produced no file" >&2
  fi
}

qemu_pid=""
cleanup() {
  if [ -n "$qemu_pid" ] && kill -0 "$qemu_pid" 2>/dev/null; then
    kill -TERM "$qemu_pid" 2>/dev/null || true
    sleep 2
    kill -KILL "$qemu_pid" 2>/dev/null || true
  fi
}
trap cleanup EXIT

echo "qemu-session: booting ($MEM MiB, $SMP vCPU, standard VGA)"
qemu-system-x86_64 \
  -enable-kvm -machine q35 -cpu host -m "$MEM" -smp "$SMP" \
  -drive if=pflash,format=raw,readonly=on,file="$OVMF_CODE" \
  -drive if=pflash,format=raw,file="$OUT/OVMF_VARS.4m.fd" \
  -vga std -display none \
  -cdrom "$ISO" -boot order=d -nic none \
  -serial "file:$SERIAL" \
  -monitor "unix:$MON,server,nowait" \
  -pidfile "$OUT/qemu.pid" \
  </dev/null >"$OUT/qemu.out" 2>&1 &
qemu_pid=$!

echo "qemu-session: waiting for AXIOM_SHELL_READY (up to ${SESSION_TIMEOUT}s)"
deadline=$(( SECONDS + SESSION_TIMEOUT ))
ready=0
stalled_since=""
while [ "$SECONDS" -lt "$deadline" ]; do
  kill -0 "$qemu_pid" 2>/dev/null || break
  if grep -q "AXIOM_SHELL_READY" "$SERIAL" 2>/dev/null; then ready=1; break; fi
  # Known host/QEMU firmware-stage stall: no guest output at all for a long
  # time. Restart once rather than treating it as a guest defect.
  if [ ! -s "$SERIAL" ]; then
    [ -n "$stalled_since" ] || stalled_since="$SECONDS"
    if [ $(( SECONDS - stalled_since )) -ge 75 ] && [ "${retried:-0}" -eq 0 ]; then
      echo "qemu-session: firmware produced no output for 75s; restarting once" >&2
      retried=1; stalled_since=""
      kill -TERM "$qemu_pid" 2>/dev/null || true; sleep 2
      kill -KILL "$qemu_pid" 2>/dev/null || true
      wait "$qemu_pid" 2>/dev/null || true
      cp "$OVMF_VARS_SRC" "$OUT/OVMF_VARS.4m.fd"
      : > "$SERIAL"
      rm -f "$MON"
      qemu-system-x86_64 \
        -enable-kvm -machine q35 -cpu host -m "$MEM" -smp "$SMP" \
        -drive if=pflash,format=raw,readonly=on,file="$OVMF_CODE" \
        -drive if=pflash,format=raw,file="$OUT/OVMF_VARS.4m.fd" \
        -vga std -display none \
        -cdrom "$ISO" -boot order=d -nic none \
        -serial "file:$SERIAL" \
        -monitor "unix:$MON,server,nowait" \
        -pidfile "$OUT/qemu.pid" \
        </dev/null >"$OUT/qemu.out" 2>&1 &
      qemu_pid=$!
    fi
  else
    stalled_since=""
  fi
  sleep 2
done

if [ "$ready" -ne 1 ]; then
  # Capture the framebuffer even on failure so a blank/rendering defect is
  # distinguishable from a harness defect.
  screenshot "00-failure" || true
  echo "qemu-session: session never became ready; last serial lines:" >&2
  sed 's/\x1b\[[0-9;]*[A-Za-z]//g' "$SERIAL" 2>/dev/null | tail -40 >&2 || true
  die "graphical session did not start"
fi

echo "qemu-session: session ready"
sleep 3
screenshot "01-desktop"

echo "qemu-session: opening launcher (Mod4+D)"
monitor "sendkey meta_l-d"
sleep 2
screenshot "02-launcher"
monitor "sendkey esc"
sleep 1

echo "qemu-session: opening a terminal (Mod4+Return)"
monitor "sendkey meta_l-ret"
sleep 4
screenshot "03-terminal"

echo "qemu-session: switching workspace (Mod4+2)"
monitor "sendkey meta_l-2"
sleep 2
screenshot "04-workspace-2"
monitor "sendkey meta_l-1"
sleep 1

echo "qemu-session: opening control center (Mod4+C)"
monitor "sendkey meta_l-c"
sleep 2
screenshot "05-control-center"
monitor "sendkey esc"
sleep 1

echo "qemu-session: opening session menu (Mod4+Shift+E)"
monitor "sendkey meta_l-shift-e"
sleep 2
screenshot "06-session-menu"
monitor "sendkey esc"
sleep 1

echo "qemu-session: requesting clean poweroff"
monitor "system_powerdown"
deadline=$(( SECONDS + POWEROFF_TIMEOUT ))
while kill -0 "$qemu_pid" 2>/dev/null; do
  [ "$SECONDS" -lt "$deadline" ] || die "guest did not power off within ${POWEROFF_TIMEOUT}s"
  sleep 2
done
wait "$qemu_pid" 2>/dev/null || true
qemu_pid=""
trap - EXIT

echo "qemu-session: guest shut down"

mapfile -t failed < <(sed 's/\x1b\[[0-9;]*m//g' "$SERIAL" | grep -E "Failed to start|Failed to mount" | sort -u)
if [ "${#failed[@]}" -gt 0 ]; then
  echo "qemu-session: ${#failed[@]} failed-unit line(s):"
  printf '  %s\n' "${failed[@]}"
  if [ -n "${AXIOM_ALLOWED_UNITS:-}" ]; then
    remaining=()
    for line in "${failed[@]}"; do
      grep -Eq "${AXIOM_ALLOWED_UNITS}" <<<"$line" || remaining+=("$line")
    done
    [ "${#remaining[@]}" -eq 0 ] || { printf 'qemu-session: unallowlisted:\n  %s\n' "${remaining[@]}" >&2; die "failed units"; }
  else
    die "failed units and AXIOM_ALLOWED_UNITS not set"
  fi
fi

echo "qemu-session: PASS (evidence in $OUT)"
