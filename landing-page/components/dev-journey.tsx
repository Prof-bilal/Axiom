"use client";

import { useEffect, useRef, useState } from "react";
import { Tag } from "@/components/idea-sections";

// Source: docs/PHASES.md (Phases 6, 7 and 9) and ADR-020/021. Installer and Developer Hub are verified in QEMU; the rest is planned.
const steps = [
  { t: "Install", status: "built", note: "Phase 6", d: "Go from a blank disk to an installed Axiom.",
    gets: ["A guided terminal installer", "Optional full-disk encryption", "Bootloader and your user account", "No autologin on installed systems"] },
  { t: "Developer Hub", status: "built", note: "Phase 6", d: "A first-boot job that sets up your developer workspace.",
    gets: ["Runs once, on first boot", "Driven by a catalog you can read", "Starts from a clean install"] },
  { t: "Toolchains", status: "planned", note: "Phase 9", d: "The languages and tools you need, ready to use.",
    gets: ["Curated toolchains and git", "Editors and a terminal workflow", "An optional security-tools set"] },
  { t: "Containers", status: "planned", note: "Phase 9", d: "Run and test projects in isolation.",
    gets: ["Containers for your projects", "Build and run samples in several languages"] },
  { t: "Snapshots", status: "planned", note: "Phase 7", d: "A safety net under everything.",
    gets: ["Btrfs snapshots before big changes", "Roll back after a bad update", "Never a promise of universal undo"] },
] as const;

const COLS = 28;
export function DevJourney() {
  const root = useRef<HTMLDivElement>(null);
  const timer = useRef(0);
  const reduced = useRef(false);
  const [step, setStep] = useState(0);

  const stop = () => window.clearInterval(timer.current);
  const play = () => {
    stop();
    setStep(0);
    if (reduced.current) { setStep(steps.length - 1); return; }
    let i = 0;
    timer.current = window.setInterval(() => { i += 1; if (i >= steps.length) { stop(); return; } setStep(i); }, 1700);
  };
  useEffect(() => {
    reduced.current = matchMedia("(prefers-reduced-motion: reduce)").matches;
    const el = root.current;
    if (!el) return;
    if (reduced.current) { setStep(steps.length - 1); return; }
    const observer = new IntersectionObserver(([e]) => { if (e.isIntersecting) { observer.disconnect(); play(); } }, { threshold: .4 });
    observer.observe(el);
    return () => { observer.disconnect(); stop(); };
  }, []);

  const pick = (i: number) => { stop(); setStep(i); };
  const s = steps[step];
  // Stack, bottom to top: install, hub, toolchains, containers. Snapshots wraps the whole stack.
  const stacked = [steps[3], steps[2], steps[1], steps[0]].map((st, k) => ({ st, idx: 3 - k }));
  return <div className="dev" ref={root}>
    <div className="demo-bar mono"><span>FROM A BLANK DISK</span><span>solid = built and verified in QEMU · dashed = planned</span></div>
    <div className="dev-body">
      <div className="dev-rail" role="group" aria-label="Steps">
        {steps.map((st, i) => <button type="button" key={st.t} aria-pressed={i === step} className={`${i <= step ? "is-on" : ""} ${st.status}`} onClick={() => pick(i)} onMouseEnter={() => pick(i)} onFocus={() => pick(i)}>
          <span className="mono">{String(i + 1).padStart(2, "0")}</span><strong>{st.t}</strong>
        </button>)}
      </div>
      <div className={`dev-disk${step >= 4 ? " net" : ""}`} aria-hidden="true">
        {stacked.map(({ st, idx }) => <div key={st.t} className={`band ${st.status}${step >= idx ? " lit" : ""}${step === idx ? " now" : ""}`}>
          <div className="cells">{Array.from({ length: COLS * 2 }, (_, c) => <i key={c} style={{ transitionDelay: `${(c % COLS) * 22}ms` }} />)}</div>
          <span className="mono">{st.t}</span>
        </div>)}
        <span className="net-tag mono">Snapshots · safety net</span>
      </div>
      <div className="dev-detail" aria-live="polite">
        <span className="mono accent">STEP {String(step + 1).padStart(2, "0")} OF 05</span>
        <h3>{s.t}</h3>
        <p>{s.d}</p>
        <ul>{s.gets.map(g => <li key={g}>{g}</li>)}</ul>
        <Tag s={s.status} note={s.note} />
        <button type="button" className="pipe-replay mono dev-replay" onClick={play}>↺ Replay</button>
      </div>
    </div>
  </div>;
}
