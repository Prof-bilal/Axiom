# Discord

- Id: `discord` · Category: Internet · Weight: medium · Licence (catalog): Proprietary
- Catalog sources: flatpak `com.discordapp.Discord`
- Install verified: yes · Screenshots: 2 of 3 · Logo: yes

## Overview
Discord is a proprietary voice, video and text chat application popular with gaming and community groups, with an official Linux client. It is for users who want Discord on Linux.

## Facts
- Name: Discord
- Publisher: Discord Inc.
- Official website: https://discord.com/ (download page not fetched in this pass)
- Licence: proprietary (per search summary). Terms not fetched. Source: search summary of Discord Linux guides
- Latest version: not found
- Typical install size: not found
- Minimum RAM: not found
- CPU: 64-bit system required (amd64 only per search summary). Source: https://itsfoss.com/install-discord-linux
- Disk: not found
- Linux packages: deb, tar.gz, rpm, pkg.tar.zst; Flathub build (x86_64). Source: https://itsfoss.com/install-discord-linux and https://wiki.archlinux.org/title/Discord

Flathub data (https://flathub.org/api/v2/appstream/com.discordapp.Discord):
- Flatpak id: `com.discordapp.Discord` · Developer: Discord Inc. · Licence: LicenseRef-proprietary=https://discord.com/terms
- Latest version on Flathub: 1.0.169 (released 2026-11-09)

## Logo
Bundled icon: `apps/hub/icons/discord.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/com.discordapp.Discord.png (verified-200).

## Screenshots
![Dark Mode Window](https://dl.flathub.org/media/com/discordapp/Discord/ad437a3fa3ceb2574841465284223573/screenshots/image-1_orig.png)
![Light Mode Window](https://dl.flathub.org/media/com/discordapp/Discord/ad437a3fa3ceb2574841465284223573/screenshots/image-2_orig.png)
Source: https://flathub.org/api/v2/appstream/com.discordapp.Discord

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Flatpak (x86_64 only) | `flatpak install flathub com.discordapp.Discord` | no |
| Official .deb (Debian/Ubuntu) | `download from https://discord.com/download, then sudo apt install ./discord.deb` | yes |

- Do not mix the Flatpak, Snap and .deb builds on one system.
- discord.com itself was not opened; check the current packages there.

- Source: https://linuxcapable.com/how-to-install-discord-on-debian-linux/
- Source: https://itsfoss.com/install-discord-linux

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S discord` | yes | yes | Unverified. |
| Debian/Ubuntu .deb | download from https://discord.com/download (Linux .deb) then `sudo apt install ./discord-*.deb` | yes | yes | Unverified filename. |
| Flatpak | `flatpak install flathub com.discordapp.Discord` | no (`--user`) | yes | ID unverified. |
| Snap | `sudo snap install discord` | yes | yes | Unverified. |

## Manual install (draft)
Use the tarball from discord.com if no package manager route.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| Blank screen or update loop | Corrupt cache. | Remove `~/.config/discord` cache dirs (unverified). |
| Screen share fails on Wayland | Portal missing. | Install `xdg-desktop-portal` and backend (unverified). |

## Sources
- https://discord.com/download
- https://itsfoss.com/install-discord-linux
- https://wiki.archlinux.org/title/Discord
