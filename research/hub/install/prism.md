# Prism Launcher (prism)

Status: unverified this session. Prism is a Minecraft launcher (PrismLauncher project).

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S prismlauncher` | yes | yes | Unverified package name. |
| Flatpak | `flatpak install flathub org.prismlauncher.PrismLauncher` | no (`--user`) | yes | ID unverified. |
| AppImage | download from https://prismlauncher.org/download/linux/ | no | yes | Unverified. |

## Manual install
Use the AppImage from prismlauncher.org.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| Java not found | Java runtime missing. | Install a JDK matching the Minecraft version (unverified). |
| AppImage FUSE error | FUSE 2 missing. | Install `libfuse2`. |

## Sources
- https://prismlauncher.org/download/linux/ (unverified this session)
