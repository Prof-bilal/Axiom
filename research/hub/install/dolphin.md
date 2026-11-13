# Dolphin emulator (dolphin)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Flatpak | `flatpak install flathub org.DolphinEmu.dolphin-emu` | no (`--user`) | yes | ID unverified. |
| Arch repos | `sudo pacman -S dolphin-emu` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install dolphin-emu` | yes | yes | Availability varies by release. |
| AppImage | download from https://dolphin-emu.org/download/ | no | yes | Unverified. |

## Manual install
Not needed.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| Graphics backend fails | Vulkan driver missing. | Install Vulkan driver for your GPU (unverified). |
| Flatpak cannot read ISO | Sandbox. | `flatpak override` for ROM folder (unverified). |

## Sources
- https://dolphin-emu.org/download/ (unverified this session)
