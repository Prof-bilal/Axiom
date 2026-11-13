# Goose

- Id: `goose` · Category: Development · Weight: light · Licence (catalog): Apache-2.0
- Catalog sources: manual `https://github.com/block/goose`
- Install verified: yes · Screenshots: 0 of 3 · Logo: yes

## Overview
goose is an open-source, on-machine AI agent from Block that can run commands, edit files and connect to MCP servers, offered as a desktop app and CLI. It is for developers and power users who want a local, extensible agent.

## Facts
- Name: goose
- Publisher: Block (project later moved to the Agentic AI Foundation per secondary sources)
- Official website: https://goose-docs.ai/ (formerly https://block.github.io/goose/)
- Licence: Apache 2.0, per the official site footer ("Open Source Apache 2.0"). Source: https://goose-docs.ai/
- Latest version: not found (page references a stable release channel without a version)
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Linux install: AppImage or .deb desktop builds; CLI install script or Homebrew per secondary sources. Source: https://www.starryhope.com/linux/goose-omarchy/ (third-party)

## Logo
Bundled icon: `apps/hub/icons/goose.png`.

## Screenshots
Not found. The official site has only logos.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Official CLI install script (now under the Linux Foundation's aaif-goose) | `curl -fsSL https://github.com/aaif-goose/goose/releases/download/stable/download_cli.sh | bash` | no |
| Desktop .deb (Debian/Ubuntu) | `download from https://github.com/aaif-goose/goose/releases, then sudo dpkg -i goose_*.deb` | yes |
| Arch AUR (community, built from the .deb) | `yay -S goose-desktop-bin` | no |

- The project moved from block/goose to aaif-goose; older URLs may still work.
- The Linux Flatpak is a bundle file on the releases page, not a Flathub app.
- Needs a model provider.

- Source: https://goose-docs.ai/docs/quickstart
- Source: https://aur.archlinux.org/packages/goose-desktop-bin

## Install options (research draft; partially verified (install script URL from multiple search sources; security caveat is from one secondary site).)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| CLI script | `sh -c "curl -fsSL https://github.com/aaif-goose/goose/releases/download/stable/download_cli.sh | bash"` | no | yes | Repo moved to aaif-goose; older `block/goose` URLs may be outdated. Read the script before running. |
| Homebrew | `brew install block-goose-cli` | no | yes | Name from search; unverified. |
| Desktop app | .deb/.rpm from GitHub releases | yes | yes | Desktop is separate from CLI. |
| Update | `goose update` | no | yes | Per Homebrew note. |

## Manual install (draft)
1. Download `download_cli.sh` from https://github.com/aaif-goose/goose/releases (stable tag) and read it.
2. Run it: `bash download_cli.sh`.
3. Check: `goose --version`.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| `goose: command not found` | Install dir not on PATH. | Add the install dir (check script output) to PATH. |
| 404 on install URL | Old `block/goose` path. | Use the `aaif-goose` release URL above. |
| Config under `~/.config/goose` missing | First run not done. | Run `goose configure` (the user sets provider keys). |

## Sources
- https://block.github.io/goose/docs/getting-started/installation
- https://goose-docs.ai/
- https://goose-docs.ai/docs/getting-started/installation
- https://www.starryhope.com/linux/goose-omarchy/
