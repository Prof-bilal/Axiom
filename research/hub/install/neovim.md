# Neovim (neovim)

Status: partially verified. Official releases page and Arch package name come from model knowledge; search was rate-limited. Confirm before shipping.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch official repos | `sudo pacman -S neovim` | yes | yes | Package may lag upstream. Common on Arch. |
| Debian/Ubuntu repos | `sudo apt install neovim` | yes | yes | Often old. |
| Fedora repos | `sudo dnf install neovim` | yes | yes | |
| AppImage (upstream) | download `nvim-linux-x86_64.appimage` from https://github.com/neovim/neovim/releases | no | yes | Needs FUSE 2 on newer distros (see errors). Filename unverified. |
| Tarball (upstream) | download `nvim-linux-x86_64.tar.gz` from releases | no | yes | Extract to `~/.local/opt`. Filename unverified. |
| Flatpak | not an official method (unverified; check Flathub) | no | yes | Not confirmed. |

## Manual install
1. Download `nvim-linux-x86_64.tar.gz` from https://github.com/neovim/neovim/releases (unverified name).
2. `mkdir -p ~/.local/opt && tar -xzf ~/Downloads/nvim-linux-x86_64.tar.gz -C ~/.local/opt`.
3. `ln -s ~/.local/opt/nvim-linux-x86_64/bin/nvim ~/.local/bin/nvim`.
4. Check: `nvim --version`.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| AppImage: `dlopen(): error loading libfuse.so.2` | FUSE 2 missing. | Arch: `sudo pacman -S fuse2`. Debian/Ubuntu: `sudo apt install libfuse2t64` or `libfuse2`. Or use the tarball instead. |
| `nvim: command not found` after tarball install | PATH. | Add `~/.local/bin` to PATH. |
| Plugins fail with `git not found` | git missing. | Install git. |
| Old version from repo lacks features | Distro lag. | Use tarball or AppImage. |

## Sources
- https://github.com/neovim/neovim/releases
- https://archlinux.org/packages/extra/x86_64/neovim/ (unverified URL)
