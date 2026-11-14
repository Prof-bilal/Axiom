# Colima

- Id: `colima` · Category: Development · Weight: medium · Licence (catalog): MIT
- Catalog sources: manual `https://github.com/abiosoft/colima`
- Install verified: yes · Screenshots: 0 of 3 · Logo: yes

## Overview
Colima runs container runtimes (Docker by default, also containerd and Incus) on macOS and Linux with minimal setup. It is for developers who want a command-line container environment without a desktop application.

## Facts
- Name: Colima
- Publisher: abiosoft (open-source GitHub project)
- Official website: https://colima.run/ (per search summary)
- Licence: MIT. Source: https://pkg.go.dev/github.com/abiosoft/colima@v0.5.6 (search summary)
- Latest version: not found
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Note: an older mirror README describes the project as early-stage with possible breaking changes. Source: https://github.com/abiosoft/colima (search summary)

## Logo
Bundled icon: `apps/hub/icons/colima.png`.
Official logo: https://raw.githubusercontent.com/abiosoft/colima/main/colima.png (verified-200).

## Screenshots
Not found. No screenshot URL recorded in this pass.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Homebrew (64-bit Linux bottles) | `brew install colima` | no |
| Release binary | `download from https://github.com/abiosoft/colima/releases` | no |

- Colima runs a VM; on Linux, Podman or Docker Engine on the host is lighter.
- Official docs: https://colima.run/docs (not opened).

- Source: https://formulae.brew.sh/formula/colima
- Source: https://github.com/abiosoft/colima

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Homebrew (Linuxbrew) | `brew install colima` | no | yes | Unverified on Linux. |
| Release binary | download from https://github.com/abiosoft/colima/releases | no | yes | Unverified filename. |
| Arch AUR | `yay -S colima` | no | yes | Unverified. |

## Manual install (draft)
Download the release binary, put it in `~/.local/bin`, then run `colima start`.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| `colima start` fails on Linux | Needs QEMU/lima. | Install `qemu` and related packages (unverified). |
| Low RAM VM fails | Default VM size too big. | `colima start --memory 2 --cpu 2` (unverified). |

## Sources
- https://github.com/abiosoft/colima
- https://pkg.go.dev/github.com/abiosoft/colima@v0.5.6
