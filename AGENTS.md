<!-- contextgit:begin -->
## Parallel runs (managed by ContextGit)

Each run works in its own git worktree. Stay inside the files you own;
if you must touch a file owned by another run, say so before editing.

<!-- contextgit:end -->

# Axiom: shared agent instructions

Build an AI-native Linux desktop for developers with safe structured automation, privacy, recovery and measured performance. The repository is project memory; no tool or chat is authoritative over maintained project contracts.

**Current development: Phase 3 — authorized 2026-10-28 by the owner’s desktop-shell execution brief. Phase 2 foundation exit met 2026-10-28; installer-release, hardware, update and security gates remain separate.** Follow the sequential subphase gates and evidence in [PHASES](docs/PHASES.md) and [desktop research](research/desktop-shell/README.md). Phase 1 (repeatable archiso build + QEMU boot) exited 2026-10-25 ([PHASE1_EVIDENCE](docs/engineering/PHASE1_EVIDENCE.md)); its archiso profile is retained as legacy evidence. Phase 2 is the **Omarchy-derived foundation migration**: pin stable Omarchy, boot Hyprland + Quickshell in QEMU, remove Omarchy product identity and validate the core system. The AI runtime, security enforcement, the installer and the first-party product integrations are **not** authorized by this phase — they follow their own gates ([PHASES](docs/PHASES.md), [migration report](docs/engineering/OMARCHY_MIGRATION.md), [ecosystem plan](docs/engineering/ECOSYSTEM_PLAN.md)).

## Architecture and map

Proposed direction ([ADR-013](docs/DECISIONS.md)): Arch x86-64 with an **Omarchy-derived foundation** — Hyprland compositor, Quickshell shell toolkit, systemd, pacman, Plymouth, SDDM; Axiom Shell on Qt 6/QML; Rust backend; D-Bus first, Unix sockets only with justification; Btrfs/Snapper; pacman/PKGBUILD; Omarchy-derived ISO/update flow pending research. Upstream `linux` plus `linux-lts` remains the kernel target; the Limine/UKI boot chain is RESEARCH against the accepted systemd-boot direction. Reuse PipeWire/WirePlumber, NetworkManager, BlueZ, Mesa; optional Flatpak applications. SQLite/FTS5 for local metadata. Providers remain replaceable; MCP grants no authority. Warden is RESEARCH until the bypass matrix and typed interface are proven.

Omarchy is **upstream infrastructure, not the product**. Never modify upstream files blindly or let Omarchy naming/theming become the Axiom surface. Pin upstream revisions, classify changes, and keep Axiom-owned shell, AI runtime, security and system APIs independent of upstream churn. First-party projects keep their own repositories and are consumed through pinned adapters, not merged into one monolith. Details: [migration report](docs/engineering/OMARCHY_MIGRATION.md), [third-party notices](THIRD_PARTY_NOTICES.md).

- `docs/`: product, architecture, contracts, security, phases and evidence.
- `.agents/skills/`: canonical portable workflows; read the relevant SKILL.md. In this restricted session only, `portable-skills/` stages their contents; see README.
- `docs/SUBAGENTS.md`: canonical roles; tool adapters only point there.
- `scripts/`: deterministic foundation validation, skill installation and the Phase 1 ISO build/check helpers.
- `iso/`: legacy Phase 1 reviewed archiso profile and build output; `tests/`: Phase 1 QEMU boot harness. Both are retained as historical evidence and are not the migration base.
- Future `apps/`, `shell/`, `services/`, `security/`, `packages/`, `installer/`, `branding/` exist only when their phase warrants them.

## Non-negotiable rules

AI never gets unrestricted root or arbitrary sudo/shell passthrough. UI never runs as root. Privileged APIs are narrow and independently authorize caller, operation and target. Sensitive actions require authorization; critical actions never execute silently. Deny missing/invalid authority. Keep secrets out of repository and logs. Preserve Wayland boundaries. Attribute actions, verify changes and test recovery where practical; never promise universal undo. Core desktop works without cloud AI. Deterministic routines avoid unnecessary model calls. Every daemon and new privileged component requires justification. Reuse mature Linux primitives. Performance claims require measurements.

Axiom Flow owns resource orchestration: reuse Linux/systemd primitives, keep LLMs out of its control loop and base pressure decisions on real telemetry rather than arbitrary RAM percentages. Never silently kill apps with unsaved work as normal optimization; benchmark resource-policy changes. Update existing docs instead of creating duplicate versions. Read [Flow](docs/system/FLOW.md) and [performance](docs/system/PERFORMANCE.md).

## Work and completion

Read this file, current phase, relevant docs/skill and implementation. Define acceptance criteria, respect ownership, implement the smallest coherent change, run targeted tests plus adversarial checks for security changes and benchmarks for performance claims. Report uncertainty. Do not replace core technologies opportunistically: research, document migration/security/performance/rollback impact and record an ADR before major changes.

Documentation follows behavior/architecture changes; link canonical contracts rather than copying them. Label V1/LATER/RESEARCH, targets versus measurements and unverified assumptions. No fabricated APIs, compatibility, benchmarks or empty TODO scaffolds. Add nested AGENTS.md only with real subsystem directories; no CLAUDE.md.

Done means implementation complete, targeted tests and integration pass, failure and security behavior addressed, reproducible build evidence retained, no known regression, documentation updated, and applicable benchmarks/recovery tests recorded. Foundation changes use `python3 scripts/validate-repo.py`; `python3 scripts/install-skills.py` requires a writable `.agents`. Phase 1 adds `python3 scripts/check-iso-profile.py`, `sudo scripts/build-iso.sh` and `tests/qemu-boot.sh`. Other ISO/package/VM commands remain upstream procedures, not implemented project wrappers.

Read [architecture](docs/ARCHITECTURE.md), [decisions](docs/DECISIONS.md), [security](docs/security/SECURITY.md), [testing](docs/engineering/TESTING.md) and [workflow](docs/AGENT_WORKFLOW.md). No feature advances merely because code exists.
