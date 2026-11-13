# OpenTofu

- Id: `opentofu` · Category: Development · Weight: light · Licence (catalog): MPL-2.0
- Catalog sources: pacman `opentofu`
- Install verified: yes · Screenshots: 0 of 3 · Logo: yes

## Overview
OpenTofu is an open-source, MPL-2.0 licensed fork of Terraform that is compatible with Terraform configurations. It is for teams that want Terraform-style infrastructure-as-code under an open licence.

## Facts
- Name: OpenTofu
- Publisher: OpenTofu project
- Official website: https://opentofu.org/ (install docs cited are older)
- Licence: MPL-2.0. Source: https://snapcraft.io/opentofu
- Latest version: 1.13.2 on the Snap Store latest/stable channel, seen 2026-11-13. Source: https://snapcraft.io/opentofu
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Install: `sudo snap install opentofu --classic`; APT/DNF repos; manual zip from GitHub releases with SHA256SUMS. Source: https://snapcraft.io/opentofu and https://opentofu.org/docs/v1.6/intro/install/standalone/

## Logo
Bundled icon: `apps/hub/icons/opentofu.png`.
Official logo: https://raw.githubusercontent.com/opentofu/brand-artifacts/main/full/transparent/SVG/on-light.svg (verified-200).

## Screenshots
Not found in this pass.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Arch package (extra) | `sudo pacman -S opentofu` | yes |

- The command is tofu, not opentofu.
- AUR alternatives: opentofu-bin, opentofu-bin-stable.

- Source: https://archlinux.org/packages/extra/x86_64/opentofu/

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Installer script | `sh -c "curl -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh && sh install-opentofu.sh --install-method standalone"` | no (standalone) | yes | Unverified. Download, read, then run. |
| Arch AUR | `yay -S opentofu-bin` | no | yes | Unverified. |
| Tarball / zip | download from https://github.com/opentofu/opentofu/releases | no | yes | Unverified filename. |

## Manual install (draft)
1. Download `tofu_<ver>_linux_amd64.zip` from GitHub releases (unverified name).
2. Unzip into `~/.local/bin`.
3. Check: `tofu version`.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| `tofu: command not found` | PATH. | Add `~/.local/bin` to PATH. |
| Provider install fails | Registry network. | Check proxy/DNS. |

## Sources
- https://opentofu.org/docs/intro/install/
- https://opentofu.org/docs/v1.6/intro/install/standalone/
- https://snapcraft.io/opentofu
