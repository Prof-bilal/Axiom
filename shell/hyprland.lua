-- Axiom Shell keybinding example. Merge this into ~/.config/hypr/bindings.lua.
-- Use the installed shell path; the test VM uses ~/.local/share/axiom/shell.
hl.unbind("SUPER + SPACE")
o.bind("SUPER + SPACE", "Axiom launcher",
  "quickshell -p /usr/share/axiom/shell ipc call axiom.shell toggleLauncher")
