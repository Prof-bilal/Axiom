# kubectl

- Id: `kubectl` · Category: Development · Weight: light · Licence (catalog): Apache-2.0
- Catalog sources: pacman `kubectl`
- Install verified: yes · Screenshots: 0 of 3 · Logo: yes

## Overview
kubectl is the command-line tool for running commands against Kubernetes clusters. It is for developers and operators who manage Kubernetes workloads from a terminal.

## Facts
- Name: kubectl
- Publisher: Kubernetes project (CNCF)
- Official website: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux
- Licence: not confirmed in this pass (Kubernetes is generally Apache-2.0; check https://github.com/kubernetes/kubernetes LICENSE)
- Latest version: not found
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Install: curl binary to /usr/local/bin, distro apt/dnf repositories, or snap. Version skew: within one minor version of the cluster control plane. Source: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux

## Logo
Bundled icon: `apps/hub/icons/kubectl.png`.
Official logo: https://raw.githubusercontent.com/kubernetes/kubernetes/master/logo/logo.png (verified-200).

## Screenshots
Not found. kubectl is a CLI with no UI screenshots in the official install docs.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Arch package (extra) | `sudo pacman -S kubectl` | yes |
| Official binary (x86-64) | `curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && install -m 0755 kubectl ~/.local/bin/kubectl` | no |

- Verify the binary with the checksum file from dl.k8s.io.
- The AUR kubectl-bin is redundant on Arch; extra already has kubectl.
- Older guides use storage.googleapis.com URLs; prefer dl.k8s.io.

- Source: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux
- Source: https://archlinux.org/packages/extra/x86_64/kubectl/

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S kubectl` | yes | yes | Unverified package name. |
| Snap | `sudo snap install kubectl --classic` | yes | yes | Unverified. |
| Upstream binary | download `kubectl` from dl.k8s.io and verify checksum (see Kubernetes docs) | no | yes | Install to `~/.local/bin`. |
| Homebrew | `brew install kubernetes-cli` | no | yes | Unverified. |

## Manual install (draft)
1. `curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"` (Kubernetes docs form, unverified).
2. Verify with the matching `.sha256` file.
3. `install -m 0755 kubectl ~/.local/bin/kubectl`.
4. Check: `kubectl version --client`.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| `kubectl: command not found` | PATH. | Add `~/.local/bin` to PATH. |
| `The connection to the server localhost:8080 was refused` | No kubeconfig. | Set `KUBECONFIG` to the cluster config file. |
| Version skew warning | Client and server differ. | Install a client close to the cluster version. |

## Sources
- https://kubernetes.io/docs/tasks/tools/
- https://kubernetes.io/docs/tasks/tools/install-kubectl-linux
