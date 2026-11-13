# Helix

- Id: `helix` · Category: Development · Weight: light · Licence (catalog): MPL-2.0
- Catalog sources: pacman `helix`
- Install verified: yes · Screenshots: 0 of 3 · Logo: yes

## Overview
Helix is a modal terminal text editor written in Rust with built-in language server support and tree-sitter syntax handling. It is for developers who want a batteries-included modal editor with no configuration plugin system.

## Facts
- Name: Helix
- Publisher: Helix editor project (community)
- Official website: https://helix-editor.com/
- Licence: MPL-2.0 (most sources; one SourceForge listing says MPL 1.0, which conflicts). Source: https://github.com/helix-editor/helix
- Latest version: not found
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Install: Snap (sudo snap install helix --classic), cargo install --path helix-term, Homebrew on macOS. Source: https://snapcraft.io/helix and https://docs.helix-editor.com/install.html

## Logo
Bundled icon: `apps/hub/icons/helix.png`.
Official logo: https://raw.githubusercontent.com/helix-editor/helix/master/logo.svg (verified-200).

## Screenshots
Not found. The official site returned only a logo image.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Arch package (extra) | `sudo pacman -S helix` | yes |

- On Arch the command is helix, not hx.
- Check the setup with: helix --health

- Source: https://docs.helix-editor.com/package-managers.html

## Install options (research draft; verified (official package-managers docs via search results).)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch extra repo | `sudo pacman -S helix` | yes | yes | Binary is `helix`, not `hx`, when installed from extra repo (per docs). |
| AUR (latest master) | `yay -S helix-git` | no | yes | Builds from git. |
| Flatpak | `flatpak install flathub com.helix_editor.Helix` | no (`--user`) | yes | Run with `flatpak run com.helix_editor.Helix`. |
| Snap | `sudo snap install --classic helix` | yes | yes | Listed in search results. |
| Fedora | `sudo dnf install helix` | yes | yes | Listed in search results. |
| AppImage | download from GitHub releases | no | yes | Filename unverified. |

## Manual install (draft)
1. Download the Linux tarball from https://github.com/helix-editor/helix/releases (unverified name).
2. Extract to `~/.local/opt/helix` and symlink `hx` into `~/.local/bin`.
3. Copy runtime dir (`runtime/`) must sit next to the binary, or set `HELIX_RUNTIME`.
4. Check: `hx --health`.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| Missing syntax highlighting or grammars | Runtime directory not found. | Set `HELIX_RUNTIME=/path/to/helix/runtime` or keep runtime beside binary (per docs, unverified exact wording). |
| `hx: command not found` with pacman install | Binary is named `helix`. | Run `helix` or alias `hx=helix`. |
| Language server missing | LSP not installed. | Run `hx --health` and install the listed LSP (per docs). |

## Sources
- https://docs.helix-editor.com/install.html
- https://docs.helix-editor.com/package-managers.html
- https://github.com/helix-editor/helix
- https://helix-editor.com/
- https://snapcraft.io/helix
