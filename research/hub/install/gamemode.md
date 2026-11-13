# GameMode (gamemode)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S gamemode` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install gamemode` | yes | yes | |
| Fedora | `sudo dnf install gamemode` | yes | yes | |

## Manual install
Not needed.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| `gamemoded` not running | Daemon not started. | `systemctl --user enable --now gamemoded` (unverified unit name). |
| Game ignores gamemoderun | Launch options not set. | Use `gamemoderun %command%` in Steam launch options. |

## Sources
- https://github.com/FeralInteractive/gamemode (unverified this session)
