# Sublime Text

- Id: `sublime` · Category: Development · Weight: light · Licence (catalog): Proprietary
- Catalog sources: manual `https://www.sublimetext.com/download`
- Install verified: yes · Screenshots: 0 of 3 · Logo: yes

## Overview
Sublime Text is a fast, closed-source commercial text and code editor with a Python plugin API and multi-cursor editing. It is for developers who want a lightweight, responsive editor and accept a paid licence.

## Facts
- Name: Sublime Text
- Publisher: Sublime HQ
- Official website: https://www.sublimetext.com/ (store https://www.sublimehq.com/store/text)
- Licence: proprietary. Free to download and evaluate; a paid licence is required for continued use. Source: https://www.sublimehq.com/store/text
- Price: a personal licence is reported at US$99 one-off by secondary sources; verify on the store page. Source: search summary only.
- Latest version: Sublime Text 4 (Build 4215), seen 2026-11-13; no release date shown. Source: https://www.sublimetext.com/
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Linux: Debian (.deb) packages for x86-64 and Aarch64 on the official site. Source: https://www.sublimetext.com/

## Logo
Bundled icon: `apps/hub/icons/sublime.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/com.sublimetext.three.png (verified-200).

## Screenshots
Not found. The official homepage has no hosted editor screenshots (only a placeholder and product icons).

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Official package repositories (Arch, apt, dnf) | `follow https://www.sublimetext.com/docs/linux_repositories.html` | yes |

- The exact Arch commands from the official page were not captured; open the page before installing.
- One Flathub listing is marked not maintained for new installs.

- Source: https://www.sublimetext.com/docs/linux_repositories.html

## Install options (research draft; unverified. Search was rate-limited; treat commands as needing confirmation on sublimetext.com.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Official apt repo (Debian/Ubuntu) | follow https://www.sublimetext.com/docs/linux_repositories.html (add key and source, then `sudo apt install sublime-text`) | yes | yes | Vendor repo. Exact key URL unverified. |
| Official tarball | download from https://www.sublimetext.com/download | no (into `~/.local/opt`) | yes | Unverified filename. |
| AUR (Arch) | `yay -S sublime-text-4` | no | yes | Community-maintained, not vendor. Name unverified. |
| Flatpak | unknown | no | yes | Not confirmed whether Flathub hosts an official build. Check Flathub. |

## Manual install (draft)
1. Download the Linux tarball from https://www.sublimetext.com/download (unverified).
2. Extract to `~/.local/opt/sublime_text` (unverified).
3. Symlink `subl` into `~/.local/bin`.
4. Check: `subl --version` (if supported; unverified).

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| Apt `NO_PUBKEY` error | Signing key not imported. | Re-run the key import step from the vendor repo page (unverified). |
| Sublime asks for license on each start | Unlicensed use. | Vendor evaluation terms apply; the user must buy a license themselves. |

## Sources
- https://forum.sublimetext.com/t/no-longer-free-to-evaluate/31335
- https://www.sublimehq.com/store/text
- https://www.sublimetext.com/
- https://www.sublimetext.com/docs/linux_repositories.html
- https://www.sublimetext.com/download
