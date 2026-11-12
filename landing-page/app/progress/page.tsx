import type { Metadata } from "next";
import Link from "next/link";
import { phases, measured, limits } from "@/lib/data";
export const metadata: Metadata = { title: "Progress | Axiom OS", description: "What works today, how it was tested, and the limitations still ahead. Axiom is currently a pre-alpha installable image." };
export default function Page() {
  const done = phases.filter((p) => p.status === "done");
  return <main id="main" className="p-page">
    <header className="wrap d-hero">
      <p className="eyebrow">PROGRESS</p>
      <h1>Built. Booted. Verified.</h1>
      <p className="lead">What works today, how it was tested, and the limitations still ahead. Axiom is currently a pre-alpha installable image.</p>
    </header>

    <section id="progress" className="wrap x-sec" aria-labelledby="done-title">
      <div className="x-head"><p className="eyebrow">WHAT’S DONE</p><h2 id="done-title">Progress, with evidence.</h2><p>A phase counts as done when a retained QEMU run passes. Code sitting in a branch does not count.</p></div>
      <ol className="p-line">{done.map((p) => <li key={p.n}>
        <span className="p-dot mono">{String(p.n).padStart(2, "0")}</span>
        <div className="p-body"><h3>{p.name} {p.date && <span className="mono dim">{p.date}</span>}</h3><p>{p.summary}</p>{p.evidence && <p className="p-ev mono">✓ {p.evidence}</p>}</div>
      </li>)}</ol>
    </section>

    <section className="wrap x-sec" aria-labelledby="measured-title">
      <div className="x-head"><p className="eyebrow">MEASURED</p><h2 id="measured-title">Numbers, honestly.</h2><p>First recorded run: software-rendered KVM guest, 2 GiB RAM, 2 vCPU.</p></div>
      <dl className="p-stats">{measured.map(([m, r, n]) => <div key={m}><dt>{m}</dt><dd className="mono">{r}</dd><dd className="p-note">{n}</dd></div>)}</dl>
      <p className="dim small p-caveat">One run on a loaded developer machine, with software rendering. A baseline to improve on, not a performance claim.</p>
    </section>

    <section id="limits" className="wrap x-sec" aria-labelledby="limits-title">
      <div className="x-head"><p className="eyebrow p-warn">LIMITS</p><h2 id="limits-title">What does not work yet.</h2><p>Published on purpose. If a claim is missing from the progress section, assume it is on this list.</p></div>
      <ul className="p-limits">{limits.map((l) => <li key={l}>{l}</li>)}</ul>
    </section>

    <div className="wrap page-next"><Link href="/">← Back to Axiom</Link><Link href="/roadmap/">See what comes next →</Link></div>
  </main>;
}
