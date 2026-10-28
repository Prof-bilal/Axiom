# Axiom Shell

Phase 3 is being rebuilt in order. This directory contains the read-only window
foundation plus the first native window-controls implementation slice. Hyprland
owns windows; Quickshell owns native models and surfaces. No daemon or root
service is added. The original Axiom branding remains in `branding/`.

Run the surface-free diagnostic in a Hyprland user session:

```sh
qs -p shell/window-state-probe.qml
```

From another terminal in this checkout:

```sh
qs ipc -p shell/window-state-probe.qml call axiomWindowProbe summary
```

Stop the diagnostic with Ctrl-C. It does not install configuration, grab focus,
replace the running shell or operate existing windows. A missing/disconnected
backend exposes unavailable state. Restart after compositor replacement; the
pinned upstream IPC singleton has no public reconnect contract. `observing`
means event transport, request liveness and native monitors exist, not verified
mutation readiness. `revalidate()` emits `validated(reachable)` asynchronously;
it is a bounded read-only IPC check, never approval for an action. Silent request
failure while idle is detected on subsequent activity or explicit revalidation.

See [specification](../research/desktop-shell/window-foundation/axiom-spec.md)
and [validation](../research/desktop-shell/window-foundation/validation.md).

The current surface-free control probe is launched with:

```sh
qs -p shell/window-controls-probe.qml
qs ipc -p shell/window-controls-probe.qml call axiomWindowControlsProbe summary
```

The visible proof surface is launched with `qs -p shell/window-controls.qml`.
It is a non-exclusive, non-keyboard-interactive layer surface and operates only
on the currently active native target. Close, maximize/fullscreen and the
explicit private-workspace minimize policy all require same-target bounded
verification. The minimize restore location is in-memory for this slice and is
not promised across shell restart. Browser/Electron coverage, keyboard/pointer
focus isolation, accessibility, persistence and performance remain open.

The default read-only integration check is `python3 tests/window-state-smoke.py`.
Only in a disposable guest, opt into actual owned-window and monitor lifecycle
tests with `AXIOM_TEST_VM=1 python3 tests/window-state-smoke.py --lifecycle --monitors`.
`AXIOM_TEST_VM=1 python3 tests/window-state-placement.py` checks targeted workspace
and mixed-scale monitor movement. Both require an actual QEMU/KVM environment.
The separate
`python3 tests/window-state-disconnect.py` forwards the real IPC through temporary
owned relays and drops those connections to verify unavailable state; add
`--request-only` to test that channel while events remain connected.
