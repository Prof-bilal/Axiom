# Zed

- Id: `zed` · Category: Development · Weight: light · Licence (catalog): GPL-3.0
- Catalog sources: flatpak `dev.zed.Zed`
- Install verified: yes · Screenshots: 5 of 3 · Logo: yes

## Overview
Zed is a high-performance, multiplayer code editor written in Rust, with built-in AI agent and collaboration features. It is for developers who want a fast native editor with integrated AI assistance.

## Facts
- Name: Zed
- Publisher: Zed Industries
- Official website: https://zed.dev/
- Licence: source primarily GPL-3.0-or-later, with Apache-2.0 components where marked; server-side components under AGPL-3.0 per a news article. Source: https://cdn.jsdelivr.net/gh/zed-industries/zed@main/README.md (README), https://itsfoss.com/news/zed-editor/
- Latest version: not found
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Linux install: vendor install script `curl -f https://zed.dev/install.sh | sh`; Flatpak and distro packages also offered. Source: https://zed.dev/docs/installation.html
- Linux requirements: 64-bit Intel/AMD or ARM; Ubuntu 20.04 and newer per third-party article. Source: https://itsfoss.com/news/zed-editor/ (third-party; not vendor-confirmed)

Flathub data (https://flathub.org/api/v2/appstream/dev.zed.Zed):
- Flatpak id: `dev.zed.Zed` · Developer: Zed Industries, Inc. · Licence: AGPL-3.0-or-later and Apache-2.0 and GPL-3.0-or-later
- Latest version on Flathub: v1.28.1 (released 2026-11-11)

## Logo
Bundled icon: `apps/hub/icons/zed.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/dev.zed.Zed.png (verified-200).

## Screenshots
![Zed with a large project open, showing language server and gitblame support](https://dl.flathub.org/media/dev/zed/Zed/fb2b92278424f25a17c9abb63f81646d/screenshots/image-1_orig.png)
![Zed with a file open and a channel message thread in the right sidebar](https://dl.flathub.org/media/dev/zed/Zed/fb2b92278424f25a17c9abb63f81646d/screenshots/image-2_orig.png)
![Example of a channel's shared document](https://dl.flathub.org/media/dev/zed/Zed/fb2b92278424f25a17c9abb63f81646d/screenshots/image-3_orig.png)
![Zed's extension list](https://dl.flathub.org/media/dev/zed/Zed/fb2b92278424f25a17c9abb63f81646d/screenshots/image-4_orig.png)
![Theme switcher UI and example theme](https://dl.flathub.org/media/dev/zed/Zed/fb2b92278424f25a17c9abb63f81646d/screenshots/image-5_orig.png)
Source: https://flathub.org/api/v2/appstream/dev.zed.Zed

- ![Parallel agents sidebar](https://zed.dev/cdn-cgi/image/width=2048,quality=75,format=auto/img/parallel-agents/sidebar.webp) Caption: sidebar for parallel agents, from the official site.
- ![Debugger](https://zed.dev/cdn-cgi/image/width=2048,quality=75,format=auto/https://images.zed.dev/video-posters/debugger.webp) Caption: debugger feature poster, from the official site.
- ![Inline assist](https://zed.dev/cdn-cgi/image/width=2048,quality=75,format=auto/img/agentic/posters/inline-assist-poster.webp) Caption: inline AI assist poster, from the official site.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Official install script | `curl -f https://zed.dev/install.sh | sh` | no |
| Flatpak (unverified wrapper) | `flatpak install flathub dev.zed.Zed` | no |

- The script build needs a Vulkan-capable GPU.

- Source: https://zed.dev/docs/linux

## Install options (research draft; verified (official docs via search results).)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Official install script | `sh -c "curl -f https://zed.dev/install.sh | sh"` | no | yes | Official fastest path. Script is piped to shell, so review it first if you need to. Needs glibc 2.31+ and Vulkan GPU per docs. |
| Preview channel | `sh -c "ZED_CHANNEL=preview curl -f https://zed.dev/install.sh | sh"` | no | yes | Preview receives updates about a week ahead. |
| Flatpak | `flatpak install flathub dev.zed.Zed` | no (`--user`) | yes | Docs say current Flatpak build exits the sandbox at startup. |
| Distro package | third-party packages named zed or zed-editor | depends | yes | Check distro repos (unverified). |

## Manual install (draft)
1. Download the tarball from https://zed.dev/download (unverified exact link).
2. Extract to `~/.local/zed.app` and symlink `~/.local/zed.app/bin/zed` to `~/.local/bin/zed`.
3. Install the desktop file from `~/.local/zed.app/share/applications/` (unverified path).
4. Check: `zed --version`.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| Blank window or crash at start | No working Vulkan driver. | Install your GPU Vulkan driver (Mesa `vulkan-radeon`, `vulkan-intel`, or NVIDIA driver with Vulkan). Check `vulkaninfo`. |
| Script fails: glibc too old | glibc below 2.31. | Upgrade the distro or use Flatpak. |
| `zed: command not found` | `~/.local/bin` not on PATH. | Add it to PATH. |
| Flatpak exits the sandbox / unexpected file access | Known Flatpak issue per Zed docs. | Prefer the install script on Linux. |

## Sources
- https://cdn.jsdelivr.net/gh/zed-industries/zed@main/README.md
- https://itsfoss.com/news/zed-editor/
- https://zed.dev/
- https://zed.dev/blog/zed-on-linux
- https://zed.dev/docs/installation.html
- https://zed.dev/docs/linux.html
