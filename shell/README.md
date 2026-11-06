# Axiom Shell

Phase 3 Axiom Shell MVP: the desktop surfaces (panel, dock, launcher,
workspaces, notifications, status, session controls) implemented in
Quickshell/QML over the Axiom session services.

Run (development, needs a Wayland session):

```sh
qs -p shell            # or: quickshell -p shell
```

## Architecture

```text
shell.qml                     ShellRoot: instantiates every surface
src/
  shared/     Theme.qml (design tokens), UiState.qml (overlay state),
              AxiomIcon (system icon set), AppIcon, PanelButton,
              MenuSurface / MenuItem / MenuSeparator (menu primitives)
  desktop/    Wallpaper.qml
  panel/      Panel, WorkspaceIndicator, Clock, Tray, StatusIndicators
  menu/       AxiomMenu ("Axiom OS" menu)
  activities/ ActivitiesOverview (window overview)
  dock/       Dock, DockItem
  launcher/   Launcher
  notifications/ NotificationCard, NotificationCenter
  session/    SessionMenu
  status/     ControlCenter (status menu)
services/                     system boundaries (singletons); Phase 5 adds DisplayService, TimeService,
                              AccountService, KeyboardService (see ADR-019)
  ApplicationService  XDG desktop entries + launch
  WindowService       wlr-foreign-toplevel window state/actions
  WorkspaceService    workspaces via ext-workspace-v1 (Quickshell.WindowManager)
  NotificationService org.freedesktop.Notifications server
  PowerService        logind/systemd session + power actions
  SystemService       audio / network / Bluetooth / power state
  HostService         os-release + /proc identity for "About Axiom"
  SettingsService     per-user settings file (wallpaper, dock pins, text size), watched
  TerminalService     "open in terminal" for the apps, through axiom-terminal
apps/ (symlink)               core apps share this config root: see ../apps/README.md
assets/                       Axiom identity assets (penguin = OS, A-mark = product, wordmark, wallpaper)
tests/                        shell-level tests
```

### Boundaries (non-negotiable)

- **UI never performs privileged or compositor operations directly.** A surface
  calls a service; a service owns the protocol/API. `WorkspaceService` and
  `WindowService` are the only files that name a compositor protocol, so the
  temporary harness can be replaced by the Axiom compositor without touching UI.
- **No fake state.** Every value is read from a real service; unsupported state
  (no battery, harness ignoring a request) is reported, never invented.
- **Tokens, not literals.** Colors, spacing, radii, type and motion come from
  `src/shared/Theme.qml` (`branding/theme/axiom/colors.toml`). The visual
  contract is [docs/DESKTOP_DESIGN.md](../docs/DESKTOP_DESIGN.md).

### Relationship to the session

```text
Axiom session (iso/phase3) -> labwc (temporary harness, ADR-016) -> quickshell -> this shell
```

labwc keybindings (`/etc/axiom/labwc/rc.xml`) drive shell IPC (`qs ipc -p /usr/local/share/axiom/shell call axiom …`;
the session exports `QS_CONFIG_PATH` so a bare `qs ipc call` also works) for
the Axiom menu (Super+A), launcher,
notification centre, control centre and session menu.

### Known limitations (Phase 3)

- Single process: one Quickshell process hosts every surface, so killing it
  restarts all surfaces together (`axiom-shell` supervisor, which stops when
  the session ends).
- Window chrome (title bars, buttons, corners, glow) belongs to the compositor
  harness (labwc theme "Axiom"); the shell cannot decorate other apps.
- Quickshell is a replaceable dependency (LGPL-3.0-only); no third-party shell
  code is copied.
