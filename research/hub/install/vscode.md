# Visual Studio Code (vscode)

Status: partially verified. Microsoft's Linux docs and the Arch wiki were confirmed by search. Flatpak ID and AUR package are unverified.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch official repos, open-source build (Code - OSS) | `sudo pacman -S code` | yes | yes | Open-source build, not the Microsoft binary. Verified via Arch wiki reference in search. |
| AUR, Microsoft build | `yay -S visual-studio-code-bin` | no (makepkg runs as user; yay asks for sudo to install) | yes | Community package, not Microsoft-maintained. Unverified against AUR page. |
| Snap (Microsoft) | `sudo snap install code --classic` | yes | yes | Listed in Microsoft's Linux docs. Requires snapd. |
| Flatpak | `flatpak install flathub com.visualstudio.code` | no (user install with `--user`) | yes | Flathub ID unverified; search sources disagreed. Check flathub.org first. |
| Debian/Ubuntu/Fedora repo | see Microsoft docs (adds Microsoft repo, then `sudo apt install code` or `sudo dnf install code`) | yes | yes | Microsoft's repo setup is in the official docs; exact key/repo lines not copied here (unverified copy). |
| Tarball / .deb / .rpm download | download from code.visualstudio.com/download | .deb/.rpm: yes; tar.gz: no | yes | Use the tarball for a user-local install. |

## Manual install
1. Open https://code.visualstudio.com/download and download the Linux `.tar.gz` (unverified exact filename).
2. `mkdir -p ~/.local/opt && tar -xzf ~/Downloads/VSCode-linux-x64.tar.gz -C ~/.local/opt` (filename unverified).
3. `ln -s ~/.local/opt/VSCode-linux-x64/bin/code ~/.local/bin/code` and ensure `~/.local/bin` is on PATH.
4. Check: `code --version`.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| `Running as root is not supported` | Launched with sudo or as root. | Run as your user. Do not use sudo for the editor. |
| `The SUID sandbox helper binary was found, but is not configured correctly` | Electron sandbox permissions on the tarball install. | Fix ownership and mode of `chrome-sandbox` in the install dir (as root, `chown root:root` and `chmod 4755`). Unverified path. |
| `No usable sandbox` or namespace errors on Ubuntu 24.04+ | AppArmor restricts unprivileged user namespaces. | Use the distro-provided VS Code package, which ships an AppArmor profile. Avoid `--no-sandbox` except as a temporary test. Unverified. |
| `code: command not found` | `~/.local/bin` not on PATH. | Add `export PATH="$HOME/.local/bin:$PATH"` to shell profile. |
| Flatpak cannot find the editor's workspace files | Flatpak sandbox has no access to the folder. | `flatpak override --user --filesystem=xdg-documents com.visualstudio.code` (unverified). |

## Sources
- https://code.visualstudio.com/docs/setup/linux
- https://wiki.archlinux.org/title/Visual_Studio_Code
- https://itsfoss.com/install-vs-code-arch-linux/
- https://linuxiac.com/how-to-install-visual-studio-code-on-arch-linux/
