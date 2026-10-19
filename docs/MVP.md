# MVP scope

V1 means the first serious prototype, not a general availability release. It proves safe AI integration inside a bootable cohesive desktop. No V1 result is yet implemented or measured.

| Priority | Deliverables |
| --- | --- |
| MUST | Rebuildable Arch/archiso x86-64 UEFI environment; Plasma 6 Wayland; original branding; accessible launcher/overlay path; Rust/D-Bus foundation; provider-neutral routing proven with one cloud adapter and Ollama; approximately 5–10 constrained capabilities; trusted permission UX; attributable audit history; Btrfs recovery proof; controlled performance baseline and candidate measurement; repeatable QEMU tests |
| SHOULD | Calamares disposable-disk installation and update/recovery pipeline; linux-lts fallback; offline help; cancellation; redacted exportable diagnostics; basic hardware smoke on a declared machine |
| LATER | Android pairing/files/notifications; workspace continuation; deterministic routines; structured opt-in activity memory; broader IDE/provider integrations; software-center enhancements |
| NOT NOW | Kernel/compositor/init/package-manager forks; universal phone ecosystem; tablet second display; voice-first UI; screenshot memory; dozens of providers/daemons; server/vector infrastructure; arbitrary AI sudo; universal undo; Windows/macOS replacement claims |

The release candidate gate additionally requires installer/update/security/license evidence even when a component is SHOULD for the early live prototype. A live ISO demo may precede installation support and must say so.

Select capabilities from [SYSTEM_AGENT_API](ai/SYSTEM_AGENT_API.md), not from an ever-growing wishlist. Prefer observe/open actions first; package/service mutation is disabled until authorization, auditing and failure behavior pass Phase 7. Rollback support is per-operation and never inferred from a snapshot alone.

Demo: boot a clean VM; open an app; inspect real telemetry; deny a sensitive action and prove no mutation; authorize a scoped action; inspect audit history; deliberately fail an eligible change and recover; compare measured baseline/candidate. Missing gate evidence means prototype incomplete.

## Flow within the existing performance proof

[Flow](system/FLOW.md) deepens the existing measurable-performance requirement, not a second full product MVP. No production automatic sleep, killer, container manager or always-on daemon is required for the first prototype.

| Priority | Exact initial resource scope |
| --- | --- |
| MUST | Logical systemd/cgroup app grouping with explicit unknowns; per-group CPU/memory/I/O visibility; PSI monitoring; recorded zram baseline; foreground/background evidence; bounded CPUWeight/IOWeight proof and manual Efficient/restore; isolated MemoryHigh/targeted-reclaim experiment; existing Control Center Performance page; paired Flow OFF/ON benchmarks including overhead and background progress |
| SHOULD | Shadow pressure-state machine; calibrated bounded foreground protection; manually consented freeze/thaw compatibility/recovery proof; version-tested systemd-oomd dry-run/integration proof; per-app preferences |
| LATER | Adaptive automatic sleeping, container auto-pause, learned preferences, advanced memory prediction, application checkpointing, broad GPU/network resource management |
| NOT NOW | Production thresholds without experiments; global RAM cleaner/cache dropping; arbitrary app killing; scheduler replacement; opaque ML/LLM resource control |

The reclaim experiment does not enable automatic reclaim on arbitrary apps. Missing/ineffective controls are visible and block that policy's promotion rather than trigger privileged fallback. Resource weights can use explicitly enrolled bounded same-user presets; disruptive operations retain [permission](security/PERMISSIONS.md) gates. Freeze/oomd proofs may use synthetic disposable workloads without claiming everyday-app compatibility. Sentinel integration is a future declared worker-budget contract, not a new requirement to implement Sentinel here.

Flow acceptance: under the same offered workload, demonstrate truthful attribution, explain/restore each intervention, compare pressure and foreground latency, report throughput/energy/overhead tradeoffs and preserve unsaved work. No minimum recovered-RAM claim. No Flow result has been measured.
