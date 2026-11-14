# Steam (steam)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S steam` (needs `multilib` enabled) | yes | yes | Multilib must be enabled first (unverified exact steps). |
| Debian/Ubuntu | `sudo apt install steam-installer` (Debian) or `steam` (Ubuntu multiverse) | yes | yes | Unverified. |
| Fedora | `sudo dnf install steam` (RPM Fusion) | yes | yes | RPM Fusion needed (unverified). |
| Flatpak | `flatpak install flathub com.valvesoftware.Steam` | no (`--user`) | yes | ID unverified. |

## Manual install
Not needed.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| `error while loading shared libraries` 32-bit | multilib / lib32 GPU libs missing. | Install lib32 Mesa or NVIDIA libs (unverified). |
| Black window in games | Vulkan driver missing. | Install Vulkan driver for your GPU. |
| Flatpak games cannot find library | Sandbox. | Use Flatpak docs for `flatpak override` (unverified). |

## Sources
- https://store.steampowered.com/about/ (unverified this session)
- https://wiki.archlinux.org/title/Steam (unverified this session)
