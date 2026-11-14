# SQLite (sqlite)

Status: unverified this session. Library and CLI are usually already on the system.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S sqlite` | yes | yes | CLI tool and library. |
| Debian/Ubuntu | `sudo apt install sqlite3` | yes | yes | CLI. |
| Fedora | `sudo dnf install sqlite` | yes | yes | |

## Manual install
Not needed.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| `sqlite3: command not found` | CLI package not installed. | Install the `sqlite` or `sqlite3` package above. |
| `database is locked` | Another process holds a write lock. | Close the other process; avoid long write transactions. |

## Sources
- https://www.sqlite.org/download.html (unverified this session)
