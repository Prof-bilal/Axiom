# Firefox (firefox)

Status: unverified this session. Commands from model knowledge.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S firefox` | yes | yes | Usually preinstalled on Omarchy/Arch desktops. |
| Debian/Ubuntu | `sudo apt install firefox` | yes | yes | On Ubuntu this may be a snap wrapper (unverified). |
| Flatpak | `flatpak install flathub org.mozilla.firefox` | no (`--user`) | yes | ID unverified. |
| Vendor tarball | download from https://www.mozilla.org/firefox/download/thanks/ and extract to `~/.local/opt` | no | yes | Unverified. |

## Manual install
Use the vendor tarball; launch `~/.local/opt/firefox/firefox`.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| Blank window on Wayland with NVIDIA | Driver or GBM issue. | Set `MOZ_ENABLE_WAYLAND=1` or check driver setup (unverified). |
| Profile locked | Old instance still running. | Close other Firefox; remove `parent.lock` only if no process runs. |

## Sources
- https://support.mozilla.org/kb/install-firefox-linux (unverified this session)
