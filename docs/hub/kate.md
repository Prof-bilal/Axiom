# Kate

- Id: `kate` · Category: Development · Weight: light · Licence (catalog): GPL-2.0
- Catalog sources: flatpak `org.kde.kate`
- Install verified: yes · Screenshots: 4 of 3 · Logo: yes

## Overview
Kate (KDE Advanced Text Editor) is a multi-document text editor from the KDE project with syntax highlighting, project sidebar and built-in terminal. It is for developers and power users on KDE Plasma and other desktops.

## Facts
- Name: Kate
- Publisher: KDE community
- Official website: https://kate-editor.org/
- Licence: contributions licensed under LGPLv2+ or MIT per the project repository; third-party listings say LGPL v2. Source: https://github.com/KDE/kate
- Latest version: not found
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Platforms: Linux, Windows, macOS via the official site "get it" page. Source: https://kate-editor.org/

Flathub data (https://flathub.org/api/v2/appstream/org.kde.kate):
- Flatpak id: `org.kde.kate` · Developer: KDE · Licence: LGPL-2.1+
- Latest version on Flathub: 26.04.2 (released 2026-06-04)

## Logo
Bundled icon: `apps/hub/icons/kate.png`.

## Screenshots
![Editing code with Kate](https://dl.flathub.org/media/org/kde/kate.desktop/1bdc8f3611cd16919ee2eb2afdfc516a/screenshots/image-1_orig.png)
Source: https://flathub.org/api/v2/appstream/org.kde.kate

- ![Kate window](https://kate-editor.org/images/kate-window.png) Caption: main Kate window (official site).
- ![Syntax highlighting](https://kate-editor.org/images/kate-syntax-example.png) Caption: syntax highlighting example (official site).
- ![Project sidebar](https://kate-editor.org/images/sidebar.png) Caption: project sidebar (official site).
- ![Search and replace](https://kate-editor.org/images/search.png) Caption: search and replace tool (official site).

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Flatpak (recommended on kate-editor.org) | `flatpak install flathub org.kde.kate` | no |
| Arch package | `sudo pacman -S kate` | yes |

- Install konsole too for the integrated terminal.
- The Flatpak may not see host language servers and formatters.

- Source: https://kate-editor.org/get-it/
- Source: https://wiki.archlinux.org/title/Kate

## Install options (research draft; unverified. Flathub ID from model knowledge; search was rate-limited.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Flatpak | `flatpak install flathub org.kde.kate` | no (`--user`) | yes | ID unverified. Run with `flatpak run org.kde.kate`. |
| Arch repos | `sudo pacman -S kate` | yes | yes | Package name unverified. |
| Debian/Ubuntu | `sudo apt install kate` | yes | yes | Package name unverified. |
| Fedora | `sudo dnf install kate` | yes | yes | Unverified. |

## Manual install (draft)
Not needed. Use a distro package or Flatpak.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| `error: remote "flathub" not found` | Flathub not added. | `flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo` |
| Flatpak cannot save to project folder | Sandbox. | `flatpak override --user --filesystem=xdg-documents org.kde.kate` (unverified). |
| Missing KDE integration in Flatpak | Portals not active. | Install `xdg-desktop-portal` and the matching backend (unverified). |

## Sources
- https://flathub.org
- https://github.com/KDE/kate
- https://kate-editor.org
- https://kate-editor.org/
