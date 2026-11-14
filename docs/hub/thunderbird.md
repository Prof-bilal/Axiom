# Thunderbird

- Id: `thunderbird` · Category: Internet · Weight: medium · Licence (catalog): MPL-2.0
- Catalog sources: flatpak `org.mozilla.thunderbird`
- Install verified: yes · Screenshots: 2 of 3 · Logo: yes

## Overview
Thunderbird is Mozilla's open-source email, calendar and contacts client. It is for users who want a desktop mail client with privacy and extension support.

## Facts
- Name: Mozilla Thunderbird
- Publisher: Mozilla / Thunderbird project
- Official website: https://www.thunderbird.net/
- Licence: Mozilla Public License (MPL); not confirmed from fetched sources in this pass. Verify at https://www.mozilla.org/MPL/
- Latest version: 153.0 ESR per a July 2026 Ubuntu Handbook article (single source, seen 2026-11-13). Source: https://ubuntuhandbook.org/index.php/2026/07/thunderbird-153-0-esr-released-with-dns-over-https-native-thundermail-services/
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Linux: no 32-bit x86 binaries from 153.0 onward. Install via thunderbird.net tarball, Flathub, or .deb. Source: https://support.mozilla.org/en-US/kb/installing-thunderbird-linux (search summary)

Flathub data (https://flathub.org/api/v2/appstream/org.mozilla.thunderbird):
- Flatpak id: `org.mozilla.thunderbird` · Developer: MZLA Technologies, part of the Mozilla Foundation · Licence: MPL-2.0
- Latest version on Flathub: 160.0 (released 2026-11-07)

## Logo
Bundled icon: `apps/hub/icons/thunderbird.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/org.mozilla.Thunderbird.png (verified-200).

## Screenshots
![Thunderbird screenshot 1](https://dl.flathub.org/media/org/mozilla/thunderbird/add6c1c4e3b479450e2da56d0ea792f9/screenshots/image-1_orig.png)
![Thunderbird screenshot 2](https://dl.flathub.org/media/org/mozilla/thunderbird/add6c1c4e3b479450e2da56d0ea792f9/screenshots/image-2_orig.png)
Source: https://flathub.org/api/v2/appstream/org.mozilla.thunderbird

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Flatpak (maintained by Thunderbird staff; Mozilla's preferred route) | `flatpak install flathub org.mozilla.thunderbird` | no |
| ESR channel | `flatpak install flathub org.mozilla.thunderbird_esr` | no |

- Flathub moved Thunderbird to the lowercase id org.mozilla.thunderbird; the old org.mozilla.Thunderbird is end-of-life and existing installs are rebased to org.mozilla.thunderbird_esr. Mozilla's support page still shows the old id.
- Distro packages can lag behind official releases, per Mozilla.

- Source: https://support.mozilla.org/kb/installing-thunderbird-linux
- Source: https://flathub.org/api/v2/appstream/org.mozilla.thunderbird

## Install options (research draft; unverified this session.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S thunderbird` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install thunderbird` | yes | yes | Ubuntu may use snap (unverified). |
| Flatpak | `flatpak install flathub org.mozilla.Thunderbird` | no (`--user`) | yes | ID unverified. |

## Manual install (draft)
Not needed.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| Profile locked | Another instance. | Close it. |
| OAuth sign-in fails | Browser portal. | Check default browser setting (unverified). |

## Sources
- https://support.mozilla.org/en-US/kb/installing-thunderbird-linux
- https://ubuntuhandbook.org/index.php/2026/07/thunderbird-153-0-esr-released-with-dns-over-https-native-thundermail-services/
- https://www.thunderbird.net
- https://www.thunderbird.net/
