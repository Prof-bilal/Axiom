// Unit tests for apps/files/files.js (pure logic). Run: node --test tests/apps/
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import vm from "node:vm";
import { fileURLToPath } from "node:url";
import path from "node:path";

const here = path.dirname(fileURLToPath(import.meta.url));
const src = fs.readFileSync(path.join(here, "../../apps/files/files.js"), "utf8")
  .replace(/^\.pragma library\s*$/m, "");
const L = {};
vm.runInNewContext(src, L);   // function declarations land on the context object

// Arrays created inside the VM context have another realm's prototype, so
// compare by value.
const eq = (a, b, m) => assert.equal(JSON.stringify(a), JSON.stringify(b), m);
const NUL = "\u0000";
const rec = (y, Y, name, size = 1, t = 1700000000.5, mode = "644", link = "") =>
  [y, Y, name, size, t, mode, link].join(NUL) + NUL;

test("paths", () => {
  assert.equal(L.joinPath("/", "a"), "/a");
  assert.equal(L.joinPath("/home/x/", "a b"), "/home/x/a b");
  assert.equal(L.parentPath("/home/x"), "/home");
  assert.equal(L.parentPath("/home"), "/");
  assert.equal(L.parentPath("/"), "/");
  assert.equal(L.baseName("/a/b/"), "b");
  eq(L.segments("/home/x").map(s => s.name), ["/", "home", "x"]);
  assert.equal(L.segments("/home/x")[2].path, "/home/x");
});

test("normalize resolves ~, relative and .. without touching disk", () => {
  assert.equal(L.normalize("~", "/home/x", "/tmp"), "/home/x");
  assert.equal(L.normalize("~/Documents", "/home/x", "/tmp"), "/home/x/Documents");
  assert.equal(L.normalize("sub/../y", "/home/x", "/tmp"), "/tmp/y");
  assert.equal(L.normalize("/a/./b//c/..", "/h", "/"), "/a/b");
  assert.equal(L.normalize("/../..", "/h", "/"), "/");
  assert.equal(L.normalize("  /etc  ", "/h", "/"), "/etc");
});

test("parseFind handles hostile names", () => {
  const names = ["a b.txt", "-dash.txt", "quote\"s'.txt", "new\nline.txt", "tab\there", "ünï©ödé 🙂", "$(touch x)", ";rm -rf", "*", ".hidden"];
  const text = names.map(n => rec("f", "f", n)).join("") + rec("d", "d", "dir") + rec("l", "d", "lnk-dir", 3, 1, "777", "dir")
    + rec("l", "N", "broken", 4, 1, "777", "nowhere") + rec("l", "f", "lnk-file", 5, 1, "777", "a b.txt");
  const e = L.parseFind(text, "/home/x");
  assert.equal(e.length, names.length + 4);
  names.forEach((n, i) => { assert.equal(e[i].name, n); assert.equal(e[i].path, "/home/x/" + n); assert.equal(e[i].isDir, false); });
  const by = Object.fromEntries(e.map(x => [x.name, x]));
  assert.equal(by["dir"].isDir, true);
  assert.equal(by["lnk-dir"].isDir, true); assert.equal(by["lnk-dir"].isLink, true);
  assert.equal(by["broken"].broken, true); assert.equal(by["broken"].isDir, false);
  assert.equal(by["lnk-file"].isLink, true); assert.equal(by["lnk-file"].isDir, false);
  assert.equal(by["lnk-file"].target, "a b.txt");
});

test("parseFind tolerates empty and truncated output", () => {
  eq(L.parseFind("", "/x"), []);
  eq(L.parseFind("f" + NUL + "f" + NUL + "half", "/x"), []);
});

test("parseTrashList, including escapes and multi-line origins", () => {
  const text = "trash:///a%20b.txt\t/home/x/t/a b.txt\n"
    + "trash:///-dash.2.txt\t/home/x/t/-dash.txt\n"
    + "trash:///nl.txt\t/home/x/t/new\nline.txt\n";
  const t = L.parseTrashList(text);
  assert.equal(t.length, 3);
  assert.equal(t[0].name, "a b.txt"); assert.equal(t[0].uri, "trash:///a%20b.txt"); assert.equal(t[0].origin, "/home/x/t/a b.txt");
  assert.equal(t[1].name, "-dash.2.txt");
  assert.equal(t[2].origin, "/home/x/t/new\nline.txt");
  eq(L.parseTrashList(""), []);
  assert.equal(L.parseTrashList("trash:///bad-no-tab\n").length, 0);
});

test("natural, folders-first, hidden-aware sorting", () => {
  const mk = (name, isDir = false, size = 0, mtime = 0) => ({ name, isDir, size, mtime });
  const list = [mk("file10"), mk("file2"), mk("B", true), mk("a", true), mk(".hid"), mk("File1")];
  eq(L.sortEntries(list, "name", true, false).map(e => e.name), ["a", "B", "File1", "file2", "file10"]);
  eq(L.sortEntries(list, "name", true, true).map(e => e.name), ["a", "B", ".hid", "File1", "file2", "file10"]);
  eq(L.sortEntries(list, "name", false, false).map(e => e.name), ["B", "a", "file10", "file2", "File1"]);
  const sized = [mk("s1", false, 5), mk("s2", false, 50), mk("s3", false, 1)];
  eq(L.sortEntries(sized, "size", false, false).map(e => e.name), ["s2", "s1", "s3"]);
  const timed = [mk("t1", false, 0, 3), mk("t2", false, 0, 1), mk("t3", false, 0, 2)];
  eq(L.sortEntries(timed, "modified", true, false).map(e => e.name), ["t2", "t3", "t1"]);
});

test("validateName", () => {
  assert.equal(L.validateName("ok name.txt"), "");
  assert.equal(L.validateName("-leading"), "");
  assert.equal(L.validateName("üñï 🙂"), "");
  for (const bad of ["", ".", "..", "a/b", "x\u0000y", "x".repeat(256)]) assert.notEqual(L.validateName(bad), "", JSON.stringify(bad));
});

test("unique names", () => {
  assert.equal(L.uniqueNewName("New folder", []), "New folder");
  assert.equal(L.uniqueNewName("New folder", ["New folder", "New folder 2"]), "New folder 3");
  assert.equal(L.uniqueCopyName("a.txt", ["b.txt"]), "a.txt");
  assert.equal(L.uniqueCopyName("a.txt", ["a.txt"]), "a (copy).txt");
  assert.equal(L.uniqueCopyName("a.txt", ["a.txt", "a (copy).txt"]), "a (copy 2).txt");
  assert.equal(L.uniqueCopyName(".bashrc", [".bashrc"]), ".bashrc (copy)");
  assert.equal(L.uniqueCopyName("dir", ["dir"]), "dir (copy)");
  assert.equal(L.uniqueCopyName("archive.tar.gz", ["archive.tar.gz"]), "archive.tar (copy).gz");
});

test("formatting", () => {
  assert.equal(L.humanSize(0), "0 B");
  assert.equal(L.humanSize(999), "999 B");
  assert.equal(L.humanSize(1500), "1.5 kB");
  assert.equal(L.humanSize(12000), "12 kB");
  assert.equal(L.humanSize(2.5e9), "2.5 GB");
  assert.equal(L.humanSize(5e15), "5000 TB");
  const now = new Date(2026, 10, 3, 12, 0).getTime();
  assert.equal(L.formatDate(new Date(2026, 10, 3, 14, 5).getTime() / 1000, now), "Nov 3, 14:05");
  assert.equal(L.formatDate(new Date(2025, 0, 9, 1, 1).getTime() / 1000, now), "Jan 9, 2025");
  assert.equal(L.formatDate(0, now), "");
});

test("categories, icons and kind labels", () => {
  const f = (name, extra = {}) => Object.assign({ name, isDir: false, isLink: false, broken: false }, extra);
  assert.equal(L.category(f("x", { isDir: true })), "folder");
  assert.equal(L.category(f("a.PNG")), "image");
  assert.equal(L.category(f("a.tar.gz")), "archive");
  assert.equal(L.category(f("Makefile")), "file");
  assert.equal(L.category(f(".png")), "file");          // dotfile, not an extension
  assert.equal(L.category(f("gone", { isLink: true, broken: true })), "broken");
  assert.equal(L.kindLabel(f("a.mp3", { isLink: true })), "Audio (link)");
  assert.equal(L.iconName(f("a.pdf")), "document");
  assert.equal(L.iconName(f("x", { isDir: true })), "folder");
  assert.equal(L.iconName(f("gone", { broken: true })), "broken-link");
});

test("displayName makes hostile names safe to show", () => {
  assert.equal(L.displayName("plain name.txt"), "plain name.txt");
  assert.equal(L.displayName("new\nline"), "new\u23CEline");
  assert.equal(L.displayName("tab\there"), "tab\u21E5here");
  assert.equal(L.displayName("bell\u0007x"), "bell\uFFFDx");
  assert.equal(L.displayName("evil\u202Etxt.exe"), "evil\uFFFDtxt.exe");
  assert.equal(L.displayName("üñï 🙂"), "üñï 🙂");
});
