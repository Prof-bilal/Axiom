# First-party ecosystem: co-evolving products into Axiom subsystems

Status: RESEARCH / design intent — nothing is a dependency and no integration is implemented.
Facts about each product were re-verified from its own repository on **2026-10-27**; where a
product documents a limit, the limit is repeated here rather than smoothed over. Pinned
revisions are recorded in the [architecture/reset report](../engineering/ARCHITECTURE_RESET_IMPACT.md) and
[third-party notices](../../THIRD_PARTY_NOTICES.md).

Axiom and five sibling projects share one author. They are **first-party components that
co-evolve with Axiom**, not third-party dependencies to be evaluated and possibly dropped.
The intent is that each grows the capability Axiom needs and that the core desktop still works
when any of them is absent.

## Ownership

All five are authored by `Prof-bilal`, the same owner as Axiom. Consequences, stated plainly:

- **Licence permission is not a blocker.** The owner can add or change licences. ModelCheck
  (repository `ModelChecker`) still ships **no licence file**; the owner decided **MIT** on
  2026-10-25, so the remaining action is to commit the file, not to negotiate rights.
- **Declaration is still required.** The release licence-inventory gate
  ([release](../engineering/RELEASE.md), [notices](../../THIRD_PARTY_NOTICES.md)) needs a
  declared licence per shipped artifact, regardless of ownership.
- **Maintenance ownership is unambiguous** — one author, aligned goals — but concentration risk
  across six projects remains recorded, not hidden.
- **Engineering evidence is unchanged.** Owning a product does not make an untested claim true.
  Warden's bypass matrix is still NOT RUN; Morphix's rollback engine still does not exist yet.

## Product narrative

The trust question — *"is this AI system actually safe to run on my machine?"* — is answered by
architecture, not by a promise. When an agent or tool worker executes, the user can see that it
ran **inside an enforced sandbox (Warden)**, under a policy derived from the approved request,
with blocked attempts and applied grants visible in the activity view. Security is the visible
default, not a settings toggle.

## Verified current state (2026-10-27)

| Product | Repository | Default branch HEAD | Release/state | Licence | Interface reality |
| --- | --- | --- | --- | --- | --- |
| Warden | `Prof-bilal/Warden` | `main` `f7c9793167` | latest stable `v0.1.17` (2026-09-14); prerelease `v0.2.0-beta.3`; old pin `cd5e8bf2` is the `axiom/integration` tip, not `main` or the tag | MIT | Go CLI only; no typed library/service API |
| RepoSpine | `Prof-bilal/RepoSpine` | `main` `9ea06ec33a` | published `v0.5.1`; `0.7.0-beta.1` is an unpublished tree candidate | MIT | TypeScript/pnpm, Node ≥22.13; CLI, SDK, MCP; repo-scoped |
| ContextGit | `Prof-bilal/ContextGit` | `main` `8acd4e7df4` | betas only; no stable release | Apache-2.0 | Python core + CLI + HTTP/SSE API + MCP; Tauri 2 app is the declared primary UI (not Electron) |
| ModelCheck | `Prof-bilal/ModelChecker` | `main` `eddcf746c3` | `v0.2.0` | **No LICENSE file**; `cli/package.json` says MIT | Node CLI only; no API/MCP |
| Morphix | `Prof-bilal/Morphix` | `main` `1ee76d1189` | no releases, no tags | MIT OR Apache-2.0 | Rust/Tauri IPC only; no CLI/API/MCP |

## Co-evolution: what each product must become

| Product | Axiom subsystem | What must change to fit | Evidence before reliance |
| --- | --- | --- | --- |
| **Warden** | Execution enforcement (conceptual **Shield** boundary) | Typed interface beyond the CLI (library or service); policy **generated from the validated capability request**; audit events correlated to Axiom request/audit IDs; permission-class mapping | Bypass matrix on mainline/LTS (NOT RUN) + policy-generation and audit-correlation tests |
| **RepoSpine** | Context child engine | A defined **multi-root/system** story (today it is repo-scoped); a stable library or MCP path a Rust parent can call; freshness surfaced in UI; decide the Node ≥22.13 runtime floor | Context quality/latency on a real workspace; runtime-packaging proof |
| **ContextGit** | Runtime context VCS | Confirm a headless runtime interface (CLI/API exist); a non-repo mode for session/agent context (currently an unmerged branch); per-child context branch isolation and merge | Per-child isolation + no-collision test; branch/merge rollback proof |
| **ModelCheck** | Model promotion gate | Become the gate a candidate model/provider must pass against the current default before selection; wire into router adapter acceptance; support local/Ollama; attach the report to the change | Add the **MIT** licence file; evaluation reproducibility; delta vs baseline on the user's workload |
| **Morphix** | Desktop customization | Its current desktop-specific adapter does not fit the Axiom-owned session boundary. Either become shell-agnostic or remain optional/deferred; its transaction/rollback engine does not exist | Transaction + rollback proof; a recorded adapter decision; permission mapping |

### Warden — the security answer

Full shaping spec: [Warden integration](../security/WARDEN_INTEGRATION.md).

Today Warden runs MCP servers in an OS-native sandbox. On Linux the real backend is **bubblewrap
namespaces + `setpriv` `no_new_privs` + `strace`**, with a host-side HTTP(S)-only egress proxy
whose hostname allowlist is checked before DNS, deny-by-default bind-mount visibility (`ENOENT`),
env allowlisting, wall-clock/memory limits, JSONL audit, and fail-closed refusal when no backend
is available. It has **no seccomp filter, no Landlock use and no typed programmatic interface**.
Its own docs say it is **not hardened against a determined local attacker** and list limits
(symlinks inside granted paths, HTTP/HTTPS-only proxy interception, no CPU throttling, no
cgroups). Upstream self-reports Linux proof runs; Axiom's independent bypass matrix is NOT RUN.

For Axiom, Warden stops being "a CLI you point at an MCP server" and becomes **the layer every
agent and tool execution passes through**. Policy must be derived from the approved typed request
([System Agent API](SYSTEM_AGENT_API.md)), never written by a model. Warden never authorizes.

### RepoSpine — the system context engine

Scans → hashes → parses → graphs a repo into local SQLite (`.codeatlas/`), then serves
**budgeted, deny-filtered** context over SDK, CLI, MCP stdio and a VS Code extension. Local
first, deterministic before AI, with a freshness signal (`fresh | stale | unknown | unavailable`).
Documented beta limits: lexical (not vector) search, no streaming, no interactive TUI, CI on
Ubuntu only. Currently **repo-scoped**; making it a *system* context engine (many roots,
workspaces, session context) is the main shaping task. Node ≥22.13 is a packaging decision.

### ContextGit — runtime context branches

Version control for LLM conversations: immutable content-addressed commits, branches/HEAD as
pointers, branch/diff/merge/rollback of context while running multiple AI agents without
collisions. The Python core is importable; a headless CLI (`ctx`), an HTTP/SSE API (`ctx-api`)
and an MCP server exist, alongside a Tauri 2 desktop app described as the primary product UI.
Per-task worktree/branch/session isolation code is present; the standalone non-repo/session mode
appears on an unmerged branch and is **unproven on main**. Context rollback stays distinct from
*system* rollback ([Btrfs rollback](../system/BTRFS_ROLLBACK.md)).

### ModelCheck — the model promotion gate

A versioned, deterministic evaluation against a chosen model, compared to a pinned baseline,
with a report where every number links to raw output and the scoring rule; `init → baseline →
verify` plus `compare`, `run` and `list`; local runs; CI verdicts; no hosted service. It
explicitly is **not** a leaderboard or router. In Axiom it becomes the gate a candidate model
must clear before it can become a default — evidence, not vendor claims. It is CLI-only today
and has no documented Ollama support.

### Morphix — reversible customization

Declarative packs, resolved change plans, snapshots, transactional apply and rollback;
**user-scope only, no root**; **desktop adapter unproven**. Phases 0–4 exist (detection, packs,
planning, snapshots); the transaction/rollback engine and desktop adapter writes do not exist
yet, and there are no releases. The current adapter does not define the Axiom
session contract; retaining Morphix requires a shell-agnostic redesign. That is
a **future decision**, not this reset's implementation.

## Integration rules

1. **Adapter by discipline, not by licence.** The core desktop (boot, session, files, recovery)
   must keep working with all five absent — for replaceability and phased evidence (ADR-008).
2. **Untrusted output.** Every product's output is untrusted content for the policy engine;
   none of them authorizes an action.
3. **No invented APIs.** Only documented interfaces are referenced; anything closer comes from
   an experiment.
4. **Pin revisions.** Ship against a pinned commit/tag with recorded provenance.
5. **Sandbox where code executes.** Tool/MCP workers run under Warden or an equivalent.

## Build vs bundle (proposed, not decided)

| Product | Preferred shape | Alternative | Open question |
| --- | --- | --- | --- |
| Warden | Library/service behind a typed interface | CLI wrapper for early POC | Process overhead vs isolation |
| RepoSpine | MCP/stdin or library | Bundled CLI | Node runtime floor and startup cost |
| ContextGit | Headless library/API | Sidecar service | Python runtime and packaging |
| ModelCheck | CLI invoked by the runtime/CI | Library | Local-first then CI artifacts |
| Morphix | Deferred pending ADR | Shell-agnostic library | Whether Axiom Shell should own customization instead |

## Repository strategy

Keep Axiom a **monorepo core** (OS integration, shell, adapters, policies, packaging) and keep
each product in its own repository, consumed through pinned packages/interfaces. Do not vendor
sibling repositories or merge them into `services/everything`.

## Open questions (updated 2026-10-27)

- RepoSpine as a *system* context engine, or repo-scoped plus a thin workspace layer?
- ContextGit headless runtime confirmation and a non-repo session mode.
- Warden as a typed library/service vs a CLI wrapper for Axiom's executor.
- ModelCheck local-first vs CI vs both; Ollama support.
- Morphix disposition after the Axiom session contract exists.
- Which components ship default vs optional (proposal: foundation, shell, runtime and Shield
  default; RepoSpine, ContextGit, ModelCheck and Morphix optional).
