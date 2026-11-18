# ADR 031: Hyprland becomes the default session compositor

Status: Proposed. Amends ADR-016 (labwc harness). Not yet the default: the ISO still
starts labwc until the opt-in test passes in QEMU (see Verification).

## Context
- labwc draws server-side title bars and rounds only their top corners. It cannot clip
  client-side windows (Electron, Chromium, GTK4), so those windows stay square.
- The user wants rounded corners on every window and animations across the desktop.
- Hyprland rounds all windows through `decoration.rounding`, including client-side ones,
  and animates windows, workspaces and layers. Axiom already ships a Hyprland config
  (`iso/phase3/airootfs/etc/axiom/hypr/hyprland.lua`) that is opt-in through
  `/etc/axiom/compositor`.
- Hyprland draws no title bar. The user chose no title bar buttons; close, minimise and
  maximise are keyboard-only (Super+Q, Super+M, Super+H, Alt+F4).

## Decision
1. Hyprland (BSD-3-Clause, installed from the Arch repositories, pinned to the version
   tested) becomes the default session compositor, after the opt-in test passes.
2. labwc stays installed as the automatic fallback in `axiom-session`, so a machine
   where Hyprland cannot start still gets a desktop.
3. Rounded corners: `decoration.rounding = 16` (Theme.radiusWindow), applied to every window.
4. Window animations belong to Hyprland (open, close, workspaces, borders). The shell keeps
   only the overlays Hyprland cannot draw (window switcher, OSD, capture bar). One owner per motion.
5. No blur (user decision). Title bar buttons: none.
6. The shell stays compositor-neutral: IPC calls, WindowService and WorkspaceService are unchanged.

## Alternatives considered
- Keep labwc and accept square client windows: rejected, the user requires rounded corners everywhere.
- Build a custom compositor: rejected for now. It is a multi-month project with no rounding
  advantage over Hyprland (see the compositor research in the axiom-compositor project).
- Patch wlroots/labwc to clip windows: rejected for now; it needs a custom GLES2 render pass
  and is weeks of work with a software-renderer fallback cost.

## Consequences
- Hyprland uses more GPU and RAM than labwc. Measure before switching the default.
- The Hyprland config API changes between versions; the version is pinned.
- Title bar buttons under Hyprland are absent; Axiom apps keep their in-app header.

## Verification
- Headless Hyprland (no ISO): foot, Files and an Electron app; screenshot shows rounded
  corners on client-side windows; shell loads with no QML errors.
- ISO built with `AXIOM_COMPOSITOR` opt-in, booted in QEMU: `tests/phase3-desktop.py`
  passes, with serial and screenshot evidence kept.
- Default switch only after the QEMU pass; labwc fallback tested by forcing a Hyprland failure.
