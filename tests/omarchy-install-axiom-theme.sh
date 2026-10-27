#!/usr/bin/env bash
# Install the Phase 2 Axiom theme into a disposable Omarchy test guest.
#
#   AXIOM_VM_SUDO_PASSWORD=... tests/omarchy-install-axiom-theme.sh \
#       --host 127.0.0.1 --port 2222 --key path/to/id_ed25519
#
# The theme lands in ~/.config/omarchy/themes/axiom (user-owned). With a sudo
# password the SDDM and Plymouth logos are replaced in the test guest only.
# Never point this at a production machine.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOST=127.0.0.1
PORT=2222
KEY=""
USER_NAME=omarchy
SUDO_PASSWORD="${AXIOM_VM_SUDO_PASSWORD:-}"

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

tar -C "$ROOT/branding" -cf - theme/axiom identity/axiom-wordmark.png |
  ssh "${ssh_opts[@]}" "$remote" 'rm -rf /tmp/axiom-brand && mkdir -p /tmp/axiom-brand && tar -xf - -C /tmp/axiom-brand'

ssh "${ssh_opts[@]}" "$remote" '
  set -e
  mkdir -p ~/.config/omarchy/themes
  rm -rf ~/.config/omarchy/themes/axiom
  cp -a /tmp/axiom-brand/theme/axiom ~/.config/omarchy/themes/axiom
  omarchy theme set axiom
'

if [[ -n "$SUDO_PASSWORD" ]]; then
  printf '%s\n' "$SUDO_PASSWORD" | ssh "${ssh_opts[@]}" "$remote" '
    set -e
    sudo -S sh -c "
      install -m 0644 /tmp/axiom-brand/identity/axiom-wordmark.png /usr/share/sddm/themes/omarchy/logo.png
      install -m 0644 /tmp/axiom-brand/identity/axiom-wordmark.png /usr/share/plymouth/themes/omarchy/logo.png
      plymouth-set-default-theme -R omarchy
    "
  '
  echo "Axiom theme + SDDM/Plymouth logos installed in the test guest."
else
  echo "Axiom user theme installed. SDDM/Plymouth logos unchanged (no sudo password supplied)."
fi
