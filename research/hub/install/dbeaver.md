# DBeaver Community (dbeaver)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Flatpak | `flatpak install flathub io.dbeaver.DBeaverCommunity` | no (`--user`) | yes | ID unverified. |
| Snap | `sudo snap install dbeaver-ce` | yes | yes | Unverified. |
| Arch repos | `sudo pacman -S dbeaver` | yes | yes | Unverified. |
| .deb | download from https://dbeaver.io/download/ then `sudo apt install ./dbeaver-ce_*.deb` | yes | yes | Unverified filename. |

## Manual install
Use the .deb or tarball from dbeaver.io.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| Java runtime errors | Bundled JDK issue. | Use the bundled build or set Java path (unverified). |
| Flatpak cannot read SSH keys | Sandbox. | Grant access with `flatpak override` (unverified). |

## Sources
- https://dbeaver.io/download/ (unverified this session)
