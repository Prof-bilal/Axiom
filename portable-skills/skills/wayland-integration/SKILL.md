---
name: wayland-integration
description: "Integrate desktop automation using Wayland consent and scoped interfaces."
---

# wayland-integration

## When to use

Use for window, capture, input or desktop integration on the Hyprland/Quickshell session. Do not use for restoring unrestricted X11-style access.

## Required inputs

Required operation, target compositor/session, portal backend, Hyprland permission defaults and permission UX.

## Procedure

1. Map the operation to a native application API, XDG portal, Hyprland IPC/permission or accessibility interface; record unavailable support.
2. Identify caller identity, user gesture/consent, session lifetime and revocation for capture or remote input; do not change Hyprland's ASK defaults to make a feature pass.
3. Keep compositor-specific functionality behind an explicit integration boundary with graceful unsupported responses.
4. Implement bounded streams and close session handles on logout, permission revocation and disconnect; treat the shell/lock process as trusted code with its own crash isolation.
5. Test denied consent, missing portal/backend, lock screen, multiple displays and changed scaling.

## Validation

Prove least scope and revocation in a real Hyprland/Quickshell guest; no X11 fallback that silently expands authority.

## Failure handling

Return an actionable unsupported or denied result; never disable compositor security to make the feature pass.

## Project references

- [desktop/WAYLAND.md](../../../docs/desktop/WAYLAND.md)
- [security/SECURITY.md](../../../docs/security/SECURITY.md)
- [migration report](../../../docs/engineering/OMARCHY_MIGRATION.md)
