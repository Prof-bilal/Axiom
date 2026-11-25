# Hub trust and security model (research)

Status: research draft. No code or ADR changed. Labels: **[V]** verified against a fetched primary source (URL given); **[S]** seen only in a search snippet or secondary source, re-check before relying on it; **[A]** assumption or design judgment.

## 1. Package signatures

**pacman (Arch repositories).** pacman verifies OpenPGP signatures against a keyring built as a web of trust: master keys co-sign developer and packager keys, which sign packages [S](https://wiki.archlinux.org/title/Pacman/Package_signing). The default `TrustedOnly` setting accepts a key only if it is locally signed or has enough web-of-trust level [V](https://archlinux.org/pacman/pacman-key.8.html).
- Proves: the file is unchanged since a key in the local keyring signed it; the signer is whoever holds that key.
- Does not prove: that the upstream software is benign; that a build script was reviewed; that the packager account was not taken over; that the key was never misused.
- Disabling checks lets untrusted packages install [V](https://archlinux.org/pacman/pacman-key.8.html).
- Axiom: installed systems set `LocalFileSigLevel = Required` (ADR-032 amendment).

**Flathub / OSTree.** OSTree signs every commit and the summary; clients verify both on pull and abort on failure [S](https://lists.freedesktop.org/archives/flatpak/2019-June/001601.html). Known pitfall: one `--gpg-verify` switch covers both, and an untrusted key gives "GPG signatures found, but none are in trusted keyring" [S](https://discourse.flathub.org/t/enterprise-or-corporate-private-flathub-setup/189).
- Proves: content came from the repository key holder and was not altered in transit.
- Does not prove: the app is safe, or that the repository key holder is the upstream developer. Flathub's key is the single trust anchor for every app in it.

**GitHub artifact attestations (Sigstore).** An attestation records which workflow built an artifact from which commit. `gh attestation verify` checks it [V](https://docs.github.com/actions/security-guides/using-artifact-attestations-to-establish-provenance-for-builds), [S](https://cli.github.com/manual/gh_attestation_verify). Public repositories use the Sigstore Public Good instance. The docs state attestations are not a guarantee that an artifact is secure [S](https://docs.github.com/en/actions/concepts/security/artifact-attestations).
- Proves: built by this workflow from this repository and commit.
- Does not prove: the source is safe, the workflow was not altered, or the maintainer account was not hijacked.

**cosign.** Same class (signing of blobs and images, keyless or key-based). Not fetched in this pass [A]; verify its docs before any design relies on it.

**minisign.** Ed25519 signature over a file; the trusted comment is covered by a global signature. Verify with `minisign -Vm <file> -P <pubkey>` or `-p <pubkeyfile>`. Key distribution and identity are not part of the tool [V](https://jedisct1.github.io/minisign/).
- Proves: the holder of the matching secret key signed this file.
- Does not prove: who that holder is. Key provenance is Axiom's job. ADR-032 ships the public key under `/usr/share/axiom/keys/`; the amendment notes it is not yet shipped.

## 2. Checksums

A checksum fetched from the same place as the download proves transfer integrity only: corruption, truncation, CDN errors. If an attacker controls the release page, they control the checksum too. A checksum becomes an authenticity check only when it arrives on a separate trust channel, such as a signed file or metadata from a different host [A].

AppImage tooling shows the same limit. A `.zsync` or `.DIGEST` match proves the file matches what the developer published [S](https://www.linuxcompatible.org/story/how-am-995s-checksum-verification-keeps-appimages-safe-and-sound). A forum argument says an attacker with server access could forge matching zsync data until signatures are enforced [S, unverified forum claim].

Rule: checksums detect corruption. They never establish who published the file.

## 3. Publisher verification

- **Flathub.** The developer proves control of the app ID's domain, via a well-known URI or a DNS TXT record at `_flathub` [S](https://docs.flathub.org/docs/for-app-authors/verification). Verified apps show a blue tick [V](https://docs.flathub.org/docs/for-users/verification). Community or third-party apps cannot be verified [V](https://docs.flathub.org/docs/for-users/verification). `--subset=verified` limits a remote to verified apps [V](https://docs.flathub.org/docs/for-users/verification). Verification confirms the publisher controls the app ID. It is not a code review [A, from the mechanism].
- **Arch.** Packagers are known volunteers whose keys are in the keyring [S](https://wiki.archlinux.org/title/Pacman/Package_signing). AUR packages have no review step before publication [S](https://wiki.archlinux.org/title/AUR_User_Guidelines). Orphaned AUR packages can be adopted by anyone [S](https://thehackernews.com/2026/06/over-400-arch-linux-aur-packages.html).
- **GitHub.** Organisation ownership and verified domains are account features, not code audits [A]. Not fetched in this pass.

## 4. AUR build scripts (design for later; not in MVP)

- **What runs.** makepkg sources the PKGBUILD as the invoking user; its `prepare()`, `build()`, `check()` and `package()` functions run arbitrary commands, and `source=()` downloads from arbitrary hosts [A, standard makepkg behaviour; makepkg man page not fetched]. The `.install` script runs as root when pacman installs the package [A]. A malicious PKGBUILD therefore reaches user files and keys even without root.
- **ArchWiki guidance.** Check the PKGBUILD, `.install` files and other files in the repository for dangerous commands; if unsure, do not build; traurAUR and ks-aur-scannerAUR do not replace manual review [S](https://wiki.archlinux.org/title/AUR_User_Guidelines). The wiki page itself was not fetchable in this pass.
- **Campaigns.**
  - July 2025: three packages posing as Firefox variants carried RAT malware and were removed about two days after upload [S, search summary only; no primary URL captured, find the Arch news item before citing].
  - June 2026 ("Atomic Arch", named by Sonatype): attackers adopted orphaned packages and edited build instructions. Counts vary, from about 400 initially to over 1,500 [S](https://thehackernews.com/2026/06/over-400-arch-linux-aur-packages.html), [S](https://www.privacyguides.org/news/2026/06/12/around-1-500-aur-packages-compromised-with-rootkit-like-malware/). Reported payloads include a credential stealer and an optional eBPF rootkit [S](https://thenextweb.com/news/arch-linux-aur-malware-credential-stealer-supply-chain).
  - A later wave reportedly led to AUR adoption being disabled on 30 July 2026 [S, single source; confirm on Arch announcements].
- **Review burden.** Each update needs a diff against the last reviewed version. Check for new maintainers, new source hosts, changed checksums, `curl`/`wget` in build steps, and new `.install` content. This does not scale to many packages, which is the reason to keep AUR out of MVP [A].

## 5. AppImage trust

- **Signatures.** An embedded GPG signature can be displayed but is not validated by the format; an external tool must validate it [S](https://docs.appimage.org/packaging-guide/optional/signatures.html). Axiom's external minisign check (ADR-032) is the right shape.
- **Sandbox.** AppImage has no sandbox model; it runs with the user's permissions and file access [S](https://notabug.org/oSoWoSo/AM/src/9.6/docs/guides-and-tutorials/sandbox.md). The AppMan project moved from Firejail to Aisap, a bubblewrap front end. It is opt-in and not every app runs in it [S](https://github.com/ivan-hc/AppMan/releases).
- **Design.** Use `bwrap` per ADR-032 and show the sandbox state in the UI. Network stays shared by default, so an app with network access can still exfiltrate what it can read. Reading `~/.ssh` must be tested, not assumed [A].

## 6. Flatpak permissions

- `flatpak info --show-permissions NAME [BRANCH]` shows the static permissions from the manifest's `finish-args` [S](https://man.archlinux.org/man/flatpak-info.1.en.raw). `flatpak permission-show` is different: it lists dynamic grants in the portal permission store [S](https://developer.puri.sm/Librem5/Apps/Guides/Permissions/index.html).
- No stable output format for `--show-permissions` was found [S]. Parse it defensively and test it against real output.
- `finish-args` categories [V](https://docs.flatpak.org/en/latest/sandbox-permissions.html): `--filesystem`, `--socket`, `--device`, `--share`.
- Broad grants to flag [V](https://docs.flatpak.org/en/latest/sandbox-permissions.html): `--device=all`; `--filesystem=host`, `host-root`, `home`; `--socket=system-bus` or `session-bus`; `--socket=inherit-wayland-socket`; `--share=network`; `--socket=pulseaudio` (microphone).
- Portals [V](https://docs.flatpak.org/en/latest/sandbox-permissions.html) mediate file choosers, URI opening, notifications and screenshots, so apps need no blanket access for those.
- **Warning wording.** Describe what the manifest asks for: "Can read and write your home folder", "Can use all devices", "Can use the network without restriction". Say this is the request, not a verdict on the app.

## 7. Vulnerability data

- **OSV.** Query API at `https://api.osv.dev/v1/query` and `/v1/querybatch`, no authentication [S](https://osv.dev/). Offline bulk data sits in `gs://osv-vulnerabilities`, organised per ecosystem; osv-scanner can run offline after the download [S](https://google.github.io/osv.dev/faq). OSV does not mirror every CVE [S](https://google.github.io/osv.dev/faq). Arch and Flathub coverage in OSV is unverified [A].
- **Arch security tracker.** security.archlinux.org is the official tracker [S](https://security.archlinux.org/advisory). Its newest advisory seen is from May 2025, and a forum thread reports publication stopped in June 2025 [S]. Treat it as unreliable until checked. `arch-audit` is the community workaround [S].
- **Flathub advisories.** None found [A].
- **Offline.** Only the OSV dump is a usable offline vulnerability source found in this pass. The pacman database holds package versions, not vulnerabilities [A].

## 8. SBOM availability

Honest answer: no official SBOM for Arch repository packages or Flathub apps was found [S]. Nearby items: pacman BUILDINFO records [S](https://lists.reproducible-builds.org/pipermail/rb-general/2023-March/002897.html); cargo-cyclonedx in Arch extra generates CycloneDX for Rust projects [S](https://archlinux.org/packages/extra/x86_64/cargo-cyclonedx/); openEuler publishes SPDX files for its own flatpak RPM [S]. Axiom should show "No SBOM published" and must not promise one [A].

## 9. Malicious package detection

- **traur** (AUR PKGBUILD scoring): reported false positives include a benign package scored 5/100 for source-hash checks; the author admits false positives; one forum post calls the tool apparently abandoned [S](https://forum.endeavouros.com/t/new-rust-tool-traur-analyzes-arch-aur-packages-for-hidden-risks/78001). Another forum warns scanners create false confidence [S](https://forum.endeavouros.com/t/dont-overly-rely-on-aur-malware-scanners/80854).
- **ks-aur-scanner** (`aur-scan`): describes itself as detecting malicious PKGBUILDs; no false-positive data found [S](https://aur.archlinux.org/packages/ks-aur-scanner/).
- Both are heuristics over build scripts. They cannot see payloads fetched at build time or obfuscated logic [A].
- **Axiom must not claim detection.** Show "no scanner flagged this", never "safe" or "clean". Scanner output is advisory text only and never changes a trust class on its own [A].

## 10. Trust classes

Five classes. Policy follows ADR-032 (admin approval for system-wide installs and unsigned user-scope files; failed signatures blocked).

**Class 1: Official distribution repository.** Evidence: package from a configured official repo, signature valid under a key in the pacman keyring. Warning: "From the Arch Linux repositories. Signed by Arch packagers. Axiom does not audit the software." Extra confirmation: none beyond the admin approval that a system-wide install already needs.

**Class 2: Verified official publisher.** Evidence: Flathub blue tick (domain proof), or AppImage with a minisign signature from a key Axiom ships or the user imported with a fingerprint they confirmed. Warning: "Published by [name], verified for [domain]. This confirms who publishes it, not that it is bug-free." Extra confirmation: show permissions; user-scope install, no extra prompt unless broad permissions are present.

**Class 3: Established community repository.** Evidence: signed repository metadata (Flatpak GPG summary, OSTree commits) without the verified flag. "Established" needs criteria, such as a minimum age or publisher history [A, not defined yet]. Warning: "Published by a community or third party, not verified by the original developer. Axiom has not reviewed it." Extra confirmation: explicit confirm; permissions shown before install.

**Class 4: Unverified third-party source.** Evidence: no valid signature, or a file the user supplied, with a recorded sha256. Warning: "No signature. Not from a verified publisher. Install only if you trust the source." Extra confirmation: admin approval (ADR-032), a typed confirmation, and a sandbox. Unsandboxed installs must say so.

**Class 5: Suspicious or unsupported.** Evidence: failed signature, signature from an unknown key, domain mismatch, a maintainer change combined with changed download hosts or added `curl`/`wget`, or no reachable upstream. Warning: "Blocked. Axiom will not install this. [Reason]." Extra confirmation: no install path in the Hub. Any override belongs outside the UI and is audited [A].

## 11. Security warnings UX

Before install, show in plain language:
- Source and trust class, with the evidence checked (key name, fingerprint, domain).
- Permissions (Flatpak in plain words; AppImage as "sandboxed" or "not sandboxed").
- Changes since the last install, for updates.
- The audit ID.

Never claim: "safe", "malware-free", "scanned and clean", "audited", "secure", "sandboxed" when it is not, or any undo guarantee. Prefer "No signature found", "Signed by key X", "Not reviewed by Axiom", "Not sandboxed".

## 12. Required safeguards

1. No `curl | bash` and no shell strings. Argv only (ADR-032).
2. No script execution from metadata. Build scripts and `.install` scripts never run from the Hub UI. Any later AUR support runs only through the reviewed path.
3. Privileged actions only through `axiom-pkgd` via polkit (`org.axiom.installer.install`). The UI never runs as root.
4. Signature checks fail closed: pacman keyring for packages, minisign for AppImages, OSTree for Flatpak. A verification error is a block, not a warning.
5. Downloads land in a fresh empty directory, are hashed, verified, and then moved. Re-verify after the move to avoid time-of-check/time-of-use issues [A].
6. Public keys read-only in `/usr/share/axiom/keys/`; secret keys never in the repository.
7. Audit log: each install records source, trust class, evidence, decision, sandbox profile and file hash (ADR-032 format).

## Open questions

1. Who holds the Axiom minisign secret key, and how is rotation handled?
2. What is the exact criterion for "established" in class 3?
3. Does Axiom ship a Flathub remote by default, and does it default to `--subset=verified`?
4. Which Flatpak `--show-permissions` output format is stable across the versions in the ISO?
5. Can bubblewrap run AppImages that need FUSE on the target ISO, and is user-namespace support on by default?
6. Is there an official Arch statement on the 2026 AUR incident and the adoption freeze? Confirm before citing.
7. Does the Arch security tracker or an alternative feed have a current, machine-readable advisory source?
8. Which cosign and GitHub verified-domain details apply to Hub-listed projects? Not verified here.
9. Should a scanner (traur, ks-aur-scanner) ever feed the UI, and if so, as advisory text only?
