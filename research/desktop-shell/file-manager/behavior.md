# File manager behavior

The specification separates a shell entry point from a mature file manager.
Opening a location delegates to the selected desktop entry; open/save dialogs
remain portal-owned. Observable states are loading, empty, populated, denied,
offline/removable-device unavailable and failed. A stale path or unplugged
volume must render an error and preserve the user's current location instead of
silently issuing a destructive operation.
