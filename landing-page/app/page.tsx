import Link from "next/link";
import { HeroExperience, PageReveals } from "@/components/hero-experience";
import { ImageCarousel } from "@/components/image-carousel";
import { aiRules, gallerySlides, owned, proof, questions, reused, showcase } from "@/lib/home";

export default function Page() {
  return <main id="main" className="home">
    <PageReveals />
    <HeroExperience />

    <section className="intro-band" id="introduction" aria-labelledby="intro-title">
      <div className="wrap intro-layout">
        <div className="intro-story">
          <h2 id="intro-title">Your computer. Your possibilities.<span className="intro-caret" aria-hidden="true" /></h2>
          <p>Your best ideas deserve a place to take shape. Axiom is a Linux desktop for developers and curious minds, bringing your apps, files and everyday tools into one thoughtful workspace.</p>
          <p>It’s a place to find your focus, make the details your own, and move naturally between the things you do every day. Familiar where it matters, considered all the way through.</p>
          <p>And as Axiom grows, we imagine AI that can lend a hand while you stay in charge. Optional assistance. Your boundaries. A computer that still feels like <em>your computer.</em></p>
        </div>
        <aside className="intro-statement" aria-label="The Axiom philosophy">
          <span className="statement-mark" aria-hidden="true">↗</span>
          <p className="statement-copy">The tools should feel connected.<br />The space should feel personal.<br /><span>The possibilities should feel yours.</span></p>
          <div className="statement-signature"><img src="/penguin.png" width={46} height={46} alt="" /><div><strong>The Axiom idea</strong><span>A little more intention. A lot more you.</span></div></div>
        </aside>
      </div>
    </section>

    <section className="x-proof" aria-label="Project status"><div className="wrap x-proof-grid">
      {proof.map(([n, l]) => <div key={l}><strong>{n}</strong><span>{l}</span></div>)}
    </div></section>

    <section className="wrap x-sec" aria-labelledby="apps-title">
      <div className="x-head"><p className="eyebrow">INSIDE THE DESKTOP</p><h2 id="apps-title">Real apps. Running today.</h2><p>Every screen below is a capture from Axiom booting in a virtual machine. No mockups.</p></div>
      <div className="x-bento">{showcase.map((s) => <article className={`x-tile x-${s.size}`} key={s.title}><img src={s.src} alt={s.alt} loading="lazy" /><div><span className="mono accent">{s.tag}</span><h3>{s.title}</h3><p>{s.text}</p></div></article>)}</div>
    </section>

    <section className="x-sec x-stack-sec" aria-labelledby="stack-title"><div className="wrap">
      <div className="x-head"><p className="eyebrow">HOW IT’S BUILT</p><h2 id="stack-title">Proven Linux underneath.<br />Axiom on top.</h2><p>We reuse what already works and build only the experience layer.</p></div>
      <div className="x-stack">
        <div className="x-layer x-own"><span className="mono accent">AXIOM BUILDS</span><ul>{owned.map((o) => <li key={o}>{o}</li>)}</ul></div>
        <div className="x-layer"><span className="mono">LINUX PROVIDES</span><ul>{reused.map((o) => <li key={o}>{o}</li>)}</ul></div>
      </div>
    </div></section>

    <section className="x-sec" aria-labelledby="ai-title"><div className="wrap x-ai">
      <div><p className="eyebrow">LOOKING A LITTLE FURTHER</p><h2 id="ai-title">AI, when it helps.<br /><em>Always your call.</em></h2><p className="x-note">A vision, not a feature. AI is not available yet.</p><Link className="text-link" href="/roadmap/">See what’s ahead <span aria-hidden="true">↗</span></Link></div>
      <div className="x-rules">{aiRules.map(([t, d]) => <div key={t}><h3>{t}</h3><p>{d}</p></div>)}</div>
    </div></section>

    <section className="wrap gallery-section" aria-labelledby="gallery-title">
      <div className="gallery-heading"><div><p className="eyebrow">A FIRST LOOK AT AXIOM</p><h2 id="gallery-title">Come on in.</h2></div><p>The desktop is taking shape.<br />Here’s a little look around.</p></div>
      <ImageCarousel slides={gallerySlides} />
    </section>

    <section className="wrap x-sec" aria-labelledby="faq-title">
      <div className="x-head"><p className="eyebrow">QUESTIONS</p><h2 id="faq-title">Straight answers.</h2></div>
      <div className="x-faq">{questions.map(([q, a]) => <details key={q}><summary>{q}</summary><p>{a}</p></details>)}</div>
    </section>

    <section className="closing-band" aria-labelledby="closing-title"><div className="closing-inner"><p className="eyebrow">EARLY DAYS. BIG IDEAS.</p><h2 id="closing-title">Axiom is just<br />getting started.</h2><p>A new Linux desktop is taking shape for people who love to make things.</p><div className="x-cta"><Link className="btn primary" href="/progress/">See the evidence <span aria-hidden="true">↗</span></Link><Link className="btn" href="/roadmap/">Read the roadmap</Link></div><span className="mono closing-status">In development · No public download yet</span></div></section>
  </main>;
}
