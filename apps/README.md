# Axiom core apps

Phase 4 (see [PHASES](../docs/PHASES.md) and [ADR-017](../docs/decisions/017-core-app-runtime.md)).

Each app is a QML application hosted by its own Quickshell process. An app is a
small entry file at the shell config root (`shell/<app>.qml`) plus its code
here. They share one Quickshell config root with the shell so the design tokens
and components (`qs.src.shared`) are imported, not copied:

```text
shell/files.qml           entry (AppId org.axiom.Files)     imports qs.apps.files
shell/software.qml        entry (AppId org.axiom.Software)  imports qs.apps.software
shell/settings.qml        entry (AppId org.axiom.Settings)  imports qs.apps.settings
shell/apps -> ../apps     symlink: apps/ is part of the same config root
apps/shared/              AppWindow, AppButton, SearchField, ContextMenu, CommandRunner
apps/files/               Axiom Files    (files.js: pure logic, FileBackend.qml: all I/O)
apps/software/            Axiom Software (software.js, PackageBackend.qml)
apps/settings/            Axiom Settings (settings.js, one page per file; Phase 5 adds Network, Bluetooth,
                          Sound, Displays (writable), Power, Notifications, Keyboard, Date & time, Users)
```

Launched with `axiom-app <files|software|settings> [path-or-uri]`
(`/usr/local/bin/axiom-app`): a fixed list of names, one optional argument
handed over as `AXIOM_APP_ARG`. Apps run as the desktop user, never as root,
and do system work through argv-array processes (`find`, `gio`, `pacman`,
`cp`, `mv`, ...), never `sh -c` with user-controlled strings. The few constant
`sh -c` scripts receive paths as `$1`/`$2`.

| App | Does | Does not (yet) |
| --- | --- | --- |
| Files | browse, search, create, rename, copy/cut/paste, trash, restore, permanent delete with confirmation, properties, open with the default app, terminal here, remembers its last folder | drag and drop, thumbnails, mounting devices, undo (restore from Trash is the recovery path) |
| Software | installed applications and packages, search, filters, details, files, open in terminal | install, remove, update (need the permission layer), repository search (needs a database refresh) |
| Settings | About, Appearance (text size, wallpaper), Dock pins, Default apps; Phase 5: Network (Wi-Fi join/forget), Bluetooth, Sound, Displays (mode, scale, rotation with auto-revert), Power (profile, idle screen-off), Notifications (Do Not Disturb, per-app mute), Keyboard layouts, Date & time, Users (list) | create/remove users and change passwords (needs the Phase 6 privileged helper), live keyboard-layout switch (applies at next login) |

## Tests

```sh
node --test tests/apps/*.test.mjs          # pure logic, host only, no guest
tests/phase4-apps.py <iso>                 # real apps in QEMU: disk-verified results + evidence
```

Run during development (needs a Wayland session): `qs -p shell/files.qml`.
