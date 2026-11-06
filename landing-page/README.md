# Axiom landing page

Next.js (App Router, static export). No runtime server, no CMS, no tracking.

```sh
npm install
npm run dev      # http://localhost:3000
npm run build    # static site in out/
```

All facts live in `lib/data.ts`. Update them from `docs/PHASES.md` and the
`docs/research/*/evidence.md` files, never from memory. Screenshots in
`public/shots/` are crops of the retained QEMU captures in
`docs/research/phase5/screenshots/`.

Page rules: no download button until redistribution is authorized (see
`THIRD_PARTY_NOTICES.md`), no source link while the repository is private, and
every limitation stays listed under "What does not work yet".
