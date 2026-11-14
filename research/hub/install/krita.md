# Krita (krita)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S krita` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install krita` | yes | yes | |
| Flatpak | `flatpak install flathub org.kde.krita` | no (`--user`) | yes | ID unverified. |
| AppImage | download from https://krita.org/download | no | yes | Unverified. |

## Manual install
Use AppImage from krita.org if needed.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| Canvas blank or slow | GPU OpenGL issue. | Update GPU driver; set OpenGL to "Auto" in settings (unverified). |
| AppImage FUSE error | FUSE 2 missing. | Install `libfuse2`. |

## Sources
- https://krita.org/download (unverified this session)
