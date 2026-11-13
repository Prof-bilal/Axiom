# Helm (helm)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S helm` | yes | yes | Unverified. |
| Snap | `sudo snap install helm --classic` | yes | yes | Unverified. |
| Vendor script | `sh -c "curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash"` | no (writes to /usr/local/bin, uses sudo) | yes | Unverified URL. Read script first. |
| Tarball | download from https://github.com/helm/helm/releases and place `helm` in `~/.local/bin` | no | yes | Unverified filename. |

## Manual install
1. Download `helm-vX.Y.Z-linux-amd64.tar.gz` from GitHub releases (unverified name).
2. Extract and move `linux-amd64/helm` into `~/.local/bin`.
3. Check: `helm version`.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| `Kubernetes cluster unreachable` | No kubeconfig. | Set `KUBECONFIG`. |
| Repo fetch fails | Network. | Check proxy and DNS. |

## Sources
- https://helm.sh/docs/intro/install/ (unverified this session)
