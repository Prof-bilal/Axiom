# First-party ecosystem: co-evolving products into Axiom subsystems

Status: RESEARCH / design intent — nothing is a dependency, no integration is implemented.
Facts about each product were read from its own README on 2026-10-25; where a product
documents a limit, the limit is repeated here rather than smoothed over. Last researched:
2026-10-25.

Axiom and five sibling projects share one author. They are **first-party components that
co-evolve with Axiom**, not third-party dependencies to be evaluated and possibly dropped.
The intent is that each grows the capability Axiom needs (see *Co-evolution* below) and that
the core desktop still works when any of them is absent.

## Ownership

All five are authored by `Prof-bilal`, the same owner as Axiom. Consequences, stated plainly:

- **Licence permission is not a blocker.** The owner can add or change licences. The one real
  gap is that ModelCheck currently ships **no licence file**; the action is to add one (align
  to whatever Axiom ships under), not to negotiate rights.
- **Declaration is still required.** The release licence-inventory gate
  ([release](../engineering/RELEASE.md)) needs a declared licence per shipped artifact,
  regardless of ownership. Ownership removes the permission question, not the paperwork.
- **Maintenance ownership is unambiguous** — one author, aligned goals. The flip side is
  concentration risk on a single maintainer across six projects; recorded, not hidden.
- **Engineering evidence is unchanged.** Owning a product does not make an untested claim
  true. Warden's bypass matrix is still NOT RUN; Morphix's rollback engine still does not
  exist yet. Ownership lets us *fix* those; it does not let us *assert* them.

## Product narrative

The trust question — *"is this AI system actually safe to run on my machine?"* — is answered
by architecture, not by a promise. When an agent or tool worker executes, the user can see
that it ran **inside an enforced sandbox (Warden)**, under a policy derived from the approved
request, with blocked attempts and applied grants visible in the activity view. Security is
the visible default, not a settings toggle. That framing drives the shaping below.

## Co-evolution: what each product must become

| Product | Axiom subsystem | What must change to fit | Evidence before reliance |
| --- | --- | --- | --- |
| **Warden** | Execution enforcement (conceptual **Shield** boundary) | Typed interface beyond the CLI (library or service); policy **generated from the validated capability request**, not hand-written YAML; audit events correlated to Axiom request/audit IDs; permission-class mapping | Bypass matrix on mainline/LTS (NOT RUN) + policy-generation and audit-correlation tests |
| **RepoSpine** | Context child engine | A defined **multi-root/system** story (today it is repo-scoped); a stable library or MCP path a Rust parent can call; freshness surfaced in UI; decide the Node ≥22.13 runtime floor | Context quality/latency on a real workspace; runtime-packaging proof |
| **ContextGit** | Runtime context VCS | A headless **runtime API** (not the Electron app); a non-repo mode for session/agent context; per-child context branch isolation and merge; keep context rollback distinct from system rollback | Per-child isolation + no-collision test; branch/merge rollback proof |
| **ModelCheck** | Model promotion gate | Become the gate that a candidate model/provider must pass against the current default before selection; wire into router adapter acceptance; support local/Ollama; attach the report to the change | Add licence; evaluation reproducibility; delta vs baseline on the user's workload |
| **Morphix** | Desktop customization | Land its own Phases 5–6 (transaction/rollback engine + KDE adapter writes); align its change-plan/snapshot model with Axiom's change-plan and [Btrfs rollback](../system/BTRFS_ROLLBACK.md); expose a typed interface for the Customization child | Transaction + rollback proof; permission mapping (appearance = NORMAL, system-wide = CRITICAL) |

### Warden — the security answer

Full shaping spec: [Warden integration](../security/WARDEN_INTEGRATION.md).

Today Warden runs MCP servers in an OS-native sandbox: on Linux `bubblewrap` namespaces, a
hostname allowlist enforced **before** DNS, deny-by-default bind mounts (ungranted paths
return `ENOENT`), env allowlisting, wall-clock/memory limits, JSONL audit, and fail-closed
behaviour (with no usable backend it refuses to run unsandboxed). Its own README states it is
**not hardened against a determined local attacker** and lists limits (symlinks within granted
paths, HTTP/HTTPS-only proxy interception, no CPU throttling).

For Axiom, Warden stops being "a CLI you point at an MCP server" and becomes **the layer every
agent and tool execution passes through**. The concrete changes are in the table above; the
key one is that policy is *derived from the approved typed request*
([System Agent API](SYSTEM_AGENT_API.md)) rather than written by hand — the user approves a
capability, and Warden's grants are the enforcement of that exact approval. This is the
runtime realisation of the [sandboxing](../security/SANDBOXING.md) and
[permissions](../security/PERMISSIONS.md) contracts, and it gives the conceptual **Shield**
boundary its first concrete implementation. It never becomes an authorization layer: it
enforces what policy already decided.

### RepoSpine — the system context engine

Scans → hashes → parses → graphs a repo into local SQLite (`.codeatlas/`), then serves
**budgeted, deny-filtered** context over SDK, CLI, MCP stdio and a VS Code extension. Local
first, deterministic before AI, with a freshness signal (`fresh | stale | unknown |
unavailable`). Ships 13 skills and an approval-gated tool installer. Documented beta limits:
lexical (not vector) search, no streaming, no interactive TUI, CI on Ubuntu only. Currently
**repo-scoped**; making it a *system* context engine (many roots, workspaces, session context)
is the main shaping task, and a design decision in its own right.

### ContextGit — runtime context branches

Version control for LLM conversations: immutable content-addressed commits, branches/HEAD as
pointers, branch/diff/merge/rollback of context "while running multiple AI agents without
collisions". Already used in this repository at development time (`AGENTS.md` carries a
ContextGit worktree note; `.contextgit/` exists). Runtime use means each child agent gets an
isolated context branch so parallel children cannot collide — and context rollback stays
distinct from *system* rollback ([Btrfs rollback](../system/BTRFS_ROLLBACK.md)).

### ModelCheck — the model promotion gate

A versioned, deterministic evaluation against a chosen model, compared to a pinned baseline,
with a report where every number links to raw output and the scoring rule; `init → baseline →
verify` plus `compare`; local runs; CI verdicts; no hosted service. It explicitly is **not** a
leaderboard or router. In Axiom it becomes the gate a candidate model must clear before it can
become a default — evidence, not vendor claims.

### Morphix — reversible customization

Declarative **TOML** packs (never executed code), resolved change plans (old → new),
snapshots, transactional apply and rollback; **user-scope only, no root**; KDE Plasma 6 only.
Phases 0–4 exist (detection, packs, planning, snapshots); the transaction/rollback engine and
KDE adapter writes are Phases 5–6 and **do not exist yet**. In Axiom it is the customization
system, and its plan/snapshot/transaction model is the template for Axiom's own
"show before you change, make it reversible" promise. Dual-licensed (MIT OR Apache-2.0);
bundled assets must be original or openly licensed (their ADR-017).

## Integration rules

1. **Adapter by discipline, not by licence.** The core desktop (boot, session, files,
   recovery) must keep working with all five absent — for replaceability and phased evidence
   (ADR-008), not because rights are unclear. Tighter coupling is allowed but must be a
   recorded decision, not a default.
2. **Untrusted output.** Every product's output is untrusted content for the policy engine;
   none of them authorizes an action.
3. **No invented APIs.** Only documented interfaces are referenced; anything closer comes
   from an experiment.
4. **Pin revisions.** Ship against a pinned commit/tag with recorded provenance.
5. **Sandbox where code executes.** Tool/MCP workers run under Warden or an equivalent.

## Open questions (see [RESEARCH](../RESEARCH.md))

Step-by-step sequence for closing these: [ecosystem work plan](../engineering/ECOSYSTEM_PLAN.md).

- RepoSpine as a *system* context engine, or repo-scoped plus a thin workspace layer?
- ContextGit runtime API and a non-repo (session) context mode.
- Warden as a typed library/service vs a CLI wrapper for Axiom's executor.
- ModelCheck licence choice and where evaluation runs (on-device, CI, or both).
- Which Morphix phases must land before Phase 3 depends on it.
