# Prism Launcher

- Id: `prism` · Category: Games · Weight: medium · Licence (catalog): GPL-3.0
- Catalog sources: flatpak `org.prismlauncher.PrismLauncher`
- Install verified: yes · Screenshots: 5 of 3 · Logo: yes

## Overview
Prism Launcher is an open-source launcher for Minecraft that manages multiple instances, mod loaders and accounts. It is for Minecraft players who want an alternative launcher with multi-instance support.

## Facts
- Name: Prism Launcher
- Publisher: Prism Launcher project
- Official website: https://prismlauncher.org/ (per the repository README)
- Licence: GPL-3.0-only for the launcher code; logo and assets CC BY-SA 4.0 (per the repository README). Source: https://github.com/PrismLauncher/PrismLauncher
- Latest version: 11.1.1 per Alpine AppStream metadata (seen 2026-11-13; not confirmed on the official site). Source: https://appstream.alpinelinux.org/html/edge/community/metainfo/prismlauncher.html
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Linux: official downloads page, Snap and distribution packages. Source: search summary

Flathub data (https://flathub.org/api/v2/appstream/org.prismlauncher.PrismLauncher):
- Flatpak id: `org.prismlauncher.PrismLauncher` · Developer: Prism Launcher Contributors · Licence: GPL-3.0-only
- Latest version on Flathub: 11.1.1 (released 2011-11-11)

## Logo
Bundled icon: `apps/hub/icons/prism.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/org.prismlauncher.PrismLauncher.png (verified-200).

## Screenshots
![The main Prism Launcher window](https://dl.flathub.org/media/org/prismlauncher/PrismLauncher/61a6268120825540bced2adcb8e6b734/screenshots/image-1_orig.png)
![Modpack installation](https://dl.flathub.org/media/org/prismlauncher/PrismLauncher/61a6268120825540bced2adcb8e6b734/screenshots/image-2_orig.png)
![Modpack updating](https://dl.flathub.org/media/org/prismlauncher/PrismLauncher/61a6268120825540bced2adcb8e6b734/screenshots/image-3_orig.png)
![Mod installation](https://dl.flathub.org/media/org/prismlauncher/PrismLauncher/61a6268120825540bced2adcb8e6b734/screenshots/image-4_orig.png)
![Mod updating](https://dl.flathub.org/media/org/prismlauncher/PrismLauncher/61a6268120825540bced2adcb8e6b734/screenshots/image-5_orig.png)
Source: https://flathub.org/api/v2/appstream/org.prismlauncher.PrismLauncher

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Flatpak (primary method on Linux) | `flatpak install flathub org.prismlauncher.PrismLauncher` | no |
| Arch package | `sudo pacman -S prismlauncher` | yes |

- An x86_64 AppImage is also on GitHub releases.
- Minecraft needs a Microsoft account to play.

- Source: https://wiki.alpinelinux.org/wiki/Prism_Launcher
- Source: https://79dbc715-prismlauncher.scrumplex.workers.dev/download/linux

## Install options (research draft; unverified this session. Prism is a Minecraft launcher (PrismLauncher project).)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S prismlauncher` | yes | yes | Unverified package name. |
| Flatpak | `flatpak install flathub org.prismlauncher.PrismLauncher` | no (`--user`) | yes | ID unverified. |
| AppImage | download from https://prismlauncher.org/download/linux/ | no | yes | Unverified. |

## Manual install (draft)
Use the AppImage from prismlauncher.org.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| Java not found | Java runtime missing. | Install a JDK matching the Minecraft version (unverified). |
| AppImage FUSE error | FUSE 2 missing. | Install `libfuse2`. |

## Sources
- https://appstream.alpinelinux.org/html/edge/community/metainfo/prismlauncher.html
- https://github.com/PrismLauncher/PrismLauncher
- https://prismlauncher.org/download/linux/
