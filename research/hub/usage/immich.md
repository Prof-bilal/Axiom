# Immich

## When to use
- You want a self-hosted private photo and video library instead of a cloud service.
- You want mobile apps to back up photos automatically to your own server.
- You need shared albums, public links and multi-user libraries on your own hardware.
- You want search by objects, faces and metadata (ML features run on your server).

## How it works
- Self-hosted app (AGPL-3.0) installed with Docker Compose from the official release files.
- Upload, view, duplicate detection and facial recognition run on the server.
- Mobile apps back up to the server and offer offline viewing.
- Store `UPLOAD_LOCATION` on a disk with enough free space; keep `DB_DATA_LOCATION` off network shares.

## Not for
- Being your only copy of your photos; the project itself recommends a 3-2-1 backup plan.
- Hosts without Docker Compose or a disk with room for the full library.

## Sources
- https://github.com/immich-app/immich
- https://immich.app/
- https://docs.immich.app/install/docker-compose
