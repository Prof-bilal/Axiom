# Window model architecture

PROPOSED: an Axiom QML `WindowState` component wraps native
`Quickshell.Hyprland` models. It is instantiated once in the shell and shared by
reference with controls, Dock and overview. No daemon, model call, process per
window or polling loop. Native Wayland handles provide live application/window
properties; native Hyprland objects provide workspace/monitor relationships.

The pinned QML API exports neither transport health nor request results. The
in-process CompositorHealth helper therefore drains a second event connection
without retaining titles/line buffers and makes a bounded read-only `j/status`
probe on connection, explicit revalidation and coalesced compositor activity.
There is no idle timer or process launch. Activity probes are limited to ten per
second, replies to 4096 characters and each probe to one second. Event loss or
failed request validation gates exposed models to empty/unavailable.

Callers receive a `validated(reachable)` signal from explicit `revalidate()`;
this reports IPC liveness, **not** action authorization, native model freshness,
mutation acknowledgement or target identity. A channel that disappears silently
while idle is discovered on the next activity/probe, not by a polling loop.
Request-path restoration can revalidate in place; a lost native event connection
requires restarting the Quickshell process, not merely reloading QML.

Quickshell exposes bare-hex window addresses while Hyprland JSON prefixes them
with `0x`. The adapter descriptor/windowByAddress boundary uses canonical
lowercase `0x` addresses, returns null for malformed/unknown targets, and keeps
native objects as the actual lifetime identity. An address alone is never a
future mutation authority because compositors may reuse it after destruction.

Runtime `hl.monitor()` changes do not necessarily emit configreloaded. Native
Wayland output geometry/DPI notifications trigger coalesced native monitor
refreshes. Refreshes only run after initialization, avoiding a race with the
upstream module's initial create-capable query. No monitor polling or duplicate
window registry is added.

All code runs as the logged-in user. No root operation, D-Bus broker, shell
command forwarding, input capture, screencopy or permission-default change.
The adapter is trusted shell code, not a future agent-authority API. Any later
model access requires the separate capability/security gates.
