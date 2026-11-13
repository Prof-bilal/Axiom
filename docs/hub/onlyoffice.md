# OnlyOffice

- Id: `onlyoffice` · Category: Productivity · Weight: medium · Licence (catalog): AGPL-3.0
- Catalog sources: flatpak `org.onlyoffice.desktopeditors`
- Install verified: yes · Screenshots: 5 of 3 · Logo: yes

## Overview
ONLYOFFICE Desktop Editors is an offline office suite for documents, spreadsheets and presentations, built on the ONLYOFFICE editor engine. It is for users who want a local, open-source alternative to Microsoft Office formats.

## Facts
- Name: ONLYOFFICE Desktop Editors
- Publisher: Ascensio System SIA (ONLYOFFICE)
- Official website: https://www.onlyoffice.com/ (helpcenter https://helpcenter.onlyoffice.com/desktop/installation)
- Licence: GNU AGPL v3.0 per the Snap Store listing and the 2016 open-source announcement. Source: https://snapcraft.io/onlyoffice-desktopeditors and https://www.onlyoffice.com/blog/2016/10/onlyoffice-desktop-editors-go-open-source
- Latest version: not found
- Typical install size: not found
- Minimum RAM: 2 GB or more per the official Linux guide (depends on document complexity). Source: https://guides.onlyoffice.com/installation/desktop-sys-reqs-linux.aspx (search summary)
- CPU: dual-core 2 GHz or better per the official Linux guide. Source: https://guides.onlyoffice.com/installation/desktop-sys-reqs-linux.aspx (search summary)
- Disk: at least 2 GB free per a third-party tutorial (unverified). Source: search summary
- Linux: DEB, RPM, GUI package, Snap, Flatpak and AppImage. Source: https://helpcenter.onlyoffice.com/desktop/installation (search summary)

Flathub data (https://flathub.org/api/v2/appstream/org.onlyoffice.desktopeditors):
- Flatpak id: `org.onlyoffice.desktopeditors` · Developer: ONLYOFFICE · Licence: AGPL-3.0-only
- Latest version on Flathub: 10.0.0 (released 2026-10-13)

## Logo
Bundled icon: `apps/hub/icons/onlyoffice.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/org.onlyoffice.desktopeditors.png (verified-200).

## Screenshots
![Home](https://dl.flathub.org/media/org/onlyoffice/desktopeditors/3760ea2b23912d02a32ae35898f66582/screenshots/image-1_orig.png)
![AI Tools](https://dl.flathub.org/media/org/onlyoffice/desktopeditors/3760ea2b23912d02a32ae35898f66582/screenshots/image-2_orig.png)
![Docs](https://dl.flathub.org/media/org/onlyoffice/desktopeditors/3760ea2b23912d02a32ae35898f66582/screenshots/image-3_orig.png)
![PDF Editor](https://dl.flathub.org/media/org/onlyoffice/desktopeditors/3760ea2b23912d02a32ae35898f66582/screenshots/image-4_orig.png)
![Sheets](https://dl.flathub.org/media/org/onlyoffice/desktopeditors/3760ea2b23912d02a32ae35898f66582/screenshots/image-5_orig.png)
Source: https://flathub.org/api/v2/appstream/org.onlyoffice.desktopeditors

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Flatpak (official Help Center guide) | `flatpak install flathub org.onlyoffice.desktopeditors` | no |

- The DEB package runs as desktopeditors; the Flatpak runs as flatpak run org.onlyoffice.desktopeditors.

- Source: https://helpcenter.onlyoffice.com/installation/desktop-install-flatpak.aspx
- Source: https://onlyoffice.com/blog/2019/11/onlyoffice-desktop-editors-are-now-available-as-flatpak

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Vendor .deb / .rpm | download from https://www.onlyoffice.com/desktop.aspx then `sudo apt install ./onlyoffice-desktopeditors_*.deb` | yes | yes | Unverified. |
| Flatpak | `flatpak install flathub org.onlyoffice.desktopeditors` | no (`--user`) | yes | ID unverified. |
| AUR | `yay -S onlyoffice-bin` | no | yes | Unverified. |

## Manual install (draft)
Use the .deb or .rpm above.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| Fonts look wrong | Missing fonts. | Install fonts package (unverified). |
| Flatpak cannot save file | Sandbox. | `flatpak override` for documents (unverified). |

## Sources
- https://github.com/ONLYOFFICE/DesktopEditors
- https://helpcenter.onlyoffice.com/desktop/installation
- https://snapcraft.io/onlyoffice-desktopeditors
- https://www.onlyoffice.com/desktop.aspx
