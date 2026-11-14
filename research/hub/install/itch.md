# itch (itch)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| AppImage | download from https://itch.io/app, `chmod +x`, run | no | yes | Unverified filename. |
| Flatpak | `flatpak install flathub io.itch.itch` | no (`--user`) | yes | ID unverified. |
| .deb | download from itch.io/app then `sudo apt install ./itch-*.deb` | yes | yes | Unverified. |

## Manual install
Download the AppImage, `chmod +x`, run.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| AppImage FUSE error | FUSE 2 missing. | Install `libfuse2`. |

## Sources
- https://itch.io/app (unverified this session)
