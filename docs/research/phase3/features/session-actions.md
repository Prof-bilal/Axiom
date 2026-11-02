# Session actions (logout / reboot / shutdown)

## Goal

Real logout, reboot and shutdown through systemd/logind — no fake buttons, and
no privileged code in the UI.

## Projects Studied

COSMIC (`cosmic-session` service, `cosmic-greeter/src/logind.rs`), systemd-logind
D-Bus API and its polkit policy (verified on this host).

## Important Source Files

- COSMIC: `cosmic-session/src/service.rs` (`com.system76.CosmicSession.{Exit,
  Restart}`), `cosmic-greeter/src/logind.rs`
  (`power_off(false)`, `reboot(false)`, `suspend(false)`), `main.rs`
  (logind `HandlePowerKey` inhibit).
- Host policy: `/usr/share/polkit-1/actions/org.freedesktop.login1.policy`.

## Runtime Behavior

- logind exposes `org.freedesktop.login1.Manager` methods `PowerOff`,
  `Reboot`, `Suspend`, `TerminateSession`, each with a polkit action.
- **Verified defaults on this host:** `org.freedesktop.login1.power-off` and
  `org.freedesktop.login1.reboot` are `allow_active=yes`,
  `allow_inactive=auth_admin_keep`, `allow_any=auth_admin_keep`. So the *active
  local session user* can power off/reboot without an authentication agent; an
  inactive session cannot.
- COSMIC's greeter calls logind directly and relies on logind for authorization
  (no polkit code in-repo).

## REA Findings

Not required; the polkit policy file is authoritative and was read directly.

## IPC / Protocols

`org.freedesktop.login1` D-Bus (Manager.PowerOff/Reboot/Suspend/
TerminateSession) with polkit; `systemctl poweroff/reboot` and
`loginctl terminate-session` are the supported command-line front-ends.

## Dependencies

systemd + logind; polkit (installed so logind's authorization check runs).

## Good Design Decisions

- Keep privileged requests with the system service (logind), never in UI code.
- Route through polkit rather than granting sudo/passwordless power commands.
- Distinguish "logout" (end this session) from "reboot/shutdown".

## Problems / Tradeoffs

- Without polkit installed, logind may deny even the active user.
- `systemctl` front-ends add a small process hop compared with a direct D-Bus
  call; acceptable for Phase 3 (no direct D-Bus QML API in the toolkit).

## License Notes

COSMIC session/greeter GPL-3.0 (reference). systemd/polkit GPL/LGPL.

## What Axiom Should Reuse

- logind + polkit as the authorization path.

## What Axiom Should Reimplement

- The session menu and the `PowerService` boundary.

## What Axiom Should Avoid

- Running the shell as root or shipping a sudo rule for power commands.
- Fabricating a "powered off" state without the real request.

## Final Axiom Design

- `PowerService` (singleton) exposes `logout()`, `reboot()`, `powerOff()`,
  `suspend()`:
  - logout → `loginctl terminate-session $XDG_SESSION_ID` (falls back to
    terminating the user's session);
  - reboot/poweroff → `systemctl reboot` / `systemctl poweroff` (logind + polkit).
- `src/session/SessionMenu.qml` (on the shared `MenuSurface`/`MenuItem`, two-step confirmation) presents Log out / Reboot /
  Shut down; opened from the panel or `$mod+Shift+e`. The UI only calls the
  service.
- The live ISO installs `polkit` so the active-session `allow_active=yes`
  policy applies.
