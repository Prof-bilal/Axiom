# Obsidian (obsidian)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Flatpak | `flatpak install flathub md.obsidian.Obsidian` | no (`--user`) | yes | ID unverified. |
| AppImage (vendor) | download from https://obsidian.md/download, `chmod +x`, run | no | yes | Unverified filename. |
| AUR | `yay -S obsidian` | no | yes | Unverified. |

## Manual install
1. Download the AppImage from https://obsidian.md/download (unverified).
2. `chmod +x Obsidian-*.AppImage`, run.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| AppImage FUSE error | FUSE 2 missing. | Install `libfuse2` (or distro equivalent). |
| Flatpak cannot see vault | Sandbox. | `flatpak override --user --filesystem=<vault path>` (unverified). |

## Sources
- https://obsidian.md/download (unverified this session)
