# KeePassXC

- Id: `keepassxc` · Category: Utilities · Weight: light · Licence (catalog): GPL-3.0
- Catalog sources: flatpak `org.keepassxc.KeePassXC`
- Install verified: yes · Screenshots: 4 of 3 · Logo: yes

## Overview
KeePassXC is a cross-platform, offline password manager that stores encrypted database files, with browser integration and a Qt interface. It is for users who want a local password manager compatible with the KeePass format.

## Facts
- Name: KeePassXC
- Publisher: KeePassXC Team
- Official website: not confirmed in this pass; repository https://github.com/keepassxreboot/keepassxc
- Licence: GPL-3.0-or-later per the Snap Store listing (official site not confirmed). Source: https://snapcraft.io/keepassxc.md
- Latest version: 2.8.0 per an October 2026 Ubuntu Handbook report (seen 2026-11-13). Source: https://ubuntuhandbook.org/index.php/2026/10/keepassxc-2-8-0-finally-released-after-a-month-of-beta-testing/
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Linux: AppImage (standard), Flatpak via Flathub (maintainers' preference), Ubuntu PPA. Source: https://linuxiac.com/keepassxc-2-8-password-manager-released-with-qt-6-wayland-support/ (search summary)

Flathub data (https://flathub.org/api/v2/appstream/org.keepassxc.KeePassXC):
- Flatpak id: `org.keepassxc.KeePassXC` · Developer: KeePassXC Team · Licence: GPL-3.0-or-later
- Latest version on Flathub: 2.8.0 (released 2026-10-21)

## Logo
Bundled icon: `apps/hub/icons/keepassxc.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/org.keepassxc.KeePassXC.png (verified-200).

## Screenshots
![Organize with Groups and Entries](https://dl.flathub.org/media/org/keepassxc/KeePassXC.desktop/8703bd4e659abcb1dac1d6646881bb00/screenshots/image-1_orig.png)
![Unlock database](https://dl.flathub.org/media/org/keepassxc/KeePassXC.desktop/8703bd4e659abcb1dac1d6646881bb00/screenshots/image-2_orig.png)
![Icon Selection for Entry](https://dl.flathub.org/media/org/keepassxc/KeePassXC.desktop/8703bd4e659abcb1dac1d6646881bb00/screenshots/image-3_orig.png)
![Password Generator](https://dl.flathub.org/media/org/keepassxc/KeePassXC.desktop/8703bd4e659abcb1dac1d6646881bb00/screenshots/image-4_orig.png)
Source: https://flathub.org/api/v2/appstream/org.keepassxc.KeePassXC

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Flatpak (amd64 and arm64 only) | `flatpak install flathub org.keepassxc.KeePassXC` | no |
| Official AppImage | `download from https://keepassxc.org/download/#linux, then chmod +x KeePassXC-*.AppImage` | no |

- AppImages need FUSE 2 (fuse2 on Arch, libfuse2 on Ubuntu 22.04+).

- Source: https://www.linuxcapable.com/how-to-install-keepassxc-on-ubuntu-22-04-lts/
- Source: https://www.rz.uni-kiel.de/en/hints-howtos/password-manager-keepassxc/installing-keepassxc/installation-on-linux/installation-and-initial-setup-of-keepassxc-on-linux

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S keepassxc` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install keepassxc` | yes | yes | |
| Fedora | `sudo dnf install keepassxc` | yes | yes | |
| Flatpak | `flatpak install flathub org.keepassxc.KeePassXC` | no (`--user`) | yes | ID unverified. |
| AppImage | download from https://keepassxc.org/download/ | no | yes | Verify signature per project docs. |

## Manual install (draft)
Not needed.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| Browser integration not working | Browser extension or native messaging path. | Follow KeePassXC browser integration docs (unverified). |
| Secret Service not available | No keyring. | Install and run a secret service (unverified). |

## Sources
- https://keepassxc.org/download/
- https://snapcraft.io/keepassxc.md
- https://ubuntuhandbook.org/index.php/2026/10/keepassxc-2-8-0-finally-released-after-a-month-of-beta-testing/
