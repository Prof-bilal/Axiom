# Sublime Text (sublime)

Status: unverified. Search was rate-limited; treat commands as needing confirmation on sublimetext.com.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Official apt repo (Debian/Ubuntu) | follow https://www.sublimetext.com/docs/linux_repositories.html (add key and source, then `sudo apt install sublime-text`) | yes | yes | Vendor repo. Exact key URL unverified. |
| Official tarball | download from https://www.sublimetext.com/download | no (into `~/.local/opt`) | yes | Unverified filename. |
| AUR (Arch) | `yay -S sublime-text-4` | no | yes | Community-maintained, not vendor. Name unverified. |
| Flatpak | unknown | no | yes | Not confirmed whether Flathub hosts an official build. Check Flathub. |

## Manual install
1. Download the Linux tarball from https://www.sublimetext.com/download (unverified).
2. Extract to `~/.local/opt/sublime_text` (unverified).
3. Symlink `subl` into `~/.local/bin`.
4. Check: `subl --version` (if supported; unverified).

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| Apt `NO_PUBKEY` error | Signing key not imported. | Re-run the key import step from the vendor repo page (unverified). |
| Sublime asks for license on each start | Unlicensed use. | Vendor evaluation terms apply; the user must buy a license themselves. |

## Sources
- https://www.sublimetext.com/download
- https://www.sublimetext.com/docs/linux_repositories.html (unverified)
