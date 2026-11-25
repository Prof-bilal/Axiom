// Unit tests for apps/hub/engine.js. Run: node --test tests/apps/
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const load = (f) => fs.readFileSync(path.join(here, "../../apps/hub", f), "utf8").replace(/^\.pragma library\s*$/m, "");
const E = new Function(load("engine.js") + "; return { cleanQuery, searchArgv, toApp, parseResults, categoryFor };")();

const RESULT = { id: "org.mozilla.firefox", name: "Firefox", summary: "Browse the web", kind: "app",
  icon: "https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/org.mozilla.firefox.png", categories: ["Network", "WebBrowser"],
  sources: [{ type: "pacman", ref: "firefox", version: "160.0.1-1", publisher: "extra", trust: "official", licence: "" },
            { type: "flatpak", ref: "org.mozilla.firefox", version: "3.0", publisher: "Mozilla", trust: "verified", licence: "MPL-2.0" }] };

test("a result becomes the app shape the screens use", () => {
  const a = E.toApp(RESULT);
  assert.equal(a.category, "Internet");
  assert.equal(a.verified, true);
  assert.equal(a.sources[0].type, "pacman", "official repo stays first");
  assert.equal(a.icon, RESULT.icon);
  assert.match(a.trustLabel, /Official Arch repository/);
});

test("an unverified Flathub-only app is not marked verified", () => {
  const a = E.toApp({ id: "x.y", name: "X", sources: [{ type: "flatpak", ref: "x.y", trust: "unverified", publisher: "Someone" }] });
  assert.equal(a.verified, false);
  assert.equal(a.trust, "unverified");
  assert.equal(a.publisher, "Someone");
});

test("categories map to the Discover chips, unknown ones to Utilities", () => {
  assert.equal(E.categoryFor(["Development", "IDE"]), "Development");
  assert.equal(E.categoryFor(["Office"]), "Productivity");
  assert.equal(E.categoryFor(["Weird"]), "Utilities");
  assert.equal(E.categoryFor(undefined), "Utilities");
});

test("search text is cleaned and bounded, and an empty one means no search", () => {
  assert.equal(E.cleanQuery("  code\u0000 editor\n "), "code  editor");
  assert.equal(E.cleanQuery("x".repeat(200)).length, 80);
  assert.equal(E.searchArgv("   "), null);
  assert.deepEqual(E.searchArgv("vim"), ["/usr/local/bin/axiom-hub", "search", "vim"]);
});

test("the engine path can be overridden for development", () => {
  assert.deepEqual(E.searchArgv("vim", "/tmp/x/axiom-hub"), ["/tmp/x/axiom-hub", "search", "vim"]);
});

test("search text is one argv element, never split or interpreted", () => {
  const argv = E.searchArgv('a; rm -rf / $(id) "q"');
  assert.equal(argv.length, 3);
  assert.equal(argv[2], 'a; rm -rf / $(id) "q"');
});

test("results parse; bad output is an error, not an exception", () => {
  assert.equal(E.parseResults(JSON.stringify({ results: [RESULT] })).apps.length, 1);
  for (const bad of ["", "not json", "{}", '{"results": 3}', "null"]) {
    const r = E.parseResults(bad);
    assert.equal(r.ok, false, bad);
    assert.deepEqual(r.apps, []);
    assert.ok(r.error.length > 0);
  }
});
