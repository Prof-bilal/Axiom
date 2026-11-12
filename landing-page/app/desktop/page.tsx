import type { Metadata } from "next";
import Link from "next/link";
import { galleries, hero } from "@/lib/data";
export const metadata: Metadata = { title: "Desktop | Axiom OS", description: "A real Wayland desktop with its own shell, Files, Settings and Terminal integration. Explore captures from the running system and previews of the installer." };
const pad = (n: number) => String(n).padStart(2, "0");
export default function Page() {
  return <main id="main" className="d-page">
    <header className="wrap d-hero">
      <p className="eyebrow">DESKTOP</p>
      <h1>Meet your workspace.</h1>
      <p className="lead">A real Wayland desktop with its own shell, Files, Settings and Terminal integration. The Phase 3 to 5 images are captures from retained QEMU runs; the Phase 6 images are renderer previews and are labelled as such.</p>
      <nav className="d-chips" aria-label="Jump to a phase">{galleries.map((g) => <a key={g.n} href={`#phase-${g.n}`}><span className="mono">P{pad(g.n)}</span> {g.title}</a>)}</nav>
      <figure className="d-hero-shot"><img src={hero.src} width={hero.w} height={hero.h} alt={hero.alt} /></figure>
    </header>

    {galleries.map((g) => <section key={g.n} id={`phase-${g.n}`} className="wrap d-phase" aria-labelledby={`t-${g.n}`}>
      <div className="d-side"><span className="mono accent">PHASE {pad(g.n)}</span><h2 id={`t-${g.n}`}>{g.title}</h2><p className="mono dim">{g.note}</p></div>
      <div className="d-shots">{g.items.map((s, i) => <figure key={s.src} className={i === 0 ? "d-first" : undefined}>
        <a href={s.src} target="_blank" rel="noreferrer"><img src={s.src} width={s.w} height={s.h} alt={s.alt} loading="lazy" /></a>
        <figcaption>{s.cap}</figcaption>
      </figure>)}</div>
    </section>)}

    <p className="wrap d-foot dim small">Phases 1 and 2 reached the same session, so they share the Phase 3 captures. Phase 0 is documents. The Phase 6 images are renderer previews, not captures of a live install. Phase 7 onward is not built.</p>
    <div className="wrap page-next"><Link href="/">← Back to Axiom</Link><Link href="/progress/">Explore progress →</Link></div>
  </main>;
}
