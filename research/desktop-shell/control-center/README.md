# 3.6 Control Center

Status: RESEARCH. Backends and authorization remain unimplemented; the
integrated shell intentionally exposes read-only service readiness only.

Research actual NetworkManager/BlueZ/PipeWire/brightness/power-profile/session backends; preserve existing Polkit authorization. Confirm requested and reported state separately. Microphone, Wi-Fi, Bluetooth, volume, brightness, theme when supported, DND and battery each need unavailable/failure UX and real guest tests. No new privileged generic service.

Before implementation, populate the eight evidence/behavior/architecture/interaction/reference/unknown/specification/validation records defined in the [research workflow](../README.md). Findings must name actual source revisions or runtime artifacts. The canonical phase gate remains in [PHASES](../../../docs/PHASES.md).
