# k9s (k9s)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S k9s` | yes | yes | Unverified. |
| Snap | `sudo snap install k9s` | yes | yes | Unverified. |
| Go install | `go install github.com/derailed/k9s@latest` | no | yes | Unverified. Requires Go. |
| Release tarball | download from https://github.com/derailed/k9s/releases | no | yes | Unverified filename. |

## Manual install
Download the tarball, extract `k9s` into `~/.local/bin`, check `k9s version`.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| `Unable to connect to the server` | Kubeconfig missing or wrong. | Set `KUBECONFIG`. |
| Terminal rendering broken | TERM setting. | Use a terminal with 256-color support. |

## Sources
- https://k9scli.io (unverified)
