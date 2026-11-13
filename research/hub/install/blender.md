# Blender (blender)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S blender` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install blender` | yes | yes | Version may be old. |
| Flatpak | `flatpak install flathub org.blender.Blender` | no (`--user`) | yes | ID unverified. |
| Vendor tarball | download from https://www.blender.org/download/ and extract to `~/.local/opt` | no | yes | Unverified filename. |

## Manual install
Extract tarball, run `blender` from the folder.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| Viewport black or crash | GPU driver or OpenGL version. | Update driver; check GPU requirements (unverified). |
| Low RAM render fails | Memory limit. | Lower scene size or tile settings. |

## Sources
- https://www.blender.org/download/ (unverified this session)
