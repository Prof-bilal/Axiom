# Execution brief acceptance ledger

The full owner brief remains the goal. This ledger is a work map, not an exit
claim or permission to skip the original requirements. Current status is in
[PHASES](../../docs/PHASES.md).

| Brief requirement | Evidence now | Work still required |
| --- | --- | --- |
| 0 Read repository/assets first | [Audit](repository-audit.md) | Reinspect implementation as it evolves; missing concept PNGs remain explicit |
| 1 Install/configure/verify REA | [Setup](../../docs/research/REA_SETUP.md), scripts/verify-rea.py | Active native connector reload is unverified; verified stdio route works |
| 2 Research system and evidence workflow | [Workflow](README.md), feature scope folders, foundation/macOS records | Populate all eight records before each feature implementation |
| 3 Public macOS UX investigation | [macOS evidence](macos/evidence.md) | Later-feature references, demonstration/video evidence when available; no invented internals |
| 4 Linux implementation investigation | [Foundation sources](window-foundation/linux-references.md) | Relevant feature-specific protocol/source inspections in order |
| 5 Feature order 3.1–3.9 | [Foundation specification](window-foundation/axiom-spec.md) | Real controls, Dock, top bar, launcher, Control Center, notifications, overview and file-manager spec |
| 6 Central design system | [Canonical tokens](../../docs/desktop/DESIGN_SYSTEM.md), official assets located | Shared QML tokens/components and actual accessibility/interaction validation |
| 7 Restrained interruptible motion | [Public guidance](macos/evidence.md), proposed tokens | Motion tokens in QML, reduced-motion path and measured behavior |
| 8 Actual desktop functionality | Native read-only QML model, live/missing-backend smoke | All visible features operate actual OS; no placeholder status/windows/icons |
| 9 Least privilege | No root/action API/permission changes in current model | Document each later system operation and service authorization; security/failure tests |
| 10 Performance | No performance claims | Startup, RSS, idle CPU, launcher/Dock/Control Center latency with raw environment and uncertainty |
| 11 Per-feature validation.md | Foundation and macOS records | Functionality, UX, integration, performance, failure, monitors and keyboard for each feature |
| 12 Visual comparison | Official assets located; no surface screenshot claimed | Actual session screenshots and provenance-backed behavioral comparison |
| 13 Six-part decisions | Foundation/macOS axiom-spec.md | Record reference/evidence/Linux/decision/reason/difference for every major choice |
| 14 Canonical subphase/status management | Updated PHASES and development status | Advance only on matching evidence; foundation exit remains open |
| 15 First execution 3.0/3.1 then 3.2/3.3 | Research infrastructure, native model and read-only smoke | Complete foundation failure/lifecycle/guest gates before controls/Dock |
| End-of-subphase reports | [Validation](window-foundation/validation.md), source/decision records | At exits enumerate research, REA, sources, evidence, decisions, files, tests, screenshots, limitations and next subphase |

Phase 3 completion additionally requires Phase 2 foundation evidence, a coherent
actual desktop session, integration/polish and no known regression. Unit checks,
source inspection, registration, counts or QML rendering alone cannot prove it.
