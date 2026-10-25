#!/usr/bin/env bash
# Reproducible archiso build with evidence capture.
#
#   sudo scripts/build-iso.sh
#
# Environment overrides:
#   AXIOM_WORK_DIR       work tree   (default iso/work)
#   AXIOM_OUT_DIR        output dir  (default iso/out)
#   AXIOM_EVIDENCE_DIR   evidence dir (default iso/out/evidence; set per run to compare builds)
#   SOURCE_DATE_EPOCH    fixed build timestamp (default: last git commit time)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE="${AXIOM_PROFILE:-$ROOT/iso/profile}"
WORK="${AXIOM_WORK_DIR:-$ROOT/iso/work}"
OUT="${AXIOM_OUT_DIR:-$ROOT/iso/out}"
EVIDENCE="${AXIOM_EVIDENCE_DIR:-$OUT/evidence}"

die() { echo "build-iso: $*" >&2; exit 1; }

command -v mkarchiso >/dev/null 2>&1 \
  || die "mkarchiso not found; install it first: sudo pacman -S --needed archiso"
[ -d "$PROFILE" ] || die "missing profile: $PROFILE"
[ -f "$PROFILE/profiledef.sh" ] || die "missing profile definition: $PROFILE/profiledef.sh"

# archiso v91 runs unprivileged via user namespaces (unshare --map-root-user) when
# they are available; otherwise it needs root. Validate the builder rather than
# assuming root is always required.
if [ "$(id -u)" -ne 0 ]; then
  command -v unshare >/dev/null 2>&1 \
    || die "not root and 'unshare' is unavailable; re-run as: sudo $0"
  if [ "$(cat /proc/sys/user/max_user_namespaces 2>/dev/null || echo 1)" = "0" ] \
     && [ "$(cat /proc/sys/kernel/unprivileged_userns_clone 2>/dev/null || echo 1)" = "0" ]; then
    die "not root and unprivileged user namespaces are disabled; re-run as: sudo $0"
  fi
  echo "build-iso: running unprivileged via mkarchiso user namespaces" >&2
fi

# Work-tree cleanup. An unprivileged build leaves entries owned by unmapped system
# uids (e.g. var/lib/nfs/statd) and read-only directories; only the mapped-root
# namespace can remove them, so mirror mkarchiso and clean inside the namespace.
if [ "$(id -u)" -eq 0 ]; then
  _rm_work() { rm -rf -- "$1"; }
else
  _rm_work() { unshare --map-auto --map-root-user rm -rf -- "$1"; }
fi

SOURCE_DATE_EPOCH="${SOURCE_DATE_EPOCH:-$(git -C "$ROOT" log -1 --format=%ct 2>/dev/null || date +%s)}"
export SOURCE_DATE_EPOCH

mkdir -p "$OUT" "$EVIDENCE"
# Remove only the task-owned work tree. Never touch anything outside it.
_rm_work "$WORK"

{
  echo "== build environment (UTC $(date -u +%Y-%m-%dT%H:%M:%SZ)) =="
  echo "archiso:      $(pacman -Q archiso 2>/dev/null || echo unknown)"
  echo "kernel:       $(uname -r)"
  echo "python:       $(python3 --version 2>&1 || echo unknown)"
  echo "SOURCE_DATE_EPOCH=$SOURCE_DATE_EPOCH"
  echo "profile_rev:  $(git -C "$ROOT" rev-parse HEAD 2>/dev/null || echo none)"
  echo "sqlite:       $(python3 -c 'import sqlite3;print(sqlite3.sqlite_version)' 2>/dev/null || echo n/a)"
} | tee "$EVIDENCE/versions.txt"

# Record the exact package/repository inputs, not just the architecture.
pacman -Q > "$EVIDENCE/pkglist-host.txt" 2>/dev/null || true
sha256sum /var/lib/pacman/sync/*.db > "$EVIDENCE/repo-db-sha256.txt" 2>/dev/null || true

# Build. Full stdout/stderr is preserved; signature verification is never disabled.
mkarchiso -v -w "$WORK" -o "$OUT" "$PROFILE" 2>&1 | tee "$EVIDENCE/build.log"

# Package manifests: declared input, plus the exact installed set from the
# persisted work-tree airootfs (mkarchiso keeps the work dir unless -r is passed).
cp "$PROFILE/packages.x86_64" "$EVIDENCE/packages-declared.txt"
AIROOTFS="$WORK/x86_64/airootfs"
if [ -d "$AIROOTFS/var/lib/pacman" ]; then
  pacman -Q --root "$AIROOTFS" > "$EVIDENCE/pkglist.txt" 2>/dev/null \
    || echo "build-iso: warning: could not read installed manifest from $AIROOTFS" >&2
else
  echo "build-iso: warning: work-tree airootfs not found; installed manifest unavailable" >&2
fi

{
  echo "-- ISO artifacts --"
  ( cd "$OUT" && sha256sum ./*.iso 2>/dev/null || true )
  echo "-- work-tree rootfs images --"
  find "$WORK" -name '*.sfs' -type f -exec sha256sum {} + 2>/dev/null || true
} | tee "$EVIDENCE/sha256sums.txt"

echo "build-iso: done. Evidence in $EVIDENCE"
