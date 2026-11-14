# Zoom

- Id: `zoom` · Category: Internet · Weight: medium · Licence (catalog): Proprietary
- Catalog sources: manual `https://zoom.us/download`
- Install verified: no · Screenshots: 0 of 3 · Logo: yes

## Overview
Video meetings client.

## Facts
Not researched yet.

## Logo
Bundled icon: `apps/hub/icons/zoom.png`.

## Screenshots
Not found.

## Install (verified against a source)
Not verified yet. Use the draft below only after checking it.

## Install options (research draft; Verified for the install and uninstall commands against Zoom's Linux install guide (fetched). Commands were not run on a machine here. The page does not give signing-key steps, so none are listed.)
Download the package from https://zoom.us/download?os=linux first.

| Method | Command | Needs root | Verified? |
|---|---|---|---|
| Debian / Ubuntu / Linux Mint (DEB) | `sudo apt install ./zoom_amd64.deb` | Yes | Verified: https://support.zoom.com/hc/en/article?id=zm_kb&sysparm_article=KB0063458 |
| openSUSE (RPM) | `sudo zypper install zoom_openSUSE_x86_64.rpm` | Yes | Verified: https://support.zoom.com/hc/en/article?id=zm_kb&sysparm_article=KB0063458 |
| Fedora / Oracle / CentOS / RedHat (RPM) | `sudo yum install zoom_x86_64.rpm` | Yes | Verified: https://support.zoom.com/hc/en/article?id=zm_kb&sysparm_article=KB0063458 |
| Arch / Manjaro (pkg) | `sudo pacman -U zoom_x86_64.pkg.tar.xz` | Yes | Verified: https://support.zoom.com/hc/en/article?id=zm_kb&sysparm_article=KB0063458 |
| Uninstall (Debian/Ubuntu) | `sudo apt remove zoom` | Yes | Verified: https://support.zoom.com/hc/en/article?id=zm_kb&sysparm_article=KB0063458 |
| Uninstall (openSUSE) | `sudo zypper remove zoom` | Yes | Verified: same page |
| Uninstall (Fedora/RHEL) | `sudo yum remove zoom` | Yes | Verified: same page |
| Uninstall (Arch) | `sudo pacman -Rs zoom` | Yes | Verified: same page |

## Possible errors and fixes (draft)
**Error: `missing dependencies` (Debian/Ubuntu)**
- Cause: stale package lists or missing dependencies.
- Fix: `sudo apt update`, then retry the install command.
- Source: https://support.zoom.com/hc/en/article?id=zm_kb&sysparm_article=KB0063458

**Error: `<user> is not in the sudoers file`** (Debian, when sudo is missing)
- Fix: run `su -`, then `apt install sudo`, then retry.
- Source: https://support.zoom.com/hc/en/article?id=zm_kb&sysparm_article=KB0063458

**Error: wrong package filename or architecture (32-bit systems)**
- Fix: use the 32-bit names: `zoom_openSUSE_i686.rpm` (openSUSE) or `zoom_i686.rpm` (Fedora/RedHat family).
- Source: https://support.zoom.com/hc/en/article?id=zm_kb&sysparm_article=KB0063458

**Error: dependency issues on Arch**
- Fix: update the system with pacman, then retry.
- Source: https://support.zoom.com/hc/en/article?id=zm_kb&sysparm_article=KB0063458

## Sources
