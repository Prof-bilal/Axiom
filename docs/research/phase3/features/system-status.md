# System status / tray

## Goal

The minimum functional status surface for Phase 3: audio, network and power
state, plus a StatusNotifierItem tray. Not a full settings application.

## Projects Studied

Quickshell (`Quickshell.Networking`, `Services.Pipewire`, `Services.UPower`,
`Services.SystemTray`), COSMIC status-area applets, the StatusNotifierItem /
DBusMenu specifications.

## Important Source Files

- Quickshell: `src/network/qml.hpp` (`Networking`: `devices`, `wifiEnabled`,
  connectivity), `src/services/pipewire/qml.hpp`
  (`Pipewire.defaultAudioSink`, `PwNodeAudio.volume/muted`),
  `src/services/upower/core.hpp` (`UPower.displayDevice`, `onBattery`) and
  `device.hpp` (`percentage`, `isLaptopBattery`),
  `src/services/status_notifier/{watcher,host}.cpp` (both roles).
- COSMIC: `cosmic-panel` status-area/system-menu applets
  (`container_config.rs` defaults).

## Runtime Behavior

- **Tray:** StatusNotifierItem hosts register with a `StatusNotifierWatcher`;
  the host exposes registered items. Quickshell implements **both** the watcher
  and the host, so it self-hosts when none exists. Left click activates,
  middle click secondary-activates, right click opens a DBusMenu.
- **Audio:** PipeWire default sink exposes `volume` (0–1) and `muted`; the shell
  can set them.
- **Network:** NetworkManager-backed devices and `wifiEnabled`; connectivity
  state reported honestly.
- **Power:** UPower `displayDevice.percentage` (0–1) and `onBattery`; a desktop
  with no battery reports `isLaptopBattery=false`.

## REA Findings

Not required; all state is exposed through well-defined D-Bus services that
Quickshell wraps.

## IPC / Protocols

`org.kde.StatusNotifierWatcher` + `org.kde.StatusNotifierItem` + DBusMenu;
PipeWire (native protocol via Quickshell); NetworkManager D-Bus; UPower D-Bus.

## Dependencies

NetworkManager, PipeWire + WirePlumber, UPower (optional), a session bus.

## Good Design Decisions

- Report unsupported/unknown state explicitly (no battery → AC, no audio →
  "Audio unavailable").
- Self-host the tray watcher so the shell works without a separate daemon.

## Problems / Tradeoffs

- Tray icon rendering across icon themes is inconsistent.
- Connectivity checks can be slow/uncertain; do not block the UI on them.

## License Notes

Quickshell LGPL-3.0-only. PipeWire MIT/LGPL-2.1. NetworkManager GPL-2.0.
UPower GPL-2.0. COSMIC applets GPL-3.0 (reference).

## What Axiom Should Reuse

- The freedesktop tray protocols and the underlying service D-Bus APIs.

## What Axiom Should Reimplement

- The status presentation and the control-center interactions.

## What Axiom Should Avoid

- Building full Settings here (Phase 5).
- Inventing values when a service is absent.

## Final Axiom Design

- `SystemService` wraps PipeWire/UPower/Networking with explicit
  `audioAvailable`/`hasBattery`/`wifiEnabled` and honest fallbacks.
- `src/panel/Tray.qml` renders `SystemTray.items` with
  activate/secondary-activate/menu.
- `src/panel/StatusIndicators.qml` shows audio, Wi-Fi and battery state.
- `src/status/ControlCenter.qml` provides a volume slider, a mute route and a
  Wi-Fi toggle. Full device settings remain Phase 5.
