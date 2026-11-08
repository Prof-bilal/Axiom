# Testing contract

Status: Phase 0 reset. Axiom testing is layered and evidence-backed. Unit and
contract checks are useful, but a desktop milestone is incomplete until the
real image boots and the real session is exercised in disposable QEMU.

- **Unit:** parsers, state machines, design-token logic and service rules.
- **Integration:** session startup, application launch, focus/workspaces,
  shutdown, notifications, settings and permission failures.
- **Security:** identity binding, denial, stale/replayed authority, secret
  handling, path traversal, portal/Wayland consent and audit failure.
- **QEMU:** UEFI boot, graphical session, monitor/input discovery, compositor
  restart, shell restart, app launch, logout and clean shutdown with serial and
  journal artifacts.
- **Hardware later:** Intel, AMD, NVIDIA where practical, suspend/resume,
  multi-monitor, HiDPI, touchpad, Bluetooth, Wi-Fi, audio and USB.

Every test records the phase, input/image hash, guest resources, expected
result, timeout, logs and cleanup. No test fixture may mount a host home,
share real credentials or silently enable production network access. See the
[detailed engineering matrix](engineering/TESTING.md).

## Phase 3 entry points

| Test | Command | What it proves |
| --- | --- | --- |
| Shell parse | `QT_QPA_PLATFORM=offscreen qs -p shell` | QML loads without type/parse errors |
| Host smoke | `tests/phase3-smoke.sh` | shell starts in a disposable headless harness (Sway-based; predates ADR-016, needs `sway`, `quickshell`, `grim`) |
| QEMU session | `tests/qemu-session.sh <iso>` | boot → shell ready → launcher/terminal/workspace/control-centre screenshots → clean poweroff |
| QEMU desktop identity | `tests/phase3-desktop.py <iso> [outdir] --res WxH [--short]` | real keyboard *and* pointer input at a chosen resolution: penguin menu + search, terminal greeting, cascade, dock launch, maximize, workspace click, status/session menus, two-step shutdown through the UI, shell log free of QML errors, os-release, fonts |
| Repository | `python3 scripts/validate-repo.py` | docs/skills/links and Phase 1 artifacts |

`tests/qemu-session.sh` uses real input (`sendkey`), captures the guest
framebuffer via the QEMU monitor (`screendump`), and fails on unallowlisted
failed systemd units. It does not mount a host home or enable networking.

`tests/phase3-desktop.py` advertises the resolution through EDID
(`-device VGA,edid=on,xres=,yres=`) and drives a USB tablet through QMP
`input-send-event` (HMP `mouse_move` is relative and an absolute tablet
ignores it). Readiness is verified from inside the guest over the root serial
console (`qs ipc --any-display … show`): the session's own `AXIOM_SHELL_READY`
marker never reaches `/dev/ttyS0`, which the serial getty owns with mode 0600,
and `qs` ignores instances on another display without `--any-display`. Root is
logged out before the UI shutdown. The image also carries a polkit rule
(`/etc/polkit-1/rules.d/50-axiom-session-power.rules`) that lets the active
desktop session power off while other sessions (such as the serial console)
exist; without it logind demands administrator authorization. Exit code 3
means the known firmware-stage stall; retry it.

## Phase 4 entry points

| Test | Command | What it proves |
| --- | --- | --- |
| Pure logic (host) | `node --test tests/apps/*.test.mjs` | Files, Software and Settings parsing, sorting, naming and formatting, including hostile file names; no guest needed |
| QEMU apps | `tests/phase4-apps.py <iso> [outdir] [--res WxH] [--only files,software,...]` | the real apps in a guest: file operations verified on disk, trash and restore, name clashes, hostile names, 10,000 entries, package list equals `pacman -Q`, rendered notification, shell restart, per-app memory |

`tests/qemu_lib.py` is the shared guest-control library (paced serial writes, QMP
pointer input, screendumps, a root shell and a session-environment user shell).
Results are checked on disk or in process state over the serial console;
screenshots are retained as evidence and are never the pass/fail signal. Exit
code 3 is the same firmware-stage stall as above.

## Phase 6 installer tests

- `python3 -m unittest discover -s tests/installer -v`: backend validation, disk
  guard, archinstall config, secret handling and the first-boot job (no root, no QEMU).
- `tests/phase6-install.py ISO OUTDIR --stage install|installed|provision [--luks]`:
  boots the ISO in installer mode (`axiom.installer=1`) and drives the real TUI with
  key events, reading the screen back from `/dev/vcs1`. The `install` stage covers
  validation errors, cancel (disk stays blank), a killed install (retryable, nothing
  mounted) and a full install; `installed` boots the installed disk offline (greeter,
  wrong/right login, session, Settings persistence across reboot, lock screen,
  no-autologin, root locked, no secrets in logs, provisioning deferred); `provision`
  boots it with network (first-boot job converges and is idempotent, loopback only).
  The ISO is booted with `-kernel/-initrd` extracted from it so the installer option
  needs no boot-menu keystrokes; the installed disk keeps the install stage's OVMF
  variables (real NVRAM boot entry). Evidence: serial log, command transcript,
  `target-inspection.txt`, screenshots in `OUTDIR`.
- The installed boot gets a serial console only because the installer copies the
  live medium's `console=` options into the boot entries.

## Console UI experiments (Phase 6 redesign)

Run in QEMU on the live ISO with screenshots (`iso/out-phase6/ui/`): the Terminus console fonts
(`ter-v*`) draw only the full block and some shades (`▀ ▄` show as `#`); `latarcyrheb-sun32` has `▀ ▄ █`
and `░ ▒ ▓` and gives 100x28 cells at 1600x900 (120x33 at 1920x1080); palette redefinition through
`ESC ] P rrggbb` works on the fbcon in QEMU. `installer/axiom-installer --demo-progress` (with
`AXIOM_DEMO_PCT=35 AXIOM_DEMO_HOLD=6`) and `greeter/axiom-greeter --preview` draw the screens with
fake data for screenshots; neither writes anything. Unit tests: `tests/installer/test_tui.py`,
`test_greeter.py` (fake greetd on a unix socket) and the progress-tracker tests in `test_backend.py`.
