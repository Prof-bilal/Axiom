#!/usr/bin/env python3
"""Read-only live/missing-session QML integration checks; never operates windows."""
import json
import argparse
import os
from pathlib import Path
import subprocess
import tempfile
import time
import uuid

ROOT = Path(__file__).resolve().parents[1]
CONFIG = ROOT / "shell/window-state-probe.qml"


def compositor_counts():
    counts = {
        key: len(json.loads(subprocess.check_output(
            ["hyprctl", "-j", query], timeout=4)))
        for key, query in (("windowCount", "clients"),
                           ("workspaceCount", "workspaces"),
                           ("monitorCount", "monitors"))
    }
    active = json.loads(subprocess.check_output(
        ["hyprctl", "-j", "activewindow"], timeout=4))
    counts["activeWindowKnown"] = bool(active.get("address"))
    workspace = json.loads(subprocess.check_output(
        ["hyprctl", "-j", "activeworkspace"], timeout=4))
    counts["activeWorkspaceId"] = workspace.get("id")
    return counts


def check(missing_session, lifecycle=False, session_env=None, disconnect=None, monitor_lifecycle=False, exercise=None, recover=None):
    env = os.environ.copy()
    env.update(session_env or {})
    if lifecycle or monitor_lifecycle or exercise:
        # Accident prevention for developer tests, not a product authority gate.
        assert env.get("AXIOM_TEST_VM") == "1", "Set AXIOM_TEST_VM=1 only in the disposable fixture"
        virtualization = subprocess.run(["systemd-detect-virt", "--vm"],
                                        capture_output=True, text=True, timeout=3)
        assert virtualization.returncode == 0 and virtualization.stdout.strip() in {"qemu", "kvm"}, \
            "Mutating integration checks require the disposable QEMU/KVM guest"
    if missing_session:
        env.pop("HYPRLAND_INSTANCE_SIGNATURE", None)
        env["QT_QPA_PLATFORM"] = "offscreen"
    with tempfile.TemporaryFile() as log:
        process = subprocess.Popen(
            ["qs", "--no-color", "-p", str(CONFIG)], env=env,
            stdin=subprocess.DEVNULL, stdout=log, stderr=subprocess.STDOUT)
        fixtures = []
        monitor_name = "AXIOM-FOUNDATION-" + uuid.uuid4().hex[:12]
        monitor_created = False
        def query(method="summary", *arguments):
            return json.loads(subprocess.check_output(
                ["qs", "ipc", "--pid", str(process.pid), "call",
                 "axiomWindowProbe", method, *arguments], env=env, timeout=3))

        def await_count(expected):
            deadline = time.monotonic() + 8
            while time.monotonic() < deadline:
                count = query("applicationSummary", "axiom-foundation-fixture")
                if (count["windowCount"] == expected
                        and count["activeWindowCount"] == (1 if expected else 0)):
                    assert count["uniqueAddressCount"] == expected, count
                    return count
                time.sleep(0.1)
            raise AssertionError(f"Fixture window count did not become {expected}")

        def await_monitors(expected):
            deadline = time.monotonic() + 8
            while time.monotonic() < deadline:
                current = query()
                if current["monitorCount"] == expected:
                    return current["monitorCount"]
                time.sleep(0.1)
            raise AssertionError(f"Monitor model did not become {expected}")

        try:
            deadline = time.monotonic() + 12
            result = None
            while time.monotonic() < deadline:
                if process.poll() is not None:
                    raise AssertionError("QML diagnostic exited before readiness")
                reply = subprocess.run(
                    ["qs", "ipc", "--pid", str(process.pid),
                     "call", "axiomWindowProbe", "summary"],
                    capture_output=True, text=True, timeout=3, env=env)
                if reply.returncode == 0:
                    result = json.loads(reply.stdout)
                    if missing_session or result["status"] == "observing":
                        break
                time.sleep(0.1)  # Bounded test readiness, not a production poll.
            assert result is not None, "No diagnostic result"
            if missing_session:
                assert result["status"] == "unavailable", result
                assert all(result[k] == 0 for k in
                           ["windowCount", "workspaceCount", "monitorCount"]), result
                assert not result["activeWindowKnown"], result
            else:
                assert result["status"] == "observing", result
                # Two stable independent samples avoid claiming a count race is
                # a model failure while the owner opens/closes an application.
                for _ in range(8):
                    before = compositor_counts()
                    reply = subprocess.check_output(
                        ["qs", "ipc", "--pid", str(process.pid),
                         "call", "axiomWindowProbe", "summary"], timeout=3)
                    result = json.loads(reply)
                    after = compositor_counts()
                    if before == after and all(result[k] == v for k, v in after.items()):
                        break
                    time.sleep(0.1)
                else:
                    raise AssertionError(f"No matching stable compositor sample: before={before}, observed={result}, after={after}")
                if lifecycle:
                    assert await_count(0)["windowCount"] == 0
                    # Explicit opt-in: only use this in a disposable guest. Foot
                    # is a real native application, not a fake compositor model.
                    for _ in range(2):
                        fixtures.append(subprocess.Popen(
                            ["foot", "--app-id=axiom-foundation-fixture", "sleep", "60"],
                            stdin=subprocess.DEVNULL, stdout=log, stderr=log, env=env))
                    two = await_count(2)
                    if exercise:
                        result["placement"] = exercise(query, env, fixtures)
                    fixtures[-1].terminate()
                    fixtures[-1].wait(timeout=4)
                    one = await_count(1)
                    fixtures[0].terminate()
                    fixtures[0].wait(timeout=4)
                    zero = await_count(0)
                    result["lifecycle"] = [two, one, zero]
                if monitor_lifecycle:
                    original = query()["monitorCount"]
                    existing = json.loads(subprocess.check_output(
                        ["hyprctl", "-j", "monitors"], env=env, timeout=4))
                    assert not any(m["name"] == monitor_name for m in existing)
                    monitor_created = True  # Also clean up an uncertain timeout.
                    response = subprocess.check_output(
                        ["hyprctl", "output", "create", "headless", monitor_name],
                        env=env, timeout=5, text=True)
                    assert response.strip() == "ok", response
                    added = await_monitors(original + 1)
                    response = subprocess.check_output(
                        ["hyprctl", "output", "remove", monitor_name],
                        env=env, timeout=5, text=True)
                    assert response.strip() == "ok", response
                    monitor_created = False
                    removed = await_monitors(original)
                    result["monitorLifecycle"] = [original, added, removed]
                if disconnect:
                    disconnect()
                    query("revalidate")
                    deadline = time.monotonic() + 6
                    while time.monotonic() < deadline:
                        disconnected = query()
                        if disconnected["status"] == "unavailable":
                            break
                        time.sleep(0.1)
                    assert disconnected["status"] == "unavailable", disconnected
                    assert all(disconnected[k] == 0 for k in
                               ["windowCount", "workspaceCount", "monitorCount"]), disconnected
                    assert not disconnected["activeWindowKnown"], disconnected
                    result["disconnect"] = disconnected
                    if recover:
                        recover()
                        query("revalidate")
                        deadline = time.monotonic() + 6
                        while time.monotonic() < deadline:
                            recovered = query()
                            if recovered["status"] == "observing":
                                break
                            time.sleep(0.1)
                        assert recovered["status"] == "observing", recovered
                        result["recovery"] = recovered
            return result
        except Exception:
            log.seek(0)
            # Startup diagnostic has no window title/content logging enabled.
            print(log.read(16000).decode(errors="replace"))
            raise
        finally:
            if monitor_created:
                subprocess.run(["hyprctl", "output", "remove", monitor_name],
                               env=env, capture_output=True, timeout=5, check=False)
            for fixture in fixtures:
                fixture.terminate()
                try:
                    fixture.wait(timeout=4)
                except subprocess.TimeoutExpired:
                    fixture.kill()
                    fixture.wait(timeout=4)
            # Only the process created by this invocation is signalled.
            process.terminate()
            try:
                process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                process.kill()
                process.wait(timeout=5)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--lifecycle", action="store_true",
                        help="Opt-in disposable guest only: open/close two owned Foot windows")
    parser.add_argument("--monitors", action="store_true",
                        help="Opt-in disposable guest only: add/remove an owned headless monitor")
    args = parser.parse_args()
    print(json.dumps({"live": check(False, args.lifecycle, monitor_lifecycle=args.monitors),
                      "missingSession": check(True)}, indent=2))
