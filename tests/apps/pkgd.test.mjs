// Tests for system/pkgd/axiom-pkgd with stubbed `id` and `pacman`, so no real root is needed.
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const helper = path.join(here, "../../system/pkgd/axiom-pkgd");
const dir = fs.mkdtempSync(path.join(os.tmpdir(), "pkgd-"));
fs.writeFileSync(path.join(dir, "id"), "#!/bin/sh\necho 0\n", { mode: 0o755 });
fs.writeFileSync(path.join(dir, "pacman"), '#!/bin/sh\necho "pacman $*"\n', { mode: 0o755 });
const live = fs.mkdtempSync(path.join(os.tmpdir(), "pkgd-live-"));
const run = (...args) => spawnSync("sh", [helper, ...args], { encoding: "utf8", env: { PATH: `${dir}:/usr/bin:/bin`, AXIOM_PKGD_LIVE_DIR: live } });

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
const srun = (...args) => spawnSync("sh", [helper, ...args], { encoding: "utf8", env: { PATH: `${sdir}:/usr/bin:/bin`, AXIOM_PKGD_VIA: "wrapper" } });

test("update takes a snapshot before the full upgrade", () => {
  const r = srun("update");
  assert.equal(r.status, 0);
  assert.equal(r.stderr.trim().split("\n")[0], "snapper -c root create --type single --description before update --print-number");
  assert.equal(r.stdout.trim(), "pacman -Syu --noconfirm");
});

test("installed sync snapshots first and never does a partial upgrade", () => {
  const r = spawnSync("sh", [helper, "sync", "neovim"], { encoding: "utf8", env: { PATH: `${sdir}:/usr/bin:/bin`, AXIOM_PKGD_LIVE_DIR: "/nonexistent" } });
  assert.equal(r.status, 0);
  const lines = r.stdout.trim().split("\n");
  assert.equal(lines[0], "snapper -c root create --type single --description before sync");
  assert.equal(lines[1], "pacman -Syu --noconfirm --needed -- neovim");
});

test("installed remove snapshots first and refuses without snapper", () => {
  const env = { PATH: `${sdir}:/usr/bin:/bin`, AXIOM_PKGD_LIVE_DIR: "/nonexistent" };
  const r = spawnSync("sh", [helper, "remove", "neovim"], { encoding: "utf8", env });
  assert.equal(r.stdout.trim().split("\n")[0], "snapper -c root create --type single --description before remove");
  const nodir = fs.mkdtempSync(path.join(os.tmpdir(), "pkgd-nosnap2-"));
  fs.writeFileSync(path.join(nodir, "id"), "#!/bin/sh\necho 0\n", { mode: 0o755 });
  fs.writeFileSync(path.join(nodir, "pacman"), '#!/bin/sh\necho "pacman $*"\n', { mode: 0o755 });
  const n = spawnSync("/bin/sh", [helper, "remove", "neovim"], { encoding: "utf8", env: { PATH: nodir, AXIOM_PKGD_LIVE_DIR: "/nonexistent" } });
  assert.equal(n.status, 3);
  assert.ok(!n.stdout.includes("pacman"));
});

test("a failed update deletes the snapshot it just took", () => {
  const fdir = fs.mkdtempSync(path.join(os.tmpdir(), "pkgd-fail-"));
  fs.writeFileSync(path.join(fdir, "id"), "#!/bin/sh\necho 0\n", { mode: 0o755 });
  fs.writeFileSync(path.join(fdir, "pacman"), "#!/bin/sh\nexit 1\n", { mode: 0o755 });
  fs.writeFileSync(path.join(fdir, "snapper"), '#!/bin/sh\ncase "$*" in *print-number*) echo 42;; *) echo "snapper $*";; esac\n', { mode: 0o755 });
  const r = spawnSync("sh", [helper, "update"], { encoding: "utf8", env: { PATH: `${fdir}:/usr/bin:/bin`, AXIOM_PKGD_VIA: "wrapper" } });
  assert.equal(r.status, 1);
  assert.ok(r.stdout.includes("snapper -c root delete 42"));
});

const fakeSync = path.join(sdir, "boot-sync");
fs.writeFileSync(fakeSync, '#!/bin/sh\necho "boot-sync $*"\n', { mode: 0o755 });
const rrun = (...args) => spawnSync("sh", [helper, ...args], { encoding: "utf8", env: { PATH: `${sdir}:/usr/bin:/bin`, AXIOM_PKGD_VIA: "wrapper", AXIOM_BOOT_SYNC: fakeSync } });

test("rollback syncs the boot files after snapper succeeds", () => {
  assert.equal(rrun("rollback", "12").stdout.trim(), "snapper -c root --ambit classic rollback 12\nboot-sync 12");
});

test("a failed boot sync after rollback is reported, not hidden", () => {
  const bad = path.join(sdir, "boot-sync-bad");
  fs.writeFileSync(bad, "#!/bin/sh\nexit 1\n", { mode: 0o755 });
  const r = spawnSync("sh", [helper, "rollback", "12"], { encoding: "utf8", env: { PATH: `${sdir}:/usr/bin:/bin`, AXIOM_PKGD_VIA: "wrapper", AXIOM_BOOT_SYNC: bad } });
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
  const r = spawnSync("/bin/sh", [helper, "update"], { encoding: "utf8", env: { PATH: nodir, AXIOM_PKGD_VIA: "wrapper" } });
  assert.equal(r.status, 3);
  assert.ok(!r.stdout.includes("pacman"));
});

test("update and rollback refuse a direct call (only their own polkit action reaches them)", () => {
  const direct = (...a) => spawnSync("sh", [helper, ...a], { encoding: "utf8", env: { PATH: `${sdir}:/usr/bin:/bin` } });
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
  const r = spawnSync("sh", [helper, "install", pkg], { encoding: "utf8", env: { PATH: `${idir}:/usr/bin:/bin`, AXIOM_PKGD_TMP: idir } });
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
  const run = (n, extra = {}) => spawnSync("sh", [syncHelper, n], { encoding: "utf8", env: { PATH: `${bin}:/usr/bin:/bin`, AXIOM_BOOT_SNAPSHOTS: snaps, AXIOM_BOOT_DIR: boot, ...extra } });
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
