# Anki (anki)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Flatpak | `flatpak install flathub net.ankiweb.Anki` | no (`--user`) | yes | ID unverified. |
| Arch repos | `sudo pacman -S anki` | yes | yes | Unverified. |
| Vendor tarball / installer | download from https://apps.ankiweb.net then `./install.sh` in extracted dir | no (install.sh may use /usr/local) | yes | Unverified; vendor script. |

## Manual install
Extract the vendor tarball and run its `install.sh`.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| Missing Qt libs | Qt not installed. | Install distro Qt packages (unverified). |
| Sync fails | AnkiWeb login or network. | Sign in yourself. |

## Sources
- https://apps.ankiweb.net (unverified this session)
