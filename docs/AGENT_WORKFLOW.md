# Portable agent workflow

The repository teaches the agent. [AGENTS.md](../AGENTS.md) is the shared entry point; [ARCHITECTURE.md](ARCHITECTURE.md), [DECISIONS.md](DECISIONS.md), [PHASES.md](PHASES.md), [SUBAGENTS.md](SUBAGENTS.md) and subsystem documents carry durable knowledge. Chat history, model preferences and a vendor's private memory are not project state. No CLAUDE.md or duplicate tool-specific architecture is required.

## Start and finish a significant task

1. Read AGENTS.md and identify the active phase and passed gates. Read relevant contracts, research and skill; inspect the existing implementation before proposing changes.
2. Define observable acceptance criteria, ownership, security boundary and required evidence. Choose the smallest coherent change.
3. Implement within ownership. Preserve unrelated work and ContextGit isolation; announce any need to touch another run's files before editing.
4. Run targeted checks, adversarial tests for sensitive paths, and benchmarks for performance claims. Compilation alone is insufficient. Record failures and tests that could not run.
5. Update canonical documents when behavior/architecture changes; use an ADR before reversing an accepted decision. Hand off files, evidence, residual risks and unresolved issues.

Architecture changes require a researched proposal: why the current design fails, alternatives, migration cost, compatibility, security/performance impact and rollback. Resolve routine choices within existing authority; a proposal is not authorization to publish, exfiltrate secrets or mutate external accounts.

## Ownership and independent review

| Stage | Owner | Deliverable |
| --- | --- | --- |
| Plan | Primary owner or architect/researcher | Phase scope, boundaries, alternatives, acceptance criteria |
| Implement | One Codex, OpenCode, Command Code or Freebuff owner | Small coherent change and targeted evidence |
| Security | Independent security role | Adversarial findings, exploit preconditions and residual risk |
| QA | Independent qa role | Contract/integration/failure outcomes and artifacts |
| Performance | Independent performance role when claims change | Reproducible results and uncertainty |
| Integrate | Primary implementation owner | Reviewed diff, resolved findings and integration evidence |

Use specialists when expertise, substantial research or independent scrutiny matters. Do not delegate every tiny task. Parallel agents own disjoint files or isolated worktrees; coordinate changes to shared contracts through the integrator. Reviewers report findings rather than approving by identity. Tool permissions and repository roles are different layers.

## Portable skills and this environment

The canonical discovery directory is `.agents/skills/<name>/SKILL.md`. Skills use the [Agent Skills specification](https://agentskills.io/specification): a folder with YAML `name` and `description`, followed by a focused workflow. Scripts/references/templates are optional and added only when useful. Do not add vendor metadata or preapproved tools to these shared workflows.

**Foundation environment limitation:** `.agents` is mounted read-only; creating `.agents/skills` was attempted and returned `Read-only file system`. Complete authoring artifacts therefore live durably under `portable-skills/skills/`, with the same relative link depth as their intended destination. This is a staging location, not an automatically discovered skill source. Use the repository's installation helper from a normal writable checkout, then validate canonical discovery. Until then, explicitly open the relevant staged SKILL.md. Do not maintain divergent copies; after installation, move canonical maintenance to `.agents/skills/` and remove staging once portability is verified.

Initial library: archiso-build, arch-pkgbuild, quickshell-ui, wayland-integration, rust-daemon, dbus-service, systemd-service, agent-system-api, threat-model, security-review, warden-policy, btrfs-transaction, performance-benchmark, qemu-integration-test, mcp-tool, provider-adapter, android-connect, release-check, omarchy-upstream. These are recurring engineering workflows, not permission to implement later phases now. No OS build or runtime scripts are supplied before their interfaces and environment exist.

## Tool integration

Compatibility was checked against upstream documentation on **2026-10-18**; installed clients still require a local discovery smoke test. Adapters are thin pointers, omit pinned models, and do not grant broad permissions. Agent prompts are not enforcement controls. Existing user/client permissions remain in force.

| Tool | Shared knowledge and workflow | Project adapter |
| --- | --- | --- |
| Codex | Root AGENTS.md; relevant nested AGENTS.md only when implementation exists; canonical skills and docs | No duplicated Codex architecture/configuration |
| OpenCode v2 | Read AGENTS.md and docs; canonical skills supported | `.opencode/agents/*.md` with `description`, `mode: subagent` and canonical role pointers |
| Command Code | Root AGENTS.md and docs; canonical skills supported | `.commandcode/agents/*.md` with `name`, `description` and canonical role pointers |
| Freebuff | Explicitly load AGENTS.md, architecture, decisions, phases and relevant workflow before implementation | No speculative format or duplicated project memory |

### Codex

Launch in the intended worktree and ask it to identify active instruction sources and phase. Official documentation describes root-to-working-directory instruction layering and repository `.agents/skills` discovery. Check global overrides if unexpected instructions appear; do not overwrite user configuration. Invoke a relevant skill explicitly when discovery is uncertain. Use canonical specialist role descriptions for delegated work without inventing a second architecture.

Sources: [instructions](https://developers.openai.com/codex/guides/agents-md), [skills](https://developers.openai.com/codex/skills).

### OpenCode

The adapters target **v2** documentation, which specifies plural `.opencode/agents/`. Earlier installations may differ; inspect installed version before assuming compatibility. Invoke the required role by its agent name and check that its prompt points to the canonical role. The eleven adapters cover the eleven domain roles; built-in Explore/Plan remain suitable for routine browsing/planning. Canonical `.agents/skills` is supported as a compatibility location. Never pin a provider merely to make an adapter load.

Sources: [agents](https://opencode.ai/v2/docs/agents), [skills](https://opencode.ai/v2/docs/skills).

### Command Code

Six high-value adapters cover architect, security, performance, researcher, qa and release. Reuse built-in General, Explore and Plan for routine implementation, search and planning instead of shadowing those names. Project Markdown agents have frontmatter and a prompt body; omitted model inherits session choice. Confirm loaded agents with `/agents` and skills with `/skills`, checking duplicates and user-level shadowing. Do not run `/init` over existing canonical instructions.

Sources: [agents](https://commandcode.ai/docs/agents), [memory](https://commandcode.ai/docs/memory), [skills](https://commandcode.ai/docs/skills).

### Freebuff

Use for bounded implementation, bug/compile fixes, tests, exploration, repetitive changes and secondary review. Supply acceptance criteria, owned files and the canonical document paths in the initial task. Ask it to read those files and report its phase before editing; do not assume that the existence of AGENTS.md in Freebuff's own repository proves automatic discovery for every release. This foundation verifies upstream project identity but does not certify a portable custom-agent/skill loader for Freebuff. A future adapter requires documentation and an installed-version test. Check current data-use settings before sending private repository or user data to any cloud model.

Sources: [official repository and product documentation links](https://github.com/CodebuffAI/freebuff), [upstream repository instructions](https://github.com/CodebuffAI/freebuff/blob/main/AGENTS.md).

## Discovery and handoff validation

In each installed tool, perform a read-only smoke task: identify canonical instructions, current phase, a specialist role and one relevant skill; explain a denied critical operation without running it. Record client version, loaded paths and unsupported behavior. This is distinct from parsing frontmatter: static validity does not prove runtime discovery or security. Do not claim installed-client compatibility until that test passes.
