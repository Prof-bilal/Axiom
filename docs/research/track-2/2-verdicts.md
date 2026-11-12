# Track 2, Agent 2 (Judge): build, bridge or kill

Date: 2026-11-09. Input: track2-agent1-candidates.md (94 rows).

## Method

- **Scores (1-5 each, total out of 20):** D = Demand (how many people need it), G = Gap (how bad today's Linux options are), B = Buildability (whether a one-developer-plus-AI team can ship a useful MVP in 3 months or less; clones of Photoshop, Office, CAD or a DAW score 1), F = Fit (developers, indie makers and Windows switchers; daily use beats niche).
- **What decides BUILD:** a row becomes BUILD only when G ≥ 3, B ≥ 3 and F ≥ 4. Axiom also has to have a structural advantage. Axiom owns the compositor, shell and automation boundary, so it can do things a third-party Wayland app cannot: global capture, window zones, input automation and a system-wide launcher. A high total with G ≤ 2 becomes BRIDGE, because a good alternative already exists.
- **BRIDGE** means one of four things: a tested Wine/Bottles preset, a web-app (PWA) preset, a curated Flatpak, or a pointer to a mature alternative. One cross-cutting piece of Axiom work covers many web-only rows: a sandboxed "install as web app" flow with notifications, tray and file handlers.
- **KILL:** the vendor is shipping Linux, the app uses kernel anti-cheat or platform lock-in, it is too large or too niche, or the problem is already solved or Windows-specific.
- **Evidence:** web searches of AlternativeTo, Phoronix, It's FOSS, OMG! Ubuntu, GamingOnLinux, vendor forums, WineHQ bug lists and community trackers (see Sources). reddit.com was blocked; secondhand snapshots of Reddit and Lemmy threads were used only as anecdotes.
- **Wine re-verification:** I re-checked the Wine status of the top candidates: Photoshop, Office/CrossOver, Fusion, Notepad++, Tally, Affinity, Fortnite/EAC, Studio One, Topaz and the WhatsApp wrappers. The WineHQ AppDB pages themselves could not be loaded, so the AppDB ratings below are secondhand.
- **Limits of the evidence:** I found no direct Google Trends data. Piracy rankings (FAST, the WinRAR search study, MUSO) are used only as a demand signal for Office, Adobe, WinRAR and IDM.

## BUILD (8 rows, 6 distinct Axiom apps), sorted by total

| Rank | Row(s) | Axiom app | D/G/B/F | Total |
|---|---|---|---|---|
| 1 | 67 ShareX | **Axiom Capture** (screenshot, annotate, OCR, quick record, upload) | 4/4/4/5 | 17 |
| 2 | 71 PowerToys (FancyZones, Run) | **Axiom zones and snap layouts** (compositor feature) | 4/4/4/5 | 17 |
| 3 | 44 Raycast / Alfred | **Axiom Launcher / command palette** | 4/3/4/5 | 16 |
| 4 | 72 AutoHotkey | **Axiom Automate** (hotkeys, remaps, text expansion, window rules) | 3/5/3/5 | 16 |
| 5 | 68 Snagit / CleanShot X | merged into **Axiom Capture** | 3/4/4/5 | 16 |
| 6 | 60 MobaXterm (absorbs 62 WinSCP as a feature) | **Axiom Connections** (SSH/SFTP/serial session workspace) | 3/3/4/5 | 15 |
| 7 | 43 Grammarly desktop | **Axiom Write** (local, opt-in writing help on selected text) | 4/4/3/4 | 15 |
| 8 | 70 Everything (voidtools) | merged into **Axiom Launcher** (instant filename index) | 3/2/5/4 | 14 |

1. **Axiom Capture (ShareX).** It is repeatedly named as "the Windows app I miss most". On Linux, the ShareX-style tools are either beta (ShotX 0.9.5b) or have experimental Wayland support (Flameshot calls GNOME and Plasma Wayland "experimental"), and a forum consensus says "there isn't really a perfect replacement". Axiom owns the compositor and portal path, so region and window capture, annotation (the Swappy/Satty pattern), OCR (Tesseract) and pluggable uploaders form a 2-3 month MVP. Evidence: AlternativeTo ShareX/Satty/Swappy pages, ShotX on PyPI, the Lemmy thread, It's FOSS.
2. **Zones and snap layouts (PowerToys).** No official port exists. Linux options are tied to one desktop (PlasmaZones for KDE, gTile/gSnap for GNOME) or are early Python projects (SnappyZones, PyXZones), and users say none matches the drag-and-snap workflow. Because Axiom owns window management, this is a compositor and shell feature rather than an extension hack. It is cheap to build and the first thing a Windows switcher notices. Evidence: the bmaupin "Linux FancyZones alternative" gist, AlternativeTo PlasmaZones, the Lemmy thread.
3. **Axiom Launcher (Raycast/Alfred, PowerToys Run, Everything).** Vicinae (C++, mostly Raycast-compatible extension API, AUR 0.20.15 in May 2026, packaged by Monolith OS in June 2026) shows both demand and a reference design. Axiom needs a launcher in its shell anyway. Build it as the shell's command palette, with structured actions, clipboard history and a plocate/FSearch-style filename index (row 70). Adopting Vicinae's extension API or embedding Vicinae instead of writing one is a valid cheaper path. Evidence: Vicinae docs and GitHub, the Show HN thread, AUR.
4. **Axiom Automate (AutoHotkey).** Wayland broke the X11 automation tools: AutoKey's Wayland support is still unreleased, wtype only types, and keyd only remaps. GNOME 49's GlobalShortcuts portal rejects non-Flatpak apps, and libei is still missing from xdg-desktop-portal-wlr. Axiom owns the compositor, so it can offer a narrow, auditable automation API that is authorized per action (hotkeys, remap, text expansion, window rules, app intents). This matches Axiom's "structured automation" pillar and its rules against arbitrary shell passthrough and unrestricted root. Buildability is 3 because the security review is real work. Evidence: AlternativeTo AutoHotkey for Linux, the AutoKey users group, the libei roadmap page, the Handy PR on GNOME's portal.
5. **Snagit/CleanShot.** Same app as ShareX, aimed at users who want polished annotations for documentation. It counts as part of Axiom Capture, not as a separate product.
6. **Axiom Connections (MobaXterm, WinSCP).** The Linux options are fragmented: Electerm (Electron), Asbru/PAC Manager (Perl/GTK, dated), Termius (proprietary) and Remmina (remote desktop only), and none is integrated with the desktop. A saved-sessions sidebar, SFTP browsing in Files through the existing GVfs path, key and agent management through the secrets service, and X11/Wayland forwarding toggles all sit on top of the existing Axiom Terminal. This is mostly UI over OpenSSH. Evidence: AlternativeTo MobaXterm, itslinuxfoss.
7. **Axiom Write (Grammarly).** Grammarly has no Linux desktop app, only browser extensions, so a writing assistant that works in every app is missing. Ship it as an explicit "improve selected text" action: the user selects text, and it is rewritten with LanguageTool and an optional local model. It must not watch keystrokes in the background, which preserves the privacy and AI-boundary rules and keeps the MVP small. The demand is broad, but only moderately specific to developers. Evidence: Agent 1 row 43; LanguageTool is the only native-adjacent option.
8. **Instant file search (Everything).** FSearch already covers most of what Everything does (gap = 2), so this is not a separate app. It is a filename-index provider inside the launcher and Files, at near-zero cost.

**Runners-up I considered and rejected for BUILD:** the PDF fill/sign/redact tool (row 8) scored 14, but ONLYOFFICE added a Redact tab in 2026 and Xournal++ already fills and signs. The Resolve transcode helper (row 21) scored 14 and should be a BRIDGE file-manager action. Figma (15) and Canva (14) have demand but a gap of 1, because the web apps work.

## BRIDGE (66 rows)

Format: `row app (D/G/B/F=total): bridge method`.

**Creative**
- 1 Photoshop (5/3/1/3=12): Photopea web preset, GIMP 3 and Krita Flatpaks. Patched-Wine installs still need custom builds and the patches were not fully upstream as of Feb 2026, so do not promise Photoshop support.
- 2 Lightroom Classic (4/2/1/3=10): darktable Flatpak, plus a guide to importing Lightroom catalogs and XMP sidecars.
- 3 Illustrator (4/3/1/3=11): Inkscape Flatpak, plus Affinity once its native Linux build ships.
- 4 InDesign (3/3/1/2=9): Scribus, plus Affinity Publisher once the Linux build ships. IDML import is still a known gap.
- 5 Premiere Pro (4/2/1/3=10): DaVinci Resolve or Kdenlive.
- 6 After Effects (3/4/1/3=11): Blender, plus Natron (stalled). The gap is real, but a clone would take years.
- 7 Audition (2/2/2/3=9): Audacity/Tenacity and ocenaudio Flatpaks.
- 10 CorelDRAW (3/3/1/2=9): Inkscape (partial CDR import). Use a Windows VM for production print shops.
- 11 Clip Studio Paint (3/2/1/2=8): Krita, plus a Wine preset (unverified).
- 12 Paint.NET (3/2/3/4=12): Pinta Flatpak.
- 13 Capture One (2/2/1/2=7): darktable or RawTherapee.
- 14 Sketch (2/1/1/3=7): Penpot or Lunacy (both have Linux builds), plus Figma web.
- 15 Figma desktop (5/1/4/5=15): web-app preset, plus a local-fonts helper (figma-agent-linux).
- 16 Canva desktop (5/1/4/4=14): web-app preset.
- 17 CapCut desktop (4/2/1/3=10): CapCut web preset, or Kdenlive.
- 18 Filmora (3/2/1/2=8): Kdenlive or Shotcut.
- 19 VEGAS Pro (2/2/1/2=7): Kdenlive or DaVinci Resolve.
- 20 Final Cut Pro (3/2/1/2=8): DaVinci Resolve. No Wine path exists.
- 21 DaVinci Resolve free (4/3/3/4=14): Flatpak or distrobox install script, plus a Files "Transcode for Resolve" action (ffmpeg to DNxHR/ProRes). Note that Studio adds the missing codecs.
- 22 Topaz Video/Photo AI (3/2/2/3=10): Upscayl, Real-ESRGAN and video2x. The Linux beta has been stale since February 2026.
- 23 3ds Max (2/2/1/2=7): Blender.
- 24 Cinema 4D (2/2/1/2=7): Blender.
- 25 ZBrush (2/2/1/2=7): Blender sculpting.
- 26 SketchUp Pro (3/3/1/2=9): SketchUp web, FreeCAD or Blender.
- 27 Ableton Live (3/2/1/3=9): Bitwig or REAPER (native).
- 28 FL Studio (4/2/1/3=10): tested Wine/Bottles preset (reported to work well), plus LMMS.
- 29 Cubase/Nuendo (2/2/1/2=7): REAPER or Bitwig.
- 30 Pro Tools (2/3/1/1=7): Ardour or Mixbus. iLok blocks Wine.
- 31 Logic/GarageBand (2/2/1/2=7): Bitwig, LMMS or Ardour.
- 33 VST plugins: Kontakt, Serum, RX (3/3/2/2=10): yabridge preset pinned to a known-good Wine version, plus native CLAP/LV2 plugins (Surge XT, Vital).

**Office and productivity**
- 8 Acrobat Pro (4/3/3/4=14): ONLYOFFICE PDF editor (redaction and signatures, 2026), Okular and Xournal++ (fill and sign). Master PDF Editor is paid.
- 34 MS Office (5/3/1/5=14): ONLYOFFICE or LibreOffice by default, the Office web-app preset, and CrossOver as a documented paid option (32-bit installer only; activation is flaky for personal accounts).
- 35 Outlook (4/3/1/4=12): Thunderbird (unverified: native Exchange support added in 2025), Evolution EWS, or the Outlook web preset.
- 36 OneNote (3/3/1/3=10): OneNote web preset; Xournal++ for pen input.
- 37 Visio (3/2/2/4=11): draw.io Flatpak, which imports VSDX.
- 38 MS Project (2/2/1/2=7): ProjectLibre.
- 40 Pages/Numbers/Keynote (2/2/1/2=7): iCloud web preset; LibreOffice imports these formats.
- 41 Notion desktop (4/1/4/5=14): web-app preset, plus AppFlowy or Anytype.
- 42 Evernote (2/1/4/3=10): web preset, plus Joplin's ENEX import.

**Engineering**
- 45 AutoCAD (4/3/1/2=10): BricsCAD (paid, native), LibreCAD or QCAD, plus the AutoCAD web preset.
- 48 Fusion (3/3/1/3=10): Onshape web preset. Do not ship the Wine script: it moved off GitHub to Codeberg in February 2026 and breaks on updates.
- 52 Altium (2/2/1/2=7): KiCad.
- 53 Proteus/Multisim (3/3/1/2=9): SimulIDE, or KiCad with ngspice, plus a Wine preset for coursework (unverified).
- 54 LTspice (3/2/1/3=9): tested Wine preset (reported to work), plus ngspice.
- 55 Keil and vendor IDEs (2/2/1/3=8): PlatformIO, or STM32CubeIDE (native).

**Developer**
- 57 Visual Studio (3/3/1/4=11): JetBrains Rider, or VS Code with C# Dev Kit. The WinForms/WPF designer gap cannot be built.
- 59 SSMS (3/2/1/4=10): VS Code mssql extension (Microsoft's official path after Azure Data Studio retired on 28 Feb 2026), or DBeaver.
- 61 Notepad++ (4/1/1/4=10): Wine preset (secondhand reports of an AppDB Platinum rating), plus Kate or CudaText.
- 62 WinSCP (3/1/1/4=9): Files SFTP through GVfs, or FileZilla. Also absorbed into Axiom Connections.
- 63 HeidiSQL (2/1/1/4=8): Wine preset, DBeaver or Beekeeper Studio.
- 64 Fork/Tower (3/2/2/5=12): Sublime Merge, GitKraken or GitButler (all native). Fork has no Linux build as of September 2026.
- 65 Dash/Proxyman/Paw (2/2/2/4=10): Zeal, mitmproxy (web UI) and Bruno.

**Utilities**
- 66 IDM (4/2/3/3=12): Free Download Manager (native), Motrix or Persepolis.
- 69 Camtasia/Bandicam (3/3/1/4=11): OBS plus OpenScreen (MIT, AppImage, auto-zoom), with editing in Kdenlive. Axiom Capture covers quick clips.
- 73 WinRAR/7-Zip GUI (4/1/4/4=13): libarchive-backed "Extract/Compress" in Files, plus PeaZip. Already solved upstream.
- 74 Rufus (3/1/3/3=10): Impression or Fedora Media Writer (Flatpak), plus Ventoy.
- 76 HWiNFO/CPU-Z/Afterburner (3/3/2/3=11): CPU-X, CoolerControl and LACT Flatpaks. Building this would need a privileged daemon, which Axiom rules make expensive.
- 77 Macrium/EaseUS/MiniTool (3/2/2/3=10): Axiom's own snapshot and recovery roadmap, plus Rescuezilla and GParted.

**Communication, finance, education, regional**
- 79 WhatsApp Desktop (5/3/2/4=14): WhatsApp Web preset (the ZapZap pattern). Calls are not available on any Linux path; say so.
- 80 Teams (4/2/2/4=12): Teams web preset, or teams-for-linux (unofficial).
- 82 QuickBooks Desktop (2/2/1/2=7): QuickBooks Online web preset, or GnuCash.
- 83 Quicken (2/2/1/2=7): GnuCash, KMyMoney or Actual Budget.
- 84 TurboTax/H&R Block (2/1/1/1=5): web versions.
- 85 TallyPrime (4/3/1/2=10): tested single-user Wine preset (LAN/server mode crashes, WineHQ bug 55355), plus ERPNext. There is still no native build in 2026.
- 87 InPage Urdu (2/3/1/2=8): CrossOver/Wine preset (verify Nastaliq rendering), plus LibreOffice with Noto Nastaliq Urdu.
- 89 SMART Notebook (2/2/1/2=7): OpenBoard.

## KILL (20 rows)

- 9 Affinity: Canva confirmed a native Linux build is "in active development" (3 Nov 2026). Wait for it; until then, point users to the AffinityOnLinux Wine route.
- 32 Studio One / Fender Studio Pro: the vendor already ships a Linux public beta.
- 39 MS Access: legacy small-business databases, Wine is broken; a Windows VM is the only honest answer.
- 46 Revit: enormous BIM suite, no Wine path; VM only.
- 47 SOLIDWORKS: Wine is broken and a clone would take years; point to FreeCAD or Onshape.
- 49 CATIA: niche enterprise aerospace/automotive software.
- 50 ETABS/SAP2000: regionally important but niche, and far too large to build; VM.
- 51 STAAD.Pro: same as ETABS.
- 56 Primavera P6: niche enterprise; the vendor's cloud version is the path.
- 58 Xcode: Apple licensing ties iOS signing to macOS; no Linux path is possible.
- 75 CCleaner/Revo: a Windows-specific need; the package manager already covers it.
- 78 Wallpaper Engine/Rainmeter: cosmetic, outside the target users, costs battery and GPU.
- 81 iMessage/FaceTime: Apple platform lock-in; cannot be built or bridged.
- 86 Busy/Marg ERP: regional niche with unverified Wine status; ERPNext as a pointer.
- 88 Respondus/Safe Exam Browser: designed to lock students to Windows/Mac; Axiom cannot fix this.
- 90 Valorant/LoL (Vanguard): kernel anti-cheat, Riot says "never".
- 91 Fortnite: Epic announced in Oct 2026 that Linux support is coming through EAC Linux v2, with no date. The vendor is handling it.
- 92 Battlefield 6/Apex (Javelin): anti-cheat block; vendor-controlled.
- 93 CoD/PUBG/R6 (Ricochet/BattlEye): anti-cheat block; vendor-controlled.
- 94 Roblox (Hyperion): anti-cheat block; do not ship unofficial workarounds.

## Counts

BUILD: 8 rows (6 distinct apps: Capture, Zones, Launcher, Automate, Connections, Write). BRIDGE: 66. KILL: 20. Total: 94.

## Sources

- [AlternativeTo: ShareX alternatives](https://alternativeto.net/software/sharex/?p=14), [Satty](https://alternativeto.net/software/satty/?p=4), [Swappy](https://alternativeto.net/software/swappy/), [ksnip](https://alternativeto.net/software/ksnip/about)
- [ShotX (PyPI)](https://pypi.org/project/shotx/), [Lemmy: no perfect ShareX replacement](https://lemmy.nekusoul.de/post/504316)
- [Gist: Linux alternative to FancyZones](https://gist.github.com/bmaupin/5ebd4d7fd52f8911e14fa55cd58aee2d), [AlternativeTo PlasmaZones](https://alternativeto.net/software/plasmazones/?p=4), [Lemmy FancyZones thread](https://lemmy.brendan.ie/comment/1587209)
- [Vicinae docs](https://docs.vicinae.com/), [Vicinae GitHub](https://github.com/vicinaehq/vicinae), [AUR vicinae-bin](https://aur.archlinux.org/packages/vicinae-bin), [Show HN: Vicinae](https://brianlovin.com/hn/45188116)
- [AlternativeTo: AutoHotkey for Linux](https://alternativeto.net/software/autohotkey/?platform=linux), [AutoKey on Wayland](https://groups.google.com/g/autokey-users/c/0aPaNxgfPyo), [libei roadmap (2026)](https://perrette.github.io/scribe/roadmap-libei/), [Flathub: Portals 1.16](https://discourse.flathub.org/t/portals-1-16-0-release-is-out/3404)
- [AlternativeTo: Everything](https://alternativeto.net/software/everything), [OMG! Ubuntu: FSearch](https://www.omgubuntu.co.uk/fsearch-fast-file-search-tool-for-ubuntu-linux)
- [AlternativeTo: MobaXterm](https://alternativeto.net/software/mobaxterm), [itslinuxfoss: MobaXterm-like for Linux](https://itslinuxfoss.com/program-like-mobaxterm-for-linux-systems/)
- [Phoronix: Photoshop 2025 Wine patch](https://www.phoronix.com/news/Adobe-Photoshop-2025-Wine-Patch), [Phoronix: upstream progress](https://www.phoronix.com/news/Adobe-Photoshop-Upstream-Wine), [It's FOSS: Photoshop installer](https://itsfoss.com/news/photoshop-installer-runs-on-linux/)
- [Phoronix: CrossOver 26](https://phoronix.com/news/CrossOver-26), [Phoronix: CrossOver 25.1 Office](https://phoronix.com/news/CrossOver-25.1-Released), [OMG! Ubuntu: CrossOver 24 Office 365](https://www.omgubuntu.co.uk/2024/02/crossover-24-released-run-office-365-linux)
- [AlternativeTo news: Affinity Linux in development](https://alternativeto.net/news/2026/11/affinity-has-announced-that-a-linux-version-is-in-development-but-there-s-no-eta-just-yet/), [OMG! Ubuntu: Affinity Linux confirmed](https://omgubuntu.co.uk/2026/11/affinity-linux-release-confirmed)
- [It's FOSS: Studio One Linux](https://itsfoss.com/news/studio-one-linux/), [Wikipedia: Studio Pro](https://en.wikipedia.org/wiki/Studio_Pro)
- [GamingOnLinux: Epic launcher Linux, Fortnite coming](https://www.gamingonlinux.com/2026/10/epic-games-launcher-preview-arrives-native-linux-support-fortnite-for-linux-is-coming-and-upgraded-easy-anti-cheat/), [PC Gamer: Fortnite to Linux with EAC](https://www.pcgamer.com/games/battle-royale/fortnite-is-coming-to-linux-once-epic-improves-easy-anti-cheat/)
- [Microsoft: What's happening to Azure Data Studio](https://learn.microsoft.com/en-us/azure-data-studio/whats-happening-azure-data-studio?tabs=dev)
- [ONLYOFFICE: Linux PDF editors 2026](https://onlyoffice.com/blog/2026/04/linux-pdf-editors), [Baeldung: fill and sign PDFs on Linux](https://www.baeldung.com/linux/fill-and-sign-pdfs)
- [Topaz community: Linux beta 5.0.3](https://community.topazlabs.com/t/topaz-video-ai-linux-beta-v5-0-3-0-b/68739?page=4), [Topaz: honest feedback and Linux support](https://community.topazlabs.com/t/honest-feedback-and-linux-support/97832)
- [Notepad++ community: Platinum on Wine](https://community.notepad-plus-plus.org/post/38667)
- [All3DP: Fusion on Linux (Aug 2026)](https://all3dp.com/2/fusion-360-for-linux-how-to-install-it/), [cryinkfly repo (archived)](https://GitHub.com/cryinkfly/Autodesk-Fusion-360-for-Linux), [WineHQ bug 56373 Fusion](https://list.winehq.org/hyperkitty/list/wine-bugs@list.winehq.org/thread/KFIZX2SLCWKUHN7KS3CGRYNOHPTO7ER7/)
- [Tally on Linux 2025 guide](https://tallyatcloud.com/articles/tally-on-linux-complete-2025-guide-to-installing-running-optimizing-tallyprime-on-linux-systems), [WineHQ bug 55355](https://list.winehq.org/archives/list/wine-bugs@list.winehq.org/thread/XRX3V5L6C6L2TO5FY5LNDBKF3J7BEDZN)
- [ZapZap GitHub](https://github.com/rafatosta/zapzap), [LinuxLinks: ZapZap](https://www.linuxlinks.com/zapzap-whatsapp-desktop-linux/)
- [Fork alternatives (no Linux)](https://alternativeto.net/software/fork/), [iTechGuides: Fork](https://www.itechguides.com/products/fork/)
- [OpenScreen README](https://cdn.jsdelivr.net/gh/siddharthvaddem/openscreen@main/README.md), [AlternativeTo: Camtasia](https://www.alternativeto.net/software/camtasia-studio/)
- Piracy demand signals (carried over from Agent 1): [FAST most-pirated brands](https://www.channelweb.co.uk/news/2270887/fast-lifts-lid-mostpirated-software-brands), [TechRadar WinRAR study](https://techradar.com/au/news/the-most-pirated-software-in-the-world-might-just-surprise-you), [MUSO 2025](https://www.muso.com/muso-2025-piracy-trends-and-insights-report)
