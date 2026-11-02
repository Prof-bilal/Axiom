# Phase 3 license audit

Recorded 2026-11-01 from each repository's `LICENSE` file at the pinned revision
(see [research/phase3/repos.lock](../../../research/phase3/repos.lock)).

Classification legend:

- **REFERENCE ONLY** — read for understanding; no code may be copied or linked.
- **SAFE TO LINK/DEPEND** — may be used as a runtime/build dependency.
- **SAFE TO MODIFY** — permissive; may be modified and redistributed with notices.
- **COPYING REQUIRES COMPLIANCE** — copyleft; copying into Axiom triggers
  obligations.
- **DO NOT COPY** — not compatible with Axiom's intended distribution.

| Project | License (SPDX) | Classification | Rationale |
| --- | --- | --- | --- |
| cosmic-panel | GPL-3.0-only | **REFERENCE ONLY** | Copyleft; Axiom does not import GPL shell code into its own shell. Architecture reference only. |
| cosmic-launcher | GPL-3.0-only | REFERENCE ONLY | Same. |
| cosmic-notifications | GPL-3.0-only | REFERENCE ONLY | Same. |
| cosmic-workspaces | GPL-3.0-only | REFERENCE ONLY | Same. |
| cosmic-session | GPL-3.0-only | REFERENCE ONLY | Same. |
| cosmic-settings | GPL-3.0-only (`subscriptions/*` MPL-2.0) | REFERENCE ONLY | Same. |
| cosmic-greeter | GPL-3.0-only | REFERENCE ONLY | Same. |
| cosmic-comp | GPL-3.0-only | REFERENCE ONLY | Same; also a compositor we are not adopting. |
| sway | MIT | **SAFE TO LINK/DEPEND** (temporary harness) | Permissive; used as a disposable compositor harness, keep the notice. |
| wayfire | MIT | SAFE TO LINK/DEPEND | Permissive; research reference and possible future harness. |
| hyprland | BSD-3-Clause | SAFE TO LINK/DEPEND (research) | Permissive; **not** selected as the harness; IPC/behavior reference only. |
| quickshell | LGPL-3.0-only (a GPL-3.0 file also ships) | **COPYING REQUIRES COMPLIANCE** | Used as a *dynamically linked package* (Arch `extra`), never vendored. LGPL relink obligation is satisfiable by shipping it as a shared library/package and preserving notices. Do not statically vendor or copy its source into Axiom. |

## Decisions

- **No GPL code is copied into Axiom.** COSMIC is studied as architecture; the
  Axiom shell is original QML/Rust.
- **Quickshell is a replaceable dependency, not Axiom identity.** It is
  dynamically linked; Axiom keeps the ability to relink and to replace it. If
  Axiom later ships a modified Quickshell, LGPL source/notices must be provided.
- **Sway is MIT** and used only as a temporary, disposable harness. Its
  configuration (`iso/phase3/.../sway.conf`) is data, not sway source.

## Obligations to carry forward

1. Add Quickshell (LGPL-3.0-only) and sway (MIT) to
   [THIRD_PARTY_NOTICES](../../../THIRD_PARTY_NOTICES.md) before a release.
2. Keep Axiom's own branding original (already the case under `branding/`).
3. If any Quickshell source is ever patched and shipped, publish the patch and
   the relink path.

## Not verified

- Exact SPDX for every bundled asset inside the reference repos (we copy none).
- Distribution/trademark review — tracked separately in
  [THIRD_PARTY_NOTICES](../../../THIRD_PARTY_NOTICES.md).
