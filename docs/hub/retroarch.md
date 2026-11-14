# RetroArch

- Id: `retroarch` · Category: Games · Weight: light · Licence (catalog): GPL-3.0
- Catalog sources: flatpak `org.libretro.RetroArch`
- Install verified: yes · Screenshots: 4 of 3 · Logo: yes

## Overview
RetroArch is a frontend for libretro emulator cores that runs many classic-console emulators under one interface. It is for retro gaming enthusiasts on Linux and other platforms.

## Facts
- Name: RetroArch
- Publisher: libretro team
- Official website: https://www.retroarch.com/
- Licence: GPL-3.0-or-later per the Snap Store listing. Source: https://snapcraft.io/retroarch.md
- Latest version: 1.22.2 per the Snap Store latest/stable channel and the official itch.io Linux listing (seen 2026-11-13). Source: https://retroarchofficial.itch.io/retroarch
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Linux: official Flatpak on Flathub, Snap, AppImage, itch.io and Steam. Source: https://www.retroarch.com/platforms.php (search summary)

Flathub data (https://flathub.org/api/v2/appstream/org.libretro.RetroArch):
- Flatpak id: `org.libretro.RetroArch` · Developer: libretro · Licence: GPL-3.0-or-later
- Latest version on Flathub: 1.22.2 (released 2025-11-22)

## Logo
Bundled icon: `apps/hub/icons/retroarch.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/org.libretro.RetroArch.png (verified-200).

## Screenshots
![RetroArch main menu](https://dl.flathub.org/media/org/libretro/RetroArch/3ee0774bac871b4ff7a8a6927c43b394/screenshots/image-1_orig.png)
![RetroArch running the NES](https://dl.flathub.org/media/org/libretro/RetroArch/3ee0774bac871b4ff7a8a6927c43b394/screenshots/image-2_orig.png)
![Rabbit : a fighting game from 1997, one of the only Electronic Arts arcade games](https://dl.flathub.org/media/org/libretro/RetroArch/3ee0774bac871b4ff7a8a6927c43b394/screenshots/image-3_orig.png)
![Wolfenstein 3D (Shareware)](https://dl.flathub.org/media/org/libretro/RetroArch/3ee0774bac871b4ff7a8a6927c43b394/screenshots/image-4_orig.png)
Source: https://flathub.org/api/v2/appstream/org.libretro.RetroArch

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Flatpak (official, per libretro docs) | `flatpak install --user flathub org.libretro.RetroArch` | no |
| Arch package (extra) | `sudo pacman -S retroarch` | yes |

- Use the AUR git build only if the Arch release has problems.

- Source: https://docs.libretro.com/guides/install-gnu

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S retroarch` | yes | yes | Unverified. Add `libretro-*` cores separately. |
| Debian/Ubuntu | `sudo apt install retroarch` | yes | yes | Cores via `libretro-*` packages. |
| Flatpak | `flatpak install flathub org.libretro.RetroArch` | no (`--user`) | yes | ID unverified. |

## Manual install (draft)
Not needed.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| No cores available | Core not installed. | Install cores via Online Updater or distro packages. |
| Audio latency | Driver config. | Switch audio driver in settings (pipewire/pulse, unverified). |

## Sources
- https://retroarchofficial.itch.io/retroarch
- https://snapcraft.io/retroarch.md
- https://www.retroarch.com/index.php?page=linux
- https://www.retroarch.com/platforms.php
