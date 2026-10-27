# Phase 1 evidence: reproducible Arch/archiso build

Status: **EXIT MET 2026-10-25 (owner sign-off).** E01 and E02 executed 2026-10-25: a reviewed
profile builds twin ISOs that boot in QEMU/KVM with logs, and the reproducibility level is
stated explicitly. Open findings are carried into Phase 2. Nothing below is a claim without a
corresponding artifact under `iso/out/evidence/` (gitignored).

Scope: minimal reviewed archiso profile ([iso/profile/README.md](../../iso/profile/README.md)),
build wrapper (`scripts/build-iso.sh`), QEMU boot harness (`tests/qemu-boot.sh`). No desktop,
installer or daemon.

## Authorization

Recorded 2026-10-24 in [PHASES](../PHASES.md): reviewed archiso profile, build script, QEMU
harness, CI validation and evidence only. Branding, Plasma, custom packages, the installer
and any `apps/`/`shell/`/`services/` component are out of scope.

## Builder environment (as built)

| Item | Value |
| --- | --- |
| Host | Arch-based (Omarchy), kernel `7.2.8-9-omarchy` |
| Python | 3.15.1 (`python3 -E`) |
| `archiso` | `91-1` (profile pinned to upstream tag `v91`, commit `723da192`) |
| QEMU | `qemu-base 11.1.2-1`, `qemu-system-x86 11.1.2-1` |
| Firmware | `edk2-ovmf 202608-1` (`/usr/share/edk2/x64/OVMF_{CODE,VARS}.4m.fd`) |
| KVM | present (`/dev/kvm`) |
| Build privilege | **unprivileged** via `mkarchiso` user namespaces (`unshare --map-auto --map-root-user`); no root used. `max_user_namespaces=29024`, `/etc/subuid` `abullah:100000:65536`. |
| `SOURCE_DATE_EPOCH` | `1792903608` (identical across both builds) |

Install: `sudo pacman -S --needed archiso qemu-base edk2-ovmf libisoburn squashfs-tools arch-install-scripts`

## Local validation (no root required)

| Check | Result |
| --- | --- |
| `python3 scripts/validate-repo.py` | PASS: 0 errors |
| `python3 scripts/check-iso-profile.py` | PASS: 0 errors |
| `python3 scripts/test-concepts.py` | PASS: 12/12, 0 skipped |
| Adversarial: `build-iso.sh` without `mkarchiso` | PASS: refuses with a clear message |
| Adversarial: tampered ISO checksum | PASS: harness fails before boot |
| Adversarial: checksum control (correct hash) | PASS: guard passes, stops at missing OVMF |
| Adversarial: `pacman.conf` with `SigLevel = Never` | PASS: profile check rejects it |

## E01 — two independent builds + a stock releng control

Three builds were run with the same archiso, repositories and `SOURCE_DATE_EPOCH`. The
control is the unmodified upstream `releng` profile, used to separate our profile changes
from inherited behavior.

| Build | ISO SHA-256 | `airootfs.sfs` SHA-256 |
| --- | --- | --- |
| run1 (`iso/profile`) | `213161926ebcfa58278c7fb058c641a23d56209fa34734a53ea045c77252713e` | `57bea630e85ee5f3c6b4faa133f7f36eb3cfdb387e17c23a2e00d5af776c488f` |
| run2 (`iso/profile`) | `6d21f9aa2742afe51ee97facb1c691885a8c4ed7928397f44a8727720137f9a2` | `fd77d8e9266987461de4f04421fcaf3235d5cb13064cd0550622f255801d0b0c` |
| control (stock releng) | `fb8f4c33a759ccbdaa9ccfd1340da0808e7a6dd0033c0530ece80992608fdbd8` | `581446962e918b412539972596ad92dc55b9b456ba11e29399d4225ddbdc61ca` |

Identical across all three: declared package list (129 entries), installed manifest (455
packages), repository DB hashes (`core`/`extra`/`multilib`/`offline`/`omarchy`), `archiso`
version and `SOURCE_DATE_EPOCH`; each ISO is `802848` sectors / `1644232704` bytes.

### Reproducibility level — explicit

**Reproducible inputs, not bit-identical artifacts.** Package set, declared inputs,
repository identities and build epoch are identical and the image geometry matches, but the
ISO and `airootfs.sfs` bytes differ between independent builds. No bit-reproducibility is
claimed.

### Why the bytes differ

- `mkarchiso`'s post-install hooks regenerate files inside the airootfs at build time with
  the then-current time: ca-certificates extracted bundles (including binary keystores
  `java-cacerts.jks` / `edk2-cacerts.bin`), locale/gconv/iconv caches, the GSettings schema
  cache, the initramfs and the uncommented mirrorlist.
- Evidence: SquashFS inode/directory table sizes differ slightly between runs (run1
  `675207`/`890616`, run2 `675211`/`890636`, control `675235`/`890584`) while file and inode
  counts are identical (`77009` files, `96926` inodes). Differing table sizes with an
  identical file set indicate differing per-file metadata/content, not a different tree.
- `mksquashfs` also compresses in parallel; container ordering/timestamps are a further
  contributor. A dedicated `mksquashfs` A/B test on one tree did not complete, so this factor
  is **not isolated** — recorded as unverified.
- `etc/machine-id` is the constant literal `uninitialized` (verified), so it is **not** a
  source of variance; the guest generates its own at boot.

## E02 — QEMU/UEFI boot

Command (`iso/out/evidence/qemu/`):

```sh
AXIOM_SUMS=iso/out/evidence/run2/sha256sums.txt \
AXIOM_ALLOWED_UNITS="Loopback Block Device" \
tests/qemu-boot.sh iso/out/axiom-2026.10.25-x86_64.iso iso/out/evidence/qemu
```

Result: **PASS** — checksum verified before boot; guest reached a login prompt
(`archiso login:` on `ttyS0`); clean `system_powerdown` via the QEMU monitor. The ISO is
booted with `-nic none`, no host disks or shares.

| Assertion | Result |
| --- | --- |
| ISO SHA-256 matches recorded checksum | PASS |
| Guest reaches a login prompt | PASS (attempt 2) |
| Clean monitor poweroff | PASS |
| Failed units | 1, allowlisted (see below) |

## Open findings

1. **`systemd-loop@…block-sr0.service` fails at boot (non-fatal).** Upstream-inherited: the
   `systemd-loop@.service` template and `systemd-import-generator` are present identically in
   stock `releng` (systemd `262.1`), no loop-unit instance ships in the image, and the profile
   diff (naming + `console=ttyS0`) cannot influence loop/DDI handling. It does not prevent
   reaching the login prompt. Owner: linux-base. Must be root-caused or shown upstream before
   Phase 2 depends on the image. It is allowlisted explicitly
   (`AXIOM_ALLOWED_UNITS="Loopback Block Device"`), never silently ignored.
2. **Firmware-stage QEMU flakiness on this host.** Roughly half of identical boots never hand
   off from UEFI to the ISO (the serial log contains only the firmware screen-init sequence,
   ~113 bytes, no guest output). It reproduces with the stock `releng` ISO and succeeds on
   retry, so it is a host/QEMU environment issue, not an image defect. The harness retries
   only zero-progress attempts (default 3), preserves every attempt's serial log and reports
   the attempt count. Owner: qa. Consider a dedicated build/test VM or more RAM.
3. **Not bit-reproducible** (see E01). No claim of bit-identical output.

## Fixes made during execution

- `scripts/build-iso.sh`: remove the work tree inside `unshare --map-auto --map-root-user`
  (an unprivileged build leaves read-only dirs and files owned by unmapped system uids that
  plain `rm -rf` cannot delete); allow `AXIOM_PROFILE` for the control build.
- `tests/qemu-boot.sh`: accept a login prompt as the readiness marker; parse `./`-prefixed
  checksums; warn when guest RAM exceeds available host memory; detach guest stdio; retry only
  firmware-stage stalls and keep per-attempt logs.

## How to reproduce

```sh
python3 scripts/check-iso-profile.py
AXIOM_EVIDENCE_DIR=iso/out/evidence/run1 scripts/build-iso.sh
AXIOM_EVIDENCE_DIR=iso/out/evidence/run2 scripts/build-iso.sh
AXIOM_PROFILE=/usr/share/archiso/configs/releng \
  AXIOM_WORK_DIR="$PWD/iso/work-control" AXIOM_OUT_DIR="$PWD/iso/out/control" \
  AXIOM_EVIDENCE_DIR="$PWD/iso/out/evidence/control" scripts/build-iso.sh
AXIOM_SUMS=iso/out/evidence/run2/sha256sums.txt \
  AXIOM_ALLOWED_UNITS="Loopback Block Device" \
  tests/qemu-boot.sh iso/out/axiom-*.iso
```

## Applicability after ADR-013 (2026-10-27)

This evidence is **historical and unchanged.** It proves that the reviewed archiso profile built and booted reproducibly in QEMU/KVM at the recorded inputs. After [ADR-013](../DECISIONS.md), the Phase 2 image base is the pinned Omarchy-derived ISO flow, so this profile is not the migration base. Nothing here is retracted: the E01/E02 results, the open findings and the stated reproducibility level ("reproducible inputs, not bit-identical artifacts") remain valid for the Phase 1 artifact. The Plasma packages later appended to `iso/profile/packages.x86_64` are legacy and were never built into the evidence ISO.
