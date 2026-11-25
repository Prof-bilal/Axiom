#!/usr/bin/env python3
"""End-to-end check of the Hub search path on this machine (not part of pytest collection; needs network and pacman).

    python3 tests/hub/e2e_hub_backend.py

Runs the real HubBackend (apps/hub) headless under Quickshell with the real engine (system/hub), the real Flathub index
and the real pacman database. It checks: a search returns Firefox from the Arch repo and Flathub with a logo URL, a search
for nothing is empty and not an error, a hostile search text is just text (no command runs), the Installed list comes from
the system, and the update check finishes. It does not install anything: installs need root and a booted Axiom system.
"""
import os
import shutil
import subprocess
import sys
import tempfile
import time

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
CANARY = "/tmp/axiom-e2e-pwned"


def main():
    if not shutil.which("qs") or not shutil.which("pacman"):
        print("SKIP: needs quickshell (qs) and pacman")
        return 0
    if os.path.exists(CANARY):
        os.remove(CANARY)
    tmp = tempfile.mkdtemp(prefix="axiom-e2e-")
    # A tiny stand-in for archlinux-appstream-data (same shape as the real package: <id>, <pkgname>, type), so the run
    # does not depend on that package being installed on the machine under test.
    cat = os.path.join(tmp, "swcatalog")
    os.makedirs(cat)
    with open(os.path.join(cat, "extra.xml"), "w") as fh:
        fh.write('<components origin="e2e">'
                 '<component type="desktop-application"><id>org.mozilla.firefox</id><pkgname>firefox</pkgname></component>'
                 '<component type="desktop-application"><id>foot.desktop</id><pkgname>foot</pkgname></component></components>')
    env = {**os.environ, "QT_QPA_PLATFORM": "offscreen",
           "AXIOM_HUB_BIN": os.path.join(REPO, "system/hub/axiom-hub"),
           "AXIOM_HUB_ENGINE": os.path.join(REPO, "system/hub/hubengine.py"),
           "AXIOM_HUB_CACHE": os.path.join(tmp, "cache"), "AXIOM_HUB_CATALOGS": cat, "AXIOM_HUB_STATE": os.path.join(tmp, "state")}
    p = subprocess.Popen(["qs", "-n", "-p", os.path.join(REPO, "shell/hub-e2e.qml")], env=env,
                         stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    lines, deadline = [], time.time() + 150
    try:
        for line in p.stdout:
            if "E2E " in line:
                lines.append(line.split("E2E ", 1)[1].strip())
                if lines[-1] == "DONE":
                    break
            if time.time() > deadline:
                break
    finally:
        p.kill()  # this exact process, never by name
        p.wait()
        shutil.rmtree(tmp, ignore_errors=True)
    got = {l.split(" ", 1)[0]: l for l in lines}
    fails = []

    def check(cond, msg):
        print(("PASS: " if cond else "FAIL: ") + msg)
        if not cond:
            fails.append(msg)

    s = got.get("SEARCH", "")
    check("error=[]" in s and "pacman:official" in s and "flatpak:" in s, "search finds Firefox from the Arch repo and Flathub: " + s)
    check("icon=0" not in s and "icon=" in s, "the result has a logo URL")
    check(got.get("EMPTY", "").startswith("EMPTY count=0 error=[]"), "a search with no match is empty and not an error: " + got.get("EMPTY", ""))
    check("error=[]" in got.get("EVIL", "x"), "hostile search text is handled as text: " + got.get("EVIL", "missing"))
    check(not os.path.exists(CANARY), "no command from the search text ran")
    i = got.get("INSTALLED", "")
    check(i.startswith("INSTALLED count=") and "count=0" not in i, "the Installed list is built from the system: " + i)
    check("UPDATES" in got, "the update check finished: " + got.get("UPDATES", "missing"))
    check("DONE" in lines, "the run finished before the time limit")
    print("%d failure(s)" % len(fails))
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main())
