# Visual Studio Code

- Id: `vscode` · Category: Development · Weight: heavy · Licence (catalog): Proprietary
- Catalog sources: flatpak `com.visualstudio.code`
- Install verified: yes · Screenshots: 1 of 3 · Logo: yes

## Overview
Visual Studio Code is Microsoft's free code editor, built on the Code - OSS repository with Microsoft-specific customizations. It targets developers who want a general-purpose editor with a large extension ecosystem, integrated debugging, Git support and a built-in terminal.

## Facts
- Name: Visual Studio Code
- Publisher: Microsoft
- Official website: https://code.visualstudio.com/
- Licence: Microsoft product licence (free; distributed build is not pure open source; some bundled extensions have their own licences). Source: https://code.visualstudio.com/docs/supporting/faq and https://code.visualstudio.com/download
- Latest version: not found (not confirmed from the download page during this research)
- Typical install size: not found from vendor. Vendor states a disk footprint of "< 500 MB". Source: https://code.visualstudio.com/docs/supporting/requirements
- Minimum RAM: not found as a minimum. Vendor recommends 1 GB of RAM. Source: https://code.visualstudio.com/docs/supporting/requirements
- CPU: not found
- Disk: vendor states disk footprint < 500 MB. Source: https://code.visualstudio.com/docs/supporting/requirements
- Linux prerequisites (vendor): GLIBCXX 3.4.25 or later, GLIBC 2.28 or later. Source: https://code.visualstudio.com/docs/supporting/requirements

Flathub data (https://flathub.org/api/v2/appstream/com.visualstudio.code):
- Flatpak id: `com.visualstudio.code` · Developer: Microsoft Corporation · Licence: LicenseRef-proprietary=https://code.visualstudio.com/license
- Latest version on Flathub: 1.139.1 (released 2026-09-25)

## Logo
Bundled icon: `apps/hub/icons/vscode.png`.
Official logo: https://code.visualstudio.com/assets/branding/app-icon.png (verified-200).

## Screenshots
![Editing TypeScript](https://dl.flathub.org/media/com/visualstudio/code/929ab57f09f2d5a5bc7cea0648c9a332/screenshots/image-1_orig.png)
Source: https://flathub.org/api/v2/appstream/com.visualstudio.code

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Flatpak (community repackage, unverified on Flathub) | `flatpak install flathub com.visualstudio.code` | no |
| Snap (Microsoft) | `sudo snap install code --classic` | yes |

- The Flathub build is a repackaging of Microsoft's build and is not supported by Microsoft.
- Extensions that need host tools (gcc, python) may need Flatpak SDK extensions, for example org.freedesktop.Sdk.Extension.golang.

- Source: https://flathub.org/de/apps/com.visualstudio.code
- Source: https://github.com/flathub/com.visualstudio.code

## Install options (research draft; partially verified. Microsoft's Linux docs and the Arch wiki were confirmed by search. Flatpak ID and AUR package are unverified.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch official repos, open-source build (Code - OSS) | `sudo pacman -S code` | yes | yes | Open-source build, not the Microsoft binary. Verified via Arch wiki reference in search. |
| AUR, Microsoft build | `yay -S visual-studio-code-bin` | no (makepkg runs as user; yay asks for sudo to install) | yes | Community package, not Microsoft-maintained. Unverified against AUR page. |
| Snap (Microsoft) | `sudo snap install code --classic` | yes | yes | Listed in Microsoft's Linux docs. Requires snapd. |
| Flatpak | `flatpak install flathub com.visualstudio.code` | no (user install with `--user`) | yes | Flathub ID unverified; search sources disagreed. Check flathub.org first. |
| Debian/Ubuntu/Fedora repo | see Microsoft docs (adds Microsoft repo, then `sudo apt install code` or `sudo dnf install code`) | yes | yes | Microsoft's repo setup is in the official docs; exact key/repo lines not copied here (unverified copy). |
| Tarball / .deb / .rpm download | download from code.visualstudio.com/download | .deb/.rpm: yes; tar.gz: no | yes | Use the tarball for a user-local install. |

## Manual install (draft)
1. Open https://code.visualstudio.com/download and download the Linux `.tar.gz` (unverified exact filename).
2. `mkdir -p ~/.local/opt && tar -xzf ~/Downloads/VSCode-linux-x64.tar.gz -C ~/.local/opt` (filename unverified).
3. `ln -s ~/.local/opt/VSCode-linux-x64/bin/code ~/.local/bin/code` and ensure `~/.local/bin` is on PATH.
4. Check: `code --version`.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| `Running as root is not supported` | Launched with sudo or as root. | Run as your user. Do not use sudo for the editor. |
| `The SUID sandbox helper binary was found, but is not configured correctly` | Electron sandbox permissions on the tarball install. | Fix ownership and mode of `chrome-sandbox` in the install dir (as root, `chown root:root` and `chmod 4755`). Unverified path. |
| `No usable sandbox` or namespace errors on Ubuntu 24.04+ | AppArmor restricts unprivileged user namespaces. | Use the distro-provided VS Code package, which ships an AppArmor profile. Avoid `--no-sandbox` except as a temporary test. Unverified. |
| `code: command not found` | `~/.local/bin` not on PATH. | Add `export PATH="$HOME/.local/bin:$PATH"` to shell profile. |
| Flatpak cannot find the editor's workspace files | Flatpak sandbox has no access to the folder. | `flatpak override --user --filesystem=xdg-documents com.visualstudio.code` (unverified). |

## Sources
- https://code.visualstudio.com/
- https://code.visualstudio.com/docs/setup/linux
- https://code.visualstudio.com/docs/supporting/faq
- https://code.visualstudio.com/docs/supporting/requirements
- https://code.visualstudio.com/download
- https://itsfoss.com/install-vs-code-arch-linux/
- https://linuxiac.com/how-to-install-visual-studio-code-on-arch-linux/
- https://wiki.archlinux.org/title/Visual_Studio_Code
