---
name: plasma-qml
description: "Build Qt 6/QML and Plasma UI consistent with the Axiom design system."
---

# plasma-qml

## When to use

Use for shell or desktop UI changes. Do not use for building a custom compositor or generic web UI.

## Required inputs

Target Plasma/Qt versions, interaction acceptance criteria, accessibility needs and component scope.

## Procedure

1. Read the design tokens and reuse existing Qt Quick Controls/Plasma components before adding custom primitives.
2. Keep application QML and Plasma-shell integration boundaries explicit; bind semantic tokens rather than scatter constants.
3. Define focus order, shortcuts, accessible names, screen-reader behavior and pointer/touch actions.
4. Move blocking work out of the UI thread; use asynchronous models, bounded lists and measured animation budgets.
5. Check dark/light modes, scale factors, small displays, reduced motion and keyboard-only flows under Plasma Wayland.

## Validation

Run relevant QML lint/tests when available and demonstrate focus, accessibility, responsiveness and frame timing in the target session.

## Failure handling

Reduce to a minimal reproducible QML case; preserve compositor logs and do not solve integration failures by granting root or global input access.

## Project references

- [desktop/DESIGN_SYSTEM.md](../../../docs/desktop/DESIGN_SYSTEM.md)
- [desktop/DESKTOP_UX.md](../../../docs/desktop/DESKTOP_UX.md)
