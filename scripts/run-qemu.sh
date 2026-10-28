#!/usr/bin/env bash
# Interactive developer VM. Uses the pinned Phase 2 disk, never host disks.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE=uefi
ACCEL=kvm
PREPARE=1
for arg in "$@"; do
  case "$arg" in
    --direct-kernel) MODE=direct ;;
    --tcg) ACCEL=tcg ;;
    --foundation) PREPARE=0 ;;
    --help) echo 'Usage: scripts/run-qemu.sh [--tcg] [--direct-kernel] [--foundation]'; exit 0 ;;
    *) echo "Unknown argument: $arg" >&2; exit 2 ;;
  esac
done
die() { echo "run-qemu: $*" >&2; exit 1; }
for tool in qemu-system-x86_64 qemu-img ssh ssh-keygen python3 sha256sum; do
  command -v "$tool" >/dev/null || die "missing $tool"
done
if [[ $ACCEL == kvm ]]; then
  [[ -r /dev/kvm && -w /dev/kvm ]] || die 'KVM unavailable; use --tcg for software emulation'
fi
BASE="$ROOT/workspace/upstream/omarchy-4.0.6.qcow2"
VM="$ROOT/workspace/upstream/omarchy-vm"
[[ -f $BASE ]] || die "missing pinned Phase 2 image: $BASE (see docs/development/QEMU_TESTING.md)"
echo 'Verifying pinned base image…'
echo "130144a193494c0510812ac02dbc1218b79de0ad53598eabc41b685907987d9f  $BASE" | sha256sum -c -
(cd "$VM" && sha256sum -c SHA256SUMS)
umask 077
mkdir -p "$ROOT/iso/out/developer"
STATE=$(mktemp -d "$ROOT/iso/out/developer/run-XXXXXXXX")
ln -sfn "$(basename "$STATE")" "$ROOT/iso/out/developer/latest"
SOCKET_DIR=$(mktemp -d /tmp/axiom-qemu-XXXXXXXX)
echo "$SOCKET_DIR" > "$STATE/socket-dir"
qemu-img create -q -f qcow2 -F qcow2 -b "$BASE" "$STATE/disk.qcow2"
ssh-keygen -q -t ed25519 -N '' -C axiom-developer-vm -f "$STATE/id_ed25519"
KEYS=$(printf 'd /home/omarchy/.ssh 0700 omarchy omarchy -\nf+ /home/omarchy/.ssh/authorized_keys 0600 omarchy omarchy - %s\n' "$(cat "$STATE/id_ed25519.pub")" | base64 -w0)
PORT=${SSH_PORT:-2222}
VNC=${VNC_DISPLAY:-1}
CPU=max
[[ $ACCEL != kvm ]] || CPU=host
BOOT=()
if [[ $MODE == uefi ]]; then
  CODE=${OVMF_CODE:-/usr/share/edk2/x64/OVMF_CODE.4m.fd}
  VARS=${OVMF_VARS_SRC:-/usr/share/edk2/x64/OVMF_VARS.4m.fd}
  [[ -r $CODE && -r $VARS ]] || die 'matching OVMF CODE/VARS files are required'
  cp "$VARS" "$STATE/OVMF_VARS.4m.fd"
  BOOT=(-drive "if=pflash,format=raw,readonly=on,file=$CODE" -drive "if=pflash,format=raw,file=$STATE/OVMF_VARS.4m.fd")
else
  BOOT=(-kernel "$VM/vmlinuz" -initrd "$VM/initrd" -append "$(cat "$VM/cmdline") console=ttyS0,115200 loglevel=4 systemd.show_status=true")
fi
GPU=VGA
if qemu-system-x86_64 -device help | rg -q 'name "virtio-vga"'; then GPU=virtio-vga; fi
ARGS=(-name 'Axiom development' -machine "q35,accel=$ACCEL" -cpu "$CPU"
  -m "${QEMU_MEM:-8G}" -smp "${QEMU_SMP:-4}" "${BOOT[@]}"
  -uuid "$(cat /proc/sys/kernel/random/uuid)"
  -drive "file=$STATE/disk.qcow2,format=qcow2,if=none,id=disk"
  -device virtio-blk-pci,drive=disk -device virtio-rng-pci -device "$GPU"
  -display none -vnc "127.0.0.1:$VNC"
  -netdev "user,id=net,restrict=on,hostfwd=tcp:127.0.0.1:$PORT-:22" -device virtio-net-pci,netdev=net
  -smbios "type=11,value=io.systemd.credential.binary:tmpfiles.extra=$KEYS"
  -serial "file:$STATE/serial.log" -qmp "unix:$SOCKET_DIR/qmp.sock,server=on,wait=off"
  -pidfile "$STATE/qemu.pid")
printf '%q ' qemu-system-x86_64 "${ARGS[@]}" > "$STATE/command.txt"
qemu-system-x86_64 --version > "$STATE/versions.txt"
echo "mode=$MODE accelerator=$ACCEL gpu=$GPU" >> "$STATE/versions.txt"
qemu-system-x86_64 "${ARGS[@]}" > "$STATE/qemu.log" 2>&1 &
QEMU_PID=$!
cleanup() {
  # Only the child owned by this invocation is signalled; overlays/logs are retained.
  if kill -0 "$QEMU_PID" 2>/dev/null; then kill "$QEMU_PID"; wait "$QEMU_PID" || true; fi
  rm -f "$SOCKET_DIR/qmp.sock"
  rmdir "$SOCKET_DIR" 2>/dev/null || true
}
trap cleanup EXIT
trap 'exit 130' INT TERM
cat > "$STATE/ssh" <<EOF
#!/usr/bin/env bash
exec ssh -i '$STATE/id_ed25519' -p '$PORT' -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile='$STATE/known_hosts' -o ConnectTimeout=3 omarchy@127.0.0.1 "\$@"
EOF
chmod +x "$STATE/ssh"
echo "VM logs and disk: $STATE"
echo "Real guest display: VNC 127.0.0.1:$VNC (port $((5900 + VNC)))"
echo "Guest SSH: $STATE/ssh"
echo 'Waiting for guest SSH; Ctrl-C stops this VM. Use the guest power menu for clean shutdown.'
DEADLINE=$((SECONDS + ${BOOT_TIMEOUT:-240}))
until "$STATE/ssh" -o BatchMode=yes true </dev/null 2>/dev/null; do
  kill -0 "$QEMU_PID" 2>/dev/null || die "QEMU exited: see $STATE/qemu.log"
  (( SECONDS < DEADLINE )) || die "guest SSH timeout; inspect $STATE/serial.log and VNC (try --direct-kernel only for diagnosis)"
  sleep 1
done
if (( PREPARE )); then
  "$ROOT/scripts/prepare-qemu-guest.sh" "$STATE"
fi
echo 'Guest ready. VM stays interactive until shutdown or Ctrl-C.'
wait "$QEMU_PID"
