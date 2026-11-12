# ADR 026: Installer privilege split (QML UI and root backend)

Status: Accepted for Phase 6 Phase 3 (QML installer). Implementation pending QEMU verification.

## Context
The graphical installer (QML, `docs/updatephase6.md` Phase 3) must not run as root (AGENTS.md:
"UI never runs as root"). Partitioning, pacstrap and archinstall need root. The existing installer
logic lives in `installer/axiom_install.py` and already validates the form (`validate_form`).

## Decision
Option 1: a root systemd service, `axiom-installd`, accepts a narrow JSON protocol over a Unix socket.
The QML UI runs as the live user and talks only to that socket.

- Socket: `/run/axiom/installd.sock`, owned by root, group `axiom-install`, mode 0660. Only members of
  `axiom-install` (the live user) can connect. Peer credentials (`SO_PEERCRED`) are checked on every
  connection.
- Operations (whitelist, nothing else):
  - `validate` (form fields; reuses `validate_form`)
  - `list_disks`
  - `start_install` (form and target disk; refused if an install is already running)
  - `status` (progress events from the existing `emit()` JSON lines)
  - `cancel` (only before partitioning starts)
- No shell passthrough. Every argument is validated by the same rules as the curses installer.
- The service logs operation names and results, never passwords.
- The curses installer stays as the fallback (`axiom-installer.service` unchanged until QML passes QEMU).

## Consequences
- Adds one small root service. Justified: it is the narrowest boundary that keeps the UI unprivileged.
- The `axiom-install` group must be created in the ISO and given to the live user only.
- A bug in the socket protocol is a privilege risk: add adversarial tests (malformed JSON, oversized
  messages, unknown operations, a non-member peer).

## Rollback
Disable `axiom-installd.service`; the curses installer runs as before.

Related: [[025-boot-ui]], `docs/updatephase6.md`.
