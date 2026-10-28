# Window state behavior

PROPOSED: initial state is unavailable. A connected compositor plus populated
native monitor model enables observation. Window/workspace/monitor objects are
owned by Quickshell and removed by native model events; consumers must tolerate
null active window, missing Wayland handle and destruction during interaction.

Each window has compositor address, optional app ID, title, workspace and monitor.
Applications group multiple windows; neither title nor app ID is a window key.
Close is a client request, not force termination. Maximize and fullscreen remain
separate states. Hyprland has no general desktop-independent minimize contract;
observe native state and investigate compositor-specific minimize/restore before
enabling those actions. Moving a window out of view alone does not prove minimize.

On observed event loss or failed request validation hide cached state. Liveness
checks run on startup, activity and explicit revalidation; silent idle failures
are not continuously polled. Request restoration can be revalidated in place.
A new Quickshell process is required after native event-connection loss; a QML
reload does not reset its C++ singleton. Never silently select another session.
Liveness alone is not mutation readiness: later actions must separately validate
the target, lock state, authorization and actual outcome.
