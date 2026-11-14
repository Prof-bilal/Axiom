# Cursor (cursor)

Status: unverified. Search not run; Cursor is a proprietary editor, so no distro package is assumed.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| AppImage (vendor) | download from https://cursor.com/download (Linux), `chmod +x`, run | no | yes | Vendor download; filename unverified. |
| AUR | `yay -S cursor-bin` | no | yes | Community package; unverified. |
| Flatpak | unverified | no | yes | Check Flathub. |

## Manual install
1. Download the Linux AppImage from the vendor download page (unverified URL).
2. `chmod +x ~/Downloads/Cursor-*.AppImage`.
3. Run it. Sign in yourself.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| AppImage FUSE error | FUSE 2 missing. | Install `libfuse2` (or distro equivalent). |
| Sandbox error at start | Electron sandbox. | Fix user namespace settings; avoid `--no-sandbox` except temporary tests. |

## Sources
- https://cursor.com (unverified this session)
