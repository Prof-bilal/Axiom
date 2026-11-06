# ADR-019: System services boundary (Phase 5)

**Date:** 2026-11-04
**Status:** Accepted for Phase 5.

## Context

Phase 5 connects the shell and Settings to the real network, Bluetooth, audio,
display, power, keyboard, time and account state. UI must not run as root, every
privileged action needs an independent check, and every new daemon needs a
justification. Quickshell 0.3.2 already speaks to NetworkManager, BlueZ,
PipeWire, UPower/power-profiles-daemon and the Wayland idle protocol.

## Decision

| Area | Service (mature primitive) | Client path | Privileged action gate |
| --- | --- | --- | --- |
| Wi-Fi, wired | NetworkManager (+ wpa_supplicant) | `Quickshell.Networking` | polkit rule `51-axiom-system-settings.rules` |
| Bluetooth | BlueZ (`bluetooth.service`) | `Quickshell.Bluetooth` | BlueZ D-Bus policy (local session) |
| Audio | PipeWire / WirePlumber | `Quickshell.Services.Pipewire` | per-user daemon, no privilege |
| Power profile, battery | power-profiles-daemon, UPower | `Quickshell.Services.UPower` | polkit stock policy (active session) |
| Brightness | brightnessctl (logind `SetBrightness`) | argv process | logind |
| Displays | labwc via wlr-output-management | `wlr-randr` argv process | compositor protocol, own session |
| Idle screen off | compositor idle + output power | `IdleMonitor` + `wlr-randr` | own session |
| Time zone, NTP | systemd-timedated, systemd-timesyncd | `timedatectl` argv process | polkit rule (set-timezone, set-ntp) |
| Keyboard layout | xkeyboard-config + labwc | `~/.config/axiom/keyboard.env`, read by `axiom-session` | none (user file) |
| Accounts | system user database | `getent passwd` (read-only) | n/a; mutation is out of scope |

- **Network stack change:** the Phase 3 image enabled systemd-networkd + iwd,
  which Quickshell's Networking module cannot read (it supports NetworkManager
  only), so the shell's network indicator was unavailable. Phase 5 enables
  NetworkManager and no longer enables networkd/iwd. One network manager, not two.
- **No new Axiom daemon.** New system services are all upstream (bluez,
  power-profiles-daemon, upower); each is D-Bus-activated or a standard unit.
- **UI never builds shell strings.** Commands are argv arrays. Wi-Fi passwords go
  straight to the network service through the Quickshell API, are not put in argv
  or logs, and the input is cleared after use.
- **Truthful unsupported states.** Every page shows an explicit state when the
  service or hardware is missing (no adapter, no backlight, service not
  running). Controls are hidden or disabled, never faked.
- **Display changes are reversible.** A change is applied and then auto-reverted
  after 12 s unless the user confirms.
- **Users:** Phase 5 lists accounts only. Creating or removing accounts and
  changing passwords needs a privileged helper that authorizes caller, operation
  and target; that belongs to Phase 6. Passwords are not passed through argv.
- **Keyboard:** labwc reads `XKB_DEFAULT_LAYOUT` only at start, so a layout
  change applies at next login; the page says so.

## Consequences

- Rollback: revert the profile symlinks (re-enable networkd/iwd) and the polkit
  rule; Settings pages degrade to their "unavailable" states.
- Hardware behaviour (real radios, backlights, suspend) is Phase 8; Phase 5 is
  verified against QEMU with virtual devices and documents what is untested.
- Security: the polkit rule grants only the listed actions, only to the desktop
  user in a local active session.
