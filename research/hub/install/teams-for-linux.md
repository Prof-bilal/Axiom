# Teams for Linux install guide

Status: Verified: install commands taken from the official installation guide; the error fixes are the guide's own documented fixes.


## Install options

| Method | Command | Needs root | Verified? |
|---|---|---|---|
| Debian/Ubuntu repo | `sudo apt update && sudo apt install teams-for-linux` (after adding the repo key and sources file from the guide) | Yes | Verified: https://ismaelmartinez.github.io/teams-for-linux/installation |
| Fedora/RHEL repo | `sudo dnf install teams-for-linux` (after importing the key and adding the repo file) | Yes | Verified: https://ismaelmartinez.github.io/teams-for-linux/installation |
| Arch AUR (yay) | `yay -S teams-for-linux` | No (yay asks for sudo to install) | Verified: https://ismaelmartinez.github.io/teams-for-linux/installation |
| Snap | `sudo snap install teams-for-linux` | Yes | Verified: https://ismaelmartinez.github.io/teams-for-linux/installation |
| Flathub | `flatpak install flathub com.github.IsmaelMartinez.teams_for_linux` | No | Verified: https://ismaelmartinez.github.io/teams-for-linux/installation |
| AppImage | `chmod +x teams-for-linux_*.AppImage && ./teams-for-linux_*.AppImage` | No | Verified: https://ismaelmartinez.github.io/teams-for-linux/installation |
| .deb (manual) | `sudo dpkg -i teams-for-linux_*.deb && sudo apt-get install -f` | Yes | Verified: https://ismaelmartinez.github.io/teams-for-linux/installation |

## Possible errors and fixes

- **Error:** missing dependencies after a `.deb` install.
  - Cause: `dpkg` does not resolve dependencies.
  - Fix: `sudo apt-get install -f`.
  - Source: https://ismaelmartinez.github.io/teams-for-linux/installation
- **Error:** AppImage will not mount.
  - Cause: `fusermount` or `fusermount3` is missing (FUSE not installed).
  - Fix: install the `fuse` or `fuse3` package. Where FUSE is unavailable, run `./teams-for-linux_*.AppImage --appimage-extract-and-run`.
  - Source: https://ismaelmartinez.github.io/teams-for-linux/installation
- **Error:** audio or webcam permission problems.
  - Cause: user is not in the `audio` or `video` group.
  - Fix: `sudo usermod -a -G audio $USER` and `sudo usermod -a -G video $USER`, then log out and back in.
  - Source: https://ismaelmartinez.github.io/teams-for-linux/installation
- **Error:** Snap audio or webcam denied on Ubuntu 24.04+.
  - Cause: AppArmor hotplug restriction.
  - Fix: `sudo snap connect teams-for-linux:hardware-observe`.
  - Source: https://ismaelmartinez.github.io/teams-for-linux/installation
- **Error:** GPG key problems with the package repo.
  - Cause: stale or incorrect signing key.
  - Fix: re-download the key and re-import it (`sudo rpm --import` on RPM systems).
  - Source: https://ismaelmartinez.github.io/teams-for-linux/installation
- **Error:** Flathub beta not found.
  - Cause: the guide states no beta build is currently published.
  - Fix: use the stable Flathub install and retry after the next release.
  - Source: https://ismaelmartinez.github.io/teams-for-linux/installation

