// Unit tests for shell/src/dock/magnify.js. Run: node --test tests/shell/
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import vm from "node:vm";
import { fileURLToPath } from "node:url";
import path from "node:path";

const here = path.dirname(fileURLToPath(import.meta.url));
const src = fs.readFileSync(path.join(here, "../../shell/src/dock/magnify.js"), "utf8").replace(/^\.pragma library\s*$/m, "");
const M = {};
vm.runInNewContext(src, M);

const P = { peak: 1.65, reach: 208 };
const SLOT = { w: 76, grow: true };
// launcher, 3 pinned, a 9px separator, 2 running: the real dock's shape.
const REST = [SLOT, SLOT, SLOT, SLOT, { w: 9, grow: false }, SLOT, SLOT];
const GAP = 4;
const near = (a, b, eps = 1e-6) => assert.ok(Math.abs(a - b) <= eps, `${a} != ${b}`);
// Screen x of the rest point u after widening (the inverse the layout must keep at the pointer).
function restToScreen(l, u) {
  let x = 0;
  for (let i = 0; i < REST.length; i++) {
    if (u < x) return l.xs[i] - (x - u); // in the fixed gap before slot i
    const end = x + REST[i].w;
    if (u <= end) return l.xs[i] + (u - x) * l.scales[i];
    x = end + GAP;
  }
  return l.xs[REST.length - 1] + l.widths[REST.length - 1] + (u - (x - GAP));
}

test("with no hover (strength 0) the dock is exactly its rest layout", () => {
  const l = M.layout(REST, GAP, 100, 300, 0, P);
  l.scales.forEach((s) => assert.equal(s, 1));
  near(l.origin, 100);
  near(l.total, l.restTotal);
  near(l.xs[1], 100 + 76 + GAP);
});

test("the slot under the pointer grows most, symmetrically falling off with distance", () => {
  const l = M.layout(REST, GAP, 0, 2 * (76 + GAP) + 38, 1, P); // centre of slot 2
  near(l.scales[2], P.peak);
  assert.ok(l.scales[1] < l.scales[2] && l.scales[3] < l.scales[2]);
  near(l.scales[1], l.scales[3], 1e-9);
  assert.ok(l.scales[0] < l.scales[1]);
  assert.equal(l.scales[4], 1, "the separator never grows");
});

test("slots farther than the reach do not grow", () => {
  const l = M.layout(REST, GAP, 0, 38, 1, { peak: 1.65, reach: 100 });
  assert.equal(l.scales[3], 1);
  assert.equal(l.scales[5], 1);
});

test("strength scales the growth smoothly between rest and full", () => {
  const full = M.layout(REST, GAP, 0, 118, 1, P).scales[1];
  near(M.layout(REST, GAP, 0, 118, 0.5, P).scales[1], 1 + (full - 1) / 2);
});

test("the icon under the cursor never slides away: the rest point under the pointer stays under it", () => {
  const total = M.layout(REST, GAP, 0, 0, 0, P).restTotal;
  for (let px = 0; px <= total; px += 7) {
    const l = M.layout(REST, GAP, 0, px, 1, P);
    near(restToScreen(l, px), px, 1e-6);
  }
});

test("the widened row stays inside the room reserved by bounds()", () => {
  const b = M.bounds(REST, GAP, P);
  const total = M.layout(REST, GAP, 0, 0, 0, P).restTotal;
  for (let px = -P.reach; px <= total + P.reach; px += 3) {
    const l = M.layout(REST, GAP, 0, px, 1, P);
    assert.ok(l.xs[0] >= -b.before - 1, `left edge at ${l.xs[0]} for px ${px}`);
    const end = l.xs[REST.length - 1] + l.widths[REST.length - 1];
    assert.ok(end <= total + b.after + 1, `right edge at ${end} for px ${px}`);
  }
  assert.ok(b.before > 0 && b.after > 0 && b.before < 400 && b.after < 400, JSON.stringify(b));
});

test("slots never overlap and keep their gaps", () => {
  for (let px = 0; px <= 520; px += 11) {
    const l = M.layout(REST, GAP, 0, px, 1, P);
    for (let i = 0; i + 1 < REST.length; i++) near(l.xs[i + 1] - (l.xs[i] + l.widths[i]), GAP, 1e-6);
  }
});

test("an empty dock and a single slot do not crash", () => {
  const e = M.layout([], GAP, 0, 50, 1, P);
  assert.equal(e.total, 0);
  eq0(M.bounds([], GAP, P));
  const one = M.layout([SLOT], GAP, 0, 38, 1, P);
  near(one.scales[0], P.peak);
  near(restToScreen1(one, 38), 38);
});
function eq0(b) { assert.equal(JSON.stringify(b), JSON.stringify({ before: 0, after: 0 })); }
function restToScreen1(l, u) { return l.xs[0] + u * l.scales[0]; }

test("a pointer far left or right of the dock leaves it at rest", () => {
  for (const px of [-1000, 5000]) {
    const l = M.layout(REST, GAP, 0, px, 1, P);
    l.scales.forEach((s) => assert.equal(s, 1));
    near(l.origin, 0);
  }
});
