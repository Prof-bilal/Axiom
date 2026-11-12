#!/usr/bin/env bash
# Build the Axiom Phase 3 graphical-session ISO.
#
#   scripts/build-phase3-iso.sh
#
# Stages the Axiom Shell into the Phase 3 profile (the profile itself is not
# mutated), then runs mkarchiso with evidence capture. Uses only official Arch
# repositories (iso/phase3/pacman.conf); no third-party desktop repository.
#
# Environment overrides:
#   AXIOM_PHASE3_PROFILE  source profile (default iso/phase3)
#   AXIOM_PHASE3_WORK     work dir      (default iso/work-phase3)
#   AXIOM_PHASE3_OUT      output dir    (default iso/out-phase3)
#   SOURCE_DATE_EPOCH     fixed build timestamp (default: last git commit time)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE_SRC="${AXIOM_PHASE3_PROFILE:-$ROOT/iso/phase3}"
WORK="${AXIOM_PHASE3_WORK:-$ROOT/iso/work-phase3}"
OUT="${AXIOM_PHASE3_OUT:-$ROOT/iso/out-phase3}"
EVIDENCE="$OUT/evidence"
SHELL_SRC="$ROOT/shell"

die() { echo "build-phase3-iso: $*" >&2; exit 1; }

command -v mkarchiso >/dev/null 2>&1 \
  || die "mkarchiso not found; install it first: sudo pacman -S --needed archiso"
[ -f "$PROFILE_SRC/profiledef.sh" ] || die "missing profile: $PROFILE_SRC/profiledef.sh"
[ -f "$SHELL_SRC/shell.qml" ] || die "missing shell entry point: $SHELL_SRC/shell.qml"

if [ "$(id -u)" -ne 0 ]; then
  command -v unshare >/dev/null 2>&1 \
    || die "not root and 'unshare' is unavailable; re-run as: sudo $0"
  if [ "$(cat /proc/sys/user/max_user_namespaces 2>/dev/null || echo 1)" = "0" ] \
     && [ "$(cat /proc/sys/kernel/unprivileged_userns_clone 2>/dev/null || echo 1)" = "0" ]; then
    die "not root and unprivileged user namespaces are disabled; re-run as: sudo $0"
  fi
  echo "build-phase3-iso: running unprivileged via mkarchiso user namespaces" >&2
fi

if [ "$(id -u)" -eq 0 ]; then
  _rm_work() { rm -rf -- "$1"; }
else
  _rm_work() { unshare --map-auto --map-root-user rm -rf -- "$1"; }
fi

SOURCE_DATE_EPOCH="${SOURCE_DATE_EPOCH:-$(git -C "$ROOT" log -1 --format=%ct 2>/dev/null || date +%s)}"
export SOURCE_DATE_EPOCH

mkdir -p "$OUT" "$EVIDENCE"
_rm_work "$WORK"

# Stage a private copy of the profile and place the built shell inside it.
mkdir -p "$WORK"
cp -r "$PROFILE_SRC" "$WORK/profile"
install -d "$WORK/profile/airootfs/usr/local/share/axiom"
cp -r "$SHELL_SRC" "$WORK/profile/airootfs/usr/local/share/axiom/shell"
# Core apps (Phase 4): staged as a sibling of the shell; shell/apps is a
# relative symlink to ../apps, so the apps share the shell's config root.
cp -r "$ROOT/apps" "$WORK/profile/airootfs/usr/local/share/axiom/apps"
rm -rf "$WORK/profile/airootfs/usr/local/share/axiom/shell/tests"
# Installer (Phase 6): backend, TUI and the Developer Hub catalogue.
install -d "$WORK/profile/airootfs/usr/local/lib/axiom-installer"
cp "$ROOT"/installer/axiom_install.py "$ROOT"/installer/axiom-installer "$WORK/profile/airootfs/usr/local/lib/axiom-installer/"
cp -r "$ROOT/catalog" "$WORK/profile/airootfs/usr/local/lib/axiom-installer/catalog"
ln -sf /usr/local/lib/axiom-installer/axiom-installer "$WORK/profile/airootfs/usr/local/bin/axiom-installer"
install -d "$WORK/profile/airootfs/usr/local/lib/axiom-tui"
cp "$ROOT"/tui/axiom_tui.py "$ROOT"/tui/fbdraw.py "$ROOT"/tui/penguin_art.py "$ROOT"/tui/penguin_image.bin "$ROOT"/tui/axiom-setfont "$WORK/profile/airootfs/usr/local/lib/axiom-tui/"
install -d "$WORK/profile/airootfs/usr/local/lib/axiom-greeter"
cp "$ROOT/greeter/axiom-greeter" "$ROOT/greeter/axiom-greeter-graphical" "$WORK/profile/airootfs/usr/local/lib/axiom-greeter/"
cp -r "$ROOT/greeter/qml" "$ROOT/greeter/labwc" "$WORK/profile/airootfs/usr/local/lib/axiom-greeter/"
install -d "$WORK/profile/airootfs/usr/local/lib/axiom-provision" "$WORK/profile/airootfs/usr/local/share/axiom/catalog"
cp "$ROOT"/provision/axiom-provision "$ROOT"/provision/axiom-provision.service "$WORK/profile/airootfs/usr/local/lib/axiom-provision/"
cp "$ROOT/catalog/developer-hub.json" "$WORK/profile/airootfs/usr/local/share/axiom/catalog/"
ln -sf /usr/local/lib/axiom-provision/axiom-provision "$WORK/profile/airootfs/usr/local/bin/axiom-provision"

# Build a fresh, build-user-owned pacman keyring.
#
# An unprivileged mkarchiso run uses the *host* GPGDir (pacman does not
# root-prefix GpgDir), which is root-owned and therefore unwritable inside the
# user namespace; any key import then fails. Point pacman at a keyring we own,
# generated from the current archlinux-keyring package inputs.
KEYRING="$WORK/keyring"
rm -rf "$KEYRING"
mkdir -p "$KEYRING"
chmod 700 "$KEYRING"
_KR=/usr/share/pacman/keyrings
if [ -f "$_KR/archlinux.gpg" ]; then
  gpg --homedir "$KEYRING" --quiet --batch --import "$_KR/archlinux.gpg"
  gpg --homedir "$KEYRING" --with-colons --list-keys 2>/dev/null \
    | awk -F: '/^fpr/{print $10":6:"}' > "$KEYRING/ownertrust.txt"
  gpg --homedir "$KEYRING" --quiet --batch --import-ownertrust "$KEYRING/ownertrust.txt"
  gpg --homedir "$KEYRING" --check-trustdb || true
  rm -f "$KEYRING/ownertrust.txt"
  echo "build-phase3-iso: keyring has $(gpg --homedir "$KEYRING" --list-keys 2>/dev/null | grep -c '^pub') keys"
else
  echo "build-phase3-iso: warning: $_KR/archlinux.gpg missing; using host keyring behavior" >&2
fi

# Inject the build keyring into the staged pacman.conf.
python3 - "$WORK/profile/pacman.conf" "$KEYRING" <<'PY'
import sys
path, keyring = sys.argv[1], sys.argv[2]
lines = open(path).read().splitlines()
out = []
for line in lines:
    out.append(line)
    if line.strip() == "[options]":
        out.append(f"GPGDir = {keyring}/")
open(path, "w").write("\n".join(out) + "\n")
PY

{
  echo "== build environment (UTC $(date -u +%Y-%m-%dT%H:%M:%SZ)) =="
  echo "archiso:      $(pacman -Q archiso 2>/dev/null || echo unknown)"
  echo "kernel:       $(uname -r)"
  echo "python:       $(python3 --version 2>&1 || echo unknown)"
  echo "SOURCE_DATE_EPOCH=$SOURCE_DATE_EPOCH"
  echo "profile_rev:  $(git -C "$ROOT" rev-parse HEAD 2>/dev/null || echo none)"
  echo "shell_files:  $(find "$SHELL_SRC" -type f | wc -l)"
  echo "packages:     $(grep -cvE '^\s*(#|$)' "$PROFILE_SRC/packages.x86_64")"
} | tee "$EVIDENCE/versions.txt"

mkarchiso -v -w "$WORK/build" -o "$OUT" "$WORK/profile" 2>&1 | tee "$EVIDENCE/build.log"

cp "$PROFILE_SRC/packages.x86_64" "$EVIDENCE/packages-declared.txt"
AIROOTFS="$WORK/build/x86_64/airootfs"
if [ -d "$AIROOTFS/var/lib/pacman" ]; then
  pacman -Q --root "$AIROOTFS" > "$EVIDENCE/pkglist.txt" 2>/dev/null \
    || echo "build-phase3-iso: warning: could not read installed manifest" >&2
fi

{
  echo "-- ISO artifacts --"
  ( cd "$OUT" && sha256sum ./*.iso 2>/dev/null || true )
  echo "-- rootfs images --"
  find "$WORK/build" -name '*.sfs' -type f -exec sha256sum {} + 2>/dev/null || true
} | tee "$EVIDENCE/sha256sums.txt"

echo "build-phase3-iso: done. Evidence in $EVIDENCE"
