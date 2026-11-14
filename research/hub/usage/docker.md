# Docker

## When to use
- You need to package an application and its dependencies into a portable image.
- You want to run a service (database, web server, tool) in an isolated container without installing it on the host.
- You are sharing a build with teammates or a server through a registry such as Docker Hub.
- You need multi-container local setups defined with Docker Compose.

## How it works
- An image is a read-only template built from a Dockerfile; each instruction adds a layer.
- A container is a running instance of an image, relatively isolated from other containers and the host.
- The `dockerd` daemon does the work; the `docker` CLI sends it commands through its REST API.
- Typical flow: build an image, run a container (pulled automatically if missing), push to a registry, pull elsewhere.
- Docker Compose defines and runs several related containers together.

## Not for
- Managing many containers across clusters; use Kubernetes tools such as kubectl or Helm.
- Running a desktop GUI-first experience with a VM on macOS or Windows; Docker Desktop or Colima fit that better.
- Rootless, daemonless operation; Podman is designed for that.

## Sources
- https://docs.docker.com/get-started/docker-overview/
