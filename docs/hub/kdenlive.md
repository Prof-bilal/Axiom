# Kdenlive

- Id: `kdenlive` · Category: Multimedia · Weight: heavy · Licence (catalog): GPL-3.0
- Catalog sources: flatpak `org.kde.kdenlive`
- Install verified: yes · Screenshots: 5 of 3 · Logo: yes

## Overview
Kdenlive is a free, open-source non-linear video editor from the KDE community with multitrack editing and effects. It is for video creators who want a full editor on Linux.

## Facts
- Name: Kdenlive
- Publisher: KDE community
- Official website: https://kdenlive.org/download
- Licence: not confirmed in this pass (commonly GPL; not verified)
- Latest version: 26.04.2 per a third-party listing (Neowin); the official download page snapshots were older. Source: https://www.neowin.net/software/kdenlive-26040/ (unverified)
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Linux: AppImage and Flatpak are the officially supported packages; Flathub stable build. Source: https://docs.kdenlive.org/en/getting_started/installation.html (search summary)

Flathub data (https://flathub.org/api/v2/appstream/org.kde.kdenlive):
- Flatpak id: `org.kde.kdenlive` · Developer: KDE · Licence: GPL-3.0-only
- Latest version on Flathub: 26.08.3 (released 2026-11-05)

## Logo
Bundled icon: `apps/hub/icons/kdenlive.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/org.kde.kdenlive.png (verified-200).

## Screenshots
![Dark theme](https://dl.flathub.org/media/org/kde/kdenlive.desktop/43ea1daa3a961b305292f8cd7ccae60f/screenshots/image-1_orig.png)
![Default interface](https://dl.flathub.org/media/org/kde/kdenlive.desktop/43ea1daa3a961b305292f8cd7ccae60f/screenshots/image-2_orig.png)
![Color correction](https://dl.flathub.org/media/org/kde/kdenlive.desktop/43ea1daa3a961b305292f8cd7ccae60f/screenshots/image-3_orig.png)
![Configurable interface](https://dl.flathub.org/media/org/kde/kdenlive.desktop/43ea1daa3a961b305292f8cd7ccae60f/screenshots/image-4_orig.png)
![Titling](https://dl.flathub.org/media/org/kde/kdenlive.desktop/43ea1daa3a961b305292f8cd7ccae60f/screenshots/image-5_orig.png)
Source: https://flathub.org/api/v2/appstream/org.kde.kdenlive

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Flatpak (officially supported) | `flatpak install flathub org.kde.kdenlive` | no |
| AppImage (officially supported) | `download from https://kdenlive.org/en/download/, then chmod +x kdenlive-*.AppImage` | no |

- Only AppImage and Flatpak releases are officially supported; the Ubuntu PPA was dropped.

- Source: https://docs.kdenlive.org/en/getting_started/installation.html

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S kdenlive` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install kdenlive` | yes | yes | |
| Flatpak | `flatpak install flathub org.kde.kdenlive` | no (`--user`) | yes | ID unverified. |
| AppImage | download from https://kdenlive.org/download/ | no | yes | Unverified. |

## Manual install (draft)
Not needed.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| Missing MLT codecs | Codec package. | Install the MLT/FFmpeg codec packages (unverified). |
| Flatpak cannot read media | Sandbox. | `flatpak override` (unverified). |

## Sources
- https://docs.kdenlive.org/en/getting_started/installation.html
- https://kdenlive.org/download
- https://kdenlive.org/download/
