# Window controls unknowns

| Unknown | Why it matters | Resolution experiment |
| --- | --- | --- |
| Does Hyprland 0.56.2 honor `Toplevel.minimized` requests for tiled and floating clients? | The foreign-toplevel API may expose a writable property while the compositor only emits an event or the client ignores it | RESOLVED for the pinned Foot fixture: direct writes timed out; V1 uses a verified private-workspace policy instead |
| Does a client remain in the model while minimized? | Close/disappearance verification must not confuse minimize with close | RESOLVED for the pinned Foot fixture: the target remained live on `special:axiom-minimized` and restored to its recorded workspace |
| How do browser/Electron clients respond to close/maximize/fullscreen? | Client protocol behavior and app policies vary | Add owned browser/Electron fixtures when available; otherwise mark NOT YET MEASURED |
| What is the correct maximize behavior for each Hyprland layout? | Hyprland's maximize-like fullscreen and layout-specific state differ | Test pinned default layout, floating, fullscreen and multiple monitors; do not generalize from one layout |
| Can a non-exclusive layer panel remain clickable without becoming the active toplevel? | If it steals focus, the active target changes before a click completes | PARTIALLY RESOLVED: the surface mapped with `keyboardInteractivity: No`, but pointer-click focus/target isolation still needs a repeatable interaction test |
| What should the UI do after a close request is accepted but the client remains open? | Close is not a guaranteed immediate disappearance | Keep pending until deadline, then report failed/unknown without killing the process |

No unknown is resolved by a rendered mockup or by a one-off `hyprctl`
success. Each resolution must retain the actual environment and target scope.
