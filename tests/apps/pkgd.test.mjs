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
const run = (...args) => spawnSync("sh", [helper, ...args], { encoding: "utf8", env: { PATH: `${dir}:/usr/bin:/bin` } });

test("sync and remove reach pacman with fixed flags", () => {
  assert.equal(run("sync", "neovim").stdout.trim(), "pacman -Sy --noconfirm --needed -- neovim");
  assert.equal(run("remove", "neovim").stdout.trim(), "pacman -Rns --noconfirm -- neovim");
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
fs.writeFileSync(path.join(sdir, "snapper"), '#!/bin/sh\necho "snapper $*"\n', { mode: 0o755 });
const srun = (...args) => spawnSync("sh", [helper, ...args], { encoding: "utf8", env: { PATH: `${sdir}:/usr/bin:/bin` } });

test("update takes a snapshot before the full upgrade", () => {
  const r = srun("update");
  assert.equal(r.status, 0);
  const lines = r.stdout.trim().split("\n");
  assert.equal(lines[0], "snapper -c root create --type single --description before update");
  assert.equal(lines[1], "pacman -Syu --noconfirm");
});

test("rollback needs a numeric snapshot id", () => {
  assert.equal(srun("rollback", "12").stdout.trim(), "snapper -c root rollback 12");
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
  const r = spawnSync("/bin/sh", [helper, "update"], { encoding: "utf8", env: { PATH: nodir } });
  assert.equal(r.status, 3);
  assert.ok(!r.stdout.includes("pacman"));
});
