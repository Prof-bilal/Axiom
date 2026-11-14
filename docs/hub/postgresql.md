# PostgreSQL

- Id: `postgresql` · Category: Development · Weight: medium · Licence (catalog): PostgreSQL
- Catalog sources: pacman `postgresql`
- Install verified: yes · Screenshots: 0 of 3 · Logo: yes

## Overview
PostgreSQL is an open-source object-relational database server known for standards compliance and extensibility. It is for developers and operators who need a production-grade relational database.

## Facts
- Name: PostgreSQL
- Publisher: PostgreSQL Global Development Group
- Official website: https://www.postgresql.org/ (downloads https://www.postgresql.org/download/linux)
- Licence: PostgreSQL License. The search did not confirm this from the official page; verify at https://www.postgresql.org/about/licence/
- Latest version: not confirmed. A site banner lists 18.3, 17.9, 16.13, 15.17 and 14.22 released February 26, 2026; an EDB table lists 18.6. Source: https://www.postgresql.org/download/linux
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Install: official apt and yum repositories per distribution. Source: https://www.postgresql.org/download/linux/ubuntu/

## Logo
Bundled icon: `apps/hub/icons/postgresql.png`.

## Screenshots
Not found. No screenshot URL recorded in this pass.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Arch package | `sudo pacman -S postgresql` | yes |
| Create the database cluster (as the postgres user) | `sudo -iu postgres initdb --locale $LANG -E UTF8 -D /var/lib/postgres/data` | yes |
| Start now and at boot | `sudo systemctl enable --now postgresql` | yes |

- The package creates the postgres system user.
- initdb fails with a permission error if run as your own user; run it as postgres.

- Source: https://wiki.archlinux.org/title/PostgreSQL_(Italiano)
- Source: https://linuxcapable.com/how-to-install-postgresql-on-arch-linux/

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S postgresql` | yes | yes | Needs initdb: `sudo -iu postgres initdb -D /var/lib/postgres/data`. Unverified. |
| Debian/Ubuntu | `sudo apt install postgresql` | yes | yes | Cluster starts automatically. |
| Fedora | `sudo dnf install postgresql-server` | yes | yes | Needs `postgresql-setup --initdb`. Unverified. |
| Container | `docker run -e POSTGRES_PASSWORD=<set-your-own> -p 5432:5432 -d postgres:17` | root or docker group | yes | Unverified tag. |

## Manual install (draft)
Not needed.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| `data directory ... has no database` / not initialized | initdb not run (Arch/Fedora). | Run initdb as postgres user (see above). |
| `peer authentication failed` | OS user mismatch. | Use `sudo -u postgres psql` or set auth method (unverified). |
| `could not bind IPv4 socket` | Port in use. | Stop other instance. |

## Sources
- https://www.postgresql.org/download/linux
- https://www.postgresql.org/download/linux/
- https://www.postgresql.org/download/linux/ubuntu/
