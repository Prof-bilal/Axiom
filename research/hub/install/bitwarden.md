# Bitwarden Desktop (bitwarden)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Flatpak | `flatpak install flathub com.bitwarden.desktop` | no (`--user`) | yes | ID unverified. |
| AppImage | download from https://bitwarden.com/download/ (Linux) and run | no | yes | Unverified. |
| Snap | `sudo snap install bitwarden` | yes | yes | Unverified. |
| Arch | `sudo pacman -S bitwarden` | yes | yes | Unverified. |

## Manual install
Use the AppImage from bitwarden.com; check the signature if offered.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| Keyring unlock fails | No secret service. | Install gnome-keyring or KWallet (unverified). |
| AppImage FUSE error | FUSE 2 missing. | Install `libfuse2`. |

## Sources
- https://bitwarden.com/download/ (unverified this session)
