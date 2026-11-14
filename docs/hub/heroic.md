# Heroic Games Launcher

- Id: `heroic` · Category: Games · Weight: medium · Licence (catalog): GPL-3.0
- Catalog sources: flatpak `com.heroicgameslauncher.hgl`
- Install verified: yes · Screenshots: 5 of 3 · Logo: yes

## Overview
Heroic Games Launcher is an open-source game launcher for Epic Games Store, GOG and Amazon Games on Linux and other platforms. It is for Linux gamers who use those stores and want a native launcher.

## Facts
- Name: Heroic Games Launcher
- Publisher: Heroic Games Launcher project
- Official website: not confirmed in this pass; repository https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher
- Licence: not confirmed in this pass (commonly GPL; not verified)
- Latest version: 2.19.x (2.19.0 and 2.19.1 reported January 2026). A newer release may exist. Source: https://www.gamingonlinux.com/2026/01/heroic-games-launcher-v2-19-released-adding-zoom-platform-appimage-updates-and-more/page=1/
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Linux: AppImage, Flathub and GitHub releases. Source: search summary

Flathub data (https://flathub.org/api/v2/appstream/com.heroicgameslauncher.hgl):
- Flatpak id: `com.heroicgameslauncher.hgl` · Developer: Heroic Games Launcher · Licence: GPL-3.0
- Latest version on Flathub: v2.22.4 (released 2026-10-15)

## Logo
Bundled icon: `apps/hub/icons/heroic.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/com.heroicgameslauncher.hgl.png (verified-200).

## Screenshots
![Library](https://dl.flathub.org/media/com/heroicgameslauncher/hgl/086b2f476c35a2b036fbad1b19d7a285/screenshots/image-1_orig.png)
![GamePage](https://dl.flathub.org/media/com/heroicgameslauncher/hgl/086b2f476c35a2b036fbad1b19d7a285/screenshots/image-2_orig.png)
![Stores](https://dl.flathub.org/media/com/heroicgameslauncher/hgl/086b2f476c35a2b036fbad1b19d7a285/screenshots/image-3_orig.png)
![Sideload Dialog](https://dl.flathub.org/media/com/heroicgameslauncher/hgl/086b2f476c35a2b036fbad1b19d7a285/screenshots/image-4_orig.png)
![Download Manager](https://dl.flathub.org/media/com/heroicgameslauncher/hgl/086b2f476c35a2b036fbad1b19d7a285/screenshots/image-5_orig.png)
Source: https://flathub.org/api/v2/appstream/com.heroicgameslauncher.hgl

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Flatpak (recommended by Heroic) | `flatpak install flathub com.heroicgameslauncher.hgl` | no |
| Arch AUR (the only AUR package Heroic supports) | `yay -S heroic-games-launcher-bin` | no |
| AppImage | `download from https://heroicgameslauncher.com/downloads, then chmod +x Heroic-*.AppImage` | no |

- Games stored outside the default paths need extra Flatpak folder access (Flatseal or flatpak override).
- Some setups need --no-sandbox for the AppImage.

- Source: https://heroicgameslauncher.com/downloads
- Source: https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/wiki/Linux-Quick-Start-Guide

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Flatpak | `flatpak install flathub com.heroicgameslauncher.hgl` | no (`--user`) | yes | ID unverified. |
| AppImage | download from GitHub releases (heroic-games-launcher), `chmod +x` | no | yes | Unverified filename. |
| AUR | `yay -S heroic-games-launcher-bin` | no | yes | Unverified. |

## Manual install (draft)
Download the AppImage and run it.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| AppImage FUSE error | FUSE 2 missing. | Install `libfuse2`. |
| Epic login fails | Browser or portal. | Check default browser (unverified). |

## Sources
- https://heroicgameslauncher.com
- https://www.gamingonlinux.com/2026/01/heroic-games-launcher-v2-19-released-adding-zoom-platform-appimage-updates-and-more/page=1/
- https://www.github.com/Heroic-Games-Launcher/HeroicGamesLauncher/releases
