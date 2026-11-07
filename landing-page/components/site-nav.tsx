"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
const links = [["Home", "/"], ["Desktop", "/desktop/"], ["Approach", "/approach/"], ["Progress", "/progress/"], ["Roadmap", "/roadmap/"]];
export function SiteNav() {
  const pathname = usePathname();
  return <nav className="nav" aria-label="Primary"><div className="nav-inner"><Link className="brand" href="/" aria-label="Axiom home"><img src="/penguin.png" alt="" width={32} height={32} /><span>Axiom<span className="brand-os"> OS</span></span></Link><ul>{links.map(([label, href]) => <li key={href}><Link href={href} aria-current={pathname.replace(/\/$/, "") === href.replace(/\/$/, "") ? "page" : undefined}>{label}</Link></li>)}</ul><span className="nav-status mono">IN DEVELOPMENT</span></div></nav>;
}
