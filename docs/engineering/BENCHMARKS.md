# Reproducible benchmarks

Status: protocol only. All product performance is NOT YET MEASURED. Last researched: 2026-10-18.

Each result must record Hardware (CPU/GPU/RAM/storage/firmware), Kernel, Build commit and artifact hash, Configuration (power profile, display, services, filesystem, VM resources), Metric, Tool/version, Runs, Baseline, Result, Variance, Regression threshold and Conclusion. Include raw samples, exclusions and failed runs. Missing fields invalidate comparative claims.

Use an unchanged pinned baseline with matching package inputs; randomize/interleave before/after runs where possible. Fix AC/battery state, thermals, display brightness, network and background workload. Separate cold boot/cache from warm launches. Use at least 10 measured runs for latency/boot and 3 long battery runs; record warmup separately. Report median, p95 where sample size supports it, spread and uncertainty. Increase sample count when noise exceeds the threshold; do not discard inconvenient outliers without cause.

| Metric | Measurement boundary / tool candidate |
|---|---|
| Boot | Firmware→login and kernel/userspace separately; systemd-analyze plus external timing |
| Login interactive | Login acceptance→input-ready marked UI event; monotonic timestamps |
| Idle RAM/CPU | Five-minute stabilized interval; MemAvailable, per-process PSS, CPU time |
| Launcher/app latency | Input event→first usable frame; instrumentation/trace, cold and warm |
| Pressure responsiveness | Fixed memory/I/O load + bounded user interaction, PSI time series |
| Battery | Fixed workload and brightness; energy delta, duration and thermal state |
| Agent idle/execution | Incremental PSS, CPU, wakeups and capability latency, provider time separate |

Initial proposed regression gate: >5% median regression when greater than measurement noise blocks promotion pending investigation. Security or correctness regressions block regardless of speed. Predeclare metric-specific absolute floors after baselines exist; this threshold is not evidence of any achieved target. Compare with the same Plasma baseline and isolate Axiom additions. VM results report guest/host contention and cannot establish GPU smoothness or battery performance.

Commands on a future installed test target include `systemd-analyze time`, `systemd-analyze critical-chain`, `cat /proc/pressure/memory`, `cat /proc/meminfo`; collect repeatedly with timestamps rather than treating one sample as a benchmark. Runtime traces and process metadata may contain private information; use synthetic workloads and redact artifacts.

Sources: [PSI](https://docs.kernel.org/accounting/psi.html), [Qt profiling guidance](https://doc.qt.io/qt-6/qtquick-performance.html). See [performance targets](../system/PERFORMANCE.md).
