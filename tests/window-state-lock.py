#!/usr/bin/env python3
"""Host-side, disposable fixture only: real lock/PAM input through owned QMP.

Reads the published fixture password from the checksum-verified vm-boot helper;
never prints or stores it. Does not modify PAM, credentials or lock permissions.
"""
import argparse
import json
from pathlib import Path
import re
import shlex
import socket
import subprocess
import time

ROOT = Path(__file__).resolve().parents[1]


def check(state):
    state = state.resolve()
    assert state.is_relative_to(ROOT / "iso/out/developer"), "Owned test state required"
    instances = json.loads(subprocess.check_output(
        [str(state / "ssh"), "-o", "BatchMode=yes", "hyprctl -j instances"], timeout=5))
    assert len(instances) == 1
    env = ["env", "LC_ALL=C.UTF-8", "XDG_RUNTIME_DIR=/run/user/1000",
           "WAYLAND_DISPLAY=" + instances[0]["wl_socket"],
           "HYPRLAND_INSTANCE_SIGNATURE=" + instances[0]["instance"],
           "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus", "OMARCHY_PATH=/usr/share/omarchy"]

    def guest(*command):
        return subprocess.check_output([str(state / "ssh"), "-o", "BatchMode=yes",
                                        shlex.join([*env, *command])], text=True, timeout=15)

    def status():
        return json.loads(guest("omarchy-shell", "lock", "status"))

    def compositor_locked():
        monitors = json.loads(guest("hyprctl", "-j", "monitors"))
        return any("LOCK" in m.get("solitaryBlockedBy", []) for m in monitors)

    password = re.search(r"Desktop and sudo password: ([^.]+)\.",
                         (ROOT / "workspace/upstream/omarchy-vm/vm-boot").read_text())[1]
    assert re.fullmatch("[a-z0-9]+", password), "Unexpected fixture password format"
    qmp_path = Path((state / "socket-dir").read_text().strip()) / "qmp.sock"
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as qmp:
        qmp.settimeout(5)
        qmp.connect(str(qmp_path))
        stream = qmp.makefile("rwb")
        json.loads(stream.readline())
        sequence = 0

        def request(command, arguments=None):
            nonlocal sequence
            sequence += 1
            message = {"execute": command, "id": sequence}
            if arguments is not None:
                message["arguments"] = arguments
            stream.write((json.dumps(message) + "\n").encode())
            stream.flush()
            while True:
                line = stream.readline()
                assert line, "Owned QMP connection closed"
                reply = json.loads(line)
                if reply.get("id") == sequence:
                    assert "error" not in reply, "QMP request failed"
                    return reply["return"]

        request("qmp_capabilities")
        assert request("query-name")["name"] == "Axiom development"

        def key(*codes):
            request("send-key", {"keys": [{"type": "qcode", "data": c} for c in codes],
                                 "hold-time": 30})
            time.sleep(0.08)

        def enter(value):
            key("ctrl", "a")
            key("backspace")
            for char in value:
                key(char)
            key("ret")

        def wait_for(predicate):
            deadline = time.monotonic() + 10
            while time.monotonic() < deadline:
                current = status()
                if predicate(current):
                    return current
                time.sleep(0.2)
            raise AssertionError("PAM lock transition did not complete; no bypass attempted")

        if not status()["locked"]:
            assert guest("omarchy-shell", "lock", "lock").strip() == "ok"
        before = wait_for(lambda s: s["locked"] and s["secure"])
        assert compositor_locked(), "Compositor must independently confirm real lock"
        locked_model = json.loads(guest("python3", "/tmp/axiom-phase3/tests/window-state-smoke.py"))
        enter("axiominvalidfixturepassword")
        time.sleep(0.8)
        rejected = wait_for(lambda s: not s["authenticating"])
        assert rejected["locked"] and rejected["secure"] and compositor_locked()
        enter(password)
        after = wait_for(lambda s: not s["locked"])
        assert not compositor_locked()
        unlocked_model = json.loads(guest("python3", "/tmp/axiom-phase3/tests/window-state-smoke.py"))
        stream.close()
    return {"before": before, "wrongInputDidNotUnlock": True, "wrongInputStatus": rejected, "after": after,
            "whileLocked": locked_model, "afterUnlock": unlocked_model,
            "scope": "New read-only model instances in both states; not shell action/overlay lock gating"}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("state", type=Path)
    args = parser.parse_args()
    print(json.dumps(check(args.state), indent=2))
