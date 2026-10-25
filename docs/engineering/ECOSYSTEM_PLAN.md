# Ecosystem work plan

Status: plan — steps 1–8 are **not started** except where noted. This is the dependency-ordered
sequence for working across Axiom and the five first-party projects
([ecosystem](../ai/ECOSYSTEM.md)). Last updated: 2026-10-25.

## Working model

- **Axiom is the host repository.** The five sibling projects are separate repositories; for
  cross-project work they are cloned into `workspace/` (gitignored, never committed here).
- **Each project keeps its own rules.** Read that repo's `AGENTS.md` and `PHASES.md` before
  editing; changes are committed in *that* repo, not in Axiom.
- **Pinned revisions.** Axiom records the exact commit it depends on per project; no floating
  `main`.
- **Evidence, not existence.** A step completes on its stated evidence, never because code
  exists ([workflow](PHASE1_EVIDENCE.md) is the model).
- **No cross-repo push without explicit authorization** for that specific repository.

## Steps (dependency ordered)

| # | Step | Repo | Output / evidence | Blocked by |
| --- | --- | --- | --- | --- |
| 0 | Workspace prepared — 5 repos cloned into `workspace/`, Axiom tree clean | Axiom | **DONE 2026-10-25** | — |
| 1 | Warden shaping spec (typed interface, request→policy, audit correlation) | Axiom | [WARDEN_INTEGRATION](../security/WARDEN_INTEGRATION.md) — **DONE** | — |
| 2 | Authorize and start Phase 2: branded Plasma 6 desktop | Axiom | Bootable branded session; UI surfaces for launcher/overlay/permission views | owner authorization |
| 3 | Warden: programmatic interface + request→policy builder + audit IDs | Warden | Interface implemented in Go; unit tests; then bypass matrix mainline **and** LTS in a VM | step 1; VM time |
| 4 | Morphix: land its Phases 5–6 (transaction/rollback engine + KDE adapter writes) | Morphix | Transaction + rollback proof on a live Plasma 6 session | step 2 (a desktop to customize) |
| 5 | RepoSpine: system/multi-root scope + freshness contract; settle Node floor | RepoSpine | Multi-root context serving; runtime-packaging decision | — |
| 6 | ContextGit: headless runtime API + non-repo session mode | ContextGit | Per-child context branch isolation; no-collision test | — |
| 7 | ModelCheck: add licence; wire as the model promotion gate | ModelCheck | Licence file; candidate-vs-baseline gate on the user's workload | owner licence choice |
| 8 | Axiom Phase 6→7: child registry, read-only children, then enforcement + audit via Warden | Axiom | Contract + denial tests; no silent critical action | steps 3–7 |

## Sequencing decision (2026-10-25)

Owner decision: **build Axiom itself first, then the AI system, then security enforcement, then
the five first-party projects.**

1. **Axiom foundation and desktop** — Phase 2 (branded Plasma 6 desktop), then Phase 3 (custom
   desktop experience): shell, launcher/overlay surfaces, design tokens.
2. **Axiom AI system** — Phases 4–6: parent `assistantd`, provider router, typed capability
   contract, child-agent registry and the read-only child set.
3. **Security enforcement** — Phase 7 with Warden (step 3 below).
4. **The five projects** — steps 4–7 land once Axiom can host them.

Steps 3–7 below are therefore **deferred** until Axiom's own foundation and AI system exist. The
contracts are written now ([WARDEN_INTEGRATION](../security/WARDEN_INTEGRATION.md)) so the
products shape to Axiom, not the other way round.

Write model when those steps start: a **feature branch + pull request per repository** — never a
commit straight to a sibling project's `main` (owner decision 2026-10-25). ModelCheck licence:
**MIT** (owner decision 2026-10-25).

## Cross-cutting rules

1. **Axiom defines the contract; the product shapes to it.** For each integration, the typed
   interface is written in Axiom first (as step 1 did for Warden), then implemented in the
   product. This is the whole point of ownership.
2. **Untrusted output everywhere.** No product's output authorizes an action.
3. **Sandbox where code executes.** Tool/MCP workers run under Warden or an equivalent.
4. **Phase gates still apply.** Axiom's [phases](../PHASES.md) and each project's own phases are
   not bypassed because the code is ours.

## What needs the owner

| Need | Why |
| --- | --- |
| Authorization to modify and push each of the five repos | They are separate repositories with their own history and CI |
| Axiom Phase 2 authorization | It is a phase gate and unlocks steps 2 and 4 |
| ModelCheck licence choice (MIT/Apache-2.0/etc.) | Required for the release inventory gate |
| A decision on coupling depth | Warden as a *required* layer vs an adapter is a real architecture decision (see ADR-012) |

## Open risks

- **Concentration:** six projects, one author.
- **Ordering risk:** Morphix cannot be integrated before its own Phases 5–6 land, and it needs a
  real Plasma session (step 2).
- **Runtime floor:** RepoSpine requires Node ≥22.13 — a bundled runtime is a packaging decision.
- **Verification:** Warden's bypass matrix and Morphix's rollback proof are the two hardest
  pieces of evidence in this plan.
