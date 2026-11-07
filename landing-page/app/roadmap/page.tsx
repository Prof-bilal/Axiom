import type { Metadata } from "next";
import Link from "next/link";
import { phases } from "@/lib/data";
export const metadata: Metadata = { title: "Roadmap | Axiom OS", description: "An installable Linux system, then deeper developer tools, security and optional AI. Follow the work in dependency order." };
const pad = (n: number) => String(n).padStart(2, "0");
export default function Page() {
  const next = phases.filter((p) => p.status === "next");
  const planned = phases.filter((p) => p.status === "planned");
  return <main id="main" className="r-page">
    <header className="wrap d-hero">
      <p className="eyebrow">ROADMAP</p>
      <h1>A useful desktop comes first.</h1>
      <p className="lead">An installable Linux system, then deeper developer tools, security and optional AI. Follow the work in dependency order.</p>
    </header>

    <section id="roadmap" className="wrap x-sec" aria-labelledby="next-title">
      <div className="x-head"><p className="eyebrow">UP NEXT</p><h2 id="next-title">One step at a time.</h2><p>The order changed on 2026-11-06: a complete, installable core distro comes before the security and AI layers. Dependency order, not dates.</p></div>
      {next.map((p) => <article key={p.n} className="r-next"><div><span className="mono r-pill">NEXT · NOT YET AUTHORIZED</span><h3><span className="mono">PHASE {pad(p.n)}</span> {p.name}</h3></div><div><p>{p.summary}</p>{p.evidence && <p className="mono r-exit">{p.evidence}</p>}</div></article>)}
    </section>

    <section className="wrap x-sec" aria-labelledby="planned-title">
      <div className="x-head"><p className="eyebrow">PLANNED</p><h2 id="planned-title">Then, in order.</h2><p>Nothing below is built yet. These are intentions, not promises.</p></div>
      <ol className="r-grid">{planned.map((p) => <li key={p.n}><span className="mono accent">{pad(p.n)}</span><h3>{p.name}</h3><p>{p.summary}</p></li>)}</ol>
    </section>

    <div className="wrap page-next"><Link href="/">← Back to Axiom</Link><Link href="/progress/">Explore progress →</Link></div>
  </main>;
}
