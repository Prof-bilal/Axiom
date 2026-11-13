# Inkscape

- Id: `inkscape` · Category: Graphics · Weight: medium · Licence (catalog): GPL-3.0
- Catalog sources: flatpak `org.inkscape.Inkscape`
- Install verified: yes · Screenshots: 4 of 3 · Logo: yes

## Overview
Inkscape is a free, open-source vector graphics editor for SVG illustration, logos and print design. It is for designers and illustrators who want an SVG-native editor.

## Facts
- Name: Inkscape
- Publisher: Inkscape project
- Official website: https://inkscape.org/
- Licence: GPL-3.0 per the Snap Store listing. Source: https://snapcraft.io/inkscape
- Latest version: 1.4.4 per the Snap Store latest/stable channel (seen 2026-11-13). Source: https://snapcraft.io/inkscape
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Source code: https://gitlab.com/inkscape/inkscape. Linux builds: AppImage, Flatpak, Snap. Source: search summary

Flathub data (https://flathub.org/api/v2/appstream/org.inkscape.Inkscape):
- Flatpak id: `org.inkscape.Inkscape` · Developer: The Inkscape Community · Licence: GPL-2.0-or-later
- Latest version on Flathub: 1.4.4 (released 2026-05-06)

## Logo
Bundled icon: `apps/hub/icons/inkscape.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/org.inkscape.Inkscape.png (verified-200).

## Screenshots
![Editing a Flatpak Logo](https://dl.flathub.org/media/org/inkscape/Inkscape/d06b79da7ad6df73032683fbcf8c4d56/screenshots/image-1_orig.png)
![Multipage editing](https://dl.flathub.org/media/org/inkscape/Inkscape/d06b79da7ad6df73032683fbcf8c4d56/screenshots/image-2_orig.png)
![Editing with Inkscape](https://dl.flathub.org/media/org/inkscape/Inkscape/d06b79da7ad6df73032683fbcf8c4d56/screenshots/image-3_orig.png)
![Gradient editing](https://dl.flathub.org/media/org/inkscape/Inkscape/d06b79da7ad6df73032683fbcf8c4d56/screenshots/image-4_orig.png)
Source: https://flathub.org/api/v2/appstream/org.inkscape.Inkscape

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Flatpak | `flatpak install flathub org.inkscape.Inkscape` | no |
| AppImage (official release listing) | `download from https://inkscape.org/release/all/gnulinux/appimage/` | no |
| Arch package | `sudo pacman -S inkscape` | yes |

- No inkscape.org page explicitly names the Flatpak id; it comes from guides and Flathub.

- Source: https://inkscape.org/release/all/gnulinux/appimage
- Source: https://wiki.inkscape.org/wiki/InstallHelp
- Source: https://linuxcapable.com/how-to-install-inkscape-on-ubuntu-linux

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S inkscape` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install inkscape` | yes | yes | |
| Flatpak | `flatpak install flathub org.inkscape.Inkscape` | no (`--user`) | yes | ID unverified. |

## Manual install (draft)
Not needed.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| Missing extensions | Python extension deps. | Install Python packages used by extensions (unverified). |
| Flatpak cannot open files | Sandbox. | `flatpak override` (unverified). |

## Sources
- https://gitlab.com/inkscape/inkscape
- https://inkscape.org/release/
- https://snapcraft.io/inkscape
