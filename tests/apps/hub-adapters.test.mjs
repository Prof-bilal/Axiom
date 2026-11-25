// Unit tests for apps/hub/adapters/*.js (store Stage 1). Run: node --test tests/apps/
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const load = (f) => fs.readFileSync(path.join(here, "../../apps/hub", f), "utf8").replace(/^\.pragma library\s*$/m, "");
const P = new Function(load("adapters/pacman.js") + "; return { parseSearch, parseInfo, sizeToMb };")();

const SEARCH = [
  "extra/firefox 160.0.1-1 [installed: 158.0.1-1]",
  "    Fast, Private & Safe Web Browser",
  "community/firefox-esr 128.0-1",
  "    Mozilla Firefox ESR",
].join("\n");

const INFO = [
  "Repository      : extra",
  "Name            : firefox",
  "Version         : 160.0.1-1",
  "Description     : Fast, Private & Safe Web Browser",
  "Architecture    : x86_64",
  "URL             : https://www.firefox.com/",
  "Licenses        : MPL-2.0",
  "Optional Deps   : firefox-i18n: Localizations",
  "                  libnotify: Notification integration",
  "Packager        : Jan Alexander Steffens (heftig) <heftig@archlinux.org>",
  "Download Size   : 86.90 MiB",
  "Installed Size  : 307.04 MiB",
  "Validated By    : SHA-256 Sum  Signature",
].join("\n");

test("search output: repo, name, version, installed state and summary", () => {
  const hits = P.parseSearch(SEARCH);
  assert.equal(hits.length, 2);
  assert.deepEqual(hits[0], { repo: "extra", name: "firefox", version: "160.0.1-1", installed: true,
    installedVersion: "158.0.1-1", summary: "Fast, Private & Safe Web Browser" });
  assert.equal(hits[1].installed, false);
  assert.equal(hits[1].repo, "community");
});

test("search output: empty and garbage input give no hits, never throw", () => {
  assert.deepEqual(P.parseSearch(""), []);
  assert.deepEqual(P.parseSearch(undefined), []);
  assert.deepEqual(P.parseSearch("error: no results\n$(id);rm -rf /"), []);
});

test("info output: fields, sizes in MB, signature state", () => {
  const i = P.parseInfo(INFO);
  assert.equal(i.name, "firefox");
  assert.equal(i.repo, "extra");
  assert.equal(i.version, "160.0.1-1");
  assert.equal(i.licence, "MPL-2.0");
  assert.equal(i.downloadMb, 87);
  assert.equal(i.installedMb, 307);
  assert.equal(i.validated, true);
  assert.equal(i.publisher.startsWith("Jan Alexander"), true);
});

test("info output without a name is rejected (null), so no card is shown", () => {
  assert.equal(P.parseInfo("Version : 1.0"), null);
  assert.equal(P.parseInfo(""), null);
});

test("sizes: units convert to MB and unknown text gives null", () => {
  assert.equal(P.sizeToMb("1.5 GiB"), 1536);
  assert.equal(P.sizeToMb("512 KiB"), 1);
  assert.equal(P.sizeToMb("nonsense"), null);
  assert.equal(P.sizeToMb(undefined), null);
});
