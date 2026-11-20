#!/usr/bin/env python3
"""Generate the Axiom cursor theme (dark glass shapes with a cyan edge, amber accents).

    python3 scripts/gen-cursors.py          # write the theme into the ISO profile
    python3 scripts/gen-cursors.py --check  # only verify the SVGs are well-formed XML

Output: iso/phase3/airootfs/usr/share/icons/axiom-cursors/{index.theme,cursors/*} in the
Xcursor format (written here directly, no xcursorgen needed), with the usual alias
names as symlinks. Frames are rendered with rsvg-convert at 24, 32, 48 and 64 px.
"""
import math, os, struct, subprocess, sys
import xml.dom.minidom

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
THEME = os.path.join(ROOT, "iso/phase3/airootfs/usr/share/icons/axiom-cursors")
SIZES = (24, 32, 48, 64)
CYAN, AMBER, FILL, RED = "#37F0EA", "#FFB348", "#102A31", "#FF5252"
BASE = 64  # all shapes are drawn on a 64 x 64 canvas

ARROW = "M8,4 L8,46 L19,36 L27,55 L35,51 L27,33 L42,33 Z"


def svg(body):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {BASE} {BASE}" width="{BASE}" height="{BASE}">'
            f"{body}</svg>")


def arrow(extra=""):
    return svg(f'<path d="{ARROW}" fill="{FILL}" stroke="{CYAN}" stroke-width="3" stroke-linejoin="round"/>{extra}')


def ring(angle, small=False):
    """A cyan-to-amber arc ring; `angle` rotates it. `small` puts it at the bottom right."""
    cx, cy, r, w = (46, 46, 10, 4) if small else (32, 32, 20, 6)
    return (f'<g transform="rotate({angle} {cx} {cy})">'
            f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="none" stroke="#1c4047" stroke-width="{w}"/>'
            f'<path d="M{cx},{cy - r} A{r},{r} 0 0 1 {cx + r},{cy}" fill="none" stroke="{CYAN}" stroke-width="{w}" stroke-linecap="round"/>'
            f'<path d="M{cx + r},{cy} A{r},{r} 0 0 1 {cx},{cy + r}" fill="none" stroke="{AMBER}" stroke-width="{w}" stroke-linecap="round"/>'
            f"</g>")


def double_arrow(angle):
    return svg(f'<g transform="rotate({angle} 32 32)"><path d="M6,32 L18,20 L18,27 L46,27 L46,20 L58,32 L46,44 L46,37 L18,37 L18,44 Z" '
               f'fill="{FILL}" stroke="{CYAN}" stroke-width="3" stroke-linejoin="round"/></g>')


HAND = (f'<rect x="26" y="8" width="11" height="30" rx="5.5" fill="{FILL}" stroke="{CYAN}" stroke-width="3"/>'
        f'<rect x="14" y="30" width="36" height="26" rx="11" fill="{FILL}" stroke="{CYAN}" stroke-width="3"/>'
        f'<circle cx="31.5" cy="14" r="2.5" fill="{AMBER}"/>')
FIST = (f'<rect x="12" y="24" width="40" height="30" rx="12" fill="{FILL}" stroke="{CYAN}" stroke-width="3"/>'
        f'<path d="M22,26 v-6 M32,26 v-8 M42,26 v-6" stroke="{CYAN}" stroke-width="3" stroke-linecap="round"/>')

# name -> (hotspot in base pixels, [frames as svg strings], delay ms for animated ones)
SHAPES = {
    "default": ((8, 4), [arrow()], 0),
    "pointer": ((31, 8), [svg(HAND)], 0),
    "text": ((32, 32), [svg(f'<path d="M24,8 h16 M24,56 h16 M32,8 V56" fill="none" stroke="{CYAN}" stroke-width="4" stroke-linecap="round"/>'
                           f'<circle cx="32" cy="32" r="2.4" fill="{AMBER}"/>')], 0),
    "wait": ((32, 32), [svg(ring(a)) for a in range(0, 360, 30)], 80),
    "progress": ((8, 4), [arrow(ring(a, True)) for a in range(0, 360, 30)], 80),
    "not-allowed": ((32, 32), [svg(f'<circle cx="32" cy="32" r="20" fill="{FILL}" stroke="{RED}" stroke-width="6"/>'
                                   f'<line x1="18" y1="46" x2="46" y2="18" stroke="{RED}" stroke-width="6" stroke-linecap="round"/>')], 0),
    "help": ((8, 4), [arrow(f'<circle cx="48" cy="18" r="11" fill="{FILL}" stroke="{AMBER}" stroke-width="3"/>'
                            f'<text x="48" y="24" text-anchor="middle" font-family="DejaVu Sans, sans-serif" font-weight="bold" font-size="17" fill="{AMBER}">?</text>')], 0),
    "move": ((32, 32), [svg(f'<path d="M32,4 L42,16 L35,16 L35,29 L48,29 L48,22 L60,32 L48,42 L48,35 L35,35 L35,48 L42,48 L32,60 L22,48 L29,48 L29,35 L16,35 L16,42 L4,32 L16,22 L16,29 L29,29 L29,16 L22,16 Z" '
                            f'fill="{FILL}" stroke="{AMBER}" stroke-width="3" stroke-linejoin="round"/>')], 0),
    "ew-resize": ((32, 32), [double_arrow(0)], 0),
    "ns-resize": ((32, 32), [double_arrow(90)], 0),
    "nwse-resize": ((32, 32), [double_arrow(45)], 0),
    "nesw-resize": ((32, 32), [double_arrow(-45)], 0),
    "crosshair": ((32, 32), [svg(f'<path d="M32,6 V26 M32,38 V58 M6,32 H26 M38,32 H58" stroke="{CYAN}" stroke-width="4" stroke-linecap="round"/>'
                                 f'<circle cx="32" cy="32" r="3" fill="{AMBER}"/>')], 0),
    "grab": ((32, 30), [svg(HAND)], 0),
    "grabbing": ((32, 30), [svg(FIST)], 0),
}

ALIASES = {
    "default": ["left_ptr", "arrow", "top_left_arrow"],
    "pointer": ["hand1", "hand2", "pointing_hand", "openhand"],
    "text": ["xterm", "ibeam"],
    "wait": ["watch"],
    "progress": ["left_ptr_watch", "half-busy"],
    "not-allowed": ["crossed_circle", "forbidden", "no-drop", "dnd-none"],
    "help": ["question_arrow", "whats_this"],
    "move": ["all-scroll", "fleur", "size_all"],
    "ew-resize": ["sb_h_double_arrow", "h_double_arrow", "col-resize", "size_hor", "e-resize", "w-resize"],
    "ns-resize": ["sb_v_double_arrow", "v_double_arrow", "row-resize", "size_ver", "n-resize", "s-resize"],
    "nwse-resize": ["size_fdiag", "nw-resize", "se-resize"],
    "nesw-resize": ["size_bdiag", "ne-resize", "sw-resize"],
    "crosshair": ["cross", "tcross"],
    "grab": [],
    "grabbing": ["closedhand", "dnd-move", "dnd-copy"],
}


def render(svg_text, px):
    """SVG -> premultiplied ARGB32 little-endian pixels at px x px."""
    png = subprocess.run(["rsvg-convert", "-w", str(px), "-h", str(px)], input=svg_text.encode(),
                         capture_output=True, check=True).stdout
    raw = subprocess.run(["magick", "png:-", "-depth", "8", "rgba:-"], input=png,
                         capture_output=True, check=True).stdout
    out = bytearray()
    for i in range(0, len(raw), 4):
        r, g, b, a = raw[i:i + 4]
        out += bytes((b * a // 255, g * a // 255, r * a // 255, a))
    return bytes(out)


def xcursor(hot, frames, delay):
    chunks = []
    for frame in frames:
        for px in SIZES:
            scale = px / BASE
            pixels = render(frame, px)
            head = struct.pack("<9I", 36, 0xFFFD0002, px, 1, px, px,
                               int(hot[0] * scale), int(hot[1] * scale), delay)
            chunks.append((px, head + pixels))
    ntoc = len(chunks)
    offset = 16 + 12 * ntoc
    toc, body = b"", b""
    for px, chunk in chunks:
        toc += struct.pack("<3I", 0xFFFD0002, px, offset + len(body))
        body += chunk
    return b"Xcur" + struct.pack("<3I", 16, 0x10000, ntoc) + toc + body


def main():
    check = "--check" in sys.argv
    for name, (_, frames, _) in SHAPES.items():
        for f in frames:
            xml.dom.minidom.parseString(f)
    if check:
        print(f"checked {len(SHAPES)} cursors"); return
    cdir = os.path.join(THEME, "cursors")
    os.makedirs(cdir, exist_ok=True)
    for name, (hot, frames, delay) in SHAPES.items():
        with open(os.path.join(cdir, name), "wb") as fh:
            fh.write(xcursor(hot, frames, delay))
        for alias in ALIASES.get(name, []):
            link = os.path.join(cdir, alias)
            if os.path.lexists(link): os.remove(link)
            os.symlink(name, link)
    with open(os.path.join(THEME, "index.theme"), "w") as fh:
        fh.write("[Icon Theme]\nName=Axiom Cursors\nComment=Axiom glass cursors\nInherits=Adwaita\n")
    print(f"wrote {len(SHAPES)} cursors")


if __name__ == "__main__":
    main()
