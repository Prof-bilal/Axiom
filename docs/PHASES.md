# Axiom implementation phases

Current phase: **Phase 3 — Axiom Shell MVP (complete, 2026-11-03; next: Phase 4)**.
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
Known limits carried forward: logout and restart were not exercised in the
final runs (logout by UI is not yet covered by an automated check), and the
numbers are software-rendered KVM baselines.

Phase 1 (bootable base) and Phase 2 (graphical session) are demonstrated by the
same image reaching a Wayland session with real applications; their evidence is
folded into the Phase 3 QEMU run rather than recorded as separate milestones.

## Phase 4 — Axiom core apps

Implement functional Files, Settings, Terminal integration and Software Center
before advanced design. Keep package/update mutations behind later permission
gates and retain offline operation.

## Phase 5 — system experience

Integrate notifications, quick settings, Bluetooth, Wi-Fi, audio, display,
power, user accounts, keyboard and appearance controls with the real Linux
services and truthful unsupported states.

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
