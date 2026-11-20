// Unit tests for apps/liveinstaller/installer.js. Run: node --test tests/apps/
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import vm from "node:vm";
import { fileURLToPath } from "node:url";
import path from "node:path";

const here = path.dirname(fileURLToPath(import.meta.url));
const src = fs.readFileSync(path.join(here, "../../apps/liveinstaller/installer.js"), "utf8")
  .replace(/^\.pragma library\s*$/m, "");
const L = {};
vm.runInNewContext(src, L);
const eq = (a, b, m) => assert.equal(JSON.stringify(a), JSON.stringify(b), m);

test("time zones group by region and UTC stays flat", () => {
  const g = L.tzGroups("Europe/Berlin\nAsia/Karachi\nEurope/Amsterdam\nUTC\n");
  eq(g.Europe, ["Amsterdam", "Berlin"]);
  eq(g.UTC, ["UTC"]);
  eq(L.tzName("Europe", "Berlin"), "Europe/Berlin");
  eq(L.tzName("UTC", "UTC"), "UTC");
});

test("an empty zone list still leaves one valid choice", () => {
  eq(L.tzGroups("").UTC, ["UTC"]);
});

test("choosers wrap around in both directions and survive an unknown value", () => {
  eq(L.cycle(["a", "b", "c"], "c", 1), "a");
  eq(L.cycle(["a", "b", "c"], "a", -1), "c");
  eq(L.cycle(["a", "b", "c"], "zzz", 1), "b");
  eq(L.cycle([], "x", 1), "x");
});

test("probe fills only the fields a page does not own", () => {
  const p = L.probe({ username: "", fullname: "", hostname: "", password: "", timezone: "UTC", keyboard: "us", locale: "en_US", git_name: "", git_email: "" });
  assert.equal(p.username, "probe");
  assert.equal(p.hostname, "axiom");
  assert.ok(p.password.length >= 10);
  assert.equal(L.probe({ username: "dev", fullname: "D", hostname: "h", password: "x" }).username, "dev");
});

test("the payload sent to the root helper has the disk and never the repeat password", () => {
  const f = { username: "dev", fullname: "Dev", hostname: "axiom", password: "pw-pw-pw-pw-1", password2: "pw-pw-pw-pw-1",
    timezone: "UTC", keyboard: "us", locale: "en_US", git_name: "", git_email: "", luks: false, luks_passphrase: "left-over" };
  const p = L.payload(f, { path: "/dev/vda", size: 123 });
  assert.equal(p.disk, "/dev/vda");
  assert.equal(p.disk_bytes, 123);
  assert.equal("password2" in p, false);
  assert.equal(p.luks_passphrase, "", "an old passphrase is dropped when encryption is off");
});

test("progress events only move forward and bad lines change nothing", () => {
  let s = L.initialProgress();
  s = L.reduce(s, JSON.stringify({ event: "progress", pct: 40, stage: "Downloading Axiom", detail: "1 MiB", eta_min: 9 }));
  assert.equal(s.pct, 40);
  assert.equal(s.eta, 9);
  s = L.reduce(s, JSON.stringify({ event: "progress", pct: 12, stage: "Downloading Axiom" }));
  assert.equal(s.pct, 40, "never goes backwards");
  const before = JSON.stringify(s);
  assert.equal(JSON.stringify(L.reduce(s, "not json")), before);
  assert.equal(JSON.stringify(L.reduce(s, "42")), before);
  s = L.reduce(s, JSON.stringify({ event: "error", message: "boom" }));
  assert.equal(s.message, "boom");
  s = L.reduce(s, JSON.stringify({ event: "done" }));
  assert.equal(s.pct, 100);
  assert.equal(s.done, true);
});

test("backend stage names map to the four visible stages", () => {
  eq(L.STAGES.map(L.stageIndex), [0, 1, 2, 3]);
  assert.equal(L.stageIndex("Adding the Axiom desktop"), 3);
  assert.equal(L.stageIndex("something new"), 0);
});

test("a disk label shows size in whole gigabytes", () => {
  assert.equal(L.diskLabel({ path: "/dev/vda", size: 25769803776, model: "QEMU" }), "/dev/vda   24 GB   QEMU");
});

test("every page maps to a sidebar step", () => {
  assert.equal(L.PAGES.length, L.PAGE_STEP.length);
  assert.ok(Math.max(...L.PAGE_STEP) < L.STEPS.length);
});
