# Architecture decisions

Accepted direction means the project chooses a technology subject to integration tests. It does not assert successful implementation. Accepted invariants constrain every phase. Changes require a new/superseding record; never silently edit history to reverse a decision. Decision date: 2026-10-18. No ADR authorizes implementation beyond current scope.

## ADR-001: Arch Linux base

**Status:** Accepted direction.

**Context:** Need upstream packages and developer control.

**Options:** Arch; Debian stable; Fedora.

**Decision:** Arch x86-64 with controlled build inputs.

**Reasons:** Aligns requested tooling and avoids a base fork.

**Tradeoffs:** Rolling integration burden and support costs.

**Risks:** Partial upgrades and mirror drift.

**Revisit When:** Update/recovery maintenance cannot meet declared support gates.

## ADR-002: Upstream kernel, systemd and UEFI boot

**Status:** Accepted direction; the systemd-boot half is re-opened for investigation by [ADR-013](#adr-013-omarchy-derived-archhyprlandquickshell-foundation) because Omarchy ships a Limine/UKI boot chain. Kernel direction (upstream `linux` + `linux-lts`) is unchanged.

**Context:** Need a maintainable boot baseline.

**Options:** Upstream linux/LTS and systemd-boot; kernel/compositor/init forks; GRUB.

**Decision:** linux plus linux-lts, systemd, systemd-boot for initial UEFI target.

**Reasons:** Reuse mature components; no V1 forks.

**Tradeoffs:** systemd-boot excludes legacy BIOS; Secure Boot integration needs proof.

**Risks:** ESP/root divergence and firmware variance.

**Revisit When:** Supported hardware requires a different loader; document migration first.

## ADR-003: Plasma Wayland desktop

**Status:** SUPERSEDED by [ADR-013](#adr-013-omarchy-derived-archhyprlandquickshell-foundation) (2026-10-27). The record below is preserved as history; do not base new work on it.

**Context:** Need cohesive UI without compositor ownership.

**Options:** Plasma/KWin; GNOME; new compositor.

**Decision:** Plasma 6 KWin Wayland and Qt 6/QML customization.

**Reasons:** Reuse desktop integration while developing original identity.

**Tradeoffs:** Plasma API compatibility and extension maintenance.

**Risks:** Automation pressure might tempt weakened isolation.

**Revisit When:** Verified integration gaps cannot be solved through portals/upstream APIs.

## ADR-004: Typed capabilities and least privilege

**Status:** Accepted invariant.

**Context:** Model output and tool content are untrusted.

**Options:** Typed broker; shell+sudo automation.

**Decision:** Small typed API with deterministic validation and independently enforced authorization.

**Reasons:** Constrains authority and produces attributable outcomes.

**Tradeoffs:** Requires deliberate contracts per operation.

**Risks:** Confused deputy and TOCTOU remain implementation concerns.

**Revisit When:** Only narrow contracts may evolve; unrestricted root is never a valid replacement.

## ADR-005: Btrfs with Snapper recovery

**Status:** Accepted direction; recovery unproven.

**Context:** Need practical recovery for eligible changes.

**Options:** Btrfs/Snapper; image-based atomic OS; backups only.

**Decision:** Btrfs/Snapper first; serialized verified jobs and explicit exclusions.

**Reasons:** Uses established snapshot tooling.

**Tradeoffs:** Not atomic across boot assets, external effects or excluded subvolumes.

**Risks:** Inconsistent pacman database, rollback bypass and lost audit history.

**Revisit When:** Recovery experiments fail; compare image-based options with migration evidence.

## ADR-006: Local modular runtime and replaceable providers

**Status:** Accepted direction.

**Context:** Need cloud-optional desktop and portable AI integration.

**Options:** Provider-neutral modules; one-vendor SDK throughout; many services.

**Decision:** Rust session orchestration, D-Bus first, SQLite/FTS5; one cloud plus Ollama proof.

**Reasons:** Avoids distributed infrastructure and provider lock-in.

**Tradeoffs:** Adapter conformance and local resource costs.

**Risks:** Credentials/egress and SQLite privilege boundaries.

**Revisit When:** Measured need exceeds current IPC/storage/process design.

## ADR-007: Warden integration conditional

**Status:** Research gate.

**Context:** Name alone does not identify enforceable upstream behavior.

**Options:** Identify and validate Warden; rely on unsupported assumptions; record unsuitable outcome.

**Decision:** No Warden dependency until repo/revision/license/Linux tests established.

**Progress (2026-10-24; re-verified 2026-10-27):** Repository and license identified ([Prof-bilal/Warden](https://github.com/Prof-bilal/Warden), MIT) and its Linux backend inspected statically; see [sandboxing](security/SANDBOXING.md). Corrected revision: `main` `f7c9793167398c86a61148c746cb4d934be11727`; the earlier `cd5e8bf2…` reference is the `axiom/integration` branch tip, not `main` or the `v0.1.17` tag. The Linux backend uses bubblewrap + setpriv `no_new_privs` + strace, with no seccomp filter and no Landlock. Our own namespace/seccomp/Landlock/network bypass tests on mainline and LTS remain **NOT RUN**, so the dependency gate is unchanged.

**Reasons:** Prevents invented security properties; avoids duplicate sandbox architecture.

**Tradeoffs:** Evaluation can delay enforcement integration.

**Risks:** Unsupported platform, bypasses and maintenance gaps.

**Revisit When:** Exact implementation passes adversarial tests or documented ADR rejects it.

## ADR-008: Portable repository knowledge

**Status:** Accepted invariant.

**Context:** Multiple AI tools must share durable architecture.

**Options:** AGENTS.md+docs+portable skills; vendor-only memory.

**Decision:** Canonical AGENTS.md, docs/SUBAGENTS.md and .agents/skills; thin adapters.

**Reasons:** Keeps knowledge independent of model/tool.

**Tradeoffs:** Discovery varies; read-only mount currently requires durable staging.

**Risks:** Adapter drift and hidden permissions.

**Revisit When:** Tool format changes; update adapter without forking project knowledge.

## ADR-009: Existing performance and connectivity primitives first

**Status:** Accepted direction; tuning/connectivity research.

**Context:** Avoid speculative persistent agents and phone promises.

**Options:** Existing Linux/KDE services; new daemons/protocols.

**Decision:** Measure existing controls; Android later via KDE Connect evaluation.

**Reasons:** Reduces security surface and maintenance.

**Tradeoffs:** Upstream API/platform limitations.

**Risks:** Unmeasured claims, privacy leakage and pairing mistakes.

**Revisit When:** Measured unmet requirement justifies scoped replacement.

## ADR-010: Axiom Flow resource orchestration

**Status:** Accepted direction, design only (2026-10-18); resource defaults, automation and flowd persistence remain experimental.

**Context:** ADR-009's existing-controls direction needs a named owner and measurable policy for foreground responsiveness under mixed developer/agent load. The old speculative performanced proposal has no implemented lifecycle to migrate.

**Options:** A: deterministic Flow orchestration over systemd/cgroups/PSI; B: uncoordinated tweaks or a new scheduler/AI scheduling daemon. Compare on-demand collection/manual control with one per-user flowd; persistence is not presumed.

**Decision:** A; one canonical FLOW.md, existing performance/profile/benchmark documents updated in place. Logical workloads, soft controls, explicit budgets and user overrides. No LLM hot path, global RAM-cleaner objective, normal app-kill loop or combined Flow/Shield/Sentinel daemon. Replace the speculative performanced name with a conditional flowd candidate, not an additional service.

**Reasons:** Addresses responsiveness, attribution and controllable background work while preserving mature Linux primitives and tool-neutral contracts. [Research Q8–Q9](RESEARCH.md) and [FLOW.md](system/FLOW.md) provide evidence and constraints.

**Tradeoffs:** Accurate app identity, activity vetoes, effective hierarchical controls and cleanup are harder than PID-level tweaks. Manual/observe-first MVP defers convenient but unsafe automation.

**Security / compatibility impact:** Explicit own-user bounded weight enrollment fits NORMAL grants; reclaim/memory protection/freezer/service actions stay SENSITIVE per-request V1, root/system policy CRITICAL. No general resource API is exposed to models. Shield authority and Sentinel execution stay separate. Missing controllers/delegation or app hints disable affected policies; no privileged fallback. No actual Shield/Sentinel implementation is assumed in this checkout.

**Migration cost:** Documentation and future interfaces only; no implementation exists. One future controller owns its settings and must coexist with existing power/system managers.

**Performance impact:** NOT YET MEASURED. Validate offered/completed workload, latency, stalls, energy and Flow overhead; lower RAM alone does not validate the decision.

**Rollback strategy:** Disable Flow, restore only still-owned runtime controls, thaw only identified Flow-owned units through a proven independent recovery path. Configuration experiments revert via planned test reboot when needed. No promise to undo external timeout, discarded working sets, OOM kills or unsaved-work loss.

**Risks:** Grouping error, starvation, protection-induced OOM, reclaim thrash, freeze orphaning, oomd collateral kills, privacy and overhead. Tests/gates precede automation.

**Revisit When:** E13–E20 show no net responsiveness benefit or unacceptable overhead/compatibility; new persistent process or broader authority requires documented alternatives and independent review. DAMON/MGLRU tuning/CRIU/eBPF are later experiments, not automatic additions.

## ADR-011: One parent AI system with bounded child agents

**Status:** Research direction; no runtime. Design in [agent system](ai/AGENT_SYSTEM.md).

**Context:** The product needs many specialised capabilities. Two shapes are possible: many
peer agents that coordinate, or one parent that delegates to bounded workers. Peer designs
compound errors, bloat context, obscure accountability and create agent-to-agent trust
problems; the existing architecture already names a single unprivileged orchestrator.

**Options:** A: one parent (`assistantd`) + a bounded, declarative child catalogue, children
re-entering the same policy/executor path; B: many peer agents with direct handoffs.

**Decision:** A. Children are ephemeral, least-privilege, budgeted and attributable; they never
self-authorize and cannot exceed the parent's authority. No child-to-child channels in V1. A
proposed built-in catalogue of about twelve children, and user-authored children as declarative
metadata + prompt with inherited ceilings and explicit approval.

**Reasons:** Linear accountability, smallest privilege, reuse of the existing
permission/audit contracts, and no new daemon.

**Tradeoffs:** The parent is a bottleneck and a single point of failure; delegation adds hops
and latency; a fixed catalogue may not cover every specialist need until user agents exist.

**Risks:** Runaway loops, cost blow-up, context bloat, unclear partial success, purpose
collisions between children. Mitigations are recorded in the agent-system document.

**Revisit When:** Measured latency/cost makes delegation worse than a single loop, or a
verified need for peer handoff appears with a documented trust model.

## ADR-012: First-party components co-evolve with Axiom

**Status:** Research direction; no component is a dependency and none is bundled.

**Context:** Five sibling projects share Axiom's author and map onto Axiom's sandbox,
code-context, context-versioning, model-evaluation and customization subsystems. They are
first-party components to be shaped to Axiom's contracts, not third-party products to be
accepted as-is — but the unverified-dependency risk recorded for Warden in ADR-007 still
applies to their behaviour.

**Options:** A: co-evolve each into an Axiom subsystem behind a versioned adapter
(CLI/SDK/MCP/library), core desktop works when all are absent, each shaped to a stated
capability; B: adopt them as-is or make them hard dependencies.

**Decision:** A. Ownership settles licence *permission* (the owner can add or change licences;
ModelCheck still needs a licence file added, and every shipped artifact still needs a declared
licence for the release inventory gate). It does **not** settle evidence: pinned revisions,
Warden's bypass matrix, Morphix's unimplemented rollback engine and RepoSpine's runtime floor
remain gates. Mapping and required shaping in [ecosystem](ai/ECOSYSTEM.md).

**Reasons:** Ownership is an unusual advantage — the products can be reshaped to fit Axiom's
contracts (e.g. Warden enforcing policies generated from approved typed requests) instead of
being bent around a fixed upstream API. Adapters keep the core desktop independent and
preserve ADR-008 replaceability.

**Tradeoffs:** Six projects maintained by one author; adapter layers cost work; deep coupling
is tempting and must be a recorded decision each time.

**Risks:** Concentration risk on a single maintainer; behavioural claims asserted merely
because the code is ours (the ADR-007 mistake in a new form); API drift across six repos.

**Revisit When:** A component passes a pinned-revision experiment, or a deeper coupling (for
example Warden as a required execution layer) is proposed and needs its own decision.

## ADR-013: Omarchy-derived Arch/Hyprland/Quickshell foundation

**Status:** Research direction, accepted 2026-10-27 for Phase 2 investigation. It supersedes ADR-003's Plasma/KWin desktop foundation. It does not authorize importing Omarchy code, changing the boot chain, or shipping anything; those remain gated by [PHASES](PHASES.md) and experiments E26–E33.

**Context:** Axiom needs a cohesive Arch-based desktop it can shape without maintaining a compositor or a shell toolkit from scratch. The earlier direction built on Plasma 6/KWin. Omarchy now provides a mature, actively maintained Arch/Hyprland/Quickshell foundation with installer, update, hardware, theme and recovery tooling. Axiom's existing documentation was written around Plasma and contains stale assumptions; the migration must be update-first, not a rewrite.

**Options:**

- A: raw Arch + Plasma/KWin (the previous direction). Mature shell components and accessibility, but Axiom's custom shell work becomes Plasma-extension work and the product identity is constrained by a large upstream desktop.
- B: raw Arch + custom Hyprland/Quickshell. Maximum control, but Axiom would rebuild installer, update, hardware and shell foundations that already exist.
- C: Omarchy-derived Arch/Hyprland/Quickshell foundation with Axiom-owned shell, AI runtime, Shield, Sentinel, Flow, system APIs and identity.

**Decision:** C, as a researched direction. Omarchy is upstream infrastructure, never the product. Axiom consumes pinned upstream revisions and replaces identity, shell UX, security behavior and agent integration.

**Evidence:** [migration report](engineering/OMARCHY_MIGRATION.md). Stable upstream pin `omacom/omarchy` `v4.0.6` (`237f1b40`) with `quattro` (`39d56653`) tracked read-only; `omarchy-iso` `main` `3c36557f`; Quickshell `v0.3.2` (`4f508be5`, LGPL-3.0-only); Hyprland `v0.56.2` (BSD-3-Clause). Quickshell covers panels, docks, lock, notifications, tray, audio, network, Bluetooth, UPower and polkit, but lacks a launcher UI, clipboard manager, OSD UI, a logind module and reduced-motion handling — those are Axiom Shell work. Omarchy documents that Secure Boot and TPM must be disabled to install; Axiom records this as an upstream limitation and a divergence target, not a supported outcome.

**Benefits:** reuse of proven Arch/Hyprland/Quickshell infrastructure; smaller foundation surface to own; an original Axiom Shell rather than Plasma extensions; clear separation between upstream infrastructure and product; upstream update/hardware work can be reviewed and ported deliberately.

**Costs:** a large documentation migration; Hyprland/Quickshell API churn and private-Qt rebuild requirements; loss of Plasma/KWin-specific work; new shell, installer and recovery research; Quickshell LGPL obligations; no inherited Secure Boot/TPM path.

**Security implications:** Hyprland's permission model, Quickshell as trusted shell code, Omarchy's documented Secure Boot/TPM limitation and opt-in passwordless sudo all require review. Axiom keeps its authorization invariants: Warden enforces, Axiom authorizes. No upstream agent bypass mode is inherited.

**Maintenance implications:** pin upstream release tags plus package versions and a pinned Quickshell build; track `quattro` read-only; classify every upstream change and port deliberately. Axiom will diverge substantially, so no auto-merge.

**Upstream strategy:** review diff → classify → Axiom compatibility review → security/performance/boot tests → port or reject. Upstream repositories (`omarchy`, `omarchy-iso`, `omarchy-pkgs`) form a pinned set.

**Migration strategy:** update the existing docs in place, preserve Phase 0/1 evidence, delete the abandoned `branding/` scaffold, mark Plasma work SUPERSEDED, and run the Foundation POC (E26) before any rebranding or code migration.

**Rollback strategy:** all migration work lives on `migration/omarchy-foundation`; upstream references are isolated under gitignored `workspace/upstream/`; ADR-003 is preserved and can be reinstated by a new superseding ADR rather than by rewriting history.

**Revisit when:** the Foundation POC fails to produce a reproducible bootable Axiom-branded Hyprland/Quickshell image, the Quickshell maintenance/tooling cost exceeds its benefit, or Hyprland/Quickshell cannot meet Axiom's accessibility, security or recovery requirements.

## Change proposal requirements

Explain why current architecture is insufficient; alternatives and primary evidence; replacement; migration cost; compatibility; security; measured or proposed performance impact; rollback strategy; owner and affected contracts. Independent review is required for trust-boundary changes. [Research](RESEARCH.md) records experiments; [phases](PHASES.md) records gates.
