# Dolphin

- Id: `dolphin` · Category: Games · Weight: heavy · Licence (catalog): GPL-2.0
- Catalog sources: flatpak `org.DolphinEmu.dolphin-emu`
- Install verified: yes · Screenshots: 4 of 3 · Logo: yes

## Overview
Dolphin is an open-source emulator for GameCube and Wii games that runs them with enhancements such as higher resolution. It is for retro gamers who want to play GameCube and Wii titles on a PC.

## Facts
- Name: Dolphin Emulator
- Publisher: Dolphin Emulator project
- Official website: https://dolphin-emu.org/ (download https://dolphin-emu.org/download/?cr=en)
- Licence: not confirmed in this pass (widely described as open source; GPL not verified)
- Latest version: 2606, reported June 25, 2026 (seen 2026-11-13). Source: https://ubuntuhandbook.org/index.php/2026/06/dolphin-emulator-2606-game-boy-player/
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Linux: official Flatpak packages (release and development repositories) for x86_64 and aarch64. Source: search summary of https://dolphin-emu.org/download/?cr=en

Flathub data (https://flathub.org/api/v2/appstream/org.DolphinEmu.dolphin-emu):
- Flatpak id: `org.DolphinEmu.dolphin-emu` · Developer: Dolphin Emulator Project · Licence: GPL-2.0+
- Latest version on Flathub: 2609a (released 2026-10-08)

## Logo
Bundled icon: `apps/hub/icons/dolphin.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/org.DolphinEmu.dolphin-emu.png (verified-200).

## Screenshots
![Dolpin's main window](https://dl.flathub.org/media/org/dolphinemu/dolphin-emu/545d6103cffc1fc13e2704ce509e2c0b/screenshots/image-1_orig.png)
![In-game](https://dl.flathub.org/media/org/dolphinemu/dolphin-emu/545d6103cffc1fc13e2704ce509e2c0b/screenshots/image-2_orig.png)
![Grapics configuration](https://dl.flathub.org/media/org/dolphinemu/dolphin-emu/545d6103cffc1fc13e2704ce509e2c0b/screenshots/image-3_orig.png)
![Controller configuration](https://dl.flathub.org/media/org/dolphinemu/dolphin-emu/545d6103cffc1fc13e2704ce509e2c0b/screenshots/image-4_orig.png)
Source: https://flathub.org/api/v2/appstream/org.DolphinEmu.dolphin-emu

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Flatpak | `flatpak install flathub org.DolphinEmu.dolphin-emu` | no |
| Arch package | `sudo pacman -S dolphin-emu` | yes |
| Dolphin's own Flatpak repo (stable) | `flatpak remote-add --if-not-exists dolphin-emu https://flatpak.dolphin-emu.org/releases.flatpakrepo` | no |

- Dolphin added official Linux Flatpak support in release 2412.

- Source: https://ubuntuhandbook.org/index.php/2024/12/dolphin-emulator-2412-flatpak-support/
- Source: https://cdn.jsdelivr.net/npm/arch-wiki-md-repo@0.10.84/wiki/_content/english/Dolphin emulator.md

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Flatpak | `flatpak install flathub org.DolphinEmu.dolphin-emu` | no (`--user`) | yes | ID unverified. |
| Arch repos | `sudo pacman -S dolphin-emu` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install dolphin-emu` | yes | yes | Availability varies by release. |
| AppImage | download from https://dolphin-emu.org/download/ | no | yes | Unverified. |

## Manual install (draft)
Not needed.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| Graphics backend fails | Vulkan driver missing. | Install Vulkan driver for your GPU (unverified). |
| Flatpak cannot read ISO | Sandbox. | `flatpak override` for ROM folder (unverified). |

## Sources
- https://dolphin-emu.org/download/
- https://dolphin-emu.org/download/?cr=en
- https://ubuntuhandbook.org/index.php/2026/06/dolphin-emulator-2606-game-boy-player/
