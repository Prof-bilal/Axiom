import Link from "next/link";
import { HeroExperience, PageReveals } from "@/components/hero-experience";
import { AiPipeline } from "@/components/ai-pipeline";
import { FaqChat } from "@/components/faq-chat";
import { Foundation } from "@/components/foundation";
import { DevJourney } from "@/components/dev-journey";
import { Agents, BuildYourOwn } from "@/components/agents";
import { IdeaStage } from "@/components/idea-stage";
import { DotField } from "@/components/dot-field";
import { CapabilityGrid, LocalFirst, Pillars, PhaseTimeline } from "@/components/idea-sections";
import { questions } from "@/lib/home";

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

    <section className="x-sec" aria-labelledby="idea-title"><div className="wrap">
      <div className="x-head"><p className="eyebrow">THE IDEA</p><h2 id="idea-title">AI proposes.<br /><em>You decide.</em></h2><p>Axiom is designed around AI, with the limits built in first. This is the design. The AI layer is not shipped yet.</p></div>
      <IdeaStage />
      <Pillars />
    </div></section>

    <section className="x-sec" aria-labelledby="travel-title"><div className="wrap">
      <div className="x-head"><p className="eyebrow">HOW IT WORKS</p><h2 id="travel-title">How an AI request travels.</h2><p>Six steps, and the model is never the one in charge. Pick a step to see what it does, and what it can never do.</p></div>
      <AiPipeline />
    </div></section>

    <section className="x-sec" aria-labelledby="caps-title"><div className="wrap">
      <div className="x-head"><p className="eyebrow">THE LIMITS</p><h2 id="caps-title">Ten things AI can do.<br /><em>Nothing else.</em></h2><p>Everything AI can ever do is on this list. Each one is checked on its own, and anything risky asks you first. Below it, what stays locked for good.</p></div>
      <CapabilityGrid />
    </div></section>

    <section className="x-sec" aria-labelledby="agents-title"><div className="wrap">
      <div className="x-head"><p className="eyebrow">THE AGENTS</p><h2 id="agents-title">Meet the <em>agents.</em></h2><p>Choose an agent, ask it to do something, and watch how Axiom keeps it in bounds. It is a scripted demo of the design: no model and no agent runtime exist yet.</p></div>
      <Agents />
    </div></section>

    <section className="x-sec" aria-labelledby="byo-title"><div className="wrap">
      <div className="x-head"><p className="eyebrow">YOUR OWN</p><h2 id="byo-title">Build your <em>own agent.</em></h2><p>Snap blocks together, like a workflow tool. You choose how it starts, what it thinks with, and what it may do. It only ever gets what you approve.</p></div>
      <BuildYourOwn />
    </div></section>

    <section className="x-sec" aria-labelledby="dev-title"><div className="wrap">
      <div className="x-head"><p className="eyebrow">FOR DEVELOPERS</p><h2 id="dev-title">Built for people who build.</h2><p>Watch a blank disk become a working workspace. The first two layers already boot in QEMU; the rest are on the roadmap.</p></div>
      <DevJourney />
    </div></section>

    <section className="x-sec" aria-labelledby="local-title"><div className="wrap">
      <div className="x-head"><p className="eyebrow">PRIVACY</p><h2 id="local-title">Yours. <em>Local-first.</em></h2><p>Your data stays on your machine by default. A model provider is something you may add, never something you need.</p></div>
      <LocalFirst />
    </div></section>

    <section className="x-sec" aria-labelledby="stack-title"><div className="wrap">
      <div className="x-head"><p className="eyebrow">FOUNDATION</p><h2 id="stack-title">Proven Linux underneath.<br />Axiom on top.</h2><p>Pick any layer to see what it does and why Axiom reuses it or builds it. We build only the experience, session and safety layers.</p></div>
      <Foundation />
    </div></section>

    <section className="x-sec" aria-labelledby="status-title"><div className="wrap">
      <div className="x-head"><p className="eyebrow">STATUS</p><h2 id="status-title">Built. Booted. Verified.</h2><p>Phases 0 to 6 are complete, each booted in a real virtual machine. Phase 5 alone passed 76 automated checks. AI and security come later, in order.</p></div>
      <PhaseTimeline />
      <p className="x-links"><Link className="text-link" href="/progress/">See the evidence <span aria-hidden="true">↗</span></Link><Link className="text-link" href="/roadmap/">Read the roadmap <span aria-hidden="true">↗</span></Link></p>
    </div></section>

    <section className="wrap x-sec" aria-labelledby="faq-title">
      <div className="x-head"><p className="eyebrow">QUESTIONS</p><h2 id="faq-title">Straight answers.</h2><p>Pick a question. The answers are short and honest, including what isn’t built yet.</p></div>
      <FaqChat items={questions} />
    </section>

    <section className="closing-band" aria-labelledby="closing-title"><DotField /><div className="closing-inner"><p className="eyebrow">EARLY DAYS. BIG IDEAS.</p><h2 id="closing-title">Axiom is just<br />getting started.</h2><p>A new Linux desktop is taking shape for people who love to make things.</p><div className="x-cta"><Link className="btn primary" href="/progress/">See the evidence <span aria-hidden="true">↗</span></Link><Link className="btn" href="/roadmap/">Read the roadmap</Link></div><span className="mono closing-status">In development · No public download yet</span></div></section>
  </main>;
}
