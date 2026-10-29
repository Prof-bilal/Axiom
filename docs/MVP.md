# MVP scope

The first serious Axiom prototype is a real, bootable graphical session—not a
polished AI desktop and not a browser simulation.

## Required sequence

1. Build a minimal Arch-based Axiom base with standard Linux plumbing.
2. Boot it reproducibly in QEMU to a Wayland graphical session.
3. Launch and manage real Linux applications with input, outputs, focus and
   basic workspaces.
4. Add the Phase 3 shell MVP and verify its real interaction flows.

AI, security enforcement, core apps beyond the terminal, hardware coverage,
installer, updates and distribution remain separate phase gates. The core
desktop must work without a network, model provider or cloud account. No
capability mutation is enabled before authorization, auditing and recovery
behavior pass its security phase.
