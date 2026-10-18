---
name: archiso-build
description: "Build and diagnose Arch-based ISO images in an isolated Arch builder."
---

# archiso-build

## When to use

Use for ISO build or boot failures. Do not use for editing desktop components.

## Required inputs

Arch builder version, profile revision, package source date, output/work directories, firmware and VM configuration.

## Procedure

1. Check pinned archiso version, disk capacity, signatures, package manifest and isolated Arch builder; never build against mutable host configuration.
2. Copy the upstream releng profile into the reviewed profile; record intentional differences and package versions.
3. Use mkarchiso with explicit work and output directories; capture complete stdout/stderr, package manifest and checksums. Do not assume a project build script exists.
4. Boot the resulting image with UEFI QEMU/KVM; collect serial console where configured, journal, boot timing and display-session evidence.
5. Diagnose download/signature, profile, initramfs, firmware and graphics failures separately; compare with unmodified releng.

## Validation

Validate image checksum, UEFI boot and repeat build provenance. For Phase 2 and later desktop profiles also verify Plasma Wayland login; do not claim bit reproducibility without comparing artifacts.

## Failure handling

Preserve logs and the failing image; remove only task-owned disposable work directories. Never retry by disabling signature verification.

## Project references

- [engineering/ISO_BUILD.md](../../../docs/engineering/ISO_BUILD.md)
- [engineering/TESTING.md](../../../docs/engineering/TESTING.md)
