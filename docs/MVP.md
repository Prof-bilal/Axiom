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
