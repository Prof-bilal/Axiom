# Ollama (ollama)

Status: unverified this session (search not run). Commands from model knowledge.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Install script | `sh -c "curl -fsSL https://ollama.com/install.sh | sh"` | yes (writes to /usr/local and creates a service) | yes | Unverified. Script uses sudo internally for system install. |
| Tarball | download `ollama-linux-amd64.tgz` from https://github.com/ollama/ollama/releases and extract to `~/.local` | no | yes | Unverified filename. |
| Arch repos | `sudo pacman -S ollama` (also `ollama-cuda`, `ollama-rocm`) | yes | yes | Package names unverified. |
| Docker | `docker run -d -v ollama:/root/.ollama -p 11434:11434 ollama/ollama` | root or docker group | yes | Unverified. |

## Manual install
1. Extract the tarball to `~/.local` (unverified path layout).
2. Start: `ollama serve`.
3. Check: `curl http://127.0.0.1:11434/api/version` (unverified endpoint).

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| Runs on CPU only | GPU driver/runtime missing. | Install CUDA or ROCm runtime (unverified per distro). |
| `address already in use` | Another ollama instance. | Stop the service: `systemctl stop ollama` (unverified). |
| Out of memory loading model | Not enough RAM/VRAM. | Use a smaller model. |

## Sources
- https://ollama.com/download (unverified)
- https://github.com/ollama/ollama
