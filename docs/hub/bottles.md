# Bottles

- Id: `bottles` · Category: Games · Weight: medium · Licence (catalog): GPL-3.0
- Catalog sources: flatpak `com.usebottles.bottles`
- Install verified: yes · Screenshots: 5 of 3 · Logo: yes

## Overview
Bottles is a GTK application for managing Wine prefixes so Windows programs and games can be installed and run on Linux. It is for users who want a graphical way to manage Wine environments.

## Facts
- Name: Bottles
- Publisher: Bottles project (bottlesdevs)
- Official website: not confirmed in this pass; repository https://github.com/bottlesdevs/Bottles
- Licence: GPL-3.0-only per the AUR package metadata and the upstream repository summary. Source: https://aur.archlinux.org/packages/bottles?O=310 (search summary)
- Latest version: not found
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Linux: Flathub is the recommended route (app ID com.usebottles.bottles). Source: https://linuxuprising.com/2021/12/bottles-wine-prefix-manager-released.html (search summary, dated)

Flathub data (https://flathub.org/api/v2/appstream/com.usebottles.bottles):
- Flatpak id: `com.usebottles.bottles` · Developer: The Bottles Contributors · Licence: GPL-3.0-only
- Latest version on Flathub: 67.6 (released 2026-11-04)

## Logo
Bundled icon: `apps/hub/icons/bottles.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/com.usebottles.bottles.png (verified-200).

## Screenshots
![Bottles List Page](https://dl.flathub.org/media/com/usebottles/bottles/e9a39d6efc5a3a5eb3abd180a1f06843/screenshots/image-1_orig.png)
![Library Page](https://dl.flathub.org/media/com/usebottles/bottles/e9a39d6efc5a3a5eb3abd180a1f06843/screenshots/image-2_orig.png)
![Create New Bottle](https://dl.flathub.org/media/com/usebottles/bottles/e9a39d6efc5a3a5eb3abd180a1f06843/screenshots/image-3_orig.png)
![Bottle Details Page](https://dl.flathub.org/media/com/usebottles/bottles/e9a39d6efc5a3a5eb3abd180a1f06843/screenshots/image-4_orig.png)
![Bottle Settings Page](https://dl.flathub.org/media/com/usebottles/bottles/e9a39d6efc5a3a5eb3abd180a1f06843/screenshots/image-5_orig.png)
Source: https://flathub.org/api/v2/appstream/com.usebottles.bottles

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Flatpak (recommended by the developers) | `flatpak install flathub com.usebottles.bottles` | no |

- Grant access to specific folders instead of --filesystem=host.
- AUR packages exist (bottles, bottles-git) but Flatpak is the recommended route.

- Source: https://linuxcapable.com/how-to-install-bottles-on-ubuntu-linux/
- Source: https://github.com/bottlesdevs/bottles

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Flatpak | `flatpak install flathub com.usebottles.bottles` | no (`--user`) | yes | ID unverified; recommended upstream route. |
| Arch AUR | `yay -S bottles` | no | yes | Unverified. |

## Manual install (draft)
Not needed.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| Runner download fails | Network. | Retry; check proxy. |
| Flatpak cannot see game folder | Sandbox. | `flatpak override --user --filesystem=<path>` (unverified). |

## Sources
- https://aur.archlinux.org/packages/bottles?O=310
- https://github.com/bottlesdevs/Bottles
- https://usebottles.com
