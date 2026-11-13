# Lens

- Id: `lens` · Category: Development · Weight: heavy · Licence (catalog): MIT
- Catalog sources: manual `https://k8slens.dev`
- Install verified: yes · Screenshots: 0 of 3 · Logo: yes

## Overview
Lens is a desktop Kubernetes IDE for viewing and managing clusters, with a GUI for workloads, logs and terminals. It is for developers and operators who prefer a desktop tool over the command line for cluster work.

## Facts
- Name: Lens (Lens IDE)
- Publisher: Mirantis (Lens IDE); OpenLens and Freelens are open-source forks
- Official website: https://lenshq.io/ (download page); k8slens.dev
- Licence: the Lens IDE product is under a proprietary EULA; source code is MIT per search summary. Personal licence eligibility depends on company revenue (up to $10M per search summary). Source: https://lenshq.io/download/index.md (not fully fetched)
- Latest version: not found
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Linux: AppImage download (may need fuse or libfuse2); Snap listing exists. Source: https://snapcraft.io/kontena-lens (search summary)

## Logo
Bundled icon: `apps/hub/icons/lens.png`.

## Screenshots
Not found in this pass.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Official APT or RPM repository, AppImage or snap (x86_64) | `follow https://docs.k8slens.dev/getting-started/install-lens` | repo: yes |
| Arch AUR (community) | `yay -S lens-bin` | no |

- The repo-installed command is lens-desktop.
- GLIBC errors were reported on Ubuntu 20.04 for both .deb and AppImage.

- Source: https://docs.k8slens.dev/getting-started/install-lens
- Source: https://aur.archlinux.org/packages/lens-bin

## Install options (research draft; unverified this session. Lens is a Kubernetes IDE; check current project status before listing.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| AppImage | download from https://k8slens.dev or GitHub releases, `chmod +x`, run | no | yes | Unverified filename. |
| Flatpak | unverified | no | yes | Check Flathub. |
| AUR | `yay -S lens-bin` | no | yes | Unverified. |

## Manual install (draft)
1. Download the AppImage (unverified URL).
2. `chmod +x Lens-*.AppImage` and run it.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| AppImage FUSE error | FUSE 2 missing. | Install `libfuse2` (or distro equivalent). |
| Cannot reach cluster | Kubeconfig not loaded. | Add kubeconfig via the app or `KUBECONFIG`. |

## Sources
- https://dev.co/devops/open-source/freelens
- https://k8slens.dev
- https://lenshq.io/download/index.md
- https://snapcraft.io/kontena-lens
