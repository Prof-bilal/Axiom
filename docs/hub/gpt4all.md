# GPT4All

- Id: `gpt4all` · Category: Development · Weight: heavy · Licence (catalog): MIT
- Catalog sources: flatpak `io.gpt4all.gpt4all`, manual `https://gpt4all.io`
- Install verified: yes · Screenshots: 2 of 3 · Logo: yes

## Overview
GPT4All is a desktop app from Nomic for running local open-weight language models on consumer hardware, with a chat interface and local document support. It is for users who want an offline chat app with no cloud account.

## Facts
- Name: GPT4All
- Publisher: Nomic AI
- Official website: https://home.nomic.ai/gpt4all (historic gpt4all.io redirects); repository https://github.com/nomic-ai/gpt4all
- Licence: MIT for the app per repository summary; model licences vary. Source: https://github.com/nomic-ai/gpt4all (search summary)
- Latest version: not found; one source says no desktop release since 3.10.0 (February 2025). Source: https://mustafa.net/2026/09/13/how-to-install-and-configure-gpt4all-on-linux/
- Typical install size: not found
- Minimum RAM: not found from vendor; a third-party guide says 4 GB. Source: https://mustafa.net/2026/09/13/how-to-install-and-configure-gpt4all-on-linux/
- CPU: Intel Core i3 2nd Gen / AMD Bulldozer or better; x86-64 only. Source: https://github.com/nomic-ai/gpt4all (search summary)
- Disk: not found

Flathub data (https://flathub.org/api/v2/appstream/io.gpt4all.gpt4all):
- Flatpak id: `io.gpt4all.gpt4all` · Developer: Nomic-ai · Licence: MIT
- Latest version on Flathub: 3.10.0 (released 2025-02-25)

## Logo
Bundled icon: `apps/hub/icons/gpt4all.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/io.gpt4all.gpt4all.png (verified-200).

## Screenshots
![Main Window](https://dl.flathub.org/media/io/gpt4all/gpt4all/1ee7ca0d1b164d3843c20316bf440a88/screenshots/image-1_orig.png)
![GPT4All screenshot 2](https://dl.flathub.org/media/io/gpt4all/gpt4all/1ee7ca0d1b164d3843c20316bf440a88/screenshots/image-2_orig.png)
Source: https://flathub.org/api/v2/appstream/io.gpt4all.gpt4all

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Flatpak (community-maintained, unverified) | `flatpak install flathub io.gpt4all.gpt4all` | no |
| Official installer (.run, x86-64 only) | `download from https://gpt4all.io, then chmod +x gpt4all-installer-linux.run && ./gpt4all-installer-linux.run` | no |

- x86-64 only; no ARM build.
- Ubuntu 23.04+ may also need libxcb-cursor.

- Source: https://flathub.org/apps/io.gpt4all.gpt4all
- Source: https://github.com/nomic-ai/gpt4all

## Install options (research draft; unverified. Search not run.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Installer from vendor | download `gpt4all-installer-linux.run` from https://gpt4all.io and run it | no | yes | Unverified filename. |
| Flatpak | unverified | no | yes | Check Flathub. |
| AUR | `yay -S gpt4all-bin` | no | yes | Unverified. |

## Manual install (draft)
1. Download the Linux installer from https://gpt4all.io (unverified).
2. `chmod +x gpt4all-installer-linux.run` and run it.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| Installer won't run | Not executable. | `chmod +x` on the file. |
| Model download fails | Network or disk full. | Check network and free space; retry. |
| Slow inference | No GPU acceleration. | Use a smaller model. |

## Sources
- https://github.com/nomic-ai/gpt4all
- https://gpt4all.io
- https://mustafa.net/2026/09/13/how-to-install-and-configure-gpt4all-on-linux/
