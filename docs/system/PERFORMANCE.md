# Performance policy and Axiom Flow

Status: Phase 0 design and measurement plan; no tuning or Flow behavior validated. Last researched: 2026-10-18. **All measurements: NOT YET MEASURED.** [FLOW.md](FLOW.md) owns the detailed resource-orchestration design; this document owns shared profiles, success criteria and targets.

## Responsiveness policy

Optimize foreground response and useful background progress, not the lowest RAM number. High allocation can be healthy; excessive stalls, latency and contention need evidence. Flow orchestrates existing Linux/systemd controls without replacing scheduling or requiring an LLM. The performance doctor uses timestamped deterministic facts; optional AI explanation never sits in the control loop.

Use logical application groups from systemd scopes/services and cgroup v2, preserving the Hyprland/Quickshell session/application/background boundaries. Avoid disconnected PID rankings and double counting. Unknown mappings/controller support are visible limitations. Classify foreground, visible background, background/heavy, critical, pinned, agent, development, media and game workloads using activity/overrides; details and precedence live in [Flow](FLOW.md).

| Signal | Flow policy use | Constraint |
| --- | --- | --- |
| Host/group CPU, memory and I/O PSI | Detect sustained stalls and validate pressure-state transitions | Stalls are not a RAM percentage or proof of a specific culprit |
| Per-workload CPU/memory/swap/I/O | Attribute budget use and compare interventions | Shared resources and device accounting can be incomplete |
| Focus/visibility/media/task hints | Bounded responsiveness preference; veto unsafe sleep | No content inspection; missing evidence disables risky actions |
| Unit properties/events | Manual Efficient weights, tested soft budget/reclaim | Inspect effective ancestors; support/write success is not measured efficacy |
| Battery/thermal/compression | Avoid moving pressure into CPU/energy/storage cost | Physical battery evidence required; no conflicting power managers |

Proposed states NORMAL → PRESSURED → CONSTRAINED → CRITICAL escalate from observation and soft weights to separately authorized reclaim, compatible sleep proofs and emergency response. Thresholds, dwell/cooldown and retry limits are experimental. CPU-only stalls must not trigger memory reclaim. Freeze stops execution; memory recovery is a separate mechanism, with resume costs. Flow never kills applications as normal optimization; oomd integration is an independent, carefully scoped last-resort experiment.

Start on demand. One lightweight per-user `flowd` is a candidate only if event/lifecycle needs and measured overhead justify persistence; replaces the speculative `performanced` name, not a second daemon. Resource Guard is a module protecting essential interactive progress through reviewed existing controls. No broad memory.min, real-time scheduling or privileged resource-control passthrough. See [systemd integration](SYSTEMD.md).

## One performance-profile system

Balanced remains the proposed default. Query supported power-profiles-daemon profiles. Eco maps to advertised power-saver where available; Performance to advertised performance. Do not invent hardware modes or compete with another power manager. Development/Gaming are later workload presets layered on a supported hardware profile. Flow weights/budgets do not override safety/user rules. [Upstream power profiles](https://upower.pages.freedesktop.org/power-profiles-daemon/).

| Existing profile | Proposed Flow participation, unvalidated |
| --- | --- |
| Eco | Prefer explicitly enrolled Efficient background policy, fewer admitted/concurrent agents; no default automatic sleep |
| Balanced | Bounded foreground preference proof and conservative background progress; compatible sleep remains optional/later |
| Performance | Retain responsiveness/fairness and configured job budgets; no unlimited CPU/memory or forced performance when unavailable |
| Development — LATER | Protect IDE interaction and active compiler progress; keep selected containers/services active; chat may be Efficient |
| Gaming — LATER | Prioritize enrolled game within bounds; lower background agents; cooperatively defer optional indexing/Sentinel only under explicit policy |

User overrides win over Flow heuristics while machine/security ceilings remain authoritative. Per-app Adaptive, Efficient, Never Restrict, High Priority and temporary Keep Active controls must report effective support. Sleep When Inactive ships only after compatibility and recovery gates. No opaque preference learning in V1.

## Targets and measurement

Success requires reduced stalls and foreground latency under the declared contention scenario, fewer whole-desktop hangs/emergency kills, predictable background progress and acceptable thaw/energy costs. Saving a fixed number of MB alone is not success. Existing 5% regression review gates remain proposals, never evidence of achievement. Device-specific absolute floors require baselines first.

| Metric | TARGET — unvalidated proposal | MEASURED |
| --- | --- | --- |
| Boot / login-to-interactive | No >5% median regression beyond noise; startup experiments must improve desktop-ready without losing optional work | NOT YET MEASURED |
| Idle RAM/CPU | No >5% regression against the pinned Axiom baseline; separately report Flow incremental PSS/CPU/wakeups | NOT YET MEASURED |
| Launcher / app startup | No >5% p95 regression beyond noise with adequate samples | NOT YET MEASURED |
| Foreground input/switch/frame response under pressure | Improve paired latency/stall distributions beyond noise without starvation; absolute target pending baseline | NOT YET MEASURED |
| Stall exposure / hangs / OOM | Reduce sustained stalls and emergency events under equal offered load; no hidden work loss or Flow kill-as-optimization | NOT YET MEASURED |
| Resume and app compatibility | First usable frame and intact work/connections; budget calibrated per class; fail closed on incompatibility | NOT YET MEASURED |
| Battery / thermals / swap | No >5% energy regression beyond noise in fixed hardware workload; report compression CPU and disk writes | NOT YET MEASURED |
| Agent / Sentinel work | Preserve predeclared minimum throughput and explicit budgets while maintaining foreground latency | NOT YET MEASURED |
| Flow service overhead | Bounded idle/pressure overhead materially below benefit; numeric budget fixed after POC baseline, before promotion | NOT YET MEASURED |

Follow the existing [benchmark protocol and Flow scenarios](../engineering/BENCHMARKS.md), [test strategy](../engineering/TESTING.md) and [research experiments](../RESEARCH.md). Functional VM checks do not establish hardware GPU/input/battery behavior. Measure 4/8/16/32 GiB systems for zram candidates; choose no universal size, algorithm, pressure threshold or memory protection before data. Keep tuning individually revertible; snapshots cannot undo lost application/network state.
