# Phase 3 research workspace

This tree holds **research material** for the Axiom Shell MVP. Nothing here is a
product or runtime dependency; the analysis conclusions live in
`docs/research/phase3/` and the decisions in `docs/decisions/`.

```text
research/phase3/
├── repos/        cloned reference repositories (gitignored; pins in repos.lock)
├── rea/          REA tooling notes / analysis artifacts (gitignored)
├── features/     working notes per feature (pointer to docs/research/phase3)
├── screenshots/  captured reference/implementation evidence
├── traces/       process/IPC/D-Bus trace notes
└── decisions/    pointers to the accepted ADRs
```

## Reference repositories

Cloned read-only into `repos/` (see [`repos.lock`](repos.lock) for exact
revisions and licenses). They are **not** vendored and are excluded from git:

- **Shell architecture:** COSMIC (`cosmic-panel`, `-launcher`,
  `-notifications`, `-workspaces`, `-session`, `-settings`, `-greeter`) and
  `cosmic-comp`.
- **Minimal Wayland:** `sway`.
- **Extensible compositor:** `wayfire`.
- **Modern desktop behavior:** `hyprland` (IPC/behavior reference only).
- **Shell toolkit:** `quickshell`.

## Rules

1. Never copy GPL code into Axiom. See `docs/research/phase3/licenses.md`.
2. Source analysis precedes REA; REA is used when runtime behavior cannot be
   read from source.
3. Prefer standards (Wayland protocols, freedesktop specs, XDG) over a specific
   project's implementation.
