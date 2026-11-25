# Unified catalogue: catalogue matching, ranking and source trust

Research only. Tags: [V] verified against the cited URL (or a search snippet from it, noted as such); [A] assumption, not checked.

## 1. Deduplication

**AppStream ids.** An AppStream component `<id>` is reverse-DNS (`{tld}.{vendor}.{product}`, e.g. `org.kde.gwenview`), must be unique across distributions and platforms, and only ASCII letters, digits, `.`, `-`, `_` are allowed [V https://freedesktop.org/software/appstream/docs/chap-Metadata.html]. Owning the domain is the uniqueness argument. The `.desktop` suffix is not part of `<id>`; it appears only in `<launchable type="desktop-id">` [V same page].

**Flathub ids.** Flathub app ids are normally the AppStream id. Verification ties the id's domain to the publisher (section 4), so `com.example.App` needs control of `example.com` [V https://docs.flathub.org/docs/for-app-authors/verification].

**Pacman to AppStream id.** Arch builds AppStream data with appstream-generator using the `archlinux` backend over the binary repos, and publishes it as `archlinux-appstream-data` [V https://ftp.fi.muni.cz/pub/linux/arch/other/packages/archlinux-appstream-data/HOWTO]. The HOWTO does not say how packages map to component ids, and I found no `provides` convention for AppStream ids [A: the mapping is done by the generator from metainfo files, not from pacman metadata]. `appstreamcli install <ID>` resolves an id to a package via the component index, which is "matched to their package names"; it does not document priority when both native and Flatpak exist [V https://man.archlinux.org/man/appstreamcli.1.en].

**Mismatch case: mousepad.** Upstream metainfo uses `org.xfce.mousepad` with launchable `org.xfce.mousepad.desktop` [V Debian copy, https://sources.debian.org/src/mousepad/0.7.0-1/org.xfce.mousepad.appdata.xml.in]. Older Ubuntu metadata used `mousepad.desktop` as the id [V https://appstream.ubuntu.com/focal/universe/metainfo/mousepad.html]. Flathub has a check for id mismatches on new apps only [V snippet, flathub-appstream-check discussion]. The Arch package `mousepad` has no shared id with the Flathub app unless the Arch index carries the same metainfo id [A].

**Match algorithm (proposed)**

1. Exact AppStream id equal across two sources: same app. Merge.
2. Native package resolved to an id through the distro AppStream index (`archlinux-appstream-data`): merge with the Flathub entry having the same id.
3. Launchable desktop-id equal to the flatpak id plus `.desktop` (e.g. `org.xfce.mousepad.desktop`): propose a merge, shown as "probable", user can confirm.
4. Curated override file (section 2) wins over all automatic matches, in both directions.
5. Name-only similarity: never merge. Show as "related".

**Never merge**

- Same display name, different publisher (for example a vendor build and a community repackage).
- Open-source build and proprietary build (`code` OSS build vs Microsoft VS Code) [A on package names].
- AUR package and an official repo package of the same name.
- Flatpak and native of the same name when the flatpak id points to a different product.
- Anything where the id is missing on one side: keep separate.

## 2. Name and identifier matching

Normalization for search only (never for merging): lowercase, strip punctuation and spaces, strip vendor noise ("for linux", "desktop", "app"), strip packaging suffixes (`-bin`, `-git`, `-stable`, `-beta`). Expect false positives: "code" matches Code OSS, VS Code, and many unrelated tools; "discord" matches clients and bots. Name equality is a ranking signal only.

Override file: `catalog-overrides.toml`, keyed by AppStream id, with explicit fields `pacman_pkg`, `flatpak_id`, `vendor_domain`, `reason`, `reviewed_by`, `date`. Every entry needs a reviewer and a reason; entries are reviewed when a source changes. Entries expire to "unlinked" if the id disappears upstream [A design].

## 3. Ranking

Transparent, additive, and shown on request. Proposed order (highest first):

1. Exact id match across sources (already merged).
2. Official publisher proven (Flathub verified, or distro-maintained repo).
3. Official distribution repo (vs AUR or Flathub-only).
4. Name match only.
5. Popularity as a tie-breaker, within one source only.

Popularity options:

- Flathub: the public API exposes an approximate 30-day install count per app, not user counts [V third-party description of the public API, https://apify.com/crawlerbros/flathub-scraper; the "installs_last_month" query appears in a Flathub forum thread, https://discourse.flathub.org/t/flathub-stats-number-of-downloads/1744]. Flathub staff say they count installs and updates, not active users [V same forum thread].
- Arch: pkgstats publishes per-package usage as a percentage of opted-in systems [V https://pkgstats.archlinux.de/]. The data is opt-in and anonymous.
- AUR: vote counts only [A].

Do not compare the flatpak install count with the pkgstats percentage; they measure different things. Do not show a number on a card unless the source is named next to it. If a source has no public count, show nothing.

## 4. Official publisher identification

**Flathub verified.** Proof of control of the app id's domain via `https://<domain>/.well-known/org.flathub.VerifiedApps.txt` or a DNS TXT record at `_flathub.<domain>`, or login with GitHub, GitLab, GNOME or KDE for those id prefixes [V https://docs.flathub.org/docs/for-app-authors/verification]. Flathub states verification confirms the app is "published by the original developer or an authorized party," and that all apps get the same safety review [V https://docs.flathub.org/blog/app-safety-layered-approach-source-to-user]. It is a publisher claim with proof, not a safety rating.

**Flathub unverified.** Many apps are unverified because they are third-party or not directly maintained by the upstream [V https://docs.flathub.org/docs/for-users/verification]. Trusted partners such as Mozilla and OBS may upload their own builds [V blog above]. The UI must not treat "unverified" as "bad".

**Arch.** Packages carry maintainer metadata; orphaned packages have no maintainer [A, not checked on the packaging pages]. Official repo membership is the distro's claim, backed by the signed package database.

**Vendor repos.** Provable only with a signing key fingerprint pinned at install time, plus the repo domain. Both can be checked; the domain alone is a claim [A].

**What the UI may say**

- "Verified by Flathub: publisher controls `example.com`" (proven).
- "In the Arch official repositories" (proven by repo membership).
- "Published by X according to the package metadata" (claimed).
- Never write "official" unless one of the two proofs above holds.

## 5. Outdated detection

- Arch: compare with `vercmp` [V https://man.archlinux.org/man/vercmp.8]. Epoch overrides everything; pkgrel is compared only if both sides have it; alpha/rc suffixes sort before the bare version.
- Flatpak: compare the installed release version with the newest `<release>` in the appstream data for the same remote and branch [A on the exact field name; check against AppStream release tags].
- Across sources: versions are not comparable. Vendor "1.100" and Arch "1.100-1" are different builds. "Outdated" means: installed version is older than the newest version from the same source it came from. Show the other source's version as information only.
- Arch repo may lag upstream; say "newer upstream release exists" only if upstream is known (not claimed by Arch).

## 6. Abandoned and suspicious sources

Flathub EOL criteria [V https://docs.flathub.org/docs/for-app-authors/maintenance]: upstream ended development or archived its repo; no upstream activity for 2 years without announcement; no Flathub maintainer or maintenance for 2 years; 3 runtime updates behind without explanation; critical bugs with no maintainer response; ToS violation. An EOL app is marked with `end-of-life` in `flathub.json` (message shown at install/update), and `end-of-life-rebase` points to a new id [V same page]. Flathub says EOL apps are no longer listed but still installable from the command line [V search snippet from Flathub forum, not fetched].

Signals the UI can honestly state:

- Flathub EOL flag with the publisher's message: shown verbatim.
- Last update date from the appstream release data: shown as a date, no label.
- Arch orphan status: "no maintainer listed" [A].
- Repo not updated in N months: a local threshold, displayed as "no update in N months", not as "abandoned".

The UI must not say "suspicious" or "malicious" based on these signals. It can say "no maintainer listed" or "end-of-life per publisher".

## 7. Avoiding duplicate installs

Detection:

- Native: `pacman -Q <pkg>` for each linked package.
- Flatpak: list installed app ids (`flatpak list --app`) and compare with the linked flatpak id [A on command syntax; verify before use].
- A merged card with two installed sources is a duplicate.

Resolution UI: show both installed versions and sandbox status; offer "keep this one" (removes the other only after confirmation); do not auto-remove. Note user data may live in different places (`~/.var/app/<id>` vs `~/.config`) [A].

## 8. Source differences to show

| Field | Arch repo | Arch AUR | Flathub | Vendor repo |
|---|---|---|---|---|
| Version | pacman version | pkgbuild version | appstream release | repo metadata |
| Sandbox | no | no | yes, static and portal permissions shown on Flathub [V blog] | depends |
| Download size | pacman download size [A] | n/a (built locally) | Flathub remote-info [A] | repo metadata |
| Update channel | stable/testing repos [A] | rolling, user-built | branch (stable/beta) [A] | vendor channel |
| Signature | pacman package signing keyring [A] | same; builds may be unsigned | Flathub signs builds [V blog] | key fingerprint if pinned |
| Publisher | distro maintainer | AUR maintainer | verified or unverified | vendor |

## 9. Default source recommendation

Official repo first, unless the user chooses otherwise, for three reasons: the distro signs and tests it, it updates with the system, and it integrates with the system's update and rollback path. Flathub first for GUI apps that the official repo lacks or ships old, when the app is verified or published by the vendor (for example Mozilla's Firefox build), and when sandboxing matters more than integration.

Exceptions:

- Proprietary apps with an official Flathub build and no official repo build: Flathub is the only publisher-provided option [A].
- Unverified Flathub or any AUR package: never the default.
- Security-sensitive apps (browsers, password managers) may default to the vendor source if proven.

## Worked examples

Names are realistic. Package names and availability are [A] unless noted.

**1. Visual Studio Code**
- Flathub `com.visualstudio.code`: publisher shown as Microsoft Corporation, labelled Unverified; the listing says it is the proprietary Microsoft build repackaged and not supported by Microsoft [V search snippet, https://flathub.org/apps/com.visualstudio.code].
- Arch AUR `visual-studio-code-bin` (community repackage of Microsoft's build) [A]. Arch official repo `code` (Code - OSS build) [A].
- Merged card: "Visual Studio Code" with two sources. Do not merge the Code OSS build with the Microsoft build. Show Flathub as "Unverified, Microsoft build, repackaged". Default: the Arch official repo entry if the user wants OSS, otherwise the vendor-built source with the unverified label visible. Open question: no vendor repo entry is proven here.

**2. Firefox**
- Flathub `org.mozilla.firefox`: Mozilla is a trusted partner that uploads its own builds [V blog]. Verified state [A, not checked].
- Arch official repo `firefox` [A]. Arch bug FS#79811 says the native AppStream data was generated from the desktop file and got the id wrong [V https://bugs.archlinux.org/task/79811].
- Merged card: one entry, id `org.mozilla.firefox`. Native shown as "Arch official repo", Flathub as "Mozilla build, sandboxed". Default: official repo (section 9), with Flathub one click away. Popularity from pkgstats within Arch only.

**3. Mousepad**
- Flathub `org.xfce.mousepad` [V https://flathub.org/el/apps/org.xfce.mousepad].
- Arch official repo `mousepad` [A]; the id link depends on the Arch AppStream index carrying `org.xfce.mousepad` [A].
- Merged card (if linked by the index or override): one entry, "probable" link. If not linked: two entries, related, not merged. Default: Arch repo. Test case for the matcher: the old `mousepad.desktop` id must not block a match.

**4. Spotify**
- Flathub `com.spotify.Client` [A]. Verified state [A].
- Arch AUR `spotify` (unofficial packaging of the official client) [A].
- Merged card: no safe merge with an official Arch package, because there is none [A]. Show Flathub as the sandboxed option, AUR as "community package, not from Spotify". No default from Arch; Flathub default if the user has Flathub enabled.

**5. Discord**
- Flathub `com.discordapp.Discord` [A]. Verified state [A].
- Arch official repo `discord` [A].
- Merged card: check the id link first; if the same id exists, one entry with two sources and the native shown as default. Flathub shown with its sandbox status. Popularity: none on the card unless the source supplies one.

## Open questions

1. Does Arch's AppStream index carry a usable id for every official package (mousepad, firefox, code)? Need to inspect `archlinux-appstream-data` output directly [not verified].
2. Is there a field in Flathub's public API for verified status and EOL, and is it stable? [not verified; only docs above]
3. Does Flathub's `com.visualstudio.code` remain unverified on the live page? The snippet may be stale.
4. Can a vendor repo be identified from its signing key fingerprint in a way users can check without trusting the UI?
5. Which popularity source is acceptable to show, given Flathub counts installs and pkgstats counts opt-in systems?
6. What is the exact `flatpak remote-info` field for download size and the appstream release field for versions? [not verified]
7. Who maintains the override file, and how are its entries reviewed over time?
