# First-party ecosystem integration

Status: RESEARCH / design intent — **no product is a dependency yet** and no integration is
implemented. Facts below were read from each project's own README on 2026-10-25; where a
project documents limits, those limits are repeated here rather than smoothed over. Last
researched: 2026-10-25.

Axiom is built by the same author as five projects that map almost one-to-one onto the
subsystems this OS needs. The design intent is to consume them **behind adapters** so the
core desktop never hard-depends on any of them and each can be swapped or dropped.

## Mapping

| Product | Repo / licence | Role in Axiom | Boundary | Phase |
| --- | --- | --- | --- | --- |
| **Warden** | `Prof-bilal/Warden` · Go · MIT · `warden-sandbox-cli` v0.1.17 | Execution sandbox for tool/MCP workers | CLI `warden run --policy` around a scoped worker | 7 |
| **RepoSpine** | `Prof-bilal/RepoSpine` · TypeScript · MIT · `repospine-cli`, Node ≥22.13 | Code-context engine for the Context child agent | Context SDK / MCP stdio, bounded `ContextPackage` | 5–6 |
| **ContextGit** | `Prof-bilal/ContextGit` · Python · Apache-2.0 | Context version control for parallel agents (branch/diff/merge/rollback) | Python core library + API | 4–6 |
| **ModelCheck** | `Prof-bilal/ModelChecker` · TypeScript · **no licence file** | Evaluate a candidate model before it becomes a default | CLI `modelcheck run` / `compare` | 5, 9 |
| **Morphix** | `Prof-bilal/Morphix` · Rust/Tauri · MIT OR Apache-2.0 | Safe, reversible desktop customization | Rust core (typed IPC), declarative TOML packs | 3, 8 |

### Warden — sandbox (Security)

Runs MCP servers in an OS-native sandbox: on Linux, `bubblewrap` namespaces with a
hostname allowlist enforced before DNS, deny-by-default bind mounts (ungranted paths return
`ENOENT`), env allowlisting, wall-clock/memory limits, JSONL audit. Fail-closed: with no
usable backend it refuses to run unsandboxed. Its own README states it is **not hardened
against a determined local attacker** and lists limits (symlinks within granted paths,
HTTP/HTTPS-only proxy interception, no CPU throttling). Integration stays gated by the
[sandboxing evaluation gate](../security/SANDBOXING.md); the bypass matrix is still NOT RUN.

### RepoSpine — code context (Context agent)

Scans → hashes → parses → graphs a repo into a local SQLite context DB (`.codeatlas/`), then
serves **budgeted, deny-filtered** context over a stable SDK, CLI, MCP stdio and a VS Code
extension. It is local-first, computes facts deterministically before AI, and exposes a
freshness signal (`fresh | stale | unknown | unavailable`) so an agent reads the current
working tree. It ships 13 first-party Skills and a tool registry with a trust assessor and
an **approval-gated** installer; `atlas setup` installs only what the user selects. Documented
beta limits: lexical (not vector) search, no streaming, no interactive TUI, CI on Ubuntu only.

Mapping: RepoSpine is the natural implementation of the **Context** child and the
[bounded context](SYSTEM_AGENT_API.md) rule. It is *not* an authorization layer — its schema
output is untrusted input like any other tool result.

### ContextGit — context VCS (parallel agents)

Version control for LLM conversations: immutable content-addressed commits, branches/HEAD as
pointers, and branch/diff/merge/rollback of *context* "while running multiple AI agents
without collisions". Python core is the source of truth; API/CLI/UI stay thin; local-first
(only configured model calls leave the machine).

Notably, **ContextGit is already used in this repository at development time** — `AGENTS.md`
carries a ContextGit-managed note about per-run git worktrees and `.contextgit/` is present.
The proposal is to extend that from the dev workflow into the runtime: each child agent gets
an isolated context branch so parallel children cannot collide, with rollback of context
(runtime *effects* are still governed by [Btrfs rollback](../system/BTRFS_ROLLBACK.md), not
by ContextGit).

### ModelCheck — model evaluation

A CLI that runs a versioned, deterministic evaluation against a chosen model, compares it to
a pinned baseline, and emits a report where every number links to raw output and the scoring
rule. `init → baseline → verify`, plus `compare`; YAML config, JSONL cases, lockfiles; runs
stay local under `RUNS_DIR`; supports CI verdicts; no hosted service or telemetry. It
explicitly is **not** a leaderboard, router or SDK.

Mapping: this is how "check and benchmark new models" becomes a *repeatable, evidence-backed*
step instead of adopting a model on vendor claims. It fits the router's adapter-acceptance
rule ([model router](MODEL_ROUTER.md)): a candidate model is benchmarked on the user's own
workload before it can become a default.

**Blocking issue:** GitHub reports **no licence** for this repository. Redistribution or
bundling is therefore not permitted by default. Either a licence is added upstream or the
integration is user-opted-in-from-npm only. Recorded before any dependency is taken.

### Morphix — reversible customization

A KDE Plasma 6 customization platform: users browse declarative **TOML** packs (never
executed code), see a resolved change plan (old → new), snapshot affected resources, apply
transactionally and roll back. User-scope only, no root. Phases 0–4 are implemented
(detection, pack spec/parser/validator/store, change planner, snapshot engine); the
**transaction/rollback engine and KDE adapter writes are Phases 5–6 and do not exist yet**.
Dual-licensed; bundled assets must be original or openly licensed (their ADR-017).

Mapping: Morphix is the Customization child and the practical realisation of Axiom's
"visible change plan + recovery" promise for desktop appearance. Its plan/snapshot/transaction
model mirrors Axiom's change-plan and rollback contracts, so the permission mapping is direct
(NORMAL for appearance changes; nothing system-wide). It also demonstrates the pattern Axiom
wants everywhere: *show before you change, and make it reversible*.

## Integration rules

1. **Adapter, never a hard dependency.** The core desktop (boot, session, files, recovery)
   must keep working with all five absent. Each integration is a versioned adapter behind an
   existing boundary (CLI, SDK, MCP, or library) and can be disabled.
2. **Untrusted output.** Every product's output is untrusted content for the policy engine;
   none of them authorizes an action.
3. **No invented APIs.** Only the documented interfaces above are referenced; anything
   closer must be established by an experiment, not assumed.
4. **Licence inventory first.** ModelCheck (none) blocks bundling now; Warden/RepoSpine MIT,
   ContextGit/Morphix Apache-2.0, Morphix dual — all require the release licence inventory
   gate ([release](../engineering/RELEASE.md)).
5. **Pin revisions.** Bundle or depend only on a pinned commit/tag with recorded provenance.
6. **Sandboxed where they execute third-party code.** Tool/MCP workers run under Warden or an
   equivalent, not with the user's ambient environment.

## Open questions (see [RESEARCH](../RESEARCH.md))

- Does RepoSpine remain usable as a *system* context engine, or is it repo-scoped only?
- Can ContextGit's branch model isolate per-child runtime context without a repo per child?
- Which Morphi phases must land before Axiom's Phase 3 can rely on it?
- ModelCheck licence, and whether evaluation runs belong on-device or in CI.
- Does Warden mediate the *Axiom* executor, or only external MCP/tool workers?
