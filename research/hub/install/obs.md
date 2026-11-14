# OBS Studio (obs)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S obs-studio` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install obs-studio` | yes | yes | |
| Flatpak | `flatpak install flathub com.obsproject.Studio` | no (`--user`) | yes | ID unverified. |

## Manual install
Not needed.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| Screen capture black on Wayland | Portal missing. | Install `xdg-desktop-portal` with matching backend (unverified). |
| Flatpak cannot use v4l2 | Device access. | Grant device permission via `flatpak override --device=all` (unverified). |

## Sources
- https://obsproject.com/download (unverified this session)
