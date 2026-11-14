# ONLYOFFICE Desktop Editors (onlyoffice)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Vendor .deb / .rpm | download from https://www.onlyoffice.com/desktop.aspx then `sudo apt install ./onlyoffice-desktopeditors_*.deb` | yes | yes | Unverified. |
| Flatpak | `flatpak install flathub org.onlyoffice.desktopeditors` | no (`--user`) | yes | ID unverified. |
| AUR | `yay -S onlyoffice-bin` | no | yes | Unverified. |

## Manual install
Use the .deb or .rpm above.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| Fonts look wrong | Missing fonts. | Install fonts package (unverified). |
| Flatpak cannot save file | Sandbox. | `flatpak override` for documents (unverified). |

## Sources
- https://www.onlyoffice.com/desktop.aspx (unverified this session)
