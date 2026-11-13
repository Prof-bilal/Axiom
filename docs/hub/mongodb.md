# MongoDB Community

- Id: `mongodb` · Category: Development · Weight: heavy · Licence (catalog): SSPL
- Catalog sources: manual `https://wiki.archlinux.org/title/MongoDB`
- Install verified: yes · Screenshots: 0 of 3 · Logo: yes

## Overview
MongoDB is a document-oriented NoSQL database; the Community Server is for self-hosted deployments on Linux and other platforms. It is for developers who need flexible schemas and document storage.

## Facts
- Name: MongoDB Community Server
- Publisher: MongoDB, Inc.
- Official website: https://www.mongodb.com/ (install docs https://mongodb.com/docs/v7.0/administration/install-on-linux)
- Licence: Server Side Public License (SSPL) v1 per the repository README. Source: https://cdn.jsdelivr.net/gh/mongodb/mongo@master/README.md
- Latest version: not found
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Linux: packages for Red Hat, Debian, Ubuntu, SUSE and Amazon Linux; supported OS versions per release on the platform matrix. Source: https://mongodb.com/docs/v7.0/administration/install-on-linux (search summary)

## Logo
Bundled icon: `apps/hub/icons/mongodb.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/com.mongodb.Compass.png (verified-200).

## Screenshots
Not found. No screenshot URL recorded in this pass.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| AUR prebuilt binary (community) | `yay -S mongodb-bin` | no |
| MongoDB shell | `yay -S mongosh-bin` | no |

- Arch has no official MongoDB package; the AUR mongodb source build takes hours.
- With mongodb-bin, the Arch Wiki says ExecStart must be wrapped with numactl --interleave=all.
- PGP key import errors are a known install problem (see the AUR page).

- Source: https://wiki.archlinux.org/title/MongoDB
- Source: https://aur.archlinux.org/packages/mongodb-bin

## Install options (research draft; unverified this session. MongoDB Community is not in most distro repos; use vendor repo or container.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Vendor apt/dnf repo | follow https://www.mongodb.com/docs/manual/administration/install-on-linux/ then `sudo apt install mongodb-org` | yes | yes | Unverified repo lines. |
| AUR | `yay -S mongodb-bin` | no | yes | Community; unverified. |
| Container | `docker run -d -p 27017:27017 --name mongo mongo:7` | root or docker group | yes | Unverified tag. |

## Manual install (draft)
Not recommended without vendor repo.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| `Illegal instruction` on start | CPU lacks AVX. | Use a build that matches your CPU; MongoDB 5+ needs AVX (per docs, unverified). |
| `Data directory /var/lib/mongodb not found` | Missing dir. | Create it and set ownership to mongodb user. |

## Sources
- https://cdn.jsdelivr.net/gh/mongodb/mongo@master/README.md
- https://mongodb.com/docs/v7.0/administration/install-on-linux
- https://www.mongodb.com/docs/manual/administration/install-on-linux/
