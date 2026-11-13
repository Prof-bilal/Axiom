# RetroArch (retroarch)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S retroarch` | yes | yes | Unverified. Add `libretro-*` cores separately. |
| Debian/Ubuntu | `sudo apt install retroarch` | yes | yes | Cores via `libretro-*` packages. |
| Flatpak | `flatpak install flathub org.libretro.RetroArch` | no (`--user`) | yes | ID unverified. |

## Manual install
Not needed.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| No cores available | Core not installed. | Install cores via Online Updater or distro packages. |
| Audio latency | Driver config. | Switch audio driver in settings (pipewire/pulse, unverified). |

## Sources
- https://www.retroarch.com/index.php?page=linux (unverified this session)
