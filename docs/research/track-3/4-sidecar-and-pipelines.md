# Track 3 / Agent 4: Capture sidecar decision and bridge pipelines
Date: 2026-11-10. Verified items cite a source; UNVERIFIED marks gaps.

## Part A. Capture cursor/click sidecar

### Verdict: NO-GO on labwc now; GO only as a Phase 11 compositor feature
The judge's drop rule ("Recordly/OpenScreen already do click zoom on labwc without udev/input-group") is NOT triggered, but the build is also not feasible on labwc without breaking Axiom's own rules. Evidence:

1. **Portal metadata cursor is dead on labwc.** xdg-desktop-portal-wlr rejects it: `if (sess->screencast_data.cursor_mode & METADATA) { ... "unsupported cursor mode requested, cancelling" }`, default EMBEDDED (xdpw `src/screencast/screencast.c`, fetched). The judge's "position comes free via metadata" does not hold on wlroots. Also Capture's spec records with `wf-recorder` (wlr-screencopy), not the portal.
2. **OpenScreen on Linux Wayland:** the only cursor telemetry found is Hyprland-IPC-specific (PRs getopenscreen/openscreen #157 closed, #158 open). Nothing for labwc/generic wlroots. Recordly (AGPL-3.0) README says Linux "records through Electron capture APIs"; v1.3.2 notes disable the cursor overlay when the portal stream may already embed the cursor. I found no confirmation of how Recordly gets clicks on Linux (UNVERIFIED; the udev/input-group claim stays unconfirmed). Net: neither tool delivers click-driven zoom on labwc today.
3. **What a sidecar needs on labwc, and why each route fails:**
   - libinput / evdev: needs `/dev/input` read = `input` group or udev rule = a keylogger-capable grant to every process of the user. Violates Axiom's privacy rules. Reject.
   - labwc `<mousebind context="Client">` + `Execute`: docs say Client binds "are also passed to applications" (labwc-config(5), fetched), so click TIMING is obtainable with no new privilege. But Execute passes no coordinates, and labwc has no cursor-position IPC. So clicks yes, position no.
   - Shell pointer focus: a layer-shell surface only gets pointer events while it intercepts input; a click-through surface gets none. Cannot track globally. Reject.
   - Post-hoc: wf-recorder embeds the cursor in video; position could be detected from frames. That is an editor feature, not a sidecar. Out of scope.
   Click-only timestamps (no position) are nearly useless for auto-zoom, so the labwc version does not clear the bar.
4. **What the compositor can do (Phase 11):** an Axiom compositor sees every pointer event with coordinates natively. Then the sidecar is a few lines in the recording path plus the permission UX. Build it there, as part of the "app X can see your pointer" consent that Phase 11 needs anyway.

### Interim (zero new code, recommended for the demo videos)
- Record with `wf-recorder` (cursor embedded). Add a Launcher action "mark zoom" later if wanted: it appends `{t_ms}` to a text file (timestamps only; user picks the region in the editor). Optional, ~1 day; skip unless the editors lack manual zoom (they do not: Recordly/OpenScreen both have manual zoom regions).
- For the user's own launch film, HyperFrames already composes scene-by-scene (video-production/compositions/film); zoom/crop is done in the HTML with GSAP. No sidecar needed.

### Phase 11 spec (kept short, for the record)
- **Scope:** while a recording session is active, the compositor writes `<name>.mp4.pointer.json` next to the video. Pointer position and button down/up only.
- **Format:** `{"v":1,"clock":"CLOCK_MONOTONIC","video_t0_ns":N,"size":[w,h],"scale":1.0,"events":[{"t":ms,"type":"move","x":..,"y":..},{"t":ms,"type":"down","button":"left","x":..,"y":..},{"t":ms,"type":"up",...}]}`. Move events throttled to 60 Hz and only inside the recorded region/output; coordinates are video-relative. No keys, no text, no window titles, no app IDs, no scroll content.
- **Consent/UX:** off by default; toggle "Record pointer for auto-zoom" in the Capture sheet; permanent panel recording indicator (already in Capture MVP) shows a second badge "pointer logged". Only the Capture process, started by the user gesture, can request it; a client calling the API without an active user-confirmed recording gets denied.
- **Malicious-client exposure:** the stream is a file owned by the user in the output folder; the leak is cursor path and click timing inside the recorded region (behavioral and could reveal typing-adjacent clicks such as an on-screen keyboard or password-manager UI). Mitigations: region clipping, file mode 0600, no live socket, no sidecar when the recording excludes the region.
- **Acceptance (QEMU):** (a) scripted pointer path via QMP/`wlrctl`-style virtual pointer reproduces within +/-1 px and +/-1 frame in the JSON; (b) typed keys in the Terminal produce zero entries; (c) recording stopped, sidecar closes valid JSON; (d) pointer outside region absent; (e) client without consent gets denied and the indicator never lies (badge shows iff logging). Retain serial/journal/screenshots.
- **Effort:** ~1.5 weeks after Phase 11 compositor input path exists; ~2 days for the JSON writer + indicator badge. Measure: event drop rate at 60 Hz, sidecar/video clock drift over 5 min, CPU overhead of logging (<1%).

## Part B. Bridge pipelines (no new apps)

### Licenses (Axiom is Apache-2.0)
| Tool | License | Bundle or recommend |
|---|---|---|
| OpenScreen | MIT (per judge note) | may bundle |
| Recordly | AGPL-3.0 (README) | recommend only (separate install, never linked) |
| whisper.cpp / openai-whisper | MIT | may bundle (models: check each model's license, UNVERIFIED) |
| ffmpeg | LGPL/GPL depending on build | use the distro package, do not vendor |
| Kdenlive | GPL-3.0 | recommend only |
| HyperFrames | UNVERIFIED (not checked; verify before shipping in an image) | check |
| git-cliff | MIT or Apache-2.0 (dual, from memory, UNVERIFIED) | may bundle |
| release-please | Apache-2.0 (from memory, UNVERIFIED) | recommend (runs in CI, not on desktop) |
Apache-2.0 rule: a GPL/AGPL app installed by the user from the repo/Flatpak as a separate program is fine ("mere aggregation"); do not statically link or copy code. Keep GPL/AGPL tools out of the Axiom source tree.

### Flow 1: demo video
1. **Record:** PrintScreen > Record region (Capture, wf-recorder). Output `~/Videos/Axiom-<ts>.mp4`. Mic optional.
2. **Auto-zoom:** open in OpenScreen (MIT) or Recordly (AGPL), add zoom regions by hand (no click metadata on labwc, see Part A), export mp4. Install: Electron apps, AppImage/AUR or Flatpak if available (availability UNVERIFIED; plan on AppImage via a Software Center "external download, checksum shown" entry).
3. **Captions:** `whisper-cli -m ggml-base.en.bin -f clip.wav -osrt` (whisper.cpp; pacman/AUR package) after `ffmpeg -i in.mp4 -ar 16000 -ac 1 clip.wav`. Produces `.srt`.
4. **Compose:** either HyperFrames (HTML project in `video-production/`, `npx hyperframes render`, needs Node) for titles/captions overlays, or Kdenlive (GPL, Flatpak/pacman) importing the srt, or plain `ffmpeg -vf subtitles=x.srt`. Cheapest: ffmpeg burn-in for a 60-second demo.
- **Integration:** Files context action "Make demo from this video" (typed action, argv only) runs steps 3 and 4-ffmpeg in a Terminal window so the user sees output; Launcher action "Record demo". Both are thin wrappers over the catalog in track-2/4; no new daemon.
- **Weak points:** no click-driven zoom on labwc (manual zoom); Electron editors on a bare wlroots session may fail to record (one unverified claim that Recordly cannot record on niri, UNVERIFIED), so run the editors only for edit, not capture; Whisper CPU time on base model ~realtime or better on a modern CPU (measure); HyperFrames needs Node and its render is heavier than ffmpeg; AGPL editor cannot be bundled.

### Flow 2: launch kit
1. `git cliff --latest --strip header -o CHANGELOG-latest.md` (conventional commits; or `--context` for JSON). release-please only if CI on GitHub is wanted.
2. Saved prompt template `~/.config/axiom/hub/launch-prompt.md` (placeholders: changelog, repo blurb, audience) pasted into any LLM, or run through a user-configured local model; output: release notes, a short post, a PH tagline. The user reviews and posts by hand.
3. Attach the demo video and the Capture screenshots.
- **Install:** git-cliff via pacman/cargo (MIT/Apache); template ships as a text file.
- **Integration:** Hub "Launch" checklist per project (changelog generated, video recorded, captions done, screenshots done, post drafted, posted by hand), a Hub field `last_release_tag`; Launcher action "Draft release notes" opens the prompt file prefilled with `git cliff --latest` output in the user's editor. No model call by Axiom itself (rule: deterministic first).
- **Weak points:** needs conventional-commit discipline (history quality in = output quality out); LLM text is generic and must be edited; no audience, which the tooling cannot fix (Track 3 judge).

### Axiom Creator profile ships
Capture + Recorder indicator, ffmpeg, whisper.cpp + one small English model (offer download in first-run, not in the ISO), git-cliff, a "Demo video" Files action, the Launcher actions above, Hub launch checklist and prompt template, a HyperFrames starter in a folder with a README pointing at `hyperframes` install. Recommended-not-bundled: OpenScreen, Recordly, Kdenlive, OBS (Software Center entries with license badges). Nothing here requires a new daemon or privileged component.

## Top risk
Marketing claims that Axiom "auto-zooms like Screen Studio" would be false on labwc: position and click data are not obtainable without an input-group hack. Do not promise it before Phase 11.

## Sources
- xdpw ScreenCast source: https://raw.githubusercontent.com/emersion/xdg-desktop-portal-wlr/master/src/screencast/screencast.c
- labwc-config(5): https://raw.githubusercontent.com/labwc/labwc/master/docs/labwc-config.5.scd
- Recordly README: https://github.com/nonomal/Recordly ; v1.3.2: https://newreleases.io/project/github/webadderallorg/Recordly/release/v1.3.2
- OpenScreen PRs: https://github.com/getopenscreen/openscreen/pull/157 , https://github.com/getopenscreen/openscreen/pull/158
- /dev/input risk: https://reviews.freebsd.org/D18694 , https://libraries.io/cargo/support-step-recorder-gui
