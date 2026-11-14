# Podman

## When to use
- You want to run containers without a background daemon running as root.
- You want rootless containers for a developer workstation or shared machine.
- You want the same container commands as Docker for pulling, running, and inspecting images.
- You need containers grouped into pods, which the docs describe as a Podman feature.

## How it works
- Podman is a command-line utility built on the libpod library for creating and maintaining containers.
- Typical flow: `podman pull` an image by its full name, `podman run -d -p` to start it with port forwarding, then `podman ps`, `podman logs`, and `podman inspect` to check it.
- `podman stop` halts a container and `podman rm` removes it; `-l` refers to the latest container.
- Rootless mode is supported; a rootless container gets no IP address, so port forwarding is the way to reach it.
- Checkpointing can save a container's process state to disk for later restore or migration.

## Not for
- Kubernetes cluster management; use kubectl, Helm, or k9s.
- A GUI-first desktop experience; Docker Desktop or Podman Desktop-style tools fit that better.
- Workflows that depend on a specific Docker daemon feature; check compatibility first. Not found on the official page.

## Sources
- https://podman.io/docs
