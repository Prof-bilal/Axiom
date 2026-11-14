# Jan (jan)

Status: unverified. Search not run; commands from model knowledge.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| AppImage | download from https://jan.ai or GitHub releases, `chmod +x`, run | no | yes | Unverified filename. |
| .deb / .rpm | `sudo apt install ./jan-*.deb` or `sudo dnf install ./jan-*.rpm` | yes | yes | From GitHub releases; unverified. |
| Flatpak | unverified | no | yes | Check Flathub. |

## Manual install
1. Download the AppImage from https://jan.ai (unverified link).
2. `chmod +x ~/Downloads/Jan-*.AppImage` and run it.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| AppImage will not start, FUSE error | FUSE 2 missing. | Install `libfuse2` (or distro equivalent). |
| Sandbox error at start | Chromium sandbox. | Fix user namespaces; avoid `--no-sandbox` except as temporary test. |

## Sources
- https://jan.ai (unverified)
- https://github.com/janhq/jan (unverified)
