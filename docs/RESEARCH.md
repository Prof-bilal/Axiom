# Research and experiment register

Last research pass: **2026-10-18**. Evidence is official documentation/upstream source where accessible. “Verified” means the cited text was inspected, not that Axiom integration works. ArchWiki/GitLab and some KDE/Calamares pages presented access challenges; blocked pages are not treated as read evidence. Implementation, hardware support and tool discovery remain untested. Source links are retained near the owning contracts rather than copied manuals.

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

**Recommendation:** A, no custom compositor V1. **Confidence:** high, particular integrations unproven. **Unresolved:** portal/KWin feature matrix, keyboard/focus behavior, accessibility. **Experiment:** E03. **Sources:** above and [desktop](desktop/DESKTOP_UX.md). **Last verified:** 2026-10-18.

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

**Recommendation:** A mandatory. Warden stays RESEARCH: multiple unrelated projects share the name; exact repository/revision/license and Linux behavior are unresolved. Do not claim Warden support from a name or README. **Confidence:** high architecture; no Warden confidence yet. **Unresolved:** enforceable sandbox ABI matrix, broker identity races, one-shot grant lifecycle. **Experiment:** E04–E06. **Sources:** above and [sandboxing](security/SANDBOXING.md), [threat model](security/THREAT_MODEL.md). **Last verified:** 2026-10-18.

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

## Coverage and evidence ownership

| Required research topics | Evidence and limitations |
| --- | --- |
| Arch, archiso, PKGBUILD, pacman, Flatpak | [Packaging](system/PACKAGING.md), [ISO](engineering/ISO_BUILD.md); blocked Arch pages acknowledged; accessible upstream/manual evidence distinguished |
| Plasma 6, Qt 6, QML, KWin, Wayland, portals | [UX](desktop/DESKTOP_UX.md), [Wayland](desktop/WAYLAND.md), [design tokens](desktop/DESIGN_SYSTEM.md) |
| D-Bus, systemd, credentials, Polkit | [Systemd](system/SYSTEMD.md), [AI](ai/AI_ARCHITECTURE.md), [permissions](security/PERMISSIONS.md) |
| namespaces, capabilities, cgroups v2, seccomp, Landlock, bubblewrap | [Sandboxing](security/SANDBOXING.md); no universal support claim |
| Btrfs, Snapper, bootloader consistency | [Recovery](system/BTRFS_ROLLBACK.md) |
| PipeWire, WirePlumber, NetworkManager, BlueZ, Mesa | [Systemd integration](system/SYSTEMD.md); GPU/hardware tests pending |
| Calamares, QEMU/KVM, GitHub Actions | [Installer](engineering/INSTALLER.md), [ISO](engineering/ISO_BUILD.md), [testing](engineering/TESTING.md), [release](engineering/RELEASE.md) |
| zram, PSI, power-profiles-daemon, resource controls | [Performance](system/PERFORMANCE.md), [benchmarks](engineering/BENCHMARKS.md); NOT YET MEASURED |
| MCP, Ollama, OpenAI, Anthropic, Gemini, OpenRouter | [MCP](ai/MCP.md), [router](ai/MODEL_ROUTER.md); protocol/version conformance tests pending |
| Agent Skills, Codex, OpenCode, Command Code, Freebuff | [Workflow](AGENT_WORKFLOW.md); installed tool smoke tests pending |
| KDE Connect, ADB, scrcpy, WebRTC, QUIC, TLS, mDNS/Avahi, BLE | [Android](connect/ANDROID.md), [cross-device](connect/CROSS_DEVICE.md); pairing/feature evidence pending |

## Experiment register

All experiments are **NOT RUN**. Owners are specialist roles in [SUBAGENTS](SUBAGENTS.md). Save future raw artifacts with build/input manifests, versions, command lines, timestamps, exit status, expected/observed results and redacted logs. A failed experiment updates the ADR and phase gate; it is not silently worked around.

| ID / owner / phase | Experiment and pass condition |
| --- | --- |
| E01 linux-base + release / 1 | Two independent controlled archiso builds; compare manifests/hashes, explain nondeterminism; boot each with retained logs |
| E02 linux-base + QA / 1, 8 | UEFI/Btrfs/root+package database+ESP recovery layout; recovered state boots coherently or clear unsupported coverage blocks commit |
| E03 desktop + QA / 3 | Plasma/QML packaging across pinned versions, keyboard/a11y/multi-DPI; portals deny unsolicited input/capture |
| E04 security + systems-rust / 4, 7 | D-Bus authenticated peer, UID/session/disconnect, grant replay/expiry/target swap and Polkit confusion; no unauthorized mutation |
| E05 security + researcher / 0, 7 | Identify Warden repo/revision/license; inspect implementation; namespace/seccomp/Landlock/network bypass tests on main/LTS; reject unsupported assumptions |
| E06 security + QA / 7 | Fail audit persistence, broker crash and disk-full; no unrecorded privileged mutation, explicit uncertain outcomes reconciled |
| E07 QA + linux-base / 8 | Hook failure, power-loss simulation, exhausted snapshot space, failed boot and rollback bypass; test surviving audit and manual recovery |
| E08 ai-runtime + QA / 5 | One cloud and Ollama conform to neutral streaming/error/cancel types; no cloud required for core desktop; no implicit content forwarding |
| E09 performance / 2, 9 | Baseline/candidate boot, idle, latency, pressure and agent overhead; raw runs/variance and thresholds; hardware-only battery claim |
| E10 architect + QA / 0–1 | On installed versions of all four tools load AGENTS and selected skill; discover adapters where supported; verify permissions; inspect .agents after mount restriction removed |
| E11 connect + security / 11 | Android pairing/revocation, discovery spoof/MITM, file traversal and feature matrix; report unsupported SMS/calls/iOS behaviors |
| E12 release + QA / 10 | Disposable Calamares install, signed full update, interrupted update recovery and release input provenance; no real host disk use |

## Remaining foundation limitation

The authoring sandbox exposes `.agents` and `.git` as read-only empty mounts. Skills are authored under `portable-skills/skills/`; installation cannot complete here. Git status/diff and commit creation cannot be validated here. This is an environment constraint, not a supported alternative to canonical discovery. Python in this session also inherited broken AppImage PYTHONHOME/PYTHONPATH; use `python3 -E` for the validation commands if that environment persists. No environment variables or host services were changed.
