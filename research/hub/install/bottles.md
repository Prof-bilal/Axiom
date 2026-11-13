# Bottles (bottles)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Flatpak | `flatpak install flathub com.usebottles.bottles` | no (`--user`) | yes | ID unverified; recommended upstream route. |
| Arch AUR | `yay -S bottles` | no | yes | Unverified. |

## Manual install
Not needed.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| Runner download fails | Network. | Retry; check proxy. |
| Flatpak cannot see game folder | Sandbox. | `flatpak override --user --filesystem=<path>` (unverified). |

## Sources
- https://usebottles.com (unverified this session)
