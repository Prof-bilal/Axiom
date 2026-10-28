# Window controls architecture

The feature has three layers:

1. `WindowState` owns the read-only native Hyprland/Wayland model and identity
   normalization. It exposes no mutation authority.
2. `WindowActions` owns one bounded action at a time. It resolves a canonical
   `0x...` address to a live native object, checks availability, performs only
   the selected native request and verifies the result against that same object.
3. `window-controls.qml` is a non-exclusive per-monitor layer-shell surface.
   It renders real active-window state, sends a user-selected operation and
   displays the resulting status. It does not parse sockets or build shell
   commands.

The shell remains a same-user process. No root helper, daemon or broad command
broker is added. Quickshell's native Wayland foreign-toplevel protocol remains
the read/identity path. The pinned guest showed that direct maximize/minimize
property writes are not uniformly honored, so the adapter uses fixed,
window-targeted Hyprland dispatch templates for maximize/fullscreen and a
fixed private-workspace move for minimize. The dispatch input is constructed
from the validated canonical address and fixed operation fields; callers cannot
submit arbitrary Hyprland text.

The action adapter uses a strict address grammar and native object identity;
window titles, app IDs and class strings are never interpolated into a command.
When the event/request backend is unavailable, the adapter denies the action and
returns an explicit unavailable result. A pending request times out rather than
remaining an unbounded state machine.

The layer surface uses existing Quickshell `PanelWindow`/Wayland primitives,
central Axiom tokens and the preserved penguin asset. It reserves no exclusive
zone and does not change Hyprland permissions. Lock-screen interaction is
outside this subphase's authority and is tested as a denial boundary.
