# LM Studio (lmstudio)

Status: partially verified. AppImage route from several guides and the Arch AUR package PKGBUILD; download page not reached.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| AppImage | download from https://lmstudio.ai/download (Linux), then `chmod +x LM-Studio-*.AppImage` and run `./LM-Studio-*.AppImage` | no | yes | Primary route. Filename pattern from guides. |
| AUR | `yay -S lmstudio` | no | yes | Packager pulls AppImage from installers.lmstudio.ai (per AUR PKGBUILD). |
| CLI (lms) | follow LM Studio docs for `lms` bootstrap (unverified command) | no | yes | Headless/server use. |

## Manual install
1. Download the Linux AppImage from https://lmstudio.ai/download.
2. `chmod +x ~/Downloads/LM-Studio-*.AppImage`.
3. Optional: `mkdir -p ~/.local/opt && mv ~/Downloads/LM-Studio-*.AppImage ~/.local/opt/lmstudio.AppImage`.
4. Run: `~/.local/opt/lmstudio.AppImage`.
5. Check: the app opens and the model catalog loads (needs network).

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| `dlopen(): error loading libfuse.so.2` | FUSE 2 missing. | Ubuntu/Debian: `sudo apt install libfuse2` (or `libfuse2t64`). Fedora: `sudo dnf install fuse-libs`. Arch: `sudo pacman -S fuse2`. |
| Crashes unless `--no-sandbox` | Chromium sandbox issue (one guide). | Last resort only; disables a security feature. Prefer fixing user namespaces. |
| Low RAM, model will not load | Model too large for RAM/VRAM. | Pick a smaller or more quantized model. |
| Wrong GPU backend, very slow | GPU driver or Vulkan missing. | Install Vulkan drivers for your GPU (`vulkaninfo`), then restart. |

## Sources
- https://lmstudio.ai/download
- https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=lmstudio
- https://www.tecmint.com/lm-studio-run-llms-linux/
