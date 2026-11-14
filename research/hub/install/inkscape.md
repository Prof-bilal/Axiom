# Inkscape (inkscape)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S inkscape` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install inkscape` | yes | yes | |
| Flatpak | `flatpak install flathub org.inkscape.Inkscape` | no (`--user`) | yes | ID unverified. |

## Manual install
Not needed.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| Missing extensions | Python extension deps. | Install Python packages used by extensions (unverified). |
| Flatpak cannot open files | Sandbox. | `flatpak override` (unverified). |

## Sources
- https://inkscape.org/release/ (unverified this session)
