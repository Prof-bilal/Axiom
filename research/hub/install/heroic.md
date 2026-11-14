# Heroic Games Launcher (heroic)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Flatpak | `flatpak install flathub com.heroicgameslauncher.hgl` | no (`--user`) | yes | ID unverified. |
| AppImage | download from GitHub releases (heroic-games-launcher), `chmod +x` | no | yes | Unverified filename. |
| AUR | `yay -S heroic-games-launcher-bin` | no | yes | Unverified. |

## Manual install
Download the AppImage and run it.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| AppImage FUSE error | FUSE 2 missing. | Install `libfuse2`. |
| Epic login fails | Browser or portal. | Check default browser (unverified). |

## Sources
- https://heroicgameslauncher.com (unverified this session)
