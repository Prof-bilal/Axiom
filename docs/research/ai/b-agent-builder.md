# Track B: Agent builder platform (research + draft spec v0)

Date: 2026-11-10. Status: RESEARCH and DRAFT. Nothing here is accepted, nothing is implemented.
Repo was read-only. Web/repo text treated as data. Method: Round 1 broad, Round 2 primary sources
(fetched this session: Agent Skills spec, MCP tools spec 2026-07-28, A2A spec (first 100k chars
only), Claude Code subagent docs, Anthropic multi-agent research post, OpenAI Agents SDK handoffs,
CrewAI agents docs, HA automation index page), Round 3 counter-evidence (search only; mostly
secondary sources). Claims marked **(unv.)** were not confirmed from a primary source this session.
LangGraph, n8n, Dify, Microsoft Agent Framework internals, custom GPTs/Gems and Home Assistant modes
are written from background knowledge or secondary sources and are all **(unv.)**. reddit not used.

---------------------------------------------------------------------------------------------------
## 0. What the repo already decides (so the spec does not reinvent it)

- AGENT_SYSTEM.md: one parent, bounded ephemeral children; no child-to-child talk in V1; authority
  never grows; model output is a proposal; user-authored children are "declarative only",
  frontmatter + prompt, no scripts, edit invalidates grants, imports untrusted. Field list exists
  (`id, version, purpose, capabilities[], tools[], model_binding, context_scope, sandbox, budget,
  evidence, failure_policy`) but "a concrete schema must be authored". This document is that schema.
- SYSTEM_AGENT_API.md: capability classes OBSERVE / NORMAL / SENSITIVE / CRITICAL, "effective
  classification can only increase", pipeline authenticate > validate > policy/consent > executor
  revalidate > audit intent > execute > verify > audit result.
- ROUTINES.md: deterministic versioned graph; LLM is an explicit optional step with consent and
  budget; edit/import invalidates grants; background trigger cannot answer a sensitive prompt; never
  replay uncertain actions.
- MCP.md: integration manifest, pin versions, approve tool-list/schema changes, fail closed.
- MODEL_ROUTER.md: provider returns untrusted tool proposals; tool names never accepted dynamically;
  no silent local-to-cloud fallback.
- ADR-022 seams S1-S9 and R4 (no stored secrets until a secret-store ADR). Track 1: profile = one
  versioned JSON file, data not code, undo = keep copies. Track 2 doc: `ActionService` with typed
  entries (id, argument schema, sensitivity), Automate caps at 10 steps / 2 s delays.
- Owner repos (ai-d1): aisskills manifest (`capabilities, activation.triggers, requires.permissions,
  access{network,secrets}, checks, risk_level`) + lockfile with content and policy hashes + scan
  without executing + untrusted wrapper = PORT-CONCEPT. ModelChecker baseline/verify/lock =
  eval harness format. ContextGit = task board / claims / audit vocabulary. Gaploom FUTURE_AGENTS =
  human-gated roles design (not re-read in detail here; ai-d3 summary only).

Net: the platform is "AGENT_SYSTEM.md child contract made concrete, with Automate's graph discipline
and Profiles' data-only/versioned/undo discipline". Little needs inventing; the risk is scope.

---------------------------------------------------------------------------------------------------
## 1. Comparison of agent definition formats and what each gets wrong (for Axiom)

| Format | Unit and shape | Good | What it gets wrong for Axiom |
|---|---|---|---|
| **Agent Skills** (agentskills.io, verified) | Dir with `SKILL.md`: YAML frontmatter `name` (<=64, lowercase-hyphen, must match dir), `description` (<=1024), optional `license`, `compatibility`, `metadata` (string map), `allowed-tools` (experimental, space-separated pre-approved tools); optional `scripts/ references/ assets/`; progressive disclosure (~100 tokens metadata, <5000 token body) | Portable, human-readable, tiny, huge ecosystem | Describes *instructions*, not an agent: no typed tools, no resource scopes, no budgets, no memory, no triggers, no version/hash. `allowed-tools` is a self-declared pre-approval string (`Bash(git:*)`): the artifact grants itself authority. `scripts/` makes shared packages code. |
| **Claude Code subagents** (verified) | Markdown + frontmatter: `name, description, tools, disallowedTools, model, permissionMode, maxTurns, skills, mcpServers, hooks, memory (user/project/local), effort, isolation, background`. Nesting default depth 3, `Agent(worker,...)` allowlist only for main-thread agent | Closest prior art; allowlist/denylist, per-agent turn cap, memory scope, worktree isolation | Tools are tool *names* with string patterns, not typed actions; `hooks` run shell commands from the definition (code in the data file); `permissionMode: bypassPermissions` exists; unknown fields silently ignored (typos = silent no-op); no cost cap, no content hash/lock, no provenance. |
| **Custom GPTs / Gems** (unv.) | Web-UI form: name, instructions, knowledge files, actions (OpenAPI), capabilities toggles | Non-expert friendly; the builder is a form, not a file | Locked to one vendor; not a file you can diff or hash; instructions are extractable (launch-era leaks, secondary sources) so "secret prompt" is not a promise; store monetization unclear/slow (secondary). Actions = OpenAPI blobs with weak per-user scoping. |
| **MCP tool definition** (verified) | `name, title, description, inputSchema (JSON Schema 2020-12), outputSchema, annotations` (readOnly/destructive/idempotent/openWorld hints) | The de facto tool schema; Axiom's ActionService schema should be wire-compatible | Annotations are explicitly "untrusted unless from trusted servers" (spec). Tool list can change (`listChanged`) after approval = rug pull. Defines tools only, no agent. Spec says a human SHOULD be in the loop, not MUST. |
| **A2A Agent Card** (verified partially) | Card: provider, capabilities (streaming, pushNotifications), `skills[]`, interfaces/bindings, `securitySchemes`, optional signature; task states SUBMITTED/WORKING/INPUT_REQUIRED/AUTH_REQUIRED/COMPLETED/FAILED/CANCELED/REJECTED | Good task state vocabulary; signed cards | It is a network interop protocol between independent agent services. Axiom has one runtime and no peer network, so adopting it adds a listener, auth surface and trust problem for zero v0 benefit. Borrow the task states; defer the protocol. |
| **CrewAI** (verified) | Agent `role, goal, backstory, llm, tools, max_iter (20), max_rpm, max_execution_time, allow_delegation (False), memory, cache`; YAML or JSONC per agent + `crew.jsonc` | Safe-ish defaults (delegation off, iteration cap); config-as-file | `role/goal/backstory` invites persona prose over a testable contract; tools are Python objects (code); memory is opaque; delegation is model-chosen free text between peers; no per-agent grants. Own docs show churn (code execution mode deprecated, interpreter tool removed). |
| **LangGraph** (unv.) | Python code defining a state graph; checkpointers, interrupts for human-in-the-loop, recursion limit | Explicit control flow; resumable; deterministic edges | It is a library, not a user-facing definition; users write code. Good ideas to copy: checkpoint/interrupt/recursion limit as runtime features. |
| **AutoGen / Microsoft Agent Framework** (partly verified via search) | Code-defined conversable agents, group chats | Research origin of many patterns | AutoGen is in maintenance mode, new users pointed to Microsoft Agent Framework (repo notice per search; dates conflict across sources). Group chat = free-form agent-to-agent talk, the failure mode AGENT_SYSTEM.md already excludes. |
| **OpenAI Agents SDK** (verified) | `Agent` objects; handoffs exposed to the model as tools `transfer_to_x`; `handoff(input_type, on_handoff, input_filter)`; input/output/tool guardrails | Typed handoff args; `input_filter` controls what the next agent sees; docs say do authorization at the start of `on_handoff` | Code-defined; guardrails apply only at chain ends (first agent input, final output), not on handoffs; nested-history option "does not redact sensitive data". |
| **n8n / Dify / Langflow** (unv. detail; Langflow CVEs from search) | Node-graph JSON/GUI workflows with AI nodes | Visual builder non-experts can use | Nodes can embed code (Langflow had multiple unauthenticated RCE CVEs in 2026, e.g. CVE-2026-33017, public-flow endpoint; verify on NVD); graphs sprawl; credential handling is per-node. Do not build a node-graph editor in v0. |
| **Home Assistant automations + blueprints** (page verified only as an index; modes from background knowledge **unv.**) | YAML trigger / condition / action; run modes (single/restart/queued/parallel + max); blueprints = templates with typed inputs | Closest *desktop-adjacent success*: non-experts use triggers+conditions+actions and typed blueprint inputs; the run-mode concept solves re-entrancy | Actions can call arbitrary services and templates (Jinja); no capability grants; shared blueprints are the trust gap. Copy: run modes, typed template inputs. |
| **aisskills manifest** (owner repo) | `schema_version, id, version, capabilities, activation.triggers, requires.permissions, access{network[],secrets}, checks, risk_level, dependencies` + lockfile | Already deny-by-default, hashed, scan-before-run | Permission vocabulary coarse (`repository.read`, host list, secrets bool); guard is string-level, not enforcement. Port structure, replace vocabulary with ActionService ids + scopes. |

Cross-cutting lesson: every format either (a) defines instructions without authority, or (b) defines authority
by naming things in strings the artifact itself wrote, or (c) is code. None binds **typed tool ids + scoped
grants + budgets + content hash** in one data file, and none makes "approval" a record separate from the
artifact. That is the gap Axiom can fill.

---------------------------------------------------------------------------------------------------
## 2. DRAFT: Axiom agent definition v0 (`axiom.agent/v0`)

### 2.1 Package layout (a directory, shareable as a zip or git folder; all files are DATA)

```
research-finder/
  SKILL.md            # Agent Skills spec-valid. Body = the agent's instructions (system prompt).
  agent.json          # axiom.agent/v0: everything machine-enforced (below)
  references/*.md     # optional static text, loaded on demand (spec convention)
  evals/cases.jsonl   # optional eval cases (ModelChecker-style)
  (no scripts/. Import rejects executables and shows why, per S9)
```
Not in the package, written locally by Axiom (so an attacker cannot ship them):
```
~/.config/axiom/agents/<id>/
  versions/<hash>/...   # every approved/previous version kept as plain files (rollback)
  approval.json         # grants the USER approved, bound to a content hash (section 2.4)
  memory/               # section 5
~/.local/state/axiom/agents/<id>/runs/<run-id>/   # run log, checkpoint, audit refs (rotated)
```

Superset decision: `SKILL.md` stays 100 percent spec-compliant (so any Agent Skills client can read the
instructions, and `skills-ref validate` passes) and carries NO authority. Axiom ignores `allowed-tools` and
`scripts/` entirely. All authority fields live in `agent.json`. Reason: the spec defines `metadata` as
string-to-string only, and unknown top-level frontmatter keys are tolerated by some clients but I could not
verify `skills-ref` accepts them **(unv.)**; a sibling JSON file avoids the question, hashes cleanly, matches the
Profiles JSON convention (ADR-022 open choice) and keeps prose out of the machine schema.

### 2.2 `agent.json` (JSONC for explanation; real file is plain JSON)

```jsonc
{
  "schema": "axiom.agent/v0",            // S2: versioned; unknown keys ignored with a warning, never fatal;
                                         // but unknown keys inside "tools"/"grants" make the file INVALID (fail closed)
  "id": "research-finder",               // = SKILL.md name = directory name
  "version": "0.3.0",                    // semver of this definition; author-set
  "title": "Idea Finder",
  "purpose": "Find candidate product ideas with source URLs.",   // one line; collision check vs built-ins

  "instructions": { "file": "SKILL.md" },   // body is untrusted-ish prose; it can ask, never grant

  "model": {
    "class": "local-small",                 // local-small | local-large | cloud-any ; never a key or endpoint
    "needs": ["tool_calling", "json_schema"],// router refuses a model lacking these (MODEL_ROUTER)
    "cloud": "never"                        // never | ask-each-run | allowed-with-consent ; default never
  },

  "tools": [                                // typed ActionService ids only. No shell, no free names.
    { "action": "web.search",  "v": "^1",   "max_calls": 30 },
    { "action": "web.fetch",   "v": "^1",   "max_calls": 60,
      "fixed_args": { "method": "GET" } },    // fixed_args cannot be overridden by the model
    { "action": "files.write", "v": "^1",   "max_calls": 40,
      "scope_ref": "grants.workspace" }
  ],

  "grants": {                               // what the agent REQUESTS. Becomes authority only via approval.json
    "ceiling": "NORMAL",                    // max sensitivity this agent may ever propose (OBSERVE|NORMAL|SENSITIVE)
                                            // CRITICAL is not expressible: schema rejects it
    "workspace": { "kind": "path", "path": "~/Axiom-Agents/research-finder/", "mode": "rw" },
    "read":  [ { "kind": "path", "path": "~/Projects/Axiom/docs/research/", "mode": "r" } ],
    "network": { "hosts": ["*.github.com", "news.ycombinator.com", "arxiv.org"], "methods": ["GET"] },
    "secrets": [],                          // names of secret-store entries; model never sees values (R4: empty until ADR)
    "unattended": { "max_sensitivity": "OBSERVE" }   // what may run with the user absent (background triggers)
  },

  "context": {                              // what enters the prompt; everything else is invisible to the model
    "include": ["memory/notes.md"],         // plain files only
    "untrusted": ["tool_results", "web", "files_outside_workspace"],  // wrapped with provenance (section 4.4)
    "max_input_tokens": 12000
  },

  "memory": { "scope": "agent", "max_bytes": 262144, "retention_days": 90, "files": ["notes.md", "seen-urls.jsonl"] },

  "triggers": [                             // all optional; none = manual only
    { "type": "manual" },
    { "type": "schedule", "cron": "0 8 * * 1", "mode": "single", "skip_if_on_battery": true },
    { "type": "file_changed", "path": "~/Axiom-Agents/inbox/", "debounce_s": 30, "mode": "queued", "max_queue": 3 },
    { "type": "handoff" }                    // started by a team (section 3); carries a typed payload
  ],

  "budgets": {                              // all REQUIRED; no "unlimited" value exists
    "max_steps": 25, "max_tool_calls": 100, "wall_s": 900,
    "max_input_tokens_total": 150000, "max_output_tokens_total": 30000,
    "max_cost_usd": 0.00,                   // 0 = local models only; cloud needs a positive cap
    "max_runs_per_day": 6, "max_concurrent": 1,
    "on_exhausted": "stop_and_report"       // stop_and_report only. No "replan".
  },

  "output": {                               // deterministic validator checks the final result
    "schema_file": "references/candidates.schema.json",   // JSON Schema 2020-12
    "must_cite": true                       // every item needs a source URL that a deterministic fetch confirmed
  },

  "gates": [                                // human-in-the-loop, evaluated by runtime, not by the model
    { "when": "tool.sensitivity >= SENSITIVE", "do": "ask" },
    { "when": "network.host not in grants.network.hosts", "do": "deny" },
    { "when": "run.first_time_after_update", "do": "ask" }
  ],

  "evals": { "cases": "evals/cases.jsonl", "pass_required_for": "badge:verified" },

  "provenance": {
    "origin": { "kind": "template|local|imported", "source": "builtin:research-team@1", "author": "local-user" },
    "created": "2026-11-10T00:00:00Z",
    "derived_from": null,                   // content hash of parent version when forked
    "content_hash": "sha256:...",           // computed by Axiom on validate; a claim in the file is ignored
    "files": { "SKILL.md": "sha256:...", "agent.json#canonical": "sha256:..." }  // recomputed locally, compared
  }
}
```

Rules the validator enforces (all deterministic, no model):
1. `tools[].action` must exist in the local ActionService registry, version range must resolve, `fixed_args`
   and any args must satisfy the action's `args_schema`. Unknown action = invalid. Model-supplied tool names
   are never looked up outside this list (MODEL_ROUTER rule).
2. `ceiling` must be >= the max sensitivity of every listed action, or validation fails ("agent lists a
   SENSITIVE action but ceiling is NORMAL"). "Effective classification can only increase" still applies at run time.
3. Every required budget key is present and bounded by hard platform maxima (e.g. wall <= 1 h per run,
   steps <= 100) that the definition cannot raise.
4. **Dangerous-combination lint** (the "lethal trifecta": private data read + untrusted content in + external
   send out): flagged; `unattended` forbidden when all three are present.
5. Content scan without executing (aisskills idea): hidden/zero-width/tag unicode, instructions that tell the
   model to ignore policy or reveal secrets, URLs in instructions, base64 blobs, any `scripts/`, `hooks`,
   `command`, `exec`-like keys. Findings are shown in the approval panel; some (scripts, hooks) are hard failures.
6. Names/paths: no absolute paths outside `~`, no `..`, no symlinks in the package, secrets-looking strings rejected.
7. Hashes are recomputed by Axiom; the `provenance.content_hash` in the file is informational.

### 2.3 Action metadata the registry must supply (what makes tools "typed")
Each ActionService entry (D2) needs, beyond `id` and argument schema:
`sensitivity` (OBSERVE|NORMAL|SENSITIVE|CRITICAL, Axiom-assigned, never taken from an MCP annotation),
`effects` (`none | undoable | compensable | irreversible`) and what undo covers, `dry_run: true|false`,
`idempotent`, `resources` (which grant kinds it touches: path/host/app/device), `destinations` (external
hosts it may contact), `produces` (output schema), `description_user` (plain-language line for the explain panel).
Imported MCP tools get a generated registry entry defaulting to SENSITIVE/irreversible/openWorld until a
human or a reviewed Axiom mapping lowers it; tool-list hash pinned; a changed schema disables the tool.

### 2.4 Approval is a separate local record (`approval.json`)
```jsonc
{ "agent": "research-finder", "content_hash": "sha256:AAA", "approved_at": "...", "approved_by": "local-user",
  "grants": { "tools": ["web.search","web.fetch","files.write"], "workspace": "...", "network": [...], "ceiling": "NORMAL",
              "unattended_max": "OBSERVE" },
  "model_binding": { "provider": "ollama", "model": "qwen3:8b@digest" },
  "budgets_accepted": {...} }
```
Grants are bound to `content_hash`. Any edit, import, or update changes the hash and voids approval; the
update flow (section 4) shows a diff of *capabilities only* and carries over grants that did not grow.
The user may approve a subset (e.g. refuse `network`); the runtime then removes the tool. Revoke = delete the
record. The grant record is the thing audited, never the definition's claims.

---------------------------------------------------------------------------------------------------
## 3. DRAFT: team definition v0 (`axiom.team/v0`)

A team is also a data directory (`team.json` + member agent dirs or references by `id@hash`). It adds
topology and typed handoffs; it adds no new powers.

```jsonc
{
  "schema": "axiom.team/v0", "id": "research-team", "version": "0.1.0",
  "title": "Research Team (Finder > Judge > MVP builder)",
  "roles": {
    "finder":  { "agent": "research-finder@sha256:AAA",  "may_spawn": [] },
    "judge":   { "agent": "research-judge@sha256:BBB",   "may_spawn": [] },
    "builder": { "agent": "research-mvp@sha256:CCC",     "may_spawn": [] }
  },
  "topology": "pipeline",                 // pipeline | manager_worker | router | debate (fixed menu; no free graph in v0)
  "workspace": { "path": "~/Axiom-Agents/research-team/", "layout": ["01-candidates/","02-verdicts/","03-mvp/"] },

  "handoffs": [                           // the ONLY channel between agents; typed, validated, artifact-by-reference
    { "id": "finder_to_judge", "from": "finder", "to": "judge",
      "payload_schema": "schemas/candidates.v1.json",    // JSON Schema 2020-12
      "carries": "artifact_refs",                        // file paths + sha256 in the team workspace, not whole transcripts
      "max_items": 25, "gate": "none" },
    { "id": "judge_to_builder", "from": "judge", "to": "builder",
      "payload_schema": "schemas/verdicts.v1.json", "carries": "artifact_refs", "max_items": 5,
      "gate": "ask_user" }                               // human reviews the shortlist before building
  ],

  "limits": {
    "max_depth": 2,                       // handoff chain length from the entry role (no cycles; DAG validated)
    "max_breadth": 4,                     // concurrent children of one role (manager_worker only)
    "max_total_agent_runs": 8, "max_concurrent_model_calls": 1,   // local hardware reality
    "spawn": "declared_roles_only",       // an agent may only start roles named in this file; never create new agents
    "budget_pool": { "max_cost_usd": 0.0, "wall_s": 3600, "max_tokens_total": 400000 },
    "on_any_member_exhausted": "stop_team_and_report"
  },

  "authority": "intersection",            // effective grant per role = role approval ∩ team ceiling ∩ user policy
  "team_ceiling": { "unattended_max": "OBSERVE", "max_sensitivity": "NORMAL" },
  "gates": [ { "when": "team.finish", "do": "ask_user" },
             { "when": "any.tool.sensitivity >= SENSITIVE", "do": "ask_user" } ],
  "triggers": [ { "type": "schedule", "cron": "0 7 * * 1", "mode": "single" }, { "type": "manual" } ],
  "evals": { "cases": "evals/team-cases.jsonl" },
  "provenance": { "origin": { "kind": "template", "source": "builtin:research-team@1" }, "content_hash": "sha256:..." }
}
```

Design rules:
- **No agent-to-agent chat.** Delegation = a handoff object that validates against `payload_schema`; the
  receiver sees the payload and only what `carries` lists (OpenAI `input_filter` idea, but default-deny, not
  default-pass). Prose summaries of other agents' reasoning do not cross.
- **Pipeline is the default topology**, parallel fan-out only for read-only OBSERVE roles (Anthropic's own
  post: multi-agent fits parallelizable research, not tasks with shared context or many dependencies;
  Cognition argues for one agent owning context; see section 9). `manager_worker` workers are all the same
  declared role with `max_breadth`; `debate` = fixed N rounds with a Judge, bounded cost; `router` = a
  deterministic keyword/schema router first, model router only if declared.
- **Spawning** is only "start a declared role"; there is no `create_agent` action. Depth and breadth caps
  are checked by the runtime before the child starts; a child that would exceed them is refused, logged.
- **Authority never grows** across a handoff: a handoff carries data, not grants. The receiver runs under its
  own approval intersected with the team ceiling.
- **Human gates** are runtime-evaluated predicates over sensitivity, cost, host, first-run-after-update.
  A background run reaching a gate enters `awaiting_gate` and pauses (ROUTINES: background cannot answer a
  sensitive prompt). Gates cannot be removed by team import; the platform's minimum gates are always added.
- **Evidence over prose:** each role's `output.schema` is validated; a role whose output fails validation
  fails the run, it is not retried more than `max_retries: 1` and never retried when a mutation may have happened.

---------------------------------------------------------------------------------------------------
## 4. Runtime lifecycle and the deterministic/model split

### 4.1 Where it runs (daemon justification)
No new daemon. The runtime is a module of the planned `assistantd` (AI_ARCHITECTURE: parent, router, policy,
registry are modules). Reuse mature primitives instead of writing a scheduler:
- Schedules and file triggers are generated as **systemd user timer / path units** from the validated trigger
  list (so triggers fire with no Axiom process resident; idle cost is zero). **(design proposal, unv. in
  Axiom; systemd feature itself is standard.)**
- A background run is a transient user service with `MemoryMax`, `CPUQuota`, `RuntimeMaxSec`; **kill =
  `systemctl --user kill`**, independent of the model loop being healthy. Duet runs inside the foreground
  session process and needs none of this.
- Run state is files (run log + checkpoint), so a crash is reconcilable by reading them.
This needs an ADR if it ends up a separate process (AGENTS.md: every daemon justified); v0 plan = module +
systemd units, zero new resident daemon.

### 4.2 State machine (A2A task states borrowed, trimmed)
`draft > validated > approved > queued > running > (awaiting_gate | paused) > running > completed | failed |
killed | budget_exhausted | rejected`. Every transition is an audit event with the run id.

### 4.3 Lifecycle steps

| Step | What happens | Deterministic or model |
|---|---|---|
| **Create** | Wizard/template fills a draft; or the user describes the agent in words and a model drafts `agent.json` + `SKILL.md` ONCE. Draft is a proposal, never self-approving. | Draft = model (optional); everything after is not. |
| **Validate** | Schema, action registry, versions, ceilings, budgets, lint, scan, hash, collision check (section 2.2). Produces a findings list and a capability summary. | Deterministic. Never asks a model "is this safe". (A model reviewer may add advisory notes, labeled advisory.) |
| **Approve** | "What can this agent do" panel (section 6.4); user approves all/subset; `approval.json` written bound to hash and the model binding. Approval prompt is a trusted-UI surface that the agent cannot draw. | Deterministic + human. |
| **Dry-run** | Runtime executes with every action replaced by its `dry_run` result or a recorded fixture; writes nothing outside a scratch dir; shows the plan of calls, estimated tokens and cost. Optional model-in-the-loop dry run on a local model. | Mixed: tool layer deterministic, reasoning model. |
| **Run** | Loop: build context (files named in `context.include` + trigger payload, untrusted-wrapped) > model proposes typed call > validator (schema, in tool list, scope, budget, gate) > policy > executor > verify > audit > result back as untrusted data. | Model proposes only; every other stage deterministic. |
| **Observe** | Live activity view reads audit events: step, tool, args (secrets redacted), result summary, cost, remaining budget, gate state. Runs are replayable from log. | Deterministic. |
| **Pause / resume** | Checkpoint after each completed step (step index, accepted tool results, budget counters, working files). Resume re-validates the hash and approval before continuing; if the definition changed, the run cannot resume. | Deterministic. |
| **Kill** | Cancels in-flight cancellable actions, stops the unit, marks `killed`. In-flight mutations with unknown outcome are marked `uncertain` and reconciled on next start by reading state, never replayed (AI_ARCHITECTURE). Kill-all switch in the shell. | Deterministic. Must work with no model. |
| **Update** | New files become a new version dir; hash changes; approval void; diff shows capability growth only (new tool, wider path, new host, higher ceiling, larger budget); shrinking changes carry over; first run after update is gated. | Deterministic. |
| **Roll back** | Switch the active pointer to a previous `versions/<hash>`; if its approval record exists and the registry still resolves its action versions, it runs without re-approval; else re-approve. Honest limit: rollback restores the *definition*, not the effects of past runs; effect undo exists only where an action declares `undoable` (profiles-style, never "universal undo"). | Deterministic. |

### 4.4 What is model-driven vs not (the replace-a-model-call list)
Model-driven: choosing the next action among allowed ones, composing queries, summarizing/scoring prose,
drafting a definition. Everything else is code: trigger firing, debounce, scheduling, dedupe by URL/hash,
schema validation, liveness check of cited URLs (a `web.fetch` HEAD), budget counting, gates, approval,
handoff routing, retries, kill, retention, scoring arithmetic. Rule of thumb for template authors: if a
step's correct output can be written as a schema + predicate, make it an action or validator, not a prompt.
Untrusted-input wrapping: tool results, web pages, files outside the workspace and other agents' outputs enter
as delimited data with provenance (`source`, `trust: untrusted`) and are never concatenated into the
instruction channel; the model's output is parsed, never executed. Wrapping reduces but does not eliminate
prompt injection, so the real defenses are the scope/grant/gate limits above.

### 4.5 Attribution
Audit actor = `{kind: agent, id, version, content_hash, run_id, parent_run_id, team_id?, model, trigger}`;
the same record family as routines (`kind: routine`) and user (`kind: user`).

---------------------------------------------------------------------------------------------------
## 5. Memory model

Principle: **memory is files the user can open, edit and delete. No hidden state.**

- Location: `~/.config/axiom/agents/<id>/memory/` (user data, backed up with S8 files; open question
  whether it belongs here or under `~/.local/share`, see Q4). Team shared memory = the team workspace folder.
- Formats: Markdown (`notes.md`, curated) and JSONL (`seen-urls.jsonl`, append-only). No database, no
  embeddings in v0. If search is needed later, an FTS5 index (already planned for activity) is *derived* and
  rebuildable from the files; deleting it loses nothing.
- Scopes (`memory.scope`): `none` | `run` (scratch dir, deleted at run end) | `agent` (its own dir only) |
  `team` (named files in the team workspace) | `user_notes` (read-only files the user marked shareable).
  No cross-agent read of another agent's `agent` memory; sharing happens by explicit handoff artifact or team file.
- Writes happen only through a typed `memory.write` action with file name from `memory.files` allowlist, size
  cap, and append/replace mode; each write is audited with a diff; a secret scanner rejects writes that look
  like keys/tokens (secrets never go to memory, per global rules).
- Retention: `max_bytes` and `retention_days` enforced by a deterministic janitor (oldest JSONL lines first;
  `notes.md` over cap blocks further writes and notifies rather than silently truncating). Default off
  (`scope: none`) for imported agents until approved.
- Reading memory into the prompt is opt-in via `context.include`; it is wrapped as untrusted because an agent
  that read a poisoned web page may have written the poison into its own memory (memory poisoning is the
  persistent form of prompt injection **(general knowledge, unv. here)**). UI shows "memory last written by
  run X from source Y" and offers one-click "forget".
- Run logs are separate from memory, rotated by size/age, and never fed back automatically.

---------------------------------------------------------------------------------------------------
## 6. Builder UX for a non-expert (Quickshell GUI)

### 6.1 Principle
Start from a template, answer plain questions, see consequences in plain language, test safely, approve once.
The user never sees JSON unless they press "Show definition" (read-only view of the real file, editable in an
advanced tab with the same validator). No node-graph editor, no code editor.

### 6.2 Flow (6 screens)
1. **Pick**: "Start from a template" (Research Team, Inbox Summarizer, Daily Digest, Downloads Tidier,
   Release-notes Drafter, Blank) or "Describe what you want" (model drafts once, clearly labeled DRAFT).
2. **Purpose and instructions**: name, one-line purpose, instruction text box with plain-language hints and
   examples (loads `SKILL.md`). Warnings inline if instructions contain URLs or "ignore previous".
3. **Abilities** (tools): checklist of ActionService entries with user-language descriptions, grouped by
   sensitivity color (read only / changes things / needs approval). Each has an info line "can be undone: yes/no".
4. **Where and what it may touch**: folder picker for workspace (default a new folder), read-only folders,
   web allowlist chips, "never uses the internet" toggle. Defaults are the narrowest.
5. **When and how much**: Manual / schedule / when a file appears; budget sliders with real numbers ("at most
   15 minutes, 100 tool calls, no cloud spending"). Local-model-only default; cloud shows destination and cost cap.
6. **Test and approve**: Dry-run button > plan view; Evals result; the explain panel; Approve.

### 6.3 Dry-run
Shows: "If I ran now I would: 1. search the web (3 queries)... 2. write 4 files in ~/Axiom-Agents/x/ ...",
estimated tokens/cost/time, and which steps would ask you. Nothing is changed. A second button "Test run
(safe sandbox)" executes against a scratch workspace with fixtures. The dry-run output is generated by the
runtime from `dry_run` results, not by asking the model to describe itself (a model's self-description is not evidence).

### 6.4 "What can this agent do" panel (the trust surface)
Generated by the runtime from validated `agent.json` + registry metadata, never from agent-written text:

```
Idea Finder  v0.3.0   Source: built-in template   Hash 3fa9...   Checks: valid, 0 warnings, evals 8/8 on qwen3:8b
CAN                                        CANNOT
 Read   the web on 3 sites (GET only)       Run commands or scripts
 Read   ~/Projects/Axiom/docs/research/     Use your passwords or keys
 Write  ~/Axiom-Agents/research-finder/     Touch anything outside those folders
 Use    local model qwen3:8b (nothing leaves this PC except the 3 sites above)
LIMITS  15 min, 100 tool calls, 0 USD, max 6 runs/day, runs alone only when you start it or Mon 08:00
ASKS YOU BEFORE  anything that changes things outside its folder
CAN BE UNDONE  its file writes: yes (kept in versions); web reads: n/a
```
Plus "Changes since last approved version" (capability diff) and "Warnings" (e.g. "reads private files AND
fetches web pages AND could send data: unattended runs blocked").

### 6.5 Built-in template: "Research Team" (Finder > Judge > MVP-builder)
Basis: the pipeline used for this project's research (Track 0-4: a finder gathers candidates with sources,
a judge tests them against evidence and counter-evidence, a builder turns survivors into a bounded MVP spec).
Re-expressed as data, not as the prompts that ran here.

| Role | Purpose | Tools (action ids, indicative) | Reads | Writes | Sensitivity |
|---|---|---|---|---|---|
| Finder | Collect 10-25 candidate ideas/pains, each with source URL, date, quote | `web.search`, `web.fetch` (host allowlist from user), `memory.write` | topic file | `01-candidates/candidates.jsonl` | OBSERVE-NORMAL |
| Judge | Score each candidate by rubric (demand, evidence strength, fit, cost, risk); run a counter-evidence pass; reject uncited items | `files.read` (workspace only), `web.fetch` (only for liveness of cited URLs, same allowlist) | candidates | `02-verdicts/verdicts.jsonl` (score, reasons, kill reasons) | OBSERVE-NORMAL |
| MVP builder | For the top N (user-set, default 3): problem, user, smallest MVP, cut list, test plan, "claims we must not make" | `files.read`, `files.write` (workspace) | verdicts | `03-mvp/<slug>.md` | NORMAL |

Deterministic around the models: topic + criteria form (typed inputs, like HA blueprints); URL dedupe;
JSON Schema check of every JSONL line; HEAD-check that cited URLs exist; score arithmetic (weights are data,
the model only fills per-criterion numbers); top-N selection; budgets; the gate "review shortlist" between
Judge and Builder; final gate before anything leaves the workspace. Default network off for Judge/Builder.
Eval cases: seeded from the owner's aiskills-library evaluation-cases.json and a few synthetic pains
(uncited claim must be rejected; duplicate URL deduped; budget exhaustion stops cleanly). Default model
class local-small for Judge scoring is an assumption **(unv., must be measured)**; the template declares
`needs: [json_schema]` and the eval decides.

### 6.6 Other builder UX points
- Everything editable has a "Show what changed" and "Undo this edit" (versions dir).
- Import: drag a folder/zip or paste a git URL; Axiom scans without running anything, shows the same panel,
  default memory off, default unattended off, `scripts/` stripped with explanation. No store browsing in v0.
- Kill button always visible on any running agent (shell panel) and a global "Stop all agents".
- Accessibility and tokens: S1 (Theme tokens only), keyboard-complete flows.

---------------------------------------------------------------------------------------------------
## 7. Duet and Team front-ends: one runtime, what depends on what

| | **Duet** (one agent beside the user) | **Team** (many agents, background) |
|---|---|---|
| Session | Foreground, user present, side panel/overlay | Background units; results in an inbox + notifications |
| Gates | Inline prompts in the panel | `awaiting_gate` items in an approvals inbox; unattended ceiling OBSERVE |
| Needs from runtime | agent def v0, ActionService with metadata, router (local first), validator, policy, audit, kill | all of Duet plus run state machine, checkpoint/resume, systemd user timer/path generation, budget pool, handoff validator, workspace dirs, notification/approval inbox, per-run cgroup limits |
| Triggers | manual only (plus "run on current selection") | schedule, file_changed, handoff |
| Memory | agent scope, plus optional "this session" run scope | agent + team workspace |
| Multi-model hardware | one model call at a time | `max_concurrent_model_calls` (likely 1 on local-only machines, so a "team" is mostly sequential there; say so in UI) |
| Sandbox need | none beyond typed actions | same; any non-typed worker (MCP servers) waits for Phase 11 Warden decision |

Build order: Duet first (it validates the definition format, panel, audit and dry-run with a human always present),
then Team (adds unattended risk). A Duet agent is literally a team of one with `unattended: OBSERVE` and no
handoffs, so no second runtime. Both depend on D2 ActionService (with seam additions below), Phase 11 for
SENSITIVE-class actions from agents and for secret refs, and Phase 12 for the router/providers. Automate
(Phase 11) is the deterministic sibling: an "agent step" is one node type Automate may call, and Automate steps are
the same ActionService ids.

---------------------------------------------------------------------------------------------------
## 8. Mapping to ADR-022 seams and new seams AI needs now

| Seam | Use by the agent platform |
|---|---|
| S1 | Builder and panel read Theme tokens only (no per-agent colors) |
| S2 | `agent.json`/`team.json`/`approval.json` carry `schema`; unknown top-level keys ignored+warned; unknown keys inside security-relevant blocks fail closed; migrations automatic |
| S3 | Template list and capability catalog are data with defaults |
| S4 | File triggers/timers generated by an adapter, not hand-written units; scheduling lives behind a service |
| S5 | **Core dependency**: tools are ActionService ids with argument schema and sensitivity. This seam must be rich enough (below) or agents get blocked on a retrofit |
| S6 | Builder is a view inside the one Quickshell process/apps pattern, via `shell/services/*` |
| S7 | No agent runs a package manager; install paths via the Phase 7 helper only |
| S8 | Definitions/approvals/memory under `~/.config/axiom/agents/`; built-in templates read-only elsewhere; system rollback never loses them |
| S9 | **Defining constraint**: no executable user content. Agents are data; a daemon for agents needs its own ADR (plan: module + systemd units) |

### New seams to add NOW (cheap while ActionService is not yet built; each is a field or a rule, not a feature)

| # | Seam | Why it is needed early |
|---|---|---|
| **S10** | **Action sensitivity + effects metadata**: every ActionService entry declares `sensitivity` (OBSERVE/NORMAL/SENSITIVE/CRITICAL), `effects` (none/undoable/compensable/irreversible), `dry_run`, `idempotent`, `resources[]`, `destinations[]`, user-language description, JSON Schema 2020-12 args/outputs (MCP-wire-compatible) | Panel, gates, dry-run and unattended ceilings cannot be computed without it; retrofitting means touching every action |
| **S11** | **Actor identity on every call**: `ActionService.invoke(actor, action, args)` with `actor = {kind: user|routine|agent, id, version, hash, run_id, parent_run_id}`; UI calls pass `kind: user` | Attribution and "agent may not do what a user click may" need the caller known from the first action |
| **S12** | **Audit event format**: append-only JSONL, one line per action phase (intent/result/verify), fields: ts, actor, action, args_hash + redacted args, grant_ref, decision (allowed/denied/asked/answered), outcome, undo_ref, cost, secret-free by construction. Shared by Zones/Profiles/Automate/agents | One format for every feature; Automate will need it anyway |
| **S13** | **Reserved `secretRef` type** in settings and action argument schemas: a handle resolved by the executor, never a value, never logged. Actual store waits for the R4 ADR | Keeps "secrets never reach the model" true by construction when the store arrives |
| **S14** | **Resource scope vocabulary**: one grammar for path globs, hosts, apps, devices, used by profiles, Zones, Automate and agent grants | Avoids three incompatible permission languages |
| **S15** | **Cancellable long actions with job ids** and progress events | Kill, pause, budget stop need cancellable primitives |
| **S16** | **Shared-artifact package convention**: dir + manifest JSON with `schema`, canonical content hash, local lock/approval kept outside the package; used by profiles, routines, agents, teams | One import/scan/diff/rollback implementation for all shareable data (ADR-022 open choice on JSON vs TOML: this doc recommends JSON manifest + Markdown prose) |
| **S17** | **Untrusted-content wrapper** at the router boundary: every string entering a prompt carries provenance and trust level | Already implied by MODEL_ROUTER/MCP; make it a type, not a convention |

Also record: SYSTEM_AGENT_API.md "CRITICAL" is not expressible in agent definitions (`ceiling` max SENSITIVE);
cloud use is per-agent opt-in with visible destination (MODEL_ROUTER).

---------------------------------------------------------------------------------------------------
## 9. Round 3: counter-evidence, incidents, and what it changes

| Finding | Evidence (verification) | Consequence in this design |
|---|---|---|
| Shared skills are an attack channel | ClawHavoc: 341 malicious skills on ClawHub, macOS stealer (AMOS) payloads, ClickFix-style fake prerequisites (Koi via SC World/Antiy; secondary counts up to 1,103 less reliable). Snyk ToxicSkills (scan of 3,984 skills, 5 Feb 2026): 36.82% with at least one flaw, 13.4% critical; confirmed-malicious count conflicts (76 vs 1,467 in sources, **unv.**) | Data-only packages, scripts rejected, no store in v0, scan without executing, approval separate from package, import never auto-approves |
| MCP rug pull / impersonation | `postmark-mcp` npm impostor BCC'd outgoing mail for weeks (Sept 2025, secondary; accounts differ on how it was compromised). CVE-2025-54136 "MCPoison" in Cursor: approval keyed to path not content (secondary) | Approval bound to content hash; MCP tool-list hash pinned; annotations never trusted (spec says so itself) |
| Builders that embed code get RCE | Langflow: CVE-2026-33017 (unauth RCE via public flow endpoint, <1.9.0), CVE-2026-0770 (validate endpoint exec) and others (search results; verify on NVD) | No node graph with code nodes; no `exec`-like key accepted; no listener |
| Multi-agent failures are mostly specification and verification | MAST (Cemri et al.): 14 failure modes in 3 categories (specification, inter-agent misalignment, task verification) from 1600+ traces over 7 frameworks (arXiv 2503.13657, verified via search abstract) | Typed handoffs with output schema validation; deterministic verifier stage; evals mandatory for "verified" badge |
| Multi-agent costs and fit | Anthropic: agents ~4x tokens of chat, multi-agent ~15x; token use explained 80% of BrowseComp variance; failure modes: 50 subagents for simple queries, endless search for nonexistent sources, duplicated work; "most coding tasks" and shared-context tasks poor fit (verified, Anthropic post). Cognition "Don't Build Multi-Agents": shared context problem (verified only through secondary summaries; 15x claim secondhand) | Pipeline default, depth/breadth caps, effort scaling rule in template, team of one is first-class, UI warns when a team is not worth it |
| Runaway loops and bills | Widely repeated "$47,000 / 11 days / 4-agent loop" and "$6,531 AWS bill" stories: vendor blogs, **unverified**; consensus point that dashboards and alerts do not stop a loop, enforcement must be in the request path | Budgets are mandatory, enforced in the runtime before each call, hard platform maxima, no "unlimited"; local-first means cloud cost is opt-in |
| Framework abstraction hell | HN "Why we no longer use LangChain" thread (June 2024): layers of abstraction, hard to debug; CEO acknowledged "abstracted away too much" (search summary). AutoGen to maintenance mode after merging direction into Microsoft Agent Framework (repo notice per search) | Small closed schema, no plug-in framework, definitions are inspectable files, runtime ~ one loop |
| "Build anything" becomes config hell | Little direct evidence found for no-code agent builders in this session (stated gap). Inference from Claude Code silently ignoring unknown frontmatter fields (verified) and from the number of knobs in CrewAI/subagent specs: too many optional fields = silent misconfiguration | Few fields, strict validation, unknown security-relevant keys are errors, templates carry defaults, explain panel shows effective values |
| Instructions are not secret | Launch-era custom GPT instruction extraction (secondary) | Do not promise prompt secrecy; do not put secrets in instructions (validator scans) |
| Counter-example that works | Home Assistant: non-experts successfully use trigger/condition/action plus blueprints with typed inputs (**unv.** beyond the index page) | Keep the UX shape small and declarative; typed template inputs |

What failed in general builders: (1) they gave authority to artifacts, (2) they let users and models compose
unbounded graphs, (3) they treated loops/cost as observability, (4) they optimized the demo, not the 100th run
(evals, update stability). Axiom's answer is the same one as Profiles: a small closed schema owned by Axiom,
a runtime that enforces limits regardless of what the file or model says, and honest limits.

---------------------------------------------------------------------------------------------------
## 10. Risks and what we should NOT build

Risks (ranked):
1. **Prompt injection through tool results** causing a permitted but wrong action. Mitigation is scope and gates, not wrapping alone. Residual risk is real; say so.
2. **Local model quality**: small local models may not do reliable tool calling or schema output; the Research Team may be unusable on modest hardware. Unmeasured **(unv.)**. Gate: ModelChecker-style evals decide "verified on this model".
3. **Over-scope**: this is a platform on top of ActionService, router, sandbox and secret store that do not exist yet; it can eat the usable-core schedule. Phase it after the usable line (ADR-022 order).
4. **Approval fatigue** (users click yes): few prompts, narrow defaults, capability diffs only on growth, unattended OBSERVE ceiling.
5. **Memory poisoning / privacy leak** into memory files; secret scanner + user-visible files + forget.
6. **Unattended side effects while user away**: ceiling OBSERVE, gates pause rather than proceed.
7. **Schema churn** breaking users' agents: S2 migration promise, versions kept, tests with old fixtures.
8. Hardware contention (one GPU/CPU shared by compositor and a team): concurrency 1, cgroup limits, pause on battery.
9. Eval illusion: passing 8 cases is not safety; label badges "passed N checks on model M", not "safe".

Do NOT build (v0 and probably ever):
- A marketplace/store, ratings, auto-update from remote, or "install by name". Import from file/git only, scan, approve. (Revisit only with curated, signed, data-only packages and an ADR.)
- Executable anything in definitions: scripts, hooks, shell tools, code nodes, arbitrary MCP stdio launch without the MCP.md manifest and Phase 11 sandbox.
- Free-form agent-to-agent conversation, group chats, dynamic agent creation, self-modifying definitions, agents that edit their own `agent.json` or approvals.
- A visual node-graph editor, a general workflow engine (Automate already is the deterministic engine, capped at 10 steps).
- A vector database or hidden "long-term memory"; cross-agent implicit memory.
- Model-generated approvals or model-decided capability classes; trusting MCP annotations.
- Autonomous CRITICAL actions, unattended SENSITIVE actions, "bypass permissions" mode.
- A new resident daemon per agent or a scheduler of our own; A2A listener or any inbound network port.
- Persona fields (`backstory`, "role-play") as required config; self-tuning prompt loops; "unlimited" budgets.
- Cloud-hosted agent execution or sync of agent definitions that carries keys.
- Universal undo claims; rollback of external effects.

---------------------------------------------------------------------------------------------------
## 11. Open questions (max 5) and decisions they enable

1. **Canonical file: `agent.json` beside a pure-spec `SKILL.md` (recommended) or a frontmatter extension in one file?** Enables: S16 package convention and the profile/routine/agent shared format; importer and scanner design.
2. **Unattended ceiling: OBSERVE only (recommended) or OBSERVE plus NORMAL-with-`undoable` effects?** Enables: Team scope (a Downloads-tidier style agent needs file moves), the effects taxonomy in S10, and gate defaults.
3. **Is the runtime a module of `assistantd` plus systemd user units (recommended, no new daemon) or a separate `agentd`?** Enables: the ADR required by S9/AGENTS.md, process model, crash/kill semantics, Phase 12 split into 12a Duet / 12b Team.
4. **Where do memory and run logs live (S8 says `~/.config/axiom/`; logs and big memory suit `~/.local/state`/`share`) and what is backed up/exported with a profile?** Enables: retention defaults, "export my agent" contents, privacy statement.
5. **Do we accept importing third-party Agent Skills (`SKILL.md`) at all in v0, as instruction-only agents with zero tools and a scan, or only first-party/own-authored artifacts?** Enables: ecosystem interop claim versus supply-chain exposure (ClawHavoc/ToxicSkills); the seed library from aiskills-library (BUNDLE verdict) under the same rules.

Decisions enabled immediately without waiting: add S10-S17 to the D2 ActionService acceptance criteria and to
ADR-022's seam table; write the audit JSONL schema doc; draft the `axiom.agent/v0` JSON Schema file and
validator tests (malicious package fixtures: hidden unicode, scripts, hook keys, widening update, hash
mismatch, budget missing, CRITICAL requested, trifecta combination).

---------------------------------------------------------------------------------------------------
## Sources

Primary (fetched this session):
- Agent Skills specification: https://agentskills.io/specification
- MCP tools, spec 2026-07-28: https://modelcontextprotocol.io/specification/2026-07-28/server/tools
- A2A specification (first 100k chars read): https://a2a-protocol.org/latest/specification/
- Claude Code subagents: https://code.claude.com/docs/en/sub-agents
- Anthropic, multi-agent research system: https://www.anthropic.com/engineering/multi-agent-research-system
- OpenAI Agents SDK handoffs: https://openai.github.io/openai-agents-python/handoffs/
- CrewAI agents: https://docs.crewai.com/en/concepts/agents
- Home Assistant automation index page: https://www.home-assistant.io/docs/automation/
- Failed fetch (redirect, no content): https://langchain-ai.github.io/langgraph/concepts/low_level/

Search-derived (secondary; verify before quoting):
- MAST, Why Do Multi-Agent LLM Systems Fail?: https://arxiv.org/abs/2503.13657
- Cognition "Don't Build Multi-Agents" via summaries: https://jxnl.co/writing/2025/09/11/why-cognition-does-not-use-multi-agent-systems/
- ClawHavoc/ClawHub: https://snyk.io/articles/clawdhub-malicious-campaign-ai-agent-skills/ , https://www.antiy.net/p/clawhavoc-analysis-of-large-scale-poisoning-campaign-targeting-the-openclaw-skill-market-for-ai-agents/ , https://www.scworld.com/news/openclaw-agents-targeted-with-341-malicious-clawhub-skills , https://incidentdatabase.ai/cite/1368/
- Snyk ToxicSkills: https://snyk.io/blog/toxicskills-malicious-ai-agent-skills-clawhub
- postmark-mcp / MCP rug pull: https://dev.to/waxell/the-mcp-rug-pull-attack-the-threat-that-changes-your-tools-after-youve-approved-them-2km0 , https://www.speakeasy.com/resources/mcp-tool-poisoning
- Langflow RCE CVEs: https://www.csa.gov.sg/alerts-and-advisories/alerts/al-2026-092/ , https://www.wiz.io/vulnerability-database/cve/cve-2026-33017
- Runaway cost anecdotes (unverified, vendor blogs): https://dev.to/waxell/the-47000-agent-loop-why-token-budget-alerts-arent-budget-enforcement-389i , https://braindetox.kr/en/posts/ai_agent_6531_aws_bill_2026.html
- LangChain critique: https://octomind.dev/blog/why-we-no-longer-use-langchain-for-building-our-ai-agents , https://brianlovin.com/hn/40739982
- AutoGen maintenance / Microsoft Agent Framework: https://github.com/microsoft/autogen
- GPT Store leaks/monetization: https://venturebeat.com/ai/openai-launches-gpt-store-but-revenue-sharing-is-still-to-come

Repo (read-only): docs/ai/AGENT_SYSTEM.md, AI_ARCHITECTURE.md, MODEL_ROUTER.md, MCP.md, ROUTINES.md,
SYSTEM_AGENT_API.md (headings and class list only), docs/decisions/022-differentiation-direction.md,
docs/research/track-1-profiles.md, docs/research/track-2/4-mvp-zones-launcher-automate.md (ActionService
mentions only), scratchpad ai-d1-ai-tooling.md, ai-d2-security.md, ai-d3-other-repos.md.
Not read in full: JARVIS_01_ARCHITECTURE.md (skipped), Gaploom FUTURE_AGENTS.md itself (summary only).
