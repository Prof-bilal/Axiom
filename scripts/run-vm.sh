#!/usr/bin/env bash
# Boot the Axiom ISO for hands-on testing, shown over VNC on 127.0.0.1:5901.
#   scripts/run-vm.sh [iso]
# Adds an emulated sound card (silent: this host's QEMU has no audio output
# backend) and a wired network. No Wi-Fi or Bluetooth hardware exists in the VM.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ISO="${1:-$ROOT/iso/out-phase3/axiom-2026.11.06-x86_64.iso}"
VARS="$(mktemp --suffix=-OVMF_VARS.fd)"
trap 'rm -f "$VARS"' EXIT
cp /usr/share/edk2/x64/OVMF_VARS.4m.fd "$VARS"
vncviewer 127.0.0.1:5901 >/dev/null 2>&1 &
qemu-system-x86_64 -enable-kvm -machine q35 -cpu host -m 2048 -smp 2 \
  -drive if=pflash,format=raw,readonly=on,file=/usr/share/edk2/x64/OVMF_CODE.4m.fd \
  -drive "if=pflash,format=raw,file=$VARS" \
  -vga none -device VGA,edid=on,xres=1920,yres=1080 \
  -device qemu-xhci -device usb-tablet \
  -audiodev none,id=snd0 -device intel-hda -device hda-duplex,audiodev=snd0 \
  -nic user,model=virtio-net-pci \
  -display none -vnc 127.0.0.1:1 -cdrom "$ISO" -boot order=d
