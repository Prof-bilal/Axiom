# MongoDB (mongodb)

Status: unverified this session. MongoDB Community is not in most distro repos; use vendor repo or container.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Vendor apt/dnf repo | follow https://www.mongodb.com/docs/manual/administration/install-on-linux/ then `sudo apt install mongodb-org` | yes | yes | Unverified repo lines. |
| AUR | `yay -S mongodb-bin` | no | yes | Community; unverified. |
| Container | `docker run -d -p 27017:27017 --name mongo mongo:7` | root or docker group | yes | Unverified tag. |

## Manual install
Not recommended without vendor repo.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| `Illegal instruction` on start | CPU lacks AVX. | Use a build that matches your CPU; MongoDB 5+ needs AVX (per docs, unverified). |
| `Data directory /var/lib/mongodb not found` | Missing dir. | Create it and set ownership to mongodb user. |

## Sources
- https://www.mongodb.com/docs/manual/administration/install-on-linux/ (unverified)
