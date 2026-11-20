// Prints the Hub's own install plan as JSON: one entry per catalog app, with the argv the
// Hub would run. tests/phase7-hub-apps.py uses this so the guest runs exactly the Hub's commands.
// Usage: node tests/apps/hub-plan.mjs [flatpak,pacman,npm,pip]   (sources this machine has)
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const load = (f) => fs.readFileSync(path.join(here, "../../apps/hub", f), "utf8").replace(/^\.pragma library\s*$/m, "");
const available = (process.argv[2] || "flatpak,pacman,npm,pip").split(",");
const { CATALOG, chooseSource, installArgv, removeArgv, flathubRemoteArgv } = new Function(
  load("catalog.js") + load("backends.js") +
  "; return { CATALOG, chooseSource, installArgv, removeArgv, flathubRemoteArgv };")();

const home = "/home/axiom";
const plan = CATALOG.map((a) => {
  const src = chooseSource(a, available);
  return {
    id: a.id, name: a.name, verified: a.verified, category: a.category, weight: a.weight,
    source: src ? src.type : null, ref: src ? src.ref : null,
    install: src ? installArgv(src, home) : null,
    remove: src ? removeArgv(src, home) : null,
  };
});
process.stdout.write(JSON.stringify({ remote: flathubRemoteArgv(), apps: plan }, null, 1));
