# LibreOffice

- Id: `libreoffice` · Category: Productivity · Weight: medium · Licence (catalog): MPL-2.0
- Catalog sources: flatpak `org.libreoffice.LibreOffice`
- Install verified: yes · Screenshots: 5 of 3 · Logo: yes

## Overview
LibreOffice is a free, open-source office suite with word processing, spreadsheet, presentation and drawing apps. It is for users who want a full office suite without a subscription.

## Facts
- Name: LibreOffice
- Publisher: The Document Foundation
- Official website: https://www.libreoffice.org/ (download https://www.libreoffice.org/download/download-libreoffice/)
- Licence: MPL-2.0 expected; not confirmed from fetched sources in this pass
- Latest version: 26.2.x per official download snapshots (26.2.4 and 26.2.5.2 seen on Snap). A 26.8 major release is reported by Ubuntu Handbook but not confirmed. Source: https://snapcraft.io/libreoffice.md
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Linux: Flatpak, Snap, deb/rpm and AppImage from the official site. Source: search summary of libreoffice.org download pages

Flathub data (https://flathub.org/api/v2/appstream/org.libreoffice.LibreOffice):
- Flatpak id: `org.libreoffice.LibreOffice` · Developer: The Document Foundation · Licence: MPL-2.0
- Latest version on Flathub: 26.8.3.1 (released 2026-11-13)

## Logo
Bundled icon: `apps/hub/icons/libreoffice.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/org.libreoffice.LibreOffice.png (verified-200).

## Screenshots
![Sample Writer document](https://dl.flathub.org/media/org/libreoffice/LibreOffice/341e8fb5e2267b0cdc5e932b3886a08e/screenshots/image-1_orig.png)
![Sample Calc document](https://dl.flathub.org/media/org/libreoffice/LibreOffice/341e8fb5e2267b0cdc5e932b3886a08e/screenshots/image-2_orig.png)
![Sample Impress document](https://dl.flathub.org/media/org/libreoffice/LibreOffice/341e8fb5e2267b0cdc5e932b3886a08e/screenshots/image-3_orig.png)
![Sample Draw document](https://dl.flathub.org/media/org/libreoffice/LibreOffice/341e8fb5e2267b0cdc5e932b3886a08e/screenshots/image-4_orig.png)
![Sample Base document](https://dl.flathub.org/media/org/libreoffice/LibreOffice/341e8fb5e2267b0cdc5e932b3886a08e/screenshots/image-5_orig.png)
Source: https://flathub.org/api/v2/appstream/org.libreoffice.LibreOffice

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Flatpak (official, distributed on Flathub) | `flatpak install flathub org.libreoffice.LibreOffice` | no |
| Help pages (separate extension) | `flatpak install flathub org.libreoffice.LibreOffice.Help` | no |

- The Flatpak uses the GTK3 backend and supports Wayland.
- flatpak uninstall --delete-data removes your LibreOffice profile; back it up first.

- Source: https://www.libreoffice.org/download/flatpak/

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S libreoffice-fresh` (or `libreoffice-still`) | yes | yes | Package names unverified. |
| Debian/Ubuntu | `sudo apt install libreoffice` | yes | yes | |
| Fedora | `sudo dnf install libreoffice` | yes | yes | |
| Flatpak | `flatpak install flathub org.libreoffice.LibreOffice` | no (`--user`) | yes | ID unverified. |
| Vendor tarball | download from https://www.libreoffice.org/download/ | no | yes | Unverified. |

## Manual install (draft)
Use vendor tarball if needed.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| Java features missing | JRE not installed. | Install a JRE package (unverified). |
| Slow start | First launch profile. | Wait; or disable extensions. |

## Sources
- https://snapcraft.io/libreoffice.md
- https://www.libreoffice.org/download/
- https://www.libreoffice.org/download/download-libreoffice/
