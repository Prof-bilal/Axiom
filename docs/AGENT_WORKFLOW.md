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

## Portable skills

Authored skills live in `portable-skills/skills/<name>/SKILL.md` and are the only maintained copy. They follow the [Agent Skills specification](https://agentskills.io/specification): a folder with YAML `name` and `description`, followed by a focused workflow. `scripts/install-skills.py` copies them into `.agents/skills/` for local discovery; that directory is generated and not tracked. Do not edit the installed copies or add vendor metadata to shared workflows.

Initial library: archiso-build, arch-pkgbuild, shell-ui, wayland-integration, rust-daemon, dbus-service, systemd-service, agent-system-api, threat-model, security-review, warden-policy, btrfs-transaction, performance-benchmark, qemu-integration-test, mcp-tool, provider-adapter, android-connect, release-check, upstream-review. These are recurring engineering workflows, not permission to implement later phases now.

## Tool integration

The repository does not track tool-specific agent adapters. Any AI coding tool that reads [AGENTS.md](../AGENTS.md) and the documents above can work on the project. Role descriptions are in [SUBAGENTS.md](SUBAGENTS.md). Local tool configuration (for example `.opencode/`, `.commandcode/`, `.claude/`) stays on your machine and is git-ignored. Agent prompts are not enforcement controls; existing user and client permissions remain in force.
