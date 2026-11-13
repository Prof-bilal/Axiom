# DaVinci Resolve

- Id: `davinci-resolve` · Category: Graphics · Weight: heavy · Licence (catalog): Free and Studio (proprietary)
- Catalog sources: manual `https://www.blackmagicdesign.com/products/davinciresolve`
- Install verified: no · Screenshots: 0 of 3 · Logo: yes

## Overview
Professional video editing, colour and audio.

## Facts
Not researched yet.

## Logo
Bundled icon: `apps/hub/icons/davinci-resolve.png`.

## Screenshots
Not found.

## Install (verified against a source)
Not verified yet. Use the draft below only after checking it.

## Install options (research draft; Not verified: the official Blackmagic pages fetched did not show Linux install steps or system requirements, so no install command in the table is confirmed by an official source. All install and error details above come from community forum results.)
| Method | Command | Needs root | Verified? |
|---|---|---|---|
| Official Linux installer | Download the Linux zip from Blackmagic's support page, unzip it, then run the `.run` installer from a terminal (exact commands not on the fetched official pages) | Likely yes (installs to `/opt`); not verified | Not verified: the official pages fetched (https://www.blackmagicdesign.com/products/davinciresolve, https://www.blackmagicdesign.com/support/family/davinci-resolve-and-fusion) do not show Linux commands; the only description is a Resolve 15 configuration guide (https://documents.blackmagicdesign.com/ConfigGuides/DaVinci_Resolve_15_Mac_Configuration_Guide.pdf), which is for macOS |
| Community: skip package check | `SKIP_PACKAGE_CHECK=1` before the `.run` command | Not stated | Not verified: community forum only (https://forum.blackmagicdesign.com/viewtopic.php?f=21&t=206765), not an official command |
| Community: .deb builder | makeresolvedeb (community tool) | Not stated | Not verified: community tool, mentioned on the forum only |

## Possible errors and fixes (draft)
**Error: installer fails the system package check on newer distributions**
- Cause: reported on Linux Mint 22.1 and similar newer distributions (community reports).
- Fix (community workaround, not official): run the installer with `SKIP_PACKAGE_CHECK=1`, then move conflicting libraries such as libglib and libgio out of `/opt/resolve/libs`. Source: https://forum.blackmagicdesign.com/viewtopic.php?f=21&t=229111 (search result only).
- Official fix: Not found.

**Symptom: installer does not work on Ubuntu 25.10+ (Wayland-only)**
- Cause: community reports that Ubuntu 25.10 removed X11 session support.
- Fix: Not found on official pages.

## Sources
