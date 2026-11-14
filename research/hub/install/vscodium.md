# VSCodium (vscodium)

Status: verified for Flathub ID and the install command. Other method details from search results.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Flatpak | `flatpak install flathub com.vscodium.codium` | no (use `--user` on a user install) | yes | Flathub ID confirmed by search. Run with `flatpak run com.vscodium.codium`. Flathub remote must exist. |
| Debian/Ubuntu package | see vscodium.com install page (`.deb` from GitHub releases) | yes for `dpkg -i`/`apt install` | yes | Downloaded from GitHub releases. |
| Fedora/openSUSE package | see vscodium.com install page (`.rpm`) | yes | yes | Official rpm listed on vscodium.com per search. |
| Tarball | download `VSCodium-linux-x64-*.tar.gz` from github.com/VSCodium/vscodium/releases | no | yes | Unpack to `~/.local/opt`; filename pattern unverified. |
| AUR (Arch) | `yay -S vscodium-bin` | no (yay) | yes | Community package; not confirmed in this session. |

## Manual install
1. Open https://github.com/VSCodium/vscodium/releases and download the Linux x64 tarball (exact name unverified).
2. `mkdir -p ~/.local/opt && tar -xzf ~/Downloads/<file>.tar.gz -C ~/.local/opt`.
3. `ln -s ~/.local/opt/VSCodium-linux-x64/bin/codium ~/.local/bin/codium` (path unverified).
4. Check: `codium --version`.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| `error: remote "flathub" not found` | Flathub not added. | `flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo` |
| Flatpak app cannot open project folder | Sandbox lacks filesystem access. | `flatpak override --user --filesystem=xdg-documents com.vscodium.codium` (unverified). |
| `Running as root is not supported` | Started with sudo. | Run as user. |
| Sandbox / SUID error on tarball | `chrome-sandbox` permissions. | Fix permissions on `chrome-sandbox` in the install dir (unverified). |

## Sources
- https://flathub.org/apps/com.vscodium.codium (ID from search results)
- https://vscodium.com
- https://github.com/VSCodium/vscodium
