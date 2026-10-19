#!/usr/bin/env python3
"""Audit whether Axiom has evidence to begin Phase 1 development.

This is a read-only gate. It does not install packages, alter host state, or
turn skipped concept checks into passes.
"""
from __future__ import annotations

import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile


ROOT = Path(__file__).resolve().parents[1]
REQUIRED_TOOLS = ("qemu-system-x86_64", "qemu-img", "mkarchiso")


def command_ok(command: list[str]) -> bool:
    result = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
    return result.returncode == 0


def main() -> int:
    blockers: list[str] = []
    evidence: dict[str, object] = {}

    validator = command_ok([sys.executable, "-E", "scripts/validate-repo.py"])
    evidence["foundation_validation"] = validator
    if not validator:
        blockers.append("foundation repository validation failed")

    with tempfile.TemporaryDirectory(prefix="axiom-readiness-") as temp:
        report_path = Path(temp) / "concepts.json"
        concepts = subprocess.run(
            [sys.executable, "-E", "-B", "scripts/test-concepts.py", "--report", str(report_path)],
            cwd=ROOT,
            capture_output=True,
            text=True,
        )
        report = json.loads(report_path.read_text()) if report_path.exists() else {}
    checks = report.get("checks", [])
    skipped = [item for item in checks if item.get("status") == "SKIP"]
    failed = [item for item in checks if item.get("status") in {"FAIL", "ERROR"}]
    evidence["concept_checks"] = {
        "exit_code": concepts.returncode,
        "total": len(checks),
        "skipped": len(skipped),
        "failed_or_errored": len(failed),
    }
    if concepts.returncode != 0 or failed:
        blockers.append("local concept checks have failures or errors")
    if skipped:
        blockers.append("local concept checks contain environment-denied skips")

    missing_tools = [tool for tool in REQUIRED_TOOLS if shutil.which(tool) is None]
    evidence["required_build_tools"] = {tool: tool not in missing_tools for tool in REQUIRED_TOOLS}
    if missing_tools:
        blockers.append("missing build tools: " + ", ".join(missing_tools))

    kvm = Path("/dev/kvm").exists()
    evidence["kvm"] = kvm
    if not kvm:
        blockers.append("/dev/kvm is unavailable for accelerated disposable VM tests")

    user_manager = command_ok(["systemctl", "--user", "show", "--property=Version", "--value"])
    evidence["user_manager"] = user_manager
    if not user_manager:
        blockers.append("user systemd manager is inaccessible")

    canonical_skills = (ROOT / ".agents/skills").is_dir()
    evidence["canonical_skills"] = canonical_skills
    if not canonical_skills:
        blockers.append("canonical .agents/skills are not installed")

    evidence_file = ROOT / "docs/engineering/CONCEPT_CHECKS_2026-10-19.json"
    recorded = json.loads(evidence_file.read_text()) if evidence_file.exists() else {}
    experiments = recorded.get("runtime_experiments_E01_E20")
    evidence["recorded_runtime_experiments"] = experiments
    if experiments != "COMPLETE":
        blockers.append("runtime experiments E01-E20 are not recorded complete")

    print("Axiom Phase 1 readiness: READY" if not blockers else "Axiom Phase 1 readiness: BLOCKED")
    for blocker in blockers:
        print(f"BLOCKER: {blocker}")
    print(json.dumps(evidence, sort_keys=True))
    return 0 if not blockers else 1


if __name__ == "__main__":
    raise SystemExit(main())
