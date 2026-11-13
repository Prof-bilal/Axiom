# k9s

- Id: `k9s` · Category: Development · Weight: light · Licence (catalog): Apache-2.0
- Catalog sources: pacman `k9s`
- Install verified: yes · Screenshots: 0 of 3 · Logo: yes

## Overview
K9s is a terminal UI for navigating and managing Kubernetes clusters, with live resource views and keyboard-driven actions. It is for operators who prefer working in the terminal over the Kubernetes dashboard.

## Facts
- Name: K9s
- Publisher: derailed (open-source project)
- Official website: https://k9scli.io/ (not fetched); repository https://github.com/derailed/k9s
- Licence: Apache-2.0 (README badge; Snap listing). Source: https://cdn.jsdelivr.net/gh/derailed/k9s@master/README.md
- Latest version: not found
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Install: Homebrew, Snap, pacman, zypper, dnf, .deb from GitHub releases. Source: https://cdn.jsdelivr.net/gh/derailed/k9s@master/README.md
- Caveat: a third-party blog mentions a paid "K9s Plus" tier, which could not be confirmed from an official source. Source: https://hoop.dev/blog/understanding-the-new-k9s-licensing-model

## Logo
Bundled icon: `apps/hub/icons/k9s.png`.
Official logo: https://raw.githubusercontent.com/derailed/k9s/master/assets/imhotep_logo.png (verified-200).

## Screenshots
Not found in this pass.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Arch package (extra) | `sudo pacman -S k9s` | yes |


- Source: https://archlinux.org/packages/extra/x86_64/k9s/

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S k9s` | yes | yes | Unverified. |
| Snap | `sudo snap install k9s` | yes | yes | Unverified. |
| Go install | `go install github.com/derailed/k9s@latest` | no | yes | Unverified. Requires Go. |
| Release tarball | download from https://github.com/derailed/k9s/releases | no | yes | Unverified filename. |

## Manual install (draft)
Download the tarball, extract `k9s` into `~/.local/bin`, check `k9s version`.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| `Unable to connect to the server` | Kubeconfig missing or wrong. | Set `KUBECONFIG`. |
| Terminal rendering broken | TERM setting. | Use a terminal with 256-color support. |

## Sources
- https://cdn.jsdelivr.net/gh/derailed/k9s@master/README.md
- https://hoop.dev/blog/understanding-the-new-k9s-licensing-model
- https://k9scli.io
- https://snapcraft.io/k9s.md
