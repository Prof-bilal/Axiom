# LM Studio

- Id: `lmstudio` · Category: Development · Weight: heavy · Licence (catalog): Free, closed source
- Catalog sources: manual `https://lmstudio.ai`
- Install verified: yes · Screenshots: 1 of 3 · Logo: yes

## Overview
LM Studio is a desktop app for downloading and running open-weight large language models locally, with a chat interface and a local server. It is for users who want to run models on their own machine.

## Facts
- Name: LM Studio
- Publisher: LM Studio (lmstudio.ai)
- Official website: https://lmstudio.ai/
- Licence: the app is free, including for work, per the vendor blog. Individual model licences apply separately. Source: https://lmstudio.ai/blog (search summary)
- Latest version: not found (download links point to a "latest" path)
- Typical install size: not found
- Minimum RAM: vendor docs recommend at least 16 GB RAM for LLMs; third-party guides mention lower floors for small models. Source: https://lmstudio.ai/docs/app/system-requirements
- CPU: x64 or ARM64; AVX2 instruction set required on x64. Source: https://lmstudio.ai/docs/app/system-requirements (search summary)
- Disk: not found
- Linux: distributed as an AppImage; Ubuntu 20.04 or newer required. Source: https://lmstudio.ai/docs/app/system-requirements (search summary)

## Logo
Bundled icon: `apps/hub/icons/lmstudio.png`.

## Screenshots
Partial. One app image on the official homepage:
- ![Bionic workspace demo preview](https://lmstudio.ai/marketing-static/_next/image?url=%2Fmarketing-static%2Fbionic-demo%2Fbionic-demo-fallback-light-windows-v9.webp&w=3840&q=75&dpl=dpl-mw6x9z2k) Caption: workspace demo preview (Windows build image on the official homepage).
Only one image found, so the three-screenshot minimum is not met.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| AppImage (official download) | `download from https://lmstudio.ai/releases/latest/linux/x86_64/LMStudio.AppImage, then chmod +x LM-Studio-*.AppImage` | no |
| Arch AUR (community) | `yay -S lmstudio-bin` | no |

- Most common launch failure: missing FUSE 2 (fuse2 on Arch, libfuse2 or libfuse2t64 on Ubuntu, fuse-libs on Fedora).
- Avoid running with --no-sandbox; it disables a security feature.
- The lmstudio.ai page itself was not opened; the URL comes from guides.

- Source: https://www.tecmint.com/lm-studio-run-llms-linux/
- Source: https://aur.archlinux.org/packages/lmstudio-bin

## Install options (research draft; partially verified. AppImage route from several guides and the Arch AUR package PKGBUILD; download page not reached.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| AppImage | download from https://lmstudio.ai/download (Linux), then `chmod +x LM-Studio-*.AppImage` and run `./LM-Studio-*.AppImage` | no | yes | Primary route. Filename pattern from guides. |
| AUR | `yay -S lmstudio` | no | yes | Packager pulls AppImage from installers.lmstudio.ai (per AUR PKGBUILD). |
| CLI (lms) | follow LM Studio docs for `lms` bootstrap (unverified command) | no | yes | Headless/server use. |

## Manual install (draft)
1. Download the Linux AppImage from https://lmstudio.ai/download.
2. `chmod +x ~/Downloads/LM-Studio-*.AppImage`.
3. Optional: `mkdir -p ~/.local/opt && mv ~/Downloads/LM-Studio-*.AppImage ~/.local/opt/lmstudio.AppImage`.
4. Run: `~/.local/opt/lmstudio.AppImage`.
5. Check: the app opens and the model catalog loads (needs network).

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| `dlopen(): error loading libfuse.so.2` | FUSE 2 missing. | Ubuntu/Debian: `sudo apt install libfuse2` (or `libfuse2t64`). Fedora: `sudo dnf install fuse-libs`. Arch: `sudo pacman -S fuse2`. |
| Crashes unless `--no-sandbox` | Chromium sandbox issue (one guide). | Last resort only; disables a security feature. Prefer fixing user namespaces. |
| Low RAM, model will not load | Model too large for RAM/VRAM. | Pick a smaller or more quantized model. |
| Wrong GPU backend, very slow | GPU driver or Vulkan missing. | Install Vulkan drivers for your GPU (`vulkaninfo`), then restart. |

## Sources
- https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=lmstudio
- https://lmstudio.ai/
- https://lmstudio.ai/blog
- https://lmstudio.ai/docs/app/system-requirements
- https://lmstudio.ai/download
- https://www.tecmint.com/lm-studio-run-llms-linux/
