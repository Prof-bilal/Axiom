# Phase 3 performance record

Status: **first measured run recorded 2026-11-03** (software-rendered KVM guest).
Nothing here is a performance claim until a run is recorded with its environment.

## What to measure (minimum)

| Metric | Method | Why |
| --- | --- | --- |
| Session start time | guest monotonic time from `AXIOM_SESSION_START` to `AXIOM_SHELL_READY` on the serial console | startup responsiveness |
| Shell process RSS | `ps -o rss= -C quickshell` in the guest after 30 s idle | idle memory of the shell |
| Idle CPU | `pidstat -p <quickshell> 1 10` (or `/proc/<pid>/stat` deltas) after the desktop settles | whether the shell burns CPU at rest |
| Compositor RSS/CPU | `sway` + `Xwayland` RSS, sway CPU idle | harness overhead (not a product claim) |
| Application launch latency | wall time from launcher activation to a mapped foreign-toplevel | perceived responsiveness |
| Workspace switch latency | time between `workspace N` and the `workspace` event | interaction smoothness |
| Notification latency | `notify-send` to a rendered card | responsiveness |

## Environment to record with every run

QEMU version, OVMF version, guest RAM/vCPU, virtual GPU model, renderer
(`WLR_RENDERER=pixman` software path in Phase 3), compositor and Quickshell
versions, ISO checksum, and whether KVM acceleration was enabled.

## Known architectural factors (analysis, not measurement)

- **Software rendering.** The Phase 3 session forces `WLR_RENDERER=pixman` and
  `LIBGL_ALWAYS_SOFTWARE=1` for virtual GPUs. This is correct for QEMU but means
  the numbers are a *software-rendering* baseline, not hardware desktop
  performance.
- **One process for every surface.** The shell is a single Quickshell process
  with one `QQuickWindow` per surface. Idle cost is therefore one QML scene
  graph tree; a crash costs every surface (see session-startup).
- **No animation work yet.** Motion is limited to short hover color fades
  (≤120 ms). This is deliberate: correctness before animation.
- **Service polling.** Status state is push-based through D-Bus/PipeWire
  services; the only timer is a 1 s clock update.

## Results

Driver: `tests/phase3-perf.py` (artifacts in `iso/out-phase3/evidence/perf/`,
not committed). Image SHA-256
`2a42a06b3ba53286bd99ef922400d46beaaf548b90e958b85e3377c3d4ecdbc7`. QEMU 11.1.2
with KVM, OVMF UEFI, 2 GiB RAM, 2 vCPU, VGA at 1920×1080, `WLR_RENDERER=pixman`
(software), labwc 0.20.2, Quickshell 0.3.2, Qt 6.12.0, kernel 7.2.11-arch1-1.
One run on a loaded developer host; treat figures as a baseline, not a claim.

| Metric | Result |
| --- | --- |
| QEMU start → login prompt | 67.5 s (includes firmware and a systemd job waiting for time sync) |
| QEMU start → shell IPC ready | 88.9 s |
| Guest-monotonic start of labwc / quickshell | 45.9 s / 57.8 s after kernel start |
| Quickshell RSS / PSS (idle ≥ 40 s) | 433 MB / 389 MB |
| labwc RSS / PSS | 72 MB / 39 MB |
| Whole guest memory used | 676 MB of 2048 MB |
| Idle CPU, 20 s window | quickshell 0.00 %, labwc 0.00 % of one core |
| `qs ipc` toggle round trip (5 runs) | 547, 382, 151, 89, 88 ms (cold start dominates; steady ~90 ms) |
| `notify-send` to the session notification server (3 runs) | 184, 20, 20 ms |

Caveats: `systemd-analyze` was not usable (boot job still waiting for time sync in
a no-network guest), so the timeline uses process start times. Latencies are
measured at the IPC/D-Bus call, not to a rendered frame. Quickshell's 433 MB
RSS is the largest single cost and is a candidate for later work; no
optimization claim is made.
