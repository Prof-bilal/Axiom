# Obsidian

- Id: `obsidian` · Category: Productivity · Weight: light · Licence (catalog): Proprietary
- Catalog sources: flatpak `md.obsidian.Obsidian`
- Install verified: yes · Screenshots: 4 of 3 · Logo: yes

## Overview
Obsidian is a Markdown-based note-taking app that stores notes as local files and supports linking and plugins. It is for writers, researchers and students who want local notes with a knowledge graph.

## Facts
- Name: Obsidian
- Publisher: Obsidian (obsidian.md)
- Official website: https://obsidian.md/ (install help https://obsidian.md/help/install)
- Licence: not found (the licence and terms were not confirmed in this pass)
- Latest version: not found
- Typical install size: not found from vendor
- Minimum RAM: not found from vendor
- CPU: not found from vendor
- Disk: not found from vendor
- Linux: AppImage, Snap, .deb and a community-maintained Flatpak. Source: https://obsidian.md/help/install (search summary)

Flathub data (https://flathub.org/api/v2/appstream/md.obsidian.Obsidian):
- Flatpak id: `md.obsidian.Obsidian` · Developer: Obsidian · Licence: LicenseRef-proprietary=https://obsidian.md/eula
- Latest version on Flathub: 1.15.0 (released 2026-10-31)

## Logo
Bundled icon: `apps/hub/icons/obsidian.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/md.obsidian.Obsidian.png (verified-200).

## Screenshots
![Screenshot of Obsidian's main interface](https://dl.flathub.org/media/md/obsidian/Obsidian/c97fbe7fe83bc7e70ac76009b6b56055/screenshots/image-1_orig.png)
![Examples of Obsidian's basic text formatting capabilities](https://dl.flathub.org/media/md/obsidian/Obsidian/c97fbe7fe83bc7e70ac76009b6b56055/screenshots/image-2_orig.png)
![Screenshot of Obsidian's graph view](https://dl.flathub.org/media/md/obsidian/Obsidian/c97fbe7fe83bc7e70ac76009b6b56055/screenshots/image-3_orig.png)
![Example of Obsidian's multi-pane (now multi-tab) layout capabilities](https://dl.flathub.org/media/md/obsidian/Obsidian/c97fbe7fe83bc7e70ac76009b6b56055/screenshots/image-4_orig.png)
Source: https://flathub.org/api/v2/appstream/md.obsidian.Obsidian

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Flatpak (listed in Obsidian's help) | `flatpak install flathub md.obsidian.Obsidian` | no |
| AppImage | `download from https://obsidian.md/download, then chmod u+x Obsidian-<version>.AppImage` | no |

- AppImage failing with a FUSE error needs libfuse2 (fuse2 on Arch).
- With Flatpak, leave Obsidian's in-app updates off; Flatpak handles updates.

- Source: https://obsidian.md/help/install

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Flatpak | `flatpak install flathub md.obsidian.Obsidian` | no (`--user`) | yes | ID unverified. |
| AppImage (vendor) | download from https://obsidian.md/download, `chmod +x`, run | no | yes | Unverified filename. |
| AUR | `yay -S obsidian` | no | yes | Unverified. |

## Manual install (draft)
1. Download the AppImage from https://obsidian.md/download (unverified).
2. `chmod +x Obsidian-*.AppImage`, run.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| AppImage FUSE error | FUSE 2 missing. | Install `libfuse2` (or distro equivalent). |
| Flatpak cannot see vault | Sandbox. | `flatpak override --user --filesystem=<vault path>` (unverified). |

## Sources
- https://obsidian.md/download
- https://obsidian.md/help/install
