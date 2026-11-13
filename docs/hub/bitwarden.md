# Bitwarden

- Id: `bitwarden` · Category: Utilities · Weight: medium · Licence (catalog): GPL-3.0
- Catalog sources: flatpak `com.bitwarden.desktop`
- Install verified: yes · Screenshots: 1 of 3 · Logo: yes

## Overview
Bitwarden is a password manager with a desktop client for Linux, Windows and macOS, alongside web and browser extensions. It is for individuals and teams who want cloud-synced password storage.

## Facts
- Name: Bitwarden (desktop app)
- Publisher: Bitwarden Inc.
- Official website: https://bitwarden.com/ (open-source page https://bitwarden.com/en-gb/open-source.md)
- Licence: source code under GPL-3.0 per secondary sources. A news report says official app builds moved to a commercial licence while a GPLv3 version of the source is kept; details unclear. Source: https://linuxiac.com/bitwarden-moves-official-app-builds-to-commercial-license-keeps-gplv3-version/
- Latest version: not found
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Linux: desktop client from the official clients repository on GitHub; Snap listing GPL-3.0. Source: https://snapcraft.io/bitwarden.md

Flathub data (https://flathub.org/api/v2/appstream/com.bitwarden.desktop):
- Flatpak id: `com.bitwarden.desktop` · Developer: Bitwarden Inc. · Licence: LicenseRef-proprietary=https://raw.githubusercontent.com/bitwarden/clients/refs/heads/main/LICENSE_BITWARDEN.txt
- Latest version on Flathub: 2026.10.3 (released 2026-11-02)

## Logo
Bundled icon: `apps/hub/icons/bitwarden.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/com.bitwarden.desktop.png (verified-200).

## Screenshots
![Bitwarden on multiple devices](https://dl.flathub.org/media/com/bitwarden/desktop/1b8e29276714c7a0aac31a343205f421/screenshots/image-1_orig.png)
Source: https://flathub.org/api/v2/appstream/com.bitwarden.desktop

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Flatpak (official desktop app on Flathub) | `flatpak install --user flathub com.bitwarden.desktop` | no |
| AppImage | `download from https://bitwarden.com/download/, then chmod +x Bitwarden-*.AppImage` | no |

- DEB and RPM packages are also offered on the download page.
- The bitwarden.com page itself was not opened; check the current version there.

- Source: https://www.linux-magazine.com/Online/Features/Bitwarden
- Source: https://community.bitwarden.com/t/snap-vs-appimage-for-linux-install/50154

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Flatpak | `flatpak install flathub com.bitwarden.desktop` | no (`--user`) | yes | ID unverified. |
| AppImage | download from https://bitwarden.com/download/ (Linux) and run | no | yes | Unverified. |
| Snap | `sudo snap install bitwarden` | yes | yes | Unverified. |
| Arch | `sudo pacman -S bitwarden` | yes | yes | Unverified. |

## Manual install (draft)
Use the AppImage from bitwarden.com; check the signature if offered.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| Keyring unlock fails | No secret service. | Install gnome-keyring or KWallet (unverified). |
| AppImage FUSE error | FUSE 2 missing. | Install `libfuse2`. |

## Sources
- https://bitwarden.com/download/
- https://bitwarden.com/en-gb/open-source.md
- https://linuxiac.com/bitwarden-moves-official-app-builds-to-commercial-license-keeps-gplv3-version/
- https://snapcraft.io/bitwarden.md
