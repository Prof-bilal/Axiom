# PostgreSQL (postgresql)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S postgresql` | yes | yes | Needs initdb: `sudo -iu postgres initdb -D /var/lib/postgres/data`. Unverified. |
| Debian/Ubuntu | `sudo apt install postgresql` | yes | yes | Cluster starts automatically. |
| Fedora | `sudo dnf install postgresql-server` | yes | yes | Needs `postgresql-setup --initdb`. Unverified. |
| Container | `docker run -e POSTGRES_PASSWORD=<set-your-own> -p 5432:5432 -d postgres:17` | root or docker group | yes | Unverified tag. |

## Manual install
Not needed.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| `data directory ... has no database` / not initialized | initdb not run (Arch/Fedora). | Run initdb as postgres user (see above). |
| `peer authentication failed` | OS user mismatch. | Use `sudo -u postgres psql` or set auth method (unverified). |
| `could not bind IPv4 socket` | Port in use. | Stop other instance. |

## Sources
- https://www.postgresql.org/download/linux/ (unverified this session)
