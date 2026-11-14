# Lutris

- Id: `lutris` · Category: Games · Weight: medium · Licence (catalog): GPL-3.0
- Catalog sources: flatpak `net.lutris.Lutris`
- Install verified: yes · Screenshots: 1 of 3 · Logo: yes

## Overview
Lutris is an open-source game manager that installs and launches games from many sources, including Wine, emulators and native Linux builds. It is for Linux gamers who want one library for all their games.

## Facts
- Name: Lutris
- Publisher: Lutris project
- Official website: https://lutris.net/ (downloads https://lutris.net/downloads)
- Licence: not confirmed in this pass (commonly GPL; not verified; heise lists "Open Source")
- Latest version: 0.5.20 per a February 2026 GamingOnLinux article. Source: https://gamingonlinux.com/2026/02/game-manager-lutris-v0-5-20-released-with-proton-upgrades-store-updates-and-much-more
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Linux: distribution packages, Flathub, and GitHub source builds. Source: https://lutris.net/downloads (search summary)

Flathub data (https://flathub.org/api/v2/appstream/net.lutris.Lutris):
- Flatpak id: `net.lutris.Lutris` · Developer: Lutris Team · Licence: GPL-3.0-or-later
- Latest version on Flathub: 0.5.23 (released 2026-03-15)

## Logo
Bundled icon: `apps/hub/icons/lutris.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/net.lutris.Lutris.png (verified-200).

## Screenshots
![Main window](https://dl.flathub.org/media/net/lutris/Lutris/ef38bc8331f9102f611cc71700cf5770/screenshots/image-1_orig.png)
Source: https://flathub.org/api/v2/appstream/net.lutris.Lutris

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Flatpak (recommended by Lutris) | `flatpak install flathub --user -y net.lutris.Lutris` | no |
| Arch package (extra) | `sudo pacman -S lutris` | yes |

- Do not run setup.py install; it skips parts the package manager handles.

- Source: https://lutris.net/downloads
- Source: https://github.com/lutris/lutris/blob/master/INSTALL.rst

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S lutris` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install lutris` | yes | yes | PPA may be needed on older releases (unverified). |
| Flatpak | `flatpak install flathub net.lutris.Lutris` | no (`--user`) | yes | ID unverified. |

## Manual install (draft)
Not needed.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| Wine runner not found | Runner not installed. | Install wine via Lutris runners or distro (unverified). |
| 32-bit libs missing | multilib. | Install lib32 GPU libs. |

## Sources
- https://gamingonlinux.com/2026/02/game-manager-lutris-v0-5-20-released-with-proton-upgrades-store-updates-and-much-more
- https://lutris.net/downloads
