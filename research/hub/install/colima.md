# Colima (colima)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Homebrew (Linuxbrew) | `brew install colima` | no | yes | Unverified on Linux. |
| Release binary | download from https://github.com/abiosoft/colima/releases | no | yes | Unverified filename. |
| Arch AUR | `yay -S colima` | no | yes | Unverified. |

## Manual install
Download the release binary, put it in `~/.local/bin`, then run `colima start`.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| `colima start` fails on Linux | Needs QEMU/lima. | Install `qemu` and related packages (unverified). |
| Low RAM VM fails | Default VM size too big. | `colima start --memory 2 --cpu 2` (unverified). |

## Sources
- https://github.com/abiosoft/colima (unverified)
