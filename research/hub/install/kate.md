# Kate (kate)

Status: unverified. Flathub ID from model knowledge; search was rate-limited.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Flatpak | `flatpak install flathub org.kde.kate` | no (`--user`) | yes | ID unverified. Run with `flatpak run org.kde.kate`. |
| Arch repos | `sudo pacman -S kate` | yes | yes | Package name unverified. |
| Debian/Ubuntu | `sudo apt install kate` | yes | yes | Package name unverified. |
| Fedora | `sudo dnf install kate` | yes | yes | Unverified. |

## Manual install
Not needed. Use a distro package or Flatpak.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| `error: remote "flathub" not found` | Flathub not added. | `flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo` |
| Flatpak cannot save to project folder | Sandbox. | `flatpak override --user --filesystem=xdg-documents org.kde.kate` (unverified). |
| Missing KDE integration in Flatpak | Portals not active. | Install `xdg-desktop-portal` and the matching backend (unverified). |

## Sources
- https://flathub.org (org.kde.kate, unverified)
- https://kate-editor.org
