# Brave (brave)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Vendor apt repo | follow https://brave.com/linux/ then `sudo apt install brave-browser` | yes | yes | Unverified repo lines. |
| Vendor script | `sh -c "curl -fsS https://dl.brave.com/install.sh | sh"` | yes | yes | Unverified URL; read before running. |
| Arch AUR | `yay -S brave-bin` | no | yes | Community. |
| Flatpak | `flatpak install flathub com.brave.Browser` | no (`--user`) | yes | ID unverified. |

## Manual install
Use the Flatpak or vendor repo; no manual tarball documented here.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| Sandbox error | Chromium sandbox. | Fix user namespaces; avoid `--no-sandbox`. |
| Flatpak cannot access downloads | Sandbox. | Use portals or `flatpak override` (unverified). |

## Sources
- https://brave.com/linux/ (unverified this session)
