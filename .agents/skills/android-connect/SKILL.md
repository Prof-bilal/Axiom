---
name: android-connect
description: "Research and prototype scoped Android pairing and device integration."
---

# android-connect

## When to use

Use for Android discovery, transfer, notifications or media integration. Do not use for promising unsupported iOS parity or a full phone ecosystem.

## Required inputs

Android version/OEM, companion permissions, required feature, transport and pairing UX.

## Procedure

1. Compare KDE Connect reuse with a narrow companion implementation; verify platform/API limits per feature.
2. Design discovery as untrusted metadata; authenticate explicit pairing, encrypt transport and support key revocation.
3. Specify clipboard, notifications, file transfer, status and media as separate permissions with visible activity.
4. Require explicit USB/wireless ADB debugging trust for scrcpy prototypes; keep developer debugging outside normal pairing claims.
5. Test rogue discovery, impersonation, path traversal, disconnect, lock screen, lost-device revoke and network changes; assess webcam/screen APIs experimentally.

## Validation

Record tested device/OS matrix and evidence for supported features; mDNS/Bluetooth proximity alone never proves identity.

## Failure handling

Disable unsupported features clearly; do not bypass Android permissions or silently enable debugging.

## Project references

- [connect/ANDROID.md](../../../docs/connect/ANDROID.md)
- [connect/CONNECT.md](../../../docs/connect/CONNECT.md)
- [connect/CROSS_DEVICE.md](../../../docs/connect/CROSS_DEVICE.md)
