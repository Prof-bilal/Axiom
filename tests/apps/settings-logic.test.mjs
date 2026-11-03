// Unit tests for apps/settings/settings.js. Run: node --test tests/apps/
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import vm from "node:vm";
import { fileURLToPath } from "node:url";
import path from "node:path";

const here = path.dirname(fileURLToPath(import.meta.url));
const src = fs.readFileSync(path.join(here, "../../apps/settings/settings.js"), "utf8")
  .replace(/^\.pragma library\s*$/m, "");
const L = {};
vm.runInNewContext(src, L);
const eq = (a, b, m = "values differ") => assert.equal(JSON.stringify(a), JSON.stringify(b), m);

test("parseMime reads the default and registered applications", () => {
  const t = 'Default application for “text/plain”: org.xfce.mousepad.desktop\nRegistered applications:\n\torg.xfce.mousepad.desktop\n\tcode-oss.desktop\nRecommended applications:\n\torg.xfce.mousepad.desktop\n\tvim.desktop\n';
  const m = L.parseMime(t);
  assert.equal(m.defaultId, "org.xfce.mousepad.desktop");
  eq(m.registered, ["org.xfce.mousepad.desktop", "code-oss.desktop", "vim.desktop"]);
});

test("parseMime with no default and with ASCII quotes", () => {
  const none = L.parseMime('No default applications for "image/x-foo"\n');
  assert.equal(none.defaultId, ""); eq(none.registered, []);
  assert.equal(L.parseMime('Default application for "inode/directory": pcmanfm.desktop\n').defaultId, "pcmanfm.desktop");
  eq(L.parseMime(""), { defaultId: "", registered: [] });
});

test("entryId", () => { assert.equal(L.entryId("org.xfce.mousepad.desktop"), "org.xfce.mousepad"); assert.equal(L.entryId("foo"), "foo"); });

test("dock pin editing never mutates its input and ignores bad indexes", () => {
  const p = ["a", "b", "c"];
  eq(L.movePin(p, 1, -1), ["b", "a", "c"]); eq(L.movePin(p, 1, 1), ["a", "c", "b"]);
  eq(L.movePin(p, 0, -1), ["a", "b", "c"]); eq(L.movePin(p, 2, 1), ["a", "b", "c"]); eq(L.movePin(p, 9, 1), ["a", "b", "c"]);
  eq(L.removePin(p, 1), ["a", "c"]); eq(L.removePin(p, 5), ["a", "b", "c"]);
  eq(L.addPin(p, "d"), ["a", "b", "c", "d"]); eq(L.addPin(p, "b"), ["a", "b", "c"]); eq(L.addPin(p, ""), ["a", "b", "c"]);
  eq(p, ["a", "b", "c"]);
});

test("wallpaper helpers", () => {
  assert.equal(L.isImageName("a.PNG"), true); assert.equal(L.isImageName("a.jpeg"), true);
  assert.equal(L.isImageName("a.txt"), false); assert.equal(L.isImageName(".png"), false); assert.equal(L.isImageName("png"), false);
  assert.equal(L.label("/home/x/Pictures/My Photo.jpg"), "My Photo");
  eq(L.parseImagePaths("/p/b.png\n/p/a.JPG\n/p/c.txt\nrelative.png\n\n"), ["/p/a.JPG", "/p/b.png"]);
});

test("system info parsing and formatting", () => {
  assert.equal(L.parseCpuModel("processor : 0\nmodel name\t: AMD Ryzen 7   5800X 8-Core\n"), "AMD Ryzen 7 5800X 8-Core");
  assert.equal(L.parseCpuModel("nothing"), "");
  assert.equal(L.parseMemTotalKb("MemTotal:        2046204 kB\nMemFree: 1 kB"), 2046204);
  assert.equal(L.parseMemTotalKb(""), 0);
  assert.equal(L.formatKb(2046204), "2.0 GiB"); assert.equal(L.formatKb(16777216), "16 GiB"); assert.equal(L.formatKb(512000), "500 MiB"); assert.equal(L.formatKb(0), "");
  assert.equal(L.firstLine("labwc 0.20.2\nextra"), "labwc 0.20.2");
  assert.equal(L.shortVersion("quickshell 0.3.2, revision abc, distributed by Arch Linux"), "quickshell 0.3.2");
  assert.equal(L.shortVersion("labwc 0.20.2 (+xwayland +nls)\nwlroots"), "labwc 0.20.2");
  assert.equal(L.shortVersion(""), "");
});
