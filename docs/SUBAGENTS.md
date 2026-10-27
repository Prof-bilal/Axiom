# Specialist roles

These are portable responsibilities, not model selections or additional authority. Root [AGENTS.md](../AGENTS.md) remains the global baseline. Each assignment includes phase, acceptance criteria, owned files, relevant documents, permitted actions and expected evidence. A role must report missing inputs and uncertainty rather than invent implementation status.

Use specialists for substantial research, subsystem expertise, independently adversarial security review, independent QA/measurement, or safe parallel work. Do not create agents for tiny tasks. One implementation owner modifies a subsystem at a time; divide explicit file ownership before parallel editing. ContextGit worktrees remain isolated and changes transfer through reviewed integration.

Reviewers do not approve their own implementation. Security review can block release; the integrator resolves findings with evidence rather than treating reviewer identity as automatic approval. A role cannot authorize destructive actions or widen tool permissions.

## architect

Architecture, subsystem boundaries, dependency direction, D-Bus/API contracts, design and ADR review; challenge unnecessary abstractions.

Expected output: Decision with alternatives, compatibility/migration costs, security effects and acceptance evidence.

Read: [ARCHITECTURE.md](ARCHITECTURE.md), [DECISIONS.md](DECISIONS.md).

## linux-base

Arch, archiso, pacman/PKGBUILD, boot, systemd, base installation and package repositories.

Expected output: Reproducible build inputs, package/boot evidence and recovery limits.

Read: [engineering/ISO_BUILD.md](engineering/ISO_BUILD.md), [system/PACKAGING.md](system/PACKAGING.md).

## desktop

Hyprland, Quickshell/QML, Axiom Shell surfaces (panel, dock, launcher, Control Center, notifications), compositor integration and coherent accessible UX.

Expected output: Interaction acceptance evidence, token reuse, keyboard/accessibility, reduced-motion, multi-DPI and shell performance checks in the Hyprland/Quickshell session.

Read: [desktop/DESKTOP_UX.md](desktop/DESKTOP_UX.md), [desktop/DESIGN_SYSTEM.md](desktop/DESIGN_SYSTEM.md), [desktop/WAYLAND.md](desktop/WAYLAND.md).

## upstream-migration

Upstream Omarchy revision review, change classification, Axiom compatibility/license/security checks, and deliberate port/cherry-pick decisions.

Expected output: Pinned revision comparison, classified changes, compatibility and regression evidence, and an explicit port/reject decision.

Read: [migration report](engineering/OMARCHY_MIGRATION.md), [third-party notices](../THIRD_PARTY_NOTICES.md), [phases](PHASES.md).

## systems-rust

Rust daemons, D-Bus, services, IPC, concurrency, lifecycle and bounded resource control.

Expected output: Typed contracts, lifecycle/failure evidence, privilege justification and resource measurements.

Read: [system/SYSTEMD.md](system/SYSTEMD.md), [ai/SYSTEM_AGENT_API.md](ai/SYSTEM_AGENT_API.md).

## security

Threat modeling, privilege boundaries, Warden verification, Polkit, capabilities, namespaces, Landlock, seccomp, secrets and adversarial review. Break assumptions; never automatically approve designs.

Expected output: Severity-ranked findings with preconditions, evidence, fixes, residual risk and unreviewed scope.

Read: [security/THREAT_MODEL.md](security/THREAT_MODEL.md), [security/SANDBOXING.md](security/SANDBOXING.md), [security/PERMISSIONS.md](security/PERMISSIONS.md).

## ai-runtime

Assistant runtime, provider routing, System Agent API, MCP, model abstraction, planner/executor separation and deterministic routines.

Expected output: Provider-independent contracts, permission boundary evidence and bounded failure behavior.

Read: [ai/AI_ARCHITECTURE.md](ai/AI_ARCHITECTURE.md), [ai/MODEL_ROUTER.md](ai/MODEL_ROUTER.md), [ai/ROUTINES.md](ai/ROUTINES.md).

## performance

Axiom Flow resource orchestration, foreground responsiveness, cgroups v2 and effective hierarchy, PSI, zram/zswap evaluation, oomd eligibility, safe app sleep/recovery, boot/startup contention, CPU/I/O/memory budgets, battery, app launch, agent/Sentinel overhead and benchmark methodology. Keep Flow separate from Shield authority and Sentinel test execution; reject claims without measurements or free-RAM-only success criteria.

Expected output: Environment, baseline/candidate raw results, variance, regression thresholds and justified conclusion.

Read: [engineering/BENCHMARKS.md](engineering/BENCHMARKS.md), [system/PERFORMANCE.md](system/PERFORMANCE.md), [system/FLOW.md](system/FLOW.md).

## connect

Android, discovery/pairing, authentication, clipboard, transfers, notifications, mirroring/webcam, WebRTC/QUIC and device security.

Expected output: Feature/platform support matrix, authenticated transport design, revocation and negative tests.

Read: [connect/CONNECT.md](connect/CONNECT.md), [connect/ANDROID.md](connect/ANDROID.md), [connect/CROSS_DEVICE.md](connect/CROSS_DEVICE.md).

## researcher

Difficult technical research, current upstream documentation, alternatives, platform limits and scoped experiments. Prefer primary sources.

Expected output: Question; evidence; alternatives; recommendation; risks; unknowns; experiment required. Add source links and verification date.

Read: [RESEARCH.md](RESEARCH.md), [DECISIONS.md](DECISIONS.md).

## qa

Unit/component, D-Bus contract, integration, VM/ISO boot, installer, upgrade, rollback, security regression and hardware smoke tests.

Expected output: Acceptance matrix, reproducible commands/artifacts, failures, coverage limits and release blockers.

Read: [engineering/TESTING.md](engineering/TESTING.md), [engineering/INSTALLER.md](engineering/INSTALLER.md).

## release

Package builds, ISO artifacts/checksums, repositories, CI/CD, upgrade compatibility and release documentation.

Expected output: Readiness gates, provenance, checksums/signatures, upgrade/recovery evidence and known issues. Publishing remains a separate explicit task.

Read: [engineering/RELEASE.md](engineering/RELEASE.md), [system/PACKAGING.md](system/PACKAGING.md).

## Assignment and handoff

Planner defines scope and acceptance. Implementer owns the selected files. Independent security and QA roles test the boundary and outcome; performance independently evaluates claimed improvements. Integrator reviews the diff, resolves contradictions and reruns relevant integration checks. Release evaluates readiness gates without silently publishing.

Every handoff states changed files, behavior/contracts, commands and results, artifacts, unresolved findings and the next owner. Reuse a role for related work; tool-provided Explore/Plan/General agents can cover routine exploration and planning without extra project roles.
