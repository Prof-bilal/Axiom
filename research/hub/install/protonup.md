# ProtonUp-Qt (protonup)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Flatpak | `flatpak install flathub net.davidotek.pupgui2` | no (`--user`) | yes | ID unverified. |
| pipx (CLI: protonup-ng style tool) | `pipx install protonup` | no | yes | Unverified; ProtonUp CLI name varies. |
| AUR | `yay -S protonup-qt` | no | yes | Unverified. |

## Manual install
Not needed.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| Steam does not show new Proton | Steam not restarted or compat dir wrong. | Restart Steam. Check Steam compatibility tools path (unverified). |
| Flatpak cannot find Steam library | Sandbox. | Flatpak override (unverified). |

## Sources
- https://davidotek.github.io/protonup-qt/ (unverified this session)
