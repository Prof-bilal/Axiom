# ADR-023: AI system direction (Jarvis) and rules

**Date:** 2026-11-10
**Status:** Accepted for the decisions below (owner answered "default" to every
open question, 2026-11-10). The rule-change rows R1-R7 are accepted as proposed
but canonical documents (`AGENTS.md`, `PHASES.md`, `ARCHITECTURE.md`,
`SECURITY.md`, `WARDEN_INTEGRATION.md`) are not yet edited; that is the next
step. R7 (token rotation) is an action for the owner, not a repository change.
Evidence: [AI synthesis](../research/ai-synthesis.md) and the reports it links.
Builds on [ADR-022](022-differentiation-direction.md) (seams S1-S9 and the
phase D plan).

## Context

Axiom's Phase 12 is an AI-native layer. The owner wants a Jarvis-style system:
user-built agents and teams, a way for cheaper models (including hosted
open-weight models such as DeepSeek, Kimi and GLM) to benefit from whichever
model is measured best at that task
("lessons"), and built-in multi-session agent management, with Shikigami
mentioned as a candidate. Research (wave 1 repo scans, wave 2 five research
tracks) found:

- Every incumbent the owner named (Grok Bot, Claude Duet, ChatGPT Dots, Meta
  Muse) is a vendor-hosted cloud VM. Local-first, user-owned agents on a real
  Linux desktop are unfilled.
- Coding-agent isolation in the current tools is weak or advisory. Shikigami is
  closed-source with redistribution prohibited and no stated agent isolation,
  and Warden's sandbox is unproven. The owner does not want to depend on
  ContextGit.
- Lessons help weaker models only with curated, focused content (SkillsBench:
  33.9% to 50.5%). Self-written skills and bloated skill sets hurt. Video is the
  wrong medium. No published study tests the owner's exact idea.
- Authority, not model quality, is the hard part. Prompt injection beats the
  published defenses under adaptive attack, and human approval gets rubber-
  stamped.

## Decision

1. **Jarvis is a platform, not an AGI.** Agents are user-built data
   (`SKILL.md` for instructions plus `agent.json` for authority, typed tools,
   grants, budgets and triggers). Authority is enforced by a deterministic
   broker, never by prompt text or another model.
2. **Front-ends:** Duet first (one visible agent; the working name is "Pair",
   since "Duet" is Anthropic's product), then Team. A Duet agent is a team of
   one, so there is one runtime.
3. **Lanes:** Lane 2 "system agents" call only typed `ActionService` actions
   through the broker. Lane 1 "developer sessions" are user-supervised coding
   agents in sandboxed clones (Axiom Sessions, an Axiom-owned engine). A
   session is a distinct low-trust caller and is never presented as "the Axiom
   AI".
4. **Authority:** effective authority is the intersection of the manifest
   request, the user grant, the parent ceiling, the lane ceiling, system policy,
   taint narrowing and remaining budget, recomputed on every call. SENSITIVE and
   CRITICAL grants are one-use. A deterministic taint rule raises egress to
   SENSITIVE once a session has seen both untrusted content and private data.
5. **Lessons:** the teacher is chosen per task area by measured score, from any
   provider (for example, one vendor's model for image-generation prompts,
   another's for coding), not fixed to one vendor. The user can also pin the
   teacher for any task area. Learners are cheaper models
   (local or hosted, reached through OpenCode, Command Code or the router). A
   lesson is text, so it can teach any model, but a lesson is only accepted for a
   learner after that learner's own score improves. Structured, sandbox-verified, private; never video;
   promoted to deterministic routines only after user approval. Shipping
   depends on a passing experiment (ModelChecker-style baseline, verify and
   compare on held-out deterministic cases).
6. **Runtime:** a module of `assistantd` plus systemd user units. Background
   runs are transient units with cgroup limits, so kill is one command that
   works without the model. The broker runs as a dedicated unprivileged UID and
   its own ADR justifies that daemon in Phase 11.
7. **Shikigami** is not bundled and not installed by default. The Developer Hub
   shows its icon as an optional entry, with a clear "external, not sandboxed or
   audited by Axiom" label. The user chooses to install it, and the install
   links to the vendor's official download. Axiom never hosts or redistributes
   it.
8. **Your repos** contribute as listed in the synthesis (section 4): Warden as a
   conditional sandbox (Phase 11), ContextGit's *ideas* (worktree per run, task
   claims, quality gate) re-implemented in Axiom and not depending on it, aisskills
   and smurf as concepts, aiskills-library and ModelChecker as bundled data and
   dev tools.

## Rule and process changes (owner may veto each row)

| # | Proposed change | Why | Stability, privacy, security impact |
|---|---|---|---|
| R1 | Record Phase 12 as 12a (Duet, builder v0, sessions preview, Research Team template) and 12b (Team, lessons if the experiment passes, routine promotion with approval) in `PHASES.md` | Gives the work exit criteria | None: documentation |
| R2 | Add seams S10-S17 (action metadata, actor identity, one audit format, `secretRef`, one resource-scope vocabulary, cancellable jobs, a shared-artifact convention, an untrusted-content wrapper) to the acceptance criteria of D2 `ActionService` | Cheapest while ActionService is unbuilt; the AI layer depends on them | Strengthens safety (audit, actor identity, untrusted content) |
| R3 | Add to `SECURITY.md`: model output is untrusted until the broker validates it; shared artifacts and lessons are untrusted input; authority is the intersection described above; sessions are never "the Axiom AI" | Found by the security research | Strengthens security |
| R4 | Correct `WARDEN_INTEGRATION.md` (it says Phase 7; `PHASES.md` says Phase 11) and the `JARVIS_01_*` docs that state "all agents run in Warden sandboxes" as settled | Doc inconsistencies found by D2 and F | None; prevents false claims |
| R5 | Require an ADR for each new daemon: `assistantd` module (ADR-023 covers the module) and the dedicated-UID broker (its own Phase 11 ADR) | AGENTS.md: every daemon needs justification | Strengthens: forces review before a privileged process exists |
| R6 | No security claims about agents on the labwc harness until the Axiom compositor exists; the claims list in the synthesis (section 8) applies | labwc lets unsandboxed clients capture and inject input | Strengthens honesty |
| R7 | Credential hygiene: rotate or revoke the tokens listed in the synthesis (section 11) and add LICENSE files where missing | Exposure found by scans | Strengthens privacy and supply-chain safety |

**Not changed:** AI never gets unrestricted root, sudo or shell; UI never runs
as root; privileged APIs are narrow and authorize caller, operation and target;
secrets stay out of the repository, logs and the model; Wayland and portal
boundaries; the core desktop works without cloud AI; deterministic routines
replace model calls where possible; performance and gain claims require
measurements.

## Alternatives considered

- **Build Shikigami in.** Rejected: closed source, redistribution prohibited,
  no stated isolation. Possible only as a user-installed link.
- **Build an AI social network with video lessons.** Rejected: video is lossy
  and expensive, and every working system converts it to structured text first.
  Kept only as structured, verified lessons in a private library.
- **Depend on ContextGit as the session engine.** Rejected by the owner, and it
  would add a Python runtime to the image. The session engine is Axiom-owned and
  built from the same ideas (one git clone or worktree per session, a task
  record, a quality gate before merge), using only git, tmux and systemd user
  units.
- **One agent format with authority inside `SKILL.md` frontmatter.** Rejected:
  the Agent Skills metadata field only holds strings, and third-party tools may
  reject unknown keys. Authority lives in `agent.json`.
- **Unattended autonomous agents first.** Rejected: this is where incumbents are
  failing, and it needs the Phase 11 sandbox to exist. Observe-only until then.

## Consequences and migration cost

- No code is written by this ADR. Phase 12 starts only after Phase 11 evidence.
- Host-side work that can start now: the lessons experiment (ModelChecker, a
  open-weight model reached through an API, with cost capped), and the credential and licence hygiene
  (R7).
- **Vendor terms (checked 2026-11-10):** Anthropic's consumer and commercial
  terms restrict building competing models from the Services but do not expressly
  restrict using Outputs. OpenAI's terms (secondary sources, its page was not
  fetchable) prohibit using Output to develop models that compete with OpenAI.
  So OpenAI outputs are **disabled as teacher material by default** until legal
  review; this is an engineering default, not legal advice.
- Hosted learner models send lesson and task text to a third-party provider.
  Redaction and per-task approval apply before any such call (ADR-022 S8, the
  secret rules). Results must report the model, provider and cost.
- The dev machine has 7 GB RAM and no GPU, so local-model experiments would be
  slow; hosted open-weight models are the practical first learners.

## Review and rollback

Independent review is required before Phase 11 security code, before Lane 1
sessions run any tool, and before any lesson is promoted to a routine.
Everything here is additive and documentation-only today; reverting means
deleting the new documents, and git holds the history.

## Open choices

The owner's answers replace the defaults in the synthesis, section 10. The
important ones: the first audience (developer and maker workflows is the
default), the single-agent name, whether shared or imported agents exist in v0
(default no), and whether the Phase 11 broker daemon is accepted (default yes,
with its own ADR).
