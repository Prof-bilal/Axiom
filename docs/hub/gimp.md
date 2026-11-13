# GIMP

- Id: `gimp` · Category: Graphics · Weight: medium · Licence (catalog): GPL-3.0
- Catalog sources: flatpak `org.gimp.GIMP`
- Install verified: yes · Screenshots: 4 of 3 · Logo: yes

## Overview
GIMP (GNU Image Manipulation Program) is a free, open-source raster image editor for photo retouching, painting and graphic design. It is for designers, photographers and hobbyists who want a full-featured editor without a subscription.

## Facts
- Name: GIMP
- Publisher: GIMP development team (GNU project)
- Official website: https://www.gimp.org/ (downloads https://www.gimp.org/downloads/)
- Licence: GPL-3.0-or-later per Wikipedia (search summary); Snap listing says GPL-3.0+ AND LGPL-3.0+. Source: https://www.wikipedia.org/wiki/GIMP
- Latest version: 3.0.6 (released 2025-10-05) per a gimp.org snapshot; a 2026 source mentions 3.2.4. Current version not confirmed. Source: https://www.gimp.org/downloads/ (search summary)
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Linux: AppImage (x86_64 and ARM64), Flathub and Snap. Source: https://www.gimp.org/downloads/ (search summary)

Flathub data (https://flathub.org/api/v2/appstream/org.gimp.GIMP):
- Flatpak id: `org.gimp.GIMP` · Developer: The GIMP team · Licence: GPL-3.0+ AND LGPL-3.0+
- Latest version on Flathub: 3.2.8 (released 2026-11-02)

## Logo
Bundled icon: `apps/hub/icons/gimp.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/org.gimp.GIMP.png (verified-200).

## Screenshots
![Scene 4 cut 15 of "ZeMarmot" being edited in GIMP. Illustration by Aryeom (CC by-sa 4.0 International)](https://dl.flathub.org/media/org/gimp/GIMP/800933a572869e1c8daee367dc2287cb/screenshots/image-1_orig.png)
![Gull on beach photograph being edited in GIMP. Photo by Iana (CC by-sa 4.0 International)](https://dl.flathub.org/media/org/gimp/GIMP/800933a572869e1c8daee367dc2287cb/screenshots/image-2_orig.png)
![Portrait of Sofiia being edited in GIMP. Photo by Sofia (CC by-sa 4.0 International)](https://dl.flathub.org/media/org/gimp/GIMP/800933a572869e1c8daee367dc2287cb/screenshots/image-3_orig.png)
![Scanned engraving being edited in GIMP. Artwork by Liam (CC0)](https://dl.flathub.org/media/org/gimp/GIMP/800933a572869e1c8daee367dc2287cb/screenshots/image-4_orig.png)
Source: https://flathub.org/api/v2/appstream/org.gimp.GIMP

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Flatpak (called official in guides) | `flatpak install flathub org.gimp.GIMP` | no |
| Remove with data | `flatpak uninstall --delete-data org.gimp.GIMP` | no |

- Missing menu icon after install: log out and back in.
- The gimp.org page itself was not opened; Flatpak details come from guides.

- Source: https://ostechnix.com/install-gimp-linux/
- Source: https://linuxcapable.com/install-gimp-on-fedora-linux/

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S gimp` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install gimp` | yes | yes | |
| Fedora | `sudo dnf install gimp` | yes | yes | |
| Flatpak | `flatpak install flathub org.gimp.GIMP` | no (`--user`) | yes | ID unverified. |

## Manual install (draft)
Not needed.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| Missing plugins | Plugin package not installed. | Install `gimp-plugin-*` packages (unverified). |
| Flatpak cannot open files outside home | Sandbox. | `flatpak override` (unverified). |

## Sources
- https://snapcraft.io/gimp
- https://www.gimp.org/downloads/
