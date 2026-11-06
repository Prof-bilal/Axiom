import type { NextConfig } from "next";
import path from "node:path";

// Static export: the page has no server needs, so any static host can serve `out/`.
// Root is pinned because this folder lives inside the big Axiom repo; without it
// Next walks the parent (iso/, docs/, worktrees) and the dev server can spin.
const config: NextConfig = {
  output: "export",
  reactStrictMode: true,
  turbopack: { root: path.resolve(import.meta.dirname) },
};
export default config;
