---
name: performance-benchmark
description: "Measure performance changes with reproducible baselines and uncertainty."
---

# performance-benchmark

## When to use

Use for performance claims or tuning. Do not use for accepting subjective speed impressions.

## Required inputs

Hardware, kernel/build/configuration, workload, metric/tool, runs and predeclared threshold.

## Procedure

1. Record hardware, firmware, power/thermal conditions, background tasks and exact baseline/candidate revisions.
2. Define metric, units, warm/cold procedure, sample count and regression threshold before measurement.
3. Alternate baseline/candidate runs when possible; preserve raw data, failures and tool versions.
4. Report before/after, variance or distribution, uncertainty and workload-specific interpretation.
5. Separate targets from measured results; mark unavailable measurements NOT YET MEASURED.

## Validation

Another operator can reproduce commands and interpret variation; battery claims require physical hardware evidence.

## Failure handling

Mark noisy or incomparable results inconclusive and identify confounders; do not cherry-pick or invent improvements.

## Project references

- [engineering/BENCHMARKS.md](../../../docs/engineering/BENCHMARKS.md)
- [system/PERFORMANCE.md](../../../docs/system/PERFORMANCE.md)
