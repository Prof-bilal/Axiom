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

**Status:** Accepted direction.

**Context:** Need a maintainable boot baseline.

**Options:** Upstream linux/LTS and systemd-boot; kernel/compositor/init forks; GRUB.

**Decision:** linux plus linux-lts, systemd, systemd-boot for initial UEFI target.

**Reasons:** Reuse mature components; no V1 forks.

**Tradeoffs:** systemd-boot excludes legacy BIOS; Secure Boot integration needs proof.

**Risks:** ESP/root divergence and firmware variance.

**Revisit When:** Supported hardware requires a different loader; document migration first.

## ADR-003: Plasma Wayland desktop

**Status:** Accepted direction.

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

## Change proposal requirements

Explain why current architecture is insufficient; alternatives and primary evidence; replacement; migration cost; compatibility; security; measured or proposed performance impact; rollback strategy; owner and affected contracts. Independent review is required for trust-boundary changes. [Research](RESEARCH.md) records experiments; [phases](PHASES.md) records gates.
