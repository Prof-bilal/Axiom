# ADR-024: Graphical greeter (Quickshell over greetd, labwc, curses fallback)

**Date:** 2026-11-10
**Status:** Accepted for Phase 6 polish. Supersedes the "curses greeter is a
stopgap" note in [ADR-021](021-installer-and-developer-hub.md) §1 and implements
the greeter row of [ADR-020](020-installable-system.md).
**Verified against:** Quickshell 0.3.2, greetd 0.10.x packaging on Arch,
labwc 0.8.x man page. End-to-end login is **not** verified yet (see
"Verification and limits").

## Context

ADR-020 chose greetd with an Axiom QML greeter on a labwc session, but Phase 6
shipped the curses screen in `greeter/axiom-greeter` as a stopgap (ADR-021).
That screen works and is safe, but it is a text login on a distribution whose
product promise is a coherent graphical desktop, and it cannot show the same
identity as the lock screen.

The greeter runs as the unprivileged `greeter` user, outside any logged-in
user session, and its only privileged interaction is the greetd IPC socket.
The installed system's `/etc/greetd/config.toml` is written by the installer
and points at `/usr/local/lib/axiom-greeter/axiom-greeter`; the installer is
outside this change's ownership, so the greetd command path must stay stable.

## Decision

### 1. A Quickshell greeter on the real greetd API

`greeter/qml/shell.qml` is a `ShellRoot` with one full-screen layer-shell
surface. It uses `Quickshell.Services.Greetd` exactly as exposed by 0.3.2
(checked in the installed `quickshell-service-greetd.qmltypes`, not from
memory):

- `Greetd.createSession(user)` starts PAM for the selected account;
- `authMessage(message, error, responseRequired, echoResponse)` asks for a
  response; the typed password is kept in a QML property only until
  `Greetd.respond(password)` answers the secret prompt, then cleared;
- `authFailure` clears the field and shows
  "That password didn't work. Try again." (or the plain lock-out message);
- `readyToLaunch` calls `Greetd.launch(["/usr/local/bin/axiom-session"], env)`
  with the same `SESSION_ENV` values the curses greeter used
  (`XDG_SESSION_TYPE=wayland`, `XDG_SESSION_DESKTOP=axiom`,
  `XDG_CURRENT_DESKTOP=Axiom`).

The look reuses the lock screen's palette and card proportions
(`shell/src/session/LockScreen.qml`, `shell/src/shared/Theme.qml`) with local
tokens, so the greeter does not import shell services that need a user session.

Accounts come from `human_users()`: UID 1000–59999 and a login shell that is
not `nologin`/`false`, the same filter as the curses greeter. `axiom-greeter`
writes the list as `{"name", "display"}` JSON, mode 0600, inside
`XDG_RUNTIME_DIR` (or a private `mkdtemp` directory), and passes the path in
`AXIOM_GREETER_USERS`. The QML never reads `/etc/shadow` or any password field
and never lists system accounts.

### 2. labwc is the greeter compositor

labwc is already in the installed package set (ADR-016, ADR-020) and `cage` is
not; adding a compositor just for the greeter would be a new dependency.
`greeter/axiom-greeter-graphical` starts:

```sh
exec labwc -C <greeter>/labwc -S "/usr/bin/qs -p <greeter>/qml"
```

`labwc -S/--session` runs the primary client and terminates the compositor when
that client exits (labwc(1)), which is the behaviour greetd needs: after
`Greetd.launch`, Quickshell exits, labwc exits, greetd starts the session.
`greeter/labwc/rc.xml` disables default keybinds and menus; the greeter is one
layer-shell surface, not a desktop.

Seat access does not need a new daemon or group change: greetd starts the
greeter as a PAM session with class `greeter` (greetd source,
`SessionClass::Greeter`), Arch's `greetd` package PAM file includes
`system-local-login` (so `pam_systemd` creates a logind session), and its
sysusers file already contains `m greeter video`. This was checked in the
packaging sources on 2026-11-10.

### 3. Stable greetd command, curses fallback

The greetd command stays `/usr/local/lib/axiom-greeter/axiom-greeter`. That
file is now a small dispatcher: it prepares the environment and account
snapshot, runs the graphical launcher, and starts the existing curses screen
(same file, same PAM/greetd code) unless the graphical greeter both exited 0
**and** wrote its readiness marker. labwc exits 0 whenever its primary client
exits, so the marker (written by the QML once it has loaded, path in
`AXIOM_GREETER_READY`, 0600 runtime directory) is what separates "Quickshell
ran" from "the QML never loaded". `SIGTERM` from greetd after a successful
launch is forwarded to labwc and is not treated as a failure. `--curses`,
`--preview` and `AXIOM_GREETER_TUI=1` force the text screen.

Keeping the path stable is deliberate: the installer writes the greetd config
and is not part of this change; changing the config would require editing
`installer/axiom_install.py`, which the handoff forbids. Operators can still
force the fallback without editing system files.

### 4. Rollback

- `AXIOM_GREETER_TUI=1` (or `--curses`) gives the old screen immediately.
- If labwc cannot start, the dispatcher falls back in the same boot.
- Reverting the change is dropping `greeter/qml`, `greeter/labwc`,
  `greeter/axiom-greeter-graphical` and the dispatcher block; the greetd
  config was never changed, and the curses code path is unchanged.

## Security

- The greeter stays unprivileged; it has no sudo, shell passthrough or root UI.
- The password moves from a `TextInput` to `Greetd.respond()` in memory and is
  cleared after the answer. It is never written to disk, logged, put in an
  environment variable or passed on a command line.
- The only file the greeter writes contains login and display names (public
  passwd data), mode 0600 in a directory owned by the greeter user.
- `AXIOM_GREETER_USERS` is a path, not account data; a user cannot inject an
  account into the list without already controlling the greeter user.
- The QML has no `console.log`; the graphical launcher's stderr only reports a
  missing runtime directory.
- PAM and faillock remain the authority. Wrong passwords show the same plain
  wording and never start a session.

## Compatibility

- Quickshell 0.3.2 (`Greetd`, `PanelWindow`, `FileView`, `Quickshell.env`) is
  the version installed in the ISO. The API is verified against the shipped
  qmltypes; a future Quickshell major needs the same check.
- greetd's IPC and PAM behaviour are unchanged; the fallback keeps working if
  greetd is older than the Quickshell service expects.
- Wayland/labwc were already used by the session; the greeter adds no new
  package.
- The QML uses Inter with fontconfig fallback, like the shell.

## Verification and limits

Verified locally:

- `pytest tests` (65 passed), including new tests for the account filter, the
  name-only snapshot (mode 0600), secret vs visible prompts, friendly PAM
  messages, "curses only when the graphical greeter does not start", and the
  readiness marker that separates a loaded QML from a clean compositor exit.
- `qmllint` parses `greeter/qml/shell.qml` with no syntax errors; its
  uncreatable-type/member warnings come from linting without the Quickshell
  runtime and match patterns already used by `shell/`.
- `python3 scripts/validate-repo.py` reports 0 errors.

Not verified (needs the owner's rebuild):

- A real login through greetd from the graphical screen in QEMU. This requires
  `sudo scripts/build-iso.sh` and then `tests/qemu-boot.sh` (or
  `tests/phase6-install.py ... --stage installed`), which the handoff reserves
  for the owner.
- Multi-monitor greeter layout: the surface is on the primary output only.
- Fingerprint/U2F prompts beyond plain PAM messages; the UI shows the message
  and accepts a typed response when PAM asks for one.

Known follow-up: `tests/phase6-install.py`'s installed stage still reads the
curses VT ("Welcome back", F10 hints) and will need a graphical-safe check
(screenshot plus QEMU key events) once the ISO is rebuilt. That file is outside
this change's ownership and was not edited.
