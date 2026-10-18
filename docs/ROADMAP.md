# Roadmap

This is dependency ordered, not a delivery-date promise. [PHASES](PHASES.md) supplies binding exits; [MVP](MVP.md) supplies priority.

| Milestone | Phases | Evidence and user value |
| --- | --- | --- |
| Foundation | 0 | Reviewed decisions, explicit unknowns, portable workflows |
| Bootable identity | 1–2 | Controlled Arch inputs, repeatable VM boot, coherent Plasma session |
| Desktop interaction | 3 | Keyboard-accessible launcher, controls and original tokens |
| Safe integration foundations | 4–5 | Versioned D-Bus, unprivileged runtime, provider-neutral overlay |
| Useful delegated actions | 6–7 | Small typed API, independently tested authorization, audit and failure handling |
| Recovery and measured behavior | 8–9 | Eligible transaction rollback proof and baseline/candidate reports |
| Installable candidate | 10 | Disposable installation, full updates, signed artifact/recovery/release checks |
| Connected experiments | 11 | Authenticated Android proof, scoped permissions |
| Advanced workflows | 12 | Deterministic routines and opt-in structured memory |

Security design starts at Phase 0 and applies at every phase; Phase 7 is enforcement integration, not permission to postpone security. Phases 11–12 are outside the first serious prototype. Performance measurements begin with the first bootable baseline; Phase 9 tests controlled changes rather than starting measurement late. No release date or hardware promise is inferred.
