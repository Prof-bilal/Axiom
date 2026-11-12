# ADR 027: Framebuffer renderer for the installer and login screens

Status: Accepted for the Phase 6 polish track. Implemented in `tui/fbdraw.py` for every installer and
login screen; unit-tested (`tests/installer/test_fbdraw.py`, `test_hardening.py`), previewed as PNG frames
(`scripts/preview-ui.sh`), and shown on the QEMU display through DRM. The end-to-end QEMU run is recorded in
`docs/TESTING.md`.

## Context
The installer (`installer/axiom-installer`) and the login screen (`greeter/axiom-greeter`) draw with
curses on the Linux virtual console. Curses only draws character cells, so the penguin is made of
coloured half-blocks and cannot show the mascot as it looks in the reference image. The user wants the
installer and login screens drawn as real pixels, with the layout unchanged.

Constraints from the repository:
- AGENTS.md: do not replace core technologies opportunistically; record compatibility, security,
  performance and rollback impact first.
- Every daemon and new privileged component needs a justification.
- The installer runs as root on the install medium; the login screen runs as the unprivileged `greeter`
  user under greetd and must not get more rights than it has now.
- The ISO has no Pillow; the renderer must use the standard library only.

## Decision
Option 1: an in-process renderer. Each program (installer, login) draws its own frames to the Linux
framebuffer `/dev/fb0`. No new service and no new privilege.

- **Output:** write a complete frame to `/dev/fb0` after the console is switched to graphics mode with
  `KDSETMODE(KD_GRAPHICS)`, and back to `KD_TEXT` on exit. Pixel format is read from
  `/sys/class/graphics/fb0` (`bits_per_pixel`, `virtual_size`, `stride`); only 32-bit formats are supported
  at first. A missing or unsupported framebuffer falls back to curses.
- **Text:** the same console font the installer already loads (`latarcyrheb-sun32.psfu.gz`), read with the
  standard library. Text is placed on the same 16×32 cell grid curses uses, so every line stays where
  it is now.
- **Layout:** each screen keeps its current row and column positions. Pixel drawing only replaces the
  cell drawing; wording and order do not change.
- **Input:** keys still come from the terminal. The program sets the terminal to raw mode with `termios`
  and reads bytes, decoding arrow and function-key escape sequences. curses is kept only as the fallback.
- **Penguin:** the real mascot image (`branding/identity/axiom-penguin.png`) is shown from a pre-scaled
  asset (`tui/penguin_image.bin`, made by `scripts/gen-penguin-image.py`, 589 KB at three sizes) in the
  rows the pixel-art face used. The not-yet-filled part is dimmed and fills from the feet up. If no image
  of the needed size exists, or on curses, the pixel-art face is drawn instead.

## Consequences and limits
- Two drawing paths exist during the migration (curses and framebuffer). They must produce the same
  text positions; a test compares them.
- Keyboard handling without curses is new code. Layouts other than US depend on the kernel keymap, which
  the terminal already applies, so the same keys reach the program as now.
- A crash in graphics mode can leave the screen blank. Restoring `KD_TEXT` must happen in a `finally`
  block and in a signal handler for SIGTERM/SIGINT.
- Not verified yet: framebuffer format on real hardware; behaviour of fbcon takeover in QEMU; screen
  sizes other than the QEMU defaults.
- The daemon option (ADR later, if needed) is not chosen here. It becomes necessary only if several
  programs must share the screen.

## What the first QEMU run found (2026-11-12)
Writing frames to `/dev/fb0` never reached the screen on the VM's `bochs-drm` display (even with the console
in graphics mode), while the text console did. A DRM/KMS dumb buffer with a mode set does reach it, so
`DrmSink` (`/dev/dri/card*`: GETRESOURCES, connector, encoder, CREATE_DUMB, ADDFB, MAP_DUMB, SETCRTC) is the
preferred backend and fbdev is only the fallback. Two bugs came from the real kernel: request numbers above
2**31 must be passed as signed ints, and the structure must be passed as the ioctl buffer.

## Fixes from the pre-release scan
- A fallback to the text console, a refused `set_master`, a refused `dirtyfb` and a refused console-mode switch
  are logged (stderr and `/run/axiom-ui.log`), so a silent fallback leaves a trace. The login (unprivileged)
  logs to stderr, which greetd puts in its journal.
- The installer adds `greeter` to group `video` so the login can open `/dev/dri`.
- `AXIOM_BACKEND_CMD` is honoured only by `--demo-install`; a preview (`AXIOM_FB_PNG`) refuses to install;
  the text-mirror hook writes only directly under `/run`, never through a symlink.
- Only the pixel rows that changed are sent to the screen; typed non-ASCII (UTF-8) characters are accepted.
- Unused gradient code was removed. A retry no longer replays the earlier run's log into the progress bar,
  and cleanup closes only the LUKS mappers that sit on the target disk.

## Implementation notes
- `FbScreen` implements the curses calls `axiom_tui.UI` uses, so each screen's layout code is unchanged;
  `axiom_tui.run()` replaces `curses.wrapper` and `axiom_tui.endwin()` releases the console for a shell.
- Preview and test hooks: `AXIOM_FB_PNG=<dir>` draws to PNG files, `AXIOM_FB_KEYS` scripts key presses,
  `AXIOM_FB_TEXT=<file>` mirrors the screen's characters (the QEMU harness reads this instead of
  `/dev/vcs1`, which a pixel-drawn screen never fills).
- Backend order: DRM, then fbdev, then curses (`AXIOM_FB_BACKEND=drm|fbdev` forces one). Curses is used when
  `TERM` is not `linux`, there is no stdin tty, the font is missing, or no backend opens.

## Rollback
Set `AXIOM_UI=curses` (or remove the framebuffer path) and both programs use the existing curses code.
The curses code stays until the framebuffer path has passed the QEMU install and login tests.

Related: [[024-graphical-greeter]], [[025-boot-ui]], [[026-installer-privilege]].
