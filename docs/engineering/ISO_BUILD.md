# Image build and QEMU workflow

Status: Phase 0 reset. The reviewed `iso/profile/`, `scripts/build-iso.sh` and
`tests/qemu-boot.sh` remain as **legacy Phase 1 evidence**. They are useful for
boot-harness validation but are not the new Axiom desktop base. The former
Omarchy wrapper is archived and has no active build path.

The next image contract is deliberately small: recorded Arch inputs, Linux
kernel, init/userspace, systemd, device management, networking, audio/graphics
prerequisites, Wayland client libraries and a temporary compositor harness. The
builder must avoid host mounts/credentials, produce a manifest and checksum,
capture serial/journal logs, and boot/cleanly shut down in UEFI QEMU/KVM.

Until that builder is reviewed, use only the retained evidence command when a
legacy ISO exists:

```sh
tests/qemu-boot.sh iso/out/<image>.iso
```

Future commands should expose explicit `build`, `run`, `test` and `reset` modes
with disposable disks and no destructive host default. Do not claim image
reproducibility from rolling mirrors alone; record package databases, firmware,
builder image/tool versions, source date and all adjustments. Installer,
updates, hardware support and release artifacts belong to Phase 9.
