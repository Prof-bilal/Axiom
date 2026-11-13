# Wireshark

- Id: `wireshark` · Category: System · Weight: medium · Licence (catalog): GPL-2.0
- Catalog sources: flatpak `org.wireshark.Wireshark`, pacman `wireshark-qt`
- Install verified: yes · Screenshots: 3 of 3 · Logo: yes

## Overview
Wireshark is a network protocol analyser for capturing and inspecting packets with a graphical interface and CLI tools. It is for network engineers, security analysts and developers debugging traffic.

## Facts
- Name: Wireshark
- Publisher: Wireshark Foundation
- Official website: https://www.wireshark.org/ (downloads https://www.wireshark.org/download.html)
- Licence: GPL-2.0 per a third-party listing (FOSSHub); not confirmed on wireshark.org in this pass. Source: https://www.fosshub.com/Wireshark.html
- Latest version: 4.6.9 per a third-party listing (FOSSHub); not confirmed on the official page. Source: https://www.fosshub.com/Wireshark.html
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Linux: official PPA ppa:wireshark-dev/stable for Ubuntu; distribution packages; source archives on the download page. Source: https://www.wireshark.org/download.html (search summary)

Flathub data (https://flathub.org/api/v2/appstream/org.wireshark.Wireshark):
- Flatpak id: `org.wireshark.Wireshark` · Developer: The Wireshark developer community · Licence: GPL-2.0
- Latest version on Flathub: 4.6.9 (released 2026-09-20)

## Logo
Bundled icon: `apps/hub/icons/wireshark.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/org.wireshark.Wireshark.png (verified-200).

## Screenshots
![Wireshark's main window](https://dl.flathub.org/media/org/wireshark/Wireshark/fc127d7493e8aface3009264399618b9/screenshots/image-1_orig.png)
![Wireshark I/O Graph](https://dl.flathub.org/media/org/wireshark/Wireshark/fc127d7493e8aface3009264399618b9/screenshots/image-2_orig.png)
![Wireshark Conversations](https://dl.flathub.org/media/org/wireshark/Wireshark/fc127d7493e8aface3009264399618b9/screenshots/image-3_orig.png)
Source: https://flathub.org/api/v2/appstream/org.wireshark.Wireshark

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Arch package (GUI) | `sudo pacman -S wireshark-qt` | yes |
| Arch package (CLI only, tshark) | `sudo pacman -S wireshark-cli` | yes |
| Allow capture as your user (then log in again) | `sudo gpasswd -a $USER wireshark` | yes |
| Flatpak (analysis only, no live capture) | `flatpak install flathub org.wireshark.Wireshark` | no |

- /usr/bin/dumpcap runs only for root and the wireshark group; the Arch package creates the group.
- The Flathub build cannot capture live traffic; use the native package for capture.

- Source: https://wiki.archlinux.org/title/Wireshark
- Source: https://wiki.wireshark.org/CaptureSetup/CapturePrivileges/

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S wireshark-qt` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install wireshark` | yes | yes | Asks whether non-root users may capture. |
| Fedora | `sudo dnf install wireshark` | yes | yes | |
| Flatpak | `flatpak install flathub org.wireshark.Wireshark` | no (`--user`) | yes | Flatpak capture needs extra setup (unverified). |

## Manual install (draft)
Not needed.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| `You don't have permission to capture on that device` | Non-root user not in wireshark group. | `sudo usermod -aG wireshark $USER` then re-login. Capture rights are powerful; grant only if needed. |
| No interfaces listed | Capture permissions. | Same as above, or run `dumpcap` setup (unverified). |

## Sources
- https://www.fosshub.com/Wireshark.html
- https://www.wireshark.org/download.html
