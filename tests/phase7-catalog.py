#!/usr/bin/env python3
"""Axiom Phase 7 catalogue check (QEMU/KVM, networked): install and remove every user-scope Hub app.

    AXIOM_TEST_NET=1 QEMU_MEM=8192 tests/phase7-catalog.py <iso> [outdir] [--only id1,id2]

The live image keeps writes in RAM, so installs need memory: QEMU_MEM sets guest RAM (MiB).

For each catalogue entry whose only usable source is Flatpak, npm or pip, the script runs the
same argv the Hub runs (see apps/hub/backends.js), as the desktop user, then checks the app is
listed as installed, removes it, and checks it is gone. Results go to results-catalog.json.

Skipped on purpose (not run here):
  - pacman entries: they need an admin password (pkexec) that a test cannot type;
  - manual entries: they are downloads or installers, not commands;
  - AppImage/.deb: covered by tests/phase7-apps.py.

Exit codes: 0 all run apps pass, 1 failures, 2 usage, 3 firmware-stage stall (retry the run).
"""
import json
import os
import re
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from qemu_lib import Guest  # noqa: E402

args = sys.argv[1:]
if not args or not os.path.isfile(args[0]):
    print(__doc__)
    sys.exit(2)
ISO = args[0]
OUT = args[1] if len(args) > 1 and not args[1].startswith("--") else "iso/out-phase7/catalog"
ONLY = None
for i, a in enumerate(args):
    if a == "--only" and i + 1 < len(args):
        ONLY = set(args[i + 1].split(","))
os.makedirs(OUT, exist_ok=True)
HOME = "/home/axiom"
CATALOG_JS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "apps", "hub", "catalog.js")


def load_catalog():
    """Read the catalogue the way tests/apps does: the JSON array inside catalog.js."""
    s = open(CATALOG_JS).read()
    return json.loads(s[s.index("[", s.index("var CATALOG")):])


def plan(app):
    """Return (kind, install argv, remove argv, detect command) for a user-scope source, else None."""
    for src in app["sources"]:
        t, ref = src["type"], src["ref"]
        if t == "flatpak" and re.fullmatch(r"[A-Za-z0-9_.-]+", ref):
            return ("flatpak",
                    ["flatpak", "install", "--user", "-y", "--noninteractive", "flathub", ref],
                    ["flatpak", "uninstall", "--user", "-y", "--noninteractive", ref],
                    f"flatpak list --app --columns=application | grep -qx {ref}")
        if t == "npm":
            return ("npm",
                    ["npm", "install", "-g", "--prefix", HOME + "/.local", ref],
                    ["npm", "uninstall", "-g", "--prefix", HOME + "/.local", ref],
                    f"npm ls -g --prefix {HOME}/.local --depth=0 --parseable | grep -q '/node_modules/{ref}$'")
        if t == "pip":
            return ("pip",
                    ["pipx", "install", ref],
                    ["pipx", "uninstall", ref],
                    f"pipx list --short | awk '{{print $1}}' | grep -qx {ref}")
    return None


def argv_str(argv):
    return " ".join("'" + a.replace("'", "'\\''") + "'" for a in argv)


catalog = load_catalog()
todo, skipped = [], []
for app in catalog:
    if ONLY is not None and app["id"] not in ONLY:
        continue
    p = plan(app)
    if p is None:
        why = "pacman needs an admin password" if any(s["type"] == "pacman" for s in app["sources"]) \
            else "manual download or installer"
        skipped.append({"id": app["id"], "reason": why})
    else:
        todo.append((app, p))

for attempt in range(1, 4):
    g = Guest(ISO, OUT, "1920x1080", mem=int(os.environ.get("QEMU_MEM", "2048")), net=os.environ.get("AXIOM_TEST_NET") == "1")
    g.start()
    if g.wait_login():
        print(f"catalog: guest reached a login prompt on attempt {attempt}")
        break
    g.shot(f"00-firmware-stall-{attempt}")
    print(f"catalog: attempt {attempt}/3 stalled in firmware; retrying")
    g.kill()
else:
    print("STALL: no login prompt after 3 attempts")
    sys.exit(3)
if not g.login_root() or not g.shell_ready():
    g.bad("could not get a session shell")
    g.kill()
    sys.exit(1)
g.prepare_env()
g.ok("session ready")

# Flathub remote once (the Hub adds it the same way).
rc, out = g.user("flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo", 180)
g.check(rc == 0, "flathub remote is available for the desktop user")

results = []
for app, (kind, inst, rem, detect) in todo:
    rec = {"id": app["id"], "name": app["name"], "kind": kind}
    t0 = time.monotonic()
    rc, out = g.user(argv_str(inst), 1800)
    rec["install_exit"] = rc
    rec["install_tail"] = (out or "").strip().splitlines()[-3:]
    rec["install_seconds"] = round(time.monotonic() - t0)
    if rc == 0:
        rc2, _ = g.user(detect, 60)
        rec["listed_after_install"] = rc2 == 0
        rc3, out3 = g.user(argv_str(rem), 900)
        rec["remove_exit"] = rc3
        rc4, _ = g.user(detect, 60)
        rec["gone_after_remove"] = rc4 != 0
        rec["pass"] = rec["listed_after_install"] and rc3 == 0 and rec["gone_after_remove"]
    else:
        rec["pass"] = False
    g.check(rec["pass"], f"{app['id']} ({kind}): install, list, remove, gone")
    results.append(rec)
    with open(os.path.join(OUT, "results-catalog.json"), "w") as f:
        json.dump({"ran": results, "skipped": skipped}, f, indent=2)

g.user("pkill -f 'flatpak|npm|pipx' ; true", 20)
if g.power_off():
    g.ok("guest powered off cleanly")
else:
    g.bad("guest did not power off")
    g.kill()

passed = sum(1 for r in results if r["pass"])
print(f"CATALOG: {passed}/{len(results)} apps passed; {len(skipped)} skipped (see results-catalog.json)")
print("RESULT:", "PASS" if not g.failures else f"FAIL ({len(g.failures)})")
sys.exit(0 if not g.failures else 1)
