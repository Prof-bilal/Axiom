# Axiom design direction

Status: Phase 0 design contract. Axiom is a mature, minimal, developer-focused
desktop—not a macOS clone, a KDE theme or a toy UI. The visible product must
use real system state and real actions; prototypes are references only and
never satisfy a graphical phase gate.

The implemented Axiom desktop identity (palette, states, panel, dock, menus,
terminal, window rules, marks, responsive rules) is specified in
[DESKTOP_DESIGN](DESKTOP_DESIGN.md). The detailed desktop contract lives in [desktop UX](desktop/DESKTOP_UX.md),
[design tokens](desktop/DESIGN_SYSTEM.md) and [Wayland boundaries](desktop/WAYLAND.md).
The initial visual language is calm dark/light surfaces, restrained accent
color, readable typography, consistent iconography and deliberate motion. Keep
tokens semantic so the shell toolkit can change without rewriting product
behavior.

Design acceptance includes keyboard-only completion, visible focus, screen-reader
names, 200% text scaling, reduced motion, mixed DPI, multi-monitor layouts,
offline operation and truthful failure states. Avoid oversized rounded cards,
neon gradients, ornamental blur, fake app icons, hidden state and animation
that delays work.

**Phase 3 status:** the token layer is implemented in
[`shell/src/shared/Theme.qml`](../shell/src/shared/Theme.qml) (palette from
`branding/theme/axiom/colors.toml`, spacing/radius/type/motion scales). Surfaces
consume tokens rather than literals. Motion is limited to short hover feedback
(≤120 ms); no animation precedes correctness. Accessibility/DPI review of the
live surfaces is **not yet measured** (see
[performance](research/phase3/performance.md)).
