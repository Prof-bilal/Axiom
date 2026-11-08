import { phases } from "@/lib/data";

// Every status tag below follows docs/PHASES.md, docs/SECURITY.md and docs/ai/*.
// "designed" means a written design with no runtime; nothing here claims shipped AI.
type Status = "built" | "designed" | "planned";
const label: Record<Status, string> = { built: "Built · verified", designed: "Designed", planned: "Planned" };
export const Tag = ({ s, note }: { s: Status; note?: string }) => <span className={`tag tag-${s} mono`}>{label[s]}{note ? ` · ${note}` : ""}</span>;

export const Pixels = ({ rows }: { rows: string[] }) => <span className="pix" aria-hidden="true" style={{ gridTemplateColumns: `repeat(${rows[0].length}, 1fr)` }}>
  {rows.flatMap((r, y) => [...r].map((c, x) => <i key={`${y}-${x}`} className={c === "1" ? "on" : c === "2" ? "on acc" : ""} style={{ animationDelay: `${(x + y) * 40}ms` }} />))}
</span>;

const pillars = [
  ["Optional", "The desktop is complete without it. No model, account or network needed.", ["00100", "10101", "10101", "10001", "01110"]],
  ["Bounded", "Typed capabilities only. Never unrestricted root, sudo or a shell.", ["11111", "10001", "10101", "10001", "11111"]],
  ["Attributed", "Every action is logged, verified and, where possible, recoverable.", ["00001", "00010", "10100", "01000", "00000"]],
  ["Private", "Local-first. No continuous screenshots by default.", ["01110", "10001", "11111", "11011", "11111"]],
] as const;

export function Pillars() {
  return <div className="pillars">{pillars.map(([t, d, rows]) => <article key={t}><Pixels rows={[...rows]} /><h3>{t}</h3><p>{d}</p></article>)}</div>;
}

// Source: docs/ai/SYSTEM_AGENT_API.md (ten capabilities) and security/PERMISSIONS.md (classes). Plain-language wording.
const lanes = [
  { k: "look", title: "Just looking", rule: "Read-only. Nothing changes.", icon: ["000000000", "000000000", "001111100", "011000110", "110022011", "110022011", "011000110", "001111100", "000000000"],
    items: [["See your system", "Basic facts about this computer.", "system.info"], ["See what's running", "Only your own programs.", "processes.list"], ["See what uses space", "Only in your approved projects.", "storage.analyze"]] },
  { k: "open", title: "Opening things", rule: "Opens what you already have.", icon: ["111111111", "121111111", "111111111", "100000001", "102000001", "100200001", "102000001", "100000001", "111111111"],
    items: [["Open an app", "From your installed apps. No shell.", "apps.open"], ["Open a project", "Only projects you added.", "workspace.open"]] },
  { k: "ask", title: "Changing things", rule: "Asks you every single time.", icon: ["010010010", "010010010", "121010010", "010010121", "010010010", "010121010", "010010010", "010010010", "010010010"],
    items: [["Clean app caches", "Only the ones you previewed. Can't be undone.", "storage.clean"], ["Start a service", "Yours only, from a short approved list.", "services.start"], ["Stop a service", "Yours only, from a short approved list.", "services.stop"]] },
  { k: "admin", title: "Big changes", rule: "Your approval plus admin password.", icon: ["001111100", "011000110", "011000110", "011000110", "111111111", "111121111", "111121111", "111111111", "111111111"],
    items: [["Install software", "From a plan you reviewed, signed sources only.", "packages.install"], ["Update the system", "A full update, never half of one.", "system.update"]] },
] as const;
const locked = [
  ["Run commands or open a shell", "There is no way to even ask."],
  ["Become root or use sudo", "Admin steps go through you."],
  ["Delete or rewrite your files", "No free file access."],
  ["Power, disks, firewall, users", "Shutdown, formatting, accounts and security settings stay off-limits."],
  ["Touch your keys or send data out", "No key access, no Git pushes, no sending anything outside."],
];
export function CapabilityGrid() {
  return <div className="caps">
    <div className="lanes">{lanes.map(l => <section key={l.k} className={`lane lane-${l.k}`}>
      <header><Pixels rows={[...l.icon]} /><div><h3>{l.title}</h3><p className="mono">{l.rule}</p></div></header>
      <ul>{l.items.map(([t, d, c]) => <li key={c}><strong>{t}</strong><span>{d}</span><code className="mono">{c}</code></li>)}</ul>
    </section>)}</div>
    <div className="locked">
      <header><Pixels rows={["001111100", "011000110", "011000110", "011000110", "111111111", "111121111", "111121111", "111111111", "111111111"]} /><div><h3>Locked for good</h3><p className="mono">AI can never do these, however it asks.</p></div></header>
      <ul>{locked.map(([t, d]) => <li key={t}><strong>{t}</strong><span>{d}</span></li>)}</ul>
    </div>
  </div>;
}

export function LocalFirst() {
  return <div className="local">
    <div className="local-box"><span className="mono accent">YOUR MACHINE</span><ul><li>Files and projects</li><li>Search index in local SQLite</li><li>Logs, redacted</li><li>Secrets, kept out of logs</li></ul><Tag s="designed" /></div>
    <div className="local-link" aria-hidden="true"><i /><span className="mono">optional · off by default</span></div>
    <div className="local-box local-cloud"><span className="mono">A MODEL PROVIDER</span><ul><li>Local or cloud, replaceable</li><li>Only if you choose it</li><li>Desktop works without it</li></ul><Tag s="designed" /></div>
  </div>;
}

export function PhaseTimeline() {
  return <div className="phases">
    <ol aria-label="Phases 0 to 13">{phases.map(p => <li key={p.n} className={`ph-${p.status}`} title={`Phase ${p.n}: ${p.name}`}><span className="mono">{String(p.n).padStart(2, "0")}</span><i /></li>)}</ol>
    <div className="phases-legend mono"><span className="lg-done">Built and verified in QEMU</span><span className="lg-next">Next</span><span className="lg-planned">Planned</span></div>
  </div>;
}
