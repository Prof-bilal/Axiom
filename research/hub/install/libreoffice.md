# LibreOffice (libreoffice)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S libreoffice-fresh` (or `libreoffice-still`) | yes | yes | Package names unverified. |
| Debian/Ubuntu | `sudo apt install libreoffice` | yes | yes | |
| Fedora | `sudo dnf install libreoffice` | yes | yes | |
| Flatpak | `flatpak install flathub org.libreoffice.LibreOffice` | no (`--user`) | yes | ID unverified. |
| Vendor tarball | download from https://www.libreoffice.org/download/ | no | yes | Unverified. |

## Manual install
Use vendor tarball if needed.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| Java features missing | JRE not installed. | Install a JRE package (unverified). |
| Slow start | First launch profile. | Wait; or disable extensions. |

## Sources
- https://www.libreoffice.org/download/ (unverified this session)
