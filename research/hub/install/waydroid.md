# Waydroid install guide

Status: Partially verified: the Debian/Ubuntu, Fedora, Void, init, container, session and APK commands are on official docs pages, but none were run on a machine here; the Arch install has no official command.


## Install options

| Method | Command | Needs root | Verified? |
|---|---|---|---|
| Debian/Ubuntu | `sudo apt update` then `sudo apt install waydroid -y` | Yes | Verified: https://docs.waydro.id/usage/install-on-desktops.md |
| Fedora (dnf) | `sudo dnf install waydroid` | Yes | Verified: https://docs.waydro.id/usage/install-on-desktops.md |
| Fedora Immutable | `rpm-ostree install waydroid` | Not shown on page (no sudo shown) | Verified: https://docs.waydro.id/usage/install-on-desktops.md |
| Void Linux | `sudo xbps-install -S waydroid` | Yes | Verified: https://docs.waydro.id/usage/install-on-desktops.md |
| Arch Linux | No command on official page (points to Arch wiki) | n/a | Not verified |
| Initialise image | `sudo waydroid init` (`-s VANILLA`, `FOSS` or `GAPPS`; default VANILLA) | Yes | Verified: https://docs.waydro.id/usage/waydroid-command-line-options.md |
| Start container | `sudo waydroid container start` | Yes | Verified: https://docs.waydro.id/usage/install-on-desktops.md |
| Start session | `waydroid session start` (run without sudo) | No | Verified: https://docs.waydro.id/usage/install-on-desktops.md |
| Install APK | `waydroid app install xyz.apk` | Not stated | Verified: https://docs.waydro.id/usage/install-and-run-android-applications.md |

## Possible errors and fixes

**Error: `dnsmasq cannot open pid file`** (container fails to start)
- Cause: AppArmor may block dnsmasq from the Waydroid run directory (official page says "one possible cause").
- Fix: add to `/etc/apparmor.d/usr.sbin.dnsmasq` or `/etc/apparmor.d/local/usr.sbin.dnsmasq`:
  `@{run}/waydroid-lxc/ r,` and `@{run}/waydroid-lxc/* rw,`
- Source: https://docs.waydro.id/debugging/known-issues.md

**Symptom: garbled or flickering display**
- Cause: systems with dual GPUs (per official known-issues page).
- Fix: the official page only names a community script, `waydroid-choose-gpu.sh` from the Quackdoc/waydroid-scripts repository, and says it is not an official fix. Official fix: Not found.
- Source: https://docs.waydro.id/debugging/known-issues.md

**Symptom: container fails to start after upgrading to Android 13**
- Cause: the home directory filesystem must support ACLs; BTRFS mounted with `noacl` (for example an encrypted systemd-homed directory) breaks this.
- Fix: make sure the BTRFS volume is not mounted with `noacl`. If using systemd-homed, create `/etc/systemd/system/systemd-homed.service.d/btrfs-acl.conf` containing `[Service]` and `Environment=SYSTEMD_HOME_MOUNT_OPTIONS_BTRFS=acl,compress=zstd:1,user_subvol_rm_allowed`.
- Source: https://docs.waydro.id/debugging/known-issues.md

