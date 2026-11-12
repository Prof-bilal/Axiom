# AI system synthesis (Track G): Jarvis

Date: 2026-11-10. Merges the AI research tracks. Method: wave 1 = three
read-only scans of the owner's repos (D); wave 2 = five research agents with 3
rounds each (A landscape, B agent builder, C lessons, E multi-session, F
security); this document and
[ADR-023](../decisions/023-ai-system-direction.md) (Proposed) are wave 3.
Reports: [A](ai/a-landscape.md), [B](ai/b-agent-builder.md),
[C](ai/c-lessons.md), [D1](ai/d1-ai-tooling.md), [D2](ai/d2-security.md),
[D3](ai/d3-other-repos.md), [E](ai/e-multisession.md),
[F](ai/f-security.md). Reddit was not reachable by the tools; many vendor
pages were not either, so product facts come from secondary coverage and prices
conflict. Nothing here was run or measured; every effort figure is an estimate.

## 1. Direction in one paragraph

**Jarvis is a platform, not an AGI.** Users build, run and own their own agents
and teams on their own machine. The model proposes; the system decides. Every
authority is a typed, revocable grant enforced by deterministic code, never by
prompt text or another LLM. It works offline, agent memory is plain files the
user can read, and agents cannot get root. Build **Duet first** (one visible
agent, every action an approved typed request), then Team. This is the gap
every incumbent leaves open: all four products you named (Grok Bot, Claude
Duet, ChatGPT Dots, Meta Muse) run in a vendor-hosted cloud VM.

## 2. What each of your four ideas became

| Idea | Verdict | Form it takes | Phase |
|---|---|---|---|
| 1. Grok-bot-style team plus Claude-Duet-style companion, and user-built agents of any kind | **Keep, narrowed** | One runtime, two front-ends. An agent = instructions + typed tools + capability grants + memory scope + trigger + budgets. A Duet agent is a team of one. Shared artifacts are data, never code | 12a Duet, 12b Team |
| 2. AI social network/YouTube where big models teach smaller models | **Keep the idea, drop the form** | Structured, sandbox-verified *lessons* from a frontier model, applied by cheaper learners (open-weight models via OpenCode, Command Code or the router), kept in a private library. No video, no social feed. Community exchange is a much later, separate ADR. Ships only if an experiment passes | 12b, gated by an experiment |
| 3. Scan my repos for what fits Axiom | **Done** (see section 4) | Verdict per repo | Now |
| 4. Shikigami built in | **Not bundled; shown as an option** | The Developer Hub shows Shikigami's icon. The user chooses to install it, and it links to the vendor's download. Axiom does not sandbox or audit it. The built-in is "Axiom Sessions", an Axiom-owned engine | Hub icon now; Axiom Sessions preview in 12a |

## 3. Evidence that decided things

- **Landscape (A).** All four named products exist as reported (vendor pages
  were unreachable, so this rests on secondary coverage; re-verify before
  quoting). Gaps no incumbent fills: local-first, memory as plain files,
  authority enforced by code, user-built agents with revocable grants on a real
  Linux desktop, a safe supply chain (OpenClaw's ClawHub had 341 malicious
  skills in one audit), and hard per-agent budgets. Anthropic's Duet is a
  proactive background agent on a cloud VM, not "one agent beside you", so our
  Duet needs a different name. Avoid "AGI", "your whole team", "autonomous" and
  unqualified "secure".
- **Agent builder (B).** An agent is a directory: a spec-valid `SKILL.md`
  (instructions only) plus `agent.json` (typed tools, requested grants, mandatory
  budgets, memory scope, triggers, evals, provenance). Approval is a separate
  local record bound to the content hash; any edit voids it. Teams use fixed
  topologies, typed handoffs, depth ≤ 2, breadth ≤ 4, no agent-to-agent chat.
  Model-driven part: only "propose the next typed call". Everything else
  (validation, policy, budgets, gates, retention) is code.
- **Lessons (C).** Curated skills lift pass rates from 33.9% to 50.5% on
  SkillsBench (87 tasks, strong evidence), and a small model with skills beat a
  larger one without them. But skills the model writes for itself gave −1.3 pts,
  2-3 focused skills beat 4+, and 16 of 84 tasks got worse. Every working video
  system first converts video into structured trajectories, so **video is the
  wrong medium**. No study tests a big-model-authored, sandbox-verified lesson
  given to a model of 8B or less, so the experiment is worth running and its
  outcome is unknown. Memory poisoning reached 77-98% success in published
  attacks, so lessons are untrusted input.
- **Sessions (E).** Shikigami is closed-source with redistribution prohibited
  and states no agent isolation. ContextGit's isolation is advisory (the
  caller identity is an environment variable). The recommended build: reuse
  ContextGit's ideas, re-implemented in Axiom (no dependency on ContextGit), and add an Axiom Sessions
  Quickshell app, run each session as a transient systemd user service inside
  an Axiom-owned sandbox (fake home, scrubbed environment, egress only through an
  allowlisting proxy, seccomp, cgroup), one tmux server per session, a separate
  clone per session by default, and a distinct `axiom` MCP server for Lane 2
  typed capabilities.
- **Security (F).** Effective authority = manifest request ∩ user grant ∩
  parent ceiling ∩ lane ceiling ∩ system policy ∩ taint narrowing ∩ remaining
  budget, recomputed by a broker on every call. A deterministic "rule of two"
  taint tracker raises egress actions to SENSITIVE once a session has seen both
  untrusted content and private data. SENSITIVE and CRITICAL grants are one-use;
  a kill switch bumps a policy generation. Biggest residual risks: prompt
  injection with legitimately granted authority; the same-UID boundary (on the
  labwc harness any unsandboxed client can capture the screen and inject input);
  and humans approving plausible but harmful requests (users accepted 93% of
  manual prompts in one report).

## 4. What you already own (repo scan D)

| Repo | Verdict | Use |
|---|---|---|
| Warden | **BUNDLE, conditional** | Linux sandbox for tool and MCP workers at Phase 11, once its bypass matrix passes and a typed API exists. First-party, MIT, single Go binary, no resident daemon, fails closed. Lacks seccomp, Landlock, cgroups; audit is strace-based and post-hoc; disable self-update |
| ContextGit | PORT-CONCEPT only (owner: do not depend on it) | Ideas only: worktree per run, task graph, claims, quality gate before merge. Re-implemented in Axiom using git, tmux and systemd units. Not shipped, not a dependency |
| aisskills | PORT-CONCEPT | Manifest, lockfile, scan-without-run, untrusted wrapper. Its `guard` is string-level, so it cannot be the enforcement boundary |
| aiskills-library | **BUNDLE as data** | Plain SKILL.md files, playbooks, eval cases: seed skills/lessons after a quality pass |
| ModelChecker | **BUNDLE as dev/CI tool** | Baseline/verify/compare gate for lessons and agents. Needs trajectory and side-effect scorers |
| CodeAtlas/RepoSpine | RECOMMEND-ONLY | Optional Developer Hub install; port its budgeted-context idea. It is retrieval, not distillation; its own 48-run pilot is anecdotal |
| smurf | PORT-CONCEPT (highest value) | Working multi-agent orchestrator: worktree per task, verify-then-review, human escalation. No licence; do not bundle |
| seduler, Gaploom | PORT-CONCEPT | Feed Axiom Projects: seduler's planned-sprint "today" first, deterministic pick as fallback; Gaploom's idea/evidence schema and `FUTURE_AGENTS.md` role design |
| OpenEye | PORT-CONCEPT | Bounded inhibitor lease as an `ActionService` action; do not bundle a second daemon or Qt tray |
| ShieldCI, Vorynex | PORT-CONCEPT (narrow) | Install-gating (ShieldCI); Landlock spawn-time and learn-then-review policy (Vorynex; proprietary licence, so concept only) |
| Bootlane | MARKETING-ASSET | v86 is 32-bit, so at most a CLI-only demo |
| portfolio | MARKETING-ASSET | Add an Axiom case study |
| CodeAtlas-ui, niubigeo, EventSphere, frontend | SKIP | Unrelated or empty |
| my-new-project | PORT-CONCEPT | Seed content after a provenance and licence check |

## 5. Architecture in one picture

```
 User ── GUI builder (Quickshell) ── agent/team files (data)  ┐
                                                              │ validated, hashed, approved
 Duet / Team front-ends ── runtime (module of assistantd) ────┤
        │  model proposes typed calls                         │
        ▼                                                     │
 Broker: grants ∩ policy ∩ taint ∩ budget ── audit (JSONL) ───┘
        │ typed actions only (ActionService, D2)
        ▼
 Sandboxed workers (Warden + Landlock/seccomp/cgroups), egress proxy, secret handles
 Lane 1: Axiom Sessions (coding agents in sandboxed clones) ── axiom MCP (Lane 2 tools)
 Lessons library (local) ── verified by ModelChecker-style gate ── promote to routines
```

## 6. Roadmap placement (consistent with ADR-022)

1. **Now, host-side, no phase needed:** run the lessons experiment with
   ModelChecker (it decides whether lessons ship); revoke the exposed tokens;
   fix the licence and doc issues in section 9. The dev machine has 7 GB RAM
   and no GPU, so local models would be slow; a hosted open-weight learner with capped cost is the realistic first target.
2. **Phase D2 (ActionService):** add seams S10-S17 to its acceptance
   criteria while it is unbuilt (the cheap moment): action metadata
   (sensitivity, effects, `dry_run`, resources, destinations), actor identity on
   every call, one audit JSONL format, a reserved `secretRef` type, one
   resource-scope vocabulary, cancellable long actions, a shared-artifact
   package convention, and an untrusted-content wrapper at the router boundary.
3. **Phase 11:** broker, sandbox layering (Warden + Landlock/seccomp/cgroups),
   secret store, audit, compositor gating, and a dedicated-UID broker/audit
   daemon (needs its own ADR). **No security claims about agents on the labwc
   harness.**
4. **Phase 12a:** agent builder v0, **Duet**, Axiom Sessions preview (Lane 1),
   built-in Research Team template, Linux-native local router.
5. **Phase 12b:** Team (checkpointing, budget pool, approvals inbox),
   lessons if the experiment passed, routine promotion with user approval.
6. Later, separate ADRs: community exchange, unattended write actions,
   third-party `SKILL.md` import, voice.

Estimates (agents' own, ±50%): sessions ~3 months to a labelled preview after
D2 and 6-8 months part time to a reviewed version; the rest is not estimated.

## 7. Rules check against AGENTS.md

| Rule | Verdict | Note |
|---|---|---|
| AI never gets unrestricted root, sudo or shell | Holds | Lane 2 is typed actions only. Lane 1 is a *user-supervised sandboxed* developer tool, never "the Axiom AI". Needs the wording in ADR-023 |
| UI never runs as root; privileged APIs narrow | Holds | The broker runs as a dedicated unprivileged UID, not root |
| Secrets out of repo, logs and the model | Holds, gated | Secrets are handles bound to a host; no secret store exists yet, so anything that stores secrets waits for Phase 11 |
| Wayland and portal boundaries | **Open risk** | labwc lets any unsandboxed client capture and inject; agent sandboxes never get a Wayland socket |
| Core desktop works without cloud AI | Holds | Cloud is a router option, never required |
| Deterministic routines avoid model calls | Holds, strengthened | Validation, policy, budgets, gates and retention are code; verified lessons compile to routines |
| Every daemon justified | **Needs ADRs** | `assistantd` module and systemd units (no new daemon for runtime); the Phase 11 broker/audit UID daemon needs its own justification |
| Attribute actions, verify, test recovery, no universal undo | Holds | Flight recorder with honest undo limits |
| Measure performance claims | Holds | No lesson-gain, cost or latency number until measured |

**No security or privacy rule needs weakening.**

## 8. Claims we may not make

| Claim | Why not | Earliest |
|---|---|---|
| "AGI", "autonomous", "your whole team" | Unsupportable; "agent washing" is widely called out | Never |
| "Agents can't get root" / "secure agents" | Only true with the broker, sandbox and tests in place; false on the labwc harness | After Phase 11 evidence |
| "ChatGPT can teach Claude images" (as a lesson) | Claude has no native image generation (verified in several sources; Anthropic's position reported secondhand). A lesson can teach Claude to write a prompt and call an image tool through MCP, not to draw | Never as "Claude draws" |
| "Cheaper models learn from frontier models" | Weights do not change; only retrieval or routines. Say "apply verified lessons" | Never in that wording |
| Any % gain from lessons | No experiment run | After the experiment |
| "Shared agents are safe" | Static scanners reportedly catch about 21-35% of skill-style injection | Never unqualified |
| "Every agent runs in Warden" | Warden's gates are unverified (existing docs overstate this) | After its bypass matrix passes |
| Shikigami is "included" | Licence forbids redistribution | Never |

## 9. Where I disagree, and challenges for you

1. **Sessions as a flagship is a risk.** The session engine is new work, and sandboxing a coding agent that needs network and a
   toolchain is hard. Treat Axiom Sessions as a preview until reviewed.
2. **The lessons idea may fail its experiment.** Do not build library, social
   or routine-promotion code before the result exists.
3. **Phase 11 is now the critical path.** Agents are only as safe as the
   broker and sandbox, and Warden's sandbox is unproven. If Phase 11 slips, Duet
   ships as read-only observe mode, not as an acting agent.
4. **No Python dependency for sessions.** Since the owner dropped ContextGit,
   the engine uses only git, tmux and systemd user units, so no Python runtime
   is added for it.
5. **Your existing docs overstate.** `WARDEN_INTEGRATION.md` says Warden lands
   in "Phase 7" but `PHASES.md` says Phase 11, and the `JARVIS_01_*` docs state
   "all agents run in Warden sandboxes" as settled. List and correct on ADR
   acceptance.
6. **The "Duet" name is taken** by Anthropic's product. Use a working name
   such as "Pair" until you choose.

## 10. Your decisions (my default in bold; say "defaults" to accept all)

| # | Question | Default |
|---|---|---|
| 1 | First audience | **Developer and maker workflows first** (Projects, Research Team, repo tasks); general personal tasks later |
| 2 | Models | **Both**: local models and bring-your-own cloud key through the router; cloud never required |
| 3 | Shared/imported agents in v0 | **No**: first-party and self-authored only; instruction-only third-party `SKILL.md` import later, scanned |
| 4 | Name for the single-agent mode | **"Pair"** (working name) |
| 5 | Duet first, Team deferred | **Yes** |
| 6 | Agent file layout | **`agent.json` beside a pure-spec `SKILL.md`** |
| 7 | Unattended ceiling | **OBSERVE only** until the Axiom compositor exists |
| 8 | Runtime process | **Module of `assistantd` plus systemd user units**; broker as a separate dedicated-UID daemon, justified in its own Phase 11 ADR |
| 9 | Where memory and logs live | **Config in `~/.config/axiom/`, data in `~/.local/share/axiom/`, state and logs in `~/.local/state/axiom/`** (clarifies S8) |
| 10 | Lessons: learner models | **Cheaper hosted open-weight models first** (e.g. DeepSeek, Kimi, GLM via OpenCode or Command Code), with cost capped; local small models later, if at all |
| 11 | Lessons: teacher | **Chosen per task area by measured score, from any provider, and the user can pin a teacher per task area.** Its solved traces become lessons; the learners apply them. Vendor terms checked 2026-11-10: Anthropic's terms do not expressly restrict using Outputs; OpenAI's terms prohibit using Output to develop competing models, so OpenAI outputs are disabled as teacher material by default until legal review |
| 12 | Promote a lesson to a routine | **Always proposal plus user approval** |
| 13 | Community exchange | **File import/export only** in v1 |
| 14 | Verification harness | **ModelChecker as an external dev/CI tool first**; port only if lessons ship |
| 15 | Sessions: flagship or convenience | **Preview now, flagship only after review** |
| 15a | Shikigami in the Developer Hub | **Show the icon; install only if the user chooses; link to the vendor download; label it external** |
| 16 | Lane 1 session without a sandbox | **Never (fail closed)** in v1 |
| 17 | Session default | **Separate clone** per session (stronger, more disk) |
| 18 | First agent adapters | **Claude Code, Codex, opencode**; credentials via secret handles where possible, otherwise an explicit grant |
| 19 | Dedicated-UID broker daemon | **Accept**, with its own ADR in Phase 11 |
| 20 | Security claims on the labwc harness | **None** until the Axiom compositor exists |
| 21 | Ask Shikigami's author whether Axiom may link to the official AppImage from its Hub entry | **Yes, before shipping the entry**; until answered, the entry links to the vendor page only |

## 11. Hygiene items from the repo scans

- **Revoke or rotate tokens.** smurf's TODO says a root `.env` still holds an
  old server token; aisskills' `HANDOFF.md` says two npm tokens were pasted in
  chat; a GitHub token file exists at `~/.config/aiskills-bench-github-token`.
  The agents saw no values.
- **Add LICENSE files** to Gaploom, seduler, Bootlane, portfolio, smurf and
  my-new-project. aisskills depends on the unlicensed smurf; Warden has three
  non-owner authors, and OpenEye's MIT notice names a different copyright
  holder. Check authorship before any bundling.
- Gaploom's git directory is `.git-real`; OpenEye's source is duplicated in
  `Insomnia/`; CodeAtlas's `.mcp.json` points at a stale `ContextGit-pr-7` path.
- Warden's pin in Axiom is stale (v0.1.17 versus v0.2.0-beta.4 or later).

## 12. Not verified

All runtime behavior (nothing was run). Vendor pages for the four named
products. Most CVE ids and incident counts (aggregator sources; check NVD).
labwc `privilegedInterfaces` behavior; whether xdg-desktop-portal-wlr
implements RemoteDesktop. Shikigami's RAM, telemetry and isolation. Local small
models' tool-calling quality. Gaploom's commit history.
