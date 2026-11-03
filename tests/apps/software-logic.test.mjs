// Unit tests for apps/software/software.js. Run: node --test tests/apps/
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import vm from "node:vm";
import { fileURLToPath } from "node:url";
import path from "node:path";

const here = path.dirname(fileURLToPath(import.meta.url));
const src = fs.readFileSync(path.join(here, "../../apps/software/software.js"), "utf8")
  .replace(/^\.pragma library\s*$/m, "");
const L = {};
vm.runInNewContext(src, L);
const eq = (a, b, m = "values differ") => assert.equal(JSON.stringify(a), JSON.stringify(b), m);

// Real `pacman -Qi` shape, including a wrapped Optional Deps field.
const FIREFOX = `Name            : firefox
Version         : 158.0.1-1
Description     : Fast, Private & Safe Web Browser
Architecture    : x86_64
URL             : https://www.firefox.com/
Licenses        : MPL-2.0
Groups          : None
Provides        : None
Depends On      : alsa-lib  at-spi2-core  bash  cairo
Optional Deps   : firefox-i18n: Localizations
                  hunspell-dictionary: Spell checking
                  libnotify: Notification integration [installed]
Required By     : None
Optional For    : None
Conflicts With  : None
Replaces        : None
Installed Size  : 280.30 MiB
Packager        : Arch Linux
Build Date      : Wed 28 Oct 2026 10:00:00 AM UTC
Install Date    : Mon 02 Nov 2026 12:56:00 PM UTC
Install Reason  : Explicitly installed
Install Script  : No
Validated By    : Signature

`;
const BASH = `Name            : bash
Version         : 5.3.9-1
Description     : The GNU Bourne Again shell
Architecture    : x86_64
URL             : https://www.gnu.org/software/bash/bash.html
Licenses        : GPL-3.0-or-later
Groups          : None
Provides        : sh
Depends On      : readline  libreadline.so=8-64  glibc  ncurses
Optional Deps   : bash-completion: for tab completion
Required By     : base  firefox  foot
Optional For    : None
Conflicts With  : None
Replaces        : None
Installed Size  : 8.50 MiB
Packager        : Arch Linux
Build Date      : Tue 01 Jul 2026 08:00:00 AM UTC
Install Date    : Mon 02 Nov 2026 12:50:00 PM UTC
Install Reason  : Installed as a dependency for another package
Install Script  : No
Validated By    : Signature
`;

test("parseQi parses blocks, lists and wrapped fields", () => {
  const p = L.parseQi(FIREFOX + BASH);
  assert.equal(p.length, 2);
  const f = p[0], b = p[1];
  assert.equal(f.name, "firefox"); assert.equal(f.version, "158.0.1-1");
  assert.equal(f.description, "Fast, Private & Safe Web Browser");
  assert.equal(f.explicit, true); assert.equal(b.explicit, false);
  eq(f.depends, ["alsa-lib", "at-spi2-core", "bash", "cairo"]);
  eq(f.groups, []); eq(f.provides, []); eq(f.requiredBy, []);
  eq(b.provides, ["sh"]); eq(b.requiredBy, ["base", "firefox", "foot"]);
  eq(f.optionalDeps, ["firefox-i18n: Localizations", "hunspell-dictionary: Spell checking", "libnotify: Notification integration [installed]"]);
  assert.equal(f.url, "https://www.firefox.com/");
  assert.equal(f.installedSize, "280.30 MiB");
  assert.equal(f.sizeBytes, Math.round(280.3 * 1048576));
  assert.equal(f.packager, "Arch Linux");
});

test("parseQi tolerates empty and junk input", () => {
  eq(L.parseQi(""), []);
  eq(L.parseQi("warning: something\n\nnot a package"), []);
  assert.equal(L.parseQi("Name : only\nVersion : 1\n").length, 1);
});

test("sizeToBytes", () => {
  assert.equal(L.sizeToBytes("0 B"), 0);
  assert.equal(L.sizeToBytes("1.00 KiB"), 1024);
  assert.equal(L.sizeToBytes("2.5 GiB"), 2684354560);
  assert.equal(L.sizeToBytes("garbage"), 0);
});

test("filterPackages", () => {
  const pk = L.parseQi(FIREFOX + BASH);
  const unused = L.parseNameSet("bash\nother\n");
  eq(L.filterPackages(pk, "", "all", unused).map(p => p.name), ["firefox", "bash"]);
  eq(L.filterPackages(pk, "", "explicit", unused).map(p => p.name), ["firefox"]);
  eq(L.filterPackages(pk, "", "deps", unused).map(p => p.name), ["bash"]);
  eq(L.filterPackages(pk, "", "unused", unused).map(p => p.name), ["bash"]);
  eq(L.filterPackages(pk, "FIRE", "all", unused).map(p => p.name), ["firefox"]);
  eq(L.filterPackages(pk, "bourne", "all", unused).map(p => p.name), ["bash"]);
  eq(L.filterPackages(pk, "zzz", "all", unused), []);
  eq(L.filterPackages(pk, "  fire  ", "explicit", unused).map(p => p.name), ["firefox"]);
});

test("sortPackages", () => {
  const pk = L.parseQi(BASH + "\n" + FIREFOX);
  eq(L.sortPackages(pk, "name").map(p => p.name), ["bash", "firefox"]);
  eq(L.sortPackages(pk, "size").map(p => p.name), ["firefox", "bash"]);
});

test("parseOwner and parseFiles", () => {
  const o = L.parseOwner("/usr/share/applications/org.xfce.mousepad.desktop is owned by mousepad 0.6.5-1\n");
  assert.equal(o.name, "mousepad"); assert.equal(o.version, "0.6.5-1");
  assert.equal(L.parseOwner("error: No package owns /usr/local/share/applications/x.desktop"), null);
  const f = L.parseFiles("foo /usr/\nfoo /usr/bin/\nfoo /usr/bin/foo\nfoo /usr/share/doc/foo/README\nfoo /usr/share/a b\n", 2);
  assert.equal(f.count, 3); eq(f.files, ["/usr/bin/foo", "/usr/share/doc/foo/README"]);
});

test("hasSyncDatabases and humanSize", () => {
  assert.equal(L.hasSyncDatabases("core.db\nextra.db\n"), true);
  assert.equal(L.hasSyncDatabases("ls: cannot access '/var/lib/pacman/sync': No such file or directory"), false);
  assert.equal(L.hasSyncDatabases(""), false);
  assert.equal(L.humanSize(512), "512 B");
  assert.equal(L.humanSize(1536), "1.5 KiB");
  assert.equal(L.humanSize(5 * 1048576), "5.0 MiB");
});
