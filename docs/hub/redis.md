# Valkey (Redis-compatible)

- Id: `redis` · Category: Development · Weight: light · Licence (catalog): BSD-3-Clause
- Catalog sources: pacman `valkey`
- Install verified: yes · Screenshots: 0 of 3 · Logo: yes

## Overview
Redis is an in-memory data store used as a cache, message broker and database. It is for developers and operators who need low-latency key-value and data-structure storage.

## Facts
- Name: Redis (Open Source 8.x)
- Publisher: Redis Ltd.
- Official website: https://redis.io/ (licence page https://redis.io/community/licenses/)
- Licence: Redis 8.0 and later offered under RSALv2, SSPLv1 or AGPLv3 (tri-licence per Redis licence page summary). Redis 7.2 and earlier BSD-3-Clause. Source: https://redis.io/community/licenses/ (search summary)
- Latest version: 8.10.2 per the Snap Store listing, seen 2026-11-13. Source: https://snapcraft.io/redis.md
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Install: distro packages, Snap, or source build. Source: https://upstash.com/blog/how-to-self-host-redis-in-2026.md (third-party)

## Logo
Bundled icon: `apps/hub/icons/redis.png`.

## Screenshots
Not found. No screenshot URL recorded in this pass.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Arch package (Valkey replaced Redis in April 2025) | `sudo pacman -S valkey` | yes |
| Start now and at boot | `sudo systemctl enable --now valkey` | yes |

- Arch moved the redis package to the AUR and no longer updates it; Valkey is the Redis-compatible replacement.
- Scripts that call redis-cli or redis-server by name may need a compatibility package.

- Source: https://archlinux.org/news/valkey-to-replace-redis-in-the-extra-repository
- Source: https://valkey.io/topics/installation

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S redis` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install redis-server` | yes | yes | |
| Fedora | `sudo dnf install redis` | yes | yes | |
| Container | `docker run -d -p 6379:6379 --name redis redis:7` | root or docker group | yes | Unverified tag. |

## Manual install (draft)
Not needed.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| `Could not connect to Redis at 127.0.0.1:6379` | Service not running. | `sudo systemctl enable --now redis` (service name varies by distro, unverified). |
| `MISCONF Redis is configured to save RDB snapshots` | Disk or permissions. | Check free space and dir permissions. |

## Sources
- https://alternativeto.net/news/2025/5/redis-goes-open-source-again-with-the-launch-of-redis-8-under-the-agplv3-license
- https://redis.io/community/licenses/
- https://redis.io/docs/latest/operate/oss_and_stack/install/install-redis/
- https://snapcraft.io/redis.md
