# Reviewed Axiom archiso profile

This is the reviewed project profile for the Axiom image. Phase 1 built the minimal
releng-based image; Phase 2 adds the Plasma 6 Wayland desktop. It is **not** yet a
branded or custom desktop, and the installer stays out of scope until its phase.

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
| `packages.x86_64` | **Phase 2:** appended `plasma-meta`, `konsole`, `dolphin`, `kate`, `xorg-xwayland` | Bootable Plasma 6 Wayland desktop. releng's base list is otherwise unchanged. |

`pacman.conf` keeps `SigLevel = Required DatabaseOptional` (signatures are never
disabled). The declared list is the input manifest.

**Open item (Phase 2, discovered 2026-10-25):** Plasma 6.8's `plasma-meta` depends on
`plasma-login-manager` (KDE's own login manager) and pulls only `sddm-kcm`, not SDDM.
The live-session login/autologin mechanism must be determined from that component's own
documentation and verified in a build — no session config is written here, and SDDM is
deliberately not assumed.

## Inspect

```sh
python3 scripts/check-iso-profile.py
```
