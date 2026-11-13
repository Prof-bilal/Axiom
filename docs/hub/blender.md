# Blender

- Id: `blender` · Category: Graphics · Weight: heavy · Licence (catalog): GPL-3.0
- Catalog sources: flatpak `org.blender.Blender`
- Install verified: yes · Screenshots: 4 of 3 · Logo: yes

## Overview
Blender is a free, open-source 3D creation suite for modelling, animation, rendering, sculpting and video editing. It is for artists, animators and technical designers.

## Facts
- Name: Blender
- Publisher: Blender Foundation
- Official website: https://www.blender.org/
- Licence: not confirmed in this pass (commonly GPL; not verified)
- Latest version: not found
- Typical install size: not found
- Minimum RAM: not found (the manual says to check minimum and recommended hardware requirements, with figures not captured)
- CPU: not found
- Disk: not found
- Linux: binary packages from blender.org, distribution packages and a Snap package. Source: https://docs.blender.org/manual/en/4.3/getting_started/installing/index.html

Flathub data (https://flathub.org/api/v2/appstream/org.blender.Blender):
- Flatpak id: `org.blender.Blender` · Developer: Blender Foundation · Licence: GPL-3.0
- Latest version on Flathub: 5.2 (released 2026-07-14)

## Logo
Bundled icon: `apps/hub/icons/blender.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/org.blender.Blender.png (verified-200).

## Screenshots
![Sculpt](https://dl.flathub.org/media/org/blender/Blender/c6b07403115901571923d99f1b725b0e/screenshots/image-1_orig.png)
![Model](https://dl.flathub.org/media/org/blender/Blender/c6b07403115901571923d99f1b725b0e/screenshots/image-2_orig.png)
![Animate](https://dl.flathub.org/media/org/blender/Blender/c6b07403115901571923d99f1b725b0e/screenshots/image-3_orig.png)
![Edit & Grade](https://dl.flathub.org/media/org/blender/Blender/c6b07403115901571923d99f1b725b0e/screenshots/image-4_orig.png)
Source: https://flathub.org/api/v2/appstream/org.blender.Blender

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Flatpak (community package, unverified) | `flatpak install flathub org.blender.Blender` | no |
| Official tarball | `download Linux build from https://www.blender.org/download/ and extract` | no |

- Distro packages may lag behind the latest release.
- The Flathub build is x86_64 only.

- Source: https://docs.blender.org/manual/en/4.5/getting_started/installing/linux.html
- Source: https://linuxcapable.com/how-to-install-blender-on-fedora-linux/

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S blender` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install blender` | yes | yes | Version may be old. |
| Flatpak | `flatpak install flathub org.blender.Blender` | no (`--user`) | yes | ID unverified. |
| Vendor tarball | download from https://www.blender.org/download/ and extract to `~/.local/opt` | no | yes | Unverified filename. |

## Manual install (draft)
Extract tarball, run `blender` from the folder.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| Viewport black or crash | GPU driver or OpenGL version. | Update driver; check GPU requirements (unverified). |
| Low RAM render fails | Memory limit. | Lower scene size or tile settings. |

## Sources
- https://docs.blender.org/manual/en/4.3/getting_started/installing/index.html
- https://www.blender.org/download/
