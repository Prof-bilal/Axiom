# pgAdmin 4

- Id: `pgadmin` · Category: Development · Weight: medium · Licence (catalog): PostgreSQL
- Catalog sources: manual `https://www.pgadmin.org/download/`
- Install verified: yes · Screenshots: 0 of 3 · Logo: yes

## Overview
pgAdmin 4 is a web and desktop administration and development tool for PostgreSQL. It is for database administrators and developers who manage PostgreSQL servers through a graphical interface.

## Facts
- Name: pgAdmin 4
- Publisher: pgAdmin Development Team (PostgreSQL community)
- Official website: https://www.pgadmin.org/ (downloads https://www.pgadmin.org/download/)
- Licence: PostgreSQL License per the pgAdmin licence page (Snap listing also says PostgreSQL). Source: https://pgadmin.org/docs/pgadmin4/8.7/licence.html
- Latest version: 9.16 per a third-party listing (unverified on pgadmin.org)
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Linux: official APT and RPM repositories (AlmaLinux, RHEL, Rocky 8 and 9); Python package from the PostgreSQL FTP server. Source: https://www.pgadmin.org/download/pgadmin-4-apt/ and https://www.pgadmin.org/download/pgadmin-4-rpm

## Logo
Bundled icon: `apps/hub/icons/pgadmin.png`.

## Screenshots
Not found. No screenshot URL recorded in this pass.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Official APT repo (Debian/Ubuntu) | `follow https://www.pgadmin.org/download/pgadmin-4-apt/` | yes |
| Official RPM repo (Fedora/RHEL) | `follow https://www.pgadmin.org/download/pgadmin-4-rpm` | yes |
| Arch AUR (community, from a guide) | `yay -S pgadmin4-py` | no |

- Arch has no official package.
- The Flathub id org.pgadmin.pgadmin4 was not confirmed; the catalog's Flatpak source may be wrong.

- Source: https://www.pgadmin.org/download/pgadmin-4-apt/
- Source: https://www.baeldung.com/linux/pgadmin-4-desktop-installation

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S pgadmin4` | yes | yes | Unverified name. |
| Debian/Ubuntu | follow pgAdmin apt repo docs, then `sudo apt install pgadmin4-desktop` | yes | yes | Unverified. |
| pip (web mode) | `pip install pgadmin4` in a venv | no | yes | Unverified. |
| Container | `docker run -p 8080:80 -e PGADMIN_DEFAULT_EMAIL=<set> -e PGADMIN_DEFAULT_PASSWORD=<set> -d dpage/pgadmin4` | root or docker group | yes | Set credentials yourself. Unverified. |

## Manual install (draft)
Not needed.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| Blank page in desktop mode | Qt/WebEngine issue. | Use web mode or container (unverified). |
| Cannot connect to server | Wrong host or auth. | Check pg_hba.conf and credentials. |

## Sources
- https://pgadmin.org/docs/pgadmin4/8.7/licence.html
- https://www.pgadmin.org/download/
- https://www.pgadmin.org/download/pgadmin-4-apt/
- https://www.pgadmin.org/download/pgadmin-4-rpm
