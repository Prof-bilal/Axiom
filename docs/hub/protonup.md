# ProtonUp-Qt

- Id: `protonup` · Category: Games · Weight: light · Licence (catalog): GPL-3.0
- Catalog sources: flatpak `net.davidotek.pupgui2`
- Install verified: yes · Screenshots: 3 of 3 · Logo: yes

## Overview
ProtonUp-Qt is a graphical tool for installing and managing community Proton and Wine builds (GE-Proton, Wine-GE, and others) for Steam and Lutris. It is for Linux gamers who want newer compatibility layers.

## Facts
- Name: ProtonUp-Qt
- Publisher: DavidoTek (open-source project)
- Official website: not confirmed in this pass; repository https://github.com/DavidoTek/ProtonUp-Qt
- Licence: GPL-3.0-or-later per a CachyOS package listing; not confirmed in the repository in this pass. Source: https://packages.cachyos.org/package/cachyos/any/protonup-qt (search summary)
- Latest version: 2.15.1 per Linuxiac (release date not confirmed). Source: https://linuxiac.com/protonup-qt-2-15-1-linux-gaming-utility-released-with-arm-ge-proton-fix/
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Linux: Flathub (recommended), AppImage, distribution packages. Source: search summary

Flathub data (https://flathub.org/api/v2/appstream/net.davidotek.pupgui2):
- Flatpak id: `net.davidotek.pupgui2` · Developer: DavidoTek · Licence: GPL-3.0
- Latest version on Flathub: 2.16.0 (released 2026-10-11)

## Logo
Bundled icon: `apps/hub/icons/protonup.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/net.davidotek.pupgui2.png (verified-200).

## Screenshots
![ProtonUp-Qt screenshot 1](https://dl.flathub.org/media/net/davidotek/pupgui2/cb80abc806d40793dec0412c81f83c68/screenshots/image-1_orig.png)
![ProtonUp-Qt screenshot 2](https://dl.flathub.org/media/net/davidotek/pupgui2/cb80abc806d40793dec0412c81f83c68/screenshots/image-2_orig.png)
![ProtonUp-Qt screenshot 3](https://dl.flathub.org/media/net/davidotek/pupgui2/cb80abc806d40793dec0412c81f83c68/screenshots/image-3_orig.png)
Source: https://flathub.org/api/v2/appstream/net.davidotek.pupgui2

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Flatpak (recommended in release notes) | `flatpak install flathub net.davidotek.pupgui2` | no |
| AppImage (GitHub releases) | `download from https://github.com/DavidoTek/ProtonUp-Qt/releases, then chmod +x ProtonUp-Qt*.AppImage` | no |

- The exact flatpak install command was not shown in sources; the app id is confirmed by the Flathub link in the README.

- Source: https://github.com/DavidoTek/ProtonUp-Qt/blob/main/README.md

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Flatpak | `flatpak install flathub net.davidotek.pupgui2` | no (`--user`) | yes | ID unverified. |
| pipx (CLI: protonup-ng style tool) | `pipx install protonup` | no | yes | Unverified; ProtonUp CLI name varies. |
| AUR | `yay -S protonup-qt` | no | yes | Unverified. |

## Manual install (draft)
Not needed.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| Steam does not show new Proton | Steam not restarted or compat dir wrong. | Restart Steam. Check Steam compatibility tools path (unverified). |
| Flatpak cannot find Steam library | Sandbox. | Flatpak override (unverified). |

## Sources
- https://davidotek.github.io/protonup-qt/
- https://github.com/DavidoTek/ProtonUp-Qt
- https://linuxiac.com/protonup-qt-2-15-1-linux-gaming-utility-released-with-arm-ge-proton-fix/
