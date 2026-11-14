# kubectl (kubectl)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S kubectl` | yes | yes | Unverified package name. |
| Snap | `sudo snap install kubectl --classic` | yes | yes | Unverified. |
| Upstream binary | download `kubectl` from dl.k8s.io and verify checksum (see Kubernetes docs) | no | yes | Install to `~/.local/bin`. |
| Homebrew | `brew install kubernetes-cli` | no | yes | Unverified. |

## Manual install
1. `curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"` (Kubernetes docs form, unverified).
2. Verify with the matching `.sha256` file.
3. `install -m 0755 kubectl ~/.local/bin/kubectl`.
4. Check: `kubectl version --client`.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| `kubectl: command not found` | PATH. | Add `~/.local/bin` to PATH. |
| `The connection to the server localhost:8080 was refused` | No kubeconfig. | Set `KUBECONFIG` to the cluster config file. |
| Version skew warning | Client and server differ. | Install a client close to the cluster version. |

## Sources
- https://kubernetes.io/docs/tasks/tools/ (unverified this session)
