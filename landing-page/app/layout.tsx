import Link from "next/link";
import { SiteNav } from "@/components/site-nav";
import type { Metadata } from "next";
import "@fontsource-variable/inter";
import "@fontsource-variable/jetbrains-mono";
import "./globals.css";
import "./marketing.css";
import "./sections.css";
import { DotField } from "@/components/dot-field";

export const metadata: Metadata = {
  title: "Axiom OS: a calm Linux workspace for developers",
  description:
    "Axiom owns the session, shell, apps and AI boundary, and reuses mature Linux for everything else. Pre-alpha, verified in QEMU. Status is published here, including what does not work.",
  openGraph: { title: "Axiom OS", description: "A calm Linux workspace for developers. Pre-alpha, with evidence." },
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <a className="skip" href="#main">Skip to content</a>
        <SiteNav />
        {children}
        <footer className="site-foot"><DotField still /><div className="wrap">
          <div className="sf-grid">
            <div className="sf-brand"><Link className="brand" href="/"><img src="/penguin.png" width={28} height={28} alt="" />Axiom OS</Link><p>A calm Linux workspace for developers. Real apps, honest evidence, and AI only when you ask for it.</p><span className="mono sf-status"><i aria-hidden="true" />In development · Pre-alpha</span></div>
            <nav aria-label="Explore"><h2 className="mono">EXPLORE</h2><Link href="/">Home</Link><Link href="/desktop/">Desktop</Link><Link href="/approach/">Approach</Link></nav>
            <nav aria-label="Project"><h2 className="mono">PROJECT</h2><Link href="/progress/">Progress</Link><Link href="/progress/#limits">Current limitations</Link><Link href="/roadmap/">Roadmap</Link></nav>
          </div>
          <div className="sf-base mono"><span>© 2026 Axiom OS</span><span>No public release yet. Nothing here is a hardware or release promise.</span></div>
        </div></footer>
      </body>
    </html>
  );
}
