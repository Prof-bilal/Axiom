# Colima

## When to use
- You are on macOS or Linux and want Docker containers without installing Docker Desktop.
- You want a lightweight, command-line container runtime that you start and stop yourself.
- You want containerd (via nerdctl) rather than Docker.
- You need a local single-node Kubernetes cluster started with one command.

## How it works
- Colima runs container runtimes inside a managed VM on macOS and Linux.
- Runtimes include Docker (the default), containerd via nerdctl, Kubernetes (a local k3s cluster), and Incus for system containers and VMs.
- You install it with Homebrew, then start it with `colima start`, optionally choosing `--runtime` or `--kubernetes`.
- You run workloads with the usual tools (`docker`, `nerdctl`, `kubectl`, or `incus`).
- CPU, memory, and disk can be sized, and separate isolated profiles are supported.

## Not for
- Windows, where its documented platforms are macOS and Linux; use Docker Desktop or Podman there.
- A polished GUI for managing containers; pair it with a tool such as Lens or Portainer.
- Production multi-node clusters; use a real Kubernetes distribution.

## Sources
- https://colima.run/
