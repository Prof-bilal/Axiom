# Chromium

- Id: `chromium` · Category: Internet · Weight: heavy · Licence (catalog): BSD
- Catalog sources: flatpak `org.chromium.Chromium`
- Install verified: yes · Screenshots: 1 of 3 · Logo: yes

## Overview
Chromium is the open-source browser project that underpins Google Chrome and many other browsers. It is for users and distributors who want a Chromium-based browser built from source or through Linux distributions.

## Facts
- Name: Chromium
- Publisher: Chromium project (Google-led)
- Official website: https://www.chromium.org
- Licence: Google-authored code under 3-clause BSD; other components under various open-source licences. Source: https://bugs.archlinux.org/task/67462 (search summary)
- Latest version: not found
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Linux: no official stable binary per a 2023 Wikipedia snapshot; distributions and community builds supply packages. Source: https://wiki.privacytools.io/wiki/Chromium_(software)?lang=en (search summary)

Flathub data (https://flathub.org/api/v2/appstream/org.chromium.Chromium):
- Flatpak id: `org.chromium.Chromium` · Developer: The Chromium Authors · Licence: BSD-3-Clause and LGPL-2.1+ and Apache-2.0 and IJG and MIT and GPL-2.0+ and ISC and OpenSSL and (MPL-1.1 or GPL-2.0 or LGPL-2.0)
- Latest version on Flathub: 157.0.8103.50 (released 2026-11-09)

## Logo
Bundled icon: `apps/hub/icons/chromium.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/org.chromium.Chromium.png (verified-200).

## Screenshots
![Chromium screenshot 1](https://dl.flathub.org/media/org/chromium/Chromium/2c7ae9c489b91756633684a24504f67f/screenshots/image-1_orig.png)
Source: https://flathub.org/api/v2/appstream/org.chromium.Chromium

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Flatpak (community-maintained) | `flatpak install flathub org.chromium.Chromium` | no |

- The Flathub build is community-maintained, not from Google.
- The Arch package name was not confirmed; check with pacman -Ss chromium.

- Source: https://www.linuxuprising.com/2020/12/chromium-and-ungoogled-chromium-web.html
- Source: https://blogs.gnome.org/wjjt/2021/03/

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S chromium` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install chromium` | yes | yes | On Ubuntu may be a snap wrapper (unverified). |
| Flatpak | `flatpak install flathub org.chromium.Chromium` | no (`--user`) | yes | Unverified ID. |

## Manual install (draft)
Not needed.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| Sandbox error as root | Running as root. | Do not run as root. |
| `The SUID sandbox helper binary` | Permissions. | Use distro package. Avoid `--no-sandbox`. |

## Sources
- https://bugs.archlinux.org/task/67462
- https://www.chromium.org
