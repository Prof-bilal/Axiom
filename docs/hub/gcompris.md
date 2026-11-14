# GCompris

- Id: `gcompris` · Category: Education · Weight: light · Licence (catalog): GPL-3.0
- Catalog sources: flatpak `org.kde.gcompris`
- Install verified: yes · Screenshots: 5 of 3 · Logo: yes

## Overview
GCompris is a free educational software suite of more than 100 activities for children roughly aged 2 to 10. It is for parents, teachers and young children learning on Linux.

## Facts
- Name: GCompris
- Publisher: GCompris team (KDE community)
- Official website: https://gcompris.net/
- Licence: AGPL-3.0-only for the current Qt-based line per Wikipedia; older releases GPL. Source: https://en.wikipedia.org/wiki/GCompris (search summary)
- Latest version: not found
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Linux: install through Discover or distribution package managers; the official site hosts Linux downloads (download page not fetched). Source: https://apps.kde.org/gcompris/ (search summary)

Flathub data (https://flathub.org/api/v2/appstream/org.kde.gcompris):
- Flatpak id: `org.kde.gcompris` · Developer: KDE · Licence: AGPL-3.0
- Latest version on Flathub: 26.2 (released 2026-09-23)

## Logo
Bundled icon: `apps/hub/icons/gcompris.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/org.kde.gcompris.png (verified-200).

## Screenshots
![GCompris main menu](https://dl.flathub.org/media/org/kde/gcompris/6b4a73b3e227329bd88ac50017e42bbb/screenshots/image-1_orig.png)
!["Click on an uppercase letter" activity](https://dl.flathub.org/media/org/kde/gcompris/6b4a73b3e227329bd88ac50017e42bbb/screenshots/image-2_orig.png)
!["Learning Clock" activity](https://dl.flathub.org/media/org/kde/gcompris/6b4a73b3e227329bd88ac50017e42bbb/screenshots/image-3_orig.png)
!["Mixing color of paint" activity](https://dl.flathub.org/media/org/kde/gcompris/6b4a73b3e227329bd88ac50017e42bbb/screenshots/image-4_orig.png)
!["Colors" activity](https://dl.flathub.org/media/org/kde/gcompris/6b4a73b3e227329bd88ac50017e42bbb/screenshots/image-5_orig.png)
Source: https://flathub.org/api/v2/appstream/org.kde.gcompris

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Flatpak (from a 2022 guide) | `flatpak install flathub org.kde.gcompris` | no |

- Only an old source confirmed the id; check flathub.org before relying on it.

- Source: https://en.ubunlog.com/?p=38232

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Flatpak | `flatpak install flathub org.gcompris.GCompris` | no (`--user`) | yes | ID unverified. |
| Arch repos | `sudo pacman -S gcompris-qt` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install gcompris-qt` | yes | yes | Unverified. |

## Manual install (draft)
Not needed.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| Audio missing | Audio backend. | Check PipeWire/PulseAudio (unverified). |
| Flatpak cannot save progress | Sandbox. | Check data dir permissions (unverified). |

## Sources
- https://apps.kde.org/gcompris/
- https://en.wikipedia.org/wiki/GCompris
- https://gcompris.net
