# Portainer CE

## When to use
- You want a web UI to see and manage containers on a Docker or Podman host without the command line.
- You manage several container environments and want them in one place.
- You want to check whether running containers' images are up to date against their registry.
- You want to view logs, statistics, and consoles for containers from a browser.

## How it works
- Portainer CE is a web UI for Docker and Podman (the official site also lists Kubernetes).
- The Containers list shows each container; from there you can inspect, edit, or duplicate it, view logs and statistics, open a console, or remove it.
- Attaching volumes to containers is handled in the same UI.
- An image indicator shows green when current, orange when a newer version exists in the remote registry, and grey when the status is unknown.
- Installation is a server install, then adding environments to manage.

## Not for
- Command-line-first workflows or scripting; use the docker or podman CLI.
- Editing Kubernetes clusters in depth; use k9s, Lens, or kubectl.
- Stacks, template, and user/RBAC details: the pages I reached did not cover them, so check the full docs. Not found in the sources used.

## Sources
- https://docs.portainer.io/start/install-ce
- https://docs.portainer.io/user/docker/containers
