# Axiom design tokens

Status: proposed Phase 0 contract; values are starting points, not a frozen
visual identity. Tokens belong to Axiom and must not be expressed as a theme
override for another desktop.

| Family | Initial scale / rule |
| --- | --- |
| Spacing | 4, 8, 12, 16, 24, 32, 48 logical px; align to a 4 px grid |
| Typography | System sans; caption 12, body 14–16, title 20, display 28; honor user scale |
| Radius | 4 control, 8 surface, 12 overlay; use square edges for dense data |
| Density | 32 px minimum pointer target; 44 px touch target; compact surfaces must remain readable |
| Focus | 2 px visible outline plus separation; never color alone |
| Motion | Immediate 0 ms, feedback ≤120 ms, standard 160–220 ms; respect reduced motion |
| Elevation | Prefer borders and contrast; restrained shadow only for transient overlays |

Use semantic roles (`surface`, `text`, `muted`, `accent`, `danger`, `warning`,
`focus`) rather than repeated literals. Support light and dark modes, contrast
checks, high-contrast overrides and dynamic scaling. Original Axiom identity
assets are reviewed separately under `branding/`; no upstream icon/font asset is
assumed to be redistributable.

## Component rules

Panels are slim and information-dense. Docks are functional launch/switch
surfaces, not decorative floating shelves. Launcher results expose real desktop
entries and search state. Window decorations provide clear close/minimize/
maximize behavior and never hide focus or unsaved-state warnings. Notifications
are time-bounded, keyboard reachable and safe for untrusted content. Animation
communicates state change and never delays a critical action.

Every component needs an accessible name/role, keyboard path, focus behavior,
empty/error/loading state, monitor/DPI behavior and a restart/reconnect story
before it can become a shell dependency.
