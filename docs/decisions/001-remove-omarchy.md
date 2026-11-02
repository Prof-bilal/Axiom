# Decision 001: remove Omarchy from the Axiom product architecture

**Date:** 2026-10-29
**Status:** Accepted; Phase 0 reset gate

## Decision

Axiom will no longer be built on Omarchy as its desktop or product foundation.
Omarchy, its ISO/package setup, shell/theme conventions, Hyprland/Quickshell
integration assumptions and user-facing commands are historical research only.
They have been removed from the repository and are not active build or runtime
dependencies.

Axiom will reuse mature Linux infrastructure—kernel, libc, systemd, udev,
drivers, networking, PipeWire, Mesa, Wayland protocols, package management and
boot technologies—while owning the compositor/session boundary, shell, core
apps, platform services, security UX and AI integration boundaries.

## Why

The previous implementation produced a themed/customized upstream desktop. It
made Axiom's identity, interaction model and release behavior downstream of a
different desktop project. That is the wrong long-term ownership boundary and
led to placeholder UI being mistaken for a real desktop implementation.

## Alternatives considered

1. Continue customizing Omarchy: fastest short-term demo, rejected because it
   keeps the product boundary upstream-owned.
2. Adopt a KDE/GNOME theme or extension pack: mature components, rejected
   because Axiom remains a theme rather than a desktop product.
3. Rewrite all Linux infrastructure: maximum control, rejected because kernel,
   drivers, init, networking, audio, graphics and package management provide no
   Axiom-specific product value.
4. Build Axiom's shell/session contract first with a temporary compositor
   harness, then assume compositor ownership: selected. It validates real
   workflows while preserving a clear migration boundary and QEMU evidence.

## Consequences

- The old Phase 2/3 evidence is historical; the roadmap restarts at Phase 0.
- The next implementation target is a minimal bootable graphical session in
  QEMU, not a polished shell or AI runtime.
- A compositor strategy must be measured and documented before it becomes a
  permanent dependency; a temporary harness cannot define Axiom UX.
- Original Axiom identity assets and desktop/security research are preserved;
  Omarchy-specific theme adapters, setup scripts and workflow skills are
  archived rather than silently reused.
- Installer, update, hardware, security enforcement and AI remain later gates.

## Rollback and review

Historical files can be inspected from the archive or Git history without
reactivating them. Reintroducing any upstream desktop component requires a new
component-scoped ADR that states its ownership boundary, license, upgrade path,
security/performance evidence and removal plan.
