# Window controls behavior model

Status: IMPLEMENTATION/VALIDATION for the pinned guest; browser/Electron and
full accessibility/performance coverage remain open.

The control target is a single still-live native window identity selected before
the action. The shell never silently falls back to the currently focused window
after a target disappears.

| Action | Request | Verification | Failure shown |
| --- | --- | --- | --- |
| Close | `Toplevel.close()` | the canonical target no longer exists in the live model | `failed: target remains` or `unavailable` |
| Minimize | Move the canonical target to fixed `special:axiom-minimized` with `follow=false`; retain original numeric workspace in the action adapter | same target remains live and reports the private-workspace name/id | timeout/failed if the compositor rejects the move; unsupported if the target cannot be resolved |
| Restore | Move the target to its recorded numeric workspace | same target reports the recorded workspace and remains live | unsupported if no in-memory restore record exists; timeout/failed otherwise |
| Maximize | Fixed Hyprland window-targeted dispatcher with `mode="maximized"`, `action="set"` | same native target reports `maximized == true` | timeout/unsupported |
| Restore from maximized | Fixed Hyprland window-targeted dispatcher with `mode="maximized"`, `action="unset"` | same native target reports `maximized == false` | timeout/unsupported |
| Fullscreen (diagnostic) | Fixed Hyprland window-targeted dispatcher with `mode="fullscreen"`, `action="set/unset"` | same native target reports the requested fullscreen state | timeout/unsupported |

Actions are asynchronous. The UI shows pending state while the bounded
verification timer runs, then one of verified, failed, unavailable or
unsupported. Close is not a kill operation: it requests the client protocol
close and does not terminate a process directly.

Fullscreen and maximize remain distinct states. The pinned guest validated both
through the same target. A fullscreen client may not show the normal controls;
the action service must not assume that a control surface can remain visible
above a locked/fullscreen surface without a separate, tested layer policy.

The private-workspace mapping is intentionally in-memory for this first slice:
a shell restart loses the restore location, so persistence is a later Dock/
workspace feature rather than an undocumented guarantee here.
