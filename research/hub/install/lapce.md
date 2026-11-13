# Lapce (lapce)

Status: unverified. Search was rate-limited; Flathub ID and Arch name are from model knowledge.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Flatpak | `flatpak install flathub dev.lapce.lapce` | no (`--user`) | yes | ID unverified; check flathub.org. |
| Arch repos | `sudo pacman -S lapce` | yes | yes | Package name unverified. Confirm with `pacman -Ss lapce`. |
| Upstream tarball/AppImage | download from https://github.com/lapce/lapce/releases | no | yes | Filenames unverified. |

## Manual install
1. Download the Linux release from https://github.com/lapce/lapce/releases (unverified name).
2. Extract to `~/.local/opt/lapce` and link `lapce` into `~/.local/bin`.
3. Check: `lapce --version` (unverified flag).

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| No GPU acceleration, blank window | Vulkan/OpenGL driver missing. | Install Mesa Vulkan drivers for your GPU (unverified for Lapce specifically). |
| `lapce: command not found` | PATH. | Add `~/.local/bin` to PATH. |

## Sources
- https://github.com/lapce/lapce
- https://flathub.org (dev.lapce.lapce, unverified)
