# Lutris (lutris)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S lutris` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install lutris` | yes | yes | PPA may be needed on older releases (unverified). |
| Flatpak | `flatpak install flathub net.lutris.Lutris` | no (`--user`) | yes | ID unverified. |

## Manual install
Not needed.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| Wine runner not found | Runner not installed. | Install wine via Lutris runners or distro (unverified). |
| 32-bit libs missing | multilib. | Install lib32 GPU libs. |

## Sources
- https://lutris.net/downloads (unverified this session)
