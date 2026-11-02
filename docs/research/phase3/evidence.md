# Phase 3 evidence log

Recorded 2026-11-01. This records what was actually observed, not what is
planned. Companion to [performance](performance.md).

## Build

| Item | Value |
| --- | --- |
| Builder | `scripts/build-phase3-iso.sh` (unprivileged, `unshare --map-auto --map-root-user`) |
| archiso | 91-1 |
| Guest kernel | 7.2.11-arch1-1 (from `linux`) |
| Declared packages | 162 (official core/extra only) |
| Installed packages | 661 (incl. dependencies) |
| ISO | `axiom-2026.10.29-x86_64.iso`, SHA-256 `722e09b56961486ff56f36ff0462acc39d2b0796d62a6bea2567fe587f3791ab` |
| Shell files staged | 28 (from `shell/`) |

## Guest run (QEMU/KVM)

| Item | Value |
| --- | --- |
| QEMU | 11.1.2, `-machine q35 -cpu host`, KVM |
| Firmware | OVMF (`edk2-ovmf`), UEFI |
| RAM / vCPU | 2048 MiB / 2 |
| Display | standard VGA (`-vga std`); `virtio-vga` is **not** available in this QEMU build |
| Network | `-nic none` (no networking, no host mounts) |
| Boot | UEFI → systemd → `getty@tty1` autologin `axiom` |

### Verified process tree

```
systemd (pid 1)
└─ getty@tty1 (autologin axiom)
   └─ axiom-session  (zsh login -> .zprofile)
      └─ dbus-run-session -- sway -c /etc/axiom/sway.conf   (pid 763)
         └─ /usr/local/bin/axiom-shell  (pid 861, supervisor)
            └─ quickshell -p /usr/local/share/axiom/shell   (pid 862)
```

Confirmed via the serial console: `loginctl` shows session 1 user `axiom` on
`seat0`/`tty1`; `axiom` is in groups `wheel,video,input,audio,rfkill,tty`;
`/dev/dri/card0` exists.

### Verified shell behavior (quickshell log + visible UI)

- Configuration loaded with no QML errors.
- `Quickshell.I3`: "Connected to IPC", "There are 1 workspaces", "There are 1
  monitors" → `WorkspaceService` works against the harness.
- `ToplevelManager`: real toplevel handles for `foot` and `firefox` with
  app-id/activation state → `WindowService` works.
- `NotificationServer`: "Registered notification server with dbus".
- `SystemTray`: StatusNotifierWatcher + StatusNotifierHost registered.
- PipeWire connected (default sink tracked), NetworkManager connected.
- Desktop entries discovered (firefox, foot, pcmanfm, mousepad, vim, …).
- IPC handler registered (`qs ipc call axiom …`).

Visible result (screenshot `research/phase3/screenshots/desktop-phase3-live.png`):
top panel (Axiom mark, workspace chip, center clock, right-side status and
power), bottom dock (terminal highlighted as running, plus editor and browser),
aurora wallpaper, and three tiled `foot` windows — driven by real input in a
live session.

## Defects found and fixed during bring-up

| Defect | Cause | Fix |
| --- | --- | --- |
| Unprivileged ISO build failed: `keyring is not writable` / `required key missing` | pacman uses the **host** `GPGDir` (it is not root-prefixed) which is root-owned and unwritable inside the build user namespace | Builder generates its own keyring from `archlinux-keyring` inputs and injects `GPGDir` into the staged `pacman.conf`; the chroot customization strips it so the guest keeps its packaged keyring |
| `Type NotificationCenter unavailable` / `Syntax error` | A QML component file had **two top-level objects** (toasts + centre) | Split into `NotificationToasts.qml` and `NotificationCenter.qml`; all shell QML now parses under `qmlformat` |
| Serial readiness markers never appeared | `axiom` was not in group `tty`, and `/dev/ttyS0` is `root:tty 0600` | Added `tty` to `axiom` |
| `-device virtio-vga` boot failed | Not a valid device in this QEMU build | Use `-vga std` |
| `Keys` attached to a window warning | `Keys` attached to `PanelWindow` (a window, not an `Item`) | Moved Escape handling to a focusable child `Item` |

## Still to record

- The automated headless acceptance run (`tests/qemu-session.sh`) with
  `screendump` evidence for launcher / terminal / workspace switch / control
  centre and a clean poweroff — pending because the host had only ~1.3 GB free
  RAM and one 2 GB guest was already running for interactive inspection.
  Timing for [performance](performance.md) comes from that run.

## Desktop identity run (2026-11-02)

Image: `axiom-2026.10.29-x86_64.iso` (SHA-256 `5e01a9ff9cb38dae776d913bc60fec3944c2dfdab17d5de23065350f3928eb7f`) built 2026-11-02 16:30 with the desktop
identity changes ([DESKTOP_DESIGN](../../DESKTOP_DESIGN.md)). Driver:
`tests/phase3-desktop.py <iso> iso/out-phase3/evidence/desktop --res 1920x1080`
(QEMU/KVM, UEFI, EDID 1920×1080, USB tablet via QMP, `-nic none`). Screenshots
retained under `iso/out-phase3/evidence/desktop/1920x1080/` (not committed).

| Check | Result |
| --- | --- |
| Shell ready (IPC target registered, verified as root over serial) | PASS |
| Empty desktop, penguin menu, menu search, terminal greeting (real guest values: `7.2.11-arch1-1`, zsh 5.9.2, Sway 1.12, foot 1.28.0) | PASS |
| Second terminal cascades +30 px; Files launched by a dock click; Super+M maximize | PASS |
| Workspace switch by clicking the panel; status menu with live NetworkManager state; launcher | PASS |
| Session menu opens; one click on Shut Down only arms it | PASS |
| Shell log free of QML errors; os-release reports Axiom Linux; Inter + JetBrains Mono installed | PASS |
| Confirmed shutdown through the session menu | **FAIL** — see open bug below |

Earlier runs in the same window verified Super+M back-toggle restoring the
Axiom floating size, and 1366×768 / 2560×1440 layouts in the headless rootfs
harness. A separate QEMU pass at those two resolutions is still to be run.

### Open bug: first panel click after a keyboard overlay is lost

With an application window focused, after any shell overlay that takes
exclusive keyboard focus (launcher, Axiom menu, status menu) is closed with
Escape, the **first** press on a panel button is not delivered to the shell;
hover still updates and the second press works. Reproduced deterministically
with a probe matrix (fresh desktop: works; app focused, no overlay: works;
overlay closed, no app: works; app focused + overlay closed: fails). Switching
panel triggers from `onClicked` to `onPressed` did not change it, so the press
itself is lost between Sway's layer-shell focus restore and Qt Wayland — not a
QML handler issue. In the run above this is why the confirming Shut Down click
never reached the menu. Next step: reproduce outside Axiom (minimal
Quickshell overlay + panel on Sway 1.12) to assign it to Sway or Qt Wayland.

### Test-harness findings

- `AXIOM_SHELL_READY` never reached the serial log in any retained run: the
  unprivileged session cannot write `/dev/ttyS0` (serial getty, mode 0600).
- `qs ipc`/`qs log` ignore instances on another Wayland display; serial-console
  calls need `--any-display` (fixed in both QEMU drivers).
- HMP `mouse_move` is relative and ignored by the absolute USB tablet; pointer
  input uses QMP `input-send-event`.
- Firmware-stage stalls (no output after the boot menu) recur under host load;
  the driver exits 3 and is retried.

## labwc desktop run (2026-11-02, ADR-016)

Image SHA-256 `e00bfcef471c14449efc807fc2e3b9137cf6bcf9b4ac633083cd6ac81c8350df` (labwc 0.20, new top bar, dock and terminal). Same driver
and resolution as above.

| Check | Result |
| --- | --- |
| Shell ready; empty desktop; terminal greeting with sixel logo and real guest values (`7.2.11-arch1-1`, zsh 5.9.2, foot 1.28.0, Axiom Dark) | PASS |
| labwc title bar (icon, title, minimize/maximize/close), cascade placement, Super+M maximize, Super+H minimize and restore from the dock | PASS |
| Files launched from the dock (Trash Can listed via GVfs); workspace switch by clicking the panel; status menu; Activities overview (3 window cards); search launcher | PASS |
| VS Code (`code-oss`) pinned in the dock | PASS |
| Shell log free of QML errors; os-release; fonts | PASS |
| Apps grid opened by clicking the dock's Axiom mark | **FAIL** — first-click bug |
| Session menu opened by clicking power; confirmed shutdown through the UI | **FAIL** — first-click bug |
| Axiom menu (Super+A) receives typing and Escape | **FAIL** — menu surface never gets keyboard focus |

The first-click bug reproduces on labwc exactly as on Sway, so it is not a
compositor defect: it lies in how the shell's overlay windows take and release
keyboard focus (Quickshell / Qt Wayland). The Axiom-menu keyboard failure is in
the same area (the launcher, a different surface type, does receive keys).
Both are the next shell fix.
