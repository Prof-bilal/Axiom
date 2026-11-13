# Ollama

- Id: `ollama` · Category: Development · Weight: heavy · Licence (catalog): MIT
- Catalog sources: manual `https://ollama.com/download`
- Install verified: yes · Screenshots: 0 of 3 · Logo: yes

## Overview
Ollama runs open-weight large language models locally through a command-line tool and a local API. It is for developers and users who want to run models on their own hardware.

## Facts
- Name: Ollama
- Publisher: Ollama (ollama.com)
- Official website: https://ollama.com/ (install script https://ollama.com/install.sh)
- Licence: MIT. Source: https://github.com/ollama/ollama (search summary; GitHub licence listing) and https://snapcraft.io/ollama.md
- Latest version: not found
- Typical install size: not found
- Minimum RAM: 8 GB for CPU-only per a 2026 community guide (unofficial). Source: https://specpicks.com/reviews/ollama-install-guide-2026
- CPU: x86_64 or ARM64 per a 2026 guide (unofficial). Source: https://specpicks.com/reviews/ollama-install-guide-2026
- Disk: 10 GB+ free storage per the same guide (unofficial)
- Linux: Ubuntu 20.04 or later and Fedora 33 or later per search summaries (not vendor-confirmed). Source: https://itsfoss.com/ollama/

## Logo
Bundled icon: `apps/hub/icons/ollama.png`.

## Screenshots
Not found. No screenshot URL recorded in this pass.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Official install script (installs to /usr/local/bin and a systemd service) | `curl -fsSL https://ollama.com/install.sh | sh` | yes |
| Manual tarball | `curl -fsSL https://ollama.com/download/ollama-linux-amd64.tar.zst | sudo tar x -C /usr` | yes |

- Logs: journalctl -e -u ollama.
- Before upgrading a manual install, remove old libraries: sudo rm -rf /usr/lib/ollama.
- Arch packages ollama, ollama-cuda and ollama-rocm were only seen in a secondary source.

- Source: https://docs.ollama.com/linux

## Install options (research draft; unverified this session (search not run). Commands from model knowledge.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Install script | `sh -c "curl -fsSL https://ollama.com/install.sh | sh"` | yes (writes to /usr/local and creates a service) | yes | Unverified. Script uses sudo internally for system install. |
| Tarball | download `ollama-linux-amd64.tgz` from https://github.com/ollama/ollama/releases and extract to `~/.local` | no | yes | Unverified filename. |
| Arch repos | `sudo pacman -S ollama` (also `ollama-cuda`, `ollama-rocm`) | yes | yes | Package names unverified. |
| Docker | `docker run -d -v ollama:/root/.ollama -p 11434:11434 ollama/ollama` | root or docker group | yes | Unverified. |

## Manual install (draft)
1. Extract the tarball to `~/.local` (unverified path layout).
2. Start: `ollama serve`.
3. Check: `curl http://127.0.0.1:11434/api/version` (unverified endpoint).

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| Runs on CPU only | GPU driver/runtime missing. | Install CUDA or ROCm runtime (unverified per distro). |
| `address already in use` | Another ollama instance. | Stop the service: `systemctl stop ollama` (unverified). |
| Out of memory loading model | Not enough RAM/VRAM. | Use a smaller model. |

## Sources
- https://github.com/ollama/ollama
- https://itsfoss.com/ollama/
- https://ollama.com/
- https://ollama.com/download
- https://snapcraft.io/ollama.md
- https://specpicks.com/reviews/ollama-install-guide-2026
