# Wireshark (wireshark)

Status: unverified this session.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Arch repos | `sudo pacman -S wireshark-qt` | yes | yes | Unverified. |
| Debian/Ubuntu | `sudo apt install wireshark` | yes | yes | Asks whether non-root users may capture. |
| Fedora | `sudo dnf install wireshark` | yes | yes | |
| Flatpak | `flatpak install flathub org.wireshark.Wireshark` | no (`--user`) | yes | Flatpak capture needs extra setup (unverified). |

## Manual install
Not needed.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| `You don't have permission to capture on that device` | Non-root user not in wireshark group. | `sudo usermod -aG wireshark $USER` then re-login. Capture rights are powerful; grant only if needed. |
| No interfaces listed | Capture permissions. | Same as above, or run `dumpcap` setup (unverified). |

## Sources
- https://www.wireshark.org/download.html (unverified this session)
