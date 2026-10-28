# 3.6 Control Center

Status: IMPLEMENTATION. The integrated shell exposes read-only
NetworkManager/BlueZ/PipeWire/UPower/power-profile health. Mutating controls
remain gated until each backend has a narrow authorization and denial test.

Research actual NetworkManager/BlueZ/PipeWire/brightness/power-profile/session backends; preserve existing Polkit authorization. Confirm requested and reported state separately. Microphone, Wi-Fi, Bluetooth, volume, brightness, theme when supported, DND and battery each need unavailable/failure UX and real guest tests. No new privileged generic service.

Before implementation, populate the eight evidence/behavior/architecture/interaction/reference/unknown/specification/validation records defined in the [research workflow](../README.md). Findings must name actual source revisions or runtime artifacts. The canonical phase gate remains in [PHASES](../../../docs/PHASES.md).
