import { galleries, hero, limits, measured, owned, phases, reused, rules } from "@/lib/data";

const nav = [["Idea", "#idea"], ["Rules", "#rules"], ["Progress", "#progress"], ["Screens", "#screens"], ["Roadmap", "#roadmap"], ["Limits", "#limits"]];

function Head({ n, title, lead }: { n: string; title: string; lead?: string }) {
  return (
    <header className="head">
      <span className="mono dim">{n}</span>
      <h2>{title}</h2>
      {lead && <p className="lead">{lead}</p>}
    </header>
  );
}

export default function Page() {
  const done = phases.filter((p) => p.status === "done");
  const ahead = phases.filter((p) => p.status !== "done");
  return (
    <>
      <nav className="nav" aria-label="Primary">
        <a className="brand" href="#top"><img src="/penguin.png" alt="" width={32} height={32} /> <span>Axiom</span></a>
        <ul>{nav.map(([l, h]) => <li key={h}><a href={h}>{l}</a></li>)}</ul>
      </nav>

      <main id="main">
        <section id="top" className="hero wrap">
          <p className="mono status"><i aria-hidden /> pre-alpha · live image · 6 of 14 phases done</p>
          <h1>A calm Linux workspace<br />for developers.</h1>
          <p className="lead">
            Axiom owns the session, the shell, the apps and the line where AI is allowed to act.
            Everything underneath is mature Linux, reused on purpose.
          </p>
          <p className="cta">
            <a className="btn primary" href="#progress">See what works</a>
            <a className="btn" href="#roadmap">Read the plan</a>
            <span className="mono dim">No download yet. Redistribution is not authorized.</span>
          </p>
          <figure className="frame">
            <img src={hero.src} width={hero.w} height={hero.h} alt={hero.alt} fetchPriority="high" />
            <figcaption className="mono dim">Captured from QEMU at 1920×1080 on 2026-11-06. A real session, not a mockup.</figcaption>
          </figure>
        </section>

        <section id="idea" className="wrap">
          <Head n="01" title="The idea" lead="Most Linux desktops are a pile of parts with a theme on top. Axiom is one product with a clear owner for every behaviour, so a developer can say which layer is responsible when something happens." />
          <div className="split">
            <div>
              <h3>Reused, not rewritten</h3>
              <ul className="tags">{reused.map((r) => <li key={r} className="mono">{r}</li>)}</ul>
              <p className="dim">Replacing mature infrastructure needs research, an ADR and a rollback plan. It does not happen opportunistically.</p>
            </div>
            <div>
              <h3>Owned by Axiom</h3>
              <dl className="owned">{owned.map(([k, v]) => <div key={k}><dt>{k}</dt><dd>{v}</dd></div>)}</dl>
            </div>
          </div>
          <p className="aim">
            <span className="mono dim">Aim</span> A complete, installable core distribution first, in the way Kali and Omarchy are
            complete, and only then the security and AI layers on top of it.
          </p>
        </section>

        <section id="rules" className="wrap">
          <Head n="02" title="Rules that do not bend" lead="These are written into the repository’s agent instructions and gate every phase." />
          <ol className="rules">{rules.map(([t, d]) => <li key={t}><strong>{t}</strong> <span>{d}</span></li>)}</ol>
        </section>

        <section id="progress" className="wrap">
          <Head n="03" title="Progress, with evidence" lead="A phase counts as done when a retained QEMU run passes. Code sitting in a branch does not count." />
          <ul className="ledger">
            {done.map((p) => (
              <li key={p.n}>
                <span className="mono n">{String(p.n).padStart(2, "0")}</span>
                <div>
                  <h3>{p.name} {p.date && <span className="mono dim">{p.date}</span>}</h3>
                  <p>{p.summary}</p>
                  {p.evidence && <p className="mono ev">{p.evidence}</p>}
                </div>
              </li>
            ))}
          </ul>

          <h3 className="sub">Measured so far</h3>
          <div className="tablewrap">
            <table>
              <caption className="sr">First recorded run, software-rendered KVM guest, 2 GiB RAM, 2 vCPU</caption>
              <thead><tr><th scope="col">Metric</th><th scope="col">Result</th><th scope="col">Note</th></tr></thead>
              <tbody>{measured.map(([m, r, n]) => <tr key={m}><th scope="row">{m}</th><td className="mono">{r}</td><td className="dim">{n}</td></tr>)}</tbody>
            </table>
          </div>
          <p className="dim small">One run on a loaded developer machine, with software rendering. A baseline to improve on, not a performance claim.</p>
        </section>

        <section id="screens" className="wrap">
          <Head n="04" title="Screens, by phase" lead="Every image is a capture from a retained QEMU run. Click one for full size. Phases 1 and 2 were shown by the same image reaching a session, so they share the Phase 3 captures. Phase 0 is documents, and Phases 6 and up have nothing to show because nothing is built yet." />
          {galleries.map((g) => (
            <div key={g.n} className="gallery">
              <h3 className="sub"><span className="mono ph">Phase {String(g.n).padStart(2, "0")}</span> {g.title} <span className="mono dim note">{g.note}</span></h3>
              <div className="shots">
                {g.items.map((s) => (
                  <figure key={s.src} className="frame">
                    <a href={s.src} target="_blank" rel="noreferrer"><img src={s.src} width={s.w} height={s.h} alt={s.alt} loading="lazy" /></a>
                    <figcaption className="mono dim">{s.cap}</figcaption>
                  </figure>
                ))}
              </div>
            </div>
          ))}
        </section>

        <section id="roadmap" className="wrap">
          <Head n="05" title="Roadmap" lead="The order changed on 2026-11-06: a complete, installable core distro comes before the security and AI layers. Dependency order, not dates." />
          <ol className="road">
            {ahead.map((p) => (
              <li key={p.n} data-status={p.status}>
                <span className="mono n">{String(p.n).padStart(2, "0")}</span>
                <div>
                  <h3>{p.name} {p.status === "next" && <span className="mono pill">next · not yet authorized</span>}</h3>
                  <p>{p.summary}</p>
                  {p.evidence && <p className="mono ev">{p.evidence}</p>}
                </div>
              </li>
            ))}
          </ol>
        </section>

        <section id="limits" className="wrap">
          <Head n="06" title="What does not work yet" lead="Published on purpose. If a claim is missing from the progress section, assume it is on this list." />
          <ul className="limits">{limits.map((l) => <li key={l}>{l}</li>)}</ul>
        </section>
      </main>

      <footer className="wrap foot">
        <span className="mono dim">Axiom OS · pre-alpha · source is private for now</span>
        <span className="mono dim">Figures from the project’s own evidence files, last updated 2026-11-06.</span>
      </footer>
    </>
  );
}
