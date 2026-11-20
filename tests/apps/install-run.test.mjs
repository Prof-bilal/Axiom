// Tests for system/installer/axiom-install-run. The live-medium marker and the backend path are swapped
// for temp paths, because the real ones need root and an archiso boot.
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const real = fs.readFileSync(path.join(here, "../../system/installer/axiom-install-run"), "utf8");
const dir = fs.mkdtempSync(path.join(os.tmpdir(), "install-run-"));
const marker = path.join(dir, "archiso");
const backend = path.join(dir, "backend.py");
fs.writeFileSync(backend, "import sys\nprint('ran', sys.stdin.readline().strip())\n");
fs.writeFileSync(path.join(dir, "id"), "#!/bin/sh\necho ${FAKE_UID:-0}\n", { mode: 0o755 });
const script = path.join(dir, "helper");
fs.writeFileSync(script, real.replace("/run/archiso", marker).replace("/usr/local/lib/axiom-installer/axiom_install.py", backend), { mode: 0o755 });
const run = (args = [], env = {}, input = "") =>
  spawnSync("sh", [script, ...args], { encoding: "utf8", input, env: { PATH: `${dir}:/usr/bin:/bin`, ...env } });

test("the helper really refers to the markers the test swaps", () => {
  assert.ok(real.includes("/run/archiso") && real.includes("/usr/local/lib/axiom-installer/axiom_install.py"));
});

test("it refuses an installed system (no live marker)", () => {
  const r = run([], {}, "{}\n");
  assert.equal(r.status, 3);
  assert.match(r.stderr, /live medium/);
});

test("it refuses when not root", () => {
  fs.mkdirSync(marker, { recursive: true });
  assert.equal(run([], { FAKE_UID: "1000" }, "{}\n").status, 1);
});

test("it takes no arguments, so the caller cannot steer it", () => {
  assert.equal(run(["--list-disks"], {}, "{}\n").status, 2);
  assert.equal(run(["; id"], {}, "{}\n").status, 2);
});

test("on the live medium as root it hands the one-line form to the backend", () => {
  const r = run([], {}, '{"a":1}\n');
  assert.equal(r.status, 0);
  assert.equal(r.stdout.trim(), 'ran {"a":1}');
});
