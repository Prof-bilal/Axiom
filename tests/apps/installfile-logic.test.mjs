// Unit tests for apps/appinstaller/installfile.js (Phase 7a logic).
import { readFileSync } from "node:fs";
import assert from "node:assert/strict";
import test from "node:test";

const src = readFileSync(new URL("../../apps/appinstaller/installfile.js", import.meta.url), "utf8")
  .replace(/^\.pragma library/m, "");
const lib = new Function(src + "; return { classify, appImageTarget, formatSize, quoteExec, desktopEntry, flatpakArgv, debStagePath, containerListed, validDebName, displayName, debListArgv, debCreateArgv, debEnterArgv, debNameArgv, debInstallArgv, debExportArgv, minisignArgv, signatureState, installPolicy, sandboxArgv, auditLine, sha256Argv, approveArgv, validSha256, sandboxExecLine, desktopEntryLine };")();

test("classifies AppImage, Flatpak and Arch packages", () => {
  assert.equal(lib.classify("Foo-x86_64.AppImage").kind, "appimage");
  assert.equal(lib.classify("app.flatpakref").kind, "flatpak");
  assert.equal(lib.classify("app.flatpak").kind, "flatpak");
  assert.equal(lib.classify("pkg-1.0-1-x86_64.pkg.tar.zst").kind, "arch");
});

test("unknown types return null", () => {
  assert.equal(lib.classify("notes.txt"), null);
  assert.equal(lib.classify("setup.exe"), null);
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

test("classifies .deb as a user-scope container install", () => {
  const c = lib.classify("Tool_1.0_amd64.DEB");
  assert.equal(c.kind, "deb");
  assert.equal(c.root, false);
});

test(".deb staging path stays inside ~/.cache/axiom-debs", () => {
  assert.equal(lib.debStagePath("/home/u/", "../../etc/x y.deb"), "/home/u/.cache/axiom-debs/x_y.deb");
});

test("recognises the Axiom container in distrobox list output", () => {
  const out = "ID           | NAME          | STATUS   | IMAGE\n1a2b | axiom-debian | Up 2 min | debian:stable\n";
  assert.equal(lib.containerListed(out), true);
  assert.equal(lib.containerListed("ID | NAME\n1 | other | Up"), false);
  assert.equal(lib.containerListed(""), false);
});

test("Debian package names are validated before use", () => {
  assert.equal(lib.validDebName("google-chrome-stable"), true);
  assert.equal(lib.validDebName("libc6+dev"), true);
  for (const bad of ["", "-rf", "a b", "a;b", "$(x)", "../x", "A"]) assert.equal(lib.validDebName(bad), false, bad);
});

test(".deb commands are argv arrays that enter only the Axiom container", () => {
  assert.deepEqual(lib.debListArgv(), ["distrobox", "list"]);
  const create = lib.debCreateArgv();
  assert.deepEqual(create.slice(0, 5), ["distrobox", "create", "--yes", "--name", "axiom-debian"]);
  assert.equal(create.includes("--image"), true);
  assert.deepEqual(lib.debInstallArgv("/h/.cache/axiom-debs/x.deb"),
    ["distrobox", "enter", "axiom-debian", "--", "sudo", "apt-get", "install", "-y", "/h/.cache/axiom-debs/x.deb"]);
  assert.deepEqual(lib.debNameArgv("/h/x.deb").slice(-4), ["dpkg-deb", "-f", "/h/x.deb", "Package"]);
  assert.deepEqual(lib.debExportArgv("pkg").slice(-3), ["distrobox-export", "--app", "pkg"]);
  for (const a of [lib.debInstallArgv("/x.deb"), lib.debExportArgv("p"), lib.debNameArgv("/x.deb")]) {
    assert.equal(a.slice(0, 4).join(" "), "distrobox enter axiom-debian --");
  }
});

test("friendly app name drops extension, architecture and version", () => {
  assert.equal(lib.displayName("Foo-Bar-1.2.3-x86_64.AppImage"), "Foo Bar");
  assert.equal(lib.displayName("/home/u/Downloads/obsidian_1.5.3_amd64.deb"), "Obsidian");
  assert.equal(lib.displayName("google-chrome-stable_current_amd64.deb"), "Google chrome");
  assert.equal(lib.displayName("1.2.3.AppImage"), "1.2.3.AppImage");
  assert.equal(lib.displayName(""), "App");
});

test("signature state: unsigned when no .minisig, verified or failed otherwise", () => {
  assert.equal(lib.signatureState({ present: false, verified: false }), "unsigned");
  assert.equal(lib.signatureState({ present: true, verified: true }), "verified");
  assert.equal(lib.signatureState({ present: true, verified: false }), "failed");
  assert.equal(lib.signatureState(null), "unsigned");
});

test("policy: failed signature blocked; unsigned allowed only with admin; system always admin", () => {
  const failed = lib.installPolicy("appimage", "user", "failed");
  assert.equal(failed.blocked, true);
  const unsigned = lib.installPolicy("appimage", "user", "unsigned");
  assert.equal(unsigned.blocked, false);
  assert.equal(unsigned.requiresAdmin, true);
  const signed = lib.installPolicy("appimage", "user", "verified");
  assert.equal(signed.requiresAdmin, false);
  const sys = lib.installPolicy("arch", "user", "verified");
  assert.equal(sys.requiresAdmin, true);
  assert.equal(lib.installPolicy("appimage", "system", "verified").requiresAdmin, true);
});

test("minisign argv is an array with the paths as separate arguments", () => {
  const argv = lib.minisignArgv("/usr/share/axiom/keys/axiom.pub", "/tmp/x; rm -rf ~.AppImage");
  assert.deepEqual(argv.slice(0, 3), ["minisign", "-V", "-p"]);
  assert.equal(argv[argv.length - 1], "/tmp/x; rm -rf ~.AppImage");
});

test("sandbox argv never mounts the home directory", () => {
  const argv = lib.sandboxArgv("/home/u/Applications/App.AppImage");
  assert.equal(argv[0], "bwrap");
  assert.ok(!argv.some((a) => a.startsWith("/home")) || argv.indexOf("/home/u/Applications/App.AppImage") > 0);
  assert.ok(!argv.includes("--bind"), "no read-write binds");
  assert.equal(argv[argv.length - 1], "/home/u/Applications/App.AppImage");
});

test("audit line is one JSON object with the audit id", () => {
  const line = lib.auditLine({ id: "ax-1", time: "t", file: "a.AppImage", sha256: "ab", signature: "unsigned",
    policy: "admin", sandbox: "bwrap", target: "/home/u/Applications/a", result: "installed" });
  assert.equal(line.includes("\n"), false);
  assert.equal(JSON.parse(line).id, "ax-1");
});

test("approve argv is pkexec + the helper; digest must be 64 lowercase hex", () => {
  assert.deepEqual(lib.approveArgv("a".repeat(64)), ["pkexec", "/usr/local/bin/axiom-pkgd", "approve", "a".repeat(64)]);
  assert.equal(lib.validSha256("a".repeat(64)), true);
  assert.equal(lib.validSha256("A".repeat(64)), false);
  assert.equal(lib.validSha256("a; rm -rf ~"), false);
});

test("sandboxed Exec line quotes the path and ends with %U", () => {
  const line = lib.sandboxExecLine('/home/u/My Apps/a$b.AppImage');
  assert.ok(line.startsWith('"bwrap"'));
  assert.ok(line.includes('"/home/u/My Apps/a\\$b.AppImage"'));
  assert.ok(line.endsWith(" %U"));
});

test("desktop entry with an Exec line keeps the line as given", () => {
  const e = lib.desktopEntryLine("Demo", 'bwrap x -- "/p" %U');
  assert.ok(e.includes("Exec=bwrap x -- \"/p\" %U"));
  assert.ok(e.startsWith("[Desktop Entry]"));
});
