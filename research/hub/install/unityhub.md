# Unity Hub install guide

Status: Verified against the official Unity Hub Linux install page (fetched). The commands were not run on a machine here. Sandbox settings and shared-library requirements are not covered by the official page, so they are not listed.


## Install options

| Method | Command | Needs root | Verified? |
|---|---|---|---|
| Ubuntu: add key | `sudo install -d /etc/apt/keyrings` then `curl -fsSL https://hub.unity3d.com/linux/keys/public \| sudo gpg --dearmor -o /etc/apt/keyrings/unityhub.gpg` | Yes | Verified: https://docs.unity.com/hub/install-hub-linux |
| Ubuntu: add repo | Write `/etc/apt/sources.list.d/unityhub.sources` (Types: deb, URIs: https://hub.unity3d.com/linux/repos/deb, Suites: stable, Components: main, Signed-By: /etc/apt/keyrings/unityhub.gpg) | Yes | Verified: https://docs.unity.com/hub/install-hub-linux |
| Ubuntu: install | `sudo apt update` then `sudo apt install unityhub` | Yes | Verified: https://docs.unity.com/hub/install-hub-linux |
| Fedora / RHEL / CentOS | Add `/etc/yum.repos.d/unityhub.repo` (baseurl https://hub.unity3d.com/linux/repos/rpm/stable, gpgcheck=1), then `sudo dnf check-update` and `sudo dnf install unityhub` | Yes | Verified: https://docs.unity.com/hub/install-hub-linux (RPM not officially supported on these distros) |
| AppImage (any distro) | `chmod +x UnityHubSetup-x86_64.AppImage` then `./UnityHubSetup-x86_64.AppImage` (download from https://public-cdn.cloud.unity3d.com/hub/prod/UnityHubSetup-x86_64.AppImage) | No | Verified: https://docs.unity.com/hub/install-hub-linux |
| Remove (apt) | `sudo apt remove unityhub` | Yes | Verified: https://docs.unity.com/hub/install-hub-linux |
| Remove (dnf) | `sudo dnf remove unityhub` | Yes | Verified: https://docs.unity.com/hub/install-hub-linux |

Notes: the official page uses `curl` to fetch the key, so `sudo apt install curl` is listed as a prerequisite. The beta repository steps are on the same page but are not copied here.

## Possible errors and fixes

**Error: AppImage reports `fusermount` or `FUSE` problem**
- Cause: FUSE is not available for AppImage mounting.
- Fix: install the `fuse3` package (Debian, Ubuntu, RHEL, Fedora), or run `./UnityHubSetup-x86_64.AppImage --appimage-extract-and-run`.
- Source: https://docs.unity.com/hub/install-hub-linux

**Error: `Only the beta shows with apt install unityhub`**
- Cause: both stable and unstable repositories are configured.
- Fix: disable the beta repository file (`unityhub-beta.sources` or `unityhub-beta.list`) and run `sudo apt update` then `sudo apt install unityhub`. RPM: move `/etc/yum.repos.d/unityhub_beta.repo` aside.
- Source: https://docs.unity.com/hub/install-hub-linux

**Error: `/etc/apt/sources.list.d/unityhub.sources: No such file or directory`**
- Fix: `sudo mkdir -p /etc/apt/sources.list.d`
- Source: https://docs.unity.com/hub/install-hub-linux

**Error: `E: Could not get lock /var/lib/dpkg/lock-frontend. It is held by process <number>`**
- Cause: another package process is running.
- Fix: the page suggests `sudo kill -9 <number>` and then `sudo dpkg --configure -a` if dpkg is left interrupted. The page does not warn that `kill -9` is forceful; wait for the other process to finish where possible.
- Source: https://docs.unity.com/hub/install-hub-linux

