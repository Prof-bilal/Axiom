---
name: shell-ui
description: "Build and test Axiom Shell surfaces against the owned session contracts and design tokens."
---

# shell-ui

Use for Axiom Shell work: panel, dock, launcher, workspaces, notifications,
control center, lock and session surfaces. The shell toolkit is replaceable;
do not assume Omarchy, Hyprland, KDE or a browser prototype is the product.

Read [architecture](../../../docs/ARCHITECTURE.md), [design](../../../docs/DESIGN.md),
[desktop UX](../../../docs/desktop/DESKTOP_UX.md), [Wayland boundaries](../../../docs/desktop/WAYLAND.md)
and [testing](../../../docs/TESTING.md). Define the real system contract,
keyboard/accessibility behavior, monitor/DPI behavior, focus ownership and
failure/restart behavior before editing a surface.

Keep shell code unprivileged. Use supported Wayland protocols and portals,
preserve consent and lock behavior, avoid fake state and screenshot-only
components, and measure idle cost and interaction latency in QEMU when the
phase requires it.
