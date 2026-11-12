# Track 2, Agent 1 (Finder): popular Win/Mac software with no native (or a crippled) Linux version

Date: 2026-11-09. Scope: candidate list for later agents to rank. Piracy is used only as a demand signal (FAST UK ranks MS Office/Windows first, then Photoshop/Illustrator and Creative Suite; search-volume studies list Photoshop, Office and WinRAR). No crack sources are listed or recommended.

Linux status key: **none** = no Linux build; **web-only** = usable only through a browser/PWA; **Wine works** = generally usable via Wine/CrossOver/Bottles, with caveats; **Wine broken** = does not install/run usefully, or only with heavy patching; **crippled** = a Linux build exists but lacks key features. "(unverified)" means not checked against a current source in this pass. Statuses are based on secondary sources and change quickly; Agent 2 should re-check the top candidates against WineHQ AppDB / ProtonDB.

| # | App | Category | Platforms | Linux status | Best Linux alternative(s) | Note |
|---|-----|----------|-----------|--------------|---------------------------|------|
| 1 | Adobe Photoshop | Creative: photo | Win, Mac | Wine broken (experimental) | GIMP 3, Krita, Photopea (web) | Community Wine patches (PhialsBasement, 2025/26) make the PS 2021/2025 CC installer work; partly upstreamed, still experimental. #1 piracy demand signal |
| 2 | Adobe Lightroom Classic | Creative: photo | Win, Mac | none (Lightroom web exists) | darktable, RawTherapee, digiKam | Catalog plus raw workflow is the main lock-in (unverified Wine status) |
| 3 | Adobe Illustrator | Creative: design | Win, Mac | Wine broken (unverified) | Inkscape, Graphite (early), Affinity via Wine | Co-ranked with Photoshop in FAST piracy list |
| 4 | Adobe InDesign | Creative: DTP | Win, Mac | none / Wine broken (unverified) | Scribus | Print/publishing standard; IDML interchange is the gap |
| 5 | Adobe Premiere Pro | Creative: video | Win, Mac | Wine broken (unverified) | Kdenlive, DaVinci Resolve, Shotcut | Most-requested video NLE among switchers |
| 6 | Adobe After Effects | Creative: motion | Win, Mac | Wine broken (unverified) | Blender, Natron (stalled), Cavalry (no Linux) | No real Linux equivalent for templates/plugins ecosystem |
| 7 | Adobe Audition | Creative: audio | Win, Mac | none (unverified) | Audacity, Tenacity, ocenaudio | Podcast/voice editing |
| 8 | Adobe Acrobat Pro | Office: PDF | Win, Mac | none | Okular, Xournal++, ONLYOFFICE PDF editor, Master PDF Editor (proprietary) | Fillable forms, signing, redaction are daily needs |
| 9 | Affinity (Canva, unified free app, v3 Oct 2025) | Creative: photo/design/DTP | Win, Mac | Wine works (with limits); native port announced | GIMP, Inkscape, Scribus | Canva confirmed a Linux version "in active development" (Nov 2026, no date). Under Wine 10.17+, Canva sign-in and WebView2 features fail |
| 10 | CorelDRAW Graphics Suite | Creative: design | Win, Mac | Wine broken / partial (unverified) | Inkscape | Very common in South Asian print/signage shops; CDR import in Inkscape is partial |
| 11 | Clip Studio Paint | Creative: illustration | Win, Mac (+mobile) | Wine works partly (unverified) | Krita | Comics/manga standard |
| 12 | Paint.NET | Creative: photo | Win | Wine works partly (unverified) | Pinta, GIMP | Lightweight daily editor for Windows switchers |
| 13 | Capture One | Creative: photo | Win, Mac | none | darktable, RawTherapee | Pro tethered shooting |
| 14 | Sketch | Creative: UI design | Mac | none (web viewer) | Figma (web), Penpot, Lunacy (has Linux) | Mac-only, no Wine path |
| 15 | Figma desktop | Creative: UI design | Win, Mac | web-only | Figma in browser, figma-linux (unofficial), Penpot | Browser works; missing local fonts helper/offline |
| 16 | Canva desktop | Creative: design | Win, Mac | web-only | Canva web, Penpot, Inkscape | Hugely popular with indie makers and in South Asia |
| 17 | CapCut desktop | Creative: video | Win, Mac | web-only (CapCut web) | Kdenlive, Shotcut, OpenShot | Default editor for short-form creators |
| 18 | Wondershare Filmora | Creative: video | Win, Mac | none | Kdenlive, Shotcut | Beginner YouTube editor; strong piracy demand among students (signal only) |
| 19 | VEGAS Pro | Creative: video | Win | Wine broken (unverified) | Kdenlive, DaVinci Resolve | Legacy favorite of hobby editors |
| 20 | Final Cut Pro | Creative: video | Mac | none | DaVinci Resolve, Kdenlive | Mac-only, impossible under Wine |
| 21 | DaVinci Resolve (free) | Creative: video | Win, Mac, Linux | crippled | Resolve Studio (paid) on Linux, Kdenlive | Free Linux build lacks H.264/H.265 decode/encode and AAC audio; users must transcode |
| 22 | Topaz Video / Photo AI | Creative: AI upscale | Win, Mac | none (unverified; possible Linux CLI beta) | Upscayl, Real-ESRGAN, video2x | AI upscaling demand from creators |
| 23 | Autodesk 3ds Max | Creative/3D | Win | none | Blender | Archviz and game asset pipelines |
| 24 | Maxon Cinema 4D | Creative/3D | Win, Mac | none (Linux render client only) | Blender | Motion-design standard |
| 25 | ZBrush | Creative/3D | Win, Mac | Wine works partly (unverified) | Blender sculpt, (Nomad: no Linux) | Sculpting |
| 26 | SketchUp Pro | Engineering/3D | Win, Mac | web (SketchUp Free/Go); Wine partial (unverified) | FreeCAD, Blender, BricsCAD Shape (unverified) | Architecture students and furniture makers |
| 27 | Ableton Live | Creative: DAW | Win, Mac | Wine works partly | Bitwig Studio (native), REAPER (native), Ardour | Most-asked DAW among Linux switchers; latency under Wine |
| 28 | FL Studio | Creative: DAW | Win, Mac | Wine works | Bitwig, LMMS, REAPER | Reported to run well in Wine; plugin compatibility hit-or-miss. Very high piracy demand (signal only) |
| 29 | Steinberg Cubase / Nuendo | Creative: DAW | Win, Mac | none / Wine broken (unverified) | REAPER, Bitwig, Ardour | Dongle/licensing blocks Wine |
| 30 | Avid Pro Tools | Creative: DAW | Win, Mac | Wine broken | Ardour, Mixbus | iLok/AAX ecosystem |
| 31 | Logic Pro / GarageBand | Creative: DAW | Mac | none | Bitwig, LMMS, Ardour | Mac-only |
| 32 | PreSonus Studio One | Creative: DAW | Win, Mac | crippled (Linux public beta, unverified current state) | Bitwig, REAPER | Rare vendor that started a Linux build |
| 33 | Native Instruments Kontakt / Komplete, Xfer Serum, iZotope RX (VST plugins) | Creative: audio plugins | Win, Mac | Wine works partly (via yabridge) | yabridge bridge, Surge XT, Vital, native LV2/CLAP plugins | Plugin library is the real lock-in, not the DAW; yabridge reliability depends on Wine version |
| 34 | Microsoft Office desktop (Word/Excel/PowerPoint) | Office | Win, Mac | web-only; Wine works partly (CrossOver: Office 2016 best, 365 32-bit installer) | LibreOffice, ONLYOFFICE, WPS Office, Office on the web | #1 piracy demand signal; Excel macros/VBA and Power Query are the gaps |
| 35 | Microsoft Outlook (classic/new) | Office/communication | Win, Mac | web-only | Thunderbird, Evolution (EWS), Outlook web | Exchange calendar/contacts |
| 36 | Microsoft OneNote | Office/education | Win, Mac | web-only | Joplin, Obsidian, Xournal++ | Student notebooks with pen input |
| 37 | Microsoft Visio | Office | Win | web-only | draw.io/diagrams.net, Dia | VSDX import partial |
| 38 | Microsoft Project | Office | Win | web-only | ProjectLibre, GanttProject | Common in engineering/construction management |
| 39 | Microsoft Access | Office | Win | Wine broken (unverified) | LibreOffice Base, Kexi | Small-business databases |
| 40 | Apple Pages / Numbers / Keynote | Office | Mac | web-only (iCloud) | LibreOffice | Mac switchers' documents |
| 41 | Notion desktop | Productivity | Win, Mac | web-only | Notion web, AppFlowy, Anytype, Obsidian (all native) | Unofficial Electron wrappers exist |
| 42 | Evernote | Productivity | Win, Mac | web-only (unverified) | Joplin, Obsidian | Legacy note archives |
| 43 | Grammarly desktop | Productivity | Win, Mac | web-only (browser extension) | LanguageTool | System-wide writing assistant missing |
| 44 | Raycast / Alfred | Productivity/utility | Mac (Raycast also Win) | none | KRunner, Ulauncher, Albert, Vicinae (unverified) | Launcher plus extensions ecosystem |
| 45 | AutoCAD | Engineering/CAD | Win, Mac | web-only (AutoCAD web); Wine broken | LibreCAD, QCAD, BricsCAD (native Linux, paid), DraftSight (unverified Linux) | DWG workflow lock-in; key for civil/architecture students |
| 46 | Autodesk Revit | Engineering/BIM | Win | none | FreeCAD BIM, BricsCAD BIM | Wine broken; VM only |
| 47 | SOLIDWORKS | Engineering/CAD | Win | Wine broken | FreeCAD 1.x, Onshape (web), Siemens NX (Linux, enterprise) | Taught in most mechanical engineering courses |
| 48 | Autodesk Fusion (360) | Engineering/CAD | Win, Mac | Wine works partly (community scripts) | FreeCAD, Onshape (web) | cryinkfly scripts work but break on updates; Autodesk: Linux "very low" likelihood |
| 49 | CATIA | Engineering/CAD | Win | none | FreeCAD, (3DEXPERIENCE web) | Aerospace/automotive |
| 50 | ETABS / SAP2000 (CSI) | Engineering: structural | Win | none / Wine broken (unverified) | OpenSees, FreeCAD FEM | Very common in South Asian civil engineering |
| 51 | STAAD.Pro (Bentley) | Engineering: structural | Win | none (unverified) | OpenSees, Code_Aster | Same audience as ETABS |
| 52 | Altium Designer | Engineering: EDA | Win | Wine broken | KiCad (native) | PCB design |
| 53 | Proteus / Multisim | Engineering/education: EDA sim | Win | Wine works partly (unverified) | KiCad + ngspice, Qucs-S, SimulIDE | Ubiquitous in EE coursework in South Asia |
| 54 | LTspice | Engineering: EDA sim | Win, Mac | Wine works | ngspice, Qucs-S | Known to run well in Wine (verify) |
| 55 | Keil uVision / MPLAB-era IDEs, Arduino-like vendor tools | Engineering: embedded | Win | Wine works partly (unverified) | PlatformIO, VS Code + vendor toolchains, STM32CubeIDE (native) | Student lab software |
| 56 | Primavera P6 (desktop) | Engineering: planning | Win | none (cloud web) | ProjectLibre | Construction scheduling |
| 57 | Visual Studio (full IDE) | Developer | Win (Mac edition retired) | none | JetBrains Rider, VS Code + C# Dev Kit, CLion | .NET/C++ Windows dev; WinForms/WPF designers missing |
| 58 | Xcode | Developer | Mac | none | (none for iOS signing), Swift toolchain on Linux, CI on macOS runners | iOS/macOS builds require a Mac |
| 59 | SQL Server Management Studio | Developer | Win | none | DBeaver, Beekeeper, VS Code mssql extension | Azure Data Studio (cross-platform) retired Feb 2026 (verify) |
| 60 | MobaXterm | Developer/sysadmin | Win | none | Remmina, Asbru, Termius, plain ssh + X11 | All-in-one SSH/SFTP/X server |
| 61 | Notepad++ | Developer/utility | Win | Wine works | Notepadqq, Kate, Geany, CudaText | Top "I miss this" editor for Windows switchers |
| 62 | WinSCP | Developer/utility | Win | Wine works | FileZilla, file-manager SFTP (KIO/GVfs) | Native file managers cover most of it |
| 63 | HeidiSQL | Developer | Win | Wine works | DBeaver, Beekeeper Studio | Has Wine instructions upstream (unverified) |
| 64 | Fork / Tower (Git GUIs) | Developer | Win, Mac | none | GitKraken, Sublime Merge, lazygit, GitButler | Polished Git GUI gap |
| 65 | Dash / Proxyman / Paw (Mac dev tools) | Developer | Mac | none | Zeal, mitmproxy, HTTPie, Bruno | Mac-only dev utilities |
| 66 | Internet Download Manager (IDM) | Utility: download | Win | Wine works (browser integration broken) | Motrix, Persepolis, uGet, aria2, Free Download Manager (native) | Very high demand in South Asia; top crack target (signal only) |
| 67 | ShareX | Utility: screen capture | Win | Wine broken (unverified) | Flameshot, Spectacle, Ksnip, OBS | Repeatedly cited as "the Windows app I miss most" |
| 68 | Snagit / CleanShot X | Utility: screen capture | Win, Mac (CleanShot Mac) | none | Flameshot, Spectacle, Satty | Annotated screenshots for docs |
| 69 | Camtasia / Bandicam | Utility: screen recording | Win, Mac (Bandicam Win) | none | OBS Studio, Kooha, GPU Screen Recorder, Kdenlive | Tutorial/course creators |
| 70 | Everything (voidtools) | Utility: file search | Win | Wine works partly (no NTFS index) | FSearch, Recoll, plocate, KRunner/Baloo | Instant filename search |
| 71 | Microsoft PowerToys (FancyZones, Run, etc.) | Utility: system | Win | none | KWin tiling/scripts, GNOME extensions, KRunner, Hyprland | FancyZones named as the single missing feature by some switchers |
| 72 | AutoHotkey | Utility: automation | Win | Wine works partly (cannot drive native apps) | AutoKey (X11), keyd, kanata, ydotool, espanso | Wayland makes global automation hard; strong fit for Axiom structured automation |
| 73 | WinRAR / 7-Zip GUI | Utility: archive | Win | crippled (CLI-only rar and 7zz on Linux) | Ark, File Roller, PeaZip | WinRAR tops one search-based piracy study |
| 74 | Rufus | Utility: system | Win | none | Ventoy, Fedora Media Writer, balenaEtcher, GNOME Disks | Bootable USB creation |
| 75 | CCleaner / Revo Uninstaller | Utility: system | Win | none | BleachBit, Stacer, package manager | Mostly a Windows-specific need |
| 76 | HWiNFO / CPU-Z / MSI Afterburner | Utility: hardware | Win | none / Wine broken | CPU-X, hardinfo2, MangoHud, LACT, CoolerControl | Afterburner-style GPU OC/fan curves are fragmented on Linux |
| 77 | Macrium Reflect / EaseUS / MiniTool Partition | Utility: backup/disk | Win | none | Rescuezilla, Clonezilla, Timeshift, GParted | Image backup with a friendly GUI |
| 78 | Wallpaper Engine / Rainmeter | Utility: customization | Win | Wine/Proton partial | linux-wallpaperengine, KDE plugin, Conky | Popular with young Windows users |
| 79 | WhatsApp Desktop | Communication | Win, Mac | web-only | WhatsApp Web, ZapZap / WasIstLos (unofficial wrappers) | The daily driver in South Asia; no calls on web (unverified current) |
| 80 | Microsoft Teams | Communication | Win, Mac | web-only (Linux client retired Dec 2022) | Teams PWA, teams-for-linux (unofficial) | Required by universities and employers |
| 81 | iMessage / FaceTime | Communication | Mac | none (FaceTime web links only) | none | Mac switchers lose it entirely |
| 82 | Intuit QuickBooks Desktop | Finance | Win (Mac edition discontinued) | web (QBO) / Wine broken | QuickBooks Online, GnuCash, Akaunting (web), Odoo | Small business accounting |
| 83 | Quicken | Finance | Win, Mac | none | GnuCash, KMyMoney, Actual Budget, Firefly III | Personal finance |
| 84 | TurboTax / H&R Block desktop | Finance: tax | Win, Mac | web-only | Online versions | Seasonal but sticky (US) |
| 85 | TallyPrime | Finance: accounting (India/South Asia) | Win | Wine works partly | GnuCash, ERPNext, Odoo | De facto SME accounting in India/Pakistan/Bangladesh; Wine crashes in server/LAN mode |
| 86 | Busy / Marg ERP | Finance: accounting (India) | Win | none (unverified Wine) | ERPNext | Retail/pharma billing in India |
| 87 | InPage (Urdu) | Office: DTP (Pakistan/India) | Win (Mac app 2024) | Wine works partly (CrossOver "runs great", dated) | LibreOffice + Noto Nastaliq Urdu, Scribus | Urdu newspapers/publishers; Nastaliq rendering under Wine reported broken (old reports) |
| 88 | Respondus LockDown Browser / Safe Exam Browser | Education | Win, Mac (+iPad) | none | none | Blocks students from using Linux for online exams |
| 89 | SMART Notebook (interactive whiteboard) | Education | Win, Mac | none (unverified) | OpenBoard | Classroom whiteboard software |
| 90 | Valorant / League of Legends (Riot Vanguard) | Games: anti-cheat | Win | Wine broken (kernel anti-cheat, "never") | none | Biggest anti-cheat blocker |
| 91 | Fortnite (EAC not enabled) | Games: anti-cheat | Win, Mac | Wine broken | none | One low-profile report claims Epic confirmed Linux support Oct 2026; unverified |
| 92 | Battlefield 6 / Apex Legends (EA Javelin) | Games: anti-cheat | Win | Wine broken | none | EA blocked Linux/Steam Deck for Apex in late 2024; job listing hints at future support |
| 93 | Call of Duty (Ricochet), PUBG, Rainbow Six Siege (BattlEye not enabled) | Games: anti-cheat | Win | Wine broken (R6/PUBG unverified) | none | Check areweanticheatyet / GamingOnLinux tracker |
| 94 | Roblox (Hyperion) | Games: anti-cheat | Win, Mac | Wine broken since 2023 | Sober (runs Android build, unofficial) | Huge with kids/teens |

## Count per category

| Category | Count (rows) |
|----------|-------------|
| Creative: photo/design/DTP/illustration | 12 (1-4, 9-16) |
| Creative: video/motion | 8 (5, 6, 17, 18, 19, 20, 21, 22) |
| Creative: 3D | 4 (23-26) |
| Creative: audio/DAW/plugins | 8 (7, 27-33) |
| Office/productivity | 13 (8, 34-44, 87) |
| Engineering/CAD/EDA | 12 (45-56) |
| Developer tools | 9 (57-65) |
| Utilities | 13 (66-78) |
| Communication | 3 (79-81) |
| Finance/tax | 5 (82-86) |
| Education | 2 (88-89) |
| Games/anti-cheat | 5 (90-94) |

Rows: 94 (several rows group 2-3 closely related apps).

South Asia emphasis rows: 10 CorelDRAW, 16 Canva, 17 CapCut, 18 Filmora, 34 MS Office, 50/51 ETABS/STAAD, 53 Proteus, 66 IDM, 79 WhatsApp, 85 Tally, 86 Busy/Marg, 87 InPage.

## Sources

- [It's FOSS: Affinity Designer on Linux](https://itsfoss.com/affinity-on-linux/)
- [AffinityOnLinux (GitHub)](https://github.com/seapear/AffinityOnLinux)
- [OMG! Ubuntu: Affinity Linux release confirmed (Nov 2026)](https://omgubuntu.co.uk/2026/11/affinity-linux-release-confirmed)
- [Techaeris: Affinity Linux port in active dev](https://techaeris.com/2026/11/05/affinity-linux-port-is-in-active-dev/)
- [Phoronix: Photoshop 2025 installer working with patched Wine](https://www.phoronix.com/news/Adobe-Photoshop-2025-Wine-Patch)
- [Phoronix: Upstream Wine progress on Photoshop patches](https://www.phoronix.com/news/Adobe-Photoshop-Upstream-Wine)
- [Tom's Hardware: Wine patches for Photoshop 2021/2025](https://tomshardware.com/software/linux/developer-patches-wine-to-make-photoshop-2021-and-2025-run-on-linux-adobe-creative-cloud-installers-finally-work-thanks-to-html-javascript-and-xml-fixes)
- [All3DP: Fusion 360 on Linux](https://all3dp.com/2/fusion-360-for-linux-how-to-install-it/)
- [cryinkfly Fusion 360 for Linux wiki](https://www.github.com/cryinkfly/Autodesk-Fusion-360-for-Linux/wiki)
- [Autodesk forum: Does Fusion 360 support Linux](https://forums.autodesk.com/t5/fusion-design-validate-document/does-autodesk-fusion-360-support-linux-os/m-p/13375445)
- [Hackaday: Running Fusion 360 on Linux with Wine](https://hackaday.com/2024/12/15/running-fusion-360-on-linux-with-wine)
- [Image-Line forum: Running FL Studio on Linux](https://forum.image-line.com/viewtopic.php?p=1629108)
- [Ardour discourse: yabridge on Ubuntu 25.04](https://discourse.ardour.org/t/solved-yabridge-in-ardour-8-12-on-ubuntu-25-04-and-later-versions/112568/7)
- [Phoronix: CrossOver 25.1 improves MS Office stability](https://phoronix.com/news/CrossOver-25.1-Released)
- [OMG! Ubuntu: CrossOver 24 runs Office 365](https://www.omgubuntu.co.uk/2024/02/crossover-24-released-run-office-365-linux)
- [AlternativeTo news: CrossOver 25.1](https://alternativeto.net/news/2025/8/crossover-25-1-improves-microsoft-office-stability-on-linux-and-refines-gaming-experience)
- [WineHQ bug 55355: TallyPrime server crashes](https://list.winehq.org/archives/list/wine-bugs@list.winehq.org/thread/XRX3V5L6C6L2TO5FY5LNDBKF3J7BEDZN)
- [Tally on Linux 2025 guide (vendor, promotional)](https://tallyatcloud.com/articles/tally-on-linux-complete-2025-guide-to-installing-running-optimizing-tallyprime-on-linux-systems)
- [Linux Mint community: Tally under Wine](https://community.linuxmint.com/tutorial/view/2353)
- [CodeWeavers compatibility: InPage Urdu](https://www.codeweavers.com/compatibility/crossover/inpage-urdu)
- [WineHQ bug 37083: running InPage](https://list.winehq.org/archives/list/wine-bugs@list.winehq.org/thread/3LCRE6I7TR24SDJCBK6FVR2U4EOYVPBD)
- [Launchpad: InPage Nastaliq font under Wine](https://answers.launchpad.net/ubuntu/+question/235601)
- [ChannelWeb: FAST most-pirated software brands](https://www.channelweb.co.uk/news/2270887/fast-lifts-lid-mostpirated-software-brands)
- [TechRadar: most pirated software (WinRAR study)](https://techradar.com/au/news/the-most-pirated-software-in-the-world-might-just-surprise-you)
- [Revenera piracy/overuse press release](https://www.revenera.com/de/about-us/press-center/software-piracy-overuse-and-misuse-are-equally-undermining-revenue-goals)
- [MUSO 2025 piracy trends report](https://www.muso.com/muso-2025-piracy-trends-and-insights-report)
- [It's FOSS: open-source tools only on Windows (ShareX etc.)](https://itsfoss.com/open-source-tools-windows/)
- [Linux.org thread: How-To Geek underrated Windows apps](https://www.linux.org/threads/how-to-geek-5-criminally-underrated-windows-apps-i-only-found-after-using-linux.67638/)
- [GamingOnLinux: anti-cheat check for competitive games](https://www.gamingonlinux.com/guides/view/anticheat-check-which-competitive-games-actually-work-on-linux-steamos/)
- [GamingOnLinux: Battlefield 6 unplayable on Linux](https://gamingonlinux.com/2025/08/battlefield-6-will-be-a-unplayable-on-linux-systems-due-to-the-anti-cheat)
- [GamingOnLinux: EA Javelin job listing mentions Linux](https://www.gamingonlinux.com/2026/03/ea-javelin-anticheat-job-listing-mentions-future-support-for-linux-and-proton/page=2)
- [GamingOnLinux: anti-cheat and the Steam Machine](https://www.gamingonlinux.com/2025/11/anti-cheat-will-still-be-one-of-the-biggest-problems-for-the-new-steam-machine)
- [tech-insider.org: Fortnite Linux claim (low confidence)](https://tech-insider.org/ca/?p=2319)
- Items marked "(unverified)" and well-known facts (Teams Linux client retired 2022, Resolve free codec limits, Apex Linux block 2024, Roblox Hyperion 2023, Azure Data Studio retirement) come from prior knowledge, not a source fetched in this pass.
