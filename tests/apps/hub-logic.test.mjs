// Unit tests for apps/hub/catalog.js and rules.js. Run: node --test tests/apps/
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const load = (f) => fs.readFileSync(path.join(here, "../../apps/hub", f), "utf8").replace(/^\.pragma library\s*$/m, "");
const R = new Function(load("catalog.js") + load("rules.js") + "; return { CATALOG, CATEGORIES, categoryCounts, byCategory, search, find, fit, lighterOption, suggestions, formatSize, sourceLabel, metaLine };")();

test("every catalog entry has the required fields and a real source", () => {
  const ids = new Set();
  for (const a of R.CATALOG) {
    for (const k of ["id", "name", "category", "summary", "publisher", "license", "sources", "weight"]) assert.ok(a[k], `${a.id}: ${k}`);
    assert.ok(R.CATEGORIES.includes(a.category), `${a.id}: category`);
    assert.ok(["light", "medium", "heavy"].includes(a.weight), `${a.id}: weight`);
    assert.ok(a.sources.length > 0 && a.sources.every((s) => s.type && s.ref), `${a.id}: sources`);
    assert.ok(!ids.has(a.id), `duplicate id ${a.id}`);
    ids.add(a.id);
    if (a.light_alt) assert.ok(R.find(R.CATALOG, a.light_alt), `${a.id}: light_alt missing`);
  }
});

test("every category has at least one app and counts add up", () => {
  const counts = R.categoryCounts(R.CATALOG);
  for (const c of R.CATEGORIES) assert.ok(counts[c] > 0, c);
  assert.equal(Object.values(counts).reduce((a, b) => a + b, 0), R.CATALOG.length);
});

test("search matches name and summary, case-insensitively", () => {
  assert.equal(R.search(R.CATALOG, "firefox")[0].id, "firefox");
  assert.ok(R.search(R.CATALOG, "TERMINAL").length >= 2);
  assert.equal(R.search(R.CATALOG, "  ").length, R.CATALOG.length);
  assert.equal(R.search(R.CATALOG, "zzzz-none").length, 0);
});

test("fit rules: 16 GB fits, 4 GB is tight, 2 GB is too heavy for a 4 GB app", () => {
  const app = { min_ram_gb: 4, size_mb: null };
  assert.equal(R.fit(app, { ramGb: 16, freeDiskGb: 100 }).level, "fits");
  assert.equal(R.fit(app, { ramGb: 6, freeDiskGb: 100 }).level, "tight");
  assert.equal(R.fit(app, { ramGb: 2, freeDiskGb: 100 }).level, "too heavy");
});

test("fit never guesses: no memory figure means unknown", () => {
  assert.equal(R.fit({ min_ram_gb: null }, { ramGb: 1, freeDiskGb: 1 }).level, "unknown");
});

test("low free disk is reported", () => {
  assert.equal(R.fit({ min_ram_gb: 1, size_mb: 455 }, { ramGb: 16, freeDiskGb: 0.5 }).level, "low disk");
});

test("lighter option appears only for heavy apps whose alternative fits", () => {
  const vs = R.find(R.CATALOG, "vscode");
  assert.equal(R.lighterOption(R.CATALOG, vs, { ramGb: 8, freeDiskGb: 50 }).id, "zed");
  assert.equal(R.lighterOption(R.CATALOG, R.find(R.CATALOG, "neovim"), { ramGb: 8, freeDiskGb: 50 }), null);
});

test("suggestions skip apps that are too heavy for the machine", () => {
  const small = R.suggestions(R.CATALOG, { ramGb: 2, freeDiskGb: 50 }, 10).map((a) => a.id);
  assert.ok(!small.includes("vscode"));
  assert.ok(R.suggestions(R.CATALOG, { ramGb: 16, freeDiskGb: 50 }, 10).length > 0);
});

test("size and source labels", () => {
  assert.equal(R.formatSize(null), "");
  assert.equal(R.formatSize(312), "312 MB");
  assert.equal(R.formatSize(2048), "2.0 GB");
  assert.equal(R.sourceLabel(R.find(R.CATALOG, "firefox")), "Flatpak");
  assert.equal(R.metaLine(R.find(R.CATALOG, "firefox")), "Flatpak");
  assert.equal(R.metaLine(R.find(R.CATALOG, "wireshark")), "Flatpak · 54 MB");
});

test("bundled icons are real PNG files, and most apps have one (letter tile otherwise)", () => {
  const dir = path.join(here, "../../apps/hub/icons");
  const files = fs.readdirSync(dir).filter((f) => f.endsWith(".png"));
  for (const f of files) assert.deepEqual([...fs.readFileSync(path.join(dir, f)).subarray(0, 4)], [0x89, 0x50, 0x4e, 0x47], f);
  assert.ok(files.length >= 40, `only ${files.length} icons`);
});
