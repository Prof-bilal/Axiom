# Phase 1 evidence: reproducible Arch/archiso build

Status: **IN PROGRESS — profile, scripts and local checks pass; build and boot pending
toolchain install.** Authorization recorded 2026-10-24 in [PHASES](../PHASES.md). This
record is filled in only from real runs; nothing here is a claim until the corresponding
command has executed and its artifacts exist under `iso/out/evidence/`.

Scope: minimal reviewed archiso profile ([iso/profile/README.md](../../iso/profile/README.md)),
build script, QEMU boot harness, CI validation. No desktop, installer or daemon.

## Local validation (2026-10-24, no root required)

| Check | Result |
| --- | --- |
| `python3 scripts/validate-repo.py` | PASS: 0 errors |
| `python3 scripts/check-iso-profile.py` | PASS: 0 errors |
| `python3 scripts/test-concepts.py` | PASS: 12/12, 0 skipped |
| `bash -n scripts/build-iso.sh tests/qemu-boot.sh` | PASS |
| Adversarial: `build-iso.sh` without `mkarchiso` | PASS: refuses with a clear message |
| Adversarial: tampered ISO checksum | PASS: harness fails before boot |
| Adversarial: checksum control (correct hash) | PASS: guard passes, stops at missing OVMF |
| Adversarial: `pacman.conf` with `SigLevel = Never` | PASS: profile check rejects it |

The build and boot evidence below require the toolchain install (administrator) and remain
NOT RUN.

## Builder environment

| Item | Value |
| --- | --- |
| Host | Arch-based, x86-64 |
| `archiso` package | NOT YET INSTALLED |
| `qemu` / `edk2-ovmf` | NOT YET INSTALLED |
| Kernel | NOT YET RECORDED |
| KVM | present (`/dev/kvm`) |
| Python | 3.15.1 |

Install command (requires an administrator):

```sh
sudo pacman -S --needed archiso qemu-system-x86_64 edk2-ovmf libisoburn squashfs-tools arch-install-scripts
```

## Experiments

| ID | Expectation | Status |
| --- | --- | --- |
| E01 | Two independent builds; compare manifests and ISO/`airootfs.sfs` hashes; explain any difference | NOT RUN |
| E02 | Independent clean build boots in QEMU/KVM with logs | NOT RUN |

## Results

### E01 — reproducibility

- Run 1 manifest / hashes: NOT RUN
- Run 2 manifest / hashes: NOT RUN
- Delta and explanation: NOT RUN

Reproducibility level: **not yet stated.** Expected honest outcome: consistent pinned
package set and reproducible structure, not bit-identical artifacts (timestamps and
squashfs/xz compression ordering). A bit-identical claim requires evidence and will not
be made without it.

### E02 — QEMU UEFI boot

- ISO checksum verified before boot: NOT RUN
- Boot reached `Startup finished`: NOT RUN
- Failed units: NOT RUN
- Clean poweroff via monitor: NOT RUN
- Serial log: NOT RUN

## How to reproduce

```sh
python3 scripts/check-iso-profile.py
sudo AXIOM_EVIDENCE_DIR=iso/out/evidence/run1 scripts/build-iso.sh
sudo AXIOM_EVIDENCE_DIR=iso/out/evidence/run2 scripts/build-iso.sh
tests/qemu-boot.sh iso/out/axiom-*.iso
```
