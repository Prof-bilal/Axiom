# MariaDB (mariadb)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S mariadb` then `sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql` | yes | yes | Unverified exact command. |
| Debian/Ubuntu | `sudo apt install mariadb-server` | yes | yes | |
| Fedora | `sudo dnf install mariadb-server` | yes | yes | |
| Container | `docker run -e MARIADB_ROOT_PASSWORD=<set-your-own> -p 3306:3306 -d mariadb:11` | root or docker group | yes | Unverified tag. |

## Manual install
Not needed.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| `Can't connect via socket` | Service not started. | `sudo systemctl enable --now mariadb`. |
| `Access denied for user 'root'` | Auth plugin. | Use `sudo mariadb` as root user via unix_socket (unverified). |

## Sources
- https://mariadb.org/download/ (unverified this session)
