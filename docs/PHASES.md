# Axiom implementation phases

Current phase: **Phase 5 — system experience (complete, 2026-11-06; Phase 6 is next and not yet authorized)**. Phases 0 to 5 are complete.
The architecture reset is complete; the previous upstream-derived desktop
direction has been removed. Each phase requires retained evidence; code existing
in a branch is not an exit criterion.

| Phase | Goal | Exit evidence |
| --- | --- | --- |
| 0 | Architecture reset | A developer can explain the owned Axiom layers, upstream boundaries, compositor strategy and QEMU acceptance path. |
| 1 | Bootable Axiom base | Minimal image boots in QEMU to login/session prerequisites with kernel, userspace, networking and graphics evidence. |
| 2 | Axiom graphical session | Wayland session, compositor foundation, input/output, window spawning and basic workspaces manage real Linux apps. |
| 3 | Axiom Shell MVP | Real panel, dock, launcher, workspaces, tray, notifications and session controls work in QEMU. |
| 4 | Axiom core apps | Files, Settings, Terminal integration and Software Center perform useful tasks. |
| 5 | System experience | Notifications, quick settings, Wi-Fi/Bluetooth/audio/display/power/user controls work through real services. |
| 6 | Security layer | Capability permissions, filesystem/network scopes, secret protection, audit and Warden disposition are evidence-backed. |
| 7 | AI-native layer | Optional agent runtime, contextual search and safe automation operate through typed permissions. |
| 8 | Hardware and stability | Declared Intel/AMD/NVIDIA, power, suspend, multi-monitor, HiDPI, input, connectivity and audio matrix passes. |
| 9 | Installer and distribution | Installer, ISO, first-run, signed updates, recovery, rollback and release channels pass disposable-target gates. |

## Phase 0 — architecture reset

Remove the upstream-derived desktop dependency; define the base-system, display,
shell, apps, services, AI and security boundaries; select an initial
distribution/build strategy; evaluate compositor options; and update canonical
documentation.

**Exit:** active docs and scripts no longer reference the removed foundation; the
repository has one architecture, one ownership model and one recommended next
task.

## Phase 1 — bootable Axiom base

Assemble the smallest x86-64 image using the Linux kernel, init/userspace,
filesystem, systemd, device management, networking, graphics stack, Wayland
prerequisites and QEMU tooling. Reuse mature drivers and services. No polished
desktop, installer or AI runtime.

**Exit:** Boot → system login/session prerequisites → basic graphical target in
QEMU, with reproducible inputs, serial/journal logs and clean shutdown.

## Phase 2 — Axiom graphical session

Implement the session contract, compositor foundation, application launch,
keyboard/mouse input, monitor detection, basic workspaces, focus and shutdown.
A temporary compositor harness is allowed only behind the documented adapter;
the Axiom compositor decision remains explicit and measured.

**Exit:** a graphical Axiom session launches and manages real Linux applications
in QEMU without browser mocks or fake window state.

## Phase 3 — Axiom Shell MVP

Implement only the desktop surface, top panel, dock, launcher, workspace
switcher, system tray, basic notifications, logout/reboot/shutdown UI and proper
window controls. Every surface consumes real session/service state, supports
keyboard and accessibility flows, and has failure/restart behavior. No fake
prototype icons, hardcoded state or screenshot-only components.

**Exit:** Boot → login → Axiom desktop → launch app → switch apps → open
launcher → use dock → logout/shutdown, all inside QEMU.

### Phase 3 implementation (2026-11-01)

Implemented in this window (see [shell/README](../shell/README.md),
[ADR-015](decisions/phase3-shell-architecture.md) and
[research](research/phase3/current-state.md)):

- **Session:** `iso/phase3/` builds a desktop image that autologins unprivileged
  user `axiom` on tty1, runs `axiom-session` → `dbus-run-session` → `labwc`
  (temporary harness) → `axiom-shell` → `quickshell -p …/shell`.
- **Shell surfaces:** top panel (workspaces, clock, tray, status, session
  route), dock (pinned + running, focus-or-launch), launcher (real XDG desktop
  entries), notification centre + toasts (`org.freedesktop.Notifications`),
  control centre (audio/Wi-Fi/power), session menu (logind/systemd).
- **Boundaries:** all system/compositor access goes through `shell/services/*`;
  UI performs no privileged operation.
- **Failure behavior:** `axiom-shell` supervises the single shell process and
  restarts it with backoff.

**Desktop identity (2026-11-01, revised 2026-11-02):** the compositor harness
moved from Sway to labwc ([ADR-016](decisions/016-labwc-compositor-harness.md))
for real window chrome; the top bar, dock and terminal follow the 2026-11-02
references. the shell, harness and terminal now share
one Axiom visual system — tokens, panel, penguin menu, dock, window rules,
Axiom Terminal and greeting — specified in [DESKTOP_DESIGN](DESKTOP_DESIGN.md)
and exercised in QEMU by `tests/phase3-desktop.py` at 1366×768, 1920×1080 and
2560×1440 (results in [evidence](research/phase3/evidence.md)).

**Completion (2026-11-03):** the exit path (boot → login → desktop → launch app →
switch apps → launcher → dock → logout/shutdown) passed in QEMU at 1920×1080
(full run, shutdown confirmed through the UI), 1366×768 and 2560×1440. The two
open defects were root-caused and fixed (overlay keyboard interactivity;
polkit authorization for session power actions). Evidence and measurements:
[evidence](research/phase3/evidence.md), [performance](research/phase3/performance.md).
Errata (2026-11-03): notification toasts and history never rendered during
Phase 3 (notifications were not tracked); fixed and verified during Phase 4,
see [Phase 4 evidence](research/phase4/evidence.md). Known limits carried
forward: logout and restart were not exercised in the
final runs (logout by UI is not yet covered by an automated check), and the
numbers are software-rendered KVM baselines.

Phase 1 (bootable base) and Phase 2 (graphical session) are demonstrated by the
same image reaching a Wayland session with real applications; their evidence is
folded into the Phase 3 QEMU run rather than recorded as separate milestones.

## Phase 4 — Axiom core apps

Implement functional Files, Settings, Terminal integration and Software Center
before advanced design. Keep package/update mutations behind later permission
gates and retain offline operation.

**Exit:** in QEMU, Files performs real file tasks (create, rename, copy, trash
and restore, open with the default app, open a terminal in a folder); the
Software Center lists, searches and describes real installed packages
offline and says plainly that repository data and package changes are not
available yet; Settings changes (wallpaper, dock pins,
default apps) persist and change the shell live; Terminal integration works
from the other apps; adversarial file names and failure paths are handled.

### Phase 4 implementation (started 2026-11-03)

Runtime decision: [ADR-017](decisions/017-core-app-runtime.md) (Quickshell/QML
apps, one process each, sharing the shell's config root; no new daemon).
Settings store: [ADR-018](decisions/018-axiom-settings-store.md) (proposed).

| Step | Work | Status |
| --- | --- | --- |
| 0 | Foundations: ADR-017/018, `apps/`, `axiom-app`, desktop entry, ISO staging | done |
| 1 | Terminal integration (`--cwd/--exec/--title`, OSC 7, finish notification) | done; also fixed notifications never rendering (Phase 3 gap) |
| 2 | Axiom Files: find/gio backend, trash and restore, hostile names, 10,000 entries | done |
| 3 | Software Center (read-only; no package mutation) | done |
| 4 | Settings (About, Appearance incl. text size, Dock, Default Apps, Displays read-only) | done |
| 5 | Shell integration: Files cutover from pcmanfm, Axiom menu rows, Trash, settings store | done |
| 6 | Verification: `tests/phase4-apps.py`, adversarial tests, measurements, evidence | done: 58 checks pass, Phase 3 regression passes |

**Completion (2026-11-03):** the exit evidence is in
[Phase 4 evidence](research/phase4/evidence.md): `tests/phase4-apps.py` passes
58 checks on `axiom-2026.11.03-x86_64.iso` (file operations verified on disk
with hostile names, Trash and restore, name clashes, 10,000 entries, package
list equal to `pacman -Q`, settings applied live by the shell, rendered
notification, shell restart, memory), and `tests/phase3-desktop.py` still
passes. Defects found on the way, including a Phase 3 notification gap and a
Trash bug on fresh accounts, are fixed and listed there. Limits carried forward:
the Software Center is read-only (needs the permission layer), reboot
persistence cannot be shown on the live image, logout/restart are not covered by
an automated check, and Phase 4 was run at 1920x1080 only.

## Phase 5 — system experience

Integrate notifications, quick settings, Bluetooth, Wi-Fi, audio, display,
power, user accounts, keyboard and appearance controls with the real Linux
services and truthful unsupported states.

**Completion (2026-11-06):** the exit evidence is in
[Phase 5 evidence](research/phase5/evidence.md): `tests/phase5-system.py` passes
76 checks on the rebuilt `axiom-2026.11.03-x86_64.iso`, including Wi-Fi join
with the right password and rejection of a wrong one, display scale with revert
and Keep, power profiles, and the idle screen-off that works on a real boot
after the `Repeater` to `Instantiator` fix in `IdleBlank.qml`. Security checks
show the desktop user cannot set the clock, change the hostname, add users or
stop system services. `tests/phase4-apps.py` (58 checks) and
`tests/phase3-desktop.py` (21 checks) also pass on the same image. Limits carried
forward: the VM has no backlight or Bluetooth controller, Wi-Fi is simulated, and
checks ran at 1920x1080 only. Real hardware is Phase 8.

## Phase 6 — security layer

Define and enforce app permissions, agent filesystem scopes, network permissions,
secret protection, capability-based execution, sensitive-file protection and
audit logs. Evaluate Warden only against verified behavior; it never grants
intent or replaces Axiom policy.

## Phase 7 — AI-native layer

Add the optional system agent, natural-language launcher, contextual search,
developer workflows, automation, project awareness and local/cloud adapters.
Core OS functionality remains independent of AI and network providers.

## Phase 8 — hardware and stability

Test Intel, AMD and NVIDIA where practical; laptop power states, suspend/resume,
multi-monitor, HiDPI, touchpad, Bluetooth, Wi-Fi, audio and USB devices. Record
supported, unsupported and untested states instead of broad claims.

## Phase 9 — installer and distribution

Only after Axiom is usable, build the installer, ISO, first-run experience,
signed update mechanism, recovery/rollback and release channels. Test disposable
disks, interruption, signature rejection and recovery before publishing.

Security review, privacy, license provenance and measured performance apply to
every phase. No phase creates a reason to rewrite mature Linux infrastructure or
to make AI a control loop for boot, session or resource management.
