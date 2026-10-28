# File manager evidence

Status: SOURCE-INSPECTED / DOCUMENTED (2026-10-28). The host has Nautilus
51.1-1 installed (`pacman -Qi nautilus`) with GPL-3.0-or-later licensing and
the desktop entry `org.gnome.Nautilus.desktop`. This is package/source evidence,
not a claim that Nautilus is present in the Phase 2 foundation image. The
freedesktop FileChooser portal is the preferred contract for application-owned
open/save flows; the shell must not replace it with a privileged browser.
