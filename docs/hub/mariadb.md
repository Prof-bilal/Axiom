# MariaDB

- Id: `mariadb` · Category: Development · Weight: medium · Licence (catalog): GPL-2.0
- Catalog sources: pacman `mariadb`
- Install verified: yes · Screenshots: 0 of 3 · Logo: yes

## Overview
MariaDB Server is a community fork of MySQL that provides a relational database for web and application workloads. It is for developers and administrators who want a MySQL-compatible open-source server.

## Facts
- Name: MariaDB Server
- Publisher: MariaDB Foundation / MariaDB plc
- Official website: https://mariadb.org/download/ (also https://mariadb.com/)
- Licence: GPL (listed as GPL-2.0 per a listing). Source: https://mariadb.com/kb/en/download/ (search summary)
- Latest version: sources disagree (11.8.2 in a winget listing; 11.4 in an older guide). Check mariadb.org/download. Source: https://wingetgui.com/apps/MariaDB-Server
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Install: distro packages (mariadb-server) or tarballs from mariadb.org. Source: https://mariadb.org/?p=15482 (search summary)

## Logo
Bundled icon: `apps/hub/icons/mariadb.png`.
Official logo: https://mariadb.org/wp-content/uploads/2019/10/mariadb_logo.svg (verified-200).

## Screenshots
Not found. No screenshot URL recorded in this pass.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Arch package | `sudo pacman -S mariadb` | yes |
| Create the data directory (Arch does not do it) | `sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql` | yes |
| Start now and at boot | `sudo systemctl enable --now mariadb` | yes |
| Set a root password and harden | `sudo mysql_secure_installation` | yes |

- MariaDB is Arch's default MySQL implementation (also mariadb-lts).
- Config path differs between guides (/etc/my.cnf.d/server.cnf or /etc/my.cnf); check the installed files.

- Source: https://wiki.archlinux.org/title/MariaDB
- Source: https://www.linuxcapable.com/how-to-install-mariadb-on-arch-linux

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S mariadb` then `sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql` | yes | yes | Unverified exact command. |
| Debian/Ubuntu | `sudo apt install mariadb-server` | yes | yes | |
| Fedora | `sudo dnf install mariadb-server` | yes | yes | |
| Container | `docker run -e MARIADB_ROOT_PASSWORD=<set-your-own> -p 3306:3306 -d mariadb:11` | root or docker group | yes | Unverified tag. |

## Manual install (draft)
Not needed.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| `Can't connect via socket` | Service not started. | `sudo systemctl enable --now mariadb`. |
| `Access denied for user 'root'` | Auth plugin. | Use `sudo mariadb` as root user via unix_socket (unverified). |

## Sources
- https://mariadb.com/kb/en/download/
- https://mariadb.org/?p=15482
- https://mariadb.org/download/
