# VLC media player

- Id: `vlc` · Category: Multimedia · Weight: light · Licence (catalog): GPL-2.0
- Catalog sources: flatpak `org.videolan.VLC`, pacman `vlc`
- Install verified: yes · Screenshots: 3 of 3 · Logo: yes

## Overview
VLC media player is a free, open-source multimedia player that plays most audio and video formats and network streams. It is for general users who want a player that handles almost any media file.

## Facts
- Name: VLC media player
- Publisher: VideoLAN
- Official website: https://www.videolan.org/
- Licence: not confirmed in this pass (commonly LGPL/GPL; not verified)
- Latest version: 3.0.24 per a September 2026 Ubuntu Handbook report (single source, seen 2026-11-13). Source: https://ubuntuhandbook.org/index.php/2026/09/vlc-3-0-24-released-ppa-updated-for-ubuntu-26-04-24-04-22-04/
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Linux: official Snap, Flathub, Debian packages and source tarball on videolan.org. Source: https://snapcraft.io/vlc.md

Flathub data (https://flathub.org/api/v2/appstream/org.videolan.VLC):
- Flatpak id: `org.videolan.VLC` · Developer: VideoLAN et al. · Licence: GPL-2.0+
- Latest version on Flathub: 3.0.24 (released 2026-09-17)

## Logo
Bundled icon: `apps/hub/icons/vlc.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/org.videolan.VLC.png (verified-200).

## Screenshots
![VLC media player screenshot 1](https://dl.flathub.org/media/org/videolan/VLC/0e71024f872bdd57a2907a775cca0e6c/screenshots/image-1_orig.png)
![VLC media player screenshot 2](https://dl.flathub.org/media/org/videolan/VLC/0e71024f872bdd57a2907a775cca0e6c/screenshots/image-2_orig.png)
![VLC media player screenshot 3](https://dl.flathub.org/media/org/videolan/VLC/0e71024f872bdd57a2907a775cca0e6c/screenshots/image-3_orig.png)
Source: https://flathub.org/api/v2/appstream/org.videolan.VLC

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Flatpak | `flatpak install flathub org.videolan.VLC` | no |
| Arch package | `sudo pacman -S vlc` | yes |

- Known error: 'Nothing matches org.videolan.VLC in remote flathub' means the Flathub remote is missing or scoped wrong; add it with flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo.
- The Arch pacman command was not checked against a source.

- Source: https://linuxcapable.com/how-to-install-vlc-media-player-on-linux-mint/
- Source: https://discourse.flathub.org/t/vlc-org-videolan-vlc-not-found-in-remote-flathub/9496

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S vlc` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install vlc` | yes | yes | |
| Flatpak | `flatpak install flathub org.videolan.VLC` | no (`--user`) | yes | ID unverified. |
| Snap | `sudo snap install vlc` | yes | yes | Unverified. |

## Manual install (draft)
Not needed.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| No hardware decoding | VA-API driver missing. | Install `libva-utils` and GPU VA-API driver (unverified). |
| Flatpak cannot play local files | Sandbox. | `flatpak override` (unverified). |

## Sources
- https://snapcraft.io/vlc.md
- https://ubuntuhandbook.org/index.php/2026/09/vlc-3-0-24-released-ppa-updated-for-ubuntu-26-04-24-04-22-04/
- https://www.videolan.org/
- https://www.videolan.org/vlc/
