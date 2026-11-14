# VSCodium

- Id: `vscodium` · Category: Development · Weight: heavy · Licence (catalog): MIT
- Catalog sources: flatpak `com.vscodium.codium`
- Install verified: yes · Screenshots: 5 of 3 · Logo: yes

## Overview
VSCodium is a community-driven, freely licensed binary distribution of Microsoft's VS Code editor with telemetry and Microsoft branding and licensing removed. It is for developers who want VS Code's features and extensions without the Microsoft product licence or telemetry.

## Facts
- Name: VSCodium
- Publisher: VSCodium community project (GitHub organisation VSCodium)
- Official website: https://vscodium.com/
- Licence: MIT for the binaries. Some extensions restrict use to official VS Code builds. Source: https://cdn.jsdelivr.net/gh/VSCodium/vscodium@master/README.md
- Latest version: not found (version badge was an image; not readable)
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Linux packages: deb, rpm, tar, AppImage, snap, Flatpak; distro repositories. Source: https://cdn.jsdelivr.net/gh/VSCodium/vscodium@master/README.md

Flathub data (https://flathub.org/api/v2/appstream/com.vscodium.codium):
- Flatpak id: `com.vscodium.codium` · Developer: The VSCodium team · Licence: MIT
- Latest version on Flathub: 1.143.17232 (released 2026-10-28)

## Logo
Bundled icon: `apps/hub/icons/vscodium.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/com.vscodium.codium.png (verified-200).

## Screenshots
![Reading a Markdown file](https://dl.flathub.org/media/com/vscodium/codium/e0a5c354f394516c7d99300ed5e4fd4a/screenshots/image-1_orig.png)
![Reading a Python example file](https://dl.flathub.org/media/com/vscodium/codium/e0a5c354f394516c7d99300ed5e4fd4a/screenshots/image-2_orig.png)
![Editing a Rust file](https://dl.flathub.org/media/com/vscodium/codium/e0a5c354f394516c7d99300ed5e4fd4a/screenshots/image-3_orig.png)
![Reading a Python File](https://dl.flathub.org/media/com/vscodium/codium/e0a5c354f394516c7d99300ed5e4fd4a/screenshots/image-4_orig.png)
![Searching for a file](https://dl.flathub.org/media/com/vscodium/codium/e0a5c354f394516c7d99300ed5e4fd4a/screenshots/image-5_orig.png)
Source: https://flathub.org/api/v2/appstream/com.vscodium.codium

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Flatpak | `flatpak install flathub com.vscodium.codium` | no |

- Sandboxed file access: grant folders with flatpak override.
- Wayland display problems: run codium --ozone-platform=x11.

- Source: https://flathub.org/pl/apps/com.vscodium.codium
- Source: https://github.com/flathub/com.vscodium.codium

## Install options (research draft; verified for Flathub ID and the install command. Other method details from search results.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Flatpak | `flatpak install flathub com.vscodium.codium` | no (use `--user` on a user install) | yes | Flathub ID confirmed by search. Run with `flatpak run com.vscodium.codium`. Flathub remote must exist. |
| Debian/Ubuntu package | see vscodium.com install page (`.deb` from GitHub releases) | yes for `dpkg -i`/`apt install` | yes | Downloaded from GitHub releases. |
| Fedora/openSUSE package | see vscodium.com install page (`.rpm`) | yes | yes | Official rpm listed on vscodium.com per search. |
| Tarball | download `VSCodium-linux-x64-*.tar.gz` from github.com/VSCodium/vscodium/releases | no | yes | Unpack to `~/.local/opt`; filename pattern unverified. |
| AUR (Arch) | `yay -S vscodium-bin` | no (yay) | yes | Community package; not confirmed in this session. |

## Manual install (draft)
1. Open https://github.com/VSCodium/vscodium/releases and download the Linux x64 tarball (exact name unverified).
2. `mkdir -p ~/.local/opt && tar -xzf ~/Downloads/<file>.tar.gz -C ~/.local/opt`.
3. `ln -s ~/.local/opt/VSCodium-linux-x64/bin/codium ~/.local/bin/codium` (path unverified).
4. Check: `codium --version`.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| `error: remote "flathub" not found` | Flathub not added. | `flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo` |
| Flatpak app cannot open project folder | Sandbox lacks filesystem access. | `flatpak override --user --filesystem=xdg-documents com.vscodium.codium` (unverified). |
| `Running as root is not supported` | Started with sudo. | Run as user. |
| Sandbox / SUID error on tarball | `chrome-sandbox` permissions. | Fix permissions on `chrome-sandbox` in the install dir (unverified). |

## Sources
- https://cdn.jsdelivr.net/gh/VSCodium/vscodium@master/README.md
- https://flathub.org/apps/com.vscodium.codium
- https://github.com/VSCodium/vscodium
- https://vscodium.com
- https://vscodium.com/
- https://www.linuxlinks.com/vscodium-binary-distribution-vs-code
