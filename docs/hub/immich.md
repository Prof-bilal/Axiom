# Immich

- Id: `immich` · Category: Productivity · Weight: heavy · Licence (catalog): AGPL-3.0
- Catalog sources: manual `https://immich.app`
- Install verified: no · Screenshots: 0 of 3 · Logo: yes

## Overview
Self-hosted photo and video backup.

## Facts
Not researched yet.

## Logo
Bundled icon: `apps/hub/icons/immich.png`.

## Screenshots
Not found.

## Install (verified against a source)
Not verified yet. Use the draft below only after checking it.

## Install options (research draft; Verified: the Docker Compose commands are from the official Immich documentation. Whether sudo or root is needed is not stated, so it is marked "not stated".)
| Method | Command | Needs root | Verified? |
|---|---|---|---|
| Docker Compose: make folder | `mkdir ./immich-app && cd ./immich-app` | No | Verified: https://docs.immich.app/install/docker-compose |
| Docker Compose: download files | `wget -O docker-compose.yml https://github.com/immich-app/immich/releases/latest/download/docker-compose.yml` and `wget -O .env https://github.com/immich-app/immich/releases/latest/download/example.env` | No | Verified: https://docs.immich.app/install/docker-compose |
| Docker Compose: start | `docker compose up -d` | Not stated (needs Docker daemon access) | Verified: https://docs.immich.app/install/docker-compose |

Before starting, edit `.env`: set `UPLOAD_LOCATION` to a directory with free space, change `DB_PASSWORD` (letters and digits only), and uncomment `TZ` with a timezone such as `Etc/UTC`.

## Possible errors and fixes (draft)
- **Error:** `unknown shorthand flag: 'd' in -d` or `open <.env path>: permission denied`.
  - Cause: an old or wrong Docker version (the page cites `docker.io` on Ubuntu 22.04.3 LTS).
  - Fix: follow the full Docker Engine install procedure, including "Uninstall old versions" and the apt or rpm repository install.
  - Source: https://docs.immich.app/install/docker-compose
- **Error:** `'name' does not match any of the regexes: '^x-'`.
  - Cause: the legacy `docker-compose` command was used.
  - Fix: use `docker compose` instead.
  - Source: https://docs.immich.app/install/docker-compose
- **Error:** `can't set healthcheck.start_interval as feature require Docker Engine v25 or later`.
  - Cause: Docker Engine is older than v25.
  - Fix: comment out the `start_interval` line in the `database` section of `docker-compose.yml`, or upgrade Docker Engine.
  - Source: https://docs.immich.app/install/docker-compose

## Sources
