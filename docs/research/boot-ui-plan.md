# Axiom boot UI plan: selector, splash, installer

Status: proposal, not approved. Reference: Omarchy 4.0.6 (`/usr/share/omarchy/`), read on 2026-11-10.

## Why
Current boot, installer and login screens are text-mode (curses). The goal is a clean, unique,
graphical look with animation, using the Axiom palette and the pixel penguin.

## Reference from Omarchy (what to keep, what to avoid)
- **Splash:** Plymouth `script` theme, dark background, centered logo, progress bar. Their progress
  is faked (ease-out to 70% over 15 s). Avoid faking it. Use real progress and an animated sprite.
- **Boot:** UKI booted directly (`omarchy-setup-direct-boot`), with no visible menu. Axiom's selector
  is our own design choice.
- **Setup form:** gum-based text prompts with Esc = back and one shared form for installer and
  first boot. Keep the shared-form idea, not the terminal widgets.

## Three layers, one palette
1. **Boot selector.** Corrected: the installed system uses systemd-boot, which cannot show images, so
   the menu stays hidden (`timeout 0`) and the visible boot screen is the Plymouth splash. The live ISO
   BIOS menu gets an Axiom syslinux splash. See [[025-boot-ui]] (`docs/decisions/025-boot-ui.md`).
   No GRUB.
2. **Splash.** Plymouth script theme. Animated penguin sprite (4-6 frames from the existing pixel
   grid in `tui/penguin_art.py`) plus a real progress bar.
3. **Installer and login.** Quickshell QML, the same stack as `shell/src/session/LockScreen.qml`.
   Depends on Part B (graphical greetd greeter) landing first.

## Steps
1. Check the ISO bootloader (`iso/profile`, archiso config). Record it in an ADR.
2. Make a penguin sprite sheet from the existing pixel map (generator in `scripts/`).
3. Plymouth theme `axiom`: static logo first, then the animated penguin, then the real progress bar.
4. Boot selector theme for the chosen bootloader, same palette.
5. Installer in QML (after Part B), reusing the greeter's components. Keep the curses installer as
   a fallback until QML is verified.
6. Each step gets a QEMU boot with retained serial and display evidence, per AGENTS.md.

## Decisions needed
- Which bootloader does the ISO use today? Determines step 4.
- Installer in QML now, or after Part B? Recommended: after Part B.
- Keep the current pixel penguin, or commission a new one for animation?

## Risks
- Plymouth and bootloader themes are not testable without a boot in QEMU; allow time for that.
- A QML installer needs a running compositor on the live ISO, which the curses installer does not.
- Animation on slow hardware: keep frame count low and let the progress bar be the only moving part
  if performance is poor.
