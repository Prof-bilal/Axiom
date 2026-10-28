# Architectural interpretation

Apple's internal architecture is UNKNOWN. Public support/HIG material describes
user interaction, not a Linux implementation or an internal Apple API contract.

Axiom ownership follows [ARCHITECTURE](../../../docs/ARCHITECTURE.md): compositor
window management in Hyprland; session UI/models in Quickshell; system state
through mature Linux services. No Cocoa/WindowServer emulation layer is proposed.
The [window foundation](../window-foundation/architecture.md) is the first actual
integration boundary. Asset reuse is limited to original Axiom/installed Linux
application resources with appropriate provenance.
