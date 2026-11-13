// Unit tests for apps/appinstaller/installfile.js (Phase 7a logic).
import { readFileSync } from "node:fs";
import assert from "node:assert/strict";
import test from "node:test";

const src = readFileSync(new URL("../../apps/appinstaller/installfile.js", import.meta.url), "utf8")
  .replace(/^\.pragma library/m, "");
const lib = new Function(src + "; return { classify, appImageTarget, formatSize, quoteExec, desktopEntry, flatpakArgv };")();

test("classifies AppImage, Flatpak and Arch packages", () => {
  assert.equal(lib.classify("Foo-x86_64.AppImage").kind, "appimage");
  assert.equal(lib.classify("app.flatpakref").kind, "flatpak");
  assert.equal(lib.classify("app.flatpak").kind, "flatpak");
  assert.equal(lib.classify("pkg-1.0-1-x86_64.pkg.tar.zst").kind, "arch");
});

test("unknown types return null", () => {
  assert.equal(lib.classify("notes.txt"), null);
  assert.equal(lib.classify("setup.deb"), null);
  assert.equal(lib.classify(""), null);
});

test("Arch packages need root; AppImage does not", () => {
  const c = lib.classify("x.pkg.tar.zst");
  assert.equal(c.root, true);
  assert.equal(lib.classify("a.AppImage").root, false);
});

test("AppImage target stays inside ~/Applications and strips path parts", () => {
  assert.equal(lib.appImageTarget("/home/u/", "../../etc/x y.AppImage"), "/home/u/Applications/x_y.AppImage");
  assert.equal(lib.appImageTarget("/home/u", "Tool 1.AppImage"), "/home/u/Applications/Tool_1.AppImage");
});

test("formats sizes", () => {
  assert.equal(lib.formatSize(512), "512 B");
  assert.equal(lib.formatSize(2048), "2.0 KB");
  assert.equal(lib.formatSize(5 * 1024 * 1024), "5.0 MB");
  assert.equal(lib.formatSize(-1), "unknown size");
});

test("quotes Exec paths with spaces and shell specials", () => {
  assert.equal(lib.quoteExec("/home/u/Applications/My App.AppImage"), '"/home/u/Applications/My App.AppImage"');
  assert.equal(lib.quoteExec('/x/$a"b`c\\d'), '"/x/\\$a\\"b\\`c\\\\d"');
});

test("builds a desktop entry with one Exec line", () => {
  const d = lib.desktopEntry("Tool\nX", "/home/u/Applications/t.AppImage");
  assert.match(d, /^\[Desktop Entry\]\nType=Application\nName=Tool X\n/);
  assert.ok(d.includes('Exec="/home/u/Applications/t.AppImage" %U\n'));
});

test("Flatpak install is argv, no shell, user scope", () => {
  assert.deepEqual(lib.flatpakArgv("/tmp/a.flatpak"), ["flatpak", "install", "--user", "--noninteractive", "/tmp/a.flatpak"]);
});

test("helper refuses to run without root", async () => {
  const { spawnSync } = await import("node:child_process");
  if (process.getuid && process.getuid() === 0) return; // only meaningful for a normal user
  const r = spawnSync("sh", [new URL("../../system/pkgd/axiom-pkgd", import.meta.url).pathname, "install", "/tmp/x.pkg.tar.zst"], { encoding: "utf8" });
  assert.equal(r.status, 1);
  assert.match(r.stderr, /must run as root/);
});
