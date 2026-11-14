# Docker Desktop for Linux (dockerdesktop)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Vendor .deb | download from https://docs.docker.com/desktop/setup/install/linux/ then `sudo apt install ./docker-desktop-*.deb` | yes | yes | Unverified filename. |
| Vendor .rpm | `sudo dnf install ./docker-desktop-*.rpm` | yes | yes | Unverified. |
| Arch | vendor package only (unverified) | yes | yes | Check vendor docs. |

## Manual install
Use the vendor .deb/.rpm above. Then start from the app menu.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| Desktop cannot connect to daemon | Docker Engine not running or wrong context. | `docker context use desktop-linux` (unverified). |
| KVM error | `/dev/kvm` not accessible. | Add user to kvm group (`sudo usermod -aG kvm $USER`). |

## Sources
- https://docs.docker.com/desktop/setup/install/linux/ (unverified)
