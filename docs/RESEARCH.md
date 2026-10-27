# Research and experiment register

Last research pass: **2026-10-18** (**2026-10-24**: Warden upstream identified; see [sandboxing](security/SANDBOXING.md)). Evidence is official documentation/upstream source where accessible. “Verified” means the cited text was inspected, not that Axiom integration works. ArchWiki/GitLab and some KDE/Calamares pages presented access challenges; blocked pages are not treated as read evidence. Implementation, hardware support and tool discovery remain untested. Source links are retained near the owning contracts rather than copied manuals.

## Q1: Is Arch an appropriate base?

**Question:** Can a rolling base support a cohesive recoverable prototype?
**Options:** A: Arch + controlled package inputs; B: stable-release base or image-based platform.
**Evidence:** [Arch official overview](https://archlinux.org/about/) describes x86-64, pacman and rolling releases; this does not establish product-level update reliability.

| Dimension | Option A | Option B |
| --- | --- | --- |
| Pros / cons | Current ecosystem and requested tooling; continuous integration burden | More fixed baseline or atomic deployment; product/package redesign |
| Security | Signed packages plus own supply-chain policy; fresh packages still need review | Longer maintenance window possible; patch/deployment policy still necessary |
| Performance | No inherent speed advantage proven | No inherent disadvantage proven |
| Maintenance | Frequent full-update/recovery tests | Migration and alternative build expertise |

**Recommendation:** Keep Arch (ADR-001); use recorded repository/package inputs and clean rebuilds. **Confidence:** high fit to requested direction, medium product reliability. **Unresolved:** repository snapshot strategy, signing custody, support lifetime, license inventory. **Experiment:** E01 and E02. **Sources:** above and [packaging research](system/PACKAGING.md), [ISO build](engineering/ISO_BUILD.md). **Last verified:** 2026-10-18.

## Q2: Existing desktop or new shell/compositor?

**Question:** How can original UX coexist with secure automation?
**Options:** A: Plasma/KWin/Wayland extensions; B: new compositor/shell or unrestricted desktop hooks.
**Evidence:** [KDE developer documentation](https://develop.kde.org/), [Qt QML documentation](https://doc.qt.io/qt-6/qtqml-index.html) and [portal research](desktop/WAYLAND.md) support building on existing surfaces; exact capture/input features depend on backend/version.

| Dimension | Option A | Option B |
| --- | --- | --- |
| Pros / cons | Mature desktop with custom tokens/components; API upgrade work | Full control; enormous compositor/accessibility burden |
| Security | Preserve portal/compositor consent and isolation | New security-critical code or weakened Wayland boundaries |
| Performance | Must measure extension/UI overhead | No evidence custom compositor improves user metrics |
| Maintenance | Follow upstream supported interfaces | Own protocol, drivers, UX and compatibility |

**Recommendation:** no custom compositor. The desktop foundation was re-scoped by [ADR-013](DECISIONS.md) to Omarchy-derived Hyprland/Quickshell; see Q26–Q29. **Confidence:** high on no custom compositor, medium on the new foundation. **Unresolved:** Quickshell feature/accessibility matrix, Hyprland permission model, boot chain. **Experiment:** E03 (re-scoped), E26–E29. **Sources:** above, [migration report](engineering/OMARCHY_MIGRATION.md). **Last verified:** 2026-10-27.

## Q3: What enforces agent authority?

**Question:** Can a model/tool safely perform system actions?
**Options:** A: small typed capabilities with deterministic policy and Linux enforcement; B: arbitrary shell + sudo or model-determined policy.
**Evidence:** [Polkit](https://polkit.pages.freedesktop.org/polkit/polkit.8.html) authorizes privileged mechanisms, not natural-language intent. [Landlock](https://docs.kernel.org/userspace-api/landlock.html), [seccomp](https://docs.kernel.org/userspace-api/seccomp_filter.html) and [cgroups v2](https://docs.kernel.org/admin-guide/cgroup-v2.html) address different boundaries; none alone replaces authorization.

| Dimension | Option A | Option B |
| --- | --- | --- |
| Pros / cons | Bounded, auditable targets; per-capability work | Broad coverage quickly; authority cannot be bounded reliably |
| Security | Independent broker checks, request-bound grants, least privilege | Prompt injection, shell injection and confused deputy exposure |
| Performance | Measure policy/audit overhead | Fast dispatch offers no acceptable safety tradeoff |
| Maintenance | Narrow contracts and regression suites | Unbounded commands and hidden effects |

**Recommendation:** A mandatory. Warden stays RESEARCH: the intended upstream is now identified ([Prof-bilal/Warden](https://github.com/Prof-bilal/Warden), MIT), but its Linux enforcement behavior is not yet validated by our own bypass tests. Do not claim Warden support from a name, README or CI badge. **Confidence:** high architecture; no Warden confidence yet. **Unresolved:** enforceable sandbox ABI matrix, broker identity races, one-shot grant lifecycle, Warden Linux bypass results on mainline/LTS. **Experiment:** E04–E06. **Sources:** above and [sandboxing](security/SANDBOXING.md), [threat model](security/THREAT_MODEL.md). **Last verified:** 2026-10-24.

## Q4: What does snapshot recovery actually cover?

**Question:** Can “undo the last action” be honest and reliable?
**Options:** A: Btrfs/Snapper eligible transactions; B: image-based immutable deployment plus separate data recovery.
**Evidence:** [Btrfs snapshots](https://btrfs.readthedocs.io/en/latest/btrfs-subvolume.html) operate on subvolumes; boot assets and other mounts require separate handling. Owning [recovery contract](system/BTRFS_ROLLBACK.md) records Snapper limitations and sources.

| Dimension | Option A | Option B |
| --- | --- | --- |
| Pros / cons | Fits Arch tooling; partial effects and boot consistency need orchestration | Deployment boundaries clearer; different packaging/update product |
| Security | Recovery authority, downgrade risk and surviving audit need review | Signed deployments still cannot undo exfiltration or external effects |
| Performance | Snapshot/storage costs must be measured | Image transfer/storage costs must be measured |
| Maintenance | Layout + package DB + ESP consistency tests | Image composition and application/data separation |

**Recommendation:** A initially with explicit per-operation coverage; reconsider only after failed experiments. **Confidence:** medium. **Unresolved:** ESP recovery, crash consistency, audit placement, encrypted layout and installer fit. **Experiment:** E02/E07. **Sources:** above, [systemd-boot](https://www.freedesktop.org/software/systemd/man/latest/systemd-boot.html). **Last verified:** 2026-10-18.

## Q5: How much runtime infrastructure is justified?

**Question:** How do AI providers and local metadata remain replaceable and inexpensive?
**Options:** A: Rust modules + D-Bus + SQLite/FTS5; B: service mesh/RPC/server database and vendor-specific types.
**Evidence:** [SQLite use cases](https://www.sqlite.org/whentouse.html) describe embedded local storage; [FTS5](https://www.sqlite.org/fts5.html) supplies text indexing. [Rust book](https://doc.rust-lang.org/book/) supplies language guidance, not memory/performance guarantees. Provider API evidence is recorded in [model router](ai/MODEL_ROUTER.md).

| Dimension | Option A | Option B |
| --- | --- | --- |
| Pros / cons | Few processes and local state; explicit concurrency/migration work | More infrastructure; unnecessary desktop operational cost |
| Security | Separate privileged audit store from user metadata | Broader credentials/listeners and additional trust boundaries |
| Performance | Measure idle, execution and indexing overhead | Server/RPC overhead has no demonstrated benefit here |
| Maintenance | Stable neutral adapter tests | More deployments and vendor leakage |

**Recommendation:** A; one cloud + Ollama acceptance first. sqlite-vec remains later RESEARCH after unmet search evidence; no server DB. **Confidence:** high direction, adapters untested. **Unresolved:** streaming cancellation, local model resource contention, credentials, schema migration. **Experiment:** E08/E09. **Sources:** above and [AI architecture](ai/AI_ARCHITECTURE.md). **Last verified:** 2026-10-18.

## Q6: How should tool portability work?

**Question:** Where does durable agent knowledge live?
**Options:** A: AGENTS.md + docs + portable skills with thin supported adapters; B: architecture duplicated into each tool's private format.
**Evidence:** Official [Codex instructions](https://developers.openai.com/codex/guides/agents-md), [skills specification](https://agentskills.io/specification), [OpenCode v2 agents](https://opencode.ai/v2/docs/agents), [Command Code agents](https://commandcode.ai/docs/agents), and [Freebuff upstream](https://github.com/CodebuffAI/freebuff) were inspected. Exact compatibility caveats and additional source links live in [workflow](AGENT_WORKFLOW.md).

| Dimension | Option A | Option B |
| --- | --- | --- |
| Pros / cons | Shared memory and small adapters; discovery differs by client | Automatic discovery may be easier; knowledge drifts |
| Security | Review executable skills and actual tool permissions | Vendor settings can silently diverge |
| Performance | Load only relevant skill references | Repeated large instruction payloads |
| Maintenance | One canonical contract per concern | Conflicting instruction copies |

**Recommendation:** A. OpenCode v2 adapters intentionally avoid v1-specific permissions; Command Code reuses General/Explore/Plan. Tool prompts do not enforce OS security. Freebuff automatic skill discovery is unverified; explicitly ask it to read canonical files. **Confidence:** high formats at research date; installed clients untested. **Unresolved:** actual tool versions, discovery and permission defaults. **Experiment:** E10. **Sources:** above. **Last verified:** 2026-10-18.

## Q7: Should the prototype create a new device protocol?

**Question:** How to offer realistic Android continuity without expanding V1?
**Options:** A: evaluate/reuse KDE Connect, ADB/scrcpy and bounded existing transports later; B: invent unified sync protocol and promise feature parity.
**Evidence:** [Android research](connect/ANDROID.md), [cross-device transport research](connect/CROSS_DEVICE.md) and [connectivity](connect/CONNECT.md) record inspected upstream sources and source-access limitations. Android/iOS platform restrictions are not bypassed by a new Linux service.

| Dimension | Option A | Option B |
| --- | --- | --- |
| Pros / cons | Existing ecosystem; capabilities vary by platform/permission | Unified design; vast protocol/client/security burden |
| Security | Pairing/revocation and per-feature consent still required | New discovery, crypto and identity attack surface |
| Performance | Measure latency/bandwidth/power on devices | No evidence custom transport improves results |
| Maintenance | Track upstream/API behavior | Own mobile clients and compatibility matrix |

**Recommendation:** A, Phase 11 only. **Confidence:** medium; KDE Connect repository/wiki inspection partly blocked. **Unresolved:** notification reply/SMS/calls/device APIs, screen/webcam constraints, iOS limits. **Experiment:** E11. **Sources:** linked contracts. **Last verified:** 2026-10-18.

## Q11: One parent AI system or many peer agents?

**Question:** How should the many specialised capabilities be organised around the model?
**Options:** A: one parent orchestrator + bounded, declarative child agents; B: many peer agents with direct handoffs.
**Evidence:** Practitioner and survey write-ups on agentic systems describe compounding error, context growth, runaway loops, cost blow-up and unclear accountability in peer topologies, and converge on a supervising parent with bounded workers; agent definitions in current tooling are declarative (metadata + focused workflow, i.e. an Agent Skills style `SKILL.md`), not executable plugins. Sources below.
**Recommendation:** A; no child-to-child channels in V1 and no new daemon. **Confidence:** medium-high on architecture, no runtime. **Unresolved:** real latency/cost of delegation vs one loop; purpose-collision handling; the exact child schema. **Experiment:** E21. **Sources:** orchestration write-ups in the register sources below.

## Q12: How do the five first-party projects fit Axiom?

**Question:** The five sibling projects share Axiom's author. How do they integrate without repeating the unverified-dependency mistake (ADR-007)?
**Options:** A: co-evolve each into an Axiom subsystem behind an adapter, shaped to a stated capability, with the core desktop working when all are absent; B: adopt them as-is or hard-depend on them.
**Evidence:** Each project's README was read 2026-10-25 — Warden (Go, MIT; bubblewrap deny-by-default sandbox; self-declared not hardened against a determined local attacker), RepoSpine (TypeScript, MIT; local-first code context; **repo-scoped**; Node ≥22.13), ContextGit (Python, Apache-2.0; content-addressed context VCS; already used in this repository), ModelCheck (TypeScript; licence **MIT** decided 2026-10-25, file not yet committed), Morphix (Rust/Tauri, MIT OR Apache-2.0; KDE Plasma 6; **rollback engine unimplemented — its Phases 5–6**). Ownership removes the licence-*permission* question but not the engineering evidence.
**Recommendation:** A; shape each product to Axiom's contracts, keep adapters for replaceability (ADR-008), pin revisions, and hold the existing evidence gates. **Confidence:** high on ownership and boundaries, low on each product's runtime fit. **Unresolved:** RepoSpine system scope, ContextGit runtime API, Warden typed interface, Morphix phase dependency. **Experiment:** E22. **Sources:** [ecosystem](ai/ECOSYSTEM.md).

## Q13: How should developer environments be provisioned?

**Question:** How do we let a developer pick a stack and get a reproducible, reversible environment?
**Options:** A: user-scope reversible methods first (version managers, rootless containers, declarative envs), system packages last; B: install everything as system packages.
**Evidence:** Public comparisons of devcontainers, Nix, devbox, mise and asdf trade isolation, reproducibility and setup cost; RepoSpine's documented `atlas setup` demonstrates the select-and-consent UX (installs only what you pick).
**Recommendation:** A; the container socket is treated as root-equivalent, services bind loopback-only, and nothing installs before confirmation. **Confidence:** medium direction, unmeasured. **Unresolved:** benchmarked disk/time; irreversibility messaging for database data; rootless availability. **Experiment:** E23. **Sources:** [dev environments](engineering/DEV_ENVIRONMENTS.md).

## Q14: How should the install-time developer checklist select and provision tooling?

**Question:** How do we let a developer tick IDE, AI tools, languages and datastores at install and get them provisioned safely?
**Options:** A: curated checklist recorded at install, applied by a first-boot job from a declarative profile; B: a fixed "developer edition" package list; C: provision inside the installer chroot.
**Evidence:** **PARTIAL — superseded by ADR-013 (2026-10-27).** The earlier external pass could not gather installer evidence; after ADR-013 the candidate is the Omarchy-derived ISO/configurator flow, not Calamares. In-repo only: [installer](engineering/INSTALLER.md) now prefers the proven upstream flow; RepoSpine's `atlas setup` verifies a nothing-preselected select-and-confirm flow; Morphix verifies plan → snapshot → apply → verify.
**Recommendation:** A, provisional and unverified; installer choice is re-scoped to the Omarchy-derived flow by ADR-013. **Confidence:** low (research incomplete). **Unresolved:** Omarchy-derived installer persistence/first-boot hook; profile reuse and attribution; failure UX; whether any online in-installer provisioning is acceptable. **Experiment:** E25. **Sources:** [install checklist](engineering/INSTALL_CHECKLIST.md).

## Q26: Should Axiom adopt Omarchy as its upstream foundation?

**Question:** What should Axiom inherit from Omarchy, and on what revision?
**Options:** A: keep raw Arch + Plasma/KWin; B: raw Arch + custom Hyprland/Quickshell; C: Omarchy-derived Arch/Hyprland/Quickshell with Axiom-owned product layers.
**Evidence:** [migration report](engineering/OMARCHY_MIGRATION.md), upstream `omacom/omarchy` `v4.0.6` (`237f1b40`), `quattro` `39d56653`, `omarchy-iso`, Quickshell `v0.3.2`, Hyprland `v0.56.2`. Omarchy is MIT; Quickshell is LGPL-3.0-only; Hyprland BSD-3-Clause. The Omarchy default branch is a `4.0.0.alpha` pre-release; stable artifacts come from tags/packages.
**Recommendation:** C as a researched direction, pinned to stable releases; Axiom owns identity, shell, AI runtime, security and system APIs. **Confidence:** medium-high on reuse, low on individual integrations. **Unresolved:** boot chain, Secure Boot/TPM, Quickshell accessibility/reduced motion, asset licensing. **Experiment:** E26–E33. **Last verified:** 2026-10-27.

## Q27: Is Quickshell sufficient for the complete Axiom Shell?

**Question:** Which shell surfaces can Quickshell implement, and what must Axiom build?
**Options:** A: Quickshell for the shell; B: keep Plasma shell; C: custom compositor/shell.
**Evidence:** Quickshell `v0.3.2` provides layer-shell panels/docks, popups, session lock, notifications, StatusNotifier/DBusMenu, PipeWire, NetworkManager, BlueZ, UPower, MPRIS, polkit, screencopy and Hyprland IPC. It has no launcher UI, clipboard manager, OSD UI, logind helper or reduced-motion handling; it uses private Qt APIs and expects API breaks in minor releases. A lock/shell crash path was reported upstream. Axiom Shell must build those missing surfaces.
**Recommendation:** A; Hyprland remains the compositor; do not build a compositor. **Confidence:** medium; the missing surfaces are real work. **Unresolved:** accessibility completeness, lock robustness, idle cost. **Experiment:** E27, E29. **Last verified:** 2026-10-27.

## Q28: Secure Boot, TPM and encryption under an Omarchy-derived base

**Question:** Can Axiom keep its stronger boot trust direction if upstream requires Secure Boot and TPM to be disabled?
**Options:** A: inherit the upstream limitation; B: signed boot/UKI + LUKS2 divergence; C: defer.
**Evidence:** Omarchy's getting-started manual instructs users to turn off Secure Boot and/or TPM; LUKS full-disk encryption is the default but no TPM-sealed unlock is documented. Axiom's target is signed boot/UKI and LUKS2; nothing is implemented.
**Recommendation:** B as a RESEARCH divergence; do not claim support and do not silently inherit the limitation. **Confidence:** low until the experiment runs. **Unresolved:** UKI signing, key custody, PCR policy, recovery. **Experiment:** E28, E30. **Last verified:** 2026-10-27.

## Q29: Does Morphix remain useful after the foundation change?

**Question:** Morphix is Plasma 6 only with no transaction/rollback engine. Does it still fit?
**Options:** A: add a Hyprland/Quickshell adapter; B: redesign shell-agnostic; C: defer/remove from the immediate integration plan.
**Evidence:** `Prof-bilal/Morphix` `main` `1ee76d11`; dual MIT/Apache-2.0; no releases; README states no user-facing functionality yet and no transaction/rollback or KDE adapter writes; Plasma `>=6.0,<7.0` only.
**Recommendation:** C for the immediate plan, with A or B as a later recorded decision after the Foundation POC. **Confidence:** high on the current limitation, medium on the replacement shape. **Unresolved:** whether declarative shell customization is better owned by Axiom Shell itself. **Experiment:** none yet; a design decision after E26/E27. **Last verified:** 2026-10-27.

## Q30: Which boot chain and recovery integration should Axiom use?

**Question:** Omarchy ships Limine + UKI; Axiom accepted systemd-boot. Which is the base?
**Options:** A: adopt Limine/UKI; B: keep systemd-boot; C: support both.
**Evidence:** Omarchy's Limine/UKI integration includes bootable snapshots and direct-EFI entries; Axiom's ADR-002 accepted systemd-boot and its Btrfs experiment assumes systemd-boot entry selection.
**Recommendation:** RESEARCH; decide by E28 on an encrypted Btrfs layout. Do not silently replace ADR-002. **Confidence:** low until measured. **Unresolved:** snapshot boot generation, ESP consistency, Secure Boot interaction. **Experiment:** E28. **Last verified:** 2026-10-27.

## Coverage and evidence ownership

| Required research topics | Evidence and limitations |
| --- | --- |
| Arch, archiso, PKGBUILD, pacman, Flatpak | [Packaging](system/PACKAGING.md), [ISO](engineering/ISO_BUILD.md); blocked Arch pages acknowledged; accessible upstream/manual evidence distinguished |
| Hyprland, Quickshell, Qt 6, QML, Wayland, portals | [UX](desktop/DESKTOP_UX.md), [Wayland](desktop/WAYLAND.md), [design tokens](desktop/DESIGN_SYSTEM.md) |
| D-Bus, systemd, credentials, Polkit | [Systemd](system/SYSTEMD.md), [AI](ai/AI_ARCHITECTURE.md), [permissions](security/PERMISSIONS.md) |
| namespaces, capabilities, cgroups v2, seccomp, Landlock, bubblewrap | [Sandboxing](security/SANDBOXING.md); no universal support claim |
| Btrfs, Snapper, bootloader consistency | [Recovery](system/BTRFS_ROLLBACK.md) |
| PipeWire, WirePlumber, NetworkManager, BlueZ, Mesa | [Systemd integration](system/SYSTEMD.md); GPU/hardware tests pending |
| Omarchy-derived installer, QEMU/KVM, GitHub Actions | [Installer](engineering/INSTALLER.md), [ISO](engineering/ISO_BUILD.md), [testing](engineering/TESTING.md), [release](engineering/RELEASE.md) |
| zram, PSI, power-profiles-daemon, resource controls | [Performance](system/PERFORMANCE.md), [benchmarks](engineering/BENCHMARKS.md); NOT YET MEASURED |
| MCP, Ollama, OpenAI, Anthropic, Gemini, OpenRouter | [MCP](ai/MCP.md), [router](ai/MODEL_ROUTER.md); protocol/version conformance tests pending |
| Agent Skills, Codex, OpenCode, Command Code, Freebuff | [Workflow](AGENT_WORKFLOW.md); installed tool smoke tests pending |
| KDE Connect, ADB, scrcpy, WebRTC, QUIC, TLS, mDNS/Avahi, BLE | [Android](connect/ANDROID.md), [cross-device](connect/CROSS_DEVICE.md); pairing/feature evidence pending |

## Experiment register

All experiments are **NOT RUN** except where a status is noted; E05 identification is recorded (2026-10-24) while its runtime bypass tests remain NOT RUN. Owners are specialist roles in [SUBAGENTS](SUBAGENTS.md). Save future raw artifacts with build/input manifests, versions, command lines, timestamps, exit status, expected/observed results and redacted logs. A failed experiment updates the ADR and phase gate; it is not silently worked around. Register gap: ADR-010 references Flow research Q8–Q9, which are not present in this register; recorded to close rather than paper over. Q11–Q13 were added 2026-10-25 with the first-party product and agent-system design ([agent system](ai/AGENT_SYSTEM.md), [ecosystem](ai/ECOSYSTEM.md), [dev environments](engineering/DEV_ENVIRONMENTS.md)).

| ID / owner / phase | Experiment and pass condition |
| --- | --- |
| E01 linux-base + release / 1 | Two independent controlled archiso builds; compare manifests/hashes, explain nondeterminism; boot each with retained logs |
| E02 linux-base + QA / 1, 8 | UEFI/Btrfs/root+package database+ESP recovery layout; recovered state boots coherently or clear unsupported coverage blocks commit |
| E03 desktop + QA / 3 | Hyprland/Quickshell shell on pinned versions, keyboard/a11y/reduced-motion/multi-DPI; portals/Hyprland permissions deny unsolicited input/capture |
| E04 security + systems-rust / 4, 7 | D-Bus authenticated peer, UID/session/disconnect, grant replay/expiry/target swap and Polkit confusion; no unauthorized mutation |
| E05 security + researcher / 0, 7 | Identify Warden repo/revision/license; inspect implementation; namespace/seccomp/Landlock/network bypass tests on main/LTS; reject unsupported assumptions. **RE-VERIFIED 2026-10-27**: [Prof-bilal/Warden](https://github.com/Prof-bilal/Warden) MIT, `main` `f7c9793167`; the earlier `cd5e8bf2…` pin is the `axiom/integration` tip, not `main` or `v0.1.17`; Linux backend is bubblewrap + setpriv + strace (no seccomp/Landlock); bypass tests **NOT RUN** |
| E06 security + QA / 7 | Fail audit persistence, broker crash and disk-full; no unrecorded privileged mutation, explicit uncertain outcomes reconciled |
| E07 QA + linux-base / 8 | Hook failure, power-loss simulation, exhausted snapshot space, failed boot and rollback bypass; test surviving audit and manual recovery |
| E08 ai-runtime + QA / 5 | One cloud and Ollama conform to neutral streaming/error/cancel types; no cloud required for core desktop; no implicit content forwarding |
| E09 performance / 2, 9 | Baseline/candidate boot, idle, latency, pressure and agent overhead; raw runs/variance and thresholds; hardware-only battery claim |
| E10 architect + QA / 0–1 | On installed versions of all four tools load AGENTS and selected skill; discover adapters where supported; verify permissions; inspect .agents after mount restriction removed |
| E11 connect + security / 11 | Android pairing/revocation, discovery spoof/MITM, file traversal and feature matrix; report unsupported SMS/calls/iOS behaviors |
| E12 release + QA / 10 | Disposable Omarchy-derived install, signed full update, interrupted-update recovery and release input provenance; no real host disk use |
| E21 ai-runtime + security / 6–7 | Child-agent contract validation: delegation bounds, no self-authorization, budget/step/cost cascade, purpose-collision rejection, untrusted child definition; no unauthorized mutation |
| E22 release + security / 5–7 | First-party integration: pinned revision + licence inventory (ModelCheck), adapter-absence test (core desktop works with every product removed), untrusted-output handling |
| E23 qa + architect / 3–4 | Pick-your-stack provisioning: reproducible apply/remove, isolation proof (services loopback-only, no socket exposure), correct permission class, data-irreversibility messaging |
| E24 performance + ai-runtime / 5, 9 | Candidate-model evaluation before it becomes a default; record the measured delta and the rollback of the default |
| E25 qa + release / 10 | Install checklist: profile recorded at install but not applied there; first-boot provisioning per-item outcomes; offline deferral; idempotent re-apply; no pre-selection; loopback-only services |
| E26 migration / 2 | Boot pinned stable Omarchy with Axiom identity in QEMU; clean UEFI boot, Hyprland/Quickshell session, no visible Omarchy branding, retained logs |
| E27 migration + desktop / 2–3 | Pinned Quickshell Axiom Shell smoke: panel, launcher, notifications, audio, network, lock; responsive and keyboard-accessible |
| E28 linux-base + security / 2 | Boot-chain decision on encrypted Btrfs: Limine/UKI vs systemd-boot reversal and rollback, with fallback kernel |
| E29 performance / 2 | Quickshell idle RSS/CPU and private-Qt rebuild behavior; pin/rebuild policy recorded |
| E30 security / 2 | Secure Boot/TPM divergence feasibility with UKI + LUKS2, or explicit rejection with evidence |
| E31 ai-runtime + context / 6 | RepoSpine bounded context + ContextGit per-agent branch isolation, no collisions, graceful absence |
| E32 security / 7 | Warden request→policy generation, audit correlation, fail-closed and bypass matrix on mainline and LTS |
| E33 release + migration / 2, 10 | Upstream-divergence upgrade test: Axiom customization survives an Omarchy-derived update |

## Remaining foundation limitation

The authoring sandbox exposes `.agents` and `.git` as read-only empty mounts. Skills are authored under `portable-skills/skills/`; installation cannot complete here. Git status/diff and commit creation cannot be validated here. This is an environment constraint, not a supported alternative to canonical discovery. Python in this session also inherited broken AppImage PYTHONHOME/PYTHONPATH; use `python3 -E` for the validation commands if that environment persists. No environment variables or host services were changed.
