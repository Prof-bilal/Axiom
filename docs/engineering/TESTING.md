# Testing strategy

Status: Phase 0 reset; runtime implementation is not yet present. Tests are
organized around real contracts and failure behavior, not screenshots.

| Layer | Required evidence | Gate |
| --- | --- | --- |
| Unit | State machines, parsers, service rules, token logic | Implementer |
| Component | Cancellation, malformed input, persistence migration, restart | Implementer + QA |
| Session/integration | Login, app launch, focus/workspace, notifications, settings, logout/shutdown | QA |
| Security | Forged consent, unauthorized peer, secret leakage, path traversal, portal/Wayland denial | Independent security |
| QEMU | UEFI boot, real Wayland session, compositor/shell restart, input/output, app smoke, clean shutdown | Linux-base + QA |
| Hardware later | GPU, Wi-Fi, Bluetooth, audio, suspend, battery, multi-monitor, HiDPI, USB | QA |
| Update/recovery later | Signed update, interruption, rollback limits, boot assets and audit survival | Release + security |
| Performance | Idle CPU/RAM, frame/interaction latency, startup and evidence uncertainty | Performance |

Every test records phase, source/image hash, environment, expected result,
timeout, retained logs and cleanup. QEMU fixtures do not mount a host home,
share credentials/clipboard, pass through arbitrary USB or bridge into a
production LAN. Default egress is disabled except for explicit fixtures.

Graphical milestones are incomplete unless they run in the real guest. A
browser prototype may support design discussion but cannot satisfy a session or
shell gate. A failure gate blocks phase advancement; flaky behavior is recorded
with an owner rather than ignored.
