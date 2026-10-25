#!/usr/bin/env bash
# UEFI boot harness for a built Axiom ISO (disposable, no host disks, no network).
#
#   tests/qemu-boot.sh iso/out/<image>.iso [outdir]
#
# Environment overrides: OVMF_CODE, OVMF_VARS_SRC, QEMU_MEM, QEMU_SMP, BOOT_TIMEOUT
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ISO="${1:-}"
OUT="${2:-$ROOT/iso/out/evidence/qemu}"
OVMF_CODE="${OVMF_CODE:-/usr/share/edk2/x64/OVMF_CODE.4m.fd}"
OVMF_VARS_SRC="${OVMF_VARS_SRC:-/usr/share/edk2/x64/OVMF_VARS.4m.fd}"
MEM="${QEMU_MEM:-2048}"
SMP="${QEMU_SMP:-2}"
BOOT_TIMEOUT="${BOOT_TIMEOUT:-240}"
POWEROFF_TIMEOUT="${POWEROFF_TIMEOUT:-90}"

die() { echo "qemu-boot: $*" >&2; exit 1; }

[ -n "$ISO" ] || die "usage: $0 <path-to.iso> [outdir]"
[ -f "$ISO" ] || die "ISO not found: $ISO"

# Verify the ISO against the recorded checksum before anything else, if we have one.
SUM_FILE="${AXIOM_SUMS:-$ROOT/iso/out/evidence/sha256sums.txt}"
if [ -f "$SUM_FILE" ]; then
  base="$(basename "$ISO")"
  expected="$(awk -v f="$base" '$2==f || $2=="*"f {print $1}' "$SUM_FILE" | head -1)"
  if [ -n "$expected" ]; then
    actual="$(sha256sum "$ISO" | awk '{print $1}')"
    [ "$expected" = "$actual" ] || die "ISO checksum mismatch: expected $expected got $actual"
    echo "qemu-boot: checksum OK for $base"
  fi
fi

[ -e /dev/kvm ] || die "/dev/kvm unavailable; accelerated tests are required (never fake this)"
[ -f "$OVMF_CODE" ] || die "OVMF code not found: $OVMF_CODE (install edk2-ovmf)"
[ -f "$OVMF_VARS_SRC" ] || die "OVMF vars not found: $OVMF_VARS_SRC (install edk2-ovmf)"
command -v qemu-system-x86_64 >/dev/null 2>&1 || die "qemu-system-x86_64 not found"
command -v python3 >/dev/null 2>&1 || die "python3 not found (used only for the QEMU monitor socket)"

mkdir -p "$OUT"

cp "$OVMF_VARS_SRC" "$OUT/OVMF_VARS.4m.fd"
SERIAL="$OUT/serial.log"
MON="$OUT/monitor.sock"
: > "$SERIAL"
rm -f "$MON"

qemu-system-x86_64 \
  -enable-kvm -machine q35 -cpu host -m "$MEM" -smp "$SMP" \
  -drive if=pflash,format=raw,readonly=on,file="$OVMF_CODE" \
  -drive if=pflash,format=raw,file="$OUT/OVMF_VARS.4m.fd" \
  -cdrom "$ISO" -boot order=d -nic none -display none \
  -serial "file:$SERIAL" \
  -monitor "unix:$MON,server,nowait" \
  -pidfile "$OUT/qemu.pid" &
QEMU_PID=$!

cleanup() {
  if kill -0 "$QEMU_PID" 2>/dev/null; then
    kill -TERM "$QEMU_PID" 2>/dev/null || true
    sleep 2
    kill -KILL "$QEMU_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT

monitor() {
  python3 - "$MON" "$1" <<'PY'
import socket, sys, time
sock_path, cmd = sys.argv[1], sys.argv[2]
s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
s.settimeout(5)
s.connect(sock_path)
time.sleep(0.2)
s.sendall((cmd + "\n").encode())
time.sleep(0.2)
try:
    s.recv(4096)
except OSError:
    pass
s.close()
PY
}

echo "qemu-boot: waiting up to ${BOOT_TIMEOUT}s for boot completion"
deadline=$(( SECONDS + BOOT_TIMEOUT ))
booted=0
while [ "$SECONDS" -lt "$deadline" ]; do
  if ! kill -0 "$QEMU_PID" 2>/dev/null; then
    die "QEMU exited before boot completed; see $SERIAL"
  fi
  if grep -q "Startup finished in" "$SERIAL" 2>/dev/null; then
    booted=1
    break
  fi
  sleep 2
done
[ "$booted" -eq 1 ] || die "boot did not reach 'Startup finished' within ${BOOT_TIMEOUT}s; see $SERIAL"
echo "qemu-boot: guest reached boot completion"

if grep -Eq "Failed to start|Failed to mount" "$SERIAL"; then
  echo "qemu-boot: WARNING: 'Failed to ...' lines present in serial log:" >&2
  grep -E "Failed to start|Failed to mount" "$SERIAL" | head -20 >&2
fi

echo "qemu-boot: requesting clean poweroff via monitor"
monitor "system_powerdown"
deadline=$(( SECONDS + POWEROFF_TIMEOUT ))
while kill -0 "$QEMU_PID" 2>/dev/null; do
  [ "$SECONDS" -lt "$deadline" ] || die "guest did not power off within ${POWEROFF_TIMEOUT}s"
  sleep 2
done
wait "$QEMU_PID" 2>/dev/null || true
trap - EXIT
echo "qemu-boot: clean shutdown; serial log at $SERIAL"

if grep -Eq "Failed to start|Failed to mount" "$SERIAL"; then
  die "boot had failed units; see $SERIAL"
fi
echo "qemu-boot: PASS"
