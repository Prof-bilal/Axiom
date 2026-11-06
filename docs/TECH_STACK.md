# Technology direction

These are replaceable directions, not claims of an implemented stack. Consult
[architecture](ARCHITECTURE.md), [research](RESEARCH.md) and
[decisions](DECISIONS.md) before substituting a component.

| Layer | Direction | Status / boundary |
| --- | --- | --- |
| Base | Arch x86-64 first; recorded package inputs | Phase 1 research; no release claim |
| Kernel/boot/init | Upstream Linux + linux-lts, systemd, reviewed bootloader technology | Phase 1; signed/recovery path later |
| Device/network/audio/graphics | udev, NetworkManager or justified alternative, BlueZ, PipeWire/WirePlumber, Mesa | Reuse upstream services; hardware evidence later |
| Display | Wayland protocols and client libraries | Phase 1 prerequisites |
| Compositor/session | Axiom-owned boundary; Phase 3 uses sway (MIT) as a temporary harness behind `WorkspaceService`/`WindowService` adapters | Phase 3 implemented; no Hyprland/KDE/GNOME product lock-in; Axiom compositor still future |
| Shell | Axiom Shell in Quickshell/QML 0.3.2 (LGPL-3.0-only, dynamically linked) | Phase 3 implemented; toolkit remains replaceable |
| Apps | Axiom Files, Settings, Terminal integration and Software | Phase 4 |
| Platform services | Rust where a daemon is justified, D-Bus first, SQLite/FTS5 local metadata | Phase 5; no generic RPC/server DB by default |
| Packages/image | pacman/PKGBUILD and a reviewed base-image builder | Phase 1/9; old upstream flow removed |
| Security | Polkit, portals, systemd sandboxing, Linux primitives and future Warden adapter | Phase 11; fail closed, no model authority |
| AI | Replaceable local/cloud providers, typed tools and context | Phase 12; core desktop works offline |
| Test/delivery | QEMU/KVM, serial/journal/display evidence, later hardware matrix | Every graphical milestone |

No custom kernel, libc, init, package manager, terminal emulator, server
database or permanent daemon is justified merely by ambition. A component earns
its place through a product-specific need, maintenance/licensing review,
security boundary, measured performance and rollback plan.
