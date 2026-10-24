---
name: qemu-integration-test
description: "Run repeatable distro integration tests in disposable QEMU/KVM guests."
---

# qemu-integration-test

## When to use

Use for ISO boot, update, recovery or service integration validation. Do not use for using VM results as proof of battery or real GPU behavior.

## Required inputs

Image checksum, firmware, machine/CPU/RAM/disk/display/network settings, test matrix and artifact directory.

## Procedure

1. Record QEMU/OVMF versions and KVM availability; distinguish emulation from acceleration.
2. Create a task-owned disposable disk with a known baseline; use copy-on-write overlays for repeat cases.
3. Boot UEFI with documented virtual devices and collect serial output where configured, journal and relevant display evidence.
4. Run positive/negative checks with timeouts and explicit outcomes; preserve firmware, command line and test logs.
5. Test restart/crash/denial/recovery as appropriate; clean only owned guest processes and temporary overlays.

## Validation

A clean rerun produces the same observable checks; failures carry enough logs to distinguish guest from harness defects.

## Failure handling

Keep failed overlays/artifacts when needed for diagnosis; never attach host block devices or kill unrelated QEMU processes.

## Project references

- [engineering/TESTING.md](../../../docs/engineering/TESTING.md)
- [engineering/ISO_BUILD.md](../../../docs/engineering/ISO_BUILD.md)
