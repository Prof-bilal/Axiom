# Helm

- Id: `helm` · Category: Development · Weight: light · Licence (catalog): Apache-2.0
- Catalog sources: pacman `helm`
- Install verified: yes · Screenshots: 0 of 3 · Logo: yes

## Overview
Helm is the package manager for Kubernetes that installs and manages applications as versioned charts. It is for platform and application teams who deploy Kubernetes workloads from reusable packages.

## Facts
- Name: Helm
- Publisher: Helm project (graduated CNCF project)
- Official website: https://helm.sh/
- Licence: Apache-2.0 per Homebrew and versionlog listings; the Snap listing says MPL-2.0 (conflict). Source: https://formulae.brew.sh/formula/helm
- Latest version: 4.3.1 per Snap Store and Homebrew listings, seen 2026-11-13. Source: https://snapcraft.io/helm.md
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Major release: Helm 4 announced by CNCF in November 2025. Source: https://www.cncf.io/announcements/2025/11/12/helm-marks-10-years-with-release-of-version-4/

## Logo
Bundled icon: `apps/hub/icons/helm.png`.

## Screenshots
Not found. Helm is a CLI with no screenshots in this pass.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Arch package (extra) | `sudo pacman -S helm` | yes |

- A newer major version may sit in extra-testing first.

- Source: https://archlinux.org/packages/helm

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S helm` | yes | yes | Unverified. |
| Snap | `sudo snap install helm --classic` | yes | yes | Unverified. |
| Vendor script | `sh -c "curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash"` | no (writes to /usr/local/bin, uses sudo) | yes | Unverified URL. Read script first. |
| Tarball | download from https://github.com/helm/helm/releases and place `helm` in `~/.local/bin` | no | yes | Unverified filename. |

## Manual install (draft)
1. Download `helm-vX.Y.Z-linux-amd64.tar.gz` from GitHub releases (unverified name).
2. Extract and move `linux-amd64/helm` into `~/.local/bin`.
3. Check: `helm version`.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| `Kubernetes cluster unreachable` | No kubeconfig. | Set `KUBECONFIG`. |
| Repo fetch fails | Network. | Check proxy and DNS. |

## Sources
- https://formulae.brew.sh/formula/helm
- https://helm.sh/
- https://helm.sh/docs/intro/install/
- https://snapcraft.io/helm.md
- https://www.cncf.io/announcements/2025/11/12/helm-marks-10-years-with-release-of-version-4/
