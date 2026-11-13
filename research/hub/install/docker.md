# Docker Engine (docker)

Status: unverified this session. Search not run; commands from model knowledge.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S docker` | yes | yes | Then `sudo systemctl enable --now docker`. |
| Debian/Ubuntu | follow https://docs.docker.com/engine/install/ubuntu/ (apt repo) | yes | yes | Vendor repo. |
| Fedora | follow https://docs.docker.com/engine/install/fedora/ | yes | yes | |
| Convenience script | `sh -c "curl -fsSL https://get.docker.com | sh"` | yes | yes | Vendor script; not recommended for production. Unverified. |

## Manual install
Use the distro packages above. After install: `sudo usermod -aG docker $USER` (root), log out and back in.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| `permission denied while trying to connect to the Docker daemon socket` | User not in docker group. | `sudo usermod -aG docker $USER`, re-login. Note: docker group is root-equivalent. |
| `Cannot connect to the Docker daemon` | Service not running. | `sudo systemctl start docker`. |
| Overlay/storage errors | Storage driver issue. | Check `docker info`; follow vendor docs. |

## Sources
- https://docs.docker.com/engine/install/
- https://wiki.archlinux.org/title/Docker (unverified)
