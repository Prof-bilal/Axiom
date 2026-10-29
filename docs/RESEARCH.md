# Research and experiment register

Last reset pass: 2026-10-29. “Verified” means the cited behavior was inspected;
it does not mean Axiom integration works. Historical Omarchy findings remain in
the archive and are not current architecture.

## Base system

Arch remains a practical research base because its kernel, package and Wayland
ecosystem fit the project, but rolling inputs require recorded package
databases, signed artifacts, clean rebuilds and recovery tests. Reuse systemd,
udev, NetworkManager (or a justified alternative), PipeWire/WirePlumber, Mesa,
BlueZ, libc, drivers and standard boot technology. Do not rebuild mature
infrastructure without a measured Axiom-specific requirement.

## Desktop technology decision

| Option | Evidence question | Current disposition |
| --- | --- | --- |
| Custom compositor using wlroots or a comparable low-level library | Can Axiom own focus, input, outputs, security and protocol compatibility with a maintainable test matrix? | Long-term candidate; Phase 2 research |
| Existing compositor as permanent foundation | Does it avoid product lock-in while meeting hardware/accessibility/security needs? | Rejected as the product architecture |
| Shell/session-first with a temporary compositor harness | Can real workflows be validated before compositor ownership, with a narrow migration adapter? | Selected for Phase 1/2 bring-up |

Required experiments: real QEMU boot, app launch/focus/workspaces, output and
input events, lock/logout, compositor and shell restart, mixed DPI, portal
denial, idle CPU/RAM and interaction latency. A browser prototype cannot answer
these questions.

## Security and platform

Use D-Bus and existing service authorization before adding a daemon. Models,
MCP, files and web content are untrusted. Typed capabilities bind caller,
target, scope, expiry and audit; future Warden adoption requires a Linux bypass
matrix and fail-closed evidence. Wayland/portal consent is never weakened for
automation. Btrfs/Snapper recovery is per-operation, not universal undo.

## Research backlog

1. Select a minimal base-image and package snapshot strategy.
2. Compare temporary Wayland compositor candidates and define the session
   adapter contract.
3. Design the Axiom compositor implementation boundary and migration evidence.
4. Measure QEMU graphical-session startup, idle cost and failure recovery.
5. Define hardware, installer, update and signed-boot experiments for later
   phases.

Each experiment records inputs, environment, expected result, failure evidence,
security/performance impact and a decision. No research label authorizes a
runtime dependency.
