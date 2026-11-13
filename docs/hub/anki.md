# Anki

- Id: `anki` · Category: Education · Weight: light · Licence (catalog): AGPL-3.0
- Catalog sources: flatpak `net.ankiweb.Anki`
- Install verified: yes · Screenshots: 1 of 3 · Logo: yes

## Overview
Anki is a spaced-repetition flashcard program for memorising information, with scheduling, add-ons and sync. It is for students and learners who use flashcards long term.

## Facts
- Name: Anki
- Publisher: Ankitects Pty Ltd
- Official website: https://apps.ankiweb.net/ (Linux install docs https://docs.ankiweb.net/platform/linux/installing.html)
- Licence: AGPL-3.0-or-later per the Snap Store listing (third-party); not confirmed from the official site in this pass
- Latest version: 26.05 per a FileHorse listing (third-party); a Snap listing shows updates in September 2026, so a newer build may exist. Source: https://www.filehorse.com/download-anki/100824/
- Typical install size: not found
- Minimum RAM: not found
- CPU: 64-bit Intel/AMD with glibc 2.35 or newer, or AArch64 with glibc 2.39 or newer. Source: https://docs.ankiweb.net/platform/linux/installing.html (search summary)
- Disk: not found
- Linux: official build from apps.ankiweb.net; distro packages may be old. Musl-based distros not supported. Source: https://docs.ankiweb.net/platform/linux/installing.html

Flathub data (https://flathub.org/api/v2/appstream/net.ankiweb.Anki):
- Flatpak id: `net.ankiweb.Anki` · Developer: Damien Elmes · Licence: AGPL-3.0+
- Latest version on Flathub: 26.09.4 (released 2026-11-04)

## Logo
Bundled icon: `apps/hub/icons/anki.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/net.ankiweb.Anki.png (verified-200).

## Screenshots
![Flashcard and answer](https://dl.flathub.org/media/net/ankiweb/Anki/844887dbd05a52ecf890ddd79317b1ff/screenshots/image-1_orig.png)
Source: https://flathub.org/api/v2/appstream/net.ankiweb.Anki

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Official tarball | `download from https://apps.ankiweb.net, then tar xaf anki-*-linux-qt6.tar.zst && cd anki-*-linux-qt6 && sudo ./install.sh` | yes |
| Flatpak (community-maintained, unofficial) | `flatpak install flathub net.ankiweb.Anki` | no |

- musl-based distros are not supported.
- If Anki does not start, extra libraries may be missing (see the official docs).

- Source: https://docs.ankiweb.net/platform/linux/installing.html

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Flatpak | `flatpak install flathub net.ankiweb.Anki` | no (`--user`) | yes | ID unverified. |
| Arch repos | `sudo pacman -S anki` | yes | yes | Unverified. |
| Vendor tarball / installer | download from https://apps.ankiweb.net then `./install.sh` in extracted dir | no (install.sh may use /usr/local) | yes | Unverified; vendor script. |

## Manual install (draft)
Extract the vendor tarball and run its `install.sh`.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| Missing Qt libs | Qt not installed. | Install distro Qt packages (unverified). |
| Sync fails | AnkiWeb login or network. | Sign in yourself. |

## Sources
- https://apps.ankiweb.net
- https://docs.ankiweb.net/platform/linux/installing.html
- https://snapcraft.io/anki-desktop
- https://www.filehorse.com/download-anki/100824/
