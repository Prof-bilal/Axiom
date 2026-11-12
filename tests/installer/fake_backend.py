#!/usr/bin/env python3
"""Fake installer backend for UI tests: prints realistic progress events quickly (no disk access)."""
import json
import sys
import time

sys.stdin.read()


def ev(**k):
    print(json.dumps(k), flush=True)


ev(event="progress", pct=2, stage="Preparing the disk", detail="")
for p in range(8, 100):
    stage = "Downloading Axiom" if p < 50 else "Installing the system" if p < 85 else "Setting up startup"
    detail = f"{p * 7} MiB downloaded at 2.5 MiB/s" if p < 50 else f"Package {p} of 159: pkg{p}"
    ev(event="progress", pct=p, stage=stage, detail=detail, eta_min=max(1, (100 - p) // 8))
    time.sleep(0.35)
ev(event="done", pct=100)
