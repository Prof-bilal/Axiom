# Axiom implementation phases

Current phase: **Phase 6 — installable system (complete, 2026-11-08; see [ADR-020](decisions/020-installable-system.md))**. Phases 0 to 6 are complete. Next: **Phase 7**.
Direction for phases 7 onward: [ADR-022](decisions/022-differentiation-direction.md) (usable core first, then the differentiators in phase D, with extension seams in every phase) and [ADR-023](decisions/023-ai-system-direction.md) (the AI system, accepted with defaults).
Phases 6 onward were re-ordered on 2026-11-06: a complete, installable core
distro (installer, packages, daily-driver, developer edition, hardware) comes
before the security and AI layers.
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
| 6 | Installable system | Installer, optional disk encryption, bootloader, user creation, first-run, login manager and lock screen; blank QEMU disk installs, reboots and keeps settings. |
| 7 | Package management and updates | Software Center installs, updates and removes packages through a narrow polkit-gated helper; snapshots roll back a bad update. |
| 8 | Daily-driver completeness | Printing, removable media, screenshots/recording, clipboard, idle lock, input methods/i18n, accessibility, default firewall and baseline hardening pass on the installed system. |
| 9 | Developer edition | Curated toolchains, git, containers, editors and optional security-tools sets; a clean install builds and runs sample projects. |
| 10 | Hardware and stability | Declared Intel/AMD/NVIDIA, power, suspend, multi-monitor, HiDPI, input, connectivity and audio matrix passes on the installed system. |
| D | Differentiators (after the usable line) | Profiles look layer, Launcher+ and typed actions, Zones, Capture, Axiom Projects, Connections, Creator profile. Each item has its own exit evidence. |
| 11 | Security layer | Capability permissions, filesystem/network scopes, secret protection, audit and Warden disposition are evidence-backed. |
| 12 | AI-native layer | Duet-style single agent and Team mode run user-built agents through typed, revocable grants; sessions preview; lessons only if their experiment passes. |
| 13 | Distribution | Signed updates, release repository, channels and recovery media pass disposable-target gates (signature rejection, interruption). |

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
76 checks on the rebuilt `axiom-2026.11.06-x86_64.iso`, including Wi-Fi join
with the right password and rejection of a wrong one, display scale with revert
and Keep, power profiles, and the idle screen-off that works on a real boot
after the `Repeater` to `Instantiator` fix in `IdleBlank.qml`. Security checks
show the desktop user cannot set the clock, change the hostname, add users or
stop system services. `tests/phase4-apps.py` (58 checks) and
`tests/phase3-desktop.py` (21 checks) also pass on the same image. Limits carried
forward: the VM has no backlight or Bluetooth controller, Wi-Fi is simulated, and
checks ran at 1920x1080 only. Real hardware is Phase 10.

## Phase 6 — installable system

Make Axiom installable, not just a live ISO: installer (archinstall or Calamares,
chosen by ADR), disk layout with optional LUKS, bootloader, user creation,
first-run, login manager and lock screen, and no autologin on installed systems.
Closes the Phase 4/5 reboot-persistence limit.

**Exit:** a blank QEMU disk installs, reboots, logs in and keeps Settings.

**Implementation (see [ADR-020](decisions/020-installable-system.md) and
[ADR-021](decisions/021-installer-and-developer-hub.md)):** a terminal installer
(`installer/`, started by `axiom-installer.service` when the kernel option
`axiom.installer=1` is set) drives archinstall; `greeter/` is the greetd login
screen; the shell's lock screen is `shell/src/session/LockScreen.qml`;
`provision/` plus `catalog/developer-hub.json` is the Developer Hub first-boot
job. Acceptance is `tests/phase6-install.py` (real key events in QEMU, evidence in
`iso/out-phase6/`) plus `tests/installer/` unit tests.

## Phase 7 — package management and updates

Make the Software Center writable through a narrow polkit-gated helper (caller,
operation and target authorized independently), mirrors, system updates, btrfs
snapshots with rollback, and a Flatpak decision recorded in an ADR.

**Exit:** install, update and remove a package from the UI; roll back after a
bad update.

## Phase 8 — daily-driver completeness

Printing, removable-media automount, screenshots and screen recording, clipboard
history, suspend and idle lock, input methods and i18n, accessibility, a default
firewall and baseline hardening (the full capability layer stays in Phase 11).

**Exit:** an everyday-task checklist passes on the installed system.

## Phase 9 — developer edition

Curated toolchains, git, containers, editors and terminal workflow, plus an
optional Kali-style security-tools package set. The Developer Hub shows Shikigami
as an optional external entry: its icon is visible, it is not installed by default,
and installing is the user's choice (the entry links to the vendor's download;
Axiom does not host, sandbox or audit it).

**Exit:** a clean install builds and runs sample projects in several languages.

## Phase 10 — hardware and stability

Test Intel, AMD and NVIDIA where practical; laptop power states, suspend/resume,
multi-monitor, HiDPI, touchpad, Bluetooth, Wi-Fi, audio and USB devices. Record
supported, unsupported and untested states instead of broad claims.

## Phase D — differentiators (after the usable line)

Starts after Phase 10. Steps are ordered and each has its own exit criteria and
QEMU evidence when it starts:

- **D1 Profiles, look layer:** colors and fonts come from the active profile
  tokens; three built-in looks; one-click undo through the kept previous file.
  Default Axiom look stays pixel-identical (regression check). Profiles are data,
  never code.
- **D2 Launcher+ and typed `ActionService`:** one catalogue and validator shared
  by the Launcher, Automate and Phase 12. Acceptance criteria include the AI seams
  S10-S17 from ADR-023 (action metadata, actor identity, one audit format, a
  reserved `secretRef` type, one resource-scope vocabulary, cancellable jobs, a
  shared-artifact convention, an untrusted-content wrapper). No Vicinae
  embedding (GPL-3.0; unsandboxed Node extensions).
- **D3 Zones:** generated labwc regions through the ADR-016 adapter.
- **D4 Capture (full app):** annotate, OCR, record, and upload only on user click
  after a destination is shown. Redaction must destroy pixels. The recording
  indicator cannot be hidden. The basic capture service from Phase 8 is reused.
- **D5 Axiom Projects:** a Python CLI over plain files; every git call goes through
  one locked-down runner (a repository's `core.fsmonitor` executed code in testing);
  a 20-case adversarial corpus must pass; kill-by test of 15 of 20 working days.
- **D6 Connections:** SSH and SFTP sessions over `~/.ssh/config`, with strict field
  schemas and never writing `ProxyCommand` or `LocalCommand`. Key-based login only.
- **D7 Creator profile and bridge pipelines:** demo video (Capture, OpenScreen or
  Recordly with manual zoom, whisper.cpp captions) and launch kit (git-cliff plus a
  prompt template). AGPL and GPL tools are recommended, never bundled.

Seams S1-S9 from ADR-022 apply to every step.

**Exit:** each D step passes its own evidence gate; no step ships a claim listed
as unsupported in the Track 4 synthesis.

## Phase 11 — security layer

Define and enforce app permissions, agent filesystem scopes, network permissions,
secret protection, capability-based execution, sensitive-file protection and
audit logs. Evaluate Warden only against verified behavior; it never grants
intent or replaces Axiom policy.

Added by ADR-023 (accepted):
- **Broker:** a dedicated unprivileged-UID daemon that recomputes effective
  authority on every call (manifest request, user grant, parent ceiling, lane
  ceiling, system policy, taint narrowing, remaining budget). It has its own ADR
  and review before it exists.
- **Sandbox layering:** Warden plus Landlock, seccomp and cgroups v2 for agent
  workers, once Warden's bypass matrix passes. Warden's audit is post-hoc, so it
  is not treated as preventive.
- **Taint rule:** deterministic; once a session has seen untrusted content and
  private data, egress actions are SENSITIVE with a payload preview.
- **Grants:** SENSITIVE and CRITICAL grants are one-use; a kill switch bumps a
  policy generation.
- **Secret store:** needed before any upload token or saved SSH passphrase.
- **Compositor gating:** labwc lets unsandboxed clients capture and inject input.
  No security claims about agents on the labwc harness until the Axiom compositor
  exists.
- **Sessions:** Axiom Sessions run in an Axiom-owned sandbox (fake home, scrubbed
  environment, egress only through an allowlisting proxy, one tmux server per
  session, one clone per session). A session never receives a Wayland socket.

## Phase 12 — AI-native layer

Phase 12 is split by ADR-023:

- **12a (Duet, working name "Pair"):** one visible agent; agent files as
  `agent.json` beside a spec-valid `SKILL.md`; typed actions only; mandatory
  budgets; memory as plain files the user can read and delete; a built-in
  Research Team template; Axiom Sessions preview (Lane 1, developer sessions);
  the Shikigami entry stays external. Runtime is a module of `assistantd` plus
  systemd user units; no new daemon beyond the Phase 11 broker.
- **12b (Team):** several bounded background agents with typed handoffs,
  depth at most 2 and breadth at most 4, a budget pool, and an approvals inbox.
  Lessons are added only if their experiment passes: a teacher is chosen per task
  area by measured score (or pinned by the user), learners are cheaper hosted or
  local models, and a lesson is accepted only after the learner's own score
  improves. Routine promotion always needs user approval.
- **Later, separate ADRs:** community exchange, unattended write actions,
  third-party `SKILL.md` import, voice.

Core OS functionality remains independent of AI and network providers. Cloud
providers are optional; any lesson or task text sent to a hosted provider is
redacted and approved per task.

**Exit (12a):** a user builds a Duet agent, grants it a capability, runs it, reads
its audit trail, revokes the grant, and kills it, all in QEMU, with the model
unable to bypass the broker. **Exit (12b):** the same for a Team, plus the
lessons experiment result retained, whether it passed or not.

## Phase 13 — distribution

Signed update mechanism, release repository, channels and recovery media. Test
disposable disks, interruption, signature rejection and recovery before
publishing.

Security review, privacy, license provenance and measured performance apply to
every phase. No phase creates a reason to rewrite mature Linux infrastructure or
to make AI a control loop for boot, session or resource management.
