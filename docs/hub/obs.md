# OBS Studio

- Id: `obs` · Category: Multimedia · Weight: heavy · Licence (catalog): GPL-2.0
- Catalog sources: flatpak `com.obsproject.Studio`
- Install verified: yes · Screenshots: 1 of 3 · Logo: yes

## Overview
OBS Studio is free, open-source software for live streaming and screen recording with scene composition and multiple sources. It is for streamers, creators and presenters.

## Facts
- Name: OBS Studio
- Publisher: OBS Project
- Official website: https://obsproject.com/ (downloads also on GitHub releases)
- Licence: GPL-2.0 per the unofficial Snap listing; official site licence page not confirmed. Source: https://snapcraft.io/obs-studio
- Latest version: 32.2.0 per a July 2026 report and the Snap latest/stable channel (seen 2026-11-13). Source: https://ubuntuhandbook.org/index.php/2026/07/obs-studio-32-2-0-released-with-sdr-to-hdr-composer-ubuntu-26-04-deb/
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- GPU/display: OpenGL 3.3 or later required on Linux (third-party guide). Source: search summary
- Linux: Flatpak recommended; OBS distributes an official deb for some releases. Source: search summary

Flathub data (https://flathub.org/api/v2/appstream/com.obsproject.Studio):
- Flatpak id: `com.obsproject.Studio` · Developer: OBS Project · Licence: GPL-2.0-or-later
- Latest version on Flathub: 33.0.1 (released 2026-10-29)

## Logo
Bundled icon: `apps/hub/icons/obs.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/com.obsproject.Studio.png (verified-200).

## Screenshots
![The OBS Studio window showing a card game, the project website, a video, and a purple rectangle](https://dl.flathub.org/media/com/obsproject/Studio/eee0a1f453649164008dc9f0913dfe7e/screenshots/image-1_orig.png)
Source: https://flathub.org/api/v2/appstream/com.obsproject.Studio

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Flatpak (official build) | `flatpak install flathub com.obsproject.Studio` | no |

- OBS maintains two official Linux builds: Flatpak and Ubuntu. The Arch package is listed as unofficial.

- Source: https://obsproject.com/wiki/Install-Instructions
- Source: https://github.com/obsproject/obs-studio/wiki/install-instructions

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S obs-studio` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install obs-studio` | yes | yes | |
| Flatpak | `flatpak install flathub com.obsproject.Studio` | no (`--user`) | yes | ID unverified. |

## Manual install (draft)
Not needed.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| Screen capture black on Wayland | Portal missing. | Install `xdg-desktop-portal` with matching backend (unverified). |
| Flatpak cannot use v4l2 | Device access. | Grant device permission via `flatpak override --device=all` (unverified). |

## Sources
- https://obsproject.com/
- https://obsproject.com/download
- https://snapcraft.io/obs-studio
- https://ubuntuhandbook.org/index.php/2026/07/obs-studio-32-2-0-released-with-sdr-to-hdr-composer-ubuntu-26-04-deb/
