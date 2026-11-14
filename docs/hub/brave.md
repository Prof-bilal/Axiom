# Brave

- Id: `brave` · Category: Internet · Weight: heavy · Licence (catalog): MPL-2.0
- Catalog sources: flatpak `com.brave.Browser`
- Install verified: yes · Screenshots: 2 of 3 · Logo: yes

## Overview
Brave is a privacy-focused, Chromium-based web browser with built-in ad and tracker blocking and a rewards system. It is for users who want a Chromium browser with privacy defaults.

## Facts
- Name: Brave Browser
- Publisher: Brave Software, Inc.
- Official website: https://brave.com/download (Linux info https://brave.com/origin/linux/)
- Licence: MPL-2.0 for the source per secondary sources; not verified against the repository. Source: search summary
- Latest version: not found
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Linux: Brave Origin, a stripped-down edition, is free on Linux (paid on other platforms). Source: https://linuxiac.com/brave-gives-linux-users-its-stripped-down-origin-browser-for-free/ (search summary)
- Install: Brave RPM repo (Fedora), Arch package, Flatpak, Snap. Source: search summary

Flathub data (https://flathub.org/api/v2/appstream/com.brave.Browser):
- Flatpak id: `com.brave.Browser` · Developer: Brave Software · Licence: MPL-2.0
- Latest version on Flathub: 1.99.57 (released 2026-11-12)

## Logo
Bundled icon: `apps/hub/icons/brave.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/com.brave.Browser.png (verified-200).

## Screenshots
![Welcome page of Brave](https://dl.flathub.org/media/com/brave/Browser/eaad22d475d8a7ae02d00d8995778a3f/screenshots/image-1_orig.png)
![New tab page of Brave](https://dl.flathub.org/media/com/brave/Browser/eaad22d475d8a7ae02d00d8995778a3f/screenshots/image-2_orig.png)
Source: https://flathub.org/api/v2/appstream/com.brave.Browser

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Official install script | `curl -fsS https://dl.brave.com/install.sh | sh` | yes |
| Arch AUR binary (official page) | `yay -Sy brave-bin` | no |
| Flatpak | `flatpak install flathub com.brave.Browser` | no |

- Brave's Linux page says the Flatpak is not working very well.
- The AUR package brave (without -bin) compiles from source and takes hours.

- Source: https://brave.com/linux/
- Source: https://forum.endeavouros.com/t/install-brave-from-the-aur-or-flatpak/69006

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Vendor apt repo | follow https://brave.com/linux/ then `sudo apt install brave-browser` | yes | yes | Unverified repo lines. |
| Vendor script | `sh -c "curl -fsS https://dl.brave.com/install.sh | sh"` | yes | yes | Unverified URL; read before running. |
| Arch AUR | `yay -S brave-bin` | no | yes | Community. |
| Flatpak | `flatpak install flathub com.brave.Browser` | no (`--user`) | yes | ID unverified. |

## Manual install (draft)
Use the Flatpak or vendor repo; no manual tarball documented here.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| Sandbox error | Chromium sandbox. | Fix user namespaces; avoid `--no-sandbox`. |
| Flatpak cannot access downloads | Sandbox. | Use portals or `flatpak override` (unverified). |

## Sources
- https://brave.com/linux/
- https://brave.com/origin/linux/
- https://linuxiac.com/brave-gives-linux-users-its-stripped-down-origin-browser-for-free/
