# Axiom Omarchy theme

Status: Phase 2 foundation theme. This is a **user theme** for the pinned
Omarchy-derived foundation, not an Axiom Shell implementation. It changes
palette, wallpaper and branding while the Phase 3 Axiom Shell is still pending.

Install on a test guest:

```sh
mkdir -p ~/.config/omarchy/themes
cp -a axiom ~/.config/omarchy/themes/axiom
omarchy theme set axiom
```

The theme contains only colours, an original aurora wallpaper and previews. It
does not ship Lua, terminal configs or VSCode extensions. Identity assets live
under `../../identity/`.

Phase 2 remains a foundation POC: Omarchy's shell widgets and layout are still
present and must be replaced by Axiom Shell in Phase 3.
