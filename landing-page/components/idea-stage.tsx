"use client";

import { useEffect, useRef, useState } from "react";
import { Tag } from "@/components/idea-sections";

// A scripted walk-through of the design. Nothing here runs; every line is a design example.
const proposal = [
  ["assistantd proposes", "free up space"],
  ["capability", "storage.clean"],
  ["scope", "package cache only"],
  ["class", "SENSITIVE · needs your approval"],
  ["recovery", "snapshot taken first"],
];
const approved = ["grant issued · one use, expires", "executed · storage.clean", "verified · freed space re-measured", "logged · attributed to you"];
type Phase = "wait" | "proposing" | "ready" | "approved" | "denied";

export function IdeaStage() {
  const root = useRef<HTMLDivElement>(null);
  const [phase, setPhase] = useState<Phase>("wait");
  const [shown, setShown] = useState(0);
  const [log, setLog] = useState(0);
  const reduced = useRef(false);

  useEffect(() => {
    reduced.current = matchMedia("(prefers-reduced-motion: reduce)").matches;
    const el = root.current;
    if (!el) return;
    if (reduced.current) { setShown(proposal.length); setPhase("ready"); return; }
    const observer = new IntersectionObserver(([e]) => { if (e.isIntersecting) { observer.disconnect(); setPhase("proposing"); } }, { threshold: .4 });
    observer.observe(el);
    return () => observer.disconnect();
  }, []);

  useEffect(() => {
    if (phase !== "proposing") return;
    const t = window.setInterval(() => setShown(n => {
      if (n + 1 >= proposal.length) { window.clearInterval(t); setPhase("ready"); }
      return n + 1;
    }), 520);
    return () => window.clearInterval(t);
  }, [phase]);

  useEffect(() => {
    if (phase !== "approved") return;
    if (reduced.current) { setLog(approved.length); return; }
    setLog(0);
    const t = window.setInterval(() => setLog(n => { if (n + 1 >= approved.length) window.clearInterval(t); return n + 1; }), 650);
    return () => window.clearInterval(t);
  }, [phase]);

  const again = () => { setLog(0); setShown(reduced.current ? proposal.length : 0); setPhase(reduced.current ? "ready" : "proposing"); };
  const decided = phase === "approved" || phase === "denied";
  return <div className="stage" ref={root}>
    <div className="stage-bar mono"><span>DESIGN EXAMPLE</span><span>nothing here runs · the AI layer is not shipped</span></div>
    <div className="stage-body">
      <section className="st-col st-ai" aria-label="The AI proposes">
        <h3 className="mono"><i aria-hidden="true" />AI proposes</h3>
        <dl className="st-card">{proposal.map(([k, v], i) => <div key={k} className={i < shown ? "on" : ""}><dt>{k}</dt><dd>{v}</dd></div>)}</dl>
        <p className="st-hint">A model only drafts a typed step. It holds no authority.</p>
      </section>

      <div className="st-link" aria-hidden="true"><i className={phase === "ready" || decided ? "go" : ""} /></div>

      <section className="st-col st-you" aria-label="You decide" aria-live="polite">
        <h3 className="mono"><i aria-hidden="true" />You decide</h3>
        {!decided && <div className="st-actions">
          <button type="button" className="st-yes" disabled={phase !== "ready"} onClick={() => setPhase("approved")}>Approve once</button>
          <button type="button" className="st-no" disabled={phase !== "ready"} onClick={() => setPhase("denied")}>Deny</button>
        </div>}
        {phase === "approved" && <ol className="st-log">{approved.map((l, i) => <li key={l} className={i < log ? "on" : ""}>{l}</li>)}</ol>}
        {phase === "denied" && <p className="st-denied"><b>Nothing ran.</b> No grant was issued. The model cannot retry on its own.</p>}
        {!decided && <p className="st-hint">{phase === "ready" ? "Your approval is required, and it works once." : "Waiting for a proposal…"}</p>}
        {decided && <button type="button" className="st-again mono" onClick={again}>↺ Run it again</button>}
      </section>
    </div>
    <div className="stage-foot"><Tag s="designed" note="Phase 12" /></div>
  </div>;
}
