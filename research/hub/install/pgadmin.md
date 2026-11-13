# pgAdmin 4 (pgadmin)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S pgadmin4` | yes | yes | Unverified name. |
| Debian/Ubuntu | follow pgAdmin apt repo docs, then `sudo apt install pgadmin4-desktop` | yes | yes | Unverified. |
| pip (web mode) | `pip install pgadmin4` in a venv | no | yes | Unverified. |
| Container | `docker run -p 8080:80 -e PGADMIN_DEFAULT_EMAIL=<set> -e PGADMIN_DEFAULT_PASSWORD=<set> -d dpage/pgadmin4` | root or docker group | yes | Set credentials yourself. Unverified. |

## Manual install
Not needed.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| Blank page in desktop mode | Qt/WebEngine issue. | Use web mode or container (unverified). |
| Cannot connect to server | Wrong host or auth. | Check pg_hba.conf and credentials. |

## Sources
- https://www.pgadmin.org/download/ (unverified this session)
