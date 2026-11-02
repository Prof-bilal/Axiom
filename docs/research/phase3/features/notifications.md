# Notifications

## Goal

Freedesktop-compatible notifications with real delivery, actions, timeouts and
a definition of how untrusted content is rendered.

## Projects Studied

COSMIC (`cosmic-notifications`), Quickshell `NotificationServer`, the Desktop
Notifications Specification 1.2.

## Important Source Files

- COSMIC: `cosmic-notifications/src/subscriptions/notifications.rs` (registers
  `org.freedesktop.Notifications`, 5 retries; caps/server-info), `src/app.rs`
  (id allocation/replace, timeout sleep → expire, action invocation),
  `cosmic-notifications-util`.
- Quickshell: `src/services/notifications/server.cpp` (registers
  `org.freedesktop.Notifications`), `qml.hpp` (`NotificationServer` with
  `trackedNotifications`, `bodySupported`, `actionsSupported`,
  `imageSupported`, `keepOnReload`), `notification.hpp` (`Notification`: id,
  appName, appIcon, summary, body, urgency, actions, `expire()`/`dismiss()`,
  `expireTimeout`).

## Runtime Behavior

- A notification daemon owns the bus name `org.freedesktop.Notifications` and
  implements `GetCapabilities`, `Notify`, `CloseNotification`,
  `GetServerInformation`, emitting `NotificationClosed` and `ActionInvoked`.
- `Notify` carries `app_name`, `replaces_id`, `app_icon`, `summary`, `body`,
  `actions` (id/text pairs), `hints` (e.g. `urgency`, `category`, `image-data`)
  and `expire_timeout`. `replaces_id` updates an existing notification.
- **Quickshell surfaces `expireTimeout` but does not run the timer itself** —
  the shell must call `expire()`/`dismiss()`. COSMIC clamps timeouts by config
  and sleeps before expiring, keeping capped history (200).

## REA Findings

Not required; the D-Bus interface and timeout behavior are in source
(`server.cpp`, `notification.hpp`, COSMIC `app.rs`).

## IPC / Protocols

`org.freedesktop.Notifications` (D-Bus session bus): Notify / CloseNotification /
GetCapabilities / GetServerInformation; signals NotificationClosed,
ActionInvoked, NotificationReplied.

## Dependencies

A session D-Bus bus; the compositor for overlay surfaces; the shell toolkit's
notification server.

## Good Design Decisions

- Own the bus name and cap capabilities explicitly (don't advertise what you
  don't render).
- Separate "toast" (transient) from "history/centre" (persistent list).
- Actions are explicit user intent; never auto-invoke.

## Problems / Tradeoffs

- The daemon must not render markup/links it doesn't sanitize; untrusted bodies
  can embed markup or huge images.
- Reload persistence can duplicate notifications.

## License Notes

COSMIC notifications GPL-3.0-only (reference). Quickshell LGPL-3.0-only.

## What Axiom Should Reuse

- The freedesktop interface and the toast-vs-centre split.

## What Axiom Should Reimplement

- The presentation, timeout/expiry policy and history UI.

## What Axiom Should Avoid

- Copying COSMIC notification code.
- Rendering untrusted body markup/links as rich content.

## Final Axiom Design

- `NotificationService` owns a Quickshell `NotificationServer` (body/image/
  actions supported, markup and hyperlinks **not** advertised, `keepOnReload`).
  It exposes `tracked`, `dismiss()`, `invoke()`, `dismissAll()`.
- `src/notifications/NotificationCard.qml` renders plain text only
  (`textFormat: PlainText`), shows app icon/name, summary, body and action
  buttons, and runs a timer (max(5 s, expireTimeout)) for toasts.
- `src/notifications/NotificationCenter.qml` provides a transient toast stack
  (overlay layer, top-right, hidden when the centre is open) and the history
  centre (clear-all, per-item dismiss) opened by `$mod+n`.
