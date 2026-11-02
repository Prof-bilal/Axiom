# Runtime traces (Phase 3)

Protocol/D-Bus/process traces captured while validating the shell go here
(gitignored operational data; findings are summarised in the feature docs).

Planned/recorded captures:

- session process tree (agetty → axiom-session → sway → quickshell) inside the
  QEMU guest;
- `swaymsg -t get_workspaces` / `-t get_outputs` / `-t get_tree` snapshots;
- the i3 IPC socket path and the foreign-toplevel set the shell sees;
- `org.freedesktop.Notifications` ownership and a `notify-send` round trip;
- `org.kde.StatusNotifier*` host registration.

Where a capture is a host-side artifact it is produced by
`tests/phase3-smoke.sh`; guest-side captures come from `tests/qemu-session.sh`.
