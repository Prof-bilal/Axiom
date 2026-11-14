# ADR 029: Glass design language with dark and light modes

Status: Accepted direction. Shell, Hub, greeter, boot, terminal and VT palette migrated; verified by static
checks and a QEMU boot (see Verification). Live switching of the compositor window theme is not done.

## Context
The reviewed UI mockups (dark glass, teal `#22d3ee` and amber `#f5a623`, gradient stroke, floating top bar
and dock) replace the earlier graphite palette. Several surfaces kept private copies of colours (Hub's own
orange palette, the greeter, Plymouth, foot, labwc, the VT palette). The desktop was also dark-only.

## Decision
- `branding/theme/axiom/colors.toml` stays the palette source. It gains `[window_controls]` and a hand-designed
  `[light]` table (the mockups show no light mode; teal and amber are darkened for AA contrast on white glass).
- `shell/src/shared/Theme.qml` exposes `dark` (Settings > Appearance: Dark, Light, Auto; Auto is light
  07:00-19:00) and every colour token follows it. `GlassPanel.qml` draws the translucent fill with the
  teal-to-amber stroke.
- `scripts/gen-labwc-theme.py` generates the `Axiom` and `Axiom-Light` labwc themes from the toml;
  `validate-repo.py` fails when they are stale.
- Hub reads `Theme` instead of its own palette; orange is no longer a Hub primary accent.
- Boot-time surfaces (Plymouth, syslinux, GRUB, greeter, TUI installer) are dark-only by design: they run
  before any user setting exists.

## Consequences
- Pixel values come from eyeballed 1024px mockups and need tuning on real displays.
- labwc cannot blur or draw gradient borders; glass is translucency only until a compositor change is
  justified in its own ADR.
- Changing the mode does not yet switch the labwc window theme or foot's colour scheme live.
- Canvas drawings in Hub do not repaint on a mode change.

## Verification
`python3 scripts/validate-repo.py`, `python -m pytest -q`, `node tests/apps/hub-logic.test.mjs`, then the
Phase 3 to 7 QEMU drivers on a rebuilt ISO with retained evidence.
