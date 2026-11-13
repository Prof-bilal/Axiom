# Podman (podman)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S podman` | yes | yes | Rootless by default. |
| Debian/Ubuntu | `sudo apt install podman` | yes | yes | Unverified. |
| Fedora | `sudo dnf install podman` | yes | yes | Unverified. |

## Manual install
Not needed.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| `newuidmap: write to uid_map failed` or no subuid range | No subuid/subgid entries. | `sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 $USER` then `podman system migrate` (unverified). |
| `cannot clone: Operation not permitted` | Unprivileged user namespaces disabled. | Check distro settings for user namespaces (unverified). |
| Registry short-name errors | Unqualified image names. | Use full image name, for example `docker.io/library/alpine`. |

## Sources
- https://podman.io (unverified this session)
