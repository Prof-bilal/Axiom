#!/usr/bin/env python3
"""Exercise real native window controls in an owned disposable QEMU guest."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import time

ROOT = Path(__file__).resolve().parents[1]
PROBE = ROOT / "shell/window-controls-probe.qml"


def require_disposable_guest(env):
    assert env.get("AXIOM_TEST_VM") == "1", "Set AXIOM_TEST_VM=1 only in the disposable fixture"
    virtualization = subprocess.run(["systemd-detect-virt", "--vm"], env=env,
                                    capture_output=True, text=True, timeout=3)
    assert virtualization.returncode == 0 and virtualization.stdout.strip() in {"qemu", "kvm"}, \
        "Window mutation tests require a disposable QEMU/KVM guest"


def main():
    env = os.environ.copy()
    require_disposable_guest(env)
    fixtures = []
    app_id = "axiom-controls-fixture-" + str(os.getpid())
    with tempfile.TemporaryFile() as log:
        process = subprocess.Popen(["qs", "--no-color", "-p", str(PROBE)], env=env,
                                    stdin=subprocess.DEVNULL, stdout=log, stderr=subprocess.STDOUT)

        def call(method, *args):
            reply = subprocess.run(["qs", "ipc", "--pid", str(process.pid), "call",
                                    "axiomWindowControlsProbe", method, *args],
                                   env=env, capture_output=True, text=True, timeout=3)
            # IPC registration can lag process creation by one event-loop turn;
            # callers' bounded waits treat this as not-ready, not as a product
            # failure. Once ready, every action call still requires success.
            if reply.returncode != 0:
                return {"_ipcError": reply.stderr.strip()}
            return json.loads(reply.stdout)

        def wait_for(predicate, description, timeout=10):
            deadline = time.monotonic() + timeout
            last = None
            while time.monotonic() < deadline:
                if process.poll() is not None:
                    raise AssertionError("control probe exited before " + description)
                last = predicate()
                if last:
                    return last
                time.sleep(0.1)
            raise AssertionError(f"Timed out waiting for {description}: {last}")

        def windows():
            return [item for item in call("windows") if item.get("appId") == app_id]

        def last_result():
            return call("lastResult")

        def action(address, operation):
            queued = call("action", address, operation)
            assert queued.get("queued"), queued
            def completed():
                result = last_result()
                return result if result.get("status") != "pending" else None
            return wait_for(completed, operation + " verification")

        try:
            wait_for(lambda: call("summary").get("status") == "observing", "probe readiness")
            for _ in range(2):
                fixtures.append(subprocess.Popen(
                    ["foot", f"--app-id={app_id}", "sleep", "60"],
                    stdin=subprocess.DEVNULL, stdout=log, stderr=log, env=env))
            wait_for(lambda: len(windows()) == 2, "two owned windows")
            targets = windows()
            target = targets[0]
            address = target["address"]
            assert address.startswith("0x")

            results = {"target": address}
            results["maximize"] = action(address, "maximize")
            assert results["maximize"]["status"] == "verified", results["maximize"]
            assert wait_for(lambda: next((w for w in windows() if w["address"] == address), {})
                             .get("maximized") is True, "maximized state")

            results["restoreMaximize"] = action(address, "restore-maximize")
            assert results["restoreMaximize"]["status"] == "verified", results["restoreMaximize"]

            results["fullscreen"] = action(address, "fullscreen")
            assert results["fullscreen"]["status"] == "verified", results["fullscreen"]
            results["exitFullscreen"] = action(address, "exit-fullscreen")
            assert results["exitFullscreen"]["status"] == "verified", results["exitFullscreen"]

            results["minimize"] = action(address, "minimize")
            assert results["minimize"]["status"] == "verified", results["minimize"]
            results["restoreMinimize"] = action(address, "restore-minimize")
            assert results["restoreMinimize"]["status"] == "verified", results["restoreMinimize"]

            results["close"] = action(address, "close")
            assert results["close"]["status"] == "verified", results["close"]
            assert wait_for(lambda: len(windows()) == 1, "one remaining owned window")
            print(json.dumps(results, indent=2))
        except Exception:
            log.seek(0)
            print(log.read(16000).decode(errors="replace"))
            raise
        finally:
            for fixture in fixtures:
                fixture.terminate()
                try:
                    fixture.wait(timeout=4)
                except subprocess.TimeoutExpired:
                    fixture.kill()
                    fixture.wait(timeout=4)
            process.terminate()
            try:
                process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                process.kill()
                process.wait(timeout=5)


if __name__ == "__main__":
    main()
