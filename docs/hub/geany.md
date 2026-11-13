# Geany

- Id: `geany` · Category: Development · Weight: light · Licence (catalog): GPL-2.0
- Catalog sources: pacman `geany`
- Install verified: yes · Screenshots: 3 of 3 · Logo: yes

## Overview
Geany is a lightweight, fast IDE-style text editor using GTK, with syntax highlighting, code folding, symbol lists and build integration. It is for developers and students who want a small, quick editor rather than a full IDE.

## Facts
- Name: Geany
- Publisher: Geany developers (community project)
- Official website: https://www.geany.org/
- Licence: GPL v2 per the official site (GitHub README says GPL v2 or later; a SourceForge listing says GPLv3, which conflicts). Source: https://www.geany.org/ and https://github.com/geany/geany
- Latest version: Geany 2.1.0, released July 2025, seen 2026-11-13. Source: https://www.geany.org/
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Platforms: Linux, macOS, Windows; Linux users usually install via distro packages. Source: https://www.geany.org/

## Logo
Bundled icon: `apps/hub/icons/geany.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/org.geany.Geany.png (verified-200).

## Screenshots
- ![Main screen](https://www.geany.org/media/uploads/screenshots/homepage/.thumbnails/geany_dark_2019-05-20.png/geany_dark_2019-05-20-500x0.png) Caption: main screen with dark theme (official site, 2019 image).
- ![Main screen with dark theme](https://www.geany.org/media/uploads/screenshots/homepage/.thumbnails/geany_light_php-2019-06-15.png/geany_light_php-2019-06-15-500x0.png) Caption: light theme with PHP file (official site).
- ![Build process](https://www.geany.org/media/uploads/screenshots/homepage/.thumbnails/geany_windows_classic-2019-06-09.png/geany_windows_classic-2019-06-09-500x0.png) Caption: build process (official site; Windows classic theme).

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Arch package (extra; listed on geany.org) | `sudo pacman -S geany` | yes |
| Plugins | `sudo pacman -S geany-plugins` | yes |


- Source: https://www.geany.org/download/third-party
- Source: https://archlinux.org/packages/extra/x86_64/geany/

## Install options (research draft; unverified. Search was rate-limited; commands from model knowledge.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S geany` | yes | yes | Common package name. |
| Debian/Ubuntu | `sudo apt install geany` | yes | yes | Can be an older version than Flathub. |
| Fedora | `sudo dnf install geany` | yes | yes | Unverified. |
| Flatpak | `flatpak install flathub org.geany.Geany` | no (`--user`) | yes | ID unverified. Run with `flatpak run org.geany.Geany`. |

## Manual install (draft)
Not needed.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| `remote "flathub" not found` | Flathub missing. | Add Flathub remote (see Kate entry). |
| Flatpak cannot open project files | Sandbox. | `flatpak override --user --filesystem=xdg-documents org.geany.Geany` (unverified). |
| Missing compiler/run output | Build tools not installed. | Install `gcc`/`make` through the distro (unverified). |

## Sources
- https://flathub.org
- https://github.com/geany/geany
- https://www.geany.org
- https://www.geany.org/
