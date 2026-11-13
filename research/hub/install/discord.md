# Discord (discord)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S discord` | yes | yes | Unverified. |
| Debian/Ubuntu .deb | download from https://discord.com/download (Linux .deb) then `sudo apt install ./discord-*.deb` | yes | yes | Unverified filename. |
| Flatpak | `flatpak install flathub com.discordapp.Discord` | no (`--user`) | yes | ID unverified. |
| Snap | `sudo snap install discord` | yes | yes | Unverified. |

## Manual install
Use the tarball from discord.com if no package manager route.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| Blank screen or update loop | Corrupt cache. | Remove `~/.config/discord` cache dirs (unverified). |
| Screen share fails on Wayland | Portal missing. | Install `xdg-desktop-portal` and backend (unverified). |

## Sources
- https://discord.com/download (unverified this session)
