#!/usr/bin/env python3
"""Disposable guest only: targeted window/workspace/mixed-scale monitor tests."""
import json
import os
from pathlib import Path
import re
import runpy
import subprocess
import time
import uuid


def exercise(query, env, fixtures):
    comparison = {}
    def ctl(*args, json_result=False):
        value = subprocess.check_output(["hyprctl", *args], env=env, timeout=5, text=True)
        if json_result:
            return json.loads(value)
        assert value.strip() == "ok", value

    def wait_for(probe, predicate):
        deadline = time.monotonic() + 8
        while time.monotonic() < deadline:
            value = probe()
            if predicate(value):
                return value
            time.sleep(0.1)
        raise AssertionError(f"Placement did not converge: {value}; last comparison: {comparison}")

    def focus_workspace(workspace):
        ctl("dispatch", 'hl.dsp.focus({workspace="' + str(workspace) + '"})')
        return wait_for(query, lambda state: state["activeWorkspaceId"] == workspace)

    clients = ctl("-j", "clients", json_result=True)
    targets = [c for c in clients if c["class"] == "axiom-foundation-fixture"
               and c["pid"] in {p.pid for p in fixtures}]
    assert len(targets) == 2, "Two owned fixture targets required"
    target = targets[-1]
    address = target["address"]
    assert re.fullmatch(r"0x[0-9a-fA-F]+", address), "Invalid compositor address"
    original_ws = ctl("-j", "activeworkspace", json_result=True)["id"]
    assert isinstance(original_ws, int) and original_ws > 0
    workspace = 900000 + os.getpid()
    assert workspace not in [w["id"] for w in ctl("-j", "workspaces", json_result=True)]
    monitor = "AXIOM-PLACEMENT-" + uuid.uuid4().hex[:12]
    assert not any(m["name"] == monitor for m in ctl("-j", "monitors", json_result=True))
    monitor_created = False
    report = {}

    def move(**fields):
        # Every value is a validated test-owned identifier or a fixed literal.
        options = ','.join(key + '=' + json.dumps(value) for key, value in fields.items())
        ctl("dispatch", 'hl.dsp.window.move({window="address:' + address + '",' + options + '})')

    def placement():
        actual = next((c for c in ctl("-j", "clients", json_result=True)
                       if c["address"] == address), None)
        assert actual is not None and actual["pid"] == target["pid"]
        monitor_state = next(m for m in ctl("-j", "monitors", json_result=True)
                             if m["id"] == actual["monitor"])
        observed = query("windowPlacement", address)
        comparison.update(observed=observed, expected={
            "workspaceId": actual["workspace"]["id"],
            "monitorName": monitor_state["name"], "monitorScale": monitor_state["scale"]})
        if (observed.get("known") and observed["workspaceId"] == actual["workspace"]["id"]
                and observed["monitorName"] == monitor_state["name"]
                and observed["monitorScale"] == monitor_state["scale"]):
            return observed
        return {}

    try:
        report["initial"] = wait_for(placement, bool)
        focus_workspace(workspace)
        move(workspace=str(workspace), follow=True)
        report["workspaceMove"] = wait_for(
            placement, lambda p: bool(p) and p["workspaceId"] == workspace)
        focus_workspace(original_ws)
        focus_workspace(workspace)
        report["workspaceSwitch"] = True

        monitor_created = True
        ctl("output", "create", "headless", monitor)
        wait_for(lambda: ctl("-j", "monitors", json_result=True),
                 lambda monitors: any(m["name"] == monitor for m in monitors))
        ctl("eval", 'hl.monitor({output="' + monitor + '",mode="1920x1080@60",position="auto",scale=1.5})')
        wait_for(lambda: ctl("-j", "monitors", json_result=True),
                 lambda monitors: any(m["name"] == monitor and m["scale"] == 1.5 for m in monitors))
        move(monitor=monitor, follow=True)
        report["mixedScaleMove"] = wait_for(
            placement, lambda p: bool(p) and p["monitorName"] == monitor and p["monitorScale"] == 1.5)
        ctl("output", "remove", monitor)
        monitor_created = False
        report["populatedMonitorRemoval"] = wait_for(
            placement, lambda p: bool(p) and p["monitorName"] != monitor)
        move(workspace=str(original_ws), follow=True)
        focus_workspace(original_ws)
        report["restored"] = wait_for(
            placement, lambda p: bool(p) and p["workspaceId"] == original_ws)
        return report
    finally:
        if monitor_created:
            ctl("output", "remove", monitor)
        # Only test-owned windows were moved; restore the initial guest workspace.
        focus_workspace(original_ws)


if __name__ == "__main__":
    check = runpy.run_path(str(Path(__file__).with_name("window-state-smoke.py")))["check"]
    print(json.dumps(check(False, lifecycle=True, exercise=exercise), indent=2))
