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

test("rollback needs a numeric snapshot id", () => {
  assert.equal(srun("rollback", "12").stdout.trim(), "snapper -c root --ambit classic rollback 12");
  for (const bad of ["", "1;2", "x", "-1"]) assert.equal(srun("rollback", bad).status, 2, JSON.stringify(bad));
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
