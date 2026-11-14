# DB Browser for SQLite (sqlitebrowser)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Flatpak | `flatpak install flathub org.sqlitebrowser.sqlitebrowser` | no (`--user`) | yes | ID unverified. |
| Arch repos | `sudo pacman -S sqlitebrowser` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install sqlitebrowser` | yes | yes | Unverified. |

## Manual install
Not needed.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| Flatpak cannot open file | Sandbox. | `flatpak override --user --filesystem=xdg-documents org.sqlitebrowser.sqlitebrowser` (unverified). |

## Sources
- https://sqlitebrowser.org (unverified this session)
