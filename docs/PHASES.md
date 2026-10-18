# Implementation phases

Current phase: **0**. These are execution gates, not dates or permission to start implementation now. Phase 0 foundation is authored; upstream/runtime experiments remain open. Advancing requires recorded evidence and an explicit phase-status update. Security applies from Phase 0; Phase 7 integrates enforcement. No mutation becomes available before its authorization and audit gate.

## Phase 0: Research and architecture validation

**Objective:** Research and architecture validation.

**Dependencies:** None.

**Implementation tasks:** Review primary sources and tool formats; identify exact Warden upstream; define trust boundaries, API and recovery experiments.

**Deliverables:** Reviewed docs, ADR baseline, skills and evidence register.

**Tests:** Run repository validation; adversarial desk review of permission/recovery scenarios.

**Security review:** Review threats, caller identity and secret/exfiltration boundaries.

**Demo:** Walk through typed request, denial and recovery design.

**Exit criteria:** Sources/unknowns explicit; no conflicting security contracts; skills authored and installation constraint recorded.

**Risks:** Unverified kernel/upstream behavior; read-only skills mount.

**Out of scope:** Any OS implementation.

## Phase 1: Repository foundation and reproducible Arch/archiso build

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

## Phase 2: Bootable branded KDE desktop

**Objective:** Bootable branded KDE desktop.

**Dependencies:** Phase 1.

**Implementation tasks:** Add Plasma Wayland packages and original branding; configure UEFI boot and LTS fallback; wire existing networking/audio services.

**Deliverables:** Bootable branded image and versioned package list.

**Tests:** UEFI boot, session type, graphics/audio/network smoke; fallback boot.

**Security review:** Review live account, services, default network exposure and credentials.

**Demo:** Login to branded Wayland session.

**Exit criteria:** Clean VM boot/login reproducible, no unexpected listeners, logs retained.

**Risks:** GPU differences; live versus installed layout.

**Out of scope:** Custom compositor and broad hardware claims.

## Phase 3: Custom desktop experience

**Objective:** Custom desktop experience.

**Dependencies:** Phase 2.

**Implementation tasks:** Implement shared tokens then launcher/panel/controls incrementally using Plasma extensions; add overlay surface without model authority.

**Deliverables:** Coherent QML components and keyboard interaction.

**Tests:** QML checks, accessibility/focus, multi-DPI and responsiveness tests.

**Security review:** Verify portals and prohibit unrestricted input/capture shortcuts.

**Demo:** Keyboard-only launch/settings/overlay walkthrough.

**Exit criteria:** UX acceptance passes with no Wayland security weakening.

**Risks:** Plasma API/upgrade compatibility.

**Out of scope:** Complete graphical store and desktop rewrite.

## Phase 4: Rust service and D-Bus foundation

**Objective:** Rust service and D-Bus foundation.

**Dependencies:** Phase 2; UI contract from Phase 3.

**Implementation tasks:** Create minimal Rust workspace; version D-Bus interfaces; add per-user lifecycle and broker skeleton; bounded errors/cancellation; harden units.

**Deliverables:** Small service foundation and contract fixtures.

**Tests:** Unit/component/bus tests, crash/restart, absent caller and resource limits.

**Security review:** Review UID/session binding, bus policy, Polkit and no generic forwarding.

**Demo:** Read-only request with clear failure when broker unavailable.

**Exit criteria:** Unauthorized callers denied; lifecycle and failure checks pass.

**Risks:** Async cancellation and sender disconnect races.

**Out of scope:** Privileged mutation.

## Phase 5: AI overlay and provider router

**Objective:** AI overlay and provider router.

**Dependencies:** Phases 3–4.

**Implementation tasks:** Implement neutral request/stream/error types; one cloud adapter and Ollama; connect overlay; explicit content-sharing consent.

**Deliverables:** Cloud/local proof with replaceable adapters.

**Tests:** Conformance, timeout/cancel, offline core desktop and provider outage tests.

**Security review:** Review credential storage, egress, prompt injection and redacted traces.

**Demo:** Switch cloud/local without changing capability contracts.

**Exit criteria:** Adapters conform and no provider output conveys authority.

**Risks:** Provider drift, GPU/RAM local-model cost.

**Out of scope:** Dozens of providers and autonomous actions.

## Phase 6: System Agent API

**Objective:** System Agent API.

**Dependencies:** Phases 4–5; Phase 0 security contracts.

**Implementation tasks:** Implement observe subset and open-action schemas/dry-runs first; schemas and target validation; design mutation handlers behind disabled gates; correlate events.

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

**Implementation tasks:** Implement request-bound trusted approval, independent broker authorization, audit persistence and crash reconciliation; evaluate Warden identified revision or record rejected dependency decision.

**Deliverables:** Permission UX, enforceable policy, audit viewer; evidence-backed Warden disposition.

**Tests:** Denied/expired/replayed approvals, malicious MCP, concurrent caller and audit failure tests.

**Security review:** Independent adversarial review of every enabled mutation and sandbox assumption.

**Demo:** Deny action, authorize scoped action, inspect attributed result.

**Exit criteria:** No silent critical action; all enabled handlers authorized/verified/audited; unresolved Warden dependency removed or validated via ADR.

**Risks:** Confused deputy, unavailable enforcement, audit disk-full.

**Out of scope:** Autonomous critical actions and generic sandbox product.

## Phase 8: Btrfs transaction and rollback

**Objective:** Btrfs transaction and rollback.

**Dependencies:** Phase 7; early layout experiment before installation.

**Implementation tasks:** Specify subvolumes; capture consistent package/root state and boot asset policy; serialize eligible transactions; implement verification/recovery jobs.

**Deliverables:** Recovery proof and per-capability limitations.

**Tests:** Crash, disk-full, hook failure, failed boot, missing snapshot, recovery reboot and audit survival tests.

**Security review:** Review privileged snapshot targets, recovery authority and downgrade/rollback bypass.

**Demo:** Fail an eligible change then recover and verify.

**Exit criteria:** Recovered package/root/boot state boots coherently; exclusions visible.

**Risks:** ESP mismatch; user/cloud effects; shared extents not backup.

**Out of scope:** Universal undo.

## Phase 9: Performance subsystem and benchmarks

**Objective:** Performance subsystem and benchmarks.

**Dependencies:** Phase 2 baseline, Phases 7–8 integrated candidate.

**Implementation tasks:** Measure declared machine/config; evaluate zram/PSI/cgroup controls and existing power profiles one change at a time; justify daemon only if required.

**Deliverables:** Baseline/candidate reports and retained raw samples.

**Tests:** Boot/login/idle/launcher/pressure/agent metrics; physical battery tests.

**Security review:** Review telemetry privacy and resource-control abuse.

**Demo:** Explain a slowdown from observed telemetry.

**Exit criteria:** Predeclared metrics/variance/thresholds recorded; regressions handled; no fabricated wins.

**Risks:** VM artifacts, thermal noise and power conflicts.

**Out of scope:** Unmeasured tuning and AI scheduling service by default.

## Phase 10: Installer, update and release pipeline

**Objective:** Installer, update and release pipeline.

**Dependencies:** Phases 1–9 candidate exits.

**Implementation tasks:** Integrate Calamares with tested Btrfs/UEFI layout; full pacman update path; signed repository/artifact process; release notes/checksums/license inventory.

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

**Implementation tasks:** Compile reviewed routines to deterministic capability graphs; bind triggers/grants; opt-in structured event memory; workspace intent export.

**Deliverables:** Deterministic routine proof and privacy controls.

**Tests:** Trigger spoofing, stale grant, partial failure, retention/deletion and cross-user isolation.

**Security review:** Review malicious routines, model regeneration and secret-bearing activity.

**Demo:** Run work-start routine offline from approved definition.

**Exit criteria:** No unnecessary model invocation; reauthorization on changed scope; memory opt-in/deletable.

**Risks:** Context leakage, stale workspace resources.

**Out of scope:** Continuous screenshots, process migration and perfect Handoff.
