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
