# ADR 028: Debian packages install inside a rootless container (click-to-install)

Status: Accepted direction for Phase 7. Implemented and unit-tested; the container path has not been run
in QEMU yet (see Verification).

## Context
Users download `.deb` files and expect "double-click, small progress window, done". The Axiom image is
Arch-based (pacman), so `dpkg -i` or `apt` on the host is wrong: it would put a second package manager's
files into a system that tracks files with pacman. The existing options are worse. `debtap` converts a
package and often breaks dependencies. Unpacking with `dpkg-deb -x` is not an install: nothing is
registered and nothing updates.

## Decision
Install a `.deb` inside a rootless `distrobox` container named `axiom-debian` (image
`docker.io/library/debian:stable`, created on first use). The package is staged under
`~/.cache/axiom-debs/`, installed with `apt-get install -y <file>` inside the container, and its launcher
is exported to the user's menu with `distrobox-export --app <package>`.

- Everything runs as the desktop user. No new privileged component, no new daemon (podman is daemonless).
- Every command is an argv array run without a shell. The package name read from the file is checked against
  the Debian name pattern before it is used. The staged file name is sanitised.
- One click path: the file handler `axiom-quickinstall.desktop` (`axiom-app quickinstall <file>`) opens a
  small progress window (`apps/appinstaller/QuickInstall.qml`) for AppImage, Flatpak and `.deb` files.
  Arch packages keep the polkit prompt and `axiom-pkgd`. The Hub's own install page and the App Installer
  window use the same `InstallFile.qml` code.
- ISO: adds the `distrobox` and `podman` packages.

## Consequences
- The first `.deb` install needs network and downloads a Debian image. The window says so.
- A `.deb` app lives in the container: it sees the user's home folder (distrobox default) but not the Arch
  system, and it does not appear in `pacman -Q`.
- Rootless podman needs subordinate uid/gid ranges for the live user. This is the part most likely to need
  work in the image (see Verification).
- Packages without a desktop file (libraries, command-line tools) install but get no launcher. The window
  says so.

## Verification (not yet done)
- Boot the ISO in QEMU, double-click a `.deb`, confirm the container is created, the app installs, and its
  launcher appears. Record the evidence under the Phase 7 notes.
- Check `/etc/subuid` and `/etc/subgid` for the live user, and that podman runs rootless there.

## Rollback
Remove the `axiom-quickinstall.desktop` associations from `mimeapps.list` and the `deb` kind from
`apps/appinstaller/installfile.js`; AppImage and Flatpak installs are unaffected. Remove the container with
`distrobox rm axiom-debian`.

Related: [[026-installer-privilege]].
