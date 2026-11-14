# Helix (helix)

Status: verified (official package-managers docs via search results).

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch extra repo | `sudo pacman -S helix` | yes | yes | Binary is `helix`, not `hx`, when installed from extra repo (per docs). |
| AUR (latest master) | `yay -S helix-git` | no | yes | Builds from git. |
| Flatpak | `flatpak install flathub com.helix_editor.Helix` | no (`--user`) | yes | Run with `flatpak run com.helix_editor.Helix`. |
| Snap | `sudo snap install --classic helix` | yes | yes | Listed in search results. |
| Fedora | `sudo dnf install helix` | yes | yes | Listed in search results. |
| AppImage | download from GitHub releases | no | yes | Filename unverified. |

## Manual install
1. Download the Linux tarball from https://github.com/helix-editor/helix/releases (unverified name).
2. Extract to `~/.local/opt/helix` and symlink `hx` into `~/.local/bin`.
3. Copy runtime dir (`runtime/`) must sit next to the binary, or set `HELIX_RUNTIME`.
4. Check: `hx --health`.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| Missing syntax highlighting or grammars | Runtime directory not found. | Set `HELIX_RUNTIME=/path/to/helix/runtime` or keep runtime beside binary (per docs, unverified exact wording). |
| `hx: command not found` with pacman install | Binary is named `helix`. | Run `helix` or alias `hx=helix`. |
| Language server missing | LSP not installed. | Run `hx --health` and install the listed LSP (per docs). |

## Sources
- https://docs.helix-editor.com/package-managers.html
- https://docs.helix-editor.com/install.html
