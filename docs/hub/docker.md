# Docker

- Id: `docker` · Category: Development · Weight: medium · Licence (catalog): Apache-2.0
- Catalog sources: pacman `docker`
- Install verified: yes · Screenshots: 0 of 3 · Logo: yes

## Overview
Docker Engine is the open-source container runtime and CLI for building, running and distributing containers on Linux. It is for developers and operators who need a standard container workflow on Linux servers and workstations.

## Facts
- Name: Docker Engine
- Publisher: Docker, Inc.
- Official website: https://www.docker.com/ (install docs: https://docs.docker.com/engine/install/ubuntu.md)
- Licence: Docker Engine and Moby open-source projects are unchanged under open-source terms per Docker statements. Source: https://docs.docker.com/subscription/desktop-license/ (search summary)
- Latest version: not found
- Typical install size: not found
- Minimum RAM: not found for Engine
- CPU: not found for Engine
- Disk: not found for Engine
- Supported Linux: 64-bit supported Ubuntu releases per official Ubuntu install page; derivatives not officially supported. Source: https://docs.docker.com/engine/install/ubuntu.md (search summary)

## Logo
Bundled icon: `apps/hub/icons/docker.png`.
Official logo: https://www.docker.com/app/uploads/2026/02/Docker_Logo_660x400.png (verified-200).

## Screenshots
Not found. No screenshot URL recorded in this pass.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Arch package | `sudo pacman -S docker` | yes |
| Start the daemon | `sudo systemctl enable --now docker` | yes |
| Run without sudo (log out and back in after) | `sudo usermod -aG docker "$USER"` | yes |

- Members of the docker group are root-equivalent.
- Docker Compose is a separate package: sudo pacman -S docker-compose.

- Source: https://itsfoss.com/install-docker-arch-linux/
- Source: https://linuxcapable.com/how-to-install-docker-on-arch-linux/

## Install options (research draft; unverified this session. Search not run; commands from model knowledge.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S docker` | yes | yes | Then `sudo systemctl enable --now docker`. |
| Debian/Ubuntu | follow https://docs.docker.com/engine/install/ubuntu/ (apt repo) | yes | yes | Vendor repo. |
| Fedora | follow https://docs.docker.com/engine/install/fedora/ | yes | yes | |
| Convenience script | `sh -c "curl -fsSL https://get.docker.com | sh"` | yes | yes | Vendor script; not recommended for production. Unverified. |

## Manual install (draft)
Use the distro packages above. After install: `sudo usermod -aG docker $USER` (root), log out and back in.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| `permission denied while trying to connect to the Docker daemon socket` | User not in docker group. | `sudo usermod -aG docker $USER`, re-login. Note: docker group is root-equivalent. |
| `Cannot connect to the Docker daemon` | Service not running. | `sudo systemctl start docker`. |
| Overlay/storage errors | Storage driver issue. | Check `docker info`; follow vendor docs. |

## Sources
- https://docs.docker.com/engine/install/
- https://docs.docker.com/engine/install/ubuntu.md
- https://docs.docker.com/subscription/desktop-license/
- https://wiki.archlinux.org/title/Docker
