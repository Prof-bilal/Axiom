# ADR 034: Flatpak apps in the Software Center

Status: Proposed. Phase 7 (package management). Implemented and unit-tested; QEMU verification pending.

## Context
The App Installer already installs a Flatpak bundle with `flatpak install --user`. The Software
Center shows only pacman packages, so Flatpak apps are not listed, updated or removed there.

## Decision
1. **User scope only.** Flatpak apps are installed, updated and removed with `--user`, so no
   root and no polkit prompt are needed.
2. **Remote:** `flathub` is the default remote. It is added with `flatpak remote-add --user --if-not-exists`
   the first time an app is installed from it. Other remotes are not added by the Software Center.
3. **Listing:** installed apps come from `flatpak list --app --user --columns=application,name,version`.
   Pending Flatpak updates come from `flatpak remote-ls --updates --user --columns=application`.
4. **Argv only:** every call is an argv array with fixed flags; an app id is checked against
   `^[A-Za-z0-9._-]+$` before it is used.
5. **Offline:** with no network, the update list is empty and the Software Center says so.

## Consequences
- Flatpak apps do not go through snapshots: a Flatpak update is per app and is removed by
  `flatpak uninstall` (its own rollback is `flatpak update --commit=<old>` and is not offered yet).
- The sandbox for Flatpak apps is Flatpak's own, which is stronger than the AppImage bubblewrap
  profile in ADR-032.

## Verification
- Argv builders and the id check are unit tested in `tests/apps/`.
- QEMU with network: install a Flatpak app from the Software Center, update it, remove it.
