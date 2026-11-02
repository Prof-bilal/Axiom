#!/usr/bin/env bash
# Host-side Axiom Shell smoke test.
#
# Boots a disposable headless compositor harness (sway) on a private Wayland
# socket, starts the Axiom Shell inside it, screenshots the result and fails on
# QML errors. This is a fast development loop; the acceptance gate is QEMU.
#
#   tests/phase3-smoke.sh [shell-dir] [outdir]
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SHELL_DIR="${1:-$ROOT/shell}"
OUT="${2:-$ROOT/iso/out/evidence/shell-smoke}"

for tool in sway quickshell grim; do
  command -v "$tool" >/dev/null 2>&1 || { echo "phase3-smoke: missing $tool" >&2; exit 1; }
done
[ -f "$SHELL_DIR/shell.qml" ] || { echo "phase3-smoke: no shell.qml in $SHELL_DIR" >&2; exit 1; }

mkdir -p "$OUT"
RUNTIME="$(mktemp -d "$OUT/runtime.XXXXXX")"
chmod 700 "$RUNTIME"
export XDG_RUNTIME_DIR="$RUNTIME"
export WAYLAND_DISPLAY="wayland-axiom"

SWAY_CONF="$RUNTIME/sway.conf"
cat > "$SWAY_CONF" <<'EOF'
# Axiom smoke-test harness config (temporary; not a product config).
EOF

pids=()
cleanup() {
  for pid in "${pids[@]:-}"; do
    [ -n "$pid" ] && kill -TERM "$pid" 2>/dev/null || true
  done
  sleep 1
  for pid in "${pids[@]:-}"; do
    [ -n "$pid" ] && kill -KILL "$pid" 2>/dev/null || true
  done
}
trap cleanup EXIT

echo "phase3-smoke: starting headless harness (sway)"
WLR_BACKENDS=headless WLR_LIBINPUT_NO_DEVICES=1 WLR_RENDERER=pixman \
  sway -c "$SWAY_CONF" >"$OUT/sway.log" 2>&1 &
sway_pid=$!
pids+=("$sway_pid")

for _ in $(seq 1 50); do
  [ -S "$RUNTIME/$WAYLAND_DISPLAY" ] && break
  sleep 0.1
done
[ -S "$RUNTIME/$WAYLAND_DISPLAY" ] || { echo "phase3-smoke: harness socket never appeared" >&2; cat "$OUT/sway.log" >&2; exit 1; }

export SWAYSOCK="$(ls "$RUNTIME"/sway-ipc.*.sock 2>/dev/null | head -1 || true)"
export I3SOCK="$SWAYSOCK"
echo "phase3-smoke: harness up (SWAYSOCK=${SWAYSOCK:-none})"

echo "phase3-smoke: starting Axiom Shell"
QT_QPA_PLATFORM=wayland quickshell -p "$SHELL_DIR" >"$OUT/shell.log" 2>&1 &
pids+=("$!")

# Wait for the shell to render something.
sleep 4

if ! kill -0 "$sway_pid" 2>/dev/null; then
  echo "phase3-smoke: harness died" >&2
  cat "$OUT/sway.log" >&2
  exit 1
fi

echo "phase3-smoke: capturing screenshot"
if ! grim "$OUT/desktop.png" 2>"$OUT/grim.log"; then
  echo "phase3-smoke: grim failed" >&2
  cat "$OUT/grim.log" >&2
fi

echo "phase3-smoke: dumping harness tree + workspaces"
swaymsg -t get_tree >"$OUT/tree.json" 2>/dev/null || true
swaymsg -t get_workspaces >"$OUT/workspaces.json" 2>/dev/null || true
swaymsg -t get_outputs >"$OUT/outputs.json" 2>/dev/null || true

echo "phase3-smoke: shell log errors"
if grep -nEi "error|failed|cannot|is not a|undefined" "$OUT/shell.log" | grep -viE "no output|ErrorHandler" | head -30; then
  echo "phase3-smoke: FAIL (see $OUT/shell.log)"
  exit 1
fi

echo "phase3-smoke: PASS (artifacts in $OUT)"
