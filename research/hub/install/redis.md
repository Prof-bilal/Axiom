# Redis (redis)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S redis` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install redis-server` | yes | yes | |
| Fedora | `sudo dnf install redis` | yes | yes | |
| Container | `docker run -d -p 6379:6379 --name redis redis:7` | root or docker group | yes | Unverified tag. |

## Manual install
Not needed.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| `Could not connect to Redis at 127.0.0.1:6379` | Service not running. | `sudo systemctl enable --now redis` (service name varies by distro, unverified). |
| `MISCONF Redis is configured to save RDB snapshots` | Disk or permissions. | Check free space and dir permissions. |

## Sources
- https://redis.io/docs/latest/operate/oss_and_stack/install/install-redis/ (unverified this session)
