# Technology direction

These are selected directions, not a tested integration matrix. Consult [research](RESEARCH.md) and [ADRs](DECISIONS.md) before substitutions. Version and package manifests will be captured in Phase 1; do not interpret “current” as an unpinned reproducible build.

| Layer | Choice | Status / boundary |
| --- | --- | --- |
| Base | Arch Linux, x86-64 | V1; rolling updates require controlled inputs/full upgrade tests |
| Upstream foundation | Omarchy-derived Arch/Hyprland/Quickshell infrastructure (`omacom/omarchy` pinned release + `omarchy-iso`/`omarchy-pkgs`) | RESEARCH by [ADR-013](DECISIONS.md); Axiom owns shell, branding, security and system APIs ([migration](engineering/OMARCHY_MIGRATION.md)) |
| Kernel/boot/init | Upstream linux; linux-lts fallback; systemd; systemd-boot vs Omarchy Limine/UKI | RESEARCH; boot chain conflicts with ADR-002 and must be decided by experiment; Secure Boot/TPM need feasibility proof |
| Desktop | Hyprland compositor, Quickshell shell toolkit, Wayland, Qt 6/QML Axiom Shell | RESEARCH/V1; Plasma/KWin superseded by ADR-013; Axiom Shell is original work |
| Backend/IPC | Rust, D-Bus; justified Unix sockets | V1; freeze minimum supported toolchain when first crate exists |
| Storage | Btrfs, Snapper | V1; ESP, external effects and user data excluded from universal recovery |
| Packages/install | pacman, PKGBUILD; Omarchy-derived ISO/install/update flow; archiso/Calamares retained as legacy research | RESEARCH; installation follows disposable VM proof; pin the upstream package set |
| Applications | Optional Flatpak | V1-compatible; permissions reviewed, no Snap default |
| Audio/graphics | PipeWire, WirePlumber, Mesa | V1; GPU-specific claims require tests |
| Network/Bluetooth | NetworkManager, BlueZ | V1; reuse existing services, no replacement daemon |
| Metadata | SQLite and FTS5 | V1; per-user stores; privileged audit boundary separate |
| Vector search | sqlite-vec or compatible lightweight extension | RESEARCH; only if structured/FTS search fails measured use cases |
| Inference | Adapter interface considers OpenAI, Anthropic, Gemini, OpenRouter, Ollama | V1 proof: one cloud plus Ollama; others later conformance work |
| Tooling | MCP with explicit mediation | V1 optional integration; protocol is not authorization |
| Enforcement | Polkit, systemd hardening, Linux primitives, portals | V1 policy design; support/ABI probe on chosen kernel |
| Warden | Execution enforcement; policy derived from approved typed requests | First-party; real Linux backend is bubblewrap + setpriv `no_new_privs` + strace (no seccomp/Landlock, no typed API); RESEARCH until the bypass matrix and interface land |
| Agent orchestration | One parent `assistantd` + bounded, declarative child agents | V1 design; no runtime ([agent system](ai/AGENT_SYSTEM.md)) |
| Context engine (RepoSpine) | Budgeted code context for the Context child | RESEARCH; repo-scoped today; Node ≥22.13 |
| Context VCS (ContextGit) | Per-child runtime context branches | RESEARCH; Apache-2.0 Python core + CLI/API/MCP; Tauri app is the primary UI; non-repo session mode unmerged |
| Model evaluation (ModelCheck) | Model promotion gate before a default changes | RESEARCH; repo is `Prof-bilal/ModelChecker`; no LICENSE file yet (`cli/package.json` declares MIT) |
| Customization (Morphix) | Reversible desktop customization | RESEARCH; Plasma 6 only today; shell-agnostic/Hyprland adapter undecided; transaction engine unimplemented |
| Flow / performance | Rust, D-Bus, systemd user scopes/services/slices, cgroup v2 accounting/controls, PSI | V1 bounded telemetry/manual policy proof; no scheduler replacement or LLM control loop |
| Flow memory / power | zram baseline, existing power-profiles-daemon | V1 experiments, no chosen zram default; reuse the single performance-profile system |
| Flow optional controls | MemoryHigh/targeted reclaim; freezer / systemd FreezeUnit-ThawUnit; systemd-oomd | Isolated reclaim MUST experiment; freeze/oomd SHOULD proofs; probe version, permissions and recovery |
| Flow service | One proposed per-user flowd, replacing speculative performanced | RESEARCH until lifecycle need and measured overhead justify persistence |
| Future memory / observability | DAMON, MGLRU tuning, CRIU, eBPF | LATER/RESEARCH only; no custom kernel or mandatory privileged tracing in V1 |
| Test/delivery | QEMU/KVM, GitHub Actions | V1; KVM availability must be checked; hosted runner fallback is not equivalent performance evidence |
| Connectivity | KDE Connect, ADB/scrcpy, mDNS/Avahi, BLE, PipeWire, WebRTC, QUIC/TLS | LATER/RESEARCH; minimize transports and permissions |

No custom kernel, compositor, package manager, init, terminal emulator, server database or RPC framework in V1. Dependencies require maintenance, license, security and resource rationale. Avoid a permanent daemon when an existing upstream service, library or short-lived job solves the need.

Flow implementation and support constraints live in [FLOW.md](system/FLOW.md); [research](RESEARCH.md) records upstream versions and future-tech separation. GPU/VRAM and network shaping are not generic cgroup budgets assumed available in V1.
