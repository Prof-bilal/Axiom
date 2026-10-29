# Axiom implementation phases

Current phase: **Phase 0 — architecture reset (in progress, 2026-10-29)**.
The former Omarchy-derived Phase 2/3 sequence is superseded. Its build and
research evidence remains under [`archive/legacy/`](../archive/legacy/) and does
not advance these gates. Each phase requires retained evidence; code existing
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

Remove Omarchy as a product/runtime dependency; classify and archive the old
foundation; define the base-system, display, shell, apps, services, AI and
security boundaries; select an initial distribution/build strategy; evaluate
compositor options; and update canonical documentation. No desktop implementation
or AI feature advances during this phase.

**Exit:** active docs and scripts no longer require Omarchy; the repository has
one architecture, one ownership model and one recommended next task: build a
minimal bootable graphical session in QEMU.

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
