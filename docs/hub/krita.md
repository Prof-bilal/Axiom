# Krita

- Id: `krita` · Category: Graphics · Weight: medium · Licence (catalog): GPL-3.0
- Catalog sources: flatpak `org.kde.krita`
- Install verified: yes · Screenshots: 5 of 3 · Logo: yes

## Overview
Krita is a free, open-source digital painting and illustration application with brushes, animation and comics tools. It is for artists and illustrators who want a professional paint program without a licence fee.

## Facts
- Name: Krita
- Publisher: Krita Foundation (KDE community)
- Official website: https://krita.org/en/download/
- Licence: GNU GPL v3 per the Krita site summary. Source: https://krita.org/en/download/ (search summary)
- Latest version: Krita 5.3.4 and 6.0.4 released September 15, 2026, per an Ubuntu Handbook report (seen 2026-11-13). Official download page versions conflict across snapshots. Source: https://ubuntuhandbook.org/index.php/2026/09/ppa-updated-with-krita-6-0-4-krita-5-3-4-for-ubuntu-26-04-24-04/
- Typical install size: Linux AppImage about 364 MB per one source (third-party). Source: search summary
- Minimum RAM: 4 GB per the official download page; 16 GB recommended (search summary). Source: https://krita.org/en/download/
- CPU: not found
- Disk: not found
- GPU: OpenGL 3.0 or higher, or Direct3D 11 (search summary). Source: https://krita.org/en/download/
- Linux: AppImage is the official build; Flatpak and Snap are community-maintained. Source: https://docs.krita.org/Installation (search summary)

Flathub data (https://flathub.org/api/v2/appstream/org.kde.krita):
- Flatpak id: `org.kde.krita` · Developer: Krita Foundation · Licence: GPL-3.0-only
- Latest version on Flathub: 5.3.4.1 (released 2026-10-07)

## Logo
Bundled icon: `apps/hub/icons/krita.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/org.kde.krita.png (verified-200).

## Screenshots
![Krita is a full-featured digital painting studio](https://dl.flathub.org/media/org/kde/krita/1348962dcc0842250c4ce6876acc36cc/screenshots/image-1_orig.png)
![The startup window now also gives you the latest news about Krita](https://dl.flathub.org/media/org/kde/krita/1348962dcc0842250c4ce6876acc36cc/screenshots/image-2_orig.png)
![There are over ten immensely powerful brush engines](https://dl.flathub.org/media/org/kde/krita/1348962dcc0842250c4ce6876acc36cc/screenshots/image-3_orig.png)
![Into animation? Krita provides everything you need for traditional, hand-drawn animation](https://dl.flathub.org/media/org/kde/krita/1348962dcc0842250c4ce6876acc36cc/screenshots/image-4_orig.png)
![If you're new to digital painting, there's an extensive, up-to-date manual](https://dl.flathub.org/media/org/kde/krita/1348962dcc0842250c4ce6876acc36cc/screenshots/image-5_orig.png)
Source: https://flathub.org/api/v2/appstream/org.kde.krita

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Flatpak (user install, per Krita docs) | `flatpak --user install flathub org.kde.krita` | no |
| AppImage | `download from https://krita.org/en/download/, then chmod +x krita-*-x86_64.AppImage` | no |

- The Flathub build can lag behind the AppImage release.
- AppImages need FUSE 2 (fuse2 on Arch, libfuse2t64 on Mint 22).

- Source: https://docs.krita.org/Installation
- Source: https://linuxcapable.com/how-to-install-krita-on-linux-mint/

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S krita` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install krita` | yes | yes | |
| Flatpak | `flatpak install flathub org.kde.krita` | no (`--user`) | yes | ID unverified. |
| AppImage | download from https://krita.org/download | no | yes | Unverified. |

## Manual install (draft)
Use AppImage from krita.org if needed.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| Canvas blank or slow | GPU OpenGL issue. | Update GPU driver; set OpenGL to "Auto" in settings (unverified). |
| AppImage FUSE error | FUSE 2 missing. | Install `libfuse2`. |

## Sources
- https://docs.krita.org/Installation
- https://krita.org/download
- https://krita.org/en/download/
- https://ubuntuhandbook.org/index.php/2026/09/ppa-updated-with-krita-6-0-4-krita-5-3-4-for-ubuntu-26-04-24-04/
