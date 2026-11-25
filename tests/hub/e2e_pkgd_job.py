#!/usr/bin/env python3
"""End-to-end check of axiom-pkgd's job, lock and cancel with REAL systemd and a REAL pacman transaction, without root.

    python3 tests/hub/e2e_pkgd_job.py        (needs network, fakeroot, curl, a systemd user session)

What is real: the helper script, systemd-run and the transient unit (in the user manager, through thin shims that add
--user), the lock, the log, and pacman downloading and installing real packages into a private root (fakeroot, no
chroot, so package hooks do not run). What is not: it is not the system manager and not the real root filesystem, and
snapper is skipped (the live-image path). So it proves the job mechanics and the cancel rule on real pacman output; it
does not prove a root install on a booted Axiom system.
"""
import os
import shutil
import signal
import subprocess
import sys
import tempfile
import time

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
HELPER = os.path.join(REPO, "system/pkgd/axiom-pkgd")
UNIT = "axiom-pkg-job.service"
MIRROR = "https://geo.mirror.pkgbuild.com/$repo/os/$arch"
fails = []


def check(cond, msg):
    print(("PASS: " if cond else "FAIL: ") + msg, flush=True)
    if not cond:
        fails.append(msg)


def active():
    return subprocess.run(["systemctl", "--user", "is-active", "--quiet", UNIT]).returncode == 0


def wait(cond, secs, step=0.3):
    end = time.time() + secs
    while time.time() < end:
        if cond():
            return True
        time.sleep(step)
    return False


class Lab:
    def __init__(self):
        self.t = tempfile.mkdtemp(prefix="axiom-pkgd-e2e-")
        self.bin = os.path.join(self.t, "bin")
        os.makedirs(self.bin)
        self.n = 0
        self.env = {**os.environ, "PATH": f"{self.bin}:/usr/bin:/bin", "AXIOM_PKGD_SYSTEMD_DIR": self.t,
                    "AXIOM_PKGD_LIVE_DIR": self.t, "AXIOM_PKGD_LOCK": os.path.join(self.t, "lock"), "AXIOM_PKGD_RUNDIR": self.t}
        self.shim("id", "echo 0")
        self.shim("logger", "exit 0")
        # The helper runs as root; here the user manager stands in for the system manager.
        self.shim("systemd-run", 'exec /usr/bin/systemd-run --user --setenv=PATH="$PATH" "$@"')
        self.shim("systemctl", 'exec /usr/bin/systemctl --user "$@"')

    def shim(self, name, body):
        p = os.path.join(self.bin, name)
        open(p, "w").write("#!/bin/sh\n" + body + "\n")
        os.chmod(p, 0o755)

    def private_root(self, throttle=None, seed_from=None):
        """A fresh private pacman root. -Sy in the helper's live path becomes -S, so the synced databases are reused."""
        self.n += 1
        r = os.path.join(self.t, f"r{self.n}")
        for d in ("root", "db/sync", "cache", "gpg", "hooks"):
            os.makedirs(os.path.join(r, d))
        xfer = f"XferCommand = /usr/bin/curl --limit-rate {throttle} -L -C - -f -o %o %u\n" if throttle else ""
        conf = os.path.join(r, "pacman.conf")
        open(conf, "w").write(f"""[options]
RootDir = {r}/root
DBPath = {r}/db
CacheDir = {r}/cache
GPGDir = {r}/gpg
LogFile = {r}/pacman.log
HookDir = {r}/hooks
Architecture = x86_64
SigLevel = Never
{xfer}[core]
Server = {MIRROR}
[extra]
Server = {MIRROR}
""")
        if seed_from:
            for f in os.listdir(seed_from):
                shutil.copy(os.path.join(seed_from, f), os.path.join(r, "db/sync", f))
        self.shim("pacman", f'for a; do case "$a" in -Sy) a=-S;; esac; set -- "$@" "$a"; shift; done\n'
                            f'exec fakeroot /usr/bin/pacman --config {conf} "$@"')
        return r

    def helper(self, *args, **kw):
        return subprocess.Popen(["sh", HELPER, *args], env=self.env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                text=True, **kw)

    def run(self, *args):
        p = self.helper(*args)
        out, _ = p.communicate(timeout=240)
        return p.returncode, out

    def installed(self, root, pkg):
        return any(d.startswith(pkg + "-") for d in os.listdir(os.path.join(root, "db/local"))) if os.path.isdir(os.path.join(root, "db/local")) else False

    def log(self):
        p = os.path.join(self.t, "axiom-pkg-job.log")
        return open(p).read() if os.path.exists(p) else ""

    def cleanup(self):
        subprocess.run(["systemctl", "--user", "stop", UNIT], capture_output=True)
        subprocess.run(["systemctl", "--user", "reset-failed", UNIT], capture_output=True)
        shutil.rmtree(self.t, ignore_errors=True)


def main():
    for tool in ("fakeroot", "curl", "pacman", "systemd-run"):
        if not shutil.which(tool):
            print(f"SKIP: needs {tool}")
            return 0
    if subprocess.run(["systemctl", "--user", "show-environment"], capture_output=True).returncode != 0:
        print("SKIP: no systemd user session")
        return 0
    if active():
        print("SKIP: an axiom-pkg-job unit is already running in this user session")
        return 0
    lab = Lab()
    try:
        # Sync the databases once, unthrottled, into a seed root.
        seed = lab.private_root()
        subprocess.run(["fakeroot", "/usr/bin/pacman", "--config", os.path.join(seed, "pacman.conf"), "-Sy"], capture_output=True, timeout=240)
        seed_db = os.path.join(seed, "db/sync")
        check(os.path.exists(os.path.join(seed_db, "core.db")), "synced the package databases for the private roots")

        # 1. a real install through the helper, as a real transient unit
        r1 = lab.private_root(seed_from=seed_db)
        rc, out = lab.run("sync", "which")
        check(rc == 0 and lab.installed(r1, "which"), f"sync installs a real package through the unit (rc={rc})")
        check(not active(), "the unit is gone after the job (--collect)")
        log = lab.log()
        check(":: Processing package changes" in log and "installing which..." in log, "the job log holds the real pacman output")
        check(":: Processing package changes" in out, "the same output was streamed to the caller")

        # 2. cancel while downloading (throttled so the window is long enough)
        r2 = lab.private_root(throttle="400k", seed_from=seed_db)
        lab.env["AXIOM_PKGD_DBLOCK"] = os.path.join(r2, "db/db.lck")
        p = lab.helper("sync", "which")
        started = wait(lambda: active() and ":: Retrieving packages" in lab.log(), 40)
        check(started, "a throttled install is running as the unit and is downloading")
        rc, out = lab.run("cancel")
        check(rc == 0, f"cancel during download succeeds (rc={rc}: {out.strip()[-80:]})")
        try:
            p.wait(timeout=60)
        except subprocess.TimeoutExpired:
            p.kill()
        check(not active(), "the unit stopped")
        check(not lab.installed(r2, "which"), "nothing was installed by the cancelled job")
        check(not os.path.exists(os.path.join(r2, "db/db.lck")), "no stale pacman lock is left behind (the helper removes it when no pacman runs)")

        # 3. closing the window (killing the caller) must not stop the install
        r3 = lab.private_root(throttle="1200k", seed_from=seed_db)
        p = lab.helper("sync", "which", start_new_session=True)
        check(wait(lambda: active() and ":: Retrieving packages" in lab.log(), 40), "install running (downloading) before the window closes")
        os.killpg(p.pid, signal.SIGKILL)  # the helper and the systemd-run client: what closing the Hub does
        p.wait()
        time.sleep(1)
        check(active(), "the unit keeps running after its caller is killed")

        # 4. a second request while it runs is refused and does not damage the first
        rc2, out2 = lab.run("sync", "which")
        check(rc2 != 0, f"a second install while one runs is refused (rc={rc2}: {out2.strip()[-90:]})")
        check(lab.log().count(":: Retrieving packages") <= 1, "the running job's log was not truncated or restarted")
        check(wait(lambda: not active(), 120), "the first job finishes on its own")
        check(lab.installed(r3, "which"), "and it installed correctly even though its caller was killed")

        # 6. cancel is refused during the commit. Real pacman's commit is too fast to time, so the real unit, lock and log
        #    are used with a replay of REAL pacman output (tests/apps/fixtures) that pauses at the commit marker.
        fixture = os.path.join(REPO, "tests/apps/fixtures/pacman-piped-install.txt")
        lab.shim("pacman", f'while IFS= read -r l; do echo "$l"; case "$l" in ":: Processing package changes"*) sleep 10;; esac; done < {fixture}')
        p = lab.helper("sync", "which", start_new_session=True)
        check(wait(lambda: active() and ":: Processing package changes" in lab.log(), 20), "the replayed job reached its commit phase")
        rc, out = lab.run("cancel")
        check(rc == 6 and "too late" in out, f"cancel is refused during the commit (rc={rc}: {out.strip()[-70:]})")
        check(active(), "and the job keeps running")
        check(wait(lambda: not active(), 40), "the job finishes on its own")
        p.wait(timeout=30)

        # 5. cancel with nothing running
        rc, out = lab.run("cancel")
        check(rc == 7, f"cancel with no job says so (rc={rc})")
    finally:
        lab.cleanup()
    print("%d failure(s)" % len(fails))
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main())
