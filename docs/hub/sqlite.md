# SQLite

- Id: `sqlite` · Category: Development · Weight: light · Licence (catalog): Public domain
- Catalog sources: pacman `sqlite`
- Install verified: yes · Screenshots: 0 of 3 · Logo: yes

## Overview
SQLite is an embedded, serverless SQL database engine shipped as a library and command-line tool. It is for application developers and users who need a file-based database with no server.

## Facts
- Name: SQLite
- Publisher: SQLite project (D. Richard Hipp and contributors)
- Official website: https://www.sqlite.org/ (download https://sqlite.org/download.html)
- Licence: public domain for the core software, per the official licence page. Source: https://sqlite.org/purchase/license
- Latest version: not found (search returned only old release references)
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Install: distro packages or the amalgamation source. Source: https://sqlite.org/download.html

## Logo
Bundled icon: `apps/hub/icons/sqlite.png`.

## Screenshots
Not found. SQLite is a library and CLI; no screenshots in this pass.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Arch package (core) | `sudo pacman -S sqlite` | yes |

- The package is sqlite; sqlite3 is the command it provides, not a package name.
- Optional extras: sqlite-doc, sqlite-analyzer.

- Source: https://archlinux.org/packages/core/x86_64/sqlite/

## Install options (research draft; unverified this session. Library and CLI are usually already on the system.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S sqlite` | yes | yes | CLI tool and library. |
| Debian/Ubuntu | `sudo apt install sqlite3` | yes | yes | CLI. |
| Fedora | `sudo dnf install sqlite` | yes | yes | |

## Manual install (draft)
Not needed.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| `sqlite3: command not found` | CLI package not installed. | Install the `sqlite` or `sqlite3` package above. |
| `database is locked` | Another process holds a write lock. | Close the other process; avoid long write transactions. |

## Sources
- https://sqlite.org/download.html
- https://sqlite.org/purchase/license
- https://www.sqlite.org/download.html
