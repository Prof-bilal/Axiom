# Window controls interaction map

## Pointer

1. The user points at a control in the Axiom surface.
2. The surface captures the current canonical active-window address before
   requesting the operation.
3. The control enters pending state and sends exactly one typed operation.
4. The adapter verifies the target's resulting native state or disappearance.
5. The surface announces success/failure without moving focus to another app as
   a workaround.

If the target changed between pointer-down and request, the action is denied
with `target-changed`; it is never redirected to the newly active window.

## Keyboard and accessibility

The visible controls expose names and roles through Qt Quick accessibility and
use a predictable left-to-right tab order. Enter/Space activates the focused
control; Escape is reserved for cancelling a pending reversible request and
never pretends to undo a close already accepted by a client. Keyboard-only
completion is a validation requirement for the final surface; the first visible
surface remains non-exclusive so it cannot steal application focus.

## Failure and cancellation

Unavailable backend, invalid address, target disappearance, unsupported native
request and verification timeout are separate states. A pending request may
stop waiting at the deadline, but the adapter does not claim the compositor
reverted an action it may already have accepted. Close has no fabricated undo.
