# Firefox

- Id: `firefox` · Category: Internet · Weight: medium · Licence (catalog): MPL-2.0
- Catalog sources: flatpak `org.mozilla.firefox`, pacman `firefox`
- Install verified: yes · Screenshots: 3 of 3 · Logo: yes

## Overview
Firefox is Mozilla's open-source web browser with privacy features and extensions support. It is for general users and developers who want an independent browser engine.

## Facts
- Name: Mozilla Firefox
- Publisher: Mozilla Foundation
- Official website: https://www.mozilla.org/firefox/
- Licence: Mozilla Public License 2.0 (MPL-2.0); not confirmed from fetched sources in this pass. Verify at https://www.mozilla.org/en-US/MPL/
- Latest version: not found in this pass
- Typical install size: not found
- Minimum RAM: not found from current vendor page (search returned only old version pages)
- CPU: not found
- Disk: not found
- Linux note: 32-bit x86 Linux no longer supported from Firefox 145; 32-bit users can use the ESR line up to ESR 140. Source: https://support.mozilla.org/si/kb/firefox-has-ended-support-32-bit-linux (search summary)

Flathub data (https://flathub.org/api/v2/appstream/org.mozilla.firefox):
- Flatpak id: `org.mozilla.firefox` · Developer: Mozilla · Licence: MPL-2.0
- Latest version on Flathub: 160.0 (released 2026-11-04)

## Logo
Bundled icon: `apps/hub/icons/firefox.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/org.mozilla.firefox.png (verified-200).

## Screenshots
![Firefox screenshot 1](https://dl.flathub.org/media/org.mozilla.firefox-stable/1504x846/org.mozilla.firefox-af5d1ae7c121ea4864b3c5a1098f8f9c.png)
![Firefox screenshot 2](https://dl.flathub.org/media/org.mozilla.firefox-stable/1504x846/org.mozilla.firefox-c6f98b38b8b28b113a75a6b34037b759.png)
![Firefox screenshot 3](https://dl.flathub.org/media/org.mozilla.firefox-stable/1504x846/org.mozilla.firefox-60e855c1f4180607e40c9762a0fb9fa6.png)
Source: https://flathub.org/api/v2/appstream/org.mozilla.firefox

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Flatpak (Mozilla guide) | `flatpak install flathub org.mozilla.firefox` | no |

- Distro packages may lag behind or lack branding, per Mozilla.
- The Arch command sudo pacman -S firefox was not checked against a source.

- Source: https://support.mozilla.org/en-US/kb/install-firefox-linux

## Install options (research draft; unverified this session. Commands from model knowledge.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S firefox` | yes | yes | Usually preinstalled on Omarchy/Arch desktops. |
| Debian/Ubuntu | `sudo apt install firefox` | yes | yes | On Ubuntu this may be a snap wrapper (unverified). |
| Flatpak | `flatpak install flathub org.mozilla.firefox` | no (`--user`) | yes | ID unverified. |
| Vendor tarball | download from https://www.mozilla.org/firefox/download/thanks/ and extract to `~/.local/opt` | no | yes | Unverified. |

## Manual install (draft)
Use the vendor tarball; launch `~/.local/opt/firefox/firefox`.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| Blank window on Wayland with NVIDIA | Driver or GBM issue. | Set `MOZ_ENABLE_WAYLAND=1` or check driver setup (unverified). |
| Profile locked | Old instance still running. | Close other Firefox; remove `parent.lock` only if no process runs. |

## Sources
- https://support.mozilla.org/kb/install-firefox-linux
- https://support.mozilla.org/si/kb/firefox-has-ended-support-32-bit-linux
- https://www.mozilla.org/firefox/
