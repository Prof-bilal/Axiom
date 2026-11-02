# Axiom roadmap

This roadmap is dependency ordered, not a delivery-date promise. The binding
gates are in [PHASES](PHASES.md); design and security contracts apply from
Phase 0.

| Milestone | Phase | User-visible result |
| --- | --- | --- |
| Architecture reset | 0 | Axiom owns the product boundary; the upstream-derived desktop is removed. |
| Bootable base | 1 | A minimal Linux image boots and reaches a real graphical target in QEMU. |
| Graphical session | 2 | Real Wayland applications launch, focus, move and switch workspaces. |
| Shell MVP | 3 | Axiom panel, dock, launcher, workspace UI, notifications and session controls work. |
| Core apps | 4 | Files, Settings, Terminal and Software are functional. |
| System experience | 5 | Device and session controls use real system services. |
| Security layer | 6 | Capabilities, scopes, audit and recovery boundaries are enforced. |
| AI-native layer | 7 | Optional agents and contextual workflows use typed, user-approved tools. |
| Hardware/stability | 8 | Declared hardware and power/connectivity matrix is measured. |
| Distribution | 9 | Installer, signed updates, recovery and release checks are usable. |

The immediate engineering target is **a bootable minimal Axiom graphical session
inside QEMU**, not a polished desktop rebuild. Axiom will reuse the kernel,
systemd, udev, networking, audio, Mesa, Wayland protocols, package manager and
drivers while owning its compositor/session boundary, shell, applications and
product services. Browser prototypes can support design discussion but never
stand in for the real session.
