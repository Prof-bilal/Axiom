# Steam

- Id: `steam` · Category: Games · Weight: heavy · Licence (catalog): Proprietary
- Catalog sources: flatpak `com.valvesoftware.Steam`
- Install verified: yes · Screenshots: 5 of 3 · Logo: yes

## Overview
Steam is Valve's digital game distribution platform and client, with a large library and a Linux client that runs many Windows games through Proton. It is for gamers who want to buy, install and play games on Linux.

## Facts
- Name: Steam
- Publisher: Valve Corporation
- Official website: https://store.steampowered.com/ (Linux client via Valve's download page; URL not fetched in this pass)
- Licence: Steam Subscriber Agreement (not verified in this pass)
- Latest version: not found
- Typical install size: not found
- Minimum RAM: not found from the Linux requirements in this pass
- CPU: not found
- Disk: not found
- Linux requirements (per Valve requirements summary): glibc 2.31 or newer, Linux kernel 5.6 or newer, D-Bus session bus, OpenGL and Vulkan drivers, unprivileged user and mount namespaces; 32-bit libraries required. Source: search summary of Valve documentation (https://developer.valvesoftware.com/wiki/Steam_under_Linux)
- Linux packaging: Valve provides a .deb package; Snap and Flatpak are not provided by Valve. Source: search summary

Flathub data (https://flathub.org/api/v2/appstream/com.valvesoftware.Steam):
- Flatpak id: `com.valvesoftware.Steam` · Developer: Valve Corporation · Licence: LicenseRef-proprietary
- Latest version on Flathub: 1.0.0.87 (released 2026-06-26)

## Logo
Bundled icon: `apps/hub/icons/steam.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/com.valvesoftware.Steam.png (verified-200).

## Screenshots
![The main Steam library window](https://dl.flathub.org/media/com/valvesoftware/Steam/71bd4338705ac5f74c133bfbaacaa3d8/screenshots/image-1_orig.png)
![Steam Store interface](https://dl.flathub.org/media/com/valvesoftware/Steam/71bd4338705ac5f74c133bfbaacaa3d8/screenshots/image-2_orig.png)
![Steam screenshot 3](https://dl.flathub.org/media/com/valvesoftware/Steam/71bd4338705ac5f74c133bfbaacaa3d8/screenshots/image-3_orig.png)
![Steam screenshot 4](https://dl.flathub.org/media/com/valvesoftware/Steam/71bd4338705ac5f74c133bfbaacaa3d8/screenshots/image-4_orig.png)
![Steam screenshot 5](https://dl.flathub.org/media/com/valvesoftware/Steam/71bd4338705ac5f74c133bfbaacaa3d8/screenshots/image-5_orig.png)
Source: https://flathub.org/api/v2/appstream/com.valvesoftware.Steam

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Arch package (needs [multilib] enabled in /etc/pacman.conf) | `sudo pacman -S steam` | yes |
| Flatpak | `flatpak install flathub com.valvesoftware.Steam` | no |

- Steam is 32-bit, so the multilib repository must be enabled first.
- The Flatpak has no home-folder access; grant it with flatpak override com.valvesoftware.Steam --filesystem=$HOME.

- Source: https://wiki.archlinux.org/title/Steam
- Source: https://developer.valvesoftware.com/wiki/Getting_Steam_and_Source_1_%26_2_on_Arch_Linux

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S steam` (needs `multilib` enabled) | yes | yes | Multilib must be enabled first (unverified exact steps). |
| Debian/Ubuntu | `sudo apt install steam-installer` (Debian) or `steam` (Ubuntu multiverse) | yes | yes | Unverified. |
| Fedora | `sudo dnf install steam` (RPM Fusion) | yes | yes | RPM Fusion needed (unverified). |
| Flatpak | `flatpak install flathub com.valvesoftware.Steam` | no (`--user`) | yes | ID unverified. |

## Manual install (draft)
Not needed.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| `error while loading shared libraries` 32-bit | multilib / lib32 GPU libs missing. | Install lib32 Mesa or NVIDIA libs (unverified). |
| Black window in games | Vulkan driver missing. | Install Vulkan driver for your GPU. |
| Flatpak games cannot find library | Sandbox. | Use Flatpak docs for `flatpak override` (unverified). |

## Sources
- https://developer.valvesoftware.com/wiki/Steam
- https://developer.valvesoftware.com/wiki/Steam_under_Linux
- https://store.steampowered.com/about/
- https://wiki.archlinux.org/title/Steam
