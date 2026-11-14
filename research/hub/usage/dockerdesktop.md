# Docker Desktop

## When to use
- You want a one-click GUI to build, run, and manage containers on a Mac, Windows, or Linux desktop.
- You are on Windows and want Linux containers through WSL 2 with a managed setup.
- You want a bundled Docker Engine, CLI, Compose, and Kubernetes in one install.
- You want to pull images from Docker Hub and share your work through repositories from the desktop.

## How it works
- It is a one-click desktop application that bundles the Docker Engine and CLI.
- A graphical interface lists and manages containers, applications, and images on the machine.
- Volume mounting shares code and data between the host and containers, with file change notifications.
- Port mappings and file system concerns are handled by default.
- Bundled components also include Compose, Docker Build, Scout, and Kubernetes.

## Not for
- Users who want a daemonless or rootless engine; Podman is built for that.
- Lightweight setups where you want to run Docker on a server without a desktop app; use the Docker Engine directly, or Colima on macOS.
- Licensing questions: the official overview page does not mention licensing, so check the Docker terms separately. Not found there.

## Sources
- https://docs.docker.com/desktop/
