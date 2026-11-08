"use client";

import Link from "next/link";
import { useEffect, useRef, useState } from "react";

// Scripted answers; nothing here is a model. Status claims follow docs/PHASES.md.
const links: Record<string, [string, string][]> = {
  "When can I try it?": [["/progress/", "See the evidence"], ["/roadmap/", "Read the roadmap"]],
  "Is AI controlling my computer?": [["/approach/", "How the limits work"]],
};

export function FaqChat({ items }: { items: string[][] }) {
  const [pick, setPick] = useState(0);
  const [typing, setTyping] = useState(false);
  const timer = useRef(0);
  const first = useRef(true);

  const ask = (i: number) => {
    window.clearTimeout(timer.current);
    setPick(i);
    if (matchMedia("(prefers-reduced-motion: reduce)").matches) { setTyping(false); return; }
    setTyping(true);
    timer.current = window.setTimeout(() => setTyping(false), 700);
  };
  useEffect(() => { first.current = false; return () => window.clearTimeout(timer.current); }, []);

  const [q, a] = items[pick];
  return <div className="faq">
    <div className="demo-bar mono"><span>ASK AXIOM</span><span>written answers · not a chatbot</span></div>
    <div className="faq-body">
      <ul className="faq-list" aria-label="Questions">
        {items.map(([question], i) => <li key={question}><button type="button" aria-pressed={pick === i} onClick={() => ask(i)}><span className="mono">{String(i + 1).padStart(2, "0")}</span>{question}</button></li>)}
      </ul>
      <div className="faq-chat" aria-live="polite">
        <p className="faq-you">{q}</p>
        <div className="faq-reply">
          <img src="/penguin.png" width={36} height={36} alt="" />
          {typing ? <p className="faq-typing" aria-label="Typing"><i /><i /><i /></p> : <div className="faq-answer"><p>{a}</p>{links[q] && <div className="faq-links">{links[q].map(([href, t]) => <Link key={href} className="text-link" href={href}>{t} <span aria-hidden="true">↗</span></Link>)}</div>}</div>}
        </div>
      </div>
    </div>
  </div>;
}
