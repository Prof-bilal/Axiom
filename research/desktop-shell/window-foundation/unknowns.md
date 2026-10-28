# Window foundation unknowns

| Unknown | Required proof |
| --- | --- |
| Hyprland minimize/restore semantics | Disposable native, terminal, browser and Electron windows; record workspace, visibility, restoration and fullscreen interactions |
| Native Wayland maximize requests honored | Source path established; compare requested vs reported state in 3.2 |
| Native minimize support | Source proves request is event-only; real minimize/restore needs an explicit compositor policy and runtime proof |
| Native IPC reconnect | Request-only loss/revalidation and fresh-process reinitialization passed. Native event connection replacement requires process restart, not QML reload |
| Cross-monitor identity/lifecycle | Workspace moves, populated virtual monitor removal and scale 1 → 1.5 → 1 passed. Physical monitor/GPU behavior remains unverified |
| App ID matching | Native, XWayland, Flatpak and Electron desktop entries; ambiguity remains explicit |
| Lock-screen boundary | Real guest lock/PAM unlock and read-only probes passed. Future shell surfaces/actions still need placement and lock-denial validation |
| Startup/idle overhead | Paired measurements in pinned guest; no performance claim from source architecture |
| Phase 2 exit | UEFI/rebuild/update/recovery and system smoke evidence still open |

No Mac is available. Apple implementation, exact timings and internal window
objects are unknown and unnecessary to specify Linux window ownership.
