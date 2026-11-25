// Unit tests for apps/hub/engine.js. Run: node --test tests/apps/
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const load = (f) => fs.readFileSync(path.join(here, "../../apps/hub", f), "utf8").replace(/^\.pragma library\s*$/m, "");
const E = new Function(load("engine.js") + "; return { cleanQuery, searchArgv, toApp, parseResults, categoryFor, sourceLabel, parseFlatpakContext, permissionNotes, sourceNotes };")();

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

const META = `[Application]
name=com.example.App
runtime=org.freedesktop.Platform/x86_64/24.08

[Context]
shared=network;ipc;
sockets=wayland;x11;session-bus;
devices=all;
filesystems=host;~/.config/app:create;

[Session Bus Policy]
org.freedesktop.Notifications=talk
`;

test("flatpak metadata: only the [Context] lists are read", () => {
  const c = E.parseFlatpakContext(META);
  assert.deepEqual(c.shared, ["network", "ipc"]);
  assert.deepEqual(c.devices, ["all"]);
  assert.deepEqual(c.filesystems, ["host", "~/.config/app:create"]);
  assert.deepEqual(E.parseFlatpakContext("garbage\nshared=network;"), { shared: [], sockets: [], devices: [], filesystems: [] }, "outside [Context] is ignored");
});

test("broad grants produce plain warnings, narrow ones only info", () => {
  const broad = E.permissionNotes(E.parseFlatpakContext(META));
  assert.ok(broad.some((n) => n.level === "warn" && /all your files/.test(n.text)));
  assert.ok(broad.some((n) => n.level === "warn" && /all devices/.test(n.text)));
  assert.ok(broad.some((n) => n.level === "warn" && /talk to other apps/.test(n.text)));
  const narrow = E.permissionNotes({ shared: ["network"], sockets: ["wayland"], devices: ["dri"], filesystems: ["xdg-download"] });
  assert.ok(narrow.every((n) => n.level === "info"));
  assert.deepEqual(E.permissionNotes({ shared: [], sockets: [], devices: [], filesystems: [] }), []);
});

test("home access is a warning but not the same text as all files", () => {
  const n = E.permissionNotes({ shared: [], sockets: [], devices: [], filesystems: ["home:ro"] });
  assert.match(n[0].text, /home folder/);
});

test("source notes: system upgrade for pacman, second copy, unverified, community", () => {
  const pac = { type: "pacman", trust: "official" }, fp = { type: "flatpak", trust: "unverified" };
  assert.ok(E.sourceNotes(pac, []).some((n) => /upgrades the system/.test(n.text) && /snapshot/.test(n.text)));
  assert.ok(E.sourceNotes(fp, []).some((n) => n.level === "warn" && /not verified/.test(n.text)));
  assert.ok(E.sourceNotes(fp, ["pacman"]).some((n) => /second copy/.test(n.text) && /Arch repository/.test(n.text)));
  assert.equal(E.sourceNotes(fp, ["flatpak"]).some((n) => /second copy/.test(n.text)), false, "same source is a reinstall, not a second copy");
  assert.ok(E.sourceNotes({ type: "pacman", trust: "community" }, []).some((n) => /community repository/.test(n.text)));
  assert.equal(E.sourceNotes({ type: "flatpak", trust: "verified" }, []).length, 0);
});

test("source labels", () => {
  assert.equal(E.sourceLabel({ type: "pacman" }), "Arch repository");
  assert.equal(E.sourceLabel({ type: "flatpak" }), "Flathub");
});

// Real `flatpak remote-info --user --show-metadata flathub org.mozilla.firefox` output from Flatpak 1.18.4
// (tests/apps/fixtures/flatpak-metadata-firefox.txt), so the parser is checked against the real format.
test("real Flatpak metadata for Firefox parses and gives sensible notes", () => {
  const real = fs.readFileSync(path.join(here, "fixtures/flatpak-metadata-firefox.txt"), "utf8");
  const c = E.parseFlatpakContext(real);
  assert.deepEqual(c.shared, ["network", "ipc"]);
  assert.ok(c.sockets.includes("wayland") && c.sockets.includes("x11"));
  assert.deepEqual(c.devices, ["all"]);
  assert.ok(c.filesystems.includes("xdg-download"));
  const notes = E.permissionNotes(c);
  assert.ok(notes.some((n) => n.level === "warn" && /all devices/.test(n.text)), "devices=all is a warning");
  assert.ok(!notes.some((n) => /all your files|home folder/.test(n.text)), "no host or home access");
  assert.ok(notes.some((n) => /X11/.test(n.text)));
  assert.ok(!notes.some((n) => /talk to other apps/.test(n.text)), "[Session Bus Policy] names are not the unrestricted session-bus socket");
});
