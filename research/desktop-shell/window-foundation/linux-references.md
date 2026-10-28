# Linux implementation references

Inspected 2026-10-28:

| Source | Version/license | Finding |
| --- | --- | --- |
| Quickshell src/wayland/hyprland/ipc/{connection,hyprland_toplevel,qml}.cpp | v0.3.2, LGPL-3.0-only | Existing event-driven compositor models and address/Wayland mapping; reuse |
| Installed Quickshell Hyprland/_Ipc and Wayland/_ToplevelManagement qmltypes | 2b4501a host build | Confirm available properties/signals against shipped package |
| Omarchy shell/services/AppLibrary.qml | v4.0.6, MIT | Uses DesktopEntries/ToplevelManager and launch feedback; application count alone does not identify a particular window |
| Omarchy config/hypr/hyprland.lua | v4.0.6, MIT | Session bootstrap loads defaults then user overrides; no host edit required for read-only diagnostics |

Quickshell source: https://github.com/quickshell-mirror/quickshell/tree/v0.3.2/src/wayland/hyprland/ipc

Omarchy source: https://github.com/omacom/omarchy/tree/237f1b4071a0bff2296c6d740ba2b9fd695ebfa0/shell

No source code is copied. KDE/GNOME/COSMIC references will be inspected where
their service boundaries answer a concrete later feature question; they have
not been represented as inspected here.
