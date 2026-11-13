# Git

- Id: `git` · Category: Development · Weight: light · Licence (catalog): GPL-2.0
- Catalog sources: pacman `git`
- Install verified: yes · Screenshots: 0 of 3 · Logo: yes

## Overview
Git is the distributed version control system used to track changes in source code and other files. It is for developers and teams who need local and remote version history.

## Facts
- Name: Git
- Publisher: Git project (maintained by Junio Hamano and contributors)
- Official website: https://git-scm.com/
- Licence: GPL-2.0 expected; not confirmed in this pass (check the COPYING file in the source tree)
- Latest version: 2.55.0 per the git-scm.com install pages (Windows page dated 2026-08-20; seen 2026-11-13). The main downloads page showed an older cached version. Source: https://git-scm.com/install/windows.html
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Linux: install via the distribution package manager; source tarballs on kernel.org and GitHub. Source: https://git-scm.com/install/linux.html (search summary)

## Logo
Bundled icon: `apps/hub/icons/git.png`.

## Screenshots
Not found. Git is a command-line tool with no screenshots on the official site.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Arch package (official git-scm.com instruction) | `sudo pacman -S git` | yes |

- Check with git --version. The Snap git-scm is not the official package.

- Source: https://git-scm.com/download/linux
- Source: https://git-scm.com/install/linux

## Install options (research draft; unverified this session. Git is usually preinstalled; check first.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S git` | yes | yes | |
| Debian/Ubuntu | `sudo apt install git` | yes | yes | |
| Fedora | `sudo dnf install git` | yes | yes | |

## Manual install (draft)
Not needed.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| `git: command not found` | Not installed. | Install with the package manager above. |
| `Author identity unknown` | No user config. | `git config --global user.name "<name>"` and `user.email` (user supplies values). |

## Sources
- https://git-scm.com/downloads
- https://git-scm.com/install/linux.html
- https://git-scm.com/install/windows.html
- https://www.kernel.org/pub/software/scm/git
