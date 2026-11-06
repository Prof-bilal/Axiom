# Phase 5 evidence log

Records what was observed, not what was planned. Companion to
[PHASES](../../PHASES.md) and [ADR-019](../../decisions/019-system-services-boundary.md).

## Final acceptance run (2026-11-06)

On the rebuilt image `iso/out-phase3/axiom-2026.11.03-x86_64.iso` (built
2026-11-06 with `sudo scripts/build-phase3-iso.sh`):

| Run | Command | Result |
| --- | --- | --- |
| Phase 5 system | `tests/phase5-system.py <iso> iso/out-phase3/evidence/phase5-full --res 1920x1080` | **76 checks, 0 failures** |
| Phase 4 apps (regression) | `tests/phase4-apps.py <iso> iso/out-phase3/evidence/phase4 --res 1920x1080` | **58 checks, pass** |
| Phase 3 desktop (regression) | `tests/phase3-desktop.py <iso> iso/out-phase3/evidence/phase3 --res 1920x1080` | **21 checks, pass**, confirmed shutdown reached |

Run logs are kept in [logs/](logs/): `phase5-full.out`, `phase4-regression.out`,
`phase3-regression.out`. Screenshots are in [screenshots/](screenshots/). The
full screenshot set (41 PNG) and command transcript stay in
`iso/out-phase3/evidence/phase5-full/1920x1080/`, which is not committed.

Environment: QEMU with KVM, UEFI (OVMF), 1.5 GiB RAM for Phase 5 (`AXIOM_P5_MEM=1536`)
and 2 GiB for Phase 4, 2 vCPU, VGA with EDID, USB tablet, `-nic none` plus
simulated Wi-Fi (`mac80211_hwsim`) and a local access point, no host shares.
Software rendering. Boot stalls in firmware happened several times on this
7 GB host; each run was retried, and only the final passing run is counted.

## What was checked

Every result is checked on disk, in service state, or in process state over the
serial console. Screenshots are kept as evidence and are never the pass/fail signal.

| Area | Checks that passed |
| --- | --- |
| Image | NetworkManager, bluetooth and polkit enabled; systemd-networkd and iwd no longer enabled (one network manager); power-profiles-daemon answers on the bus; required tools installed |
| Mascots | app icons and shell mascots installed; Settings About loads the showcase mascot without QML errors |
| Network | two simulated Wi-Fi radios; access point runs; NetworkManager manages wlan0; a wrong password does not connect; the right password connects; the Wi-Fi password is not written to the app log or journal files; wlan0 gets an IPv4 address |
| Bluetooth | BlueZ enabled; with no controller bluetoothd is correctly not started and the page reports that |
| Sound | PipeWire sink exists; Mute and Unmute work; the slider changes the volume |
| Displays | outputs reported through wlr-randr; 2x scale applies; an unconfirmed change reverts automatically; Keep makes it stick |
| Power | Power saver and Balanced switch the real profile; 5 min idle setting saves; no backlight in the VM and the UI says so; **the screen turns off after the idle time**; input wakes the screen |
| Notifications | page loads without QML errors |
| Keyboard | layouts apply after a session restart; a malformed layout value is ignored and nothing runs |
| Date & time | timezone change applied by timedated; the shell session is authorised for the allowed actions; setting the clock itself is not granted |
| Users | current account exists in the user database |
| Security | the desktop user cannot set the clock, change the hostname, add a user or stop a system service; no account was created; no Axiom UI process runs as root |
| Recovery | the supervised shell restarts after being killed; Power page recovers after power-profiles-daemon restarts |
| Memory | measured PSS: shell 518 MB, Settings Network page 228 MB |

## Fixes made during this phase

- **Idle screen-off** (`shell/src/session/IdleBlank.qml`): the idle monitor was
  created inside a `Repeater` under a non-visual `Scope`, which never created
  its delegate, so the monitor never existed. Changed to `Instantiator`.
  Verified on a real boot: the output went off after the idle time and
  `DisplayService.setAllPower on=false` ran.
- **Phase 3 shutdown check** (`tests/phase3-desktop.py`): the uncommitted
  session-menu mascot moved the Shut Down row from y≈169 to y≈261. The test
  still clicked the old position, so the power-off step failed. Updated the
  coordinate. The earlier "did not power off without confirmation" pass was
  not valid because that click missed the button too.

Earlier bisect runs of the idle problem were not valid: the probe checked
before the idle time elapsed. They were replaced by the logging probes above.

## Known limits

- The VM has no backlight, so brightness is not testable and the UI shows that
  state instead of a fake slider.
- No Bluetooth controller in the VM; only the "no controller" state is verified.
- Wi-Fi uses simulated radios and a local access point, not real hardware.
- Displays were checked at 1920x1080 only.
- Real hardware (laptop sleep, suspend/resume, multi-monitor, real Wi-Fi and
  Bluetooth) is Phase 8 and is not claimed here.
