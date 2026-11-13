# VLC (vlc)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S vlc` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install vlc` | yes | yes | |
| Flatpak | `flatpak install flathub org.videolan.VLC` | no (`--user`) | yes | ID unverified. |
| Snap | `sudo snap install vlc` | yes | yes | Unverified. |

## Manual install
Not needed.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| No hardware decoding | VA-API driver missing. | Install `libva-utils` and GPU VA-API driver (unverified). |
| Flatpak cannot play local files | Sandbox. | `flatpak override` (unverified). |

## Sources
- https://www.videolan.org/vlc/ (unverified this session)
