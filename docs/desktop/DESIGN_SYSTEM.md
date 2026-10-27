# Axiom design tokens

Status: proposed V1 tokens; usability/accessibility validation pending. Last researched: 2026-10-18.

The visual direction is graphite surfaces with a restrained teal accent, clear typography and explicit activity states. Publish tokens once in a shared QML theme module when Axiom Shell implementation begins (Quickshell/QML); component QML consumes semantic names rather than repeated literals. Respect desktop font, scale and accessibility preferences.

| Token family | Proposed values (logical pixels unless specified) |
|---|---|
| Spacing | 4, 8, 12, 16, 24, 32, 48 |
| Typography | system sans; caption 12, body 14, title 20, display 28; scalable |
| Radius | control 8; surface 12; overlay 16 |
| Elevation | flat 0; raised 1; overlay 2; modal 3; subdued shadows only |
| Panel | minimum height 36; grows with text |
| Dock | minimum height 64; icon 40; gap 8; optional autohide |
| Motion | immediate 0ms; feedback 100ms; standard 180ms; transition 240ms |
| Focus | 2px outline plus 2px separation; never color alone |
| Pointer targets | minimum 32×32; touch mode 44×44 |

| Semantic color | Dark proposal | Light proposal |
|---|---|---|
| Background | #151A1E | #F4F7F8 |
| Surface | #20282E | #FFFFFF |
| Foreground | #ECF2F4 | #17242B |
| Muted foreground | #B4C2CA | #4A606C |
| Accent / on accent | #64D8C5 / #102822 | #00675B / #FFFFFF |
| Danger / warning | #FF9C9C / #F3D27A | #A01828 / #725000 |

Colors are candidates, not certified accessible pairs. Test every actual text/background combination against WCAG AA contrast (4.5:1 ordinary text, 3:1 large text and relevant UI boundaries). Never communicate permission level, error or progress solely by color. Link error text to recovery action.

Tab order follows reading order; Escape dismisses reversible overlays, not an executing privileged transaction. Enter activates the focused action; destructive actions are never the default merely because a model suggested them. Preserve focus when models update. Supply accessible roles, names, status announcements and keyboard alternatives for drag gestures. Honor reduced motion and disable ornamental animation; avoid forced blur/transparency.

Use asynchronous models, bounded delegates and image sizes; no synchronous network/DB work on the UI thread. Profile render and binding cost before optimization. Sources: [W3C contrast guidance](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html), [Qt Quick performance](https://doc.qt.io/qt-6/qtquick-performance.html), [Qt Quick accessibility](https://doc.qt.io/qt-6/accessible-qtquick.html). See [UX](DESKTOP_UX.md).
