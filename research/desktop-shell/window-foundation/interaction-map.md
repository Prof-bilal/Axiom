# Foundation interaction map

This subphase has no visual surface. Consumers observe availability, windows,
active window, workspaces and monitors. Diagnostics return counts and state
flags by default; do not log users' window titles or app content.

Session starts → connect health transport → native models initialize → consumers
observe objects. Window opens → native model adds object → component appears in
consumers. Focus clears → activeWindow becomes null → no implicit target.
Window closes → object removed → target invalidated. Monitor disappears → native
workspace/monitor relationship changes → tolerate null. IPC disconnects → all
exposed arrays empty and activeWindow null → consumer announces unavailable.

Keyboard/pointer actions, shortcuts, focus traversal and visual window controls
are deferred to 3.2. This read-only stage must not steal focus or reserve space.
