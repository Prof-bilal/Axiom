# Roadmap

This is dependency ordered, not a delivery-date promise. [PHASES](PHASES.md) supplies binding exits; [MVP](MVP.md) supplies priority.

| Milestone | Phases | Evidence and user value |
| --- | --- | --- |
| Foundation | 0 | Reviewed decisions, explicit unknowns, portable workflows |
| Foundation migration | 1–2 | Controlled Arch inputs, legacy Phase 1 evidence, pinned Omarchy-derived Hyprland/Quickshell boot with Axiom identity |
| Desktop interaction | 3 | Keyboard-accessible Axiom Shell launcher, panels, Control Center and original tokens on Quickshell |
| Safe integration foundations | 4–5 | Versioned D-Bus, unprivileged runtime, provider-neutral overlay, parent orchestrator and child-agent registry |
| Useful delegated actions | 6–7 | Small typed API, read-only child set, independently tested authorization, Warden enforcement, audit and failure handling |
| Recovery and measured behavior | 8–9 | Eligible rollback proof; Flow POC/manual resource policies and small V1 benchmark evidence |
| Installable candidate | 10 | Disposable installation, full updates, signed artifact/recovery/release checks |
| Connected experiments | 11 | Authenticated Android proof, scoped permissions |
| Advanced workflows | 12 | Deterministic routines, opt-in structured memory and separately authorized advanced Flow policies |

Execution order (owner decision 2026-10-25, re-scoped 2026-10-27): **Axiom foundation migration first, then Axiom Shell, then the AI system and context foundation, then security enforcement, then recovery/performance/evaluation, then the five first-party projects** — see the [migration report](engineering/OMARCHY_MIGRATION.md), [ecosystem work plan](engineering/ECOSYSTEM_PLAN.md) and [ecosystem](ai/ECOSYSTEM.md).

Security design starts at Phase 0 and applies at every phase; Phase 7 is enforcement integration, not permission to postpone security. Phases 11–12 are outside the first serious prototype. Performance measurements begin with the first bootable baseline; Phase 9 tests controlled changes rather than starting measurement late. No release date or hardware promise is inferred.

Flow research belongs to Phase 0; grouping/Flow OFF baselines begin in Phase 2, UI/contracts in Phases 3–4, authorization in Phase 7, and POC/V1 evidence in Phase 9. Safe automatic sleep/container policies remain advanced work. See [canonical Flow design](system/FLOW.md); no new profile system or phase numbering is introduced.
