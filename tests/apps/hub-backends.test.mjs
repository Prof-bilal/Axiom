// Unit tests for apps/hub/backends.js. Run: node --test tests/apps/
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const load = (f) => fs.readFileSync(path.join(here, "../../apps/hub", f), "utf8").replace(/^\.pragma library\s*$/m, "");
const B = new Function(load("catalog.js") + load("backends.js") + "; return { CATALOG, flathubRemoteArgv, stepFromLine: (x) => stepFromLine(x), chooseSource, installArgv, removeArgv, updateArgv, parseProgress, stepFor, installedIds, STEPS };")();

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
  const ids = B.installedIds(B.CATALOG, "org.videolan.VLC\ncom.discordapp.Discord\n", "git\nneovim\n");
  assert.deepEqual(ids.sort(), ["discord", "git", "neovim", "vlc"]);
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
