# itch

- Id: `itch` · Category: Games · Weight: light · Licence (catalog): MIT
- Catalog sources: manual `https://itch.io/app`
- Install verified: yes · Screenshots: 0 of 3 · Logo: yes

## Overview
The itch app is a desktop client for itch.io that installs and updates games and tools from the itch.io store. It is for players and creators who use itch.io.

## Facts
- Name: itch app
- Publisher: itch corp
- Official website: https://itch.io/app
- Licence: MIT per the GitHub repository (itchio/itch) summary. Source: https://github.com/itchio/itch (search summary)
- Latest version: not found (the installer downloads the latest version)
- Typical install size: not found (the Linux installer is a small Go executable per the official install docs)
- Minimum RAM: not found from vendor
- CPU: not found from vendor
- Disk: not found from vendor
- Linux: download the Linux installer from https://itch.io/app. Source: https://itch.io/docs/itch/installing/linux/ (search summary)

## Logo
Bundled icon: `apps/hub/icons/itch.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/io.itch.itch.png (verified-200).

## Screenshots
Not found.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Official installer | `download itch-setup from https://itch.io/app, then chmod +x itch-setup && ./itch-setup` | no |
| Arch AUR (community wrapper of the same installer) | `yay -S itch-setup-bin` | no |

- Installs to ~/.itch; needs GTK3.
- Uninstall: ~/.itch/itch-setup --uninstall (your library in ~/.config/itch stays).

- Source: https://itch.io/docs/itch/installing/linux/
- Source: https://aur.archlinux.org/packages/itch-setup-bin

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| AppImage | download from https://itch.io/app, `chmod +x`, run | no | yes | Unverified filename. |
| Flatpak | `flatpak install flathub io.itch.itch` | no (`--user`) | yes | ID unverified. |
| .deb | download from itch.io/app then `sudo apt install ./itch-*.deb` | yes | yes | Unverified. |

## Manual install (draft)
Download the AppImage, `chmod +x`, run.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| AppImage FUSE error | FUSE 2 missing. | Install `libfuse2`. |

## Sources
- https://github.com/itchio/itch
- https://itch.io/app
- https://itch.io/docs/itch/installing/linux/
