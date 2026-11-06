import type { Metadata } from "next";
import "@fontsource-variable/inter";
import "@fontsource-variable/jetbrains-mono";
import "./globals.css";

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
        {children}
      </body>
    </html>
  );
}
