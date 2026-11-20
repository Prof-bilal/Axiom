#!/usr/bin/env python3
"""Generate the Axiom application icon suite (glass squircle tiles).

    python3 scripts/gen-icons.py            # write SVG + 256 px PNG into the ISO profile
    python3 scripts/gen-icons.py --check    # only verify every glyph is well-formed XML

Each icon is a dark-teal squircle with a cyan-to-amber glass edge and a glyph in
the Axiom palette (cyan = focus, amber = accent). Output goes to
iso/phase3/airootfs/usr/share/icons/hicolor/{scalable,256x256}/apps/. PNGs are
rendered with rsvg-convert. Deterministic: same input, same files.
"""
import math, os, subprocess, sys
import xml.dom.minidom

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "iso/phase3/airootfs/usr/share/icons/hicolor")

CYAN, CYAN2, AMBER, ORANGE, PAPER, INK = "#37F0EA", "#20D6D2", "#FFB348", "#FF9418", "#E8F4F4", "#08151A"


def gear(cx, cy, r_out, r_in, teeth, hole, fill):
    """A gear: a toothed outline with a round hole (even-odd fill)."""
    pts = []
    step = 2 * math.pi / teeth
    for i in range(teeth):
        a = i * step
        for da, r in ((-0.30, r_in), (-0.16, r_out), (0.16, r_out), (0.30, r_in)):
            pts.append((cx + r * math.cos(a + da * step * 2), cy + r * math.sin(a + da * step * 2)))
    d = "M" + " L".join(f"{x:.1f},{y:.1f}" for x, y in pts) + " Z "
    d += f"M{cx + hole:.1f},{cy:.1f} A{hole},{hole} 0 1 0 {cx - hole:.1f},{cy:.1f} A{hole},{hole} 0 1 0 {cx + hole:.1f},{cy:.1f} Z"
    return f'<path d="{d}" fill="{fill}" fill-rule="evenodd"/>'


GLYPHS = {
    "files": f"""
      <rect x="58" y="94" width="140" height="96" rx="14" fill="{CYAN2}" opacity=".55"/>
      <path d="M58 108 a14 14 0 0 1 14 -14 h34 l12 14 z" fill="{CYAN2}" opacity=".8"/>
      <rect x="76" y="76" width="104" height="74" rx="8" fill="{PAPER}" opacity=".92"/>
      <rect x="58" y="112" width="140" height="80" rx="14" fill="{CYAN}" opacity=".95"/>
      <circle cx="182" cy="178" r="17" fill="{AMBER}"/><circle cx="182" cy="178" r="6" fill="{INK}"/>""",
    "terminal": f"""
      <rect x="50" y="62" width="156" height="114" rx="16" fill="{INK}" fill-opacity=".85" stroke="{CYAN}" stroke-width="8"/>
      <polyline points="80,104 106,124 80,144" fill="none" stroke="{AMBER}" stroke-width="9" stroke-linecap="round" stroke-linejoin="round"/>
      <line x1="120" y1="146" x2="152" y2="146" stroke="{CYAN}" stroke-width="9" stroke-linecap="round"/>
      <rect x="102" y="188" width="52" height="10" rx="5" fill="{CYAN}" opacity=".6"/>""",
    "browser": f"""
      <circle cx="128" cy="128" r="54" fill="{INK}" fill-opacity=".5" stroke="{CYAN}" stroke-width="8"/>
      <ellipse cx="128" cy="128" rx="24" ry="54" fill="none" stroke="{CYAN}" stroke-width="6"/>
      <line x1="76" y1="128" x2="180" y2="128" stroke="{CYAN}" stroke-width="6"/>
      <ellipse cx="128" cy="128" rx="88" ry="26" fill="none" stroke="{AMBER}" stroke-width="7" transform="rotate(-22 128 128)"/>""",
    "settings": gear(110, 116, 50, 40, 8, 16, CYAN) + gear(172, 172, 30, 24, 6, 10, AMBER),
    "sysmon": f"""
      <polyline points="48,128 90,128 108,82 134,174 152,108 166,128 208,128" fill="none" stroke="{CYAN}" stroke-width="9" stroke-linecap="round" stroke-linejoin="round"/>
      <rect x="56" y="170" width="30" height="24" rx="5" fill="{AMBER}" opacity=".85"/>
      <rect x="170" y="62" width="30" height="24" rx="5" fill="{AMBER}" opacity=".85"/>""",
    "trash": f"""
      <rect x="108" y="58" width="40" height="14" rx="6" fill="{CYAN}"/>
      <rect x="68" y="72" width="120" height="14" rx="6" fill="{CYAN}"/>
      <path d="M80 94 h96 l-8 104 h-80 z" fill="{CYAN}" fill-opacity=".22" stroke="{CYAN}" stroke-width="7" stroke-linejoin="round"/>
      <line x1="110" y1="112" x2="113" y2="180" stroke="{AMBER}" stroke-width="6" stroke-linecap="round"/>
      <line x1="128" y1="112" x2="128" y2="180" stroke="{AMBER}" stroke-width="6" stroke-linecap="round"/>
      <line x1="146" y1="112" x2="143" y2="180" stroke="{AMBER}" stroke-width="6" stroke-linecap="round"/>""",
    "software": f"""
      <path d="M102 100 C102 62 154 62 154 100" fill="none" stroke="{CYAN}" stroke-width="9" stroke-linecap="round"/>
      <rect x="66" y="96" width="124" height="108" rx="18" fill="{CYAN}" opacity=".92"/>
      <polyline points="108,180 128,124 148,180" fill="none" stroke="{AMBER}" stroke-width="10" stroke-linecap="round" stroke-linejoin="round"/>
      <line x1="116" y1="160" x2="140" y2="160" stroke="{AMBER}" stroke-width="9" stroke-linecap="round"/>""",
    "appinstaller": f"""
      <path d="M70 150 v34 h116 v-34" fill="none" stroke="{CYAN}" stroke-width="10" stroke-linecap="round" stroke-linejoin="round"/>
      <line x1="128" y1="62" x2="128" y2="148" stroke="{AMBER}" stroke-width="12" stroke-linecap="round"/>
      <polyline points="94,116 128,150 162,116" fill="none" stroke="{AMBER}" stroke-width="12" stroke-linecap="round" stroke-linejoin="round"/>""",
    "hub": f"""
      <rect x="62" y="62" width="58" height="58" rx="15" fill="{CYAN}" opacity=".95"/>
      <rect x="136" y="62" width="58" height="58" rx="15" fill="{AMBER}" opacity=".95"/>
      <rect x="62" y="136" width="58" height="58" rx="15" fill="{AMBER}" opacity=".95"/>
      <rect x="136" y="136" width="58" height="58" rx="15" fill="{CYAN}" opacity=".95"/>""",
    "notifications": f"""
      <path d="M82 176 C96 154 96 124 106 102 C112 88 144 88 150 102 C160 124 160 154 174 176 Z" fill="{CYAN}" opacity=".95" transform="translate(-2 0)"/>
      <circle cx="126" cy="80" r="8" fill="{CYAN}"/>
      <circle cx="126" cy="192" r="13" fill="{AMBER}"/>""",
    "power": f"""
      <path d="M92 88 A58 58 0 1 0 164 88" fill="none" stroke="{CYAN}" stroke-width="12" stroke-linecap="round"/>
      <line x1="128" y1="62" x2="128" y2="128" stroke="{AMBER}" stroke-width="12" stroke-linecap="round"/>""",
    "media": f"""
      <rect x="58" y="58" width="140" height="140" rx="32" fill="none" stroke="{CYAN}" stroke-width="7" opacity=".7"/>
      <polygon points="106,88 184,128 106,168" fill="{AMBER}" stroke="{AMBER}" stroke-width="8" stroke-linejoin="round"/>
      <path d="M82 112 q-10 16 0 32 M70 100 q-20 28 0 56" fill="none" stroke="{CYAN}" stroke-width="6" stroke-linecap="round"/>""",
    "calculator": f"""
      <rect x="64" y="60" width="128" height="42" rx="10" fill="{INK}" fill-opacity=".9" stroke="{CYAN}" stroke-width="4"/>
      <rect x="150" y="72" width="30" height="18" rx="3" fill="{AMBER}" opacity=".9"/>
      <g fill="{CYAN}" opacity=".92">
        <rect x="64" y="114" width="36" height="28" rx="8"/><rect x="110" y="114" width="36" height="28" rx="8"/>
        <rect x="64" y="152" width="36" height="28" rx="8"/><rect x="110" y="152" width="36" height="28" rx="8"/>
        <rect x="64" y="190" width="36" height="22" rx="8"/><rect x="110" y="190" width="36" height="22" rx="8"/>
      </g>
      <rect x="156" y="114" width="36" height="28" rx="8" fill="{AMBER}"/>
      <rect x="156" y="152" width="36" height="60" rx="8" fill="{AMBER}"/>""",
    "calendar": f"""
      <rect x="62" y="68" width="132" height="130" rx="18" fill="{PAPER}" opacity=".93"/>
      <path d="M62 86 a18 18 0 0 1 18 -18 h96 a18 18 0 0 1 18 18 v22 h-132 z" fill="{CYAN}"/>
      <line x1="94" y1="56" x2="94" y2="80" stroke="{INK}" stroke-width="9" stroke-linecap="round"/>
      <line x1="162" y1="56" x2="162" y2="80" stroke="{INK}" stroke-width="9" stroke-linecap="round"/>
      <text x="128" y="174" text-anchor="middle" font-family="DejaVu Sans, sans-serif" font-weight="bold" font-size="50" fill="{ORANGE}">14</text>""",
    "documents": f"""
      <rect x="74" y="56" width="100" height="132" rx="12" fill="{PAPER}" opacity=".93"/>
      <line x1="92" y1="84" x2="156" y2="84" stroke="{CYAN2}" stroke-width="7" stroke-linecap="round"/>
      <line x1="92" y1="106" x2="156" y2="106" stroke="{CYAN2}" stroke-width="7" stroke-linecap="round"/>
      <line x1="92" y1="128" x2="132" y2="128" stroke="{CYAN2}" stroke-width="7" stroke-linecap="round"/>
      <circle cx="158" cy="160" r="26" fill="{INK}" fill-opacity=".55" stroke="{AMBER}" stroke-width="9"/>
      <line x1="178" y1="180" x2="202" y2="204" stroke="{AMBER}" stroke-width="11" stroke-linecap="round"/>""",
}


# Dark, neutral tile used by the terminal (matches the reference: near-black
# squircle with a recessed screen and a light chevron, no accent colour).
DARK_TILE = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#2b2b2d"/><stop offset="1" stop-color="#121213"/></linearGradient>
    <linearGradient id="slot" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#1f1f21"/><stop offset="1" stop-color="#0c0c0d"/></linearGradient>
  </defs>
  <rect x="14" y="14" width="228" height="228" rx="60" fill="url(#bg)" stroke="#3a3a3d" stroke-width="3"/>
  <rect x="46" y="62" width="164" height="132" rx="34" fill="url(#slot)" stroke="#34343a" stroke-width="2"/>
  <polyline points="92,104 124,128 92,152" fill="none" stroke="#c9ccd1" stroke-width="13" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
"""

DARK_ICONS = {"terminal"}

# Trash: a grey metal bin with paper poking out, on the dark tile (reference icon).
TRASH_SVG = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#2b2b2d"/><stop offset="1" stop-color="#121213"/></linearGradient>
    <linearGradient id="bin" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stop-color="#8e949b"/><stop offset="0.5" stop-color="#c9ced4"/><stop offset="1" stop-color="#7d838a"/></linearGradient>
  </defs>
  <rect x="14" y="14" width="228" height="228" rx="60" fill="url(#bg)" stroke="#3a3a3d" stroke-width="3"/>
  <path d="M74 112 L96 58 L160 58 L182 112 Z" fill="#e9e4da"/>
  <path d="M92 74 L104 112 M118 70 L122 112 M146 74 L140 112" stroke="#b9b2a6" stroke-width="3"/>
  <rect x="62" y="100" width="132" height="22" rx="8" fill="url(#bin)"/>
  <path d="M74 122 L84 214 Q86 222 96 222 L160 222 Q170 222 172 214 L182 122 Z" fill="url(#bin)"/>
  <path d="M104 136 L108 208 M128 136 L128 208 M152 136 L148 208" stroke="#6e747b" stroke-width="5" stroke-linecap="round"/>
</svg>
"""

# Files: a teal folder with a light sheet behind and a dark penguin face.
FILES_SVG = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">
  <defs>
    <linearGradient id="body" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#22b193"/><stop offset="1" stop-color="#17937a"/></linearGradient>
  </defs>
  <rect x="14" y="14" width="228" height="228" rx="60" fill="#1f2a2b"/>
  <path d="M40 62 Q40 48 54 48 L100 48 Q108 48 112 56 L120 66 L202 66 Q216 66 216 80 L216 92 L40 92 Z" fill="#127a66"/>
  <rect x="48" y="84" width="160" height="34" rx="6" fill="#dfe5e6"/>
  <rect x="34" y="104" width="188" height="114" rx="14" fill="url(#body)"/>
  <g fill="#0b4a3f">
    <ellipse cx="128" cy="146" rx="34" ry="38"/>
    <path d="M94 140 Q96 176 128 186 Q160 176 162 140 Q160 108 128 104 Q96 108 94 140 Z"/>
    <ellipse cx="128" cy="162" rx="30" ry="22"/>
  </g>
  <ellipse cx="116" cy="136" rx="6" ry="7" fill="#e9f5f1"/>
  <ellipse cx="140" cy="136" rx="6" ry="7" fill="#e9f5f1"/>
  <circle cx="117" cy="137" r="2.5" fill="#0b4a3f"/>
  <circle cx="141" cy="137" r="2.5" fill="#0b4a3f"/>
  <path d="M116 150 Q128 158 140 150 L134 158 Q128 162 122 158 Z" fill="#f2b33d"/>
</svg>
"""
TERMINAL_SVG = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">
  <polyline points="72,84 118,128 72,172" fill="none" stroke="#d4d8dd" stroke-width="18" stroke-linecap="round" stroke-linejoin="round"/>
  <rect x="134" y="160" width="60" height="16" rx="8" fill="#d4d8dd"/>
</svg>
"""
CUSTOM_SVG = {"trash": TRASH_SVG, "files": FILES_SVG}

# Glyph-only icons, like Firefox and VS Code: the squircle background, its
# sheen and edge are removed; the glyph (and the terminal's recessed screen) stays.
import re
BG_RECTS = re.compile(r'<rect x="(?:14|16|17\.5)"[^>]*?(?:rx="(?:58|56\.5|60)"|height="112")[^>]*/>\s*')


def flat(svg):
    return BG_RECTS.sub("", svg)


def tile(glyph):
    return f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#25454c"/><stop offset="1" stop-color="#0b1619"/></linearGradient>
    <linearGradient id="edge" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="{CYAN}"/><stop offset="1" stop-color="{AMBER}"/></linearGradient>
    <linearGradient id="sheen" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#fff" stop-opacity=".16"/><stop offset="1" stop-color="#fff" stop-opacity="0"/></linearGradient>
    <clipPath id="clip"><rect x="16" y="16" width="224" height="224" rx="58"/></clipPath>
  </defs>
  <rect x="16" y="16" width="224" height="224" rx="58" fill="url(#bg)"/>
  <rect x="16" y="16" width="224" height="112" fill="url(#sheen)" clip-path="url(#clip)"/>
  <rect x="17.5" y="17.5" width="221" height="221" rx="56.5" fill="none" stroke="url(#edge)" stroke-width="3" opacity=".85"/>
  <g>{glyph}</g>
</svg>
"""


def main():
    check = "--check" in sys.argv
    for name, glyph in GLYPHS.items():
        if name in DARK_ICONS:
            svg = DARK_TILE  # terminal keeps its dark tile (reference look)
        else:
            svg = flat(CUSTOM_SVG.get(name) or tile(glyph))
        xml.dom.minidom.parseString(svg)  # raises on malformed XML
        if check:
            continue
        sdir, pdir = os.path.join(OUT, "scalable/apps"), os.path.join(OUT, "256x256/apps")
        os.makedirs(sdir, exist_ok=True); os.makedirs(pdir, exist_ok=True)
        svg_path = os.path.join(sdir, f"axiom-{name}.svg")
        with open(svg_path, "w") as fh:
            fh.write(svg)
        subprocess.run(["rsvg-convert", "-w", "256", "-h", "256", svg_path, "-o",
                        os.path.join(pdir, f"axiom-{name}.png")], check=True)
    print(("checked " if check else "wrote ") + f"{len(GLYPHS)} icons")


if __name__ == "__main__":
    main()
