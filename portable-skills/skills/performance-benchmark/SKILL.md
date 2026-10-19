---
name: performance-benchmark
description: "Measure performance changes with reproducible baselines and uncertainty."
---

# performance-benchmark

## When to use

Use for performance claims or tuning. Do not use for accepting subjective speed impressions.

## Required inputs

Hardware, kernel/build/configuration, workload, metric/tool, runs and predeclared threshold. For Flow: offered memory/CPU/I/O load, foreground/background apps and grouping, profile/power state, swap/zram/oomd setup, controller support, Flow OFF/ON policy and explicit safety/cleanup limits.

## Procedure

1. Record hardware, firmware, power/thermal conditions, background tasks and exact baseline/candidate revisions.
2. Define metric, units, warm/cold procedure, sample count and regression threshold before measurement.
3. Alternate baseline/candidate runs when possible; preserve raw data, failures and tool versions.
4. Report before/after, variance or distribution, uncertainty and workload-specific interpretation.
5. For Flow, use the existing benchmark scenarios: interleave OFF/ON at identical offered load and emergency policy. Record host/group PSI, input/switch/frame/launch latency where instrumentable, memory/swap/compression, CPU/I/O, background completed work, interventions, freezes/resumes and OOM/exit sources. Do not score success by free RAM or kill/pause work invisibly to improve a graph.
6. Exercise overrides, unavailable controllers and recovery; freeze tests require explicit eligibility and independent thaw. Bound stress to disposable targets, scratch storage, run duration and abort/recovery route outside affected cgroups. No host stress, cache dropping, broad unit changes or silent app killing.
7. Separate targets from measured results; mark unavailable measurements NOT YET MEASURED. Benchmark Flow's own CPU/PSS/wakeups and collection cost; reject starvation or lost work regardless of latency gains.

## Validation

Another operator can reproduce commands and interpret variation; battery claims require physical hardware evidence.

## Failure handling

Mark noisy or incomparable results inconclusive and identify confounders; do not cherry-pick or invent improvements. Abort safely on unexpected pressure, lost input or unauthorized targets; retain failed/OOM runs, thaw only test-owned matching groups and restore owned runtime settings. Lack of recovery invalidates the candidate.

## Project references

- [engineering/BENCHMARKS.md](../../../docs/engineering/BENCHMARKS.md)
- [system/PERFORMANCE.md](../../../docs/system/PERFORMANCE.md)
- [system/FLOW.md](../../../docs/system/FLOW.md)
