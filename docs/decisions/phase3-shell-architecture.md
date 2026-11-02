# ADR-015: Phase 3 shell architecture

**Date:** 2026-11-01
**Status:** Accepted for Phase 3 (MVP). The compositor choice is explicitly
temporary and does not become the product contract.

## Context

Phase 3 must deliver a real, working Axiom desktop in QEMU: boot → graphical
session → panel, dock, launcher, workspace switching, notifications, status and
session controls, all backed by real system state. Axiom already decided
([ARCHITECTURE](../ARCHITECTURE.md), [ADR-014](../DECISIONS.md#adr-014-axiom-owned-desktop-architecture-after-the-reset))
to own the compositor/session boundary and shell while reusing standard Linux
infrastructure, and to allow a disposable compositor harness for bring-up.

No `shell/` or `compositor/` implementation existed. Writing a security-critical
Wayland compositor from scratch before any shell workflow works would delay a
real desktop by months and risk another "looks done, isn't" milestone.

## Options

| Option | Development time | Control | Performance | Dependencies | Multi-monitor | Maintainability | Maturity | Visual freedom | Replacement cost |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **A. Custom compositor + custom shell** | Highest | Full | Best possible (owned) | Minimal upstream | Must build | Owned but large | None yet | Total | — |
| **B. Minimal existing compositor + Quickshell Axiom shell** | Lowest | Window policy delegated; shell fully owned | Good; virtual GPU needs software path | Sway (MIT) + Quickshell (LGPL) | Provided by sway | Small shell; harness replaceable | High (both mature) | High (QML) | Compositor swap behind adapter |
| **C. Custom compositor + Quickshell temporary shell** | High (compositor first) | Full compositor ownership | Owned | Quickshell (LGPL) | Must build | Two moving parts early | Low until compositor works | High | Shell swap later |

## Decision

**Option B for the Phase 3 MVP**, with two hard boundaries:

1. **The compositor is a temporary harness, not the product.** Sway (MIT) is
   chosen for the bring-up because it implements the exact protocols the shell
   needs — `zwlr_layer_shell_v1`, `zwlr_foreign_toplevel_management_v1`,
   `ext-workspace-v1`, and wlr screencopy — is small, MIT-licensed, and is the
   minimal Wayland architecture the research brief asks us to study. Its
   configuration is disposable (`iso/phase3/airootfs/etc/axiom/sway.conf`).
2. **The shell talks through Axiom-owned service adapters, never the compositor
   directly.** `WorkspaceService` (i3/sway IPC) and `WindowService`
   (`wlr-foreign-toplevel-management`) are the only places a compositor
   protocol is named. A future Axiom compositor replaces those adapters; no UI
   component changes.

**Shell toolkit: Quickshell/QML (LGPL-3.0-only)**, treated as a replaceable
implementation dependency, not Axiom's identity. It is used as a dynamically
linked package (Arch `extra`), never vendored, so LGPL relink obligations are
satisfiable. If it is replaced later, the surfaces are QML components behind
the service boundary.

Option C remains the target architecture for the *next* compositor milestone:
an Axiom-owned compositor implementing the same standard protocols, with the
same shell on top. This ADR does not authorise starting that compositor.

## Why not A now

- A Wayland compositor is security- and correctness-critical; a rushed one is
  worse than a mature harness and would not save time in Phase 3.
- The brief explicitly prefers "a real working Axiom desktop fastest without
  creating long-term lock-in". Option B meets that; the lock-in is contained by
  the adapter boundary and an MIT dependency.

## Consequences

- **Positive:** a real desktop in QEMU now; real window/workspace state; the
  shell is genuinely Axiom's; the compositor can be swapped without rewriting
  the product.
- **Negative:** window policy (tiling, maximize/minimize semantics,
  decorations) is sway's for now; a tiling harness makes "minimize" and
  server-side decorations limited, and the shell must report unsupported
  operations honestly.
- **License:** Quickshell LGPL-3.0-only — keep it a separate shared-library
  package with notices; no static vendoring. Sway MIT — retain notice.
- **Rollback:** delete the harness config and adapter implementations; the UI
  and service callers remain valid against any compositor that provides the
  same standard protocols.

## Revisit when

The Axiom compositor milestone starts, or the harness blocks a required behavior
(server-side decorations, per-output workspaces, secure lock). At that point
record a new superseding ADR with the compositor's protocol matrix and measured
performance.
