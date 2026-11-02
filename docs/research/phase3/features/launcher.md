# Application launcher

## Goal

Discover and launch real installed applications, keyboard-first, using Linux
standards (`.desktop` entries, XDG data dirs), with real icons and search.

## Projects Studied

COSMIC (`cosmic-launcher` + `pop-launcher`), Quickshell (`DesktopEntries`),
freedesktop Desktop Entry Spec and Icon Theme Spec.

## Important Source Files

- COSMIC: `cosmic-launcher/src/subscriptions/launcher.rs` (search delegated to
  `pop-launcher`), `src/app.rs` (load entry, Wayland activation token,
  `cosmic_launch::spawn`), icon resolution via `IconSource::{Name,Mime}`.
- Quickshell: `src/core/desktopentry.cpp` (`DesktopEntries` manager,
  `DesktopEntry` with `id`/`name`/`icon`/`command`/`startupClass`/`noDisplay`/
  `runInTerminal`/`categories`/`keywords`/`execute()`).

## Runtime Behavior

- Entries are discovered under each `XDG_DATA_DIRS` path's `applications/`
  directory and `~/.local/share/applications`, parsed, and filtered
  (`Type=Application`, `NoDisplay=true` hidden).
- Launching uses the parsed `Exec` with field-code expansion (`%f %F %u %U %i
  %c %k`), stripping `%` codes for omitted files/URLs. Correct Wayland launch
  also passes an activation token so the compositor focuses the new window.
- Icons are resolved by name through the icon theme (hicolor fallback), not by
  a hard-coded path.

## REA Findings

Not required; entry parsing and icon lookup are specified by the freedesktop
specs and visible in source.

## IPC / Protocols

XDG desktop entries and XDG data dirs; icon theme spec; `XDG_ACTIVATION_TOKEN`/
`DESKTOP_STARTUP_ID` for activation; optional DBus activation
(`DBusActivatable=true`).

## Dependencies

A desktop-entry parser; an icon theme; a launcher (session/glib).

## Good Design Decisions

- Delegate search to a dedicated engine (COSMIC → `pop-launcher`) so the UI only
  renders results and stays responsive.
- Request an activation token at launch so focus lands on the new window.
- Resolve icons by name with a documented fallback.

## Problems / Tradeoffs

- `Exec` field codes are easy to get wrong; a session launcher (`gio launch`) is
  safer than hand-splitting.
- Search quality/ranking is a product surface that a raw substring match does
  not solve.

## License Notes

COSMIC launcher GPL-3.0-only (reference). Quickshell LGPL-3.0-only.

## What Axiom Should Reuse

- XDG desktop-entry discovery and icon-theme resolution.
- Activation-token-aware launching.

## What Axiom Should Reimplement

- The launcher UI and ranking; later, an Axiom search index (Phase 5).

## What Axiom Should Avoid

- Copying COSMIC/pop-launcher code and its pop-launcher process dependency.
- Parsing `Exec` by naive string splitting in UI code.

## Final Axiom Design

- `ApplicationService` (singleton) wraps Quickshell `DesktopEntries`: lists
  visible entries, ranks by prefix/name match, resolves icons via
  `Quickshell.iconPath`, and launches via `DesktopEntry.execute()`.
- `src/launcher/Launcher.qml`: an Overlay-layer `PanelWindow` with a scrim, a
  `TextInput`, a keyboard-navigable `ListView` of real entries; Enter launches,
  Esc closes, Up/Down navigate; clicking outside closes. Opened by `$mod+d`
  (sway binding → `qs ipc -p /usr/local/share/axiom/shell call axiom toggleLauncher`; a bare `qs ipc call` cannot find the instance).
