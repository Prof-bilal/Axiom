# Chromium (chromium)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S chromium` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install chromium` | yes | yes | On Ubuntu may be a snap wrapper (unverified). |
| Flatpak | `flatpak install flathub org.chromium.Chromium` | no (`--user`) | yes | Unverified ID. |

## Manual install
Not needed.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| Sandbox error as root | Running as root. | Do not run as root. |
| `The SUID sandbox helper binary` | Permissions. | Use distro package. Avoid `--no-sandbox`. |

## Sources
- https://www.chromium.org (unverified this session)
