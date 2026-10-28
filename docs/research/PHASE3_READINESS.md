# Phase 3 research and implementation readiness

Status: **RESEARCH/DOCUMENTATION ONLY** (owner pause, 2026-10-28). No new
Phase 3 implementation is authorized by this document. Existing exploratory
work remains historical evidence until the owner explicitly resumes coding.

The purpose of this packet is to make the next implementation turn deliberate:
each surface must have a source-backed behavior model, a Linux ownership model,
license/provenance notes, security boundaries, an acceptance matrix and a
reproducible validation plan before code is added.

## Read this packet in order

1. [Desktop-shell research workflow](../../research/desktop-shell/README.md)
2. [REA UI reverse-engineering workflow](REA_UI_REVERSE_ENGINEERING.md)
3. [Open-source and license matrix](OPEN_SOURCE_DESKTOP_LICENSES.md)
4. [UI change workflow](UI_CHANGE_WORKFLOW.md)
5. [Implementation-readiness ledger](../../research/desktop-shell/implementation-readiness.md)
6. The feature's eight dossier records and its linked validation artifacts

## Readiness gate

A feature is **ready to implement** only when all of the following are true:

- the observable behavior is documented from public UX material, an actual
  runtime observation, or source evidence; proprietary internals are not
  treated as facts;
- the relevant Linux source and pinned revision are identified, with the
  compositor, shell, service and UI ownership separated;
- REA Evidence IDs or reproducible source/runtime references are recorded,
  including coverage and unknowns;
- every input, title, app ID, icon path and IPC value is treated as untrusted
  data; no display value becomes a command or an authority decision;
- the license, copyright, asset and trademark provenance is known for every
  copied or linked input; MIT is not assumed merely because a project is
  called a distribution;
- failure, unavailable, disconnect, lock, multi-monitor, mixed-DPI,
  keyboard-only and reduced-motion states have an explicit design;
- the acceptance test can exercise the real user session in a disposable
  QEMU/KVM guest or an explicitly scoped host session without touching
  unrelated applications; and
- performance measurements have a defined start/end event, workload, noise
  treatment and limitation statement.

If one item is missing, the status stays **RESEARCH**. A polished mockup or a
successful QML import is not an implementation gate.

## Sequential research order

The feature order remains the phase contract:

| Order | Feature | Documentation status |
| --- | --- | --- |
| 3.0 | Research infrastructure and evidence workflow | complete for infrastructure |
| 3.1 | Window foundation | validation evidence exists; readiness ledger remains open |
| 3.2 | Window controls | research required before implementation |
| 3.3 | Dock | research required before implementation |
| 3.4 | Top bar | research required before implementation |
| 3.5 | Launcher | research required before implementation |
| 3.6 | Control Center | research required before implementation |
| 3.7 | Notifications | research required before implementation |
| 3.8 | Workspace overview | research required before implementation |
| 3.9 | File-manager specification | research/specification only |
| 3.10 | Integration and polish | depends on all earlier evidence |

Research for a later feature must not silently turn into implementation of an
earlier feature. Update the ledger and the feature's eight records first.

## What this prevents

- copying a screenshot, Apple asset or undocumented private behavior into the
  product;
- replacing a real Hyprland/Wayland state with a decorative QML duplicate;
- treating a permissive dependency license as permission to copy its branding,
  artwork, documentation or trademarks;
- coupling a surface directly to raw compositor IPC or shell commands;
- allowing an AI or UI action to become privileged merely because a button is
  visible; and
- declaring a feature complete because it renders while its backend is absent.

The canonical phase status remains in [`docs/PHASES.md`](../PHASES.md). Phase 2
is still incomplete; this readiness packet does not create a release claim.
