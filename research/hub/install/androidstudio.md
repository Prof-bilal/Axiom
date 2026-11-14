# Android Studio (androidstudio)

Status: verified for the three methods named by search results (official tarball, Snapcraft, Flathub community package). Commands unverified beyond those names.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Official tarball | download from https://developer.android.com/studio, extract to `/opt`, run `/opt/android-studio/bin/studio.sh` | extract to /opt: yes; ~/.local/opt: no | yes | Google's official build. Updates via Help > Check for Update. Recommended. |
| Snap (snapcrafters) | `sudo snap install android-studio --classic` | yes | yes | Requires snapd. Updates via `sudo snap refresh android-studio`. |
| Flatpak (community) | `flatpak install flathub com.google.AndroidStudio` | no (`--user`) | yes | Community wrapper around the tarball, not built by Google. Update via `flatpak update com.google.AndroidStudio`. |

Note: Android SDK and emulator need KVM. Check `/dev/kvm` access (`ls -l /dev/kvm`); the user must be in the `kvm` group (`sudo usermod -aG kvm $USER`, root, re-login).

## Manual install
1. Download `android-studio-<version>-linux.tar.gz` from https://developer.android.com/studio.
2. `sudo tar -xzf ~/Downloads/android-studio-*-linux.tar.gz -C /opt` (root needed for /opt).
3. Run `/opt/android-studio/bin/studio.sh`.
4. Check: the setup wizard starts and downloads the SDK to `~/Android/Sdk`.

## Possible errors and fixes

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
- https://wiki.debian.org/AndroidStudio
- https://snapcraft.io/android-studio (search result reference: snapcrafters package)
- https://flathub.org/apps/com.google.AndroidStudio
