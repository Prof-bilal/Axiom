# Lens (lens)

Status: unverified this session. Lens is a Kubernetes IDE; check current project status before listing.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| AppImage | download from https://k8slens.dev or GitHub releases, `chmod +x`, run | no | yes | Unverified filename. |
| Flatpak | unverified | no | yes | Check Flathub. |
| AUR | `yay -S lens-bin` | no | yes | Unverified. |

## Manual install
1. Download the AppImage (unverified URL).
2. `chmod +x Lens-*.AppImage` and run it.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| AppImage FUSE error | FUSE 2 missing. | Install `libfuse2` (or distro equivalent). |
| Cannot reach cluster | Kubeconfig not loaded. | Add kubeconfig via the app or `KUBECONFIG`. |

## Sources
- https://k8slens.dev (unverified this session)
