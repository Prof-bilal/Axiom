# Emacs

- Id: `emacs` · Category: Development · Weight: light · Licence (catalog): GPL-3.0
- Catalog sources: flatpak `org.gnu.emacs`
- Install verified: yes · Screenshots: 1 of 3 · Logo: yes

## Overview
GNU Emacs is an extensible, customisable text editor with a Lisp runtime, used for programming, writing and many other tasks. It is for users who want a long-lived, highly programmable editor.

## Facts
- Name: GNU Emacs
- Publisher: GNU Project (Free Software Foundation)
- Official website: https://www.gnu.org/software/emacs/
- Licence: not confirmed in this research (the official page fetch failed; the search did not confirm GPL). Check the COPYING file in the source tarball.
- Latest version: 31.1 per a third-party news report dated August 2026 and the Snap Store listing (seen 2026-11-13). Not confirmed on gnu.org. Sources: https://ubuntuhandbook.org/index.php/2026/08/gnu-emacs-31-1-released/ and https://snapcraft.io/emacs.md
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Distribution: GNU/Linux distributions package Emacs; the GNU download page lists mirrors. Source: https://www.gnu.org/software/emacs/download.html

Flathub data (https://flathub.org/api/v2/appstream/org.gnu.emacs):
- Flatpak id: `org.gnu.emacs` · Developer: Free Software Foundation · Licence: GPL-3.0+ and GFDL-1.3+
- Latest version on Flathub: 31.1 (released 2026-08-24)

## Logo
Bundled icon: `apps/hub/icons/emacs.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/org.gnu.emacs.png (verified-200).

## Screenshots
![Editing a Lisp program, whilst viewing the manual](https://dl.flathub.org/media/org/gnu/emacs/79f1308b0e57813710dafafdc7ce9a4f/screenshots/image-1_orig.png)
Source: https://flathub.org/api/v2/appstream/org.gnu.emacs

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Arch package (GTK, stable) | `sudo pacman -S emacs` | yes |
| Terminal-only build | `sudo pacman -S emacs-nox` | yes |
| Wayland (PGTK) build | `sudo pacman -S emacs-wayland` | yes |
| Flatpak | `flatpak install flathub org.gnu.emacs` | no |

- With emacs-nox, emacs and emacs -nw behave the same.

- Source: https://wiki.archlinux.org/title/Emacs
- Source: https://archlinux.org/packages/extra/x86_64/emacs-wayland/

## Install options (research draft; partially verified. GNU's download page recommends distro repos (search). Flatpak ID from search results; Arch package name from search results.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S emacs` | yes | yes | GNU-recommended route. `emacs-nox` for terminal-only (search tutorial, unverified). |
| Debian/Ubuntu | `sudo apt install emacs` | yes | yes | Version depends on release. |
| Fedora | `sudo dnf install emacs` | yes | yes | |
| Flatpak | `flatpak install flathub org.gnu.emacs` | no (`--user`) | yes | Listed in search results; community-maintained per older coverage. |
| Source tarball | download from https://ftp.gnu.org/gnu/emacs/ and build | no (prefix `~/.local`) | yes | `./configure --prefix=$HOME/.local && make && make install` (standard GNU steps, unverified for current version). |

## Manual install (draft)
1. Get the tarball from https://ftp.gnu.org/gnu/emacs/ (unverified current version).
2. `tar -xf emacs-<ver>.tar.xz && cd emacs-<ver>`.
3. `./configure --prefix="$HOME/.local" && make -j"$(nproc)" && make install`. Needs build deps (libgtk-3, libgnutls, etc.).
4. Check: `emacs --version`.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| `configure: error: ... not found` | Build deps missing. | Install the distro's emacs build dependencies (for example `sudo apt build-dep emacs`). |
| Emacs opens in wrong font or slow with Wayland | Toolkit issue. | Start with `emacs --with-x-toolkit=gtk3` or use the default build (unverified). |
| Flatpak cannot access files | Sandbox. | `flatpak override --user --filesystem=xdg-documents org.gnu.emacs`. |

## Sources
- https://flathub.org
- https://ftp.gnu.org/gnu/emacs/
- https://snapcraft.io/emacs.md
- https://ubuntuhandbook.org/index.php/2026/08/gnu-emacs-31-1-released/
- https://www.gnu.org/software/emacs/download.html
