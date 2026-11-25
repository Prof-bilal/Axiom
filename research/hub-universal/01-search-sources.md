# Hub 2.0 search sources: research (01)

Status: research only. Date of research 2026-11-25. Tags: **[V]** verified from a primary source (URL given); **[A]** assumption or unverified; **[X]** attempted, could not verify (fetch blocked or 404).

Note: several primary pages (Arch Wiki, archlinux.org API docs, flathub docs, search.nixos.org, Flatpak docs) returned bot-protection or 404 during fetching. Anything resting on those is marked [A] or [X].

## 1. Arch official repos (pacman)

- **Local search, no root, no sync** [V] `pacman -Ss <regexp>` searches "each package in the sync databases for names or descriptions", `-Si` shows info on a sync package, `-Qi` local package info, `-F` queries the files database. Source: https://man.archlinux.org/man/pacman.8
- [V] `-Qu` "works best if the sync database is refreshed using -Sy"; `-F -y` refreshes files DB. Refresh is needed only for freshness, not to search. Root is needed for `-Sy` writes [A]; the man page does not state root requirements for query ops.
- [V] Default DB dir `/var/lib/pacman/` (`DBPath`); sync DBs are `<repo>.db` under it [V partial: man page gives DBPath default; the `sync/` subdir is [A]]. Source: https://man.archlinux.org/man/pacman.conf.5
- [A] `expac` (third-party, reads the local/sync DB with custom format strings) can print name/version/size/license from the DB without parsing pacman output. Not fetched; verify on the expac project page before use.
- **Metadata available from sync DB** [V pacman man page for `-Si` fields; A on exact field list]: name, version, description, arch, URL, licenses, download size, installed size, depends, provides, conflicts, packager. Exact field list [A].
- **archlinux.org search API** [X] Endpoint `https://archlinux.org/packages/search/json/` returns JSON with keys `version`, `limit` (250 in the sample), `valid`, `results`. No documentation of query params (`name`, `q`, `repo`, `arch`), per-result fields, rate limit, or data licence was retrievable (Anubis block / no docs). Do not depend on it without checking the docs page or source (archweb repo).
- **Signing** [X] Repos use detached `.sig` per package; pacman `SigLevel` default is `Required TrustedOnly` [V: https://man.archlinux.org/man/pacman.conf.5]. Keys are managed by `pacman-key` with the `archlinux-keyring` package [A; the Arch wiki and keyring repo were blocked]. Source to check: https://wiki.archlinux.org/title/Pacman/Package_signing
- **Install / update / security model**: install via pacman (root, via polkit/helper in Axiom); update via `-Syu` (root, full upgrade). Security: signature-checked packages from repo, trusted by keyring [V on SigLevel, A on keyring model].
- **Arch rate limits**: none documented that we could verify [X]. Repo mirrors are used for sync, so sync should be cached and rate-limited by the Hub itself [A].
- **Maintenance burden**: low. Hub reads local sync DB; a refresh job runs as the privileged helper. Repo layout changes are rare [A].

## 2. Flathub

- **Repo layout and appstream** [V partial] Flathub publishes appstream refs; an install example shows `https://flathub.org/repo/appstream/fr.free.Homebank.flatpakref` (https://docs.flatpak.org/en/latest/repositories.html). [X] Could not verify `dl.flathub.org/repo/appstream` layout, `summary`/`summary.idx` format, or summary signing: the Flatpak "hosting a repository" page did not document file names. Flatpak tools themselves (`flatpak remote-ls --app`) read the summary without root for system remotes and can list app IDs and versions [A; not verified on docs].
- **Appstream as the catalog** [V] Software stores "like Flathub, GNOME Software, KDE Discover and even Flatpak CLI reads this combined AppStream catalog file." Source: https://docs.flathub.org/docs/for-app-authors/metainfo-guidelines
- **Component id** [V] MetaInfo `<id>` must match the Flatpak Application-ID exactly; reverse DNS is the convention (`org.example`). Same page.
- **Search** [V] Flathub website search depends on icons and screenshots being present for console apps (same page). [V] Forum thread (2021) says a public app list exists at `https://flathub.org/api/v1/apps`, and that no official query docs exist (https://discourse.flathub.org/t/does-flathub-expose-a-public-api-for-querying-applications/1765). [X] Current fetch of `flathub.org/api/v1/apps` returned 404, and no Flathub API docs/swagger page was found. Treat the API as **unverified and undocumented**.
- **Scope** [X] Whether Flathub includes only desktop apps: not verified (FAQ fetch 404). Flathub is a Flatpak remote for apps with a Flatpak manifest; CLI tools are included but Flathub's website prioritises desktop apps [A].
- **Install**: `flatpak install` (user scope, no root for `--user`) [A]. **Update**: `flatpak update` from the remote summary [A]. **Security**: sandboxed (Flatpak permissions), repo GPG-signed (`--gpg-sign` in `flatpak build-update-repo`, https://docs.flatpak.org/en/latest/hosting-a-repository.html; the summary sig filename is [X]). **Rate limits**: none documented [X]. **Download size**: available in the summary/ref data [A].
- **Maintenance burden**: medium. Parse appstream XML/gz from dl.flathub.org or let `flatpak` read the remote summary (preferred: no custom parser) [A].

## 3. AppImage / AppImageHub

- **Catalog** [V] AppImageHub is a community-maintained directory of tested AppImages; each entry is one `data/NAME` file linking to a repo, download dir or AppImage; maintainers merge PRs. Feeds: `https://appimage.github.io/feed.json`, `feed.xml`, `search.json` (https://github.com/AppImage/appimage.github.io).
- [V] "the data output format is not finalized yet and is subject to change any time without prior notice". Treat the feed as unstable.
- [V] AppImageHub "does not track versions (only channels such as release or nightly)", and gives no guarantees about the AppImages listed. So it is not a version source.
- **Update / zsync** [X] The AppImage update-information docs (`docs.appimage.org/packaging-guide/optional/updateinformation.html`) fetched with 404 on the tried path. Format strings such as `gh-releases-zsync|owner|repo|latest|*.AppImage.zsync` are [A] from memory: verify before implementing.
- **Verification** [A] AppImages can carry a detached signature (`zsign`/`gpg` ext) but there is no mandatory signing. Verify by checksum published by the vendor or GitHub release attestation.
- **Install / security**: user-space executable, no sandbox (unless via firejail/Flatpak wrap) [A]. Hub must treat it as untrusted code [A].
- **Maintenance burden**: medium-high: unstable feed, no versions.

## 4. GitHub Releases

- **REST endpoints** [V] `GET /repos/{owner}/{repo}/releases`, `GET /releases/latest`, `GET /releases/tags/{tag}`, `GET /releases/{release_id}`. Assets appear inside the release object with `browser_download_url`, `download_count` (https://docs.github.com/en/rest/releases/releases). [X] Asset-specific endpoints not confirmed on that page.
- **Auth headers** [V] `Accept: application/vnd.github+json`, `Authorization: Bearer <token>`, `X-GitHub-Api-Version`.
- **Rate limits** [V] Unauthenticated: 60 req/h per IP. Authenticated: 5,000 req/h (personal token/app). Secondary: ~80 content-creating req/min and 500/h; 900 points/min per REST endpoint (https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api). Implication: a search that fans out per repo must cache aggressively; unauthenticated use is not viable at scale.
- **Signatures/checksums** [V] Artifact attestations: `actions/attest` records build provenance; verify with `gh attestation verify <file> -R owner/repo` (https://docs.github.com/en/actions/security-for-github-actions/using-artifact-attestations/using-artifact-attestations-to-establish-provenance-for-builds). Adoption depends on each project. Checksum files (`SHA256SUMS`) and minisign/cosign are project-specific [A].
- **Install / update / security**: download asset, verify, install by user or helper. Only "verified" releases (attested or signed checksum from a known repo) should be shown, per the user's decision [A on policy wording].
- **Metadata**: name, tag, published date, asset name, size, download URL. Licence and arch: not in the release object; need repo metadata (`GET /repos/{owner}/{repo}` returns `license`) [A].
- **Maintenance burden**: high per-repo variance; needs an allowlist of verified repos.

## 5. Vendor repositories (Chrome, VS Code, etc.)

- [A] Most vendors publish apt/rpm repos with signed `Release`/`Packages` indexes, or only tarballs and `.deb`/`.rpm`. Google Chrome and VS Code publish Debian/RPM repos and, for Chrome, Flathub/Snap variants exist. None verified in this run [X].
- [A] There is no unified machine-readable catalog across vendors. Each vendor index is per-repo: searching means fetching and parsing each index.
- **Install**: distrobox per decision 028 (vendor `.deb`/`.rpm` inside a container, exported entry). **Update**: vendor repo or in-container package manager. **Security**: vendor signature only; repo key must be pinned.
- **Maintenance burden**: high; one parser per vendor. Recommend: list only a fixed allowlist of vendors.

## 6. Other catalogs

- **AppStream (freedesktop), system-wide** [V] Catalog XML/YAML and icon cache are defined in the AppStream spec; catalogs live at `/usr/share/swcatalog/xml` (distro-installed), `/var/lib/swcatalog/xml` (downloaded), `/var/cache/swcatalog/xml` (local), and plain or gzip XML is allowed (https://www.freedesktop.org/software/appstream/docs/chap-CatalogData.html). Component IDs are "short unique, lower-cased" with conventions per type; reverse-DNS is used in examples but not mandatory [V]. Best candidate for a local, offline, no-network metadata index; covers Flathub and distro apps if the distro ships AppStream data for pacman packages [A: Arch's `appstream` data for pacman packages is not verified].
- **Snap Store API** [X] Not fetched. Relevance: low for MVP (Snap not in MVP scope); skip unless the user adds it.
- **Nix search (search.nixos.org)** [X] Page fetch failed (404). Licence and rate limits are unverified. Relevance: out of MVP; reference only.
- **Homebrew formula JSON API (Linux)** [X] `https://formulae.brew.sh/api/formula.json` is too large for the fetch tool (10 MB cap). Its existence and format are [A] from Homebrew docs; the structure (fields `name`, `desc`, `license`, `versions`, `bottle`) is [A]. Good reference for a one-file index design.

## Which sources can be searched together without unreliable duplicates

- **Safe together now**: Arch sync DB (pacman) + Flathub appstream (once the file layout is verified). These have the strongest signing and lowest duplicate risk. Arch and Flathub overlap rarely in the same app ID space (Arch `firefox` vs Flathub `org.mozilla.firefox`), so they must be deduped by key, not by name.
- **Only with a curated allowlist**: GitHub Releases (per repo, must be verified), AppImageHub (unstable feed, no versions).
- **Not together in MVP**: vendor repos (per-vendor parsers), Snap/Nix/Homebrew (out of scope).

## Dedupe key recommendation

1. **Primary key: reverse-DNS component id** from appstream where available (e.g. `org.mozilla.firefox`), which Flathub enforces to equal the Flatpak App ID [V].
2. **Fallback: normalized name** for Arch packages with no appstream entry: lowercase, strip `-bin`, `-git`, `-appimage`, `-flatpak` suffixes, strip version-like tokens, map separators to `-`. This is a heuristic [A]; it can merge distinct packages, so show both and let the user choose.
3. **Source-scoped ID**: store `(source, native_id)`, e.g. `(arch, firefox)`, `(flathub, org.mozilla.firefox)`, `(github, owner/repo)`, so a group can be built without guessing.
4. Group by the primary key, but never auto-merge across sources when the name heuristic alone matches; show one row with source badges and let install pick the chosen source.

## Open questions

1. Confirm the archlinux.org package search JSON endpoint parameters, response fields, and data licence from the archweb source or docs (not reachable in this run).
2. Confirm the Flathub appstream and summary file layout on `dl.flathub.org`, and whether `flatpak remote-ls` is the preferred read path (no custom parser).
3. Confirm whether `flathub.org/api/v1/apps` still exists and whether its use is permitted (the 2021 forum thread asked for usage limits; no answer found).
4. Confirm AppImage update-information format strings and zsync verification steps from docs.appimage.org (404 in this run).
5. Confirm Arch signing details (`archlinux-keyring`, `pacman-key`, packager and master keys) and whether Axiom's pacman helper should pin keys itself.
6. Confirm whether Arch ships AppStream metadata for pacman packages (e.g. via a `appstream` package or `archlinux-appstream-data`). If yes, that becomes a no-scrape option for Arch.
7. Decide the "verified" bar for GitHub Releases: attestation only, or checksum file plus pinned signer.
8. Confirm expac fields and whether it is needed at all, since `pacman -Si`/`-Qi` may suffice.
9. Confirm the licence of Hub-displayed metadata from each source before showing it publicly.
