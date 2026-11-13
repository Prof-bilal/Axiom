# GNU Emacs (emacs)

Status: partially verified. GNU's download page recommends distro repos (search). Flatpak ID from search results; Arch package name from search results.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S emacs` | yes | yes | GNU-recommended route. `emacs-nox` for terminal-only (search tutorial, unverified). |
| Debian/Ubuntu | `sudo apt install emacs` | yes | yes | Version depends on release. |
| Fedora | `sudo dnf install emacs` | yes | yes | |
| Flatpak | `flatpak install flathub org.gnu.emacs` | no (`--user`) | yes | Listed in search results; community-maintained per older coverage. |
| Source tarball | download from https://ftp.gnu.org/gnu/emacs/ and build | no (prefix `~/.local`) | yes | `./configure --prefix=$HOME/.local && make && make install` (standard GNU steps, unverified for current version). |

## Manual install
1. Get the tarball from https://ftp.gnu.org/gnu/emacs/ (unverified current version).
2. `tar -xf emacs-<ver>.tar.xz && cd emacs-<ver>`.
3. `./configure --prefix="$HOME/.local" && make -j"$(nproc)" && make install`. Needs build deps (libgtk-3, libgnutls, etc.).
4. Check: `emacs --version`.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| `configure: error: ... not found` | Build deps missing. | Install the distro's emacs build dependencies (for example `sudo apt build-dep emacs`). |
| Emacs opens in wrong font or slow with Wayland | Toolkit issue. | Start with `emacs --with-x-toolkit=gtk3` or use the default build (unverified). |
| Flatpak cannot access files | Sandbox. | `flatpak override --user --filesystem=xdg-documents org.gnu.emacs`. |

## Sources
- https://www.gnu.org/software/emacs/download.html
- https://ftp.gnu.org/gnu/emacs/
- https://flathub.org (org.gnu.emacs)
