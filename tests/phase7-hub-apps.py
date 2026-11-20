#!/usr/bin/env python3
"""Phase 7 Hub acceptance: install every installable Hub app one by one, launch it, then remove it.

    tests/phase7-hub-apps.py ISO OUTDIR [--only id,id] [--disk-gb 60] [--mem 4096] [--fresh]

The install and remove commands are the Hub's own argv (tests/apps/hub-plan.mjs reads apps/hub/backends.js),
run in a guest with user-mode networking and a blank virtio disk mounted as the desktop user's home.
Per app, the result is recorded with evidence (the command output and the launch log):

  install   the Hub's command exits 0 and the app shows up in the package manager's list
  launch    GUI app: its desktop Exec stays alive for 15 s; CLI app: `--version` (or `--help`) exits 0
            with output. A crash or a short-lived exit is a FAIL.
  remove    the Hub's remove command exits 0 and the app is gone from the list

Pacman installs run as root through /usr/local/bin/axiom-pkgd, the same helper that pkexec runs after the
polkit prompt. The serial root shell stands in for the polkit prompt, which needs a graphical agent.
Apps with no installable source (manual only) are recorded as SKIP, not as passes.
Results: OUTDIR/results.json (resumable: finished apps are skipped on rerun unless --fresh).
Exit codes: 0 all installable apps pass, 1 at least one FAIL, 2 usage, 3 firmware stall.
"""
import json
import os
import shlex
import subprocess
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from qemu_lib import Guest  # noqa: E402

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
args = sys.argv[1:]
if len(args) < 2 or not os.path.isfile(args[0]):
    print(__doc__)
    sys.exit(2)
ISO, OUT = args[0], args[1]
ONLY = None
DISK_GB, MEM, FRESH = 60, 4096, "--fresh" in args
for i, a in enumerate(args):
    if a == "--only":
        ONLY = set(args[i + 1].split(","))
    if a == "--disk-gb":
        DISK_GB = int(args[i + 1])
    if a == "--mem":
        MEM = int(args[i + 1])
os.makedirs(OUT, exist_ok=True)
RESULTS_PATH = os.path.join(OUT, "results.json")
results = {} if FRESH or not os.path.exists(RESULTS_PATH) else json.load(open(RESULTS_PATH))
DISK = os.path.join(OUT, "hub-disk.qcow2")
LOG_DIR = os.path.join(OUT, "apps")
os.makedirs(LOG_DIR, exist_ok=True)
PLAN = json.loads(subprocess.run(["node", os.path.join(REPO, "tests/apps/hub-plan.mjs")],
                                 check=True, capture_output=True, text=True).stdout)
HOME = "/home/axiom"


def save():
    json.dump(results, open(RESULTS_PATH, "w"), indent=1)


def q(argv):
    return " ".join(shlex.quote(x) for x in argv)


def boot():
    if not os.path.exists(DISK):
        subprocess.run(["qemu-img", "create", "-f", "qcow2", DISK, f"{DISK_GB}G"], check=True)
    for attempt in range(1, int(os.environ.get("QEMU_BOOT_ATTEMPTS", "3")) + 1):
        g = Guest(ISO, OUT, "1920x1080", mem=MEM, smp=4, net=True,
                  extra=["-drive", f"file={DISK},if=virtio,format=qcow2"])
        g.start()
        if g.wait_login():
            return g
        print(f"phase7-hub: firmware stall on attempt {attempt}; retrying", flush=True)
        g.kill()
    sys.exit(3)


g = boot()
g.login_root()
if not g.shell_ready():  # no session means no user commands: stop, do not mark every app FAIL
    g.kill()
    sys.exit(f"desktop shell never came up; see {OUT}/transcript.txt")
g.prepare_env()  # writes /tmp/axiom-env.sh, which user() sources
# Blank disk becomes the desktop user's home, so Flatpak and npm writes stay off the RAM live image.
rc, out = g.sh(f"mkfs.ext4 -q -F /dev/vda && mkdir -p {HOME} && mount /dev/vda {HOME} && chown axiom {HOME} && df -h {HOME} | tail -1", 300)
g.check(rc == 0, f"home disk mounted ({out.splitlines()[-1] if out else 'no output'})")
rc, out = g.sh("ping -c1 -W5 dl.flathub.org >/dev/null 2>&1 && echo NET_OK || echo NET_FAIL", 30)
g.check("NET_OK" in (out or ""), "guest reaches dl.flathub.org (user-mode network)")
g.user(q(PLAN["remote"]), 120)  # the Hub adds the flathub remote before the first Flatpak install
g.user("mkdir -p ~/Applications", 20)


def installed_now(app):
    """Same test the Hub uses to decide 'installed' (backends.js installedIds)."""
    ref = app["ref"]
    if app["source"] == "flatpak":
        rc, out = g.user("flatpak list --app --columns=application", 60)
        return ref in (out or "").split()
    if app["source"] == "pacman":
        rc, out = g.sh("pacman -Qq", 60)
        return ref in (out or "").split()
    if app["source"] == "npm":
        rc, out = g.sh(f"npm ls -g --prefix {HOME}/.local --depth=0 --parseable", 60)
        return f"/node_modules/{ref}" in (out or "")
    if app["source"] == "pip":
        rc, out = g.user("pipx list --short", 60)
        return any(line.split()[:1] == [ref] for line in (out or "").splitlines())
    return False


def launch_check(app, logf):
    """GUI apps stay up for 15 s; CLI apps print a version and exit 0."""
    src, ref = app["source"], app["ref"]
    if src == "flatpak":
        cmd, gui = f"flatpak run {shlex.quote(ref)}", True
    else:
        rc, out = g.sh(f"pacman -Ql {shlex.quote(ref)} 2>/dev/null | grep '/usr/share/applications/.*\\.desktop$' | head -1 | awk '{{print $2}}'", 30) if src == "pacman" else (0, "")
        desk = (out or "").strip()
        execline = ""
        if desk:
            rc2, dout = g.sh(f"grep -m1 '^Exec=' {shlex.quote(desk)}", 20)
            execline = (dout or "").replace("Exec=", "").split()
            execline = " ".join(t for t in execline if not t.startswith("%"))
        if execline:
            cmd, gui = execline, True
        else:
            binary = ref.split("/")[-1].lower()
            cmd, gui = f"{binary} --version", False
    if gui:
        rc, out = g.user(f"( {cmd} > /tmp/launch.log 2>&1 & echo $! > /tmp/launch.pid ); sleep 15; "
                         f"kill -0 $(cat /tmp/launch.pid) && echo ALIVE || echo DEAD; "
                         f"pkill -f {shlex.quote(ref if src == 'flatpak' else cmd.split()[0])} ; sleep 2; cat /tmp/launch.log | tail -20", 90)
        ok = "ALIVE" in (out or "")
    else:
        rc, out = g.user(f"timeout 20 {cmd}", 40)
        ok = rc == 0 and bool((out or "").strip())
    with open(logf, "a") as f:
        f.write(f"$ launch ({'gui' if gui else 'cli'}) {cmd}\n{out}\n")
    return ok, cmd, gui


for app in PLAN["apps"]:
    aid = app["id"]
    if ONLY and aid not in ONLY:
        continue
    if aid in results and results[aid].get("status") in ("PASS", "SKIP", "FAIL") and not FRESH:
        print(f"skip (done): {aid} = {results[aid]['status']}", flush=True)
        continue
    logf = os.path.join(LOG_DIR, aid + ".log")
    open(logf, "w").close()
    row = {"name": app["name"], "source": app["source"], "ref": app["ref"], "verified": app["verified"], "checks": {}}
    results[aid] = row
    if not app["install"]:
        row.update(status="SKIP", note="no installable source (manual only); the Hub cannot install it")
        save()
        print(f"SKIP {aid}: manual only", flush=True)
        continue
    t0 = time.monotonic()
    if app["source"] == "pacman":
        # root path through the helper, as pkexec would run it after the polkit prompt
        rc, out = g.sh(f"/usr/local/bin/axiom-pkgd sync {shlex.quote(app['ref'])}", 1800)
    else:
        rc, out = g.user(q(app["install"]), 1800)
    open(logf, "a").write(f"$ install\n[rc={rc}]\n{out}\n")
    row["checks"]["install_rc0"] = rc == 0
    row["checks"]["in_package_list"] = installed_now(app) if rc == 0 else False
    row["install_seconds"] = round(time.monotonic() - t0)
    if row["checks"]["install_rc0"] and row["checks"]["in_package_list"]:
        ok, cmd, gui = launch_check(app, logf)
        row["checks"]["launch"] = ok
        row["launch_cmd"] = cmd
    else:
        row["checks"]["launch"] = False
    if app["remove"]:
        if app["source"] == "pacman":
            rc, out = g.sh(f"/usr/local/bin/axiom-pkgd remove {shlex.quote(app['ref'])}", 600)
        else:
            rc, out = g.user(q(app["remove"]), 600)
        open(logf, "a").write(f"$ remove\n[rc={rc}]\n{out}\n")
        row["checks"]["removed"] = rc == 0 and not installed_now(app)
    row["status"] = "PASS" if all(row["checks"].values()) else "FAIL"
    save()
    print(f"{row['status']} {aid}: {row['checks']}", flush=True)

g.kill()
save()
summary = {k: v["status"] for k, v in results.items()}
tally = {s: sum(1 for x in summary.values() if x == s) for s in ("PASS", "FAIL", "SKIP")}
print("TOTALS", tally, flush=True)
sys.exit(1 if tally["FAIL"] else 0)
