# GIMP (gimp)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S gimp` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install gimp` | yes | yes | |
| Fedora | `sudo dnf install gimp` | yes | yes | |
| Flatpak | `flatpak install flathub org.gimp.GIMP` | no (`--user`) | yes | ID unverified. |

## Manual install
Not needed.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| Missing plugins | Plugin package not installed. | Install `gimp-plugin-*` packages (unverified). |
| Flatpak cannot open files outside home | Sandbox. | `flatpak override` (unverified). |

## Sources
- https://www.gimp.org/downloads/ (unverified this session)
