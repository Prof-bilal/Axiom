# Lapce

- Id: `lapce` · Category: Development · Weight: light · Licence (catalog): Apache-2.0
- Catalog sources: flatpak `dev.lapce.lapce`
- Install verified: yes · Screenshots: 1 of 3 · Logo: yes

## Overview
Lapce is a fast, lightweight code editor written in pure Rust with a Floem-based UI. It is for developers who want a snappy, low-overhead editor with an open-source Rust codebase.

## Facts
- Name: Lapce
- Publisher: Lapce project (repository github.com/lapce/lapce)
- Official website: https://lapce.dev/ (redirects to https://lap.dev/lapce/)
- Licence: Apache License 2.0. Source: https://github.com/lapce/lapce (search summary)
- Latest version: 0.4.2 per https://lap.dev/lapce/ (seen 2026-11-13). A third-party review lists v0.4.6 with no date; check https://github.com/lapce/lapce/releases.
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Install: Snap (https://snapcraft.io/lapce) and GitHub releases. Source: https://snapcraft.io/lapce

Flathub data (https://flathub.org/api/v2/appstream/dev.lapce.lapce):
- Flatpak id: `dev.lapce.lapce` · Developer: Dongdong Zhou, et al. · Licence: Apache-2.0
- Latest version on Flathub: 0.4.6 (released 2026-01-21)

## Logo
Bundled icon: `apps/hub/icons/lapce.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/dev.lapce.lapce.png (verified-200).

## Screenshots
![Lapce source project opened in Lapce with Rust source code file opened](https://dl.flathub.org/media/dev/lapce/lapce/9c9fd2d6c653ac517ed98e2e1c2a36b3/screenshots/image-1_orig.png)
Source: https://flathub.org/api/v2/appstream/dev.lapce.lapce

- ![Lapce editor screenshot](https://raw.githubusercontent.com/lapce/lapce/master/extra/images/screenshot.png) Caption: main editor screenshot from the official project repository (linked from lap.dev). Only one screenshot found.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Flatpak | `flatpak install flathub dev.lapce.lapce` | no |

- Arch availability is unclear (sources conflict); the Snap is unmaintained.

- Source: https://flathub.org/it/apps/dev.lapce.lapce

## Install options (research draft; unverified. Search was rate-limited; Flathub ID and Arch name are from model knowledge.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Flatpak | `flatpak install flathub dev.lapce.lapce` | no (`--user`) | yes | ID unverified; check flathub.org. |
| Arch repos | `sudo pacman -S lapce` | yes | yes | Package name unverified. Confirm with `pacman -Ss lapce`. |
| Upstream tarball/AppImage | download from https://github.com/lapce/lapce/releases | no | yes | Filenames unverified. |

## Manual install (draft)
1. Download the Linux release from https://github.com/lapce/lapce/releases (unverified name).
2. Extract to `~/.local/opt/lapce` and link `lapce` into `~/.local/bin`.
3. Check: `lapce --version` (unverified flag).

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| No GPU acceleration, blank window | Vulkan/OpenGL driver missing. | Install Mesa Vulkan drivers for your GPU (unverified for Lapce specifically). |
| `lapce: command not found` | PATH. | Add `~/.local/bin` to PATH. |

## Sources
- https://flathub.org
- https://github.com/lapce/lapce
- https://lap.dev/lapce/
- https://snapcraft.io/lapce
