#!/usr/bin/env python3
"""Phase 7 update and rollback acceptance on an installed btrfs system (ADR-033).

    tests/phase7-update-rollback.py INSTALL_DIR OUTDIR

INSTALL_DIR is the Phase 6 install stage's output (it holds disk.qcow2 and OVMF_VARS.fd).
The guest boots the installed disk with user-mode networking, logs in as the installer-created
user and reaches a root shell through sudo (root is locked, as on a real install).

Checks, in order:
  1. the root filesystem is btrfs and the first-boot snapper setup finished
  2. the helper refuses what it must: no snapper, bad snapshot number, bad description, no polkit agent
  3. install htop through the helper (the Software Center path after polkit)
  4. update through axiom-pkg-update: a 'before update' snapshot exists before pacman runs
  5. a broken system after the update (htop's binary removed) is detected
  6. axiom-pkg-rollback to the 'before update' snapshot, reboot, and the system is back:
     htop runs, the file written after the snapshot is gone, the file written before it is kept

Exit codes: 0 all checks pass, 1 a check failed, 2 usage, 3 the guest never reached a login prompt.
Evidence: OUTDIR/transcript.txt (every root command with rc and output), serial log and screendump.
"""
import os
import re
import shlex
import subprocess
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from qemu_lib import Guest  # noqa: E402

USER, PW = "dev", "correct-horse-9"  # the Phase 6 install stage's account
if len(sys.argv) != 3 or not os.path.isdir(sys.argv[1]):
    print(__doc__)
    sys.exit(2)
INST, OUT = sys.argv[1], sys.argv[2]
DISK = os.path.join(INST, "disk.qcow2")
VARS = os.path.join(INST, "OVMF_VARS.fd")
os.makedirs(OUT, exist_ok=True)


def boot():
    g = Guest(None, OUT, mem=2560, smp=2)
    g.vars_src = VARS
    g.extra = ["-nic", "user,model=virtio-net-pci",
               "-drive", f"file={DISK},if=virtio,format=qcow2,cache=unsafe"]
    g.start()
    return g


def serial_root(g, mark=0):
    """Log in as the installed user, then reach a root shell through sudo (root is locked)."""
    if not g.wait_for("login:", 420, mark):
        return False
    time.sleep(3)
    g._write(USER + "\n"); time.sleep(2)
    g._write(PW + "\n"); time.sleep(5)
    g._write("sudo -S -p '' -i\n"); time.sleep(2)
    g._write(PW + "\n"); time.sleep(3)
    g._write("exec sh\n"); time.sleep(2)
    g._write("stty -echo; PS1=; PS2=\n"); time.sleep(1.5)
    return g.sh("id -u", 15)[1].strip() == "0"


def user_cmd(g, cmd, timeout=60):
    """Run as the installed user, the way the Software Center runs unprivileged reads."""
    return g.sh(f"su {USER} -s /bin/sh -c {shlex.quote(cmd)}", timeout)


g = boot()
if not g.wait_for("login:", 420):
    g.kill()
    sys.exit(3)
if not serial_root(g):
    g.check(False, "root shell reached through the installed user's sudo")
    g.kill()
    sys.exit(1)
g.check(True, "root shell reached through the installed user's sudo")

# 1. btrfs root and first-boot snapper setup
rc, out = g.sh("findmnt -no FSTYPE /", 20)
g.check(out.strip() == "btrfs", f"root filesystem is btrfs (got {out.strip()!r})")
ok = False
for _ in range(120):  # the first-boot oneshot may still be running
    rc, out = g.sh("test -f /etc/axiom/snapper-done && snapper list-configs 2>/dev/null | grep -c '^root'", 20)
    if (out or "").strip() == "1":
        ok = True
        break
    time.sleep(5)
g.check(ok, "first-boot snapper setup finished and the root config exists")

# 2. helper refusals (negative checks)
rc, out = g.sh("/usr/bin/env PATH=/nonexistent /bin/sh /usr/local/bin/axiom-pkgd update; echo RC=$?", 60)
g.check("RC=3" in out, "update refused when snapper is missing (exit 3, no pacman run)")
rc, out = g.sh("/usr/local/bin/axiom-pkgd rollback abc; echo RC=$?", 30)
g.check("RC=2" in out, "rollback refused for a non-numeric snapshot id")
rc, out = g.sh("/usr/local/bin/axiom-pkgd snapshot 'a;rm -rf /'; echo RC=$?", 30)
g.check("RC=2" in out, "snapshot refused for a description with shell characters")
rc, out = user_cmd(g, "pkexec /usr/local/bin/axiom-pkg-update; echo RC=$?", 60)
g.check("RC=0" not in out and "RC=" in out, "unprivileged update without a polkit agent is refused")

# 3. install htop through the helper (sync = pacman -Sy --needed, the install path)
rc, out = g.sh("/usr/local/bin/axiom-pkgd sync htop", 1800)
g.check(rc == 0, f"install htop through the helper (rc={rc})")
rc, out = g.sh("pacman -Qq htop", 20)
g.check(rc == 0, "htop is in the package database")

# 4. update with a snapshot taken first
g.sh("echo before-update > /etc/axiom-rollback-test", 20)
rc, out = g.sh("/usr/local/bin/axiom-pkg-update", 3600)
g.check(rc == 0, f"update through axiom-pkg-update (rc={rc})")
rc, out = g.sh("snapper -c root list --columns number,description | grep 'before update' | tail -1", 30)
m = re.search(r"^\s*(\d+)\s*\|", out or "", re.M)
snap = m.group(1) if m else None
g.check(snap is not None, f"a 'before update' snapshot exists (number {snap})")
g.sh("echo after-update > /etc/axiom-after-update", 20)

# 5. the system is broken by the update (simulated: htop's binary is removed)
rc, out = g.sh("rm -f /usr/bin/htop && (htop --version >/dev/null 2>&1; echo RC=$?)", 30)
g.check("RC=0" not in out, "a broken binary is detected after the update")

# 6. rollback and reboot
rc, out = g.sh(f"/usr/local/bin/axiom-pkg-rollback {shlex.quote(snap or '0')}; echo RC=$?", 600)
g.check("RC=0" in out, "rollback to the 'before update' snapshot is accepted")
mark = len(g.raw)
g.sh("sync", 60)
g._write("systemctl reboot\n")
back = serial_root(g, mark)
g.check(back, "the system boots again after the rollback and reaches a root shell")
if back:
    rc, out = g.sh("htop --version >/dev/null 2>&1; echo RC=$?", 30)
    g.check("RC=0" in out, "htop runs again (its binary is back)")
    rc, out = g.sh("test -e /etc/axiom-after-update && echo PRESENT || echo GONE", 20)
    g.check("GONE" in out, "the file written after the snapshot is gone")
    rc, out = g.sh("cat /etc/axiom-rollback-test", 20)
    g.check("before-update" in out, "the file written before the snapshot is kept")

g.kill()
sys.exit(1 if g.failures else 0)
