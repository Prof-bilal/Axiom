<!-- contextgit:begin -->
## Parallel runs (managed by ContextGit)

Each run works in its own git worktree. Stay inside the files you own;
if you must touch a file owned by another run, say so before editing.

<!-- contextgit:end -->

# Axiom: shared agent instructions

Build an AI-native Linux desktop for developers with safe structured automation, privacy, recovery and measured performance. The repository is project memory; no tool or chat is authoritative over maintained project contracts.

**Current phase: Phase 0, foundation and validation.** This task creates documentation/workflows only. No distro implementation is authorized yet. Phase changes require the exit evidence in [PHASES](docs/PHASES.md).

## Architecture and map

Approved direction: Arch x86-64; upstream `linux` plus `linux-lts`; systemd and UEFI systemd-boot; Plasma 6/KWin/Wayland; Qt 6/QML UI; Rust backend; D-Bus first, Unix sockets only with justification; Btrfs/Snapper; pacman/PKGBUILD; archiso; Calamares initially. Reuse PipeWire/WirePlumber, NetworkManager, BlueZ, Mesa; optional Flatpak applications. SQLite/FTS5 for local metadata. Providers remain replaceable; MCP grants no authority. Warden is RESEARCH until exact upstream and enforcement behavior are verified.

- `docs/`: product, architecture, contracts, security, phases and evidence.
- `.agents/skills/`: canonical portable workflows; read the relevant SKILL.md. In this restricted session only, `portable-skills/` stages their contents; see README.
- `docs/SUBAGENTS.md`: canonical roles; tool adapters only point there.
- `scripts/`: deterministic foundation validation/skill installation.
- Future `apps/`, `shell/`, `services/`, `security/`, `packages/`, `iso/`, `installer/`, `branding/`, `tests/` exist only when implementation warrants them.

## Non-negotiable rules

AI never gets unrestricted root or arbitrary sudo/shell passthrough. UI never runs as root. Privileged APIs are narrow and independently authorize caller, operation and target. Sensitive actions require authorization; critical actions never execute silently. Deny missing/invalid authority. Keep secrets out of repository and logs. Preserve Wayland boundaries. Attribute actions, verify changes and test recovery where practical; never promise universal undo. Core desktop works without cloud AI. Deterministic routines avoid unnecessary model calls. Every daemon and new privileged component requires justification. Reuse mature Linux primitives. Performance claims require measurements.

## Work and completion

Read this file, current phase, relevant docs/skill and implementation. Define acceptance criteria, respect ownership, implement the smallest coherent change, run targeted tests plus adversarial checks for security changes and benchmarks for performance claims. Report uncertainty. Do not replace core technologies opportunistically: research, document migration/security/performance/rollback impact and record an ADR before major changes.

Documentation follows behavior/architecture changes; link canonical contracts rather than copying them. Label V1/LATER/RESEARCH, targets versus measurements and unverified assumptions. No fabricated APIs, compatibility, benchmarks or empty TODO scaffolds. Add nested AGENTS.md only with real subsystem directories; no CLAUDE.md.

Done means implementation complete, targeted tests and integration pass, failure and security behavior addressed, reproducible build evidence retained, no known regression, documentation updated, and applicable benchmarks/recovery tests recorded. Foundation changes use `python3 scripts/validate-repo.py`; `python3 scripts/install-skills.py` is available only when `.agents` is writable. ISO/package/VM commands are future upstream procedures, not implemented project wrappers.

Read [architecture](docs/ARCHITECTURE.md), [decisions](docs/DECISIONS.md), [security](docs/security/SECURITY.md), [testing](docs/engineering/TESTING.md) and [workflow](docs/AGENT_WORKFLOW.md). No feature advances merely because code exists.
