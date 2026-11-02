# Build strategy

Status: Phase 0 research. Axiom is not yet an installable distribution and no
new product build command is claimed. The retained `scripts/build-iso.sh` and
`iso/profile/` are legacy Phase 1 archiso evidence. The former upstream build
wrapper has been removed and must not be used as the active base.

The next build contract is a minimal x86-64 image assembled from recorded Arch
inputs and standard Linux packages: kernel, init/userspace, systemd, device
management, networking, audio, graphics, Wayland prerequisites and a
temporary compositor harness. It must be reproducible enough to compare
manifests and logs, boot in QEMU, and fail closed when an input is missing.

The Phase 3 graphical profile is `iso/phase3/` (built with
`scripts/build-phase3-iso.sh`). It derives from the reviewed Phase 1 profile,
uses only official Arch repositories, creates unprivileged user `axiom` and
starts the session on tty1. It is a bring-up desktop image, not a release
artifact.

Do not recreate the kernel, libc, init, package manager, drivers or mature
device services. Do not add an installer, update channel, custom package
repository or polished shell until the phase gate authorizes it. See the
[architecture](ARCHITECTURE.md), [phases](PHASES.md) and [legacy ISO notes](engineering/ISO_BUILD.md).
