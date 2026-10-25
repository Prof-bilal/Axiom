#!/usr/bin/env bash
# UEFI boot harness for a built Axiom ISO (disposable, no host disks, no network).
#
#   tests/qemu-boot.sh iso/out/<image>.iso [outdir]
#
# Environment overrides:
#   OVMF_CODE, OVMF_VARS_SRC, QEMU_MEM, QEMU_SMP, BOOT_TIMEOUT, POWEROFF_TIMEOUT,
#   QEMU_BOOT_ATTEMPTS, AXIOM_SUMS, AXIOM_ALLOWED_UNITS
#
# A firmware-stage stall (UEFI never hands off to the ISO, so no guest output appears)
# is a known host/QEMU flakiness; such an attempt is retried up to QEMU_BOOT_ATTEMPTS.
# An attempt that produced guest output but failed is never retried. Every attempt's
# serial log is kept for evidence.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ISO="${1:-}"
OUT="${2:-$ROOT/iso/out/evidence/qemu}"
OVMF_CODE="${OVMF_CODE:-/usr/share/edk2/x64/OVMF_CODE.4m.fd}"
OVMF_VARS_SRC="${OVMF_VARS_SRC:-/usr/share/edk2/x64/OVMF_VARS.4m.fd}"
MEM="${QEMU_MEM:-1536}"
SMP="${QEMU_SMP:-2}"
BOOT_TIMEOUT="${BOOT_TIMEOUT:-240}"
POWEROFF_TIMEOUT="${POWEROFF_TIMEOUT:-90}"
ATTEMPTS="${QEMU_BOOT_ATTEMPTS:-3}"
FIRMWARE_ONLY_BYTES=4096

die() { echo "qemu-boot: $*" >&2; exit 1; }

[ -n "$ISO" ] || die "usage: $0 <path-to.iso> [outdir]"
[ -f "$ISO" ] || die "ISO not found: $ISO"

# Verify the ISO against the recorded checksum before anything else, if we have one.
SUM_FILE="${AXIOM_SUMS:-$ROOT/iso/out/evidence/sha256sums.txt}"
if [ -f "$SUM_FILE" ]; then
  base="$(basename "$ISO")"
  expected="$(awk -v f="$base" '{p=$2; sub(/^\*/, "", p); sub(/^\.\//, "", p); if (p==f) {print $1; exit}}' "$SUM_FILE")"
  if [ -n "$expected" ]; then
    actual="$(sha256sum "$ISO" | awk '{print $1}')"
    [ "$expected" = "$actual" ] || die "ISO checksum mismatch: expected $expected got $actual"
    echo "qemu-boot: checksum OK for $base"
  else
    echo "qemu-boot: WARNING: no recorded checksum for $base in $SUM_FILE" >&2
  fi
fi

[ -e /dev/kvm ] || die "/dev/kvm unavailable; accelerated tests are required (never fake this)"
[ -f "$OVMF_CODE" ] || die "OVMF code not found: $OVMF_CODE (install edk2-ovmf)"
[ -f "$OVMF_VARS_SRC" ] || die "OVMF vars not found: $OVMF_VARS_SRC (install edk2-ovmf)"
command -v qemu-system-x86_64 >/dev/null 2>&1 || die "qemu-system-x86_64 not found"
command -v python3 >/dev/null 2>&1 || die "python3 not found (used only for the QEMU monitor socket)"

# A guest much larger than available host memory stalls in firmware; surface that
# rather than letting it look like a guest defect.
mem_avail_kb="$(awk '/^MemAvailable/{print $2}' /proc/meminfo 2>/dev/null || echo 0)"
if [ "${mem_avail_kb:-0}" -gt 0 ] && [ "$mem_avail_kb" -lt $(( MEM * 1024 )) ]; then
  echo "qemu-boot: WARNING: ${mem_avail_kb} KiB host memory available is below the ${MEM} MiB guest; boot may stall" >&2
fi

mkdir -p "$OUT"
MON="$OUT/monitor.sock"

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

qemu_pid=""
cleanup() {
  if [ -n "$qemu_pid" ] && kill -0 "$qemu_pid" 2>/dev/null; then
    kill -TERM "$qemu_pid" 2>/dev/null || true
    sleep 2
    kill -KILL "$qemu_pid" 2>/dev/null || true
  fi
}
trap cleanup EXIT

booted=0
attempt=0
serial=""
while [ "$attempt" -lt "$ATTEMPTS" ]; do
  attempt=$((attempt + 1))
  serial="$OUT/serial.attempt${attempt}.log"
  cp "$OVMF_VARS_SRC" "$OUT/OVMF_VARS.4m.fd"
  : > "$serial"
  rm -f "$MON"

  qemu-system-x86_64 \
    -enable-kvm -machine q35 -cpu host -m "$MEM" -smp "$SMP" \
    -drive if=pflash,format=raw,readonly=on,file="$OVMF_CODE" \
    -drive if=pflash,format=raw,file="$OUT/OVMF_VARS.4m.fd" \
    -cdrom "$ISO" -boot order=d -nic none -display none \
    -serial "file:$serial" \
    -monitor "unix:$MON,server,nowait" \
    -pidfile "$OUT/qemu.pid" \
    </dev/null >"$OUT/qemu.attempt${attempt}.out" 2>&1 &
  qemu_pid=$!

  echo "qemu-boot: attempt $attempt/$ATTEMPTS (guest ${MEM} MiB); waiting up to ${BOOT_TIMEOUT}s"
  deadline=$(( SECONDS + BOOT_TIMEOUT ))
  booted=0
  while [ "$SECONDS" -lt "$deadline" ]; do
    kill -0 "$qemu_pid" 2>/dev/null || break
    if grep -qE "Startup finished in|Reached target .*Login Prompts|login:" "$serial" 2>/dev/null; then
      booted=1
      break
    fi
    sleep 2
  done

  if [ "$booted" -eq 1 ]; then
    break
  fi

  progress="$(wc -c < "$serial" 2>/dev/null || echo 0)"
  kill -0 "$qemu_pid" 2>/dev/null && echo "qemu-boot: attempt $attempt ended without a login prompt (${progress} bytes captured)" >&2
  if [ -n "$qemu_pid" ] && kill -0 "$qemu_pid" 2>/dev/null; then
    kill -TERM "$qemu_pid" 2>/dev/null || true
    sleep 2
    kill -KILL "$qemu_pid" 2>/dev/null || true
  fi
  wait "$qemu_pid" 2>/dev/null || true
  qemu_pid=""

  if [ "$progress" -lt "$FIRMWARE_ONLY_BYTES" ] && [ "$attempt" -lt "$ATTEMPTS" ]; then
    echo "qemu-boot: firmware never handed off (host flakiness); retrying" >&2
    continue
  fi
  break
done

[ "$booted" -eq 1 ] || die "boot did not reach a login prompt after ${attempt} attempt(s) (host MemAvailable ${mem_avail_kb:-?} KiB); see $serial"
cp "$serial" "$OUT/serial.log"
echo "qemu-boot: guest reached a login prompt on attempt $attempt"

echo "qemu-boot: requesting clean poweroff via monitor"
monitor "system_powerdown"
deadline=$(( SECONDS + POWEROFF_TIMEOUT ))
while kill -0 "$qemu_pid" 2>/dev/null; do
  [ "$SECONDS" -lt "$deadline" ] || die "guest did not power off within ${POWEROFF_TIMEOUT}s"
  sleep 2
done
wait "$qemu_pid" 2>/dev/null || true
qemu_pid=""
trap - EXIT
echo "qemu-boot: clean shutdown; serial log at $OUT/serial.log (${attempt} attempt(s))"

# Report failed units loudly. Non-empty AXIOM_ALLOWED_UNITS (an extended regex) is the
# only way to accept a failure, and it must be justified in the evidence record.
mapfile -t failed < <(sed 's/\x1b\[[0-9;]*m//g' "$OUT/serial.log" | grep -E "Failed to start|Failed to mount" | sort -u)
if [ "${#failed[@]}" -gt 0 ]; then
  echo "qemu-boot: ${#failed[@]} failed-unit line(s) in serial log:"
  printf '  %s\n' "${failed[@]}"
  if [ -n "${AXIOM_ALLOWED_UNITS:-}" ]; then
    remaining=()
    for line in "${failed[@]}"; do
      grep -Eq "${AXIOM_ALLOWED_UNITS}" <<<"$line" || remaining+=("$line")
    done
    if [ "${#remaining[@]}" -gt 0 ]; then
      printf 'qemu-boot: unallowlisted failures:\n  %s\n' "${remaining[@]}" >&2
      die "boot had non-allowlisted failed units; see $OUT/serial.log"
    fi
    echo "qemu-boot: all failed-unit lines matched AXIOM_ALLOWED_UNITS='${AXIOM_ALLOWED_UNITS}'"
  else
    die "boot had failed units and AXIOM_ALLOWED_UNITS was not set; see $OUT/serial.log"
  fi
fi
echo "qemu-boot: PASS"
