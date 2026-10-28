# Implementation phases

Current development: **Phase 3 — authorized 2026-10-28 by the owner's desktop-shell execution brief**. Phase 2 foundation exit is recorded; installer-release, hardware, update and security gates remain separate. Phase 0 exit is recorded (2026-10-24, [FOUNDATION_VALIDATION](engineering/FOUNDATION_VALIDATION.md)); Phase 1 (repeatable archiso build + QEMU boot) exited 2026-10-25 ([PHASE1_EVIDENCE](engineering/PHASE1_EVIDENCE.md)) and its profile is retained as legacy evidence. **Phase 2 is the completed pinned Omarchy-derived foundation migration**: Hyprland + Quickshell in disposable QEMU, Axiom identity and core-system evidence. The earlier "branded Plasma 6 Wayland desktop" Phase 2 scope is **SUPERSEDED**. The AI runtime, security enforcement, the installer and the first-party product integrations are **not** authorized by this phase — they follow their own gates. These are execution gates, not dates. Advancing requires recorded evidence and an explicit phase-status update. Security applies from Phase 0; Phase 7 integrates enforcement. Follow the dependency-ordered validation waves in [TESTING.md](engineering/TESTING.md). No mutation becomes available before its authorization and audit gate.

## Phase status log

| Phase | Status | Evidence |
| --- | --- | --- |
| 0 Research and architecture validation | EXIT MET 2026-10-24 | [FOUNDATION_VALIDATION](engineering/FOUNDATION_VALIDATION.md), [PHASE0_EVIDENCE](engineering/PHASE0_EVIDENCE.json) |
| 1 Repository foundation and reproducible Arch/archiso build | EXIT MET 2026-10-25 (owner sign-off) | [PHASE1_EVIDENCE](engineering/PHASE1_EVIDENCE.md) |
| 2 Omarchy-derived foundation migration | EXIT MET 2026-10-28 (foundation ISO + disposable QEMU target) | [PHASE2_EVIDENCE](engineering/PHASE2_EVIDENCE.md), [PHASE2_BUILD](engineering/PHASE2_BUILD.md) |
| 3 Axiom Shell on Hyprland/Quickshell | AUTHORIZED 2026-10-28; integrated implementation in validation | [Research and validation](../research/desktop-shell/README.md), [implementation evidence](engineering/PHASE3_IMPLEMENTATION.md) |
| 4–12 | Not started | — |

> **Note:** The original Phase 3 desktop shell implementation was removed because the visual and interaction architecture did not meet the intended Axiom desktop quality. Phase 3 will restart from a new shell specification inspired by macOS interaction quality.

Phase 1 authorization covers only the reviewed archiso profile, build script, QEMU boot harness, CI validation and its evidence. It does not authorize branding, Plasma, custom packages, the installer, or any `apps/`, `shell/` or `services/` component. E01/E02 supply the Phase 1 exit evidence; E03/E09/E12 remain deferred to their own phases. The Phase 1 archiso profile is retained as legacy evidence; the Phase 2 Plasma scope was superseded by [ADR-013](DECISIONS.md).

## Sequencing and first-party components

Execution order is **Axiom itself first, then the AI system, then security enforcement, then the five first-party projects** (owner decision 2026-10-25). The products are shaped to Axiom's contracts, not adopted as-is. See [ecosystem](ai/ECOSYSTEM.md), [agent system](ai/AGENT_SYSTEM.md), [Warden integration](security/WARDEN_INTEGRATION.md) and the [ecosystem work plan](engineering/ECOSYSTEM_PLAN.md).

| Component | Lands in | Role |
| --- | --- | --- |
| Parent `assistantd` + child-agent registry | 4–6 | One orchestrator; bounded, declarative child agents ([agent system](ai/AGENT_SYSTEM.md)) |
| RepoSpine | 5–6 | Context child engine — budgeted code context over SDK/MCP |
| ContextGit | 4–6 | Per-child runtime context branches; no context collisions |
| Warden | 7 | Execution enforcement; policy derived from the approved request |
| Morphix | 3, 8 | Reversible desktop customization through the transaction path |
| ModelCheck | 5, 9 | Model promotion gate before a default model changes |

Deferred until their phases, and not implied by this table: the five product integrations themselves, user-authored child agents (after Phase 7), and the dev-environment provisioning UI (its Phase 3 surface is selection/confirmation only). Each product keeps its own repository, phase gates and evidence; no component becomes a hard dependency of the core desktop (ADR-012).

## Phase 0: Research and architecture validation

**Status:** EXIT MET 2026-10-24.

**Objective:** Research and architecture validation.

**Dependencies:** None.

**Implementation tasks:** Review primary sources and tool formats; identify exact Warden upstream; define trust boundaries, API and recovery experiments. Flow research covers cgroups/PSI, systemd launch/delegation/controls, reclaim/freezer, zram/zswap, oomd and benchmark design; record E13–E20 with no production thresholds.

**Deliverables:** Reviewed docs, ADR baseline, skills and evidence register; canonical Flow design with source/version limitations and separate Shield/Sentinel integration boundaries.

**Tests:** Run repository validation; adversarial desk review of permission/recovery scenarios.

**Security review:** Review threats, caller identity and secret/exfiltration boundaries.

**Demo:** Walk through typed request, denial and recovery design.

**Exit criteria:** Sources/unknowns explicit; no conflicting security contracts; skills authored and installation constraint recorded.

**Risks:** Unverified kernel/upstream behavior; read-only skills mount.

**Out of scope:** Any OS implementation.

## Phase 1: Repository foundation and reproducible Arch/archiso build

**Status:** EXIT MET 2026-10-25. Open findings carried into Phase 2: the upstream-inherited `systemd-loop@…sr0` boot unit failure (non-fatal) and host QEMU firmware-stage flakiness; see [PHASE1_EVIDENCE](engineering/PHASE1_EVIDENCE.md).

**Objective:** Repository foundation and reproducible Arch/archiso build.

**Dependencies:** Phase 0 exit plus explicit authorization to implement.

**Implementation tasks:** Provision disposable Arch builder; capture tool/package/repository inputs; copy upstream profile; create minimal project profile; script clean build/log capture; add CI validation; repeat build.

**Deliverables:** Reviewed profile, package manifest, build script, evidence artifact.

**Tests:** Clean builds twice; compare manifests and hashes; explain nondeterminism; ISO structure checks.

**Security review:** Verify package signatures, source provenance and build privilege model; isolate untrusted PR builds.

**Demo:** Build minimal image from recorded inputs.

**Exit criteria:** Independent clean build boots in QEMU with logs; reproducibility level explicitly stated.

**Risks:** Rolling repositories; mirror/signing drift; KVM availability.

**Out of scope:** Custom shell, AI runtime and installer.

## Phase 2: Omarchy-derived foundation migration

**Status:** EXIT MET 2026-10-28 for the pinned foundation ISO and disposable QEMU target. The earlier "bootable branded KDE desktop" content is **SUPERSEDED** and preserved only as history. The Plasma packages added to the legacy Phase 1 archiso profile are legacy evidence, not the migration base.

**Objective:** Adopt the pinned Omarchy-derived Arch/Hyprland/Quickshell foundation safely.

**Dependencies:** Phase 1 evidence; [ADR-013](DECISIONS.md); completed documentation migration; upstream mirrors pinned to recorded revisions.

**Implementation tasks:** pin the stable Omarchy release plus `omarchy-iso` and matching package set; boot original Omarchy in disposable QEMU; map components and audit licenses; remove Omarchy product identity; produce a minimally Axiom-branded boot using Hyprland + Quickshell; validate NetworkManager, PipeWire/WirePlumber, BlueZ, snapshots and the update path; record a reproducible build recipe. Axiom Shell, the AI runtime and first-party integrations are **not** started here.

**Deliverables:** Axiom-branded foundation image, component audit, pinned upstream revisions, reproducible build instructions.

**Tests:** UEFI boot, Hyprland/Quickshell session, system/network/audio/Bluetooth smoke, snapshot/update checks, and visible-branding removal.

**Security review:** live account, greeter, firewall/SSH defaults, boot chain (Limine/UKI vs systemd-boot), and no inherited passwordless sudo or agent bypass mode.

**Demo:** boot the Axiom-branded foundation in QEMU.

**Exit criteria:** **MET 2026-10-28.** The pinned Axiom-branded foundation ISO booted in disposable QEMU, and the installed target was inspected for Axiom identity, Hyprland/Quickshell/SDDM, core services, Limine and the `linux-omarchy` boot artifacts. Evidence and retained build logs are recorded in [PHASE2_EVIDENCE](engineering/PHASE2_EVIDENCE.md).

**Risks:** upstream pre-release drift, boot-chain conflict with ADR-002, hardware variance, package-set pinning.

**Out of scope:** Axiom Shell, AI runtime, installer release, first-party integration, Secure Boot/TPM claims.

## Phase 3: Axiom Shell on Hyprland/Quickshell

**Status:** AUTHORIZED 2026-10-28. Research infrastructure is complete; the
window foundation and controls remain in validation while the integrated shell
implementation advances through the remaining feature gates.

**Objective:** A real Linux desktop shell with original Axiom identity and
macOS-inspired interaction quality. Public Apple UX references inform behavior;
Linux source and actual runtime integration determine implementation. No fake
system state, browser mockups, Apple assets or invented proprietary internals.

**Dependencies:** Phase 2 exit for integrated release acceptance; record actual
Hyprland/Quickshell/Qt revisions for every runtime validation. Continue development
on the owner's authorization while foundation gaps remain visible.

| Subphase | Status | Required exit |
| --- | --- | --- |
| 3.0 Research infrastructure | COMPLETE | [Infrastructure evidence](../research/desktop-shell/validation.md); later feature investigations remain sequential |
| 3.1 Window foundation | VALIDATION | Shared real window/workspace/monitor identity and lifecycle; disconnect/failure/guest evidence |
| 3.2 Window controls | IMPLEMENTATION | Real close, minimize, maximize/restore across app/window/fullscreen/monitor matrix |
| 3.3 Dock | IMPLEMENTATION | Actual desktop entries, launch/focus behavior and running-window grouping; persistence, menus/reorder/autohide and measured interaction remain open |
| 3.4 Top bar | IMPLEMENTATION | Axiom identity, actual workspace/active-window/time/audio/battery/notification state; NetworkManager/Bluetooth and multi-monitor ownership remain open |
| 3.5 Launcher | IMPLEMENTATION | Keyboard-ready desktop-entry search and activation; file/settings/command/recent/calculator/quick-action search and measured latency remain open |
| 3.6 Control Center | RESEARCH | Backends and authorization are specified; no service mutation is implemented before its narrow contract and denial tests |
| 3.7 Notifications | IMPLEMENTATION | Quickshell notification service, count/history/dismiss; grouping/actions/clear/DND and keyboard access remain open |
| 3.8 Workspace overview | IMPLEMENTATION | Actual Hyprland workspace model and switching via the top bar; window-list/overview presentation and drag/thumbnails remain open |
| 3.9 File manager specification | NOT STARTED | Evidence-backed specification; reuse mature file manager, no full replacement without foundation |
| 3.10 Integration and polish | NOT STARTED | Coherent original design/motion, full session tests, accessibility, performance and retained evidence |

Allowed statuses: NOT STARTED, RESEARCH, IMPLEMENTATION, VALIDATION, COMPLETE,
BLOCKED. COMPLETE requires actual system integration and all applicable tests;
rendering alone never suffices. A subphase with open acceptance stays in
VALIDATION. Dependencies are sequential: finish 3.0/3.1, then 3.2/3.3, establish
stability, then continue 3.4 onward. Research scopes are not completed findings.

**Evidence:** [research workflow](../research/desktop-shell/README.md),
[Phase 3 readiness packet](research/PHASE3_READINESS.md),
[REA UI workflow](research/REA_UI_REVERSE_ENGINEERING.md),
[license map](research/OPEN_SOURCE_DESKTOP_LICENSES.md),
[repository audit](../research/desktop-shell/repository-audit.md),
[REA setup](research/REA_SETUP.md),
[window foundation](../research/desktop-shell/window-foundation/axiom-spec.md)
and [actual results/gaps](../research/desktop-shell/window-foundation/validation.md).
At each exit record references, REA investigations, source inspections, evidence,
decisions, files, tests, applicable screenshots, limitations and next subphase.

**Design:** Extend the central [tokens](desktop/DESIGN_SYSTEM.md), including
motion, reduced motion, focus/hover/disabled/accessibility states; reuse official
branding. Validate hierarchy, spacing, responsiveness and clarity against public
references without copying Apple's appearance. Screenshot concepts are not runtime
assets or integration evidence.

**Tests:** Real Hyprland/Wayland user session; normal/terminal/browser/Electron,
same-app windows, fullscreen, monitors/hotplug/mixed DPI, keyboard-only focus,
1366×768/4K/text scaling, reduced motion, lock/unlock, offline/unavailable services,
startup/RSS/idle CPU and launcher/Dock/Control Center latency. Required evidence
must retain environment, command, actual result, uncertainty and artifacts.

**Security:** Shell runs as the user. Existing narrow Linux services authorize
privileged operations; document each. No arbitrary dispatch API for agents,
generic privileged broker, input/capture bypass, weakened compositor permissions
or deep Warden integration. AI runtime, security enforcement, first-party
integration, provisioning and installer remain gated by their later phases.

**Exit criteria:** All subphase acceptance and Phase 2 foundation evidence pass;
real desktop session, original Axiom identity, offline operation, no Wayland
security weakening, measured performance and no known regression.

**Risks:** Quickshell/private-Qt churn, compositor-specific minimize semantics,
window lifecycle races, application ID ambiguity, accessibility, monitor/lock
boundaries and incomplete foundation/rebuild evidence.

**Out of scope:** Custom compositor, full file-manager rewrite, complete software
center, massive AI assistant, Apple resource reuse and release claims without gates.

## Phase 4: Rust service and D-Bus foundation

**Objective:** Rust service and D-Bus foundation.

**Dependencies:** Phase 2; UI contract from Phase 3.

**Implementation tasks:** Create minimal Rust workspace; version D-Bus interfaces; add per-user lifecycle and broker skeleton; bounded errors/cancellation; harden units. Design Flow observation and same-user target identity contracts; all mutating Flow integration remains gated until Phase 7 and an authorized Phase 9 POC.

**Deliverables:** Small service foundation and contract fixtures.

**Tests:** Unit/component/bus tests, crash/restart, absent caller and resource limits.

**Security review:** Review UID/session binding, bus policy, Polkit and no generic forwarding.

**Demo:** Read-only request with clear failure when broker unavailable.

**Exit criteria:** Unauthorized callers denied; lifecycle and failure checks pass.

**Risks:** Async cancellation and sender disconnect races.

**Out of scope:** Privileged mutation.

## Phase 5: AI runtime and model promotion

**Objective:** AI overlay, provider router and a gated model-promotion path.

**Dependencies:** Phases 3–4.

**Implementation tasks:** Implement neutral request/stream/error types; one cloud adapter and Ollama; connect the Axiom Shell overlay; explicit content-sharing consent. Add the **ModelCheck promotion-gate POC**: a candidate model/provider must pass a baseline comparison on the user's workload before it can become a default, with raw evidence and no vendor-claim promotion. ModelCheck remains a local tool first; CI verdict artifacts are later.

**Deliverables:** Cloud/local proof with replaceable adapters.

**Tests:** Conformance, timeout/cancel, offline core desktop and provider outage tests.

**Security review:** Review credential storage, egress, prompt injection and redacted traces.

**Demo:** Switch cloud/local without changing capability contracts.

**Exit criteria:** Adapters conform and no provider output conveys authority.

**Risks:** Provider drift, GPU/RAM local-model cost.

**Out of scope:** Dozens of providers and autonomous actions.

## Phase 6: System Agent API and context foundation

**Objective:** System Agent API plus the first RepoSpine/ContextGit context proof.

**Dependencies:** Phases 4–5; Phase 0 security contracts.

**Implementation tasks:** Implement observe subset and open-action schemas/dry-runs first; schemas and target validation; design mutation handlers behind disabled gates; correlate events. Add the child-agent registry and the read-only child set (Context, Research, Security, Performance), with RepoSpine as the context engine and ContextGit isolating per-child context; children never self-authorize and no child-to-child channels exist in V1 ([agent system](ai/AGENT_SYSTEM.md), [ecosystem](ai/ECOSYSTEM.md)). POC: parent agent requests bounded RepoSpine context, a child gets its own ContextGit branch, edits a project, and context history is preserved without collisions. Both tools stay optional; absence degrades to approved bounded file reads.

**Deliverables:** 5–10 capability contracts and staged handlers.

**Tests:** Contract validation, malformed input, bounds, target replacement and deny tests.

**Security review:** Review each capability before exposure; no sensitive execution before Phase 7.

**Demo:** Typed observe calls and open-action dry-runs with invalid request rejection.

**Exit criteria:** Small useful read-only set and dry-run contracts demonstrated; all mutation remains disabled until Phase 7 exit.

**Risks:** Scope creep, hidden upstream side effects.

**Out of scope:** Arbitrary shell and hundreds of functions.

## Phase 7: Permission enforcement and auditing

**Objective:** Permission enforcement and auditing.

**Dependencies:** Phases 4–6.

**Implementation tasks:** Implement request-bound trusted approval, independent broker authorization, audit persistence and crash reconciliation; evaluate Warden identified revision or record rejected dependency decision. Warden becomes the execution-enforcement layer: policy derived from the approved typed request (never model-supplied), audit correlated to Axiom request/audit IDs, fail-closed preserved — see [Warden integration](security/WARDEN_INTEGRATION.md); the bypass matrix on mainline and LTS is required evidence. Add a bounded **Sentinel POC** on a local target: synthetic user/test run inside Warden-isolated workers, reproducible finding, explicit resource budget, no production target.

**Deliverables:** Permission UX, enforceable policy, audit viewer; evidence-backed Warden disposition.

**Tests:** Denied/expired/replayed approvals, malicious MCP, concurrent caller and audit failure tests.

**Security review:** Independent adversarial review of every enabled mutation and sandbox assumption; include Flow target enrollment, approved weight bounds, disruptive-action consent and recovery authority before its Phase 9 controller can be enabled.

**Demo:** Deny action, authorize scoped action, inspect attributed result.

**Exit criteria:** No silent critical action; all enabled handlers authorized/verified/audited; unresolved Warden dependency removed or validated via ADR.

**Risks:** Confused deputy, unavailable enforcement, audit disk-full.

**Out of scope:** Autonomous critical actions and generic sandbox product.

## Phase 8: Btrfs transaction and rollback

**Objective:** Btrfs transaction and rollback.

**Dependencies:** Phase 7; early layout experiment before installation.

**Implementation tasks:** Specify subvolumes; capture consistent package/root state and boot asset policy; serialize eligible transactions; implement verification/recovery jobs. Align Morphix change plans with Axiom transactions so desktop customization is recovered through the same verification path (Morphix's retention and its Plasma-only adapter remain a separate decision). Account for Omarchy's root-only snapshot coverage: `/home`, boot assets and external effects stay excluded unless separately proven.

**Deliverables:** Recovery proof and per-capability limitations.

**Tests:** Crash, disk-full, hook failure, failed boot, missing snapshot, recovery reboot and audit survival tests.

**Security review:** Review privileged snapshot targets, recovery authority and downgrade/rollback bypass.

**Demo:** Fail an eligible change then recover and verify.

**Exit criteria:** Recovered package/root/boot state boots coherently; exclusions visible.

**Risks:** ESP mismatch; user/cloud effects; shared extents not backup.

**Out of scope:** Universal undo.

## Phase 9: Performance subsystem and benchmarks

**Objective:** Flow POC → small Flow V1 candidate within the existing performance phase; protect foreground responsiveness using measured Linux-native controls.

**Dependencies:** Phase 2 Flow OFF baseline and mainline/LTS grouping probes; Phase 3 UX/Phase 4 interfaces; Phases 7–8 integrated candidate and authorization/audit/recovery gates. No implementation is authorized by this documentation update.

**Implementation tasks:** First run an on-demand POC with logical app scopes, bounded telemetry/PSI and manual CPUWeight/IOWeight Efficient/restore on expendable enrolled workloads. Then add a Control Center resource view, foreground/background evidence, zram baseline and isolated MemoryHigh/reclaim experiment. Calibrate a shadow pressure-state machine and bounded foreground/Resource Guard proofs; evaluate one flowd only if lifecycle/recovery needs and measured overhead justify persistence. Freeze/thaw and oomd integration are SHOULD proofs, not mandatory production defaults.

**Deliverables:** Group/support matrix; manual policy proof with original/effective/restored settings; bounded local interventions; Flow OFF/ON reports/raw samples; explicit unsupported features and no chosen production thresholds without evidence.

**Tests:** E13–E20; five Flow contention scenarios in the existing benchmark protocol; background throughput, stalls/latency, overhead, override/crash recovery, media/build/service safety; separate zram 4/8/16/32 GiB matrix and physical energy tests.

**Security review:** Independent review of identity/delegation, own-user target bounds, disruptive/root-operation consent, malicious hints, resource starvation and independent thaw path; never broaden Polkit or grant Docker socket access to simplify orchestration.

**Demo:** Explain real pressure without a model; manually place an enrolled background app in Efficient mode, show effective controls and restore them; compare matched-load foreground response and background work. Reclaim proof uses disposable target and records actual outcome.

**Exit criteria:** Flow MUST scope in MVP passes; benchmark evidence includes uncertainty and regressions; essential interaction and useful background progress survive the tested workload; user override/restore works; no Flow app-kill optimizer; overhead/degradation documented. Each SHOULD feature has a separate compatibility/permission/recovery gate and may remain disabled. Auto-sleep/auto-pause are not required for phase exit.

**Risks:** False app grouping, missing controllers, ineffective I/O weights, priority inversion, reclaim thrash, compression CPU/battery cost, oomd collateral damage, measurement noise and controller persistence overhead.

**Out of scope:** Production automatic app sleep, container auto-pause, learned policies, advanced memory prediction, checkpointing, generic GPU/network budgeting, LLM hot path and unmeasured tuning defaults.

## Phase 10: Installer, update and release pipeline

**Objective:** Installer, update and release pipeline.

**Dependencies:** Phases 1–9 candidate exits.

**Implementation tasks:** Adopt the Omarchy-derived installer/update/release path after research and rebranding; do not rebuild Calamares-first functionality merely because the old architecture expected it. Keep a full pacman update path, signed repository/artifact process, release notes/checksums/license inventory and tested rollback. Include the developer install checklist: selection stored at install, provisioning applied on first boot, nothing pre-selected ([install checklist](engineering/INSTALL_CHECKLIST.md), [installer](engineering/INSTALLER.md)).

**Deliverables:** Installable release candidate and recovery media.

**Tests:** Disposable disk install, reboot, full update, interruption/recovery, installer cancellation, signature rejection.

**Security review:** Independent disk-target, supply-chain, Secure Boot threat and secrets/signing review.

**Demo:** Install VM then update and recover.

**Exit criteria:** Release checklist passes; known issues and supported matrix published; approval before publishing.

**Risks:** Destructive disks, key custody, rolling dependencies.

**Out of scope:** Broad daily-driver compatibility promise.

## Phase 11: Android connectivity proof

**Objective:** Android connectivity proof.

**Dependencies:** Phase 10; separate later scope authorization.

**Implementation tasks:** Reuse KDE Connect first; choose minimal discovery/pairing and file/status proof; evaluate scrcpy/webcam separately.

**Deliverables:** Authenticated bounded device proof and limitations.

**Tests:** Pair/revoke/MITM/path traversal/reconnect tests on declared Android versions.

**Security review:** Review discovery spoofing, trust revocation, clipboard/notification privacy.

**Demo:** Pair, transfer scoped file, revoke.

**Exit criteria:** Transport/authentication limits evidenced; no unsupported phone claims.

**Risks:** Android permissions/vendor variance; LAN exposure.

**Out of scope:** Complete phone ecosystem, iOS parity and tablet display.

## Phase 12: Routines, memory and advanced workflows

**Objective:** Routines, memory and advanced workflows.

**Dependencies:** Phase 10 plus reviewed later scope; connectivity optional.

**Implementation tasks:** Compile reviewed routines to deterministic capability graphs; bind triggers/grants; opt-in structured event memory; workspace intent export. Flow advanced work is a separately authorized track here: compatibility-tested automatic sleep, runtime-specific container idle management, visible reversible adaptive preferences and startup orchestration; reuse Flow/permission/profile contracts instead of a new resource system.

**Deliverables:** Deterministic routine proof and privacy controls.

**Tests:** Trigger spoofing, stale grant, partial failure, retention/deletion and cross-user isolation; Flow advanced work adds sleep/idle false positives, service continuity, revocation and crash/thaw recovery plus benchmark regression gates.

**Security review:** Review malicious routines, model regeneration and secret-bearing activity.

**Demo:** Run work-start routine offline from approved definition.

**Exit criteria:** No unnecessary model invocation; reauthorization on changed scope; memory opt-in/deletable.

**Risks:** Context leakage, stale workspace resources.

**Out of scope:** Continuous screenshots, process migration and perfect Handoff.
