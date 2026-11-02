# Session startup

## Goal

Define how Axiom goes from login to a running compositor + shell process tree,
with explicit ordering, environment and failure behavior.

## Projects Studied

COSMIC (`cosmic-session`, `cosmic-greeter`), Sway (`sway/main.c`,
`sway/server.c`), Wayfire (plugin/config loader), Hyprland (IPC/session sockets),
Quickshell (launch/process model).

## Important Source Files

- COSMIC: `cosmic-session/src/main.rs`, `cosmic-session/src/comp.rs`,
  `cosmic-session/src/systemd.rs`, `data/cosmic.desktop` (`Exec=start-cosmic`).
- Sway: `sway/main.c`, `sway/server.c` (`server_init`, `server_start`).
- Quickshell: `src/launch/command.cpp` (config resolution), `src/launch/launch.cpp`.

## Runtime Behavior

- **COSMIC:** `.desktop` runs `start-cosmic`, which imports the environment into
  the systemd user manager and `exec dbus-run-session -- cosmic-session`.
  `cosmic-session` owns a per-component `ProcessManager` with
  `max_restarts(usize::MAX)` and exponential backoff, spawns `cosmic-comp`
  (passing a socketpair as `COSMIC_SESSION_SOCK`), waits for the compositor to
  report `WAYLAND_DISPLAY`/`DISPLAY` over JSON, exports them via
  `systemctl --user set-environment`, then starts settings-daemon, notifications,
  panel, launcher, workspaces and background, each in a transient `.scope`.
  Panels force notifications (and vice-versa) to respawn via socketpair; the
  compositor's exit code decides session exit vs restart.
- **Sway:** `main()` is dual-mode (IPC client vs compositor). The compositor
  creates the display, backend, all Wayland globals, loads config, starts the
  backend, then runs the event loop; it may `exec` clients but is not a process
  supervisor. Outputs appear on backend `new_output`; a fallback headless output
  always exists. Session/seat come from logind.
- **Quickshell:** one process per (config path, ShellId) lock. `ShellRoot` is an
  optional QML root. Each shell surface is its own `QQuickWindow`.

## REA Findings

Shell process/parent/child relationships and the environment hand-off
(`COSMIC_SESSION_SOCK`, `WAYLAND_DISPLAY`) are visible statically in
`comp.rs`/`session.rs`; no runtime REA capture was required to establish them.
REA was not needed for sway (single process, no IPC hand-off beyond `SWAYSOCK`).

## IPC / Protocols

D-Bus session bus (`dbus-run-session`), systemd user manager environment,
per-component scopes, and (in COSMIC) a private socketpair for compositor↔session
hand-off. Sway exposes i3 IPC over `$XDG_RUNTIME_DIR/sway-ipc.<uid>.<pid>.sock`.

## Dependencies

logind/PAM session, a session D-Bus, systemd (user), the compositor, the shell
toolkit.

## Good Design Decisions

- A dedicated session bus and a documented readiness hand-off (COSMIC's
  `WAYLAND_DISPLAY` exchange) remove startup races.
- Supervising shell components with bounded restarts keeps the desktop alive
  after a component crash.
- Keeping the compositor a separate process from the session manager.

## Problems / Tradeoffs

- COSMIC's many processes need a manager; the failure model is more complex.
- Sway is *not* a session manager — something else must start and supervise the
  shell.
- A single monolithic shell process is simpler but means one crash takes every
  surface down.

## License Notes

COSMIC session/comp are GPL-3.0-only (reference only). Sway is MIT. Quickshell is
LGPL-3.0-only.

## What Axiom Should Reuse

- `.desktop` + session-bus + systemd user environment as the session substrate.
- Supervised component restarts with backoff.
- Explicit readiness signalling rather than fixed sleeps.

## What Axiom Should Reimplement

- The Axiom session command and the service adapter boundary (own code).

## What Axiom Should Avoid

- Copying COSMIC session code (GPL, and it is a full desktop session manager).
- Making the compositor harness a session manager or product dependency.

## Final Axiom Design

```text
agetty --autologin axiom (logind session)
  -> /etc/skel/.zprofile   (tty1, no display) exec axiom-session
  -> axiom-session         (sets XDG_*, software-render fallback)
       -> dbus-run-session -- sway -c /etc/axiom/sway.conf
            -> exec /usr/local/bin/axiom-shell   (sway exec)
                 -> quickshell -p /usr/local/share/axiom/shell
```

- **Order:** user session → environment → compositor → shell. The shell waits
  for the compositor's socket before connecting.
- **Environment:** `XDG_CURRENT_DESKTOP=Axiom`, `XDG_SESSION_TYPE=wayland`,
  `XDG_RUNTIME_DIR`, `WLR_RENDERER=pixman`, `LIBGL_ALWAYS_SOFTWARE=1`,
  `MOZ_ENABLE_WAYLAND=1`, `QT_QPA_PLATFORM=wayland`.
- **Failure behavior:** the shell is supervised by `axiom-shell`, which restarts
  it with backoff (5 s after 5 rapid failures). If the compositor exits, the
  session ends and returns to the login shell. A crash of the shell does **not**
  end the compositor or session.
- **Failure model honesty:** the Phase 3 shell is a *single* Quickshell process
  hosting every surface, so killing it restarts the entire shell rather than one
  widget. This is documented as a known limitation; splitting surfaces into
  supervised processes is future work.
