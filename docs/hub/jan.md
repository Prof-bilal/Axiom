# Jan

- Id: `jan` · Category: Development · Weight: heavy · Licence (catalog): AGPL-3.0 (disputed)
- Catalog sources: manual `https://jan.ai`
- Install verified: yes · Screenshots: 0 of 3 · Logo: yes

## Overview
Jan is an open-source desktop app for running AI models locally, with a chat interface and support for connecting to remote model APIs. It is for users who want a private, offline-capable alternative to cloud chat apps.

## Facts
- Name: Jan
- Publisher: Jan (janhq)
- Official website: https://jan.ai/ (per search summary); repository https://github.com/janhq/jan
- Licence: AGPL-3.0 per the official repository; several third-party sites say Apache-2.0 (conflict). Source: https://github.com/janhq/jan (search summary)
- Latest version: not found
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Linux: AppImage and .deb builds from jan.ai or GitHub releases. Source: search summary of third-party reviews (https://dev.to/jovan_chan_9500711396d4e6/jan-ai-review-2026-13ei)

## Logo
Bundled icon: `apps/hub/icons/jan.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/ai.jan.Jan.png (verified-200).

## Screenshots
Not found. No screenshot URL recorded in this pass.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| AppImage (official docs) | `download from https://jan.ai/download, then chmod +x jan-linux-x86_64-*.AppImage` | no |
| .deb (Debian/Ubuntu, official docs) | `sudo apt-get install ./jan-linux-amd64-*.deb` | yes |

- Needs a CPU with AVX2; 8 GB RAM minimum, 16 GB recommended.
- The Flatpak id ai.jan.Jan was only seen in third-party sources.
- The licence is still unconfirmed (AGPL-3.0 vs Apache-2.0).

- Source: https://jan.ai/docs/desktop/linux
- Source: https://docs.jan.ai/jan/installation/linux

## Install options (research draft; unverified. Search not run; commands from model knowledge.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| AppImage | download from https://jan.ai or GitHub releases, `chmod +x`, run | no | yes | Unverified filename. |
| .deb / .rpm | `sudo apt install ./jan-*.deb` or `sudo dnf install ./jan-*.rpm` | yes | yes | From GitHub releases; unverified. |
| Flatpak | unverified | no | yes | Check Flathub. |

## Manual install (draft)
1. Download the AppImage from https://jan.ai (unverified link).
2. `chmod +x ~/Downloads/Jan-*.AppImage` and run it.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| AppImage will not start, FUSE error | FUSE 2 missing. | Install `libfuse2` (or distro equivalent). |
| Sandbox error at start | Chromium sandbox. | Fix user namespaces; avoid `--no-sandbox` except as temporary test. |

## Sources
- https://dev.to/jovan_chan_9500711396d4e6/jan-ai-review-2026-13ei
- https://github.com/janhq/jan
- https://jan.ai
- https://tooldirectory.ai/tools/jan-ai
