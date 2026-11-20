# Handoff: graphical login (Phase 6 polish, Part B)

## Goal
Replace the curses login screen (`greeter/axiom-greeter`) with a graphical greetd greeter that
looks and behaves like the existing lock screen (`shell/src/session/LockScreen.qml`): Axiom
wordmark, user name, password field, error message. ADR-020 already chose a Quickshell QML
greeter on greetd. The curses greeter was a stopgap (ADR-021).

Part A (installer pick-lists) is separate and already done. Do not change the installer here.

## Hard rules (from AGENTS.md)
- The greeter runs as the unprivileged `greeter` user. No sudo, no shell passthrough, no root UI.
- Never store, log or echo the password. Only forward it to greetd.
- List only local human accounts (UID 1000-59999, login shell not nologin/false), as
  `axiom-greeter` does today.
- Keep the upstream pieces: greetd, PAM, systemd, Quickshell. No new Axiom daemon.
- No fake UI: the greeter must talk to real greetd. Screenshots alone do not count.

## Owned files (edit only these)
- `greeter/` (new QML greeter files, plus its launcher and config; keep `axiom-greeter` as the
  fallback, see below)
- `shell/src/session/` only if a shared component is needed for the greeter. Do not change
  LockScreen behaviour.
- `iso/` overlay/provision files that install the greeter and its config (only the greeter-related
  lines)
- `tests/installer/test_greeter.py` and any new greeter tests
- `docs/decisions/` one new ADR that supersedes the curses-greeter note in ADR-021

Do not touch `installer/`, `apps/`, or the other shell files. If you need one, stop and report.

## What to build
1. A Quickshell greeter (`greeter.qml`) using the greetd IPC from Quickshell. Verify the exact
   API against the installed Quickshell version. Do not assume it.
2. Flow: pick the user, type the password, submit. Create session, answer the PAM prompt,
   start `/usr/local/bin/axiom-session`. Keep the `SESSION_ENV` values from `axiom-greeter`
   (`XDG_SESSION_TYPE=wayland`, `XDG_SESSION_DESKTOP=axiom`, `XDG_CURRENT_DESKTOP=Axiom`).
3. Wrong password shows "That password didn't work. Try again." and clears the field.
4. Run it under a minimal Wayland compositor for the greeter user. Choose `labwc` (ADR-020)
   unless `cage` is already in the package set; say which you chose and why.
5. Fallback: if the graphical greeter can't start, greetd must still reach a usable login.
   Keep `axiom-greeter` (curses) as the fallback command in the greetd config.
6. Wire it into the ISO's greetd config and the greeter user's group/seat access, and keep the
   change minimal.
7. Write the ADR. It must record compatibility, security, rollback (curses fallback) and the
   measured or verified behaviour.

## Acceptance criteria
- Greeter code passes no privilege or password through logs or files.
- Only local human accounts are listed.
- Wrong password shows the error and does not start a session.
- Correct password reaches `axiom-session`.
- Curses fallback still works if the graphical greeter fails to start.

## Tests (must all pass before reporting done)
- `pytest tests` (not `python -m pytest` at the root; that scans `iso/work/` and fails).
- `python3 scripts/validate-repo.py`.
- Add unit tests for the account filter and the greetd message handling, using the existing
  style in `tests/installer/test_greeter.py`.
- The end-to-end check needs a rebuilt ISO and QEMU. Do not run it yourself. Report exactly what
  is needed: `sudo scripts/build-iso.sh` then `tests/qemu-boot.sh`. The user runs these.

## Report back with
- `git diff --stat` and the full diff of the owned files.
- The full output of the test commands.
- The ADR file path.
- What could not be verified (especially the QEMU login path), stated plainly.
Do not commit.
