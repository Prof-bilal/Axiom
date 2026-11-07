import type { Metadata } from "next";
import Link from "next/link";
import { owned, reused, rules } from "@/lib/data";
export const metadata: Metadata = { title: "Approach | Axiom OS", description: "Familiar Linux foundations. An Axiom experience built around your work, with explicit limits on what automation can do." };
export default function Page() {
  return <main id="main" className="a-page">
    <header className="wrap d-hero">
      <p className="eyebrow">APPROACH</p>
      <h1>A desktop with a clear point of view.</h1>
      <p className="lead">Familiar Linux foundations. An Axiom experience built around your work, with explicit limits on what automation can do.</p>
    </header>

    <section id="idea" className="wrap x-sec" aria-labelledby="idea-title">
      <div className="x-head"><p className="eyebrow">01 · THE IDEA</p><h2 id="idea-title">Reuse the foundation.<br />Build the experience.</h2><p>Axiom brings the shell, core apps and system controls together as one desktop, with explicit boundaries between the interface, Linux services and future automation.</p></div>
      <div className="a-split">
        <div className="a-card"><span className="mono">REUSED, NOT REWRITTEN</span><ul className="a-tags">{reused.map((r) => <li key={r}>{r}</li>)}</ul><p>Replacing mature infrastructure needs research, an ADR and a rollback plan. It does not happen opportunistically.</p></div>
        <div className="a-card a-own"><span className="mono accent">OWNED BY AXIOM</span><dl>{owned.map(([k, v]) => <div key={k}><dt>{k}</dt><dd>{v}</dd></div>)}</dl></div>
      </div>
    </section>

    <section id="rules" className="wrap x-sec" aria-labelledby="rules-title">
      <div className="x-head"><p className="eyebrow">02 · RULES</p><h2 id="rules-title">Rules that do not bend.</h2><p>Written into the repository’s agent instructions. They gate every phase.</p></div>
      <ol className="a-rules">{rules.map(([t, d], i) => <li key={t}><span className="mono accent">{String(i + 1).padStart(2, "0")}</span><h3>{t}</h3><p>{d}</p></li>)}</ol>
    </section>

    <section className="wrap x-sec"><div className="a-aim"><span className="mono accent">THE AIM</span><p>A complete, installable core distribution first, followed by the security and AI layers.</p></div></section>

    <div className="wrap page-next"><Link href="/">← Back to Axiom</Link><Link href="/progress/">Explore progress →</Link></div>
  </main>;
}
