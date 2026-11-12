#!/usr/bin/env python3
"""Generate tui/penguin_image.bin: the mascot (branding/identity/axiom-penguin.png) at the pixel sizes the
framebuffer renderer shows it (ADR-027).

    python3 scripts/gen-penguin-image.py

Sides are 32 pixels per cell row of the three pixel-art sizes (20, 14 and 8 rows), so the image takes the
same space as the pixel-art face it replaces. File format: b"AXPI", u32 count, then per image
u32 side, u32 compressed length, zlib(RGBA bytes). Needs Pillow (dev-time only, not on the ISO).
"""
import os
import struct
import zlib
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "branding/identity/axiom-penguin.png")
SIDES = (640, 448, 256)
MARGIN = 0.03  # transparent border, as a fraction of the side


def image(src, side):
    box = src.getchannel("A").point(lambda a: 255 if a > 8 else 0).getbbox()
    pic = src.crop(box)
    inner = int(side * (1 - 2 * MARGIN))
    pic.thumbnail((inner, inner), Image.LANCZOS)
    canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    canvas.paste(pic, ((side - pic.width) // 2, side - pic.height - int(side * MARGIN)))  # feet on the bottom
    return canvas


def main():
    src = Image.open(SRC).convert("RGBA")
    out = bytearray(b"AXPI" + struct.pack("<I", len(SIDES)))
    for side in SIDES:
        blob = zlib.compress(image(src, side).tobytes(), 9)
        out += struct.pack("<II", side, len(blob)) + blob
    path = os.path.join(ROOT, "tui/penguin_image.bin")
    with open(path, "wb") as fh:
        fh.write(out)
    print("wrote", path, len(out), "bytes")


if __name__ == "__main__":
    main()
