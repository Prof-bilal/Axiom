"use client";

import { useState } from "react";
import { Tag } from "@/components/idea-sections";

// Source: docs/ARCHITECTURE.md and lib/data.ts (owned / reused). Axiom builds the top; Linux provides the bottom.
type Owner = "axiom" | "linux";
type Layer = { name: string; owner: Owner; what: string; why: string; status?: "built" | "designed" | "planned"; note?: string };
const layers: Layer[] = [
  { name: "AI and security boundary", owner: "axiom", status: "planned", note: "Phases 11 and 12", what: "The limits around AI and permissions: what may run, who approved it, and a record of it.", why: "This is the safety model. It has to be Axiom's own, so nothing can quietly widen it." },
  { name: "Core apps", owner: "axiom", status: "built", note: "Phase 4", what: "Files, Settings, Software Center and Terminal integration.", why: "Everyday apps that match the rest of the desktop and talk to real system services." },
  { name: "Axiom Shell", owner: "axiom", status: "built", note: "Phase 3", what: "Panel, dock, launcher, notifications and the control centre, in one Quickshell/QML process.", why: "The part you actually see and use all day. It is the experience." },
  { name: "Platform services", owner: "axiom", status: "designed", what: "Narrow, individually authorized privileged operations.", why: "Each privileged action checks who asked, what, and on which target. No broad root access." },
  { name: "Compositor and session boundary", owner: "axiom", status: "built", note: "temporary harness", what: "Axiom owns the session boundary. labwc stands in as a temporary harness behind a documented adapter.", why: "The edge between apps, the shell and the system. The harness can be swapped without touching the rest." },
  { name: "Wayland, Mesa, PipeWire", owner: "linux", what: "The display protocol, graphics drivers and sound.", why: "Mature and widely tested. Apps already speak it, so we reuse it." },
  { name: "NetworkManager and BlueZ", owner: "linux", what: "Wi-Fi, networking and Bluetooth.", why: "Hardware networking is hard and already solved. Settings talks to it." },
  { name: "pacman", owner: "linux", what: "Package management on an Arch base.", why: "A proven way to install and update software." },
  { name: "systemd and udev", owner: "linux", what: "Starts services and handles devices as they appear.", why: "The standard system manager. Rebuilding it would add risk, not value." },
  { name: "Linux kernel and drivers", owner: "linux", what: "The core of the system: hardware, memory and processes.", why: "Maintained by thousands of people. Axiom reuses it as it is." },
];
const COLS = 36;

export function Foundation() {
  const [pick, setPick] = useState(2);
  const [show, setShow] = useState<"all" | Owner>("all");
  const l = layers[pick];
  return <div className="fnd">
    <div className="demo-bar mono"><span>THE STACK</span>
      <span className="fnd-filter" role="group" aria-label="Filter layers">{([["all", "Everything"], ["axiom", "Built by Axiom"], ["linux", "Reused from Linux"]] as const).map(([k, t]) => <button type="button" key={k} aria-pressed={show === k} onClick={() => setShow(k)}>{t}</button>)}</span></div>
    <div className="fnd-body">
      <div className="fnd-stack" role="group" aria-label="Layers, top to bottom">
        {layers.map((x, i) => <div key={x.name} className="fnd-wrap">
          {(i === 0 || i === 5) && <h3 className={`mono fnd-head ${x.owner}`}>{x.owner === "axiom" ? "AXIOM BUILDS" : "LINUX PROVIDES"}</h3>}
          <button type="button" className={`layer ${x.owner}${x.status ? ` ${x.status}` : ""}${pick === i ? " on" : ""}${show !== "all" && show !== x.owner ? " dim" : ""}`} aria-pressed={pick === i} onClick={() => setPick(i)} onMouseEnter={() => setPick(i)} onFocus={() => setPick(i)}>
            <span className="layer-cells" aria-hidden="true">{Array.from({ length: COLS }, (_, c) => <i key={c} />)}</span>
            <strong>{x.name}</strong>
          </button>
        </div>)}
      </div>
      <aside className={`fnd-detail ${l.owner}`} aria-live="polite">
        <span className="mono accent">{l.owner === "axiom" ? "AXIOM BUILDS THIS" : "REUSED FROM LINUX"}</span>
        <h3>{l.name}</h3>
        <p>{l.what}</p>
        <div className="fnd-why"><span className="mono">{l.owner === "axiom" ? "WHY WE BUILD IT" : "WHY WE REUSE IT"}</span><p>{l.why}</p></div>
        {l.status && <Tag s={l.status} note={l.note} />}
      </aside>
    </div>
  </div>;
}
