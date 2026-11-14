# Geany (geany)

Status: unverified. Search was rate-limited; commands from model knowledge.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S geany` | yes | yes | Common package name. |
| Debian/Ubuntu | `sudo apt install geany` | yes | yes | Can be an older version than Flathub. |
| Fedora | `sudo dnf install geany` | yes | yes | Unverified. |
| Flatpak | `flatpak install flathub org.geany.Geany` | no (`--user`) | yes | ID unverified. Run with `flatpak run org.geany.Geany`. |

## Manual install
Not needed.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| `remote "flathub" not found` | Flathub missing. | Add Flathub remote (see Kate entry). |
| Flatpak cannot open project files | Sandbox. | `flatpak override --user --filesystem=xdg-documents org.geany.Geany` (unverified). |
| Missing compiler/run output | Build tools not installed. | Install `gcc`/`make` through the distro (unverified). |

## Sources
- https://www.geany.org
- https://flathub.org (org.geany.Geany, unverified)
