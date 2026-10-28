# Axiom window-controls specification

Status: IMPLEMENTATION/VALIDATION for the smallest V1 slice; full feature
remains open until the matrix, accessibility and performance gates are exercised.

## V1

- Show an original Axiom control cluster on the active monitor using the
  preserved penguin asset, graphite surface and teal accent tokens.
- Expose close, minimize/restore and maximize/restore for the currently active
  native Wayland toplevel. Minimize is an explicit Axiom policy: park on
  `special:axiom-minimized` and restore to the recorded workspace.
- Use canonical native address identity and a single bounded action adapter.
- Show real app ID/title as plain text only when available; never use them as a
  selector or execute them.
- Show pending, verified, failed, unavailable and unsupported states.
- Keep the panel non-exclusive and avoid changing the target focus solely to
  operate a control.

## Deliberate differences

This is not a macOS clone. Axiom uses protocol-backed Linux state, explicit
failure text, compositor-specific limitations and original branding. It does
not copy Apple control glyphs, private behavior, assets or window-server
assumptions.

## Later

Keyboard-first global entry, browser/Electron matrix, richer fullscreen policy,
pointer target-isolation, multi-monitor placement, persistence across shell
restart and Dock integration remain later acceptance work. A feature is not
complete until those applicable tests and the performance record pass.
