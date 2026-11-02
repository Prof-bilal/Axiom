# Testing contract

Status: Phase 0 reset. Axiom testing is layered and evidence-backed. Unit and
contract checks are useful, but a desktop milestone is incomplete until the
real image boots and the real session is exercised in disposable QEMU.

- **Unit:** parsers, state machines, design-token logic and service rules.
- **Integration:** session startup, application launch, focus/workspaces,
  shutdown, notifications, settings and permission failures.
- **Security:** identity binding, denial, stale/replayed authority, secret
  handling, path traversal, portal/Wayland consent and audit failure.
- **QEMU:** UEFI boot, graphical session, monitor/input discovery, compositor
  restart, shell restart, app launch, logout and clean shutdown with serial and
  journal artifacts.
- **Hardware later:** Intel, AMD, NVIDIA where practical, suspend/resume,
  multi-monitor, HiDPI, touchpad, Bluetooth, Wi-Fi, audio and USB.

Every test records the phase, input/image hash, guest resources, expected
result, timeout, logs and cleanup. No test fixture may mount a host home,
share real credentials or silently enable production network access. See the
[detailed engineering matrix](engineering/TESTING.md).

## Phase 3 entry points

| Test | Command | What it proves |
| --- | --- | --- |
| Shell parse | `QT_QPA_PLATFORM=offscreen qs -p shell` | QML loads without type/parse errors |
| Host smoke | `tests/phase3-smoke.sh` | shell starts in a disposable headless harness (Sway-based; predates ADR-016, needs `sway`, `quickshell`, `grim`) |
| QEMU session | `tests/qemu-session.sh <iso>` | boot → shell ready → launcher/terminal/workspace/control-centre screenshots → clean poweroff |
| QEMU desktop identity | `tests/phase3-desktop.py <iso> [outdir] --res WxH [--short]` | real keyboard *and* pointer input at a chosen resolution: penguin menu + search, terminal greeting, cascade, dock launch, maximize, workspace click, status/session menus, two-step shutdown through the UI, shell log free of QML errors, os-release, fonts |
| Repository | `python3 scripts/validate-repo.py` | docs/skills/links and Phase 1 artifacts |

`tests/qemu-session.sh` uses real input (`sendkey`), captures the guest
framebuffer via the QEMU monitor (`screendump`), and fails on unallowlisted
failed systemd units. It does not mount a host home or enable networking.

`tests/phase3-desktop.py` advertises the resolution through EDID
(`-device VGA,edid=on,xres=,yres=`) and drives a USB tablet through QMP
`input-send-event` (HMP `mouse_move` is relative and an absolute tablet
ignores it). Readiness is verified from inside the guest over the root serial
console (`qs ipc --any-display … show`): the session's own `AXIOM_SHELL_READY`
marker never reaches `/dev/ttyS0`, which the serial getty owns with mode 0600,
and `qs` ignores instances on another display without `--any-display`. Root is
logged out before the UI shutdown so logind sees a single session. Exit code 3
means the known firmware-stage stall; retry it.
