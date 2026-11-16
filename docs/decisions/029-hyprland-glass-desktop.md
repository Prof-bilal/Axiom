# ADR 029: Hyprland replaces labwc for the glass desktop (superseded)

**Date:** 2026-11-15
**Status:** Superseded on 2026-11-16 by [ADR-016](016-labwc-compositor-harness.md) (amended).
The product owner dropped blur and glass for solid surfaces, which removed this ADR's main reason.
Hyprland stays in the ISO as an opt-in compositor (`/etc/axiom/compositor` = `hyprland`) but is
no longer the default, and the shell no longer depends on it.

## Context
The new visual direction (23 reference screens in `branding/reference/glass/`) is glassmorphism:
frosted translucent surfaces with backdrop blur, a cyan-to-amber gradient edge, large radii and
floating panel and dock. labwc cannot blur what is behind a surface (ADR-016 and DESKTOP_DESIGN say
so), so the look cannot be built on it. The reference set also shows screens Axiom does not have:
screenshot tool, OSDs, window switcher, snap preview, System Monitor, polkit dialog, file-open dialog,
desktop and file context menus.

## Options
| Option | Backdrop blur | Cost |
| --- | --- | --- |
| Keep labwc, translucent surfaces only | No | None; look is tinted, not frosted |
| labwc built with scenefx | Yes | Custom compositor package to maintain |
| **Hyprland** | **Yes, plus rounding, shadows, gradient borders, animations, layer blur rules** | **Session, config and window services ported; GL renderer** |

## Decision
Move the user session to Hyprland (official Arch package). The compositor is still a replaceable
harness, not the product contract.

- Session: `axiom-session` starts Hyprland (through `start-hyprland`) with
  `/etc/axiom/hypr/hyprland.lua`; the shell is started from that config. Keybinds are ported from
  `/etc/axiom/labwc/rc.xml`. Hyprland 0.56 configuration is Lua.
- Fallback: if Hyprland is not installed, if `/etc/axiom/compositor` contains `labwc`, or if Hyprland
  stops within 15 s of starting, `axiom-session` starts the labwc session instead and writes
  `AXIOM_COMPOSITOR_FALLBACK labwc` to the serial console.
- Software GL is forced only inside a virtual machine; on real hardware Hyprland uses the GPU.
- Blur is done by the compositor only: window blur plus `layerrule` blur for the Quickshell layer
  namespaces. QML surfaces stay plain translucent rectangles (`GlassSurface`); no blur shaders in QML.
- Window chrome: Hyprland has no server-side title bar with buttons. Axiom apps draw their own title
  bar (traffic lights, centred title) in QML. Third-party apps and foot keep their own client-side
  decorations. This is a loss against ADR-016, which gave every window the same title bar.
- Workspaces and windows: checked against Hyprland 0.56.2 with Quickshell 0.3.2. Foreign-toplevel
  lists windows, so `WindowService` is unchanged. `ext-workspace-v1` lists workspaces but reports
  `canActivate` false, so `WorkspaceService` keeps the protocol for state and switches workspaces
  through Hyprland IPC when the protocol refuses.
- Not ported: minimize (Super+H parks the window on a hidden workspace instead), Alt+Shift+Tab, the
  labwc desktop right-click menu, and the labwc window switcher OSD.
- The greeter keeps its own minimal labwc session (ADR-024). It does not need blur to work.
- Design rules that change: DESKTOP_DESIGN lists blur as something to avoid and says orange is never
  decoration. The glass edge uses a cyan-to-amber gradient. DESKTOP_DESIGN is updated in the same
  change that restyles the first shipped surface.
- A "reduce transparency" setting turns glass fills opaque and blur off. Required for accessibility and
  for machines without usable GL.

## Consequences
- Hyprland needs GLES. QEMU evidence runs need virtio-gpu with GL, or llvmpipe, which may be slow.
  ADR-016 rejected Hyprland partly for this; it is the main risk.
- Larger and faster-moving compositor than labwc: more code in the session's trust boundary, more
  config churn across releases. No new privileged component; the UI still never runs as root.
- D3 Zones (generated labwc regions) must be redesigned on Hyprland layouts.
- No performance claim is made. Blur cost is measured before any is.

## Verification (not yet done)
- Boot the ISO in QEMU with Hyprland; retain serial, journal and screenshots.
- Rerun the Phase 3 to 7 drivers on that ISO.
- Measure idle CPU and frame time with blur on and off, on GL and on llvmpipe.
- Confirm the session falls back cleanly when GL is missing.

## Rollback
The labwc config, theme and session path stay in the tree until this ADR is accepted. Rollback is
pointing `axiom-session` back at `labwc -C /etc/axiom/labwc`. `GlassSurface` works on labwc as a
tinted surface without blur.

Related: [[016-labwc-compositor-harness]], [[024-graphical-greeter]].
