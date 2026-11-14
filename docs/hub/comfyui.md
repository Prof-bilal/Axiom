# ComfyUI

- Id: `comfyui` · Category: Graphics · Weight: heavy · Licence (catalog): GPL-3.0
- Catalog sources: manual `https://github.com/comfyanonymous/ComfyUI`
- Install verified: no · Screenshots: 0 of 3 · Logo: yes

## Overview
Node-based interface for Stable Diffusion image generation.

## Facts
Not researched yet.

## Logo
Bundled icon: `apps/hub/icons/comfyui.png`.

## Screenshots
Not found.

## Install (verified against a source)
Not verified yet. Use the draft below only after checking it.

## Install options (research draft; Verified: Desktop install commands are from the official Linux desktop docs; manual PyTorch and run commands are from the official ComfyUI README. The exact git clone command is not verified.)
| Method | Command | Needs root | Verified? |
|---|---|---|---|
| Comfy Desktop .deb (Debian/Ubuntu) | `sudo apt install ./*.deb` | Yes | Verified: https://docs.comfy.org/installation/desktop/linux |
| Comfy Desktop AppImage | `chmod +x ./*.AppImage && ./*.AppImage` | No (not stated) | Verified: https://docs.comfy.org/installation/desktop/linux |
| Comfy Desktop from source | `sudo apt install build-essential git`, then `git clone https://github.com/Comfy-Org/Comfy-Desktop.git`, `cd Comfy-Desktop`, `pnpm run init`, `./linux-dev.sh` | Only for the apt step | Verified: https://docs.comfy.org/installation/desktop/linux |
| ComfyUI manual, NVIDIA PyTorch | `pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu130` | No (use a venv) | Verified: https://github.com/Comfy-Org/ComfyUI |
| ComfyUI manual, AMD ROCm PyTorch | `pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm7.2` | No (use a venv) | Verified: https://github.com/Comfy-Org/ComfyUI |
| ComfyUI manual, Intel XPU PyTorch | `pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/xpu` | No (use a venv) | Verified: https://github.com/Comfy-Org/ComfyUI |
| ComfyUI dependencies | `pip install -r requirements.txt` (run inside the ComfyUI folder) | No (use a venv) | Verified: https://github.com/Comfy-Org/ComfyUI |
| ComfyUI run | `python main.py` | No | Verified: https://github.com/Comfy-Org/ComfyUI |

The README says to git clone the repository but does not give the exact command, so no clone command is listed.

## Possible errors and fixes (draft)
- **Error:** `Error: not found: make` during `pnpm run init`.
  - Cause: build tools are missing.
  - Fix: `sudo apt install build-essential git`.
  - Source: https://docs.comfy.org/installation/desktop/linux
- **Error:** AppImage fails to launch because the sandbox is blocked.
  - Cause: the sandbox cannot be created on this system.
  - Fix: `./*.AppImage --no-sandbox`. This disables sandboxing for every process, so use it only when the normal launch fails.
  - Source: https://docs.comfy.org/installation/desktop/linux
- **Error:** AppArmor profile missing after upgrading to Ubuntu 24.04.
  - Cause: the package's AppArmor profile was not installed.
  - Fix: `sudo apt reinstall comfyui-desktop-2`.
  - Source: https://docs.comfy.org/installation/desktop/linux
- **Error:** AppImage update fails.
  - Cause: the file is in a read-only location.
  - Fix: move the AppImage to a folder your user can write to.
  - Source: https://docs.comfy.org/installation/desktop/linux

## Sources
