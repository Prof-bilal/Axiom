# Portainer (portainer)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Docker container (CE) | `docker run -d -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest` | root or docker group | yes | Mounting docker.sock gives root-equivalent access. Unverified. |
| Helm (Kubernetes) | follow Portainer docs | depends | yes | Unverified. |

## Manual install
Not needed. Use the container command above.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| Port 9443 in use | Port conflict. | Change the host port. |
| Cannot connect to docker socket | Socket permissions. | Add user to docker group (see docker entry). |

## Sources
- https://docs.portainer.io (unverified)
