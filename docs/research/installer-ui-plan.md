# Installer and login UI: research and plan (no code yet)

Date: 2026-11-11. Scope: the look of the installer and the login screen. Not started.

## What the user wants
1. The old layout back: the installer's screens and flow as they were (the curses installer).
2. Selection screens with a clean, Omarchy-like list style (highlighted row, arrow keys), not a plain text form.
3. Installation progress shown the same way as before (penguin fills up while the disk is prepared).
4. The penguin must match the Axiom logo, not the grey pixel penguin.
5. Graphical, not a terminal look, but the same screens and order.

## What the repo has now (research)
- Official logo: `branding/identity/axiom-penguin.png` (512 px). The desktop top bar and docs use it
  (`docs/DESKTOP_DESIGN.md`, asset table).
- `shell/assets/axiom-penguin.png` (96 px) is a downscaled copy. The QML login and the Phase 3 installer
  use it at 96 to 120 px, so the penguin looks small and flat.
- Curses installer progress (`installer/axiom-installer`, `draw_progress` / `penguin_cells`) draws the
  penguin from `tui/penguin_art.py`. That art is a grey pixel grid generated from the old hand-drawn
  penguin (`scripts/gen-penguin-art.py`). This is the mismatch the user sees: the progress screen does not
  show the Axiom logo.
- Omarchy reference (`/usr/share/omarchy/install/provisioning/setup-form.sh`): gum-based lists and prompts,
  Esc = back, one shared form for installer and first boot. Their menus are lists with a single highlighted
  row.
- Phase 3 WIP (`docs/handoff/phase3-wip/qml/shell.qml`): QML installer with the card layout. Screens verified
  in QEMU: language and time (choices), the account step. Penguin uses the 96 px copy.

## Plan
### 1. Penguin asset (fixes the mismatch)
- Use `branding/identity/axiom-penguin.png` (512 px) everywhere the installer and login show the logo.
  Ship a 256 px and a 512 px copy under `installer/qml/assets/` (copy from branding, do not hand-edit).
- Progress screen: draw the logo in grey, then fill it from the bottom with the cyan accent as the
  percentage rises (same idea as the old curses penguin fill, but with the real logo). Use a shader mask or
  a clipped Image; no invented progress values.
- Login and installer use the same logo file. Plymouth splash keeps the same logo.

### 2. Selection screens (Omarchy-like lists)
- Language, keyboard and time zone: a vertical list, one highlighted row, Up/Down to move, Left/Right to
  change the value shown on the row. Same keys as the curses installer (Part A), so the old flow is kept.
- Disk: list of disks, one selected, Enter to choose. Same as the old disk step.
- Account, PC name, passwords: form rows (label + field), as the old curses form. Esc goes back.
- Confirm: type ERASE, as before.

### 3. Installation progress
- Penguin fill plus percentage and the current stage (from the existing `progress` events:
  pct, stage, detail, eta_min). Same stage texts as the curses installer (`Preparing the disk`, etc.).
- Done screen: reboot instruction, as before.

### 4. Where the code goes
- Start from `docs/handoff/phase3-wip/qml/shell.qml` for the screen logic and key handling.
- Keep the curses installer as the fallback until the QML path passes a full QEMU install.
- Installer backend and daemon: `docs/handoff/phase3-wip/axiom_installd.py` (design in ADR 026 draft).
  This is still needed for the QML installer to run as the live user.

### 5. Tests and evidence (when we build it)
- Screenshots in QEMU of: each selection screen, the progress screen at 0%, 50%, 100%, and the login screen.
- Keys: arrow navigation on every list; typing on every text row; Esc goes back.
- Penguin check: the logo on screen matches `branding/identity/axiom-penguin.png` (side by side).
- Full install on a blank virtual disk, and the installed system boots to the login screen.
- Phase 3 to 5 regression on the same ISO.

## Decisions for the user
1. Penguin: use the 512 px Axiom logo as it is (recommended), or make a flat version for small sizes?
2. Progress fill: the logo fills from the bottom (recommended), or a simple bar under the logo?
3. Installer as QML (needs the daemon, ADR 026), or keep curses but change its penguin only (much smaller change)?

## Layout decision (user, 2026-11-11)
- Keep the layout of the QML installer as built (`docs/handoff/phase3-wip/qml/shell.qml`): step title at
  the top, a card per choice or field, arrow keys to change, hint line at the bottom.
- Style: clean vector text with a proper sans font, not the curses/pixel look. No character-grid art.
- Logo: official 512 px Axiom penguin, not the pixel penguin from `tui/penguin_art.py`.

## Final layout (user, image 9): keep the current installer layout, change two things only
Keep exactly the screen in the reference image: wordmark at the top, step bar with "Step N of 6", the
step title in cyan, the intro text, rows with `< value >` (selected row highlighted cyan), "Continue",
the hint line, and the footer key hints (Up/Down move, Left/Right change, Enter continue, Esc go back).
Not cards. Not the Phase 3 QML card layout.

Change 1: the top name. Replace the spaced pixel text `A X I O M` with the proper Axiom wordmark
(`branding/identity/axiom-wordmark.png` / `.svg`), clean and not letter-spaced.

Change 2: installation progress. Use the planned penguin: the official 512 px logo (grey), filled from the
bottom with the Axiom cyan as the percentage rises. Not the pixel-art penguin.

Implementation note: this layout is drawn by the curses installer today. Reproducing it with a clean
wordmark and a logo fill needs graphics (QML), which is the daemon question (ADR 026) again.

## Welcome page (missing in the QML installer; present on GitHub curses installer)
Source: GitHub `HEAD` `installer/axiom-installer`, `main()` (commit `0150c22`).

Screen 0 "Welcome to Axiom!" (before step 1):
- Intro: "Let's get your computer ready. First you'll answer a few simple questions."
- Two selectable rows, same row style as the reference layout (selected row cyan):
  1. **Install Axiom**: "Set up this computer. It takes about 15 minutes and needs internet."
  2. **Advanced options**: "Recovery tools, a terminal, or restart."
- Up/Down move, Enter choose, Esc does nothing on this page (nothing to go back to).
- Penguin at the top (same grey-to-cyan logo, not pixel art).

Advanced options page (from Welcome, Esc goes back):
- **Recovery tools**: "Open a shell with disk tools (lsblk, cryptsetup, mount, btrfs)."
- **Open a terminal**: "A plain shell on the install medium."
- **Restart**: "Restart the computer."

Implementation notes:
- Install Axiom goes to step 1 (Language and time). Current QML starts at step 1; add a step -1 for Welcome.
- Recovery tools and Open a terminal: start a terminal on the live medium as user `axiom` (no root UI).
  Recovery tools need root for disk work; they stay in the curses fallback, or are opened as a root
  shell through a narrow daemon operation. Decision needed.
- Restart: the live user cannot reboot directly. Needs a daemon operation `reboot` (root, narrow) or polkit.
  Decision needed (same ADR 026 socket).

Tests (when built): screenshot of Welcome and Advanced pages; Up/Down/Enter on each row; Esc on
Advanced goes back; Install goes to Language; Restart reboots the VM.
