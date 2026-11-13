# MangoHud (mangohud)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S mangohud` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install mangohud` | yes | yes | Availability varies. |
| Fedora | `sudo dnf install mangohud` | yes | yes | Unverified. |
| Flatpak | `flatpak install flathub org.freedesktop.Platform.VulkanLayer.MangoHud` | no | yes | Vulkan layer runtime; ID unverified. |

## Manual install
Not needed.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| Overlay not shown | Layer not loaded. | Launch with `mangohud %command%` (Steam) or `mangohud <app>`. |
| Vulkan layer missing | Layer package not installed. | Install the MangoHud layer package for your distro (unverified). |

## Sources
- https://github.com/flightlessmango/MangoHud (unverified this session)
