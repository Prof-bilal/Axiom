#!/usr/bin/env python3
"""Disposable-guest observation fixture cost; not input-to-frame latency."""
import hashlib
import json
import os
from pathlib import Path
import platform
import statistics
import subprocess
import sys
import tempfile
import time

ROOT = Path(__file__).resolve().parents[1]
CONFIGS = {"native": ROOT / "tests/fixtures/window-native.qml",
           "axiom": ROOT / "shell/window-state-probe.qml"}


def progress(message):
    print(message, file=sys.stderr, flush=True)


def start(config, log):
    started = time.monotonic()
    process = subprocess.Popen(["qs", "--no-color", "-p", str(config)],
                               stdin=subprocess.DEVNULL, stdout=log, stderr=log)
    try:
        while time.monotonic() - started < 12:
            assert process.poll() is None, "Probe exited during startup"
            reply = subprocess.run(["qs", "ipc", "--pid", str(process.pid), "call",
                                    "axiomWindowProbe", "summary"],
                                   capture_output=True, text=True, timeout=2)
            if reply.returncode == 0 and json.loads(reply.stdout)["status"] == "observing":
                return process, (time.monotonic() - started) * 1000
            time.sleep(0.01)
        raise TimeoutError("Probe readiness")
    except Exception:
        stop(process)
        raise


def stop(process):
    process.terminate()
    try:
        process.wait(timeout=4)
    except subprocess.TimeoutExpired:
        process.kill()
        process.wait(timeout=4)


def sample(process):
    assert process.poll() is None
    fields = Path(f"/proc/{process.pid}/stat").read_text().split(") ", 1)[1].split()
    pss = next(int(line.split()[1]) for line in
               Path(f"/proc/{process.pid}/smaps_rollup").read_text().splitlines()
               if line.startswith("Pss:"))
    return {"time": time.monotonic(), "cpuTicks": int(fields[11]) + int(fields[12]),
            "pssKiB": pss}


def main():
    raw = {name: [] for name in CONFIGS}
    idle = {}
    with tempfile.TemporaryFile() as log:
        # One warmup per arm, followed by ten interleaved measured launches each.
        for run in range(11):
            for name in (["native", "axiom"] if run % 2 == 0 else ["axiom", "native"]):
                process, latency = start(CONFIGS[name], log)
                stop(process)
                if run:
                    raw[name].append(latency)
        progress("Ten interleaved startup measurements per arm complete")
        for name, config in CONFIGS.items():
            process, _ = start(config, log)
            try:
                progress(f"{name}: 30-second stabilization, then five-minute idle interval")
                time.sleep(30)
                samples = [sample(process)]
                for index in range(10):
                    time.sleep(30)
                    samples.append(sample(process))
                    progress(f"{name}: idle sample {index + 1}/10")
                duration = samples[-1]["time"] - samples[0]["time"]
                cpu_seconds = (samples[-1]["cpuTicks"] - samples[0]["cpuTicks"]) / os.sysconf("SC_CLK_TCK")
                idle[name] = {"samples": samples, "durationSeconds": duration,
                              "cpuSeconds": cpu_seconds,
                              "oneCpuPercent": cpu_seconds / duration * 100,
                              "medianPssKiB": statistics.median(s["pssKiB"] for s in samples)}
            finally:
                stop(process)
    return {
        "scope": "Warm probe-process start to first successful IPC reply reporting native models; no UI/first-frame claim",
        "predeclaredProtocol": {"warmupPerArm": 1, "startupRunsPerArm": 10,
                                 "stabilizationSeconds": 30, "idleSecondsPerArm": 300,
                                 "idleSampleSeconds": 30, "regressionThresholdPercent": 5,
                                 "interpretation": "Investigate differences beyond 5% and measured noise; no product-speed claim"},
        "environment": {"kernel": platform.release(), "architecture": platform.machine(),
                        "guestCpuCount": os.cpu_count(),
                        "quickshell": subprocess.check_output(["qs", "--version"], text=True).strip(),
                        "clockTicksPerSecond": os.sysconf("SC_CLK_TCK"),
                        "sourceSha256": {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
                                         for p in [*CONFIGS.values(), *sorted((ROOT / "shell/services").glob("*.qml"))]}},
        "startupMilliseconds": raw,
        "startupSummary": {name: {"median": statistics.median(v), "min": min(v), "max": max(v)}
                           for name, v in raw.items()},
        "idle": idle,
        "limitations": ["Single guest session and software VGA; host contention/thermal state not controlled",
                        "IPC readiness polling and client startup add measurement overhead and quantization",
                        "PSS depends on other processes sharing Qt libraries; idle arms are sequential",
                        "No battery, GPU, frame timing, whole-shell startup or input-latency measurement"]}


if __name__ == "__main__":
    print(json.dumps(main(), indent=2))
