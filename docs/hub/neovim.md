# Neovim

- Id: `neovim` · Category: Development · Weight: light · Licence (catalog): Apache-2.0
- Catalog sources: pacman `neovim`
- Install verified: yes · Screenshots: 4 of 3 · Logo: yes

## Overview
Neovim is a refactored fork of Vim focused on extensibility, with a built-in Lua API and an async architecture. It is for terminal-centric developers who want a customisable modal editor.

## Facts
- Name: Neovim
- Publisher: Neovim project (community)
- Official website: https://neovim.io/
- Licence: Apache-2.0 OR Vim for recent contributions; older contributions under the Vim licence. Source: https://snapcraft.io/nvim and https://github.com/neovim/neovim
- Latest version: 0.12 listed as current stable on https://neovim.io/ (seen 2026-11-13). Snap Store shows v0.12.5 as latest/stable (seen 2026-11-13). The two sources differ in precision.
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Linux: prebuilt x86_64 and arm64 archives and AppImage on GitHub Releases. Source: https://github.com/neovim/neovim-releases/releases

## Logo
Bundled icon: `apps/hub/icons/neovim.png`.
Official logo: https://raw.githubusercontent.com/neovim/neovim.github.io/master/static/logos/neovim-logo-300x87.png (verified-200).

## Screenshots
- ![Statuscolumn](https://neovim.io/images/showcase/statuscolumn0.12.png) Caption: statuscolumn (official screenshots page).
- ![Customizable tabline](https://neovim.io/images/showcase/tabline-custom.png) Caption: customizable tabline (official screenshots page).
- ![Telescope help tags](https://neovim.io/images/showcase/telescope_helptags.png) Caption: TUI with telescope, courtesy of @sunjon (official screenshots page).
- ![Neovide animated cursor](https://neovim.io/images/showcase/neovide-animatedCursor.gif) Caption: neovide animated cursor (official screenshots page).

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Arch package | `sudo pacman -S neovim` | yes |
| AUR development build | `yay -S neovim-git` | no |

- No Flathub listing was confirmed for io.neovim.nvim.

- Source: https://wiki.archlinux.org/title/Nvim
- Source: https://www.neovim.io/doc/install

## Install options (research draft; partially verified. Official releases page and Arch package name come from model knowledge; search was rate-limited. Confirm before shipping.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch official repos | `sudo pacman -S neovim` | yes | yes | Package may lag upstream. Common on Arch. |
| Debian/Ubuntu repos | `sudo apt install neovim` | yes | yes | Often old. |
| Fedora repos | `sudo dnf install neovim` | yes | yes | |
| AppImage (upstream) | download `nvim-linux-x86_64.appimage` from https://github.com/neovim/neovim/releases | no | yes | Needs FUSE 2 on newer distros (see errors). Filename unverified. |
| Tarball (upstream) | download `nvim-linux-x86_64.tar.gz` from releases | no | yes | Extract to `~/.local/opt`. Filename unverified. |
| Flatpak | not an official method (unverified; check Flathub) | no | yes | Not confirmed. |

## Manual install (draft)
1. Download `nvim-linux-x86_64.tar.gz` from https://github.com/neovim/neovim/releases (unverified name).
2. `mkdir -p ~/.local/opt && tar -xzf ~/Downloads/nvim-linux-x86_64.tar.gz -C ~/.local/opt`.
3. `ln -s ~/.local/opt/nvim-linux-x86_64/bin/nvim ~/.local/bin/nvim`.
4. Check: `nvim --version`.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| AppImage: `dlopen(): error loading libfuse.so.2` | FUSE 2 missing. | Arch: `sudo pacman -S fuse2`. Debian/Ubuntu: `sudo apt install libfuse2t64` or `libfuse2`. Or use the tarball instead. |
| `nvim: command not found` after tarball install | PATH. | Add `~/.local/bin` to PATH. |
| Plugins fail with `git not found` | git missing. | Install git. |
| Old version from repo lacks features | Distro lag. | Use tarball or AppImage. |

## Sources
- https://archlinux.org/packages/extra/x86_64/neovim/
- https://github.com/neovim/neovim
- https://github.com/neovim/neovim-releases/releases
- https://github.com/neovim/neovim/releases
- https://neovim.io/
- https://neovim.io/screenshots/
- https://snapcraft.io/nvim
