# DBeaver Community

- Id: `dbeaver` · Category: Development · Weight: heavy · Licence (catalog): Apache-2.0
- Catalog sources: flatpak `io.dbeaver.DBeaverCommunity`
- Install verified: yes · Screenshots: 4 of 3 · Logo: yes

## Overview
DBeaver Community is a free, cross-platform database administration and SQL client supporting many database engines. It is for developers and analysts who need one tool across several databases.

## Facts
- Name: DBeaver Community (dbeaver-ce)
- Publisher: DBeaver Corp.
- Official website: https://dbeaver.io/ (download https://dbeaver.io/download/)
- Licence: Apache License 2.0 per the official about page. Source: https://dbeaver.io/about/
- Latest version: 26.2.3 per the official download page (released October 18, 2026 as shown). Source: https://dbeaver.io/download/ (search summary)
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Linux install: snap (dbeaver-ce --classic), Flatpak (io.dbeaver.DBeaverCommunity), PPA, .deb. Source: https://dbeaver.io/download/ and https://snapcraft.io/dbeaver-ce

Flathub data (https://flathub.org/api/v2/appstream/io.dbeaver.DBeaverCommunity):
- Flatpak id: `io.dbeaver.DBeaverCommunity` · Developer: DBeaver Corporation · Licence: Apache-2.0
- Latest version on Flathub: 26.2.4 (released 2026-11-01)

## Logo
Bundled icon: `apps/hub/icons/dbeaver.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/io.dbeaver.DBeaverCommunity.png (verified-200).

## Screenshots
![General overview](https://dl.flathub.org/media/io/dbeaver/DBeaverCommunity/330733fda5961c5b0eaa724ce7080977/screenshots/image-1_orig.png)
![Entity Relationship Diagram](https://dl.flathub.org/media/io/dbeaver/DBeaverCommunity/330733fda5961c5b0eaa724ce7080977/screenshots/image-2_orig.png)
![Editing and running a SQL script](https://dl.flathub.org/media/io/dbeaver/DBeaverCommunity/330733fda5961c5b0eaa724ce7080977/screenshots/image-3_orig.png)
![Editing a Stored Procedure](https://dl.flathub.org/media/io/dbeaver/DBeaverCommunity/330733fda5961c5b0eaa724ce7080977/screenshots/image-4_orig.png)
Source: https://flathub.org/api/v2/appstream/io.dbeaver.DBeaverCommunity

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Flatpak (listed on dbeaver.io/download) | `flatpak install flathub io.dbeaver.DBeaverCommunity` | no |

- Flathub says DBeaver does not support the Flatpak repackaging; report Flatpak issues to Flathub.
- The first install is large because it pulls a GNOME runtime.
- SSH tunnels: give the sandbox read access to ~/.ssh with flatpak override (community tip).

- Source: https://dbeaver.io/download/
- Source: https://flathub.org/de/apps/io.dbeaver.DBeaverCommunity

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Flatpak | `flatpak install flathub io.dbeaver.DBeaverCommunity` | no (`--user`) | yes | ID unverified. |
| Snap | `sudo snap install dbeaver-ce` | yes | yes | Unverified. |
| Arch repos | `sudo pacman -S dbeaver` | yes | yes | Unverified. |
| .deb | download from https://dbeaver.io/download/ then `sudo apt install ./dbeaver-ce_*.deb` | yes | yes | Unverified filename. |

## Manual install (draft)
Use the .deb or tarball from dbeaver.io.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| Java runtime errors | Bundled JDK issue. | Use the bundled build or set Java path (unverified). |
| Flatpak cannot read SSH keys | Sandbox. | Grant access with `flatpak override` (unverified). |

## Sources
- https://dbeaver.io/about/
- https://dbeaver.io/download/
- https://snapcraft.io/dbeaver-ce
