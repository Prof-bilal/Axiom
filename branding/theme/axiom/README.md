# Axiom identity palette

Status: reviewed product asset (Phase 0/3); not a compositor or upstream-desktop
theme.

This directory preserves the original Axiom aurora wallpaper, palette and
identity previews as inputs to the Axiom design-token runtime. The files are
consumed by the Axiom Shell token layer, not installed through another desktop's
theme command.

`colors.toml` is the canonical Axiom palette (see
[DESKTOP_DESIGN](../../../docs/DESKTOP_DESIGN.md)). `icons/axiom-penguin*` is the
earlier hand-drawn penguin, superseded by `branding/identity/axiom-penguin.png`
(source: `branding/theme/walllpaper/toppanel.png`); it is kept for history and
not shipped.

The palette is provisional: validate contrast, light/dark behavior, scaling,
color-blindness and high-contrast modes before shipping.
