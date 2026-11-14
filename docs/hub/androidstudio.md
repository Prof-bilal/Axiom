# Android Studio

- Id: `androidstudio` · Category: Development · Weight: heavy · Licence (catalog): Apache-2.0
- Catalog sources: flatpak `com.google.AndroidStudio`
- Install verified: yes · Screenshots: 5 of 3 · Logo: yes

## Overview
Android Studio is Google's official IDE for building Android apps, built on the IntelliJ platform. It is aimed at Android developers and includes the Android SDK tooling, emulator and build system.

## Facts
- Name: Android Studio
- Publisher: Google
- Official website: https://developer.android.com/studio
- Licence: not found in this research (Android Studio is distributed under Google's Android Studio terms, which were not fetched)
- Latest version: Android Studio Rabbit 2 | 2026.2.2 Patch 1, seen 2026-11-13. Source: https://developer.android.com/studio
- Release date: not found (page shows only "April 28, 2026" in the licence text)
- Typical install size: Linux download 1.6 GB, seen 2026-11-13. Source: https://developer.android.com/studio
- Minimum RAM: 8 GB for Studio alone; 16 GB for Studio plus emulator (per search results for the official install page; not re-fetched). Source: https://developer.android.com/studio/install?authuser=0
- CPU: not found
- Disk: 8 GB free for Studio alone; 16 GB for Studio and emulator (per search results for the official install page). Source: https://developer.android.com/studio/install?authuser=0

Flathub data (https://flathub.org/api/v2/appstream/com.google.AndroidStudio):
- Flatpak id: `com.google.AndroidStudio` · Developer: Android Open Source Project · Licence: LicenseRef-proprietary=https://developer.android.com/studio/terms
- Latest version on Flathub: 2026.2.2.9 (released 2026-11-05)

## Logo
Bundled icon: `apps/hub/icons/androidstudio.png`.
Official logo: https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/com.google.AndroidStudio.png (verified-200).

## Screenshots
![Android Studio Showing the structure of a project](https://dl.flathub.org/media/com/google/AndroidStudio/14c79cfed9911ddb77b23429977e485e/screenshots/image-1_orig.png)
![Try Gemini in Android Studio](https://dl.flathub.org/media/com/google/AndroidStudio/14c79cfed9911ddb77b23429977e485e/screenshots/image-2_orig.png)
![Intelligent code editor](https://dl.flathub.org/media/com/google/AndroidStudio/14c79cfed9911ddb77b23429977e485e/screenshots/image-3_orig.png)
![Flexible build system](https://dl.flathub.org/media/com/google/AndroidStudio/14c79cfed9911ddb77b23429977e485e/screenshots/image-4_orig.png)
![Easily emulate any device](https://dl.flathub.org/media/com/google/AndroidStudio/14c79cfed9911ddb77b23429977e485e/screenshots/image-5_orig.png)
Source: https://flathub.org/api/v2/appstream/com.google.AndroidStudio

- ![Android Studio hero image](https://developer.android.com/static/images/studio/studio-hero-image.png) Caption: official hero image (marketing graphic, not a UI capture). Source: https://developer.android.com/studio
- ![Flexible build system](https://developer.android.com/static/images/studio/flexible-build-system.png) Caption: build system graphic from the official page. Source: https://developer.android.com/studio
- ![APK and App Bundle Analyzer](https://developer.android.com/static/images/studio/apk-bundle-analyzer.png) Caption: APK/App Bundle Analyzer graphic from the official page. Source: https://developer.android.com/studio

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Flatpak (community build, unverified) | `flatpak install flathub com.google.AndroidStudio` | no |
| Official tarball | `download Linux (64-bit) from https://developer.android.com/studio` | no |

- The Flathub package is community-made and unverified; it wraps Google's tarball.

- Source: https://wiki.debian.org/AndroidStudio
- Source: https://flathub.org/fr/apps/com.google.AndroidStudio/install

## Install options (research draft; verified for the three methods named by search results (official tarball, Snapcraft, Flathub community package). Commands unverified beyond those names.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Official tarball | download from https://developer.android.com/studio, extract to `/opt`, run `/opt/android-studio/bin/studio.sh` | extract to /opt: yes; ~/.local/opt: no | yes | Google's official build. Updates via Help > Check for Update. Recommended. |
| Snap (snapcrafters) | `sudo snap install android-studio --classic` | yes | yes | Requires snapd. Updates via `sudo snap refresh android-studio`. |
| Flatpak (community) | `flatpak install flathub com.google.AndroidStudio` | no (`--user`) | yes | Community wrapper around the tarball, not built by Google. Update via `flatpak update com.google.AndroidStudio`. |

Note: Android SDK and emulator need KVM. Check `/dev/kvm` access (`ls -l /dev/kvm`); the user must be in the `kvm` group (`sudo usermod -aG kvm $USER`, root, re-login).

## Manual install (draft)
1. Download `android-studio-<version>-linux.tar.gz` from https://developer.android.com/studio.
2. `sudo tar -xzf ~/Downloads/android-studio-*-linux.tar.gz -C /opt` (root needed for /opt).
3. Run `/opt/android-studio/bin/studio.sh`.
4. Check: the setup wizard starts and downloads the SDK to `~/Android/Sdk`.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| Emulator: `KVM is not available` / `/dev/kvm` permission denied | User not in kvm group. | `sudo usermod -aG kvm $USER`, then log out and in. |
| Emulator very slow | Hardware acceleration off. | Enable VT-x/AMD-V in BIOS; check `kvm-ok` or `lscpu`. |
| `Unable to access Android SDK add-on list` | Network or proxy. | Set proxy in Settings > Appearance & Behavior > System Settings > HTTP Proxy. |
| Low RAM, IDE freezes | Gradle daemon plus emulator. | Reduce `org.gradle.jvmargs` in `gradle.properties`; use fewer emulator RAM. |
| `studio.sh: Permission denied` | Not executable after extract. | `chmod +x /opt/android-studio/bin/studio.sh`. |
| Launcher icon missing for tarball install | Desktop entry not created. | Create one via Tools > Create Desktop Entry in the app. |

## Sources
- https://developer.android.com/studio
- https://developer.android.com/studio/install?authuser=0
- https://flathub.org/apps/com.google.AndroidStudio
- https://snapcraft.io/android-studio
- https://wiki.debian.org/AndroidStudio
