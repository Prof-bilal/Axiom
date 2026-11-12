# Installation design

Status: Phase 6 design ([ADR-020](../decisions/020-installable-system.md), [ADR-021](../decisions/021-installer-and-developer-hub.md)); implementation starts at milestone M1. Axiom
will own the target-disk plan, identity, update/recovery semantics and first-run
experience while reusing a proven Linux installer technology when its behavior
and license are verified. The removed upstream installer path is not a
requirement or preferred dependency.

The first hardware contract is x86-64 UEFI, GPT, a reviewed filesystem layout,
fresh disposable target media and a fallback kernel. Dual boot, legacy BIOS,
complex manual partitioning, Secure Boot/TPM claims and broad hardware support
remain unproven until separate experiments pass.

Before writes, show target identity/capacity, the complete destructive plan and
an explicit confirmation. Revalidate the target immediately before execution;
protect the running medium and unrelated mounts. Partition/user inputs are data,
not shell commands. Secrets must not appear in logs or generated defaults.

Test cancellation, wrong-target guard, low space, firmware mismatch, offline
requirements, user creation failure, interruption, reboot without media,
package consistency, fallback boot and snapshot/recovery limits on disposable
disks only. The developer stack checklist is recorded separately and is not
silently applied during installation.

## Implementation (Phase 6)

| Piece | Path | Notes |
| --- | --- | --- |
| Look and feel | `tui/axiom_tui.py`, `tui/fbdraw.py`, `tui/penguin_art.py`, `tui/penguin_image.bin` | shared by installer and login screen: big console font, Axiom palette, centred cards, penguin that fills with progress. |
| Backend | `installer/axiom_install.py` | stdlib; validates the form, builds archinstall `--config`/`--creds`, runs it with argv only, applies the Axiom overlay, writes the Hub profile, cleans up after failure. |
| UI | `installer/axiom-installer` | curses TUI; Welcome → locale/keyboard/timezone → disk (+LUKS) → account → git identity → Developer Hub → review (type `ERASE`) → install. Esc goes back; nothing is written before the review confirmation. |
| Mode switch | `axiom-installer.service`, UEFI entry `00-axiom-installer.conf` | kernel option `axiom.installer=1` replaces the live desktop autologin on tty1. |
| Login | `greeter/axiom-greeter`, greetd | no autologin on installed systems; password goes only to greetd/PAM. |
| Lock | `shell/src/session/LockScreen.qml`, `/etc/pam.d/axiom-lock` | `ext-session-lock-v1` + PAM; `qs ipc call axiom lock`. |
| Hub | `catalog/developer-hub.json`, `provision/axiom-provision` | profile selects ids; root-owned catalogue names packages/images. |

Target guard: only whole, non-removable, read-write disks with nothing mounted are
offered, and the same check re-runs immediately before writing. A failed or killed
run kills leftover processes under `/mnt`, unmounts it and closes LUKS so the
machine is retryable. Secrets: password hash and LUKS passphrase live in 0600 files
on `/run` for the duration of the run; the profile and logs never contain them
(tested). Evidence and the exact commands are in [TESTING](../TESTING.md).
