"use client";

import { useEffect, useState } from "react";
import { Pixels } from "@/components/idea-sections";
import { agentIcons } from "@/lib/agent-icons";

// Source: docs/ai/AGENT_SYSTEM.md (V1 policy), AI_ARCHITECTURE.md, security/PERMISSIONS.md.
// Status of all of it: designed, no runtime exists. Roles are short readings of the proposed names.
type Cls = "OBSERVE" | "NORMAL" | "SENSITIVE";
const children: [string, Cls, string, string][] = [
  ["Context", "OBSERVE", "none", "Reads project and workspace context so other agents start informed."],
  ["Research", "OBSERVE", "none", "Looks things up and gathers sources. Read-only."],
  ["Build", "NORMAL", "required", "Builds a project inside a sandbox."],
  ["Test", "NORMAL", "required", "Runs tests inside a sandbox."],
  ["Debug", "NORMAL", "required", "Investigates failures inside a sandbox."],
  ["Security", "OBSERVE", "none", "Reviews for security issues. Read-only."],
  ["Dependency", "SENSITIVE", "required", "Plans dependency changes. Every step needs your approval."],
  ["Environment", "SENSITIVE", "required", "Plans environment changes. Every step needs your approval."],
  ["Data / Service", "SENSITIVE", "container", "Works with data and services inside a container."],
  ["Performance", "OBSERVE", "none", "Measures first, and only then suggests changes. Starts read-only."],
  ["Customization", "NORMAL", "none", "Proposes desktop customization changes."],
  ["Model Eval", "OBSERVE", "required", "Checks a candidate model before it is trusted as a default."],
];
const classNote: Record<Cls, string> = {
  OBSERVE: "Reads redacted information. Observing is never permission to upload it.",
  NORMAL: "Can open an approved app or workspace. Grants are session-scoped.",
  SENSITIVE: "Needs your approval for each request.",
};

// Illustrative tasks, one per child agent. The run is scripted: no model and no agent runtime exist yet.
const tasks: Record<string, [string, string, string]> = {
  "Context": ["What is this project about?", "Reads the open workspace, read-only", "A short map of the project (example)"],
  "Research": ["Find papers on local-first sync", "Searches and collects sources, read-only", "Five sources with short notes (example)"],
  "Build": ["Build my project", "Runs the build inside the sandbox", "Build finished, output shown (example)"],
  "Test": ["Run my tests", "Runs the test suite inside the sandbox", "42 passed, 1 failed, with the log (example)"],
  "Debug": ["Why does the app crash on start?", "Reproduces the crash inside the sandbox", "Likely cause found, fix proposed (example)"],
  "Security": ["Check this project for risks", "Reviews code and settings, read-only", "Two warnings, none critical (example)"],
  "Dependency": ["Update my project's libraries", "Plans the update inside the sandbox", "Update plan ready, nothing installed yet (example)"],
  "Environment": ["Set up Python 3.12 for this project", "Plans the setup inside the sandbox", "Setup plan ready for review (example)"],
  "Data / Service": ["Start my local database", "Prepares it inside a container", "Database ready on a local port (example)"],
  "Performance": ["Why is my laptop slow?", "Measures first, read-only", "One process uses most of the CPU (example)"],
  "Customization": ["Switch to a darker theme", "Proposes the setting change", "Dark theme proposed, easy to switch back (example)"],
  "Model Eval": ["Check a new model before I trust it", "Runs the checks inside the sandbox", "Passed 18 of 20 checks (example)"],
};
const bad = "Delete everything in my home folder";
const rule: Record<Cls, string> = { OBSERVE: "read-only, no approval needed", NORMAL: "approved app or workspace, session grant", SENSITIVE: "needs your approval, one time" };
const sandboxLine = (sb: string) => sb === "none" ? "no sandbox needed, it only reads" : sb === "required" ? "runs in a sandbox, and fails closed without one" : "runs in a container";

type Line = { text: string; ok?: boolean };
type Phase = "idle" | "running" | "await" | "done" | "denied" | "blocked";

export function Agents() {
  const [pick, setPick] = useState(0);
  const [ask, setAsk] = useState<"" | "main" | "bad">("");
  const [phase, setPhase] = useState<Phase>("idle");
  const [shown, setShown] = useState(0);
  const [approved, setApproved] = useState(false);
  const [name, cls, sandbox] = children[pick];
  const [askText, act, result] = tasks[name];

  const head: Line[] = ask === "bad"
    ? [{ text: `assistantd hands this to ${name}` }, { text: "Policy: no capability matches “delete files”", ok: false }]
    : [{ text: `assistantd hands this to ${name}` }, { text: `Policy: ${cls} · ${rule[cls]}` }, { text: `Sandbox: ${sandboxLine(sandbox)}` }];
  const tail: Line[] = [{ text: act, ok: true }, { text: "Verified against what was promised", ok: true }, { text: "Logged and attributed to you", ok: true }];
  const needsOk = ask === "main" && cls === "SENSITIVE" && !approved; // sensitive agents stop for your approval before acting
  const lines = ask === "bad" || needsOk ? head : [...head, ...tail];

  useEffect(() => {
    if (phase !== "running") return;
    const t = window.setInterval(() => setShown(n => {
      if (n + 1 >= lines.length) {
        window.clearInterval(t);
        setPhase(ask === "bad" ? "blocked" : needsOk ? "await" : "done");
      }
      return n + 1;
    }), 650);
    return () => window.clearInterval(t);
  }, [phase, ask, cls, approved]); // eslint-disable-line react-hooks/exhaustive-deps

  const run = (k: "main" | "bad") => { setAsk(k); setApproved(false); setShown(0); setPhase("running"); };
  const choose = (i: number) => { setPick(i); setAsk(""); setApproved(false); setShown(0); setPhase("idle"); };
  const approve = () => { setApproved(true); setPhase("running"); };

  return <div className="demo">
    <div className="demo-bar mono"><span>DESIGN EXAMPLE</span><span>scripted · no model and no agent runtime exist yet</span></div>
    <div className="demo-body">
      <div className="demo-pick">
        <h3 className="mono">1 · Choose an agent</h3>
        <ul>{children.map(([n, c], i) => {
          const icon = agentIcons.find(a => a.name === n)!;
          return <li key={n}><button type="button" className={`k-${c.toLowerCase()}`} aria-pressed={pick === i} onClick={() => choose(i)}><Pixels rows={icon.rows} /><span>{n}</span></button></li>;
        })}</ul>
      </div>
      <div className="demo-chat">
        <header><Pixels rows={agentIcons.find(a => a.name === name)!.rows} /><div><h3>{name}</h3><p className="mono"><b className={`k-${cls.toLowerCase()}`}>{cls}</b> · {classNote[cls]}</p></div></header>
        <div className="demo-feed" aria-live="polite">
          {ask === "" && <div className="demo-ask"><h4 className="mono">2 · Ask it to do something</h4>
            <button type="button" onClick={() => run("main")}>“{askText}”</button>
            <button type="button" className="demo-bad" onClick={() => run("bad")}>“{bad}”<i className="mono">try something it must refuse</i></button></div>}
          {ask !== "" && <>
            <p className="demo-you">{ask === "main" ? askText : bad}</p>
            <ol className="demo-log">{lines.slice(0, shown).map((l, i) => <li key={i} className={l.ok === false ? "no" : l.ok ? "ok" : ""}>{l.text}</li>)}</ol>
            {phase === "await" && <div className="demo-approve"><p>This agent wants to change something. <b>Do you approve, once?</b></p><div><button type="button" className="st-yes" onClick={approve}>Approve once</button><button type="button" className="st-no" onClick={() => setPhase("denied")}>Deny</button></div></div>}
            {phase === "done" && <p className="demo-result"><b>Result</b>{result}</p>}
            {phase === "denied" && <p className="demo-result demo-stop"><b>Nothing ran</b>No grant was issued, and the agent cannot retry on its own.</p>}
            {phase === "blocked" && <p className="demo-result demo-stop"><b>Denied. Nothing ran</b>No agent has a capability for this, so it can’t even be attempted.</p>}
            {(phase === "done" || phase === "denied" || phase === "blocked") && <button type="button" className="st-again mono" onClick={() => { setAsk(""); setPhase("idle"); setShown(0); }}>↺ Ask something else</button>}
          </>}
        </div>
      </div>
    </div>
    <p className="demo-core mono">Behind every agent: overlay → assistantd → Policy module → system-agentd. A model only proposes; policy re-checks everything. Children do not spawn or talk to each other in V1.</p>
  </div>;
}

// Visual agent builder demo. It is scripted: the builder, the grant model and agent runtime are not built yet.
type Group = "start" | "think" | "tool" | "out";
type Block = { id: string; group: Group; label: string; hint: string; icon: string; cls?: "OBSERVE" | "NORMAL" | "SENSITIVE" | "CRITICAL" };
const ic = (n: string) => agentIcons.find(a => a.name === n)!.rows;
const play = ["010000000", "011000000", "011100000", "011110000", "011111000", "011110000", "011100000", "011000000", "010000000"];
const check = ["001111100", "011000110", "110000211", "110002011", "112020011", "110200011", "011000110", "001111100", "000000000"];
const blocks: Block[] = [
  { id: "ask", group: "start", label: "When I ask", hint: "Runs when you start it.", icon: "play" },
  { id: "local", group: "think", label: "Local model", hint: "Runs on your machine. The default.", icon: "assistantd" },
  { id: "cloud", group: "think", label: "Cloud model", hint: "Only with your consent, never a silent fallback.", icon: "assistantd" },
  { id: "proj", group: "tool", label: "Open a project", hint: "workspace.open · a project you added", icon: "overlay", cls: "NORMAL" },
  { id: "run", group: "tool", label: "See what's running", hint: "processes.list · your own programs", icon: "Performance", cls: "OBSERVE" },
  { id: "space", group: "tool", label: "See what uses space", hint: "storage.analyze · approved projects", icon: "Data / Service", cls: "OBSERVE" },
  { id: "clean", group: "tool", label: "Clean app caches", hint: "storage.clean · only previewed caches", icon: "Environment", cls: "SENSITIVE" },
  { id: "update", group: "tool", label: "Update the system", hint: "system.update · full update only", icon: "Dependency", cls: "CRITICAL" },
  { id: "show", group: "out", label: "Show me the result", hint: "Reports back to you.", icon: "check" },
];
const rowsFor = (b: Block) => b.icon === "play" ? play : b.icon === "check" ? check : ic(b.icon);
const order: Group[] = ["start", "think", "tool", "out"];
const groupTitle: Record<Group, string> = { start: "Start", think: "Think", tool: "Do", out: "Report" };

export function BuildYourOwn() {
  const [chain, setChain] = useState<string[]>([]);
  const [name, setName] = useState("My agent");
  const [done, setDone] = useState(false);
  const [note, setNote] = useState("");
  const by = (id: string) => blocks.find(b => b.id === id)!;
  const nodes = chain.map(by).sort((a, b) => order.indexOf(a.group) - order.indexOf(b.group));
  const asks = nodes.filter(n => n.cls === "SENSITIVE" || n.cls === "CRITICAL");
  const has = (g: Group) => nodes.some(n => n.group === g);
  const checks: [string, boolean][] = [
    ["It has a start", has("start")], ["It has a model to think with", has("think")], ["It has at least one thing to do", has("tool")],
    ["It runs sandboxed, as you, never as root", true], ["Risky steps ask you first", true],
  ];
  const valid = checks.every(c => c[1]);
  const add = (b: Block) => {
    setDone(false); setNote("");
    setChain(c => b.group === "tool" || b.group === "out" && !c.includes(b.id) ? (c.includes(b.id) ? c : [...c, b.id]) : [...c.filter(id => by(id).group !== b.group), b.id]);
  };
  const remove = (id: string) => { setDone(false); setChain(c => c.filter(x => x !== id)); };
  const locked = () => setNote("Not available to any agent. There is no way to run a free-form command.");

  return <div className="demo build">
    <div className="demo-bar mono"><span>DESIGN EXAMPLE</span><span>the visual builder is not built yet · nothing here is saved</span></div>
    <div className="build-body">
      <aside className="build-palette" aria-label="Blocks">
        <h3 className="mono">1 · Pick blocks</h3>
        {order.map(g => <div key={g}><h4 className="mono">{groupTitle[g]}</h4>
          <ul>{blocks.filter(b => b.group === g).map(b => <li key={b.id}><button type="button" title={b.hint} className={b.cls ? `k-${b.cls.toLowerCase()}` : ""} onClick={() => add(b)}><Pixels rows={rowsFor(b)} /><span>{b.label}</span></button></li>)}
            {g === "tool" && <li><button type="button" className="build-lock" title="Never available" onClick={locked}><Pixels rows={ic("Security")} /><span>Run any command</span><i className="mono">LOCKED</i></button></li>}</ul></div>)}
      </aside>

      <section className="build-canvas" aria-label="Your agent">
        <header><h3 className="mono">2 · Connect them</h3><label className="mono">Name <input value={name} maxLength={28} onChange={e => { setName(e.target.value); setDone(false); }} /></label></header>
        {nodes.length === 0 ? <p className="build-empty">Click blocks on the left to build your agent. Try Start, Think, then something to do.</p>
          : <ol className="flow-nodes">{nodes.flatMap((n, i) => {
            const gate = n.cls === "SENSITIVE" || n.cls === "CRITICAL";
            const items = [] as React.ReactNode[];
            if (gate) items.push(<li key={`g-${n.id}`} className="node node-gate"><Pixels rows={ic("Policy module")} /><span>Ask me first</span><i className="mono">AUTO-ADDED{n.cls === "CRITICAL" ? " · + ADMIN PASSWORD" : ""}</i></li>);
            items.push(<li key={n.id} className={`node ${n.cls ? `k-${n.cls.toLowerCase()}` : ""}`}><Pixels rows={rowsFor(n)} /><span>{n.label}</span><i className="mono">{n.cls ?? groupTitle[n.group].toUpperCase()}</i><button type="button" aria-label={`Remove ${n.label}`} onClick={() => remove(n.id)}>✕</button></li>);
            return items;
          })}</ol>}
        {note && <p className="build-note" role="status">{note}</p>}
        <div className="build-register">
          {!done ? <button type="button" className="st-yes" disabled={!valid} onClick={() => setDone(true)}>Register “{name || "My agent"}”</button>
            : <div className="build-done" role="status"><b>“{name || "My agent"}” is ready.</b><span>Runs as you, sandboxed. {asks.length ? `Asks before: ${asks.map(a => a.label.toLowerCase()).join(", ")}.` : "It never changes anything."} Editing it later asks you again.</span><button type="button" className="st-again mono" onClick={() => setDone(false)}>✎ Edit</button></div>}
        </div>
      </section>

      <aside className="build-checks" aria-label="Safety checks" aria-live="polite">
        <h3 className="mono">3 · Safety checks</h3>
        <ul>{checks.map(([t, ok]) => <li key={t} className={ok ? "ok" : ""}>{t}</li>)}</ul>
        <p className="mono">Your agent can only ask for things on this list, and only gets what you approve.</p>
      </aside>
    </div>
    <p className="demo-core mono">Under the hood a built agent is saved as a small declarative file, never code. It can request capabilities but never declare its own authority, an edit asks for approval again, shared agents are untrusted, and with no sandbox available it fails closed.</p>
  </div>;
}
