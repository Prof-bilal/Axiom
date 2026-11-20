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

const ZONE_TAB = "# comment\nPK\t+2452+06703\tAsia/Karachi\nAR\t-3436-05827\tAmerica/Argentina/Buenos_Aires\tBuenos Aires (BA, CF)\nDE\t+5230+01322\tEurope/Berlin\tGermany (most areas)\nXX\tbroken\tNowhere/Land\nUS\t+404251-0740023\tAmerica/New_York\tEastern\n";
const COUNTRIES = "# iso\nPK\tPakistan\nAR\tArgentina\nDE\tGermany\nUS\tUnited States\n";

test("zone.tab coordinates become decimal degrees, east and north positive", () => {
  const t = L.parseZoneTab(ZONE_TAB, L.parseCountries(COUNTRIES));
  const k = t["Asia/Karachi"];
  assert.ok(Math.abs(k.lat - 24.8667) < 0.001 && Math.abs(k.lon - 67.05) < 0.001);
  assert.equal(k.country, "Pakistan");
  const b = t["America/Argentina/Buenos_Aires"];
  assert.ok(b.lat < 0 && b.lon < 0, "south and west are negative");
  assert.ok(Math.abs(t["America/New_York"].lat - 40.7142) < 0.001, "the seconds form is read");
});

test("lines that are comments or malformed are skipped, not fatal", () => {
  const t = L.parseZoneTab(ZONE_TAB, L.parseCountries(COUNTRIES));
  assert.equal("Nowhere/Land" in t, false);
  assert.equal(Object.keys(t).length, 4);
  eq(L.parseZoneTab("", {}), {});
});

test("pin label names the city and the country", () => {
  const t = L.parseZoneTab(ZONE_TAB, L.parseCountries(COUNTRIES));
  assert.equal(L.pinLabel("Asia/Karachi", t), "Karachi, Pakistan");
  assert.equal(L.pinLabel("America/Argentina/Buenos_Aires", t), "Buenos Aires, Argentina");
  assert.equal(L.pinLabel("UTC", t), "", "UTC is not a place");
});

test("an unknown country code falls back to the code", () => {
  assert.equal(L.parseZoneTab("ZZ\t+0000+00000\tX/Y\n", {})["X/Y"].country, "ZZ");
});

// Real zone.tab rows. The map is only useful if a city's pin lands inside its own country's outline.
const CITIES = {
  "Asia/Karachi": ["PK", "+2452+06703"], "Europe/London": ["GB", "+513030-0000731"], "America/New_York": ["US", "+404251-0740023"],
  "America/Los_Angeles": ["US", "+340308-1181434"], "Asia/Tokyo": ["JP", "+353916+1394441"], "Australia/Sydney": ["AU", "-3352+15113"],
  "Africa/Cairo": ["EG", "+3003+03115"], "Africa/Lagos": ["NG", "+0627+00324"], "America/Sao_Paulo": ["BR", "-2332-04637"],
  "Europe/Moscow": ["RU", "+554521+0373704"], "Asia/Kolkata": ["IN", "+2232+08822"], "Asia/Shanghai": ["CN", "+3114+12128"],
  "America/Mexico_City": ["MX", "+1924-09909"], "Africa/Johannesburg": ["ZA", "-2615+02800"], "Europe/Berlin": ["DE", "+5230+01322"],
  "Europe/Paris": ["FR", "+4852+00220"], "Asia/Jakarta": ["ID", "-0610+10648"], "Pacific/Auckland": ["NZ", "-3652+17446"],
  "Atlantic/Reykjavik": ["IS", "+6409-02151"], "Asia/Dubai": ["AE", "+2518+05518"], "Europe/Istanbul": ["TR", "+4101+02858"],
  "America/Argentina/Buenos_Aires": ["AR", "-3436-05827"], "America/Toronto": ["CA", "+4339-07923"], "Asia/Dhaka": ["BD", "+2343+09025"],
  "Asia/Kabul": ["AF", "+3431+06912"], "Asia/Tehran": ["IR", "+3540+05126"], "Asia/Riyadh": ["SA", "+2438+04643"],
  "Asia/Kathmandu": ["NP", "+2743+08519"], "Asia/Colombo": ["LK", "+0656+07951"], "Europe/Oslo": ["NO", "+5955+01045"],
};
const map = {};
vm.runInNewContext(fs.readFileSync(path.join(here, "../../apps/liveinstaller/worldmap.js"), "utf8").replace(/^\.pragma library\s*$/m, ""), map);
const rings = (cc) => (map.SHAPES.find((s) => s[0] === cc) || [, []])[1].map((flat) => {
  const r = []; for (let i = 0; i < flat.length; i += 2) r.push([flat[i] / map.Q, flat[i + 1] / map.Q]); return r; });
const within = (x, y, r) => { let c = false; for (let i = 0, j = r.length - 1; i < r.length; j = i++) {
  if ((r[i][1] > y) !== (r[j][1] > y) && x < (r[j][0] - r[i][0]) * (y - r[i][1]) / (r[j][1] - r[i][1]) + r[i][0]) c = !c; } return c; };
const edge = (x, y, r) => Math.min(...r.map((a, i) => { const b = r[(i + 1) % r.length]; const dx = b[0] - a[0], dy = b[1] - a[1];
  const t = dx === 0 && dy === 0 ? 0 : Math.max(0, Math.min(1, ((x - a[0]) * dx + (y - a[1]) * dy) / (dx * dx + dy * dy)));
  return Math.hypot(x - (a[0] + t * dx), y - (a[1] + t * dy)); }));

test("every test city's pin lands inside its own country (or within 0.5 degrees of the coast)", () => {
  for (const [zone, [cc, c]] of Object.entries(CITIES)) {
    const p = L.parseCoords(c);
    const rs = rings(cc);
    assert.ok(rs.length > 0, `${cc} has an outline`);
    const ok = rs.some((r) => within(p.lon, p.lat, r)) || Math.min(...rs.map((r) => edge(p.lon, p.lat, r))) <= 0.5;
    assert.ok(ok, `${zone} (${p.lat.toFixed(2)}, ${p.lon.toFixed(2)}) is outside ${cc}`);
  }
});

test("Karachi is strictly inside Pakistan and not inside India", () => {
  const p = L.parseCoords(CITIES["Asia/Karachi"][1]);
  assert.ok(rings("PK").some((r) => within(p.lon, p.lat, r)));
  assert.equal(rings("IN").some((r) => within(p.lon, p.lat, r)), false);
});

test("outlines are sane: France and Norway exist, nothing wraps the date line, all points are on the map", () => {
  assert.ok(rings("FR").length > 0 && rings("NO").length > 0, "ISO_A2_EH fixes the -99 codes");
  for (const [cc, rs] of map.SHAPES) for (const flat of rs) {
    assert.equal(flat.length % 2, 0, cc);
    const xs = flat.filter((_, i) => i % 2 === 0), ys = flat.filter((_, i) => i % 2 === 1);
    assert.ok(Math.max(...xs) - Math.min(...xs) <= 1800, `${cc} wraps the date line`);
    assert.ok(Math.min(...xs) >= -1800 && Math.max(...xs) <= 1800, cc);
    assert.ok(Math.max(...ys) <= map.LAT_TOP * map.Q && Math.min(...ys) >= map.LAT_BOTTOM * map.Q, cc);
  }
});
