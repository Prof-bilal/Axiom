# GameMode

- Id: `gamemode` · Category: Games · Weight: light · Licence (catalog): BSD
- Catalog sources: pacman `gamemode`
- Install verified: yes · Screenshots: 0 of 3 · Logo: yes

## Overview
Feral GameMode is a daemon and library that lets games request temporary CPU and GPU performance optimisations on Linux. It is for Linux gamers who want a performance boost while playing.

## Facts
- Name: GameMode
- Publisher: Feral Interactive
- Official website: not confirmed in this pass; repository https://github.com/FeralInteractive/gamemode
- Licence: BSD-3-Clause (Revised), per the GitHub README licence section. Source: https://github.com/FeralInteractive/gamemode
- Latest version: 1.8.2 referenced in the README build instructions and a game directory listing (not confirmed against the releases page). Source: https://github.com/FeralInteractive/gamemode
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Linux: RPM and Deb packages, Gentoo ebuild, or source build with bootstrap.sh. Source: search summary

## Logo
Bundled icon: `apps/hub/icons/gamemode.png`.

## Screenshots
Not found. The project is a daemon with no GUI.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Arch packages (lib32 needs [multilib]) | `sudo pacman -S gamemode lib32-gamemode` | yes |
| Join the gamemode group | `sudo usermod -aG gamemode $USER` | yes |

- Without the gamemode group the daemon cannot change CPU governor or niceness.
- Steam launch option: gamemoderun %command%.

- Source: https://wiki.archlinux.org/title/GameMode
- Source: https://www.archlinux.org/packages/multilib/x86_64/lib32-gamemode

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S gamemode` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install gamemode` | yes | yes | |
| Fedora | `sudo dnf install gamemode` | yes | yes | |

## Manual install (draft)
Not needed.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| `gamemoded` not running | Daemon not started. | `systemctl --user enable --now gamemoded` (unverified unit name). |
| Game ignores gamemoderun | Launch options not set. | Use `gamemoderun %command%` in Steam launch options. |

## Sources
- https://github.com/FeralInteractive/gamemode
