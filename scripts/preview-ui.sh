#!/usr/bin/env bash
# Render the installer and login screens to PNG files with the pixel renderer (ADR-027).
# No VM, no root, no ISO build:   scripts/preview-ui.sh [outdir]      (default /tmp/axiom-ui)
set -eu
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${1:-/tmp/axiom-ui}"
rm -rf "$OUT"
shot() { name="$1"; shift; env AXIOM_FB_PNG="$OUT/$name" "$@"; }

shot login        AXIOM_FB_EVERY=1 AXIOM_PREVIEW_HOLD=0 python3 "$ROOT/greeter/axiom-greeter" --preview
shot welcome-and-language AXIOM_FB_KEYS="enter,down,right,down,right" python3 "$ROOT/installer/axiom-installer"
for pct in 12 54 100; do
  shot "progress-$pct" AXIOM_DEMO_PCT=$pct AXIOM_DEMO_HOLD=0 python3 "$ROOT/installer/axiom-installer" --demo-progress
done
find "$OUT" -name '*.png' | sort
