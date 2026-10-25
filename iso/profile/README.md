# Reviewed Axiom archiso profile

This is the reviewed project profile for the Phase 1 minimal Axiom image. It is a
vendored copy of the upstream `releng` profile with the small, explicit differences
listed below. It is **not** a complete desktop; branding, Plasma, custom packages and
the installer are out of scope until later phases.

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

`packages.x86_64` is unchanged from releng for Phase 1 and recorded as the declared
input manifest. `pacman.conf` keeps `SigLevel = Required DatabaseOptional` (signatures
are never disabled).

## Inspect

```sh
python3 scripts/check-iso-profile.py
```
