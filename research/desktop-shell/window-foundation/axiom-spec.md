# 3.1 Window foundation specification

Status: VALIDATION; acceptance not yet established.

Reference: macOS observable window/app distinction and Linux compositor APIs.

Evidence: [evidence](evidence.md) and [source inspection](linux-references.md)
establish real native window/workspace/monitor models; public documentation is
not runtime validation.

Linux implementation: reuse Quickshell's event-driven Hyprland and Wayland
objects. Keep transport health and target lifetime explicit.

Axiom decision: one shared read-only WindowState first; later narrow actions
must target a still-live object, expose requested/confirmed/failed outcomes,
and never fall back to whichever window currently has focus. No generic dispatch
interface for external callers. No fake state to make a visual render.

Reason: controls, Dock and overview need the same window identity and lifecycle.
Reliability is a prerequisite for appearance and interaction work.

Difference: Hyprland remains a tiling compositor; maximize is distinct from
fullscreen, minimize requires a proven Linux policy, and original Axiom controls
do not attempt to replace every application's client-side decoration.

Acceptance: live counts match independent compositor queries; open/close/focus
events propagate; same-app windows stay distinct; absent backend exposes empty
unavailable state; disconnect invalidates targets; no host/window/config
mutation; QML load/lint pass. Real guest failure, multi-monitor and performance
evidence are required before marking 3.1 COMPLETE or proceeding to visible work.
