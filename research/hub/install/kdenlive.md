# Kdenlive (kdenlive)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S kdenlive` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install kdenlive` | yes | yes | |
| Flatpak | `flatpak install flathub org.kde.kdenlive` | no (`--user`) | yes | ID unverified. |
| AppImage | download from https://kdenlive.org/download/ | no | yes | Unverified. |

## Manual install
Not needed.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| Missing MLT codecs | Codec package. | Install the MLT/FFmpeg codec packages (unverified). |
| Flatpak cannot read media | Sandbox. | `flatpak override` (unverified). |

## Sources
- https://kdenlive.org/download/ (unverified this session)
