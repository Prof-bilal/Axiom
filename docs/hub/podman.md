# Podman

- Id: `podman` · Category: Development · Weight: light · Licence (catalog): Apache-2.0
- Catalog sources: pacman `podman`
- Install verified: yes · Screenshots: 0 of 3 · Logo: yes

## Overview
Podman is a daemonless container engine that runs OCI containers, with a Docker-compatible CLI, rootless operation and pods. It is for developers and administrators who want container workflows without a long-running root daemon.

## Facts
- Name: Podman
- Publisher: Podman project (open source; see podman.io)
- Official website: https://podman.io/ (docs: https://docs.podman.io)
- Licence: Apache-2.0. Source: https://en.wikipedia.org/wiki/Podman (search summary)
- Latest version: not confirmed. Third-party packages show 5.6.2 and 5.7.0; upstream release not checked.
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Install: distro packages (e.g., `sudo apt install podman` on Debian 11+/Ubuntu 20.10+; `sudo dnf install podman` on Fedora). Source: search summary of distro guides (third-party)

## Logo
Bundled icon: `apps/hub/icons/podman.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/io.podman_desktop.PodmanDesktop.png (verified-200).

## Screenshots
Not found. No screenshot URL recorded in this pass.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Arch package | `sudo pacman -S podman` | yes |
| Rootless helpers | `sudo pacman -S passt fuse-overlayfs crun` | yes |

- Rootless use needs subordinate UID/GID ranges in /etc/subuid and /etc/subgid.
- Check with: podman info (expects cgroups v2 and crun).

- Source: https://podman.io/docs/installation

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S podman` | yes | yes | Rootless by default. |
| Debian/Ubuntu | `sudo apt install podman` | yes | yes | Unverified. |
| Fedora | `sudo dnf install podman` | yes | yes | Unverified. |

## Manual install (draft)
Not needed.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| `newuidmap: write to uid_map failed` or no subuid range | No subuid/subgid entries. | `sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 $USER` then `podman system migrate` (unverified). |
| `cannot clone: Operation not permitted` | Unprivileged user namespaces disabled. | Check distro settings for user namespaces (unverified). |
| Registry short-name errors | Unqualified image names. | Use full image name, for example `docker.io/library/alpine`. |

## Sources
- https://docs.podman.io
- https://en.wikipedia.org/wiki/Podman
- https://podman.io
- https://podman.io/
