# Phase 3 implementation-readiness ledger

Status: **RESEARCH ONLY**. The owner requested documentation and reverse
engineering before further Phase 3 coding. A row becomes READY only after the
linked eight-record dossier, source/license review and validation plan are
complete.

| Subphase | Current state | Required research before code | Implementation gate |
| --- | --- | --- | --- |
| 3.0 infrastructure | COMPLETE for evidence workflow | Keep REA setup/version and bounded evidence reproducible | No feature code implied |
| 3.1 window foundation | VALIDATION evidence exists from disposable guest work | Reconcile remaining health/lifecycle/performance artifacts; preserve explicit unavailable and identity contracts | Real window/workspace/monitor model, disconnect recovery and lock boundaries pass |
| 3.2 window controls | NOT STARTED | Research close/maximize/minimize semantics, fullscreen and cross-monitor behavior; document confirmation and unsupported states | Real operations on real windows; no title-based dispatch or fake minimize |
| 3.3 Dock | NOT STARTED | Research desktop-entry metadata, process launch, grouping, pin persistence, menus, reorder and autohide ownership | Actual entries/icons, launch/restore/grouping and persistence tests |
| 3.4 top bar | NOT STARTED | Identify service owners and stale/denied states for network, Bluetooth, audio, battery, power, time and notifications | Each module reports real state and failure, not sample values |
| 3.5 launcher | NOT STARTED | Define local indexes, recency, app/file/settings/command boundaries, keyboard navigation and latency protocol | Search remains data; action execution is separately typed/authorized |
| 3.6 Control Center | NOT STARTED | Map each toggle to a stable API, authorization rule, confirmation and rollback | No generic shell passthrough; failure and unavailable states tested |
| 3.7 notifications | NOT STARTED | Inspect notification service, history, grouping, actions, DND and accessibility contracts | Real service integration and action/clear/history tests |
| 3.8 workspace overview | NOT STARTED | Prove workspace/window listing and decide whether thumbnails/drag are technically supported | No duplicate authority or invented thumbnails |
| 3.9 file-manager specification | SPECIFICATION ONLY | Compare mature file managers and portal contracts, including license and integration cost | Evidence-backed spec; separate ADR required for a replacement |
| 3.10 integration/polish | NOT STARTED | Consolidate tokens, motion, reduced-motion, accessibility, performance and regression matrix | Full-session evidence and release-gate review |

## Per-row completion evidence

Attach these links to the row before changing its state:

1. eight dossier files (`evidence`, `behavior`, `architecture`,
   `interaction-map`, `linux-references`, `unknowns`, `axiom-spec`,
   `validation`);
2. REA Evidence IDs or primary source revisions, with scope and limitations;
3. license/provenance entry in [`THIRD_PARTY_NOTICES.md`](../../THIRD_PARTY_NOTICES.md)
   when anything is copied, linked or redistributed;
4. a failure/security acceptance matrix and a disposable-session command;
5. actual results, artifacts and uncertainty notes.

## Research questions that must not be skipped

- What is the real authority for this state?
- What happens when the authority disconnects or reports unavailable?
- What exact identity is used for a target, and how is it validated?
- Is the operation supported by the current pinned compositor/protocol?
- Which user/session privileges are required, and where is authorization
  independently enforced?
- What is copied versus merely referenced, and which license/asset/trademark
  obligations follow?
- What test falsifies the design, and what recovery path is bounded?

Until those answers are recorded, keep the feature in RESEARCH and do not add
Phase 3 implementation code.
