# Reviewed Axiom archiso profile

This is the **legacy Phase 1** reviewed project profile for the Axiom image. Phase 1 built the
minimal releng-based image and its archiso evidence; the Plasma 6 packages appended later were
part of the now-superseded Plasma Phase 2 and are **not** the current migration base. After
[ADR-013](../../docs/DECISIONS.md) the image foundation is the pinned Omarchy-derived
Hyprland/Quickshell flow. The installer remains out of scope until its phase.

## Provenance

- Upstream: [archlinux/archiso](https://github.com/archlinux/archiso) (GitLab: `archlinux/archiso`)
- Pinned tag: **v91** (`723da192226e1c9d5def9168f13332793c82a85e`)
- Matches the packaged `archiso` version in `extra` at vendoring time (`archiso 91-1`).
- Source path: `configs/releng/` copied wholesale, then the differences below applied.

When the installed `mkarchiso` version changes, re-vendor from the matching tag and
re-apply the differences; do not hand-edit files that upstream owns.

## Intentional differences from upstream releng

| File | Change | Reason |
| --- | --- | --- |
| `profiledef.sh` | `iso_name="axiom"`, `iso_label="AXIOM_<YYYYMM>"`, `iso_publisher="Axiom"`, `iso_application="Axiom Live/Rescue Medium"`, `install_dir="axiom"` | Project identity + non-colliding install dir. All other keys (bootmodes, squashfs tool options, `bootstrap_tarball_compression`, `file_permissions`) are unchanged from releng. |
| `efiboot/loader/entries/01-archiso-linux.conf` | append `console=ttyS0,115200` to kernel `options` | Headless QEMU boot assertion (serial capture). |
| `efiboot/loader/entries/02-archiso-speech-linux.conf` | append `console=ttyS0,115200` to kernel `options` | Same, for the speech entry. |
| `packages.x86_64` | **Legacy Phase 2 (SUPERSEDED):** appended `plasma-meta`, `konsole`, `dolphin`, `kate`, `xorg-xwayland` | Historical Plasma 6 experiment; not the Omarchy-derived migration base. releng's base list is otherwise unchanged. |

`pacman.conf` keeps `SigLevel = Required DatabaseOptional` (signatures are never
disabled). The declared list is the input manifest.

**Historical open item (Phase 2, discovered 2026-10-25; closed as superseded 2026-10-27):**
Plasma 6.8's `plasma-meta` depends on `plasma-login-manager` (KDE's own login manager) and
pulls only `sddm-kcm`, not SDDM. The Plasma session assumption was superseded by
[ADR-013](../../docs/DECISIONS.md); the migration base uses Omarchy's SDDM Wayland greeter.
No session configuration is written in this legacy profile.

## Inspect

```sh
python3 scripts/check-iso-profile.py
```
