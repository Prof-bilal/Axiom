# Axiom Phase 3: start the graphical session on the first local VT.
# This is the login -> session -> compositor -> shell entry point.
if [ -z "$WAYLAND_DISPLAY" ] && [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
  exec /usr/local/bin/axiom-session
fi
