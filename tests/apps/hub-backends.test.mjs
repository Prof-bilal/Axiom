// Unit tests for apps/hub/backends.js. Run: node --test tests/apps/
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const load = (f) => fs.readFileSync(path.join(here, "../../apps/hub", f), "utf8").replace(/^\.pragma library\s*$/m, "");
const B = new Function(load("catalog.js") + load("backends.js") + "; return { CATALOG, flathubRemoteArgv, stepFromLine: (x) => stepFromLine(x), chooseSource, installArgv, removeArgv, updateArgv, parseProgress, stepFor, installedIds, STEPS, errorLine, exitMessage, enqueue, installedSourceTypes, updateIds, installedSource, pacmanProgress, freshPacmanState };")();

test("Flatpak installs are user-scope argv with the ref last", () => {
  assert.deepEqual(B.installArgv({ type: "flatpak", ref: "org.videolan.VLC" }, "/home/u"),
    ["flatpak", "install", "--user", "-y", "--noninteractive", "flathub", "org.videolan.VLC"]);
});

test("pacman goes through the helper with pkexec, never a shell", () => {
  assert.deepEqual(B.installArgv({ type: "pacman", ref: "neovim" }, "/home/u"), ["pkexec", "/usr/local/bin/axiom-pkgd", "sync", "neovim"]);
  assert.deepEqual(B.removeArgv({ type: "pacman", ref: "neovim" }, "/home/u"), ["pkexec", "/usr/local/bin/axiom-pkgd", "remove", "neovim"]);
});

test("unsafe or malformed refs are rejected", () => {
  for (const ref of ["foo; rm -rf /", "../x", "-Syu", "a b", "", "FOO"]) {
    assert.equal(B.installArgv({ type: "pacman", ref }, "/h"), null, ref);
  }
  assert.equal(B.installArgv({ type: "flatpak", ref: "x y" }, "/h"), null);
  assert.equal(B.installArgv(null, "/h"), null);
  assert.equal(B.installArgv({ type: "weird", ref: "x" }, "/h"), null);
});

test("CLI tools install into the user's own folder", () => {
  assert.deepEqual(B.installArgv({ type: "npm", ref: "opencode-ai" }, "/home/u"), ["npm", "install", "-g", "--prefix", "/home/u/.local", "opencode-ai"]);
  assert.deepEqual(B.installArgv({ type: "pip", ref: "aider-chat" }, "/home/u"), ["pipx", "install", "aider-chat"]);
  assert.deepEqual(B.removeArgv({ type: "pip", ref: "aider-chat" }, "/home/u"), ["pipx", "uninstall", "aider-chat"]);
  assert.deepEqual(B.updateArgv({ type: "npm", ref: "x" }, "/home/u").slice(0, 2), ["npm", "update"]);
});

test("every catalog source produces a valid install command", () => {
  for (const a of B.CATALOG) for (const s of a.sources) { if (s.type === "manual") continue; assert.ok(B.installArgv(s, "/home/u"), `${a.id}/${s.type}`); }
});

test("source choice follows what the machine has", () => {
  const ff = B.CATALOG.find((a) => a.id === "firefox");
  assert.equal(B.chooseSource(ff, ["pacman"]).type, "pacman");
  assert.equal(B.chooseSource(ff, ["flatpak", "pacman"]).type, "flatpak");
  assert.equal(B.chooseSource(ff, ["npm"]), null);
});

test("progress parsing takes the last percentage", () => {
  assert.equal(B.parseProgress("Installing… 12%\nInstalling… 45%"), 45);
  assert.equal(B.parseProgress("no numbers"), -1);
  assert.equal(B.parseProgress("1234%"), -1);
});

test("steps follow the percentage", () => {
  assert.equal(B.stepFor(0), 0);
  assert.equal(B.stepFor(40), 1);
  assert.equal(B.stepFor(80), 2);
  assert.equal(B.stepFor(100), 3);
  assert.equal(B.STEPS.length, 4);
});

test("installed ids come from flatpak and pacman lists", () => {
  const ids = B.installedIds(B.CATALOG, "org.videolan.VLC\ncom.example.NotInTheList\n", "git\nneovim\n");
  assert.deepEqual(ids.sort(), ["git", "neovim", "vlc"]);
});

test("the Flathub remote is added for the user, idempotently", () => {
  const a = B.flathubRemoteArgv();
  assert.deepEqual(a.slice(0, 4), ["flatpak", "remote-add", "--user", "--if-not-exists"]);
  assert.ok(a[a.length - 1].startsWith("https://dl.flathub.org/"));
});

test("progress: percent, done/total fraction, or nothing", () => {
  assert.equal(B.parseProgress("Installing… 12%\nInstalling… 45%"), 45);
  assert.equal(B.parseProgress("Installing 3/4 packages"), 75);
  assert.equal(B.parseProgress("Installing 0/0"), -1);
  assert.equal(B.parseProgress("resolving dependencies"), -1);
});

test("the step follows the command's own wording", () => {
  assert.equal(B.stepFromLine("Configuring the desktop entry"), 2);
  assert.equal(B.stepFromLine("Finalizing installation"), 3);
  assert.equal(B.stepFromLine("Installing org.videolan.VLC"), 1);
  assert.equal(B.stepFromLine("hello"), -1);
});

test("npm and pipx installs are detected from their own listings", () => {
  const cat = [
    { id: "codex", sources: [{ type: "npm", ref: "@openai/codex" }] },
    { id: "opencode", sources: [{ type: "npm", ref: "opencode-ai" }] },
    { id: "aider", sources: [{ type: "pip", ref: "aider-chat" }] },
    { id: "neovim", sources: [{ type: "pacman", ref: "neovim" }] },
  ];
  const npm = "/home/u/.local/lib/node_modules/@openai/codex\n/home/u/.local/lib/node_modules/opencode-ai\n";
  const pipx = "aider-chat 0.50.1\n";
  assert.deepEqual(B.installedIds(cat, "", "", npm, pipx), ["codex", "opencode", "aider"]);
  assert.deepEqual(B.installedIds(cat, "", "", "", ""), []);
  assert.deepEqual(B.installedIds(cat, "", "neovim", "", ""), ["neovim"]);
});

test("the error shown is the line that says what went wrong, not the last progress line", () => {
  const log = "resolving dependencies...\n:: Retrieving packages...\nerror: failed retrieving file 'x' from mirror: 404\n( 1/3) installing foo [####] 100%\n";
  assert.equal(B.errorLine(log), "error: failed retrieving file 'x' from mirror: 404");
});

test("with no error wording it falls back to the last non-progress line, then to a generic message", () => {
  assert.equal(B.errorLine("Preparing\nAll done soon\n(1/2) installing a\n"), "All done soon");
  assert.equal(B.errorLine("(1/2) installing a\n50%\n"), "The command failed.");
  assert.equal(B.errorLine(""), "The command failed.");
  assert.equal(B.errorLine(undefined), "The command failed.");
});

test("helper exit codes have plain-language messages; unknown codes defer to the log", () => {
  assert.match(B.exitMessage(5), /already running/);
  assert.match(B.exitMessage(6), /Too late to cancel/);
  assert.match(B.exitMessage(126), /dismissed/);
  assert.equal(B.exitMessage(1), "");
  assert.equal(B.exitMessage(0), "");
});

test("a request while busy is queued; the same request twice is ignored", () => {
  const a = { id: "a", name: "A" }, b = { id: "b", name: "B" };
  let r = B.enqueue([], { id: "a", act: "install" }, b, "install");
  assert.equal(r.accepted, true);
  assert.deepEqual(r.queue.map((q) => q.app.id), ["b"]);
  r = B.enqueue(r.queue, { id: "a", act: "install" }, b, "install");
  assert.equal(r.accepted, false, "already waiting");
  assert.equal(r.queue.length, 1);
  assert.equal(B.enqueue([], { id: "a", act: "install" }, a, "install").accepted, false, "already running");
  assert.equal(B.enqueue([], { id: "a", act: "install" }, a, "remove").accepted, true, "a different action is a different request");
  assert.equal(B.enqueue([], null, a, "install").accepted, true, "external job: nothing of ours is running");
});

test("the picked source wins when its backend exists; otherwise the first usable one", () => {
  const app = { sources: [{ type: "pacman", ref: "firefox" }, { type: "flatpak", ref: "org.mozilla.firefox" }] };
  assert.equal(B.chooseSource(app, ["pacman", "flatpak"], app.sources[1]).type, "flatpak");
  assert.equal(B.chooseSource(app, ["pacman"], app.sources[1]).type, "pacman", "flatpak not installed here");
  assert.equal(B.chooseSource(app, ["pacman", "flatpak"], { type: "flatpak", ref: "evil.injected" }).type, "pacman", "a source not on the app is never used");
  assert.equal(B.chooseSource(app, ["pacman", "flatpak"]).type, "pacman");
  assert.equal(B.chooseSource(app, [], null), null);
});

test("installed source types say which copy is installed", () => {
  const app = { sources: [{ type: "pacman", ref: "firefox" }, { type: "flatpak", ref: "org.mozilla.firefox" }] };
  assert.deepEqual(B.installedSourceTypes(app, "org.mozilla.firefox\n", "git\n"), ["flatpak"]);
  assert.deepEqual(B.installedSourceTypes(app, "", "firefox\n").sort(), ["pacman"]);
  assert.deepEqual(B.installedSourceTypes(app, "org.mozilla.firefox\n", "firefox\n").sort(), ["flatpak", "pacman"]);
  assert.deepEqual(B.installedSourceTypes(app, "", ""), []);
});

test("update ids come from flatpak ids and pacman -Qu lines", () => {
  const apps = [
    { id: "org.mozilla.firefox", sources: [{ type: "pacman", ref: "firefox" }, { type: "flatpak", ref: "org.mozilla.firefox" }] },
    { id: "pacman:neovim", sources: [{ type: "pacman", ref: "neovim" }] },
    { id: "org.gimp.GIMP", sources: [{ type: "flatpak", ref: "org.gimp.GIMP" }] },
  ];
  assert.deepEqual(B.updateIds(apps, "org.gimp.GIMP\n", "neovim 0.9-1 -> 0.10-1\nlinux 6.1-1 -> 6.2-1\n").sort(), ["org.gimp.GIMP", "pacman:neovim"]);
  assert.deepEqual(B.updateIds(apps, "", ""), []);
  assert.deepEqual(B.updateIds(apps, undefined, undefined), []);
  assert.deepEqual(B.updateIds(apps, "", "firefox 1 -> 2\n"), ["org.mozilla.firefox"]);
});

test("remove and update act on the installed source, not the first one listed", () => {
  const app = { sources: [{ type: "pacman", ref: "firefox" }, { type: "flatpak", ref: "org.mozilla.firefox" }] };
  assert.equal(B.installedSource(app, ["flatpak"]).ref, "org.mozilla.firefox");
  assert.equal(B.installedSource(app, ["pacman", "flatpak"]).ref, "firefox");
  assert.equal(B.installedSource(app, []), null);
  // and the chosen source is what the helper command is built from
  assert.deepEqual(B.removeArgv(B.installedSource(app, ["flatpak"]), "/home/u").slice(0, 3), ["flatpak", "uninstall", "--user"]);
});

// Real output of a real pacman transaction with stdout not a terminal (as in a unit's journal); see
// tests/apps/fixtures/pacman-piped-install.txt. Progress and the cancel rule are checked against it, not against guesses.
const REAL = fs.readFileSync(path.join(here, "fixtures/pacman-piped-install.txt"), "utf8").split("\n");

test("progress from a real pacman transaction: spinner while downloading, then 50 to 99 by package", () => {
  let s = B.freshPacmanState();
  const seen = [];
  for (const line of REAL) { s = B.pacmanProgress(s, line); seen.push(s.percent); }
  assert.equal(s.total, 11, "total from the Packages (11) line");
  assert.equal(s.count, 11, "one installing line per package");
  assert.ok(s.committing);
  assert.equal(seen[0], -1, "no percentage before the commit starts");
  assert.equal(s.percent, 99);
  assert.deepEqual(seen, [...seen].sort((a, b) => a - b), "never goes backwards");
});

test("hook lines and download lines do not move the pacman progress", () => {
  let s = B.freshPacmanState();
  for (const line of [" glibc-2.44-1-x86_64 downloading...", "(1/3) Generating the configured locale...", "checking keyring...", ""]) s = B.pacmanProgress(s, line);
  assert.equal(s.percent, -1);
  assert.equal(s.committing, false);
});

test("the commit phase is detected from the real marker, before the first package is installed", () => {
  let s = B.freshPacmanState();
  for (const line of REAL) { s = B.pacmanProgress(s, line); if (/^:: Processing package changes/.test(line)) break; }
  assert.equal(s.committing, true);
  assert.equal(s.count, 0);
  assert.equal(s.percent, 50);
});
