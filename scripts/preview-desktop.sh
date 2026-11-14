#!/usr/bin/env bash
# Screenshot every Axiom UI (desktop, menus, apps, terminal) in a nested Hyprland window.
# No VM, no root, no ISO build. Needs a running Wayland session plus: Hyprland, quickshell (qs), grim, foot.
#   scripts/preview-desktop.sh [outdir] [--keep]      (default /tmp/axiom-preview)
# --keep leaves the nested window open when done so you can click around.
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${1:-/tmp/axiom-preview}"
KEEP=0; for a in "$@"; do [ "$a" = "--keep" ] && KEEP=1; done
[ "$OUT" = "--keep" ] && OUT=/tmp/axiom-preview
for tool in Hyprland qs grim; do command -v "$tool" >/dev/null || { echo "missing: $tool"; exit 2; }; done
mkdir -p "$OUT"; rm -f "$OUT"/*.png
RT="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
TMP="$(mktemp -d)"
SHELL_QML="$ROOT/shell/shell.qml"

cat > "$TMP/nested.conf" <<EOF
monitor = , 1920x1080@60, 0x0, 1
misc {
    disable_hyprland_logo = true
    disable_splash_rendering = true
}
general {
    gaps_in = 6
    gaps_out = 12
}
exec-once = qs -p $SHELL_QML
EOF

before="$(ls "$RT" | grep -E '^wayland-[0-9]+$' | sort)"
Hyprland -c "$TMP/nested.conf" >"$TMP/hypr.log" 2>&1 &
HYPR=$!
NEST=""
for _ in $(seq 1 30); do
  sleep 0.5
  NEST="$(comm -13 <(echo "$before") <(ls "$RT" | grep -E '^wayland-[0-9]+$' | sort) | head -1)"
  [ -n "$NEST" ] && break
done
[ -n "$NEST" ] || { echo "nested Hyprland did not start (see $TMP/hypr.log)"; kill "$HYPR" 2>/dev/null; exit 1; }
export WAYLAND_DISPLAY="$NEST"
sleep 6   # let the shell draw its panel and dock

shot() { sleep "${2:-2}"; grim "$OUT/$1.png" && echo "$OUT/$1.png"; }
ipc() { qs ipc -p "$SHELL_QML" call axiom "$@" >/dev/null 2>&1; }

shot 01-desktop 0
for view in toggleAxiomMenu toggleApps toggleActivities toggleControlCenter toggleNotificationCenter toggleSessionMenu; do
  ipc "$view"; shot "02-${view#toggle}" 1.5; ipc closeOverlays; sleep 0.5
done

# Apps: each is its own quickshell config. Close it by killing only the process we started.
for app in files settings software hub appinstaller; do
  qs -p "$ROOT/shell/$app.qml" >/dev/null 2>&1 &
  APID=$!
  shot "03-app-$app" 6
  kill "$APID" 2>/dev/null; wait "$APID" 2>/dev/null
done

if command -v foot >/dev/null; then
  foot -c "$ROOT/iso/phase3/airootfs/etc/xdg/foot/foot.ini" >/dev/null 2>&1 &
  FPID=$!
  shot 04-terminal 3
  kill "$FPID" 2>/dev/null; wait "$FPID" 2>/dev/null
fi

ipc lock; shot 05-lockscreen 2

echo "done: $OUT"
if [ "$KEEP" = 1 ]; then echo "nested window left open (kill $HYPR to close)"; else kill "$HYPR" 2>/dev/null; rm -rf "$TMP"; fi
