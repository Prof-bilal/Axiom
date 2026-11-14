# KeePassXC (keepassxc)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S keepassxc` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install keepassxc` | yes | yes | |
| Fedora | `sudo dnf install keepassxc` | yes | yes | |
| Flatpak | `flatpak install flathub org.keepassxc.KeePassXC` | no (`--user`) | yes | ID unverified. |
| AppImage | download from https://keepassxc.org/download/ | no | yes | Verify signature per project docs. |

## Manual install
Not needed.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| Browser integration not working | Browser extension or native messaging path. | Follow KeePassXC browser integration docs (unverified). |
| Secret Service not available | No keyring. | Install and run a secret service (unverified). |

## Sources
- https://keepassxc.org/download/ (unverified this session)
