#!/usr/bin/env bash
# Phase 2 baseline boot for the pinned Omarchy stable VM image.
#
#   tests/omarchy-vm-boot.sh [outdir] [-- command...]
#
# The image is never modified: QEMU runs a disposable qcow2 overlay. The VM gets
# a new SSH key and machine ID per boot, no host shares and user-mode networking
# only for SSH/serial probes. VNC is bound to localhost on :1.
#
# Environment overrides:
#   AXIOM_OMARCHY_VM     unpacked VM dir (default workspace/upstream/omarchy-vm)
#   AXIOM_OMARCHY_DISK   base qcow2 (default workspace/upstream/omarchy-4.0.6.qcow2)
#   QEMU_MEM, QEMU_SMP, SSH_PORT, VNC_DISPLAY
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VM_DIR="${AXIOM_OMARCHY_VM:-$ROOT/workspace/upstream/omarchy-vm}"
DISK="${AXIOM_OMARCHY_DISK:-$ROOT/workspace/upstream/omarchy-4.0.6.qcow2}"
OUT="${1:-$ROOT/iso/out/evidence/phase2/omarchy-boot}"
[[ $# -eq 0 ]] || shift
if [[ ${1:-} == "--" ]]; then shift; fi

die() { echo "omarchy-vm-boot: $*" >&2; exit 1; }
for f in vmlinuz initrd cmdline; do
  [[ -s "$VM_DIR/$f" ]] || die "missing $VM_DIR/$f"
done
[[ -s "$DISK" ]] || die "missing base image $DISK (download the pinned stable qcow2)"
SUM_FILE="${AXIOM_OMARCHY_SHA256:-$DISK.sha256}"
if [[ -f "$SUM_FILE" ]]; then
  expected="$(awk '{print $1; exit}' "$SUM_FILE")"
  actual="$(sha256sum "$DISK" | awk '{print $1}')"
  [[ "$expected" == "$actual" ]] || die "base image checksum mismatch: expected $expected got $actual"
  echo "omarchy-vm-boot: base image checksum OK" >&2
else
  echo "omarchy-vm-boot: WARNING: no checksum at $SUM_FILE" >&2
fi
[[ -r /dev/kvm && -w /dev/kvm ]] || die "/dev/kvm is not usable"
for t in qemu-system-x86_64 qemu-img ssh-keygen ssh; do
  command -v "$t" >/dev/null 2>&1 || die "missing $t"
done

mkdir -p "$OUT"
STATE="$OUT/state"
rm -rf "$STATE"
mkdir -p "$STATE"
RUN="$STATE/run.qcow2"
PIDFILE="$STATE/qemu.pid"
QMP="$STATE/qmp.sock"
if (( ${#QMP} >= 100 )); then
  QMP="/tmp/axiom-omarchy-qmp-$$.sock"
fi
SERIAL="$OUT/serial.log"
: >"$SERIAL"

qemu_img="$(command -v qemu-img)"
"$qemu_img" create -qf qcow2 -b "$(realpath "$DISK")" -F qcow2 "$RUN" >/dev/null

ssh-keygen -q -t ed25519 -N '' -C axiom-omarchy-vm -f "$STATE/id_ed25519"
keys=$(printf 'd /home/omarchy/.ssh 0700 omarchy omarchy -\nf+ /home/omarchy/.ssh/authorized_keys 0600 omarchy omarchy - %s\n' \
  "$(cat "$STATE/id_ed25519.pub")" | base64 -w0)

port="${SSH_PORT:-2222}"
vnc="${VNC_DISPLAY:-1}"
uuid="$(cat /proc/sys/kernel/random/uuid)"
mem="${QEMU_MEM:-8G}"
smp="${QEMU_SMP:-4}"

display_args=(-device VGA -display none -vnc "127.0.0.1:${vnc}")
# Prefer virtio-vga when this QEMU build provides it; otherwise standard VGA.
if qemu-system-x86_64 -device help 2>&1 | grep -q 'name "virtio-vga'; then
  display_args=(-device virtio-vga -display none -vnc "127.0.0.1:${vnc}")
fi

qemu_pid=""
cleanup() {
  local status=$?
  if [[ -n "$qemu_pid" ]] && kill -0 "$qemu_pid" 2>/dev/null; then
    kill "$qemu_pid" 2>/dev/null || true
    for _ in $(seq 1 50); do kill -0 "$qemu_pid" 2>/dev/null || break; sleep 0.1; done
    kill -KILL "$qemu_pid" 2>/dev/null || true
  fi
  rm -f "$QMP"
  exit "$status"
}
trap cleanup EXIT
trap 'exit 130' INT TERM

# vm-boot-compatible credential injection; no password login.
qemu-system-x86_64 \
  -cpu host -enable-kvm -machine q35,accel=kvm \
  -smp "$smp" -m "$mem" \
  -kernel "$VM_DIR/vmlinuz" -initrd "$VM_DIR/initrd" \
  -append "$(cat "$VM_DIR/cmdline") console=ttyS0,115200 loglevel=4 systemd.show_status=true" \
  -uuid "$uuid" \
  -drive "file=$RUN,format=qcow2,if=none,id=d0" \
  -device virtio-blk-pci,drive=d0 \
  -smbios "type=11,value=io.systemd.credential.binary:tmpfiles.extra=$keys" \
  "${display_args[@]}" \
  -device virtio-rng-pci \
  -netdev "user,id=n0,hostfwd=tcp:127.0.0.1:${port}-:22" \
  -device virtio-net-pci,netdev=n0 \
  -serial "file:$SERIAL" \
  -qmp "unix:$QMP,server,nowait" \
  -pidfile "$PIDFILE" -daemonize
qemu_pid="$(cat "$PIDFILE")"

ssh_opts=(-i "$STATE/id_ed25519" -p "$port" -o BatchMode=yes -o IdentitiesOnly=yes
  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR
  -o ConnectTimeout=1)
echo "omarchy-vm-boot: waiting for SSH on 127.0.0.1:$port (VNC :$vnc, QMP $QMP)" >&2
deadline=$((SECONDS + 300))
until ssh "${ssh_opts[@]}" omarchy@127.0.0.1 true </dev/null 2>/dev/null; do
  kill -0 "$qemu_pid" 2>/dev/null || die "QEMU exited before SSH was ready; see $SERIAL"
  (( SECONDS < deadline )) || die "no SSH after 300s; see $SERIAL"
  sleep 0.5
done
echo "omarchy-vm-boot: SSH ready; QEMU pid $qemu_pid" >&2

if [[ $# -gt 0 ]]; then
  ssh "${ssh_opts[@]}" omarchy@127.0.0.1 "$@"
else
  printf '%s\n' \
    "VM running." \
    "  SSH: ssh -i $STATE/id_ed25519 -p $port omarchy@127.0.0.1" \
    "  VNC: 127.0.0.1:$vnc" \
    "  QMP: $QMP" \
    "  log: $SERIAL" \
    "Press Ctrl-C to power off and remove the overlay."
  while kill -0 "$qemu_pid" 2>/dev/null; do sleep 1; done
fi
