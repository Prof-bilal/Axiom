# Track 2, Agent 3 (MVP designer): Capture, Write, Connections

Date: 2026-11-09. Input: track2-agent2-verdicts.md, plus a read-only review of the repo (AGENTS.md, ARCHITECTURE, SECURITY and docs/security/*, PHASES, TECH_STACK, ADR-016/017/018, shell/ and apps/ code, the iso/phase3 package list).

## What exists today, and what all three specs depend on

- **App runtime (ADR-017).** Each app is a Quickshell/QML `FloatingWindow` running in its own process, launched with `axiom-app <name>` (a fixed list of names). Apps run as the desktop user. System work goes through argv-array `Quickshell.Io` processes. `sh -c` is allowed only for constant scripts, with paths passed in as `$1`. Each app has a budget of 256 MiB PSS, and the whole guest must stay under 1.8 GiB. Every new app follows this pattern. None of them needs a new daemon or toolkit.
- **Reusable code.**
  - `ScreencopyView` is already used with toplevel sources in `shell/src/activities/ActivitiesOverview.qml` (labwc exposes toplevel capture, ADR-016).
  - `TerminalService.open(cwd, title, argv)` runs `axiom-terminal` with argv only.
  - Files lists folders with `find -printf`, reacts to `gio monitor` events and already uses `gio`.
  - `SettingsService` and the `$XDG_STATE_HOME/axiom/<app>.json` view-state pattern (ADR-018).
  - The labwc keybinding to `qs ipc` path that the shell already uses.
- **Already in the image:** gvfs 1.62 (the SFTP backend `gvfsd-sftp` is in the base `gvfs` package, checked with `pacman -Qo`), openssh (which ships the `ssh-agent.socket` systemd user unit), PipeWire, xdg-desktop-portal plus -wlr, and polkit.
- **Not in the image:** Xwayland, and any Secret Service provider (no gnome-keyring, KeePassXC or similar).
- **Cross-cutting gap: a user secret store.** Capture (uploader tokens) and Connections (optional saved passphrases) both want libsecret. A Secret Service provider (for example gnome-keyring, 3.4 MiB, unlocked by PAM at greetd login) is a Phase 11 "secret protection" decision and needs its own ADR. **Neither MVP below depends on it.** Both work without stored secrets, and secret-backed features are listed under "later".
- **Phase fit.**
  - Capture is the Phase 8 item "screenshots and screen recording", so it is not extra scope.
  - Connections is a Phase 9 (developer edition) feature.
  - Write's grammar checking can ship any time after Phase 8. Its model rewrite waits for the Phase 12 provider router (docs/ai/MODEL_ROUTER.md).

---

## 1. Axiom Capture (ShareX / Snagit / CleanShot class)

**Problem and user.** A developer or maker wants to grab a region or window, mark it up, and paste it into an issue, chat or doc in a few seconds. Windows switchers expect PrintScreen to just work. On Wayland today, people chain grim, slurp and Satty together, Flameshot's Wayland support is experimental, and ShotX is in beta (verdict, rank 1). Axiom owns the shell and the compositor boundary, so it can give capture one consistent flow.

**MVP (must have).**
1. **PrintScreen opens a region overlay on a frozen frame.** The shell runs `grim` on the output into `$XDG_RUNTIME_DIR` and shows it full-screen as a layer surface. The user drags to select. Esc cancels.
2. **Region, full-screen and window modes.** Window mode uses `ScreencopyView` on the toplevel plus `grabToImage`, reusing the overview code. The foreign-toplevel protocol gives no window geometry, so `grim -g` cannot capture a single window.
3. **Instant actions after capture:** copy to clipboard (`wl-copy --type image/png`, from a constant `sh -c` with `$1`), save to `~/Pictures/Screenshots/Axiom-<timestamp>.png`, or open in the editor. A notification goes through the existing NotificationService.
4. **Editor (`axiom-app capture <png>`):**
   - Tools: crop, arrow, rectangle, highlighter, text, numbered step marker, and redact (solid box or coarse pixelate).
   - Undo and redo.
   - Export flattens to PNG.
   - It is a QML Canvas with a MultiEffect/ShaderEffect, which needs no new toolkit.
5. **OCR region to clipboard:** `tesseract <png> - -l eng`, argv only, followed by `wl-copy`.
6. **Quick recording:**
   - Records a region or the full screen to MP4 with `wf-recorder -g <geom> -f <file>`, optionally with PipeWire audio.
   - A permanent red recording indicator sits in the panel and also stops the recording. Stopping sends `SIGINT` so the file is finalized cleanly.
   - Optional GIF export of short clips through ffmpeg, which wf-recorder already depends on.
7. **One upload target, and only as an explicit action:**
   - The user configures one HTTPS endpoint as a subset of the ShareX `.sxcu` format (URL, form field name, URL extractor from the JSON response).
   - A confirmation sheet shows the image and the destination host before every upload. The upload itself is `curl` with argv only.
   - Tokens go in a 0600 config file under `$XDG_CONFIG_HOME/axiom/capture/` until the secret store exists. Say so in the UI.

**Later.**
- Scrolling capture.
- A capture history panel.
- Pinning a screenshot as a floating window.
- Webcam overlay.
- Several uploaders, including S3 and Imgur presets.
- Storing tokens in libsecret.
- Integration with the Phase 8 clipboard history.
- OCR in more languages.
- An "AI explain this screenshot" action (Phase 12, local by default).

**Out of scope.**
- A video editor (bridge to Kdenlive/OBS, as in verdict row 69).
- Automatic or background upload, and any cloud account.
- Delayed or timed capture of other users' sessions.
- Any capture API for third-party apps (they use the portal).

**Reuse.** `grim` 1.5 (46 KiB), `wf-recorder` 0.6 (122 KiB), `tesseract` 5.5.3 plus `tesseract-data-eng` (about 27 MiB), `wl-clipboard`, `curl`, all from Arch `extra`. Axiom code reused: ScreencopyView, NotificationService, `qs ipc` keybindings and the AppWindow components. `gpu-screen-recorder` 6.1 is the fallback if wf-recorder performance fails the measurement below. The decision to keep the annotator in-house rather than bridge Satty is deliberate: Satty is GTK4 plus libadwaita, which would add a second toolkit with a visual mismatch.

**Architecture fit.**
- The overlay lives in the already-running shell process, which avoids paying a QML cold start on every PrintScreen. The editor is a separate app process, so crash isolation holds.
- Third-party and Flatpak apps keep going through xdg-desktop-portal Screenshot/ScreenCast (xdpw). Capture does not weaken that path.
- **Harness caveat:** under labwc, any Wayland client can bind wlr-screencopy or ext-image-copy-capture without consent. Capture does not create this hole, but Phase 11 must restrict capture protocols to trusted clients (security-context filtering in the Axiom compositor).
- Nothing runs as root.

**Risks and mitigations.**
| Risk | Mitigation |
|---|---|
| Redaction that can be reversed (blur) | Redact means a solid fill or pixelation with blocks of 16 px or more, flattened on export. A test asserts that no original pixel survives in the redacted area. |
| Sensitive screenshots leaking through the temp directory | Temp files go only in `$XDG_RUNTIME_DIR` (tmpfs, 0700) and are deleted on cancel or exit. |
| Capturing the lock screen or greeter | Capture refuses while the session is locked. A test covers this. |
| Hidden recording | The indicator cannot be hidden, and a notification shows the file path at start and stop. |
| Uploader exfiltration or SSRF | HTTPS only, confirmation each time with the host shown, no redirects to other hosts (`curl --proto =https`, no `-L`), and an image-type and size cap. The token is never logged. |
| Uploading from a file someone else supplied | The uploader takes only the file that the editor or capture produced. |

**Acceptance criteria (QEMU, retained evidence).**
1. A test window draws a known RGB pattern. A region capture via `qs ipc` produces a PNG whose pixels match the pattern at the expected offsets.
2. Window capture of the test window matches its content and excludes the other windows.
3. The clipboard holds `image/png` afterwards (`wl-paste --list-types`).
4. The editor applies one of each tool and exports, and a pixel check passes. Redacted pixels contain no original values.
5. OCR of a window showing a fixed sentence has a character error rate of 5% or less.
6. A 10-second recording gives an MP4 whose `ffprobe` duration is 10 ± 1 s, and the indicator is visible in a screenshot taken during the recording.
7. Upload against a local HTTPS test server in the guest returns the URL. A plain `http://` endpoint and a cross-host redirect are both rejected.
8. Capture while locked is denied.
9. Cancelling leaves `$XDG_RUNTIME_DIR` clean.

**Effort.** About 8 weeks:
- overlay and modes, 2 weeks
- editor, 2.5 weeks
- OCR, 0.5 weeks
- recording plus indicator, 1.5 weeks
- uploader, 0.5 weeks
- QEMU driver and evidence, 1 week

**Measure.**
- PrintScreen to overlay visible, p50 and p95. The target is 250 ms or less p95 on KVM. Software rendering is reported separately.
- Capture to clipboard time.
- Editor PSS. Gate: 256 MiB or less with a 1080p image.
- Recording CPU %, plus dropped frames from wf-recorder stats at 1080p30. In QEMU these are relative numbers only, not hardware claims.
- OCR milliseconds per 1080p region.

---

## 2. Axiom Write (Grammarly class, explicit and local)

**Problem and user.** Indie makers and developers write READMEs, issues, release notes, emails and chat messages. Grammarly has no Linux desktop app, and it reads everything you type.

**Challenge to the verdict.** The gap is narrower than G = 4 suggests:
- Browser text, which is most Grammarly use, is already covered on Linux by the Grammarly and LanguageTool browser extensions.
- Developers' editors already get inline checking from `harper-ls` (VS Code, Neovim, Zed, Helix) and from LanguageTool LSPs.
- What remains is native and Electron apps without extensions, used through a copy-and-check flow that is clunkier than inline underlines. A global "replace selection" needs input injection, which belongs to Axiom Automate and its per-action authorization.

**Recommendation:** build Write as a **small selection action (a launcher command plus a hotkey), not a standalone flagship app**, and rank it last of the three. Do not put LanguageTool in the base image. LanguageTool is 386 MiB, plus about 147 MiB of JRE, plus 1 to 2 GiB of heap with n-grams. That breaks the 1.8 GiB guest gate.

**MVP (must have).**
1. **Hotkey, or the launcher command "Check selected text":**
   - Reads the primary selection with `wl-paste --primary --no-newline`. The fallback is the clipboard.
   - Hard cap of 20,000 characters, with an error if the text is longer.
   - Nothing is read until the user invokes it.
2. **A small Write window listing issues:**
   - Each issue shows the span, the message and its suggestions. The user can accept or ignore each one, or accept all.
   - Live re-check as the user edits inside the window only.
3. **Output:** "Copy result" puts the text on the clipboard, and the user pastes it with Ctrl+V. That is the honest MVP. There is no keystroke synthesis.
4. **Default backend: Harper.**
   - Rust, Apache-2.0, English, in Arch `extra` 2.13.0 as `harper-cli` and `harper-ls` (115 MiB package).
   - Runs as a short-lived process per check, or as `harper-ls` over stdio LSP for structured JSON.
   - The `harper-cli` JSON output flag is unverified. If it is missing, use LSP.
5. **Optional backend: LanguageTool**, for languages beyond English and deeper rules:
   - Opt-in install of `languagetool` plus a headless JRE from Settings or Software.
   - The server starts on demand, bound to `127.0.0.1` on a random port, and stops after 5 minutes idle. The client uses the documented `/v2/check` JSON API.
6. **No network by default.** There is no remote LanguageTool or cloud option in the MVP.

**Later.**
- **"Rewrite: clearer, shorter, more formal" through a local model.** This goes only through the Phase 12 provider router (Ollama local endpoint, no silent fallback to cloud), and it is shown as a diff the user accepts.
- Cloud providers, opt-in with the destination disclosed (MODEL_ROUTER.md rules).
- **"Replace selection in place"** through the Axiom Automate paste intent, authorized per action.
- Personal dictionary, and per-app language.

**Out of scope.**
- Background keystroke or accessibility-tree watching.
- Inline underlines in other apps.
- An input-method hook.
- Any always-on daemon.
- Browser extensions (bridge to the existing ones).

**Architecture fit.**
- A user process that reads only the selection the user explicitly hands it, which preserves Wayland boundaries. Reading the primary selection needs a data-control protocol from labwc, which must be verified in the spike.
- Checker processes run with no network and no home access beyond the text passed on stdin. Run them under a systemd-run user scope with `PrivateNetwork=yes` where the scope supports it, or record this as a Phase 11 sandbox target.
- Text is untrusted data, and model output is a proposal, never authority (SECURITY.md).

**Risks and mitigations.**
| Risk | Mitigation |
|---|---|
| Sensitive text, such as a selected password or token, sent somewhere | Local-only backends, no logs of the text, the text is held in memory only, and no history in the MVP. |
| The LanguageTool port is reachable by other local users or processes | Bind to loopback with a random port. Accept that same-user processes can query it; it only checks text. |
| Prompt injection through the selected text (later, model rewrite) | Output is a diff that needs acceptance, with no tools and no actions. |
| Memory cost | Harper is the default, and LanguageTool is opt-in and exits when idle. Measure both. |

**Acceptance criteria (QEMU).**
1. Select a fixture sentence with three known errors in a test window, press the hotkey, and Write lists at least those three. Accept-all followed by Copy gives the expected corrected string (`wl-paste`).
2. With guest egress blocked by nft, checks still work, and a packet counter shows zero outbound connections during a check.
3. With LanguageTool enabled, its socket is `127.0.0.1` only (`ss -ltnp`), and its process is gone 5 minutes after the last check.
4. Selected text over 20,000 characters is refused with a message.
5. Grepping the journal and `$XDG_STATE_HOME` for the fixture text finds nothing.

**Effort.** About 3 weeks: selection and window, 1 week; Harper, 0.5 weeks; LanguageTool lifecycle, 1 week; tests, 0.5 weeks. Model rewrite adds about 1.5 weeks after Phase 12.

**Measure.**
- Hotkey to first issues for 500 words: Harper (expected well under 1 s, but it must be measured) versus LanguageTool cold and warm.
- LanguageTool RSS idle and peak.
- Write window PSS.
- Accuracy on a fixed error corpus (recall of the seeded errors per backend).

---

## 3. Axiom Connections (MobaXterm / WinSCP class)

**Problem and user.** Developers and makers manage VPSs, Raspberry Pis and homelab boxes. They want a saved list of hosts, one click to a shell, and a file browser on the same host. On Linux the options are Electron (Electerm), dated tools (Asbru), proprietary (Termius) or only remote desktop (Remmina) (verdict, rank 6).

**Key design choice: `~/.ssh/config` is the session store.** Axiom does not create its own database. Hosts that Axiom creates go in an Axiom-owned include file, `~/.ssh/config.d/axiom.conf`. A single `Include config.d/*.conf` line is added to the top of `~/.ssh/config` only after confirmation, and a backup is kept. Every session then also works from any terminal, from git, and from VS Code Remote. Uninstalling Axiom leaves the user's setup intact.

**MVP (must have).**
1. **Host list:**
   - All `Host` aliases from `~/.ssh/config` and its includes. Wildcard patterns are skipped.
   - Effective values are resolved with `ssh -G <alias>` (argv), so OpenSSH does the parsing, not Axiom.
   - Search box, plus recents in `$XDG_STATE_HOME/axiom/connections.json`.
2. **Add, edit or remove a host**, only in the Axiom-owned file. Fields: alias, HostName, User, Port, IdentityFile (chosen from `~/.ssh/*.pub` pairs), ProxyJump (picked from existing aliases), and LocalForward lines.
3. **Open a shell:** `TerminalService.open(null, alias, ["ssh", alias])`, which opens a new Axiom Terminal window. The first connection handles host-key trust-on-first-use in the terminal through OpenSSH's own prompt.
4. **Open files:**
   - `gio mount sftp://<alias>/`, then Files opens the GVfs FUSE path (`/run/user/$UID/gvfs/sftp:host=<alias>`), so the existing `find`/`gio` operations work unchanged.
   - Files gains "Connections" sidebar entries and "Unmount".
   - The MVP supports key and agent authentication only. Password hosts get "use Terminal" or "add a key".
5. **Keys:**
   - Lists keys.
   - "Create key" runs `ssh-keygen -t ed25519` in the terminal, so the passphrase prompt happens in OpenSSH, not in Axiom UI.
   - "Copy public key", and "Install key on host" runs `ssh-copy-id` in the terminal.
   - Enable `ssh-agent.socket` (openssh user unit) in the session so a passphrase is typed once per login.
6. **Status:** reachability check with `ssh -o BatchMode=yes -o ConnectTimeout=5 <alias> true`, run only on demand.

**Later.**
- Saved passwords or passphrases through libsecret (needs the secret-store ADR).
- A password prompt for SFTP in the GUI. GVfs needs a GMountOperation that QML cannot supply; this needs a small native helper or a `gio mount` driven over stdin.
- A tunnel manager (start and stop a LocalForward as `ssh -N`), and tabs or split panes once Terminal has them.
- Serial consoles (`picocom`, which needs the `uucp` group via a permission prompt).
- Mosh, an import wizard (PuTTY or MobaXterm `.mxtsessions`), broadcast input to several hosts, and an RDP/VNC hand-off to Remmina.

**Out of scope.**
- X11 forwarding (no Xwayland in the image; revisit when Xwayland ships).
- Any SSH implementation of Axiom's own; OpenSSH is the only client.
- Storing private keys outside `~/.ssh`.
- Cloud sync of sessions.
- An AI agent that runs commands on remote hosts (Phase 12 at the earliest, through capabilities).

**Architecture fit.**
- A user-session app (`axiom-app connections`), with no daemon and no root, and argv only.
- OpenSSH owns cryptography, host keys, the agent and authentication.
- GVfs owns SFTP, and Files stays the single file UI.
- Secrets never pass through QML in the MVP: passphrases are typed into OpenSSH in the terminal, and the agent holds them.

**Risks and mitigations.**
| Risk | Mitigation |
|---|---|
| **Config injection leading to code execution.** A field containing a newline could add `ProxyCommand`, `LocalCommand` or `Match exec` to `ssh_config`. | Strict field schemas: alias matches `[A-Za-z0-9._-]{1,64}` and must not start with `-`. Hostname is a strict hostname or IP. User follows POSIX username rules. Port is 1-65535. Paths must be under `~/.ssh` and contain no whitespace or control characters. Axiom never writes `ProxyCommand`, `LocalCommand`, `PermitLocalCommand` or `Match`. Writes are atomic with a backup. Tests use a corpus of malicious fields. |
| Argument injection into `ssh` (`-oProxyCommand=...` given as an alias) | Validate the alias as above. ssh treats `-o` as an option, so never pass an unvalidated string. |
| Damaging the user's handwritten `~/.ssh/config` | Read-only except the single `Include` line, which is added after confirmation with a backup. A parse failure from `ssh -G` is shown, not "fixed". |
| Hidden connections that leak metadata | Status checks run only on demand. No background polling. |
| Weakening host-key checking | Never pass `StrictHostKeyChecking=no`. Trust-on-first-use is left to OpenSSH in the terminal. |

**Acceptance criteria (QEMU).** The guest runs a local `sshd` with a test user and key, and `localhost` stands in for a remote host.
1. Add a host through the UI. `axiom.conf` contains exactly the expected block, and `ssh -G` resolves it.
2. "Open shell" opens a terminal where `whoami` shows the test user (screenshot plus serial log).
3. "Open files" mounts SFTP. In Files, the user creates, renames and deletes a file, and each result is verified on the server side with `stat`.
4. Unmount removes the GVfs mount.
5. A malicious-field corpus (newline plus ProxyCommand, a leading `-o` alias, `../` in IdentityFile) is rejected, and `axiom.conf` is unchanged byte for byte.
6. A handwritten `~/.ssh/config` fixture is unchanged apart from the confirmed Include line, and the backup exists.
7. Logs and the journal contain no key material or passphrases.

**Effort.** About 4.5 weeks:
- config read and write plus validation, 1.5 weeks
- UI, 1 week
- Files SFTP mount integration, 1 week
- keys, agent and the QEMU driver, 1 week

**Measure.**
- Click to remote prompt, against plain `ssh` (the overhead should be under 100 ms; measure it).
- SFTP listing of a 1,000-entry directory through the FUSE path in Files.
- Connections and Files PSS against the 256 MiB gate.
- Time for `ssh -G` resolution across 50 hosts. If it is slow, batch or cache it per file modification time.

---

## Priority and challenges

1. **Capture: build it first.** Phase 8 already requires it, and Axiom's structural advantage (the shell overlay plus toplevel capture) is real. The risk is concentrated in the editor, so time-box that at 2.5 weeks.
2. **Connections: build it.** It is cheap because OpenSSH, GVfs, Terminal and Files do the heavy lifting. Using `ssh_config` as the store is the main design win and also the main security risk.
3. **Write: downgrade it to a selection action and rank it last.** The verdict overstates the gap: browser extensions and `harper-ls` in editors already cover most writing developers do. The heavy LanguageTool stack must stay opt-in. The AI rewrite is blocked until Phase 12.

## Sources

- Arch `extra` package data (checked with `pacman -Si`/`-Qo`/`-Ql` on 2026-11-09): gvfs 1.62 ships `gvfsd-sftp`; openssh ships `ssh-agent.socket`; grim 1.5, slurp 1.5, wf-recorder 0.6, gpu-screen-recorder 6.1.4, satty 0.22, tesseract 5.5.3, languagetool 6.6 (386 MiB), harper 2.13.0 (115 MiB), jre21-openjdk-headless (147 MiB), gnome-keyring 3.4 MiB.
- [Arch harper package files](https://archlinux.org/packages/extra/x86_64/harper/files/) (lists `harper-cli` and `harper-ls`); [Arch harper package](https://www.archlinux.org/packages/extra/x86_64/harper); [WP Tavern: Automattic acquires Harper](https://wptavern.com/automattic-acquires-harper-founder-elijah-potter-joins-the-team-as-code-wrangler); [Linuxlinks: Harper](https://www.linuxlinks.com/harper-english-grammar-checker/)
- LanguageTool memory, from secondhand sources: [LanguageTool forum: RAM consumption](https://forum.languagetool.org/t/ram-consumption/7946), [self-host LanguageTool guide](https://www.qwe.edu.pl/ai-tools/self-host-languagetool-open-source-grammarly/), [loglux/languagetool-docker](https://awesome.ecosyste.ms/projects/github.com%2Floglux%2Flanguagetool-docker), [Hostinger LanguageTool](https://www.hostinger.com/applications/languagetool)
- Capture protocols: [wayland.app: wlr-screencopy](https://wayland.app/protocols/wlr-screencopy-unstable-v1) (lists labwc; deprecated in favour of ext-image-copy-capture), [Phoronix: Wayland merges new capture protocols](https://phoronix.com/news/Wayland-Merges-Screen-Capture), [KDE bug 513785](https://bugs.kde.org/show_bug.cgi?id=513785) (lists labwc as an ext-image-copy-capture implementer)

## Not verified

These need a 1-day spike each before work starts:
- whether `harper-cli` has a JSON output flag
- whether labwc 0.20 exposes a data-control protocol for `wl-paste --primary`
- whether gvfsd-sftp honours `ssh_config` aliases, and how `gio mount` behaves on an unknown host key
- whether wf-recorder 0.6 uses ext-image-copy-capture or wlr-screencopy on labwc
