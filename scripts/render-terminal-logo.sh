#!/usr/bin/env bash
# Render the Axiom Terminal greeting logo (A-mark + "Axiom OS") as a sixel
# image for foot. Output is committed so image builds need no image tooling.
#
#   scripts/render-terminal-logo.sh <InterVariable.ttf>
#
# Requires rsvg-convert and ImageMagick (magick). The font is used through a
# private fontconfig file; nothing is installed on the host.
#
# Height is 48 px: three terminal rows at the Axiom foot line height (17 px)
# on a scale-1 output. axiom-greeting reserves three rows for it.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FONT="${1:?usage: $0 <path to InterVariable.ttf>}"
OUT_DIR="$ROOT/iso/phase3/airootfs/usr/local/share/axiom/terminal"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

mkdir -p "$OUT_DIR" "$WORK/fonts"
cp "$FONT" "$WORK/fonts/"
cat > "$WORK/fonts.conf" <<EOF
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig><dir>$WORK/fonts</dir><cachedir>$WORK/cache</cachedir></fontconfig>
EOF

# A-mark geometry is branding/identity/axiom-mark.svg (148-unit box), scaled.
cat > "$WORK/logo.svg" <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" width="250" height="48" viewBox="0 0 250 48">
  <defs>
    <linearGradient id="mark" x1="0" y1="0" x2="1" y2="0.35">
      <stop offset="0" stop-color="#37F0EA"/>
      <stop offset="0.55" stop-color="#20D6D2"/>
      <stop offset="1" stop-color="#FF9418"/>
    </linearGradient>
    <linearGradient id="os" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#FFB348"/>
      <stop offset="1" stop-color="#FF9418"/>
    </linearGradient>
  </defs>
  <g transform="translate(0 3) scale(0.30)">
    <path fill="url(#mark)" fill-rule="evenodd"
          d="M74 4L136 144H109L96 112H52L39 144H12Z M74 42L88 82H60Z"/>
  </g>
  <text x="54" y="37" font-family="Inter" font-size="34" font-weight="600"
        letter-spacing="-0.5" fill="#EDF5F5">Axiom</text>
  <text x="160" y="37" font-family="Inter" font-size="34" font-weight="400"
        fill="url(#os)">OS</text>
</svg>
EOF

FONTCONFIG_FILE="$WORK/fonts.conf" rsvg-convert "$WORK/logo.svg" -o "$WORK/logo.png"
magick "$WORK/logo.png" -trim +repage -background none -gravity west -extent x48 "$WORK/logo-trim.png"
cp "$WORK/logo-trim.png" "$OUT_DIR/axiom-logo.png"
magick "$WORK/logo-trim.png" -colors 96 sixel:"$OUT_DIR/axiom-logo.six"
echo "render-terminal-logo: wrote $OUT_DIR/axiom-logo.{png,six} ($(magick identify -format '%wx%h' "$WORK/logo-trim.png"))"
