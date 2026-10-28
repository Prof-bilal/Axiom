#!/usr/bin/env python3
"""Static contract checks for the integrated Quickshell surface.

These checks deliberately complement, rather than replace, a real Hyprland
guest run. They catch accidental privilege/process dispatch and ensure the
surface remains backed by the pinned native models.
"""
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = (ROOT / "shell/axiom-shell.qml").read_text()


def require(fragment: str) -> None:
    if fragment not in SOURCE:
        raise SystemExit(f"missing shell contract fragment: {fragment}")


for fragment in (
    "import Quickshell.Hyprland",
    "import Quickshell.Services.Notifications",
    "import Quickshell.Services.Pipewire",
    "import Quickshell.Services.UPower",
    "DesktopEntries.applications.values",
    "ToplevelManager.toplevels.values",
    "Hyprland.workspaces.values",
    "target.activate()",
    "entry.execute()",
    "Pipewire.ready",
    "UPower.devices",
    "notifications.trackedNotifications",
):
    require(fragment)

for forbidden in ("sudo ", "pkexec", "Process {", "execDetached", "Qt.createQmlObject"):
    if forbidden in SOURCE:
        raise SystemExit(f"forbidden dispatch in integrated shell: {forbidden}")

print("Axiom shell contract: PASS (native models, session-scoped launch, no privileged dispatch)")
