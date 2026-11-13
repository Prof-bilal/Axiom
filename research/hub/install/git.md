# Git (git)

Status: unverified this session. Git is usually preinstalled; check first.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S git` | yes | yes | |
| Debian/Ubuntu | `sudo apt install git` | yes | yes | |
| Fedora | `sudo dnf install git` | yes | yes | |

## Manual install
Not needed.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| `git: command not found` | Not installed. | Install with the package manager above. |
| `Author identity unknown` | No user config. | `git config --global user.name "<name>"` and `user.email` (user supplies values). |

## Sources
- https://git-scm.com/downloads (unverified this session)
