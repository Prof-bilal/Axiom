# Ecosystem work plan

Status: plan — steps are not started except where noted. This is the dependency-ordered sequence
for working across Axiom and the five first-party projects. Re-verified **2026-10-27**; stale
repository pins and the `axiom/integration` claim from the 2026-10-25 version are corrected.
See [ecosystem](../ai/ECOSYSTEM.md), [architecture](../ARCHITECTURE.md) and the
[reset impact report](ARCHITECTURE_RESET_IMPACT.md).

## Working model

- **Axiom is the host repository.** The five sibling projects are separate repositories; for
  cross-project work they are cloned into `workspace/` (gitignored, never committed here).
- **Each project keeps its own rules.** Read that repo's `AGENTS.md` and phases before editing;
  changes are committed in *that* repo, not in Axiom.
- **Pinned revisions.** Axiom records the exact commit it depends on per project; no floating
  `main`. Current verified heads:

  | Project | Repository | Verified head 2026-10-27 |
  | --- | --- | --- |
  | Warden | `Prof-bilal/Warden` | `f7c9793167398c86a61148c746cb4d934be11727` |
  | RepoSpine | `Prof-bilal/RepoSpine` | `9ea06ec33a69a613a91831cd7c533a11ca16b032` |
  | ContextGit | `Prof-bilal/ContextGit` | `8acd4e7df4ca583334745c20f17968094ced6162` |
  | ModelCheck | `Prof-bilal/ModelChecker` | `eddcf746c30399c77e494cc6dfcfa9398e64c1bb` |
  | Morphix | `Prof-bilal/Morphix` | `1ee76d1189b843d306f4987a71cf49fdaae2b683` |

- **Evidence, not existence.** A step completes on its stated evidence, never because code
  exists.
- **No cross-repo push without explicit authorization** for that specific repository.
- The earlier claim that every sibling repo's `axiom/integration` was "currently identical to
  that repo's `main`" was wrong for Warden; the branch exists but does not match `main`.

## Steps (dependency ordered)

| # | Step | Repo | Output / evidence | Blocked by |
| --- | --- | --- | --- | --- |
| 0 | Workspace prepared — sibling repos remain optional and pinned when adopted | Axiom | Recorded revisions; no core desktop dependency | — |
| 1 | Warden shaping spec (typed interface, request→policy, audit correlation) | Axiom | [WARDEN_INTEGRATION](../security/WARDEN_INTEGRATION.md) — **DONE** | — |
| 2 | Axiom graphical-session contract and compositor evaluation | Axiom | Phase 2 QEMU session evidence | Phase 0 reset decision |
| 3 | Axiom Shell MVP on the owned session contract | Axiom | Phase 3 shell acceptance | step 2 |
| 4 | RepoSpine: system/multi-root scope, stable interface, Node floor decision | RepoSpine | Multi-root context serving; packaging decision | step 0 |
| 5 | ContextGit: confirm headless runtime interface, non-repo session mode, per-child isolation | ContextGit | Isolation + no-collision evidence | step 0 |
| 6 | Warden: programmatic interface + request→policy builder + audit correlation | Warden | Interface implemented in Go; unit tests | step 1 |
| 7 | ModelCheck: commit the licence; wire as the model promotion gate | ModelChecker | Licence file; candidate-vs-baseline gate | owner licence choice |
| 8 | Morphix decision: shell-agnostic adapter vs removal | Morphix | Recorded ADR-level decision | steps 2–3 |
| 9 | Axiom integration: context POC (Phase 6), Warden enforcement + Sentinel POC (Phase 7) | Axiom | Contract + denial tests; no silent critical action | steps 4–8 |
| 10 | Independent Warden bypass matrix on mainline and LTS | Warden + Axiom security | E32 evidence | step 6 |

## Sequencing decision

Current decision (2026-10-29 reset): **Axiom base/session first, then Axiom Shell,
then the AI runtime and context foundation, then security enforcement, then first-party
products shaped to Axiom's contracts.**

Reason: RepoSpine + ContextGit give the AI runtime useful context and multi-agent state before
any mutation authority exists; Warden then provides safe execution; ModelCheck governs model
changes before defaults move; Morphix must be re-evaluated because the desktop foundation is
now Axiom-owned and shell-agnostic.

Write model when sibling steps start: a **feature branch + pull request per repository** — never
a commit straight to a sibling project's `main`. ModelCheck licence: **MIT** (owner decision
2026-10-25); the file still needs to be committed in `Prof-bilal/ModelChecker`.

## Build vs bundle (proposed)

| Product | Preferred shape | Alternative | Reason |
| --- | --- | --- | --- |
| Warden | Library/service behind a typed interface | CLI wrapper for the first POC | Process overhead vs isolation and audit correlation |
| RepoSpine | MCP/stdin or library | Bundled CLI | Node ≥22.13 runtime floor |
| ContextGit | Headless library/API | Sidecar service | Python runtime and packaging |
| ModelCheck | CLI invoked by runtime/CI | Library | Local-first evaluation with CI artifacts |
| Morphix | Deferred pending its disposition decision | Shell-agnostic library | Plasma adapter does not fit |

## Cross-cutting rules

1. **Axiom defines the contract; the product shapes to it.** The typed interface is written in
   Axiom first, then implemented in the product.
2. **Untrusted output everywhere.** No product's output authorizes an action.
3. **Sandbox where code executes.** Tool/MCP workers run under Warden or an equivalent.
4. **Phase gates still apply.** Axiom's phases and each project's own phases are not bypassed
   because the code is ours.
5. **Graceful absence.** Core desktop works with every first-party component removed.

## What needs the owner

| Need | Why |
| --- | --- |
| Authorization to modify and push each of the five repos | Separate repositories with their own history and CI |
| Authorization to modify and push each sibling repo | Separate repositories with their own history and CI |
| ModelCheck licence file commit | Required for the release inventory gate |
| Morphix disposition (adapter vs redesign vs removal) | Its Plasma-only adapter does not fit the new foundation |

## Open risks

- **Concentration:** six projects, one author.
- **Ordering risk:** RepoSpine/ContextGit interfaces and Morphix's disposition are unproven.
- **Runtime floor:** RepoSpine requires Node ≥22.13.
- **Verification:** Warden's bypass matrix and Morphix's rollback proof are the hardest evidence.
- **Upstream churn:** Temporary compositor/toolkit candidates can move quickly; pin them behind an adapter and keep them replaceable.
