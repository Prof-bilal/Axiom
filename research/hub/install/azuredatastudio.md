# Azure Data Studio (azuredatastudio)

Status: unverified this session. Microsoft has announced retirement of Azure Data Studio; check current status before listing.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Tarball | download from Microsoft's Azure Data Studio page, extract to `~/.local/opt`, run `azuredatastudio` | no | yes | Unverified URL and filename. |
| .deb / .rpm | `sudo apt install ./azuredatastudio-*.deb` | yes | yes | Unverified. |
| Snap / Flatpak | unverified | varies | yes | Check stores. |

## Manual install
Download the tarball and run its launcher; check the app opens.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| Keyring errors on start | No secret service. | Install and run gnome-keyring or KWallet (unverified). |
| Sandbox error | Electron sandbox. | Fix chrome-sandbox permissions (unverified). |

## Sources
- https://learn.microsoft.com/sql/azure-data-studio/ (unverified this session)
