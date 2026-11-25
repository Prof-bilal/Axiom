// Tests for system/pkgd/axiom-pkgd with stubbed `id` and `pacman`, so no real root is needed.
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { spawn, spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const helper = path.join(here, "../../system/pkgd/axiom-pkgd");
const dir = fs.mkdtempSync(path.join(os.tmpdir(), "pkgd-"));
// Never touch the real /run lock or the real systemd in tests: a temp lock file and a systemd dir that does not exist.
const LOCKFILE = path.join(dir, "lock");
const BASE = { AXIOM_PKGD_LOCK: LOCKFILE, AXIOM_PKGD_SYSTEMD_DIR: "/nonexistent", AXIOM_PKGD_RUNDIR: dir };
fs.writeFileSync(path.join(dir, "id"), "#!/bin/sh\necho 0\n", { mode: 0o755 });
fs.writeFileSync(path.join(dir, "pacman"), '#!/bin/sh\necho "pacman $*"\n', { mode: 0o755 });
const live = fs.mkdtempSync(path.join(os.tmpdir(), "pkgd-live-"));
const run = (...args) => spawnSync("sh", [helper, ...args], { encoding: "utf8", env: { ...BASE, PATH: `${dir}:/usr/bin:/bin`, AXIOM_PKGD_LIVE_DIR: live } });

test("on the live image sync and remove reach pacman with fixed flags", () => {
  assert.equal(run("sync", "neovim").stdout.trim(), "pacman -Sy --noconfirm --needed -- neovim");
  assert.equal(run("remove", "neovim").stdout.trim(), "pacman -Rns --noconfirm -- neovim");
});

test("core packages cannot be removed", () => {
  for (const core of ["linux", "pacman", "polkit", "systemd", "axiom-pkgd"]) {
    const r = run("remove", core);
    assert.equal(r.status, 2, core);
    assert.ok(!r.stdout.includes("pacman"), core);
  }
});

test("bad package names are refused before pacman runs", () => {
  for (const bad of ["", "-Syu", "a;b", "A", "a b", "../x", "$(id)"]) {
    const r = run("sync", bad);
    assert.equal(r.status, 2, JSON.stringify(bad));
    assert.ok(!r.stdout.includes("pacman"), JSON.stringify(bad));
  }
});

test("unknown operations and relative install paths are refused", () => {
  assert.equal(run("upgrade", "x").status, 2);
  assert.equal(run("install", "rel.pkg.tar.zst").status, 2);
  assert.equal(run("install", "/tmp/x.txt").status, 2);
  assert.equal(run().status, 2);
});

test("a non-root caller is refused", () => {
  fs.writeFileSync(path.join(dir, "id"), "#!/bin/sh\necho 1000\n", { mode: 0o755 });
  assert.equal(run("sync", "neovim").status, 1);
  fs.writeFileSync(path.join(dir, "id"), "#!/bin/sh\necho 0\n", { mode: 0o755 });
});

// Snapshot-backed verbs (ADR-033): snapper and pacman are stubbed; the order of calls is checked.
const sdir = fs.mkdtempSync(path.join(os.tmpdir(), "pkgd-snap-"));
fs.writeFileSync(path.join(sdir, "id"), "#!/bin/sh\necho 0\n", { mode: 0o755 });
fs.writeFileSync(path.join(sdir, "pacman"), '#!/bin/sh\necho "pacman $*"\n', { mode: 0o755 });
// Echo to stderr too: `update` captures stdout to read the snapshot number.
fs.writeFileSync(path.join(sdir, "snapper"), '#!/bin/sh\necho "snapper $*"\necho "snapper $*" >&2\n', { mode: 0o755 });
const srun = (...args) => spawnSync("sh", [helper, ...args], { encoding: "utf8", env: { ...BASE, PATH: `${sdir}:/usr/bin:/bin`, AXIOM_PKGD_VIA: "wrapper" } });

test("update takes a snapshot before the full upgrade", () => {
  const r = srun("update");
  assert.equal(r.status, 0);
  assert.equal(r.stderr.trim().split("\n")[0], "snapper -c root create --type single --description before update --print-number");
  assert.equal(r.stdout.trim(), "pacman -Syu --noconfirm");
});

test("installed sync snapshots first and never does a partial upgrade", () => {
  const r = spawnSync("sh", [helper, "sync", "neovim"], { encoding: "utf8", env: { ...BASE, PATH: `${sdir}:/usr/bin:/bin`, AXIOM_PKGD_LIVE_DIR: "/nonexistent" } });
  assert.equal(r.status, 0);
  const lines = r.stdout.trim().split("\n");
  assert.equal(lines[0], "snapper -c root create --type single --description before sync");
  assert.equal(lines[1], "pacman -Syu --noconfirm --needed -- neovim");
});

test("installed remove snapshots first and refuses without snapper", () => {
  const env = { ...BASE, PATH: `${sdir}:/usr/bin:/bin`, AXIOM_PKGD_LIVE_DIR: "/nonexistent" };
  const r = spawnSync("sh", [helper, "remove", "neovim"], { encoding: "utf8", env });
  assert.equal(r.stdout.trim().split("\n")[0], "snapper -c root create --type single --description before remove");
  const nodir = fs.mkdtempSync(path.join(os.tmpdir(), "pkgd-nosnap2-"));
  fs.writeFileSync(path.join(nodir, "id"), "#!/bin/sh\necho 0\n", { mode: 0o755 });
  fs.writeFileSync(path.join(nodir, "pacman"), '#!/bin/sh\necho "pacman $*"\n', { mode: 0o755 });
  fs.writeFileSync(path.join(nodir, "flock"), "#!/bin/sh\nexit 0\n", { mode: 0o755 }); // PATH is only this dir
  const n = spawnSync("/bin/sh", [helper, "remove", "neovim"], { encoding: "utf8", env: { ...BASE, PATH: nodir, AXIOM_PKGD_LIVE_DIR: "/nonexistent" } });
  assert.equal(n.status, 3);
  assert.ok(!n.stdout.includes("pacman"));
});

test("a failed update deletes the snapshot it just took", () => {
  const fdir = fs.mkdtempSync(path.join(os.tmpdir(), "pkgd-fail-"));
  fs.writeFileSync(path.join(fdir, "id"), "#!/bin/sh\necho 0\n", { mode: 0o755 });
  fs.writeFileSync(path.join(fdir, "pacman"), "#!/bin/sh\nexit 1\n", { mode: 0o755 });
  fs.writeFileSync(path.join(fdir, "snapper"), '#!/bin/sh\ncase "$*" in *print-number*) echo 42;; *) echo "snapper $*";; esac\n', { mode: 0o755 });
  const r = spawnSync("sh", [helper, "update"], { encoding: "utf8", env: { ...BASE, PATH: `${fdir}:/usr/bin:/bin`, AXIOM_PKGD_VIA: "wrapper" } });
  assert.equal(r.status, 1);
  assert.ok(r.stdout.includes("snapper -c root delete 42"));
});

const fakeSync = path.join(sdir, "boot-sync");
fs.writeFileSync(fakeSync, '#!/bin/sh\necho "boot-sync $*"\n', { mode: 0o755 });
const rrun = (...args) => spawnSync("sh", [helper, ...args], { encoding: "utf8", env: { ...BASE, PATH: `${sdir}:/usr/bin:/bin`, AXIOM_PKGD_VIA: "wrapper", AXIOM_BOOT_SYNC: fakeSync } });

test("rollback syncs the boot files after snapper succeeds", () => {
  assert.equal(rrun("rollback", "12").stdout.trim(), "snapper -c root --ambit classic rollback 12\nboot-sync 12");
});

test("a failed boot sync after rollback is reported, not hidden", () => {
  const bad = path.join(sdir, "boot-sync-bad");
  fs.writeFileSync(bad, "#!/bin/sh\nexit 1\n", { mode: 0o755 });
  const r = spawnSync("sh", [helper, "rollback", "12"], { encoding: "utf8", env: { ...BASE, PATH: `${sdir}:/usr/bin:/bin`, AXIOM_PKGD_VIA: "wrapper", AXIOM_BOOT_SYNC: bad } });
  assert.equal(r.status, 4);
  assert.match(r.stderr, /do not reboot/);
});

test("rollback needs a numeric snapshot id", () => {
  for (const bad of ["", "1;2", "x", "-1"]) assert.equal(rrun("rollback", bad).status, 2, JSON.stringify(bad));
});

test("snapshot descriptions are checked", () => {
  assert.equal(srun("snapshot", "before install 2").status, 0);
  for (const bad of ["", "a;rm", "$(id)", "x".repeat(61)]) assert.equal(srun("snapshot", bad).status, 2, JSON.stringify(bad));
});

test("without snapper the snapshot-backed verbs refuse and never run pacman", () => {
  const nodir = fs.mkdtempSync(path.join(os.tmpdir(), "pkgd-nosnap-"));
  fs.writeFileSync(path.join(nodir, "id"), "#!/bin/sh\necho 0\n", { mode: 0o755 });
  fs.writeFileSync(path.join(nodir, "pacman"), '#!/bin/sh\necho "pacman $*"\n', { mode: 0o755 });
  fs.writeFileSync(path.join(nodir, "flock"), "#!/bin/sh\nexit 0\n", { mode: 0o755 }); // PATH is only this dir
  const r = spawnSync("/bin/sh", [helper, "update"], { encoding: "utf8", env: { ...BASE, PATH: nodir, AXIOM_PKGD_VIA: "wrapper" } });
  assert.equal(r.status, 3);
  assert.ok(!r.stdout.includes("pacman"));
});

test("update and rollback refuse a direct call (only their own polkit action reaches them)", () => {
  const direct = (...a) => spawnSync("sh", [helper, ...a], { encoding: "utf8", env: { ...BASE, PATH: `${sdir}:/usr/bin:/bin` } });
  for (const args of [["update"], ["rollback", "3"]]) {
    const r = direct(...args);
    assert.equal(r.status, 2, args.join(" "));
    assert.ok(!r.stdout.includes("pacman") && !r.stdout.includes("snapper"), args.join(" "));
  }
});

test("the wrappers set the marker for update and rollback", () => {
  for (const w of ["axiom-pkg-update", "axiom-pkg-rollback"]) {
    assert.match(fs.readFileSync(path.join(here, "../../system/pkgd", w), "utf8"), /AXIOM_PKGD_VIA=wrapper/);
  }
});

test("install hands the detached signature to pacman and logs the digest", () => {
  const idir = fs.mkdtempSync(path.join(os.tmpdir(), "pkgd-inst-"));
  fs.writeFileSync(path.join(idir, "id"), "#!/bin/sh\necho 0\n", { mode: 0o755 });
  fs.writeFileSync(path.join(idir, "logger"), '#!/bin/sh\necho "logger $*"\n', { mode: 0o755 });
  fs.writeFileSync(path.join(idir, "pacman"), '#!/bin/sh\nfor a; do case "$a" in */package) ls "$a" "$a.sig" 2>&1;; esac; done\n', { mode: 0o755 });
  const pkg = path.join(idir, "x.pkg.tar.zst");
  fs.writeFileSync(pkg, "data");
  fs.writeFileSync(pkg + ".sig", "sig");
  const r = spawnSync("sh", [helper, "install", pkg], { encoding: "utf8", env: { ...BASE, PATH: `${idir}:/usr/bin:/bin`, AXIOM_PKGD_TMP: idir, AXIOM_PKGD_LIVE_DIR: idir } });
  assert.match(r.stdout, /logger -t axiom-pkgd install x\.pkg\.tar\.zst sha256=[0-9a-f]{64} signed=yes/);
  assert.match(r.stdout, /package\.sig/);
});

// axiom-boot-sync (ADR-036): a restored snapshot's kernels replace the ones on /boot.
const syncHelper = path.join(here, "../../system/pkgd/axiom-boot-sync");
function bootFixture(kernels) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "bootsync-"));
  const snaps = path.join(root, "snaps"), boot = path.join(root, "boot"), bin = path.join(root, "bin");
  fs.mkdirSync(boot); fs.mkdirSync(bin);
  fs.writeFileSync(path.join(bin, "id"), "#!/bin/sh\necho 0\n", { mode: 0o755 });
  // Fake mkinitcpio writes "<ver>" into the image so the test can see which modules it was built for.
  fs.writeFileSync(path.join(bin, "mkinitcpio"), '#!/bin/sh\nwhile [ $# -gt 0 ]; do case "$1" in -k) k=$2; shift;; -g) g=$2; shift;; esac; shift; done\n[ "${FAIL_INITRAMFS:-}" = 1 ] && exit 1\necho "initramfs-for-$k" > "$g"\n', { mode: 0o755 });
  for (const [ver, base] of kernels) {
    const m = path.join(snaps, "7", "snapshot", "usr/lib/modules", ver);
    fs.mkdirSync(m, { recursive: true });
    fs.writeFileSync(path.join(m, "vmlinuz"), `kernel-${ver}`);
    fs.writeFileSync(path.join(m, "pkgbase"), base + "\n");
  }
  fs.writeFileSync(path.join(boot, "vmlinuz-linux"), "kernel-NEWER");
  const run = (n, extra = {}) => spawnSync("sh", [syncHelper, n], { encoding: "utf8", env: { ...BASE, PATH: `${bin}:/usr/bin:/bin`, AXIOM_BOOT_SNAPSHOTS: snaps, AXIOM_BOOT_DIR: boot, ...extra } });
  return { boot, run };
}

test("boot sync puts the snapshot's kernels and matching initramfs on /boot", () => {
  const { boot, run } = bootFixture([["6.10.1-arch1-1", "linux"], ["6.6.9-1-lts", "linux-lts"]]);
  const r = run("7");
  assert.equal(r.status, 0, r.stderr);
  assert.equal(fs.readFileSync(path.join(boot, "vmlinuz-linux"), "utf8"), "kernel-6.10.1-arch1-1");
  assert.equal(fs.readFileSync(path.join(boot, "initramfs-linux.img"), "utf8").trim(), "initramfs-for-6.10.1-arch1-1");
  assert.equal(fs.readFileSync(path.join(boot, "vmlinuz-linux-lts"), "utf8"), "kernel-6.6.9-1-lts");
  assert.deepEqual(fs.readdirSync(boot).filter((f) => f.endsWith(".axiom-new")), []);
});

test("boot sync leaves the old boot files alone if the initramfs build fails", () => {
  const { boot, run } = bootFixture([["6.10.1-arch1-1", "linux"]]);
  const r = run("7", { FAIL_INITRAMFS: "1" });
  assert.equal(r.status, 1);
  assert.equal(fs.readFileSync(path.join(boot, "vmlinuz-linux"), "utf8"), "kernel-NEWER");
  assert.deepEqual(fs.readdirSync(boot).filter((f) => f.endsWith(".axiom-new")), []);
});

test("boot sync rejects bad snapshot numbers and snapshots without kernels", () => {
  const { run } = bootFixture([["6.10.1-arch1-1", "linux"]]);
  for (const bad of ["", "1;2", "x"]) assert.equal(run(bad).status, 2, JSON.stringify(bad));
  assert.equal(run("99").status, 3);
});

// ---- ADR-037: lock, transient unit, cancel, snapshot before install ------------------------------------------
test("a second transaction is refused while another process holds the lock", async () => {
  // A separate process holds the lock, as a running pkexec helper would. (An inherited fd would share the lock.)
  const holder = spawn("flock", ["-n", LOCKFILE, "sleep", "5"], { stdio: "ignore" });
  try {
    await new Promise((r) => setTimeout(r, 400));
    const r = spawnSync("sh", [helper, "sync", "neovim"], { encoding: "utf8", env: { ...BASE, PATH: `${dir}:/usr/bin:/bin`, AXIOM_PKGD_LIVE_DIR: "/nonexistent" } });
    assert.equal(r.status, 5, r.stderr);
    assert.match(r.stderr, /already running/);
    assert.ok(!r.stdout.includes("pacman") && !r.stdout.includes("snapper"));
  } finally {
    holder.kill();
  }
});

test("with systemd the transaction runs as the transient unit axiom-pkg-job", () => {
  const udir = fs.mkdtempSync(path.join(os.tmpdir(), "pkgd-unit-"));
  fs.writeFileSync(path.join(udir, "id"), "#!/bin/sh\necho 0\n", { mode: 0o755 });
  fs.writeFileSync(path.join(udir, "systemd-run"), '#!/bin/sh\necho "systemd-run $*"\n', { mode: 0o755 });
  const r = spawnSync("sh", [helper, "sync", "neovim"], { encoding: "utf8", env: { PATH: `${udir}:/usr/bin:/bin`, AXIOM_PKGD_LOCK: path.join(udir, "lock"), AXIOM_PKGD_SYSTEMD_DIR: udir, AXIOM_PKGD_LIVE_DIR: udir, AXIOM_PKGD_RUNDIR: udir } });
  assert.equal(r.status, 0, r.stderr);
  // The command runs inside a small wrapper that copies its output to a log (cancel reads it), then the real command.
  assert.match(r.stdout.trim(), /^systemd-run --unit=axiom-pkg-job --collect --wait --pipe --quiet -- sh -c .*tee -p.* sh \S+axiom-pkg-job\.log \S+axiom-pkg-job\.log\.rc pacman -Sy --noconfirm --needed -- neovim$/s);
});

function cancelEnv(logText, active = true) {
  const cdir = fs.mkdtempSync(path.join(os.tmpdir(), "pkgd-cancel-"));
  fs.writeFileSync(path.join(cdir, "id"), "#!/bin/sh\necho 0\n", { mode: 0o755 });
  fs.writeFileSync(path.join(cdir, "systemctl"), `#!/bin/sh\ncase "$1" in is-active) exit ${active ? 0 : 3};; stop) echo "systemctl $*";; esac\n`, { mode: 0o755 });
  if (logText !== null) fs.writeFileSync(path.join(cdir, "axiom-pkg-job.log"), logText + "\n"); // what `job` wrote while pacman ran
  return { PATH: `${cdir}:/usr/bin:/bin`, AXIOM_PKGD_RUNDIR: cdir };
}

// The log text is a real pacman transaction (stdout not a terminal), cut where each phase would be.
const REAL = fs.readFileSync(path.join(here, "fixtures/pacman-piped-install.txt"), "utf8").trimEnd().split("\n");
const commitAt = REAL.findIndex((l) => l.startsWith(":: Processing package changes"));

test("cancel stops the job while pacman is still downloading (real output)", () => {
  assert.ok(commitAt > 5, "fixture has a download phase before the commit");
  for (const upto of [3, commitAt - 1]) { // resolving, and the end of keyring/integrity checks
    const r = spawnSync("sh", [helper, "cancel"], { encoding: "utf8", env: cancelEnv(REAL.slice(0, upto).join("\n")) });
    assert.equal(r.status, 0, r.stderr);
    assert.equal(r.stdout.trim(), "systemctl stop axiom-pkg-job.service");
  }
});

test("cancel is refused once pacman is changing the system (real output)", () => {
  // from the commit marker on, and again once packages are being installed
  for (const upto of [commitAt + 1, commitAt + 4, REAL.length]) {
    const r = spawnSync("sh", [helper, "cancel"], { encoding: "utf8", env: cancelEnv(REAL.slice(0, upto).join("\n")) });
    assert.equal(r.status, 6, `upto ${upto}`);
    assert.match(r.stderr, /too late/);
    assert.ok(!r.stdout.includes("systemctl stop"), `upto ${upto}`);
  }
  for (const line of ["upgrading glibc...", "removing foo...", "reinstalling bar..."]) {
    assert.equal(spawnSync("sh", [helper, "cancel"], { encoding: "utf8", env: cancelEnv(line) }).status, 6, line);
  }
});

test("cancel is refused when the log cannot be read (phase unknown), never assumed safe", () => {
  const r = spawnSync("sh", [helper, "cancel"], { encoding: "utf8", env: cancelEnv(null) });
  assert.equal(r.status, 6);
  assert.match(r.stderr, /cannot tell/);
  assert.ok(!r.stdout.includes("systemctl stop"));
});

test("cancel with no job running says so", () => {
  const r = spawnSync("sh", [helper, "cancel"], { encoding: "utf8", env: cancelEnv("", false) });
  assert.equal(r.status, 7);
  assert.match(r.stderr, /no install is running/);
});

test("install (pacman -U) snapshots first on an installed system and refuses without snapper", () => {
  const idir = fs.mkdtempSync(path.join(os.tmpdir(), "pkgd-instsnap-"));
  fs.writeFileSync(path.join(idir, "id"), "#!/bin/sh\necho 0\n", { mode: 0o755 });
  fs.writeFileSync(path.join(idir, "logger"), "#!/bin/sh\n", { mode: 0o755 });
  fs.writeFileSync(path.join(idir, "pacman"), '#!/bin/sh\necho "pacman $*"\n', { mode: 0o755 });
  fs.writeFileSync(path.join(idir, "flock"), "#!/bin/sh\nexit 0\n", { mode: 0o755 });
  const pkg = path.join(idir, "x.pkg.tar.zst");
  fs.writeFileSync(pkg, "d");
  const env = { PATH: idir, AXIOM_PKGD_TMP: idir, AXIOM_PKGD_LIVE_DIR: "/nonexistent", AXIOM_PKGD_LOCK: path.join(idir, "lock"), AXIOM_PKGD_SYSTEMD_DIR: "/nonexistent", AXIOM_PKGD_RUNDIR: idir };
  // PATH is only idir: provide the few tools the script needs.
  for (const tool of ["cp", "rm", "mktemp", "sha256sum", "cut", "basename", "tee", "cat", "sh"]) fs.symlinkSync(spawnSync("sh", ["-c", `command -v ${tool}`], { encoding: "utf8" }).stdout.trim(), path.join(idir, tool));
  const refused = spawnSync("/bin/sh", [helper, "install", pkg], { encoding: "utf8", env });
  assert.equal(refused.status, 3, refused.stderr);
  assert.ok(!refused.stdout.includes("pacman -U"));
  fs.writeFileSync(path.join(idir, "snapper"), '#!/bin/sh\necho "snapper $*"\n', { mode: 0o755 });
  const ok = spawnSync("/bin/sh", [helper, "install", pkg], { encoding: "utf8", env });
  assert.equal(ok.status, 0, ok.stderr);
  const lines = ok.stdout.trim().split("\n");
  assert.equal(lines[0], "snapper -c root create --type single --description before install");
  assert.match(lines[1], /^pacman -U --noconfirm -- /);
});

test("a new job does not start, or truncate the running job's log, while axiom-pkg-job is active", () => {
  const udir = fs.mkdtempSync(path.join(os.tmpdir(), "pkgd-busy-"));
  fs.writeFileSync(path.join(udir, "id"), "#!/bin/sh\necho 0\n", { mode: 0o755 });
  fs.writeFileSync(path.join(udir, "systemd-run"), '#!/bin/sh\necho "systemd-run $*"\n', { mode: 0o755 });
  fs.writeFileSync(path.join(udir, "systemctl"), "#!/bin/sh\nexit 0\n", { mode: 0o755 }); // is-active: yes
  fs.writeFileSync(path.join(udir, "axiom-pkg-job.log"), "installing foo...\n");
  const r = spawnSync("sh", [helper, "sync", "neovim"], { encoding: "utf8", env: { PATH: `${udir}:/usr/bin:/bin`, AXIOM_PKGD_LOCK: path.join(udir, "lock"), AXIOM_PKGD_SYSTEMD_DIR: udir, AXIOM_PKGD_LIVE_DIR: udir, AXIOM_PKGD_RUNDIR: udir } });
  assert.equal(r.status, 5, r.stderr);
  assert.ok(!r.stdout.includes("systemd-run"), "no second unit was started");
  assert.equal(fs.readFileSync(path.join(udir, "axiom-pkg-job.log"), "utf8"), "installing foo...\n", "the running job's log is untouched");
});

test("after a cancel the helper removes a stale pacman lock, but only when no pacman is running", () => {
  const mk = (pgrepRc) => {
    const cdir = fs.mkdtempSync(path.join(os.tmpdir(), "pkgd-lck-"));
    fs.writeFileSync(path.join(cdir, "id"), "#!/bin/sh\necho 0\n", { mode: 0o755 });
    fs.writeFileSync(path.join(cdir, "logger"), "#!/bin/sh\n", { mode: 0o755 });
    fs.writeFileSync(path.join(cdir, "systemctl"), '#!/bin/sh\ncase "$1" in is-active) exit 0;; stop) exit 0;; esac\n', { mode: 0o755 });
    fs.writeFileSync(path.join(cdir, "pgrep"), `#!/bin/sh\nexit ${pgrepRc}\n`, { mode: 0o755 });
    fs.writeFileSync(path.join(cdir, "axiom-pkg-job.log"), ":: Retrieving packages...\n");
    const lck = path.join(cdir, "db.lck");
    fs.writeFileSync(lck, "");
    return { lck, env: { PATH: `${cdir}:/usr/bin:/bin`, AXIOM_PKGD_RUNDIR: cdir, AXIOM_PKGD_DBLOCK: lck } };
  };
  const none = mk(1); // pgrep finds nothing
  assert.equal(spawnSync("sh", [helper, "cancel"], { encoding: "utf8", env: none.env }).status, 0);
  assert.equal(fs.existsSync(none.lck), false, "stale lock removed");
  const some = mk(0); // a pacman is running
  assert.equal(spawnSync("sh", [helper, "cancel"], { encoding: "utf8", env: some.env }).status, 0);
  assert.equal(fs.existsSync(some.lck), true, "a lock in use is left alone");
});
