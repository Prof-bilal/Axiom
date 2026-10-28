# 3.1 validation record

Status: **VALIDATION, not COMPLETE**, 2026-10-28. This is a real native observation
adapter, not the complete desktop shell or a verified action service.

## Results

| Check | Actual outcome |
| --- | --- |
| QML lint | PASS: `/usr/lib/qt6/bin/qmllint -I /usr/lib/qt6/qml shell/services/WindowState.qml shell/window-state-probe.qml` |
| Host read-only smoke | PASS: 2 windows / 1 workspace / 1 monitor matched independent `hyprctl` samples; initial activation resolved through Wayland |
| Missing session | PASS on host and guest: unavailable, all exposed counts zero, no active window |
| Guest native integration | PASS: fresh pinned fixture booted via UEFI/OVMF + KVM; model connected through actual Wayland/Hyprland |
| Same-app lifecycle/focus | PASS in guest: two real Foot windows produced 2 distinct addresses and 1 active window, then 1/1, then 0/0 after owned process cleanup |
| Monitor events | PASS in guest: actual headless output creation/removal changed the same model 1 → 2 → 1 |
| IPC disconnect | PASS in guest: test relays forwarded real compositor state, then closed only owned connections; exposed model changed from 1 workspace/1 monitor to unavailable with zero counts; Wayland/compositor stayed running |
| Workspace/mixed-scale placement | PASS in follow-up fixture: targeted workspace move/switch; monitor scale 1 → 1.5; populated monitor removal returned the window to scale 1 |
| Request-only loss/recovery | PASS in follow-up fixture: event connection stayed alive, failed explicit validation emptied exposed state, request restoration revalidated in place; fresh process initialized against unaffected compositor |
| Real lock/PAM unlock | PASS for read-only observation before/after unlock; actual secure lock independently confirmed by Hyprland; wrong input did not unlock; published credential succeeded through QMP keyboard/PAM |
| Existing repository checks | PASS: foundation validator, 14 concept checks including negative research-record/link cases, whitespace check |
| REA | PASS: MCP handshake/catalog (229 tools), server identity and bounded installed-directory inspection; no behavioral/decompilation claim |

Durable results: [host](results/host-smoke.json),
[guest lifecycle](results/guest-lifecycle.json),
[disconnect](results/guest-disconnect.json),
[workspace/monitor placement](results/guest-placement.json),
[request recovery](results/guest-request-recovery.json),
[lock/unlock](results/guest-lock.json),
[guest packages](results/guest-versions.txt),
[environment/source hashes](results/environment.json).
Guest: Quickshell 0.3.2.r7.g2b4501a-1, Hyprland 0.56.2-4, Qt 6.12.0;
QEMU 11.1.2, 4 GiB RAM, 2 vCPUs, standard VGA, restricted user networking and
localhost SSH. This is a software/emulated graphics path, not physical GPU proof.
Logind lists a tty-launched session, while the live Hyprland/Wayland sockets and
native client/model tests establish the actual graphical protocol integration.

Reproduction after setting the test guest's actual session environment:

```sh
AXIOM_TEST_VM=1 python3 tests/window-state-smoke.py --lifecycle --monitors
AXIOM_TEST_VM=1 python3 tests/window-state-placement.py
python3 tests/window-state-disconnect.py
python3 tests/window-state-disconnect.py --request-only
python3 scripts/verify-rea.py
```

`--lifecycle` and `--monitors` are opt-in disposable-guest operations, never
default host tests. Read-only smoke has no flags. Tests launch/clean only their
owned processes and headless output; default diagnostics create no surface,
reserve no space and grab no input. IPC relay tests add only temporary owned
runtime sockets and forward actual state; they do not synthesize window data.

Raw VM command, serial/QEMU logs, firmware variables and overlay are retained in
`iso/out/developer/run-jsxc3cbS/`. Image SHA256 is recorded in environment.json.
The owner-restored launcher was run as `--foundation` to bypass its absent
preparation helper; only network restriction was changed. Successful fixture
UEFI boot does not establish a rebuildable Axiom foundation or Phase 2 exit.
At the end of the run, ACPI powerdown did not stop this upstream fixture; the
owned VM was terminated through its QMP `quit` command and the launcher exited.
The overlay/logs were retained. This is cleanup evidence, not a clean guest
shutdown or power-menu acceptance result; the shutdown behavior remains open.

## Findings and limitations

Initial active detection needed the Wayland handle because upstream's IPC pointer
is empty before a focus event. Native minimize property writes timed out in the
pinned Foot/Hyprland fixture; controls therefore must implement a proven policy
rather than assume a Wayland request hides a window. The current 3.2 adapter's
private-workspace policy is recorded in the window-controls dossier.

Follow-up acceptance progress: workspace mappings, scale changes, populated
monitor removal, request-only failure/revalidation/reinitialization, actual
lock/PAM unlock and the complete lifecycle/placement/disconnect rerun are
exercised. The remaining 3.1 gate is the raw startup/PSS/CPU performance
collection plus final source-hash review before exit.
Relay disconnect proves transport loss handling,
not every independent internal Quickshell failure. UI/keyboard/accessibility,
normal/browser/Electron actions and fullscreen mutation are 3.2 acceptance;
they are not implied by the read-only tests. No screenshot is needed for this
surface-free model, and no visual comparison result is claimed.

## Subphase handoff

Research: public Apple window/Dock/HIG guidance; native Quickshell and Hyprland
source and installed metadata. REA investigation: bounded plugin-directory
inventory only. Decision: one shared native read-only QML model with explicit
unavailable state; no new daemon or authority surface.

Files: `shell/services/WindowState.qml`, `shell/window-state-probe.qml`,
`shell/README.md`, the window-state test scripts, REA verifier/setup/evidence,
the research dossiers and phase/UX/entry-point documentation. Original branding
and editor state were preserved. Window controls now have an implementation
slice and guest harness; Dock remains unstarted.

Next: finish the 3.1 performance/source-hash gate; expand 3.2 across the
application/accessibility matrix; then investigate/implement 3.3 Dock. No later
visible feature is advanced.
