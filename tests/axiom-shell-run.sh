#!/usr/bin/env bash
# Load the Axiom Shell into a disposable Omarchy test guest.
#
#   tests/axiom-shell-run.sh --key path/to/id_ed25519 [--port 2222]
#
# It replaces the running Omarchy Quickshell instance in the guest. It does not
# install a service, modify the host, or touch a persistence image.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOST=127.0.0.1
PORT=2222
KEY=""
USER_NAME=omarchy

usage() {
  sed -n '2,9p' "$0" >&2
  exit 2
}
while [[ $# -gt 0 ]]; do
  case "$1" in
    --host) HOST="$2"; shift 2 ;;
    --port) PORT="$2"; shift 2 ;;
    --key) KEY="$2"; shift 2 ;;
    --user) USER_NAME="$2"; shift 2 ;;
    *) usage ;;
  esac
done
[[ -n "$KEY" && -s "$KEY" ]] || usage

ssh_opts=(-i "$KEY" -p "$PORT" -o BatchMode=yes -o IdentitiesOnly=yes
  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR)
remote="$USER_NAME@$HOST"

tar -C "$ROOT" -cf - shell branding/theme/axiom/backgrounds/aurora.png branding/theme/axiom/icons/axiom-penguin.png |
  ssh "${ssh_opts[@]}" "$remote" '
    rm -rf /tmp/axiom-shell-incoming
    mkdir -p /tmp/axiom-shell-incoming
    tar -xf - -C /tmp/axiom-shell-incoming
    mkdir -p ~/.local/share/axiom
    rm -rf ~/.local/share/axiom/shell
    cp -a /tmp/axiom-shell-incoming/shell ~/.local/share/axiom/shell
    install -m 0644 /tmp/axiom-shell-incoming/branding/theme/axiom/backgrounds/aurora.png ~/.local/share/axiom/aurora.png
    install -m 0644 /tmp/axiom-shell-incoming/branding/theme/axiom/icons/axiom-penguin.png ~/.local/share/axiom/axiom-penguin.png
    export XDG_RUNTIME_DIR=/run/user/1000
    export LANG=C.UTF-8
    export WAYLAND_DISPLAY=$(basename "$(ls /run/user/1000/wayland-* | head -1)")
    export HYPRLAND_INSTANCE_SIGNATURE=$(basename "$(ls -d /run/user/1000/hypr/* | head -1)")
    omarchy toggle idle stay-awake >/dev/null 2>&1 || true
    # Match the kernel comm name only. A -f pattern would appear in this SSH
    # command argv and kill the session; quoting it here also breaks the
    # single-quoted remote script, so pgrep -x on comm is the safe form.
    for pid in $(pgrep -x omarchy-launch- || true); do
      kill -TERM "$pid" 2>/dev/null || true
    done
    pkill -TERM -x quickshell 2>/dev/null || true
    sleep 1
    setsid env XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" LANG=C.UTF-8 WAYLAND_DISPLAY="$WAYLAND_DISPLAY" \
      HYPRLAND_INSTANCE_SIGNATURE="$HYPRLAND_INSTANCE_SIGNATURE" \
      quickshell -n -p "$HOME/.local/share/axiom/shell" >/tmp/axiom-shell.log 2>&1 < /dev/null &
    sleep 3
    echo "== axiom shell processes =="
    pgrep -af "quickshell" || true
    echo "== log =="
    sed -n "1,80p" /tmp/axiom-shell.log 2>/dev/null || true
  '
