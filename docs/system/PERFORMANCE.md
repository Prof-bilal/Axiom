# Performance policy

Status: V1 measurement plan; no tuning has been validated. Last researched: 2026-10-18.

The default profile is Balanced. Eco and Performance map to hardware-supported power-profiles-daemon profiles where available; Development and Gaming are LATER workload policies, not invented firmware modes. Query supported profiles rather than assuming availability. Do not run competing power managers.

| Signal | Proposed use | Safety requirement |
|---|---|---|
| CPU, memory, I/O PSI | Explain stalls and correlate workloads | Pressure is evidence of contention, not proof of its cause |
| cgroups v2 | Attribute agent/container costs; bound background jobs | Never starve compositor, input, or authorization UI |
| zram | Compare compressed swap under memory pressure | Measure CPU cost, OOM behavior and interaction with disk swap |
| systemd controls | Evaluate CPUWeight, IOWeight, MemoryHigh | Test degraded operation and restore defaults |
| battery/thermal sensors | Explain sustained drain or throttling | State missing sensors and observation interval |

Start with on-demand read-only telemetry inside existing services; performanced is LATER until sampling, persistence or scheduling justifies a daemon. Diagnostics must show timestamps, sources and uncertainty; model explanations cannot invent causal findings. Process command lines may contain secrets and are excluded by default.

Proposed reference test environment: x86_64, 4 vCPU/8 GiB VM for repeatable functional comparison; separately one documented integrated-GPU laptop for battery and GPU testing. VM results cannot establish real battery improvement.

| Metric | Initial TARGET (proposal) | MEASURED |
|---|---|---|
| Boot and login-to-interactive | No >5% median regression against pinned baseline | NOT YET MEASURED |
| Idle RAM / CPU | No >5% regression against branded Plasma baseline | NOT YET MEASURED |
| Launcher / app startup | No >5% p95 regression | NOT YET MEASURED |
| Memory-pressure responsiveness | Complete defined interactive scenario without lost input | NOT YET MEASURED |
| Battery impact | No >5% energy increase in fixed workload | NOT YET MEASURED |
| Agent idle/execution overhead | Record incremental RSS, wakeups, CPU time and latency | NOT YET MEASURED |

Use [benchmark methodology](../engineering/BENCHMARKS.md); targets are review thresholds, not product claims. Tune one variable at a time and retain an immediate revert path.

Sources: [kernel PSI](https://docs.kernel.org/accounting/psi.html), [zram](https://docs.kernel.org/admin-guide/blockdev/zram.html), [systemd resource controls](https://www.freedesktop.org/software/systemd/man/latest/systemd.resource-control.html), [power-profiles-daemon reference](https://upower.pages.freedesktop.org/power-profiles-daemon/).
