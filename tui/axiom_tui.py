"""Shared console UI for the Axiom installer and login screen (Phase 6). Python stdlib only.

Targets the Linux virtual console: 16 colours (the palette is redefined to the Axiom colours),
the kernel font latarcyrheb-sun32 (16x32 cells, has half blocks and shades) and curses. Colours used
as cell backgrounds stay in slots 0-7 because the console has no bright backgrounds.
"""
import curses
import locale
import os
import subprocess
import sys
import textwrap
import time

sys.path.insert(0, os.path.dirname(os.path.realpath(__file__)))
import penguin_art  # noqa: E402

# Slots 0-7 are the pixel/background colours; 8-15 are brighter text variants (bold maps there).
# Bold turns slot n into slot n+8, so each bright slot is the brighter twin of the one below it.
PALETTE = ["070B0D", "FF5C5C", "3DDC97", "FF9418", "2A3A40", "EDF5F5", "20D6D2", "9FB4B7",
           "4E5E62", "FF8A8A", "7CF0BE", "FFB348", "5F7A82", "FFFFFF", "37F0EA", "EDF5F5"]
BG, RED, GREEN, ORANGE, GHOST, WHITE, CYAN, TEXT = range(8)
FONT = "latarcyrheb-sun32"
CLASS_COLOR = {"b": CYAN, "w": WHITE, "o": ORANGE, "k": GHOST}  # dark slate, the reference body (a background-safe slot)
LOGO = ["  ▄▄▄  ▄▄ ▄▄ ▄▄ ▄▄▄  ▄▄   ▄▄",
        " ██▀██ ▀█▄█▀ ██ ██▀██ ███▄███",
        " ██▀██ ▄█▀█▄ ██ ██▄██ ██ ▀ ██"]


# ---- console setup ------------------------------------------------------------------------------
def fb_size():
    """(width, height) of the framebuffer, or (0, 0) while it does not exist yet."""
    try:
        w, h = open("/sys/class/graphics/fb0/virtual_size").read().split(",")
        return int(w), int(h)
    except (OSError, ValueError):
        return 0, 0


def fb_height():
    return fb_size()[1]


def wait_fb_height(timeout=10.0, step=0.25):
    """The framebuffer appears a moment after boot; at service start fb0 may not exist yet."""
    end = time.monotonic() + timeout
    while True:
        h = fb_height()
        if h or time.monotonic() >= end:
            return h
        time.sleep(step)


def font_applied(out):
    """True when the console is as many columns wide as the 16-pixel font gives on this screen."""
    w = fb_size()[0]
    try:
        return w > 0 and os.get_terminal_size(out.fileno()).columns == w // 16
    except (OSError, ValueError, AttributeError):
        return False


def apply_font(out, attempts=6):
    """Load the large font and make sure it stuck: the framebuffer console takes over from the early text
    console a moment after boot and starts with its own default font, so retry until the size matches."""
    for _ in range(attempts):
        subprocess.run(["setfont", FONT], stdin=out, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
        time.sleep(0.4)
        if font_applied(out):
            return True
        time.sleep(1.0)
    return False


_palette_set = False  # a preview in an ordinary terminal changed its palette and must reset it


def setup_console(out=None, bg=None, preview=False):
    """On a Linux VT: UTF-8 mode, Axiom palette (background slot 0 replaced by bg, if given) and
    (as root, on a big enough screen) the large font. preview=True also sets the palette in an
    ordinary terminal (OSC 4), so a preview shows the Axiom colours; restore_console undoes it."""
    global _palette_set
    out = out or sys.stdout
    palette = PALETTE if bg is None else [bg] + PALETTE[1:]
    if preview and os.environ.get("TERM") != "linux":
        out.write("".join(f"\033]4;{i};#{c}\033\\" for i, c in enumerate(palette)) + "\033[2J\033[H")
        out.flush()
        _palette_set = True
        return True
    if os.environ.get("TERM") != "linux":
        return False
    try:
        out.write("\033%G" + "".join(f"\033]P{i:X}{c}" for i, c in enumerate(palette)) + "\033[0m\033[2J\033[H")
        out.flush()
        if os.geteuid() == 0 and wait_fb_height() >= 700:
            apply_font(out)
            out.write("".join(f"\033]P{i:X}{c}" for i, c in enumerate(palette)) + "\033[2J\033[H")  # takeover may reset it
            out.flush()
    except OSError:
        return False
    return True


def restore_console(out=None):
    global _palette_set
    out = out or sys.stdout
    if os.environ.get("TERM") == "linux":
        out.write("\033]R\033[0m\033[2J\033[H")
        out.flush()
    elif _palette_set:
        out.write("\033]104\033\\\033[0m\033[2J\033[H")  # OSC 104: back to the terminal's own colours
        out.flush()
        _palette_set = False


# ---- pure helpers (unit-tested) -------------------------------------------------------------------
def wrap(text, width):
    lines = []
    for para in text.split("\n"):
        lines += textwrap.wrap(para, max(10, width)) or [""]
    return lines


def pick_penguin(rows_available):
    """Largest art whose half-block height fits, or None for the text-only layout."""
    for art in (penguin_art.LARGE, penguin_art.MEDIUM, penguin_art.SMALL):
        if len(art) // 2 <= rows_available:
            return art
    return None


def penguin_cells(art, fill):
    """Rows of (glyph, fg, bg, bold) cells. fill is 0..1, filled from the feet up; the leading edge glows."""
    h = len(art)
    filled = int(round(max(0.0, min(1.0, fill)) * h))
    out = []
    for r in range(0, h, 2):
        row = []
        for x in range(len(art[r])):
            px = []
            glow = False
            for y in (r, r + 1):
                c = art[y][x]
                if c == ".":
                    px.append(BG)
                    continue
                is_filled = (h - 1 - y) < filled
                # the unfilled body is background-dark, so the rising fill shows on it
                px.append(CLASS_COLOR[c] if is_filled else (BG if c == "k" else GHOST))
                glow = glow or (is_filled and (h - 1 - y) >= filled - 2 and filled < h)
            top, bot = px
            if top == bot:
                row.append((" ", BG, top, False))
            else:
                row.append(("▀", top, bot, glow))
        out.append(row)
    return out


BIG = {  # 5x5 pixel letters; '#' is one pixel, drawn as one block (two cells at scale 2: square pixels)
    "A": [" ### ", "#   #", "#####", "#   #", "#   #"],
    "X": ["#   #", " # # ", "  #  ", " # # ", "#   #"],
    "I": ["#####", "  #  ", "  #  ", "  #  ", "#####"],
    "O": [" ### ", "#   #", "#   #", "#   #", " ### "],
    "M": ["#   #", "## ##", "# # #", "#   #", "#   #"],
}


def big_rows(text, scale=2):
    """Block-letter banner rows for text (A-Z letters in BIG), letters separated by one pixel."""
    gap = " " * scale
    return [gap.join("".join("█" * scale if px == "#" else " " * scale for px in BIG[ch][r]) for ch in text)
            for r in range(5)]


def capslock_on():
    try:
        for name in os.listdir("/sys/class/leds"):
            if name.endswith("capslock"):
                return open(f"/sys/class/leds/{name}/brightness").read().strip() not in ("", "0")
    except OSError:
        pass
    return False


# ---- curses surface -------------------------------------------------------------------------------
class UI:
    def __init__(self, scr):
        try:
            locale.setlocale(locale.LC_ALL, "")
        except locale.Error:
            pass
        self.s = scr
        for call, arg in ((curses.curs_set, (0,)), (curses.use_default_colors, ())):
            try:
                call(*arg)
            except curses.error:
                pass
        self._pairs = {}
        self.s.keypad(True)

    def pair(self, fg, bg=BG):
        key = (fg, bg)
        if key not in self._pairs:
            curses.init_pair(len(self._pairs) + 1, fg, bg)
            self._pairs[key] = curses.color_pair(len(self._pairs) + 1)
        return self._pairs[key]

    # sizes
    @property
    def h(self):
        return self.s.getmaxyx()[0]

    @property
    def w(self):
        return self.s.getmaxyx()[1]

    def put(self, y, x, text, fg=TEXT, bg=BG, bold=False):
        bold = bold and fg != BG  # bold dark text would turn grey
        if 0 <= y < self.h and 0 <= x < self.w:
            try:
                self.s.addnstr(y, x, text, max(0, self.w - x - 1), self.pair(fg, bg) | (curses.A_BOLD if bold else 0))
            except curses.error:
                pass

    def center(self, y, text, **kw):
        self.put(y, max(0, (self.w - len(text)) // 2), text, **kw)

    def box(self, y, x, h, w, fg=GHOST):
        a = self.pair(fg)
        for i in range(1, w - 1):
            self._ch(y, x + i, curses.ACS_HLINE, a)
            self._ch(y + h - 1, x + i, curses.ACS_HLINE, a)
        for j in range(1, h - 1):
            self._ch(y + j, x, curses.ACS_VLINE, a)
            self._ch(y + j, x + w - 1, curses.ACS_VLINE, a)
        for (yy, xx, c) in ((y, x, curses.ACS_ULCORNER), (y, x + w - 1, curses.ACS_URCORNER),
                            (y + h - 1, x, curses.ACS_LLCORNER), (y + h - 1, x + w - 1, curses.ACS_LRCORNER)):
            self._ch(yy, xx, c, a)

    def _ch(self, y, x, ch, attr):
        if 0 <= y < self.h and 0 <= x < self.w - 1:
            try:
                self.s.addch(y, x, ch, attr)
            except curses.error:
                pass

    def draw_penguin(self, top, art, fill):
        rows = penguin_cells(art, fill)
        x0 = max(0, (self.w - len(art[0])) // 2)
        for j, row in enumerate(rows):
            for i, (g, fg, bg, bold) in enumerate(row):
                if g == " " and bg == BG:
                    continue
                if 0 <= top + j < self.h and 0 <= x0 + i < self.w - 1:
                    try:
                        self.s.addstr(top + j, x0 + i, g, self.pair(fg, bg) | (curses.A_BOLD if bold else 0))
                    except curses.error:
                        pass
        return len(rows)

    def wordmark(self, y=0):
        """Banner: block wordmark when there is room, text otherwise. Returns rows used."""
        if self.h >= 26:
            for i, line in enumerate(LOGO):
                self.center(y + i, line, fg=CYAN, bold=True)
            return 4
        self.center(y, "A X I O M", fg=CYAN, bold=True)
        return 2

    def steps(self, y, current, total):
        """Step indicator: filled and empty blocks plus 'Step n of m'."""
        seg = "▄▄▄▄"
        width = total * 5 - 1
        x = max(0, (self.w - width) // 2)
        for i in range(total):
            self.put(y, x + i * 5, seg, fg=CYAN if i < current else GHOST)
        self.center(y + 1, f"Step {current} of {total}", fg=TEXT)
        return 3

    def footer(self, text):
        self.center(self.h - 1, text, fg=TEXT)

    def card_geometry(self, rows_needed, top):
        w = min(self.w - 6, 76)
        x = (self.w - w) // 2
        h = min(rows_needed, self.h - top - 2)
        return x, w, h
