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

Initial proposed regression gate: >5% median regression when greater than measurement noise blocks promotion pending investigation. Security or correctness regressions block regardless of speed. Predeclare metric-specific absolute floors after baselines exist; this threshold is not evidence of any achieved target. Compare with the same pinned Axiom session/compositor baseline and isolate Axiom additions. VM results report guest/host contention and cannot establish GPU smoothness or battery performance.

Commands on a future installed test target include `systemd-analyze time`, `systemd-analyze critical-chain`, `cat /proc/pressure/memory`, `cat /proc/meminfo`; collect repeatedly with timestamps rather than treating one sample as a benchmark. Runtime traces and process metadata may contain private information; use synthetic workloads and redact artifacts.

Sources: [PSI](https://docs.kernel.org/accounting/psi.html), [Qt profiling guidance](https://doc.qt.io/qt-6/qtquick-performance.html). See [performance targets](../system/PERFORMANCE.md).

## Flow responsiveness experiments

Use this existing protocol, not a parallel benchmark system. [FLOW.md](../system/FLOW.md) owns policy/safety; [PERFORMANCE.md](../system/PERFORMANCE.md) owns targets. **All Flow OFF/ON results: NOT YET MEASURED.** Scenario names below specify workload families; a runnable fixture must pin versions, local browser pages/tab counts, dataset/model hashes, compile/test commands, duration, seed and offered load before execution.

| Scenario | Declared target and offered workload | Main comparison |
| --- | --- | --- |
| F1 | 4 GiB: browser + editor + terminal | Input/switch latency during bounded memory pressure; swap and stalls |
| F2 | 8 GiB: browser + VS Code + Discord + Docker + database | Mixed CPU/memory/I/O contention, service health and unsaved editor work |
| F3 | 8 GiB: F2 + AI coding agent | Same offered workload plus pinned synthetic agent fixture; agent/desktop progress and overhead |
| F4 | 16 GiB: developer workload + local model | Fixed model/quantization/context/concurrency; CPU/GPU/VRAM separately; foreground responsiveness during inference |
| F5 | Declared 8/16 GiB machines: Sentinel background soak + interactive desktop | Dedicated worker budget and declared test duration; desktop latency plus worker completion/errors, no hidden truncation |

Sentinel has no implementation in this checkout. F5 may first use a deterministic synthetic worker with the same declared resource envelope, explicitly labeled a stand-in; actual Sentinel integration remains unvalidated. Replace private/cloud-dependent content with local fixtures. If Discord or other proprietary apps cannot be redistributed, record operator-provided versions and repeat a redistributable substitute case; do not claim equivalence. Add separate zram tuning cases across **4/8/16/32 GiB** machines; the scenario suite does not imply every workload fits every RAM tier.

### OFF/ON comparison and controls

1. **OFF** disables only Flow adjustments; preserve kernel, Axiom session/compositor, inherited budgets, zram/swap, oomd policy, power profile and hardware inputs. “OFF” does not disable emergency protection. Record restored runtime properties and rebuild/reboot when persistent configuration changed.
2. **ON** uses the same fixture/input schedule, effective parent budgets and emergency policy. Record exact candidate settings, supported controllers, group map and consented interventions. Observe-only Flow is a useful separate overhead arm.
3. Randomize/interleave pairs using the existing run protocol. Script bounded typing/switching/launch interactions without unrestricted Wayland input injection: instrument a controlled Qt fixture, use an explicitly permitted test interface or external input hardware. State measurement boundary; dispatch time alone is not input-to-frame latency. Real app/compositor response needs validated presentation/trace or external video/hardware timing. Unsupported measurement remains unavailable, never inferred from CPU usage.
4. Match offered work and also report **completed useful work**. If pausing/throttling a job reduces processed data, show that tradeoff; no speed claim from silently killing work, reducing tab count, dropping requests or omitting timeouts. Do not compare different kernel reclaim/oomd policies as if Flow alone caused improvement.
5. Freeze, reclaim, zram, hard-cap and oomd tests are independent treatment arms before combining. A kill-policy experiment requires a separate label and expendable fixtures; it must not contaminate the soft-controls comparison.

### Required report columns

Extend the existing Hardware/Kernel/Build/Configuration/Metric/Tool/Runs/Baseline/Result/Variance/Threshold/Conclusion record with scenario, input seed, unit-to-app confidence, effective hierarchy, block scheduler, swap stack, power/thermal state, Flow policy/version/state transitions, interventions and completion/health criteria.

| Observation | Required treatment |
| --- | --- |
| Foreground input, app-switch, launch and first usable frame | Median/tail/distribution where supported; lost frames/input and hangs are failures, not dropped samples |
| UI frame responsiveness | Presentation/frame-time distribution and missed-frame bursts; measurement overhead recorded |
| Host + group CPU/memory/I/O PSI | Timestamped some/full averages where defined and cumulative stall deltas normalized by interval; time above predeclared experimental bands |
| Memory/swap/compression | Current/peak charge, anonymous/file categories where available, host available memory, swap-in/out and zram logical/physical use; do not double-count compressed data as free memory |
| CPU / I/O / workload progress | CPU time, throttle time, device bytes/latencies, completed compile/tests/requests/tokens and errors; fairness floor declared per workload |
| Freeze/reclaim effects | Exact target/eligibility, freeze completion, thaw-to-usable latency, actual reclaimed change, faults/stalls after return, graphics/network/build/state damage |
| Emergency behavior | oomd/kernel kill source evidence, group membership, victims, killed-app count, recovery time and user-visible notice; unknown sources explicit |
| Energy / heat / storage | Physical-device energy and temperature, compression cost and disk swap writes; no per-app battery assertion from CPU alone |
| Flow overhead | Idle and pressured PSS/CPU/wakeups, sample rate and event volume, audit cost and controller restart behavior |

Pressure bands, fairness floors, stop limits, cooldowns, thaw latency budgets and permitted outcome tradeoffs are chosen **for each experiment before its run**, then calibrated across workloads before any production default. The existing proposed >5% regression gate applies beyond noise; do not declare p95 improvement from insufficient samples. Record NOT YET MEASURED for missing results.

### Safety and cleanup

Stress only disposable VMs or explicitly designated physical test systems, with synthetic unsaved work, bounded scratch files, CPU/memory/I/O caps, duration and independent abort/recovery route outside controlled groups. No production Docker socket, host cgroup writes or unbounded storage test. Do not exhaust the host behind a small guest. Capture intervention/audit and failure logs before cleanup. Thaw only test-owned still-matching units and restore owned settings; use planned reboot when swap configuration changes require it. A missing recovery path blocks the experiment. VM functionality, laptop battery/GPU results and installed-app compatibility are separate claims.
