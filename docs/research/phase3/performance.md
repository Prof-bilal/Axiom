# Phase 3 performance record

Status: **methodology defined; measurements pending the first QEMU session run.**
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

**Partial (2026-11-01).** A live QEMU/KVM session was observed to boot through
`getty@tty1` autologin → `axiom-session` → `sway` → `quickshell` and render the
full desktop (panel, dock, wallpaper, real application windows), with a single
stable `quickshell` process supervised by `axiom-shell`. See
[evidence](evidence.md) for the environment and checksum.

Numeric results are **not yet recorded**: the readiness markers were not captured
on that run (the serial socket only records after a client connects), so startup
time, idle RAM and idle CPU must come from the automated `-serial file:` run.
Prior `docs/engineering/BENCHMARKS.md` expectations do not apply to this shell.
