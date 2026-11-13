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
  assert.equal(run("sync", "neovim").stdout.trim(), "pacman -S --noconfirm --needed -- neovim");
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
