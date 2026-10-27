# Wayland integration boundaries

Status: V1 baseline re-scoped to a Hyprland/Quickshell session (ADR-013); individual backend support requires experiments. Last researched: 2026-10-27.

Use Hyprland as the compositor on Wayland and Quickshell for shell surfaces. Do not grant global input capture, arbitrary screen reading or compositor internals solely to automate desktop actions. XWayland compatibility must not become the security architecture.

| Need | Preferred mechanism | Required proof |
|---|---|---|
| Launch application | desktop application IDs / desktop activation via Hyprland exec or systemd | ID validation; no shell expansion |
| File selection | FileChooser/document portals | Scope returned resources, handle revoked access |
| Screen sharing | ScreenCast portal with PipeWire | Visible consent, selection, stop/revocation |
| Remote input | RemoteDesktop portal where supported | Explicit session consent, revocation and lock behavior |
| Global shortcut | Hyprland global shortcuts protocol (`hyprland-global-shortcuts-v1`) or the GlobalShortcuts portal | Conflict handling and per-session scope |
| Window/workspace control | Hyprland IPC (`hyprctl` request/event sockets) and Quickshell's `Quickshell.Hyprland` module | Narrow operations, version compatibility, no arbitrary script upload |
| Shell surfaces | Quickshell layer-shell (`PanelWindow`, `FloatingWindow`, `WlrLayershell`) | Workspace/monitor correctness, lock behavior, no compositor bypass |
| Screenshots/recording | Hyprland screencopy permission + Quickshell `ScreencopyView` or portal | Permission ASK/deny honored; no silent capture fallback |
| Accessibility | Qt accessibility (AT-SPI) and Quickshell `Accessible` properties | Consent/privacy review; do not treat accessibility as unrestricted agent access |

Hyprland permissions default several capabilities to ASK (screencopy, input capture, cursor position, plugin load). Axiom must not change those defaults to make a feature pass. Portals are permission interfaces, not a universal automation API. Denial or absence returns a typed unsupported/denied error; do not fall back to hidden capture or synthetic input. Quickshell executes arbitrary QML/processes as the user and is treated as trusted shell code, never as a sandbox.

Experiments: screen-sharing stop on lock/logout; mixed-DPI capture; shortcut collisions; disconnected portal; cancelled chooser; monitor removal; malicious window title; lock/shell crash isolation; and agent attempts to approve its own authorization UI. Content captured from windows/files remains untrusted model input. Session permissions do not authorize separate system changes.

Sources: [Hyprland wiki](https://wiki.hypr.land/), [Quickshell docs](https://quickshell.org/docs/), [XDG Desktop Portal](https://flatpak.github.io/xdg-desktop-portal/docs/). See [permissions](../security/PERMISSIONS.md), [migration report](../engineering/OMARCHY_MIGRATION.md).
