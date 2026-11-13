# Portainer CE

- Id: `portainer` · Category: Development · Weight: medium · Licence (catalog): zlib
- Catalog sources: manual `https://www.portainer.io`
- Install verified: yes · Screenshots: 0 of 3 · Logo: yes

## Overview
Portainer is a web-based management UI for Docker, Swarm and Kubernetes environments. Portainer CE is the free edition for managing containers and stacks, and it is for operators who want a GUI over container hosts.

## Facts
- Name: Portainer (Community Edition, CE)
- Publisher: Portainer.io
- Official website: https://www.portainer.io/
- Licence: zlib (repository, per GitHub). Portainer BE is a commercial edition. Source: https://github.com/portainer/portainer (search summary)
- Latest version: not found
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Install: Docker container, ports 8000 and 9443 in the common docker run example; Docker Compose supported. Source: secondary guides (not portainer.io docs)

## Logo
Bundled icon: `apps/hub/icons/portainer.png`.

## Screenshots
Not found. No screenshot URL recorded in this pass.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Create the data volume | `docker volume create portainer_data` | docker group |
| Run Portainer CE (web UI on https://localhost:9443) | `docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:lts` | docker group |

- Needs Docker running first.
- Guides disagree on port 8000 (edge agent) and the image tag (latest, lts, or pinned); check docs.portainer.io.
- Mounting the Docker socket gives Portainer root-equivalent control of the host.

- Source: https://oneuptime.com/blog/post/2026-03-20-portainer-docker-run-install/view
- Source: https://computingforgeeks.com/install-portainer-ubuntu-2604/

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Docker container (CE) | `docker run -d -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest` | root or docker group | yes | Mounting docker.sock gives root-equivalent access. Unverified. |
| Helm (Kubernetes) | follow Portainer docs | depends | yes | Unverified. |

## Manual install (draft)
Not needed. Use the container command above.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| Port 9443 in use | Port conflict. | Change the host port. |
| Cannot connect to docker socket | Socket permissions. | Add user to docker group (see docker entry). |

## Sources
- https://docs.portainer.io
- https://github.com/portainer/portainer
