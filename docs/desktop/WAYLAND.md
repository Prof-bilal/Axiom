# Wayland integration boundaries

Status: V1 baseline; individual backend support requires experiments. Last researched: 2026-10-18.

Use Plasma 6/KWin on Wayland. Do not grant global input capture, arbitrary screen reading or compositor internals solely to automate desktop actions. XWayland compatibility must not become the security architecture.

| Need | Preferred mechanism | Required proof |
|---|---|---|
| Launch application | desktop application IDs / desktop activation | ID validation; no shell expansion |
| File selection | FileChooser/document portals | Scope returned resources, handle revoked access |
| Screen sharing | ScreenCast portal with PipeWire | Visible consent, selection, stop/revocation |
| Remote input | RemoteDesktop portal where supported | Explicit session consent, revocation and lock behavior |
| Global shortcut | GlobalShortcuts portal/backend or supported KDE facility | Conflict handling and per-session scope |
| Window/workspace control | Supported KWin scripting/API extension | Narrow operations, version compatibility, no arbitrary script upload |
| Accessibility | Appropriate accessibility APIs | Consent/privacy review; do not treat accessibility as unrestricted agent access |

Portals are permission interfaces, not a universal automation API. Backend capabilities and protocol versions differ; test xdg-desktop-portal-kde against the pinned Plasma version. Denial or absence returns a typed unsupported/denied error; do not fall back to hidden capture or synthetic input. KWin scripts are compositor extensions with substantial trust and require packaged, reviewed code.

Experiments: screen-sharing stop on lock/logout; mixed-DPI capture; shortcut collisions; disconnected portal; cancelled chooser; monitor removal; malicious window title; and agent attempts to approve its own authorization UI. Content captured from windows/files remains untrusted model input. Session permissions do not authorize separate system changes.

Sources: [Wayland architecture](https://wayland.freedesktop.org/docs/html/), [XDG Desktop Portal](https://flatpak.github.io/xdg-desktop-portal/docs/), [KWin scripting](https://develop.kde.org/docs/plasma/kwin/). See [permissions](../security/PERMISSIONS.md).
