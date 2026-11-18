# ADR 032: Install verification, policy, sandbox and audit for the App Installer

Status: Proposed. Extends ADR-028 (.deb through distrobox). Implementation is in progress;
the UI and the wiring to the verifier are not yet done.

## Context
The App Installer installs AppImage, Flatpak, Arch packages and .deb. It does not check a
signature, has no policy step, runs AppImages without a sandbox, and keeps no record of what
was installed. The desktop UI should show these states from real results.

## Decision
1. **Signatures with minisign.** A file's detached `.minisig` is checked with
   `minisign -V -p <key> -m <file>`. Public keys ship read-only in `/usr/share/axiom/keys/`.
   Missing `.minisig` = unsigned. A `.minisig` that does not verify = failed.
2. **Policy.**
   - Failed signature: blocked.
   - Unsigned user-scope file: allowed only after an admin approval.
   - System-wide install (Arch packages, anything under `/usr`): always an admin approval.
   - Signed and verified user-scope file: installs in the user's account, no prompt.
   Admin approval is the existing polkit action `org.axiom.installer.install`
   (`/usr/local/bin/axiom-pkgd`). The UI never asks for a password itself.
3. **Sandbox for user installs: bubblewrap.** An AppImage is launched with `bwrap`: the system
   is mounted read-only, `/tmp` is a tmpfs, and no home directory is mounted, so the app
   cannot read `~/.ssh` or other user files. Network is shared by default. Warden
   (`/home/abullah/Projects/Warden`) is not used: it is a Node, pre-1.0 sandbox for AI agents.
4. **Audit record.** Each install appends one JSON line to
   `~/.local/state/axiom/install-audit.jsonl` with: id, time, file, sha256, signature state,
   policy decision, sandbox profile, target and result. The id is the audit ID shown in the UI.
   System installs are recorded by `axiom-pkgd`.
5. **Argv only.** Every external command (minisign, sha256sum, bwrap, pkgd) runs through
   `CommandRunner` as an argv array, never a shell string.

## Consequences
- An unsigned file now needs an admin approval, which is slower for developers testing their
  own builds. They can sign their builds with minisign.
- `minisign` must be added to the ISO package list; it is not installed on the current host.
- bubblewrap needs unprivileged user namespaces. Where they are off, the install falls back to
  "not sandboxed" and says so in the UI; it does not silently run without a sandbox.

## Verification
- Unit tests in `tests/apps/installfile-logic.test.mjs` for the signature state, policy,
  minisign and bwrap argv, and the audit line.
- Headless App Installer with a signed and an unsigned sample file; screenshots of each state.
- QEMU: an unsigned AppImage asks for admin; a signed one installs without a prompt; the
  audit line is written; a probe inside the sandbox cannot read `~/.ssh`.
