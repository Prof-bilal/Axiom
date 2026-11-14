# GCompris (gcompris)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Flatpak | `flatpak install flathub org.gcompris.GCompris` | no (`--user`) | yes | ID unverified. |
| Arch repos | `sudo pacman -S gcompris-qt` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install gcompris-qt` | yes | yes | Unverified. |

## Manual install
Not needed.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| Audio missing | Audio backend. | Check PipeWire/PulseAudio (unverified). |
| Flatpak cannot save progress | Sandbox. | Check data dir permissions (unverified). |

## Sources
- https://gcompris.net (unverified this session)
