# MangoHud

- Id: `mangohud` · Category: Games · Weight: light · Licence (catalog): MIT
- Catalog sources: pacman `mangohud`
- Install verified: yes · Screenshots: 0 of 3 · Logo: yes

## Overview
MangoHud is a Vulkan and OpenGL overlay for Linux that displays FPS, frame timings, CPU and GPU statistics during games. It is for Linux gamers and benchmarkers who want performance data on screen.

## Facts
- Name: MangoHud
- Publisher: flightlessmango (open-source project)
- Official website: not confirmed in this pass; repository https://github.com/flightlessmango/MangoHud
- Licence: not confirmed in this pass (an MIT claim from earlier notes is unverified)
- Latest version: 0.8.2 per a November 2025 GamingOnLinux article; a 0.8.3 development build appears in a May 2026 directory snapshot (unconfirmed). Source: https://www.gamingonlinux.com/2025/11/mangohud-performance-overlay-for-linux-v0-8-2-released
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Linux: GitHub releases and distribution packages; GOverlay GUI companion. Source: search summary

## Logo
Bundled icon: `apps/hub/icons/mangohud.png`.

## Screenshots
Not found.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Arch packages (lib32 needs [multilib]) | `sudo pacman -S mangohud lib32-mangohud` | yes |

- 32-bit games need lib32-mangohud.
- With GameMode: mangohud gamemoderun %command% as the Steam launch option.

- Source: https://wiki.archlinux.org/title/MangoHud
- Source: https://www.archlinux.org/packages/multilib/x86_64/lib32-mangohud

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S mangohud` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install mangohud` | yes | yes | Availability varies. |
| Fedora | `sudo dnf install mangohud` | yes | yes | Unverified. |
| Flatpak | `flatpak install flathub org.freedesktop.Platform.VulkanLayer.MangoHud` | no | yes | Vulkan layer runtime; ID unverified. |

## Manual install (draft)
Not needed.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| Overlay not shown | Layer not loaded. | Launch with `mangohud %command%` (Steam) or `mangohud <app>`. |
| Vulkan layer missing | Layer package not installed. | Install the MangoHud layer package for your distro (unverified). |

## Sources
- https://github.com/flightlessmango/MangoHud
- https://github.com/flightlessmango/MangoHud/releases
- https://www.gamingonlinux.com/2025/11/mangohud-performance-overlay-for-linux-v0-8-2-released
