# DB Browser for SQLite

- Id: `sqlitebrowser` · Category: Development · Weight: light · Licence (catalog): GPL-3.0
- Catalog sources: flatpak `org.sqlitebrowser.sqlitebrowser`
- Install verified: yes · Screenshots: 4 of 3 · Logo: yes

## Overview
DB Browser for SQLite is a visual tool for creating, designing and editing SQLite database files. It is for developers and analysts who want a GUI for SQLite.

## Facts
- Name: DB Browser for SQLite
- Publisher: DB4S project (sqlitebrowser)
- Official website: not confirmed in this pass; repository https://github.com/sqlitebrowser/sqlitebrowser
- Licence: dual MPL-2.0 or GPL-3.0-or-later. Source: https://snapcraft.io/sqlitebrowser.md (search summary)
- Latest version: not found
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Linux install: distro packages (apt, dnf, pacman), Snap, AppImage, or source build (BUILDING.md). Source: https://snapcraft.io/sqlitebrowser

Flathub data (https://flathub.org/api/v2/appstream/org.sqlitebrowser.sqlitebrowser):
- Flatpak id: `org.sqlitebrowser.sqlitebrowser` · Developer: DB Browser for SQLite developers · Licence: MPL-2.0 and GPL-3.0+
- Latest version on Flathub: 3.13.1 (released 2024-10-16)

## Logo
Bundled icon: `apps/hub/icons/sqlitebrowser.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/org.sqlitebrowser.sqlitebrowser.png (verified-200).

## Screenshots
![DB Browser for SQLite, executing query](https://dl.flathub.org/media/org/sqlitebrowser/sqlitebrowser/f936f43dea69ed8f0e3eeb8e936ac8d4/screenshots/image-1_orig.png)
![DB Browser for SQLite, browsing data with plot](https://dl.flathub.org/media/org/sqlitebrowser/sqlitebrowser/f936f43dea69ed8f0e3eeb8e936ac8d4/screenshots/image-2_orig.png)
![DB Browser for SQLite, browsing a blob field](https://dl.flathub.org/media/org/sqlitebrowser/sqlitebrowser/f936f43dea69ed8f0e3eeb8e936ac8d4/screenshots/image-3_orig.png)
![DB Browser for SQLite, creating a table](https://dl.flathub.org/media/org/sqlitebrowser/sqlitebrowser/f936f43dea69ed8f0e3eeb8e936ac8d4/screenshots/image-4_orig.png)
Source: https://flathub.org/api/v2/appstream/org.sqlitebrowser.sqlitebrowser

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Flatpak | `flatpak install flathub org.sqlitebrowser.sqlitebrowser` | no |
| Arch package | `sudo pacman -S sqlitebrowser` | yes |

- Flathub lists about 17.3 MiB installed.

- Source: https://flathub.org/it/apps/org.sqlitebrowser.sqlitebrowser
- Source: https://linuxcapable.com/how-to-install-sqlite-on-arch-linux/

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Flatpak | `flatpak install flathub org.sqlitebrowser.sqlitebrowser` | no (`--user`) | yes | ID unverified. |
| Arch repos | `sudo pacman -S sqlitebrowser` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install sqlitebrowser` | yes | yes | Unverified. |

## Manual install (draft)
Not needed.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| Flatpak cannot open file | Sandbox. | `flatpak override --user --filesystem=xdg-documents org.sqlitebrowser.sqlitebrowser` (unverified). |

## Sources
- https://github.com/sqlitebrowser/sqlitebrowser
- https://snapcraft.io/sqlitebrowser.md
- https://sqlitebrowser.org
