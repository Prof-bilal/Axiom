# Axiom desktop experience

Status: Phase 0 product contract; no shell implementation is active.

Axiom should feel mature, minimal, high-quality, developer-focused, responsive,
fast, calm and functional. It is not a macOS clone, cartoonish widget set,
neon dashboard, KDE/GNOME extension pack or browser mock. Borrow interaction
principles only when they solve a user problem, then express them through
Axiom's own information architecture and tokens.

## Shell surfaces

- **Top panel:** current workspace/session state, time, connectivity, audio,
  power and a stable route to the Control Center.
- **Dock:** real application launch/switch state, pinned entries and clear
  running indicators; no placeholder icons or hardcoded app counts.
- **Launcher:** searchable desktop entries, files and later approved actions;
  keyboard-first and useful offline.
- **Workspace UI:** real compositor/session state, predictable focus and
  keyboard shortcuts; no duplicate window manager hidden in the shell.
- **Notifications:** untrusted content rendered safely, actionable only with
  explicit user intent, and recoverable after shell restart where appropriate.
- **Control Center:** device/session settings backed by real services, with
  unknown/unsupported/error states visible.
- **Lock/login/session:** trusted, unprivileged presentation with a clear
  boundary from model-authored content and shutdown/reboot authorization.

## Acceptance journeys

Boot, login, launch a real app, switch workspaces/apps, open the launcher, use
the dock, inspect a notification, change a supported setting, lock/unlock, and
logout/reboot. Repeat keyboard-only, screen-reader naming, reduced-motion,
offline, denied-permission, shell-restart and monitor/DPI scenarios in QEMU.

The shell observes session/service contracts; it does not invent windows,
timers, system state, permissions or recovery guarantees. Core desktop journeys
must work without AI, cloud access or a network connection.
