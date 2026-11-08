"use client";

import { useEffect, useRef, useState } from "react";
import { Pixels } from "@/components/idea-sections";

// Every step is a design commitment from docs/ai/AI_ARCHITECTURE.md and docs/SECURITY.md.
// No AI runtime exists yet, so the section is labelled as design throughout.
const steps = [
  { t: "Ask", d: "You ask in plain words, or a routine you set up runs.", never: "Nothing runs yet. Asking is not authority.", who: "overlay, running as you", ex: "“Free up some space.”",
    icon: ["011111110", "111111111", "112121211", "111111111", "011111110", "001100000", "000100000", "000000000", "000000000"] },
  { t: "Plan", d: "A model drafts a proposal as typed steps. It runs as you, never as root.", never: "Model output is never authority.", who: "assistantd, running as you", ex: "storage.clean · package cache",
    icon: ["000010000", "000010000", "000111000", "001111100", "111121111", "001111100", "000111000", "000010000", "000010000"] },
  { t: "Policy check", d: "Policy re-checks the capability, the scope and your consent. Each grant works once.", never: "No standing permissions.", who: "a checking step, not a daemon", ex: "SENSITIVE → approval needed",
    icon: ["111111111", "111111111", "111111211", "111112111", "112121111", "011211110", "001111100", "000111000", "000010000"] },
  { t: "Narrow executor", d: "A small service runs one typed capability at a time, with the grant you gave.", never: "No sudo, no shell, no free-form D-Bus call.", who: "session executor, or system-agentd for root steps", ex: "one capability · one grant",
    icon: ["000111000", "010111010", "111111111", "111000111", "111020111", "111000111", "111111111", "010111010", "000111000"] },
  { t: "Verify", d: "The result is checked against what was promised.", never: "Success is never assumed.", who: "", ex: "freed space re-measured",
    icon: ["001111100", "011000110", "110000211", "110002011", "112020011", "110200011", "011000110", "001111100", "000000000"] },
  { t: "Audit and recover", d: "The action is logged, and a snapshot is taken before changes where possible.", never: "No promise of universal undo.", who: "audit log, plus a separate root journal", ex: "logged · snapshot first",
    icon: ["111111111", "100000001", "122222001", "100000001", "122222221", "100000001", "122200001", "100000001", "111111111"] },
] as const;

export function AiPipeline() {
  const root = useRef<HTMLDivElement>(null);
  const timer = useRef(0);
  const [active, setActive] = useState(0);
  const reduced = useRef(false);

  const stop = () => window.clearInterval(timer.current);
  const play = () => {
    stop();
    setActive(0);
    if (reduced.current) return;
    let i = 0;
    timer.current = window.setInterval(() => { i += 1; if (i >= steps.length) { stop(); return; } setActive(i); }, 1900);
  };

  useEffect(() => {
    reduced.current = matchMedia("(prefers-reduced-motion: reduce)").matches;
    const el = root.current;
    if (!el || reduced.current) return;
    // Walk the pipeline once when it scrolls into view.
    const observer = new IntersectionObserver(([e]) => { if (e.isIntersecting) { observer.disconnect(); play(); } }, { threshold: .4 });
    observer.observe(el);
    return () => { observer.disconnect(); stop(); };
  }, []);

  const pick = (i: number) => { stop(); setActive(i); };
  const s = steps[active];
  return <div className="pipe" ref={root}>
    <div className="pipe-bar mono"><span>HOW A REQUEST TRAVELS</span><span>designed · no AI runtime exists yet</span></div>
    <div className="pipe-track" role="group" aria-label="Pipeline steps">
      <div className="pipe-line" aria-hidden="true"><i className="pipe-packet" style={{ left: `${(active + .5) / steps.length * 100}%` }} /></div>
      {steps.map((st, i) => <button type="button" key={st.t} className={i === active ? "is-active" : i < active ? "is-done" : ""} aria-pressed={i === active} onClick={() => pick(i)} onMouseEnter={() => pick(i)} onFocus={() => pick(i)}>
        <span className="pipe-icon"><Pixels rows={[...st.icon]} /></span>
        <span className="mono pipe-n">{String(i + 1).padStart(2, "0")}</span>
        <strong>{st.t}</strong>
      </button>)}
    </div>
    <div className="pipe-detail" aria-live="polite">
      <div className="pd-main">
        <span className="mono accent">STEP {String(active + 1).padStart(2, "0")} OF 06</span>
        <h3>{s.t}</h3>
        <p>{s.d}</p>
        {s.who && <p className="pd-who mono"><b>Runs as</b> {s.who}</p>}
      </div>
      <div className="pd-side">
        <div className="pd-ex"><span className="mono">THE PACKET</span><code>{s.ex}</code></div>
        <div className="pd-never"><span className="mono">NEVER</span><p>{s.never}</p></div>
      </div>
    </div>
    <button type="button" className="pipe-replay mono" onClick={play}>↺ Replay</button>
  </div>;
}
