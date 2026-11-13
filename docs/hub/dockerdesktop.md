# Docker Desktop

- Id: `dockerdesktop` · Category: Development · Weight: heavy · Licence (catalog): Proprietary
- Catalog sources: manual `https://docs.docker.com/desktop/setup/install/linux/`
- Install verified: yes · Screenshots: 0 of 3 · Logo: yes

## Overview
Docker Desktop is Docker's desktop application for Linux, macOS and Windows that bundles the Docker Engine, CLI, Compose and a graphical dashboard. It is for developers who want a managed local container environment with a GUI.

## Facts
- Name: Docker Desktop
- Publisher: Docker, Inc.
- Official website: https://www.docker.com/products/docker-desktop/ (install docs: https://docs.docker.com/desktop/setup/install/linux.md)
- Licence: Docker Subscription Service Agreement; commercial use in larger enterprises (more than 250 employees or more than $10 million annual revenue) requires a paid subscription. Source: https://docs.docker.com/subscription/desktop-license/ (search summary)
- Latest version: not found
- Typical install size: not found
- Minimum RAM: at least 4 GB of RAM (Linux). Source: https://docs.docker.com/desktop/setup/install/linux.md (search summary)
- CPU: 64-bit CPU with virtualisation support. Source: https://docs.docker.com/desktop/setup/install/linux.md (search summary)
- Disk: not found
- Linux prerequisites: Ubuntu, Debian, RHEL, Fedora on x86_64/amd64; systemd; QEMU 5.2 or later; GNOME, KDE or MATE. Source: https://docs.docker.com/desktop/setup/install/linux.md (search summary)

## Logo
Bundled icon: `apps/hub/icons/dockerdesktop.png`.

## Screenshots
Not found. No screenshot URL recorded in this pass.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Experimental Arch package from Docker (untested by Docker) | `download the Arch package from https://docs.docker.com/desktop/release-notes/, then sudo pacman -U ./docker-desktop-*.pkg.tar.zst` | yes |

- Docker has not tested or verified the Arch package.
- Needs a 64-bit CPU with virtualization; KVM is reportedly not required from version 4.35.
- GNOME tray icon needs gnome-shell-extension-appindicator.
- On Linux, Docker Engine or Podman is lighter; Docker Desktop runs a VM.

- Source: https://docs.docker.com/desktop/setup/install/linux/
- Source: https://wiki.archlinux.org/title/Docker

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Vendor .deb | download from https://docs.docker.com/desktop/setup/install/linux/ then `sudo apt install ./docker-desktop-*.deb` | yes | yes | Unverified filename. |
| Vendor .rpm | `sudo dnf install ./docker-desktop-*.rpm` | yes | yes | Unverified. |
| Arch | vendor package only (unverified) | yes | yes | Check vendor docs. |

## Manual install (draft)
Use the vendor .deb/.rpm above. Then start from the app menu.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| Desktop cannot connect to daemon | Docker Engine not running or wrong context. | `docker context use desktop-linux` (unverified). |
| KVM error | `/dev/kvm` not accessible. | Add user to kvm group (`sudo usermod -aG kvm $USER`). |

## Sources
- https://docs.docker.com/desktop/setup/install/linux.md
- https://docs.docker.com/desktop/setup/install/linux/
- https://docs.docker.com/subscription/desktop-license/
