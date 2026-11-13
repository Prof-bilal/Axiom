# Cursor

- Id: `cursor` · Category: Development · Weight: medium · Licence (catalog): Proprietary
- Catalog sources: manual `https://cursor.com`
- Install verified: yes · Screenshots: 0 of 3 · Logo: yes

## Overview
Cursor is a proprietary AI-assisted code editor built on a VS Code base, with an integrated AI chat and agent. It is for developers who want AI editing inside a VS Code-style interface.

## Facts
- Name: Cursor
- Publisher: Anysphere
- Official website: https://cursor.com/ (download page https://cursor.com/download)
- Licence: proprietary (Wikipedia listing). Pricing tiers are not confirmed; third-party listings disagree. Source: https://en.wikipedia.org/wiki/Cursor_(code_editor)
- Latest version: not found
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Linux: AppImage and .deb builds per third-party guides. Source: https://mustafa.net/2026/07/25/how-to-install-cursor-on-linux-step-by-step-setup-guide/

## Logo
Bundled icon: `apps/hub/icons/cursor.png`.
Official logo: https://ptht05hbb1ssoooe.public.blob.vercel-storage.com/assets/brand/brand-logo-10.svg (found-unconfirmed).

## Screenshots
Not found. No screenshot URL recorded in this pass.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| AppImage, .deb or RPM from the official download page | `download from https://cursor.com/download` | deb/rpm: yes |
| Update a .deb install (repo added by the .deb) | `sudo apt update && sudo apt install --only-upgrade cursor` | yes |

- In-app auto-update only works for the AppImage; .deb users update through apt.
- AppImages need FUSE 2; some users report the AppImage needs --no-sandbox, which disables a security feature.
- cursor.com itself was not opened.

- Source: https://forum.cursor.com/t/if-you-use-deb-version-auto-update-will-download-appimage/155066
- Source: https://linuxcapable.com/how-to-install-cursor-on-ubuntu-linux/

## Install options (research draft; unverified. Search not run; Cursor is a proprietary editor, so no distro package is assumed.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| AppImage (vendor) | download from https://cursor.com/download (Linux), `chmod +x`, run | no | yes | Vendor download; filename unverified. |
| AUR | `yay -S cursor-bin` | no | yes | Community package; unverified. |
| Flatpak | unverified | no | yes | Check Flathub. |

## Manual install (draft)
1. Download the Linux AppImage from the vendor download page (unverified URL).
2. `chmod +x ~/Downloads/Cursor-*.AppImage`.
3. Run it. Sign in yourself.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| AppImage FUSE error | FUSE 2 missing. | Install `libfuse2` (or distro equivalent). |
| Sandbox error at start | Electron sandbox. | Fix user namespace settings; avoid `--no-sandbox` except temporary tests. |

## Sources
- https://cursor.com
- https://cursor.com/download
- https://en.wikipedia.org/wiki/Cursor_(code_editor
