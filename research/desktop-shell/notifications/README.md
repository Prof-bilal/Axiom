# 3.7 Notification Center

Status: IMPLEMENTATION. The integrated shell now owns the pinned Quickshell
notification service and renders count/history/dismiss behavior; this scope
record is not a completed feature gate.

Investigate freedesktop notification service ownership and Quickshell notification API before replacing any daemon. History, grouping, timestamps, clearing, actions and DND need lifecycle/persistence/privacy contracts. Actions belong to originating live notifications; user content is untrusted. Test bus-name conflicts and keyboard flows.

Before implementation, populate the eight evidence/behavior/architecture/interaction/reference/unknown/specification/validation records defined in the [research workflow](../README.md). Findings must name actual source revisions or runtime artifacts. The canonical phase gate remains in [PHASES](../../../docs/PHASES.md).
