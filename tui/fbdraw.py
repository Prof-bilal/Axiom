"""Framebuffer renderer for the Axiom installer and login (ADR-027). Python stdlib only.

FbScreen implements the small curses surface that axiom_tui.UI uses (erase, addnstr, addstr, refresh,
getch, timeout, getmaxyx), so every screen keeps its layout and only the drawing changes: each text
cell is drawn as 16x32 pixels from the console font, half blocks as exact pixel halves.
Output goes to /dev/fb0 on a real console, or to PNG files for previews (AXIOM_FB_PNG=<dir>).
"""
import ctypes
import curses
import errno
import fcntl
import glob
import gzip
import mmap
import os
import select
import signal
import struct
import sys
import termios
import time
import tty
import zlib

FONT_NAME = "latarcyrheb-sun32.psfu.gz"
FONT_DIRS = ("/usr/share/kbd/consolefonts", "/usr/lib/kbd/consolefonts", "/usr/share/consolefonts")
KDSETMODE, KD_TEXT, KD_GRAPHICS = 0x4B3A, 0, 1
HALF = {"▀": (1, 0), "▄": (0, 1), "█": (1, 1)}  # glyph -> (top is fg, bottom is fg)
KEYNAMES = {"enter": 10, "esc": 27, "tab": 9, "space": 32, "backspace": 127, "up": curses.KEY_UP,
            "down": curses.KEY_DOWN, "left": curses.KEY_LEFT, "right": curses.KEY_RIGHT,
            **{f"f{n}": curses.KEY_F0 + n for n in range(1, 13)}}


class Unsupported(Exception):
    """The framebuffer cannot be used; the caller falls back to curses."""


LOG_PATH = "/run/axiom-ui.log"
TEXT_DIR = "/run"  # the only directory the text-mirror hook may write to (root writes it)


def log(message):
    """One line on stderr and in /run/axiom-ui.log, so a fallback or a hidden error leaves a trace."""
    line = f"axiom-ui: {message}"
    print(line, file=sys.stderr)
    try:
        with open(LOG_PATH, "a") as fh:
            fh.write(line + "\n")
    except OSError:
        pass  # not allowed to write /run (unprivileged greeter): stderr still has it


# ---- font ---------------------------------------------------------------------------------------
class Font:
    def __init__(self, data):
        if data[:4] != b"\x72\xb5\x4a\x86":
            raise Unsupported("not a PSF2 font")
        _, hsize, flags, length, charsize, self.h, self.w = struct.unpack("<7I", data[4:32])
        self.bpr = (self.w + 7) // 8
        self.glyphs = [data[hsize + i * charsize: hsize + (i + 1) * charsize] for i in range(length)]
        self.index = {}
        if flags & 1:  # unicode table: UTF-8 codepoints per glyph, 0xFF ends the glyph, 0xFE starts sequences
            pos = hsize + length * charsize
            for i in range(length):
                end = data.index(b"\xff", pos)
                head = data[pos:end].split(b"\xfe")[0]
                for ch in head.decode("utf-8", "ignore"):
                    self.index.setdefault(ch, i)
                pos = end + 1
        else:
            self.index = {chr(i): i for i in range(min(256, length))}

    def rows(self, ch):
        """Bit rows (one int per pixel row, MSB = left) for ch; unknown characters draw as '?'."""
        g = self.glyphs[self.index.get(ch, self.index.get("?", 0))]
        return [int.from_bytes(g[r * self.bpr:(r + 1) * self.bpr], "big") >> (self.bpr * 8 - self.w)
                for r in range(self.h)]


def load_font(path=None):
    paths = [path] if path else [os.path.join(d, FONT_NAME) for d in FONT_DIRS]
    for p in paths:
        if p and os.path.exists(p):
            with open(p, "rb") as fh:
                data = fh.read()
            return Font(gzip.decompress(data) if data[:2] == b"\x1f\x8b" else data)
    raise Unsupported("console font not found")


# ---- mascot image -------------------------------------------------------------------------------
IMAGE_FILE = os.path.join(os.path.dirname(os.path.realpath(__file__)), "penguin_image.bin")
DIM = 0.2  # how much of the colour the not-yet-filled part of the mascot keeps


def load_images(path=IMAGE_FILE):
    """{side: RGBA bytes} from penguin_image.bin (scripts/gen-penguin-image.py); empty when it is missing."""
    try:
        with open(path, "rb") as fh:
            data = fh.read()
        if data[:4] != b"AXPI":
            return {}
        count, pos, images = struct.unpack("<I", data[4:8])[0], 8, {}
        for _ in range(count):
            side, size = struct.unpack("<II", data[pos:pos + 8])
            images[side] = zlib.decompress(data[pos + 8:pos + 8 + size])
            pos += 8 + size
        return images
    except (OSError, struct.error, zlib.error):
        return {}


def blend_rows(rgba, side, bg, strength):
    """Pixel rows (BGRA bytes) of the image over the background colour bg=(b, g, r), colour scaled by strength."""
    rows = []
    for y in range(side):
        row = bytearray()
        line = rgba[y * side * 4:(y + 1) * side * 4]
        for x in range(0, side * 4, 4):
            a = line[x + 3] / 255 * strength
            row += bytes((int(bg[0] + (line[x + 2] - bg[0]) * a), int(bg[1] + (line[x + 1] - bg[1]) * a),
                          int(bg[2] + (line[x] - bg[2]) * a), 255))
        rows.append(bytes(row))
    return rows


# ---- sinks --------------------------------------------------------------------------------------
def png_bytes(w, h, bgra):
    rgb = bytearray(w * h * 3)
    rgb[0::3], rgb[1::3], rgb[2::3] = bgra[2::4], bgra[1::4], bgra[0::4]
    raw = b"".join(b"\0" + bytes(rgb[y * w * 3:(y + 1) * w * 3]) for y in range(h))

    def chunk(tag, body):
        return struct.pack(">I", len(body)) + tag + body + struct.pack(">I", zlib.crc32(tag + body) & 0xFFFFFFFF)
    return (b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0))
            + chunk(b"IDAT", zlib.compress(raw, 1)) + chunk(b"IEND", b""))


class PngSink:
    """Preview output: the newest frame is <dir>/latest.png; snapshot() keeps numbered copies."""

    def __init__(self, directory, size=(1600, 900)):
        os.makedirs(directory, exist_ok=True)
        self.dir, self.w, self.h, self.n = directory, size[0], size[1], 0

    def size(self):
        return self.w, self.h

    def present(self, bgra, rows=None):
        self.last = bytes(bgra)
        with open(os.path.join(self.dir, "latest.png"), "wb") as fh:
            fh.write(png_bytes(self.w, self.h, bgra))

    def snapshot(self):
        self.n += 1
        with open(os.path.join(self.dir, f"frame-{self.n:03d}.png"), "wb") as fh:
            fh.write(png_bytes(self.w, self.h, self.last))

    def close(self):
        pass


def set_console_mode(mode):
    """KD_GRAPHICS stops the kernel's text console drawing over us; a no-op when stdin is not a VT."""
    try:
        fcntl.ioctl(0, KDSETMODE, mode)
    except OSError as e:
        if e.errno != errno.ENOTTY:  # ENOTTY just means this is not a virtual terminal
            log(f"console mode {mode} refused: {e}")


# DRM/KMS (what the text console itself sits on): a dumb buffer scanned out by a mode set. Writing to
# /dev/fb0 does not reach the screen on drivers such as bochs-drm, so this is the preferred backend.
def _ioc(nr, size):
    return (3 << 30) | (size << 16) | (0x64 << 8) | nr  # _IOWR('d', nr, struct)


class _Res(ctypes.Structure):
    _fields_ = [("fb_id_ptr", ctypes.c_uint64), ("crtc_id_ptr", ctypes.c_uint64),
                ("connector_id_ptr", ctypes.c_uint64), ("encoder_id_ptr", ctypes.c_uint64),
                *((n, ctypes.c_uint32) for n in ("count_fbs", "count_crtcs", "count_connectors", "count_encoders",
                                                 "min_width", "max_width", "min_height", "max_height"))]


class _Mode(ctypes.Structure):
    _fields_ = [("clock", ctypes.c_uint32),
                *((n, ctypes.c_uint16) for n in ("hdisplay", "hsync_start", "hsync_end", "htotal", "hskew",
                                                 "vdisplay", "vsync_start", "vsync_end", "vtotal", "vscan")),
                ("vrefresh", ctypes.c_uint32), ("flags", ctypes.c_uint32), ("type", ctypes.c_uint32),
                ("name", ctypes.c_char * 32)]


class _Conn(ctypes.Structure):
    _fields_ = [("encoders_ptr", ctypes.c_uint64), ("modes_ptr", ctypes.c_uint64), ("props_ptr", ctypes.c_uint64),
                ("prop_values_ptr", ctypes.c_uint64),
                *((n, ctypes.c_uint32) for n in ("count_modes", "count_props", "count_encoders", "encoder_id",
                                                 "connector_id", "connector_type", "connector_type_id", "connection",
                                                 "mm_width", "mm_height", "subpixel", "pad"))]


class _Enc(ctypes.Structure):
    _fields_ = [(n, ctypes.c_uint32) for n in ("encoder_id", "encoder_type", "crtc_id", "possible_crtcs",
                                               "possible_clones")]


class _Crtc(ctypes.Structure):
    _fields_ = [("set_connectors_ptr", ctypes.c_uint64),
                *((n, ctypes.c_uint32) for n in ("count_connectors", "crtc_id", "fb_id", "x", "y", "gamma_size",
                                                 "mode_valid")), ("mode", _Mode)]


class _Create(ctypes.Structure):
    _fields_ = [*((n, ctypes.c_uint32) for n in ("height", "width", "bpp", "flags", "handle", "pitch")),
                ("size", ctypes.c_uint64)]


class _Map(ctypes.Structure):
    _fields_ = [("handle", ctypes.c_uint32), ("pad", ctypes.c_uint32), ("offset", ctypes.c_uint64)]


class _Fb(ctypes.Structure):
    _fields_ = [(n, ctypes.c_uint32) for n in ("fb_id", "width", "height", "pitch", "bpp", "depth", "handle")]


class _Dirty(ctypes.Structure):
    _fields_ = [*((n, ctypes.c_uint32) for n in ("fb_id", "flags", "color", "num_clips")), ("clips_ptr", ctypes.c_uint64)]


IOCTL = {"res": _ioc(0xA0, ctypes.sizeof(_Res)), "setcrtc": _ioc(0xA2, ctypes.sizeof(_Crtc)),
         "enc": _ioc(0xA6, ctypes.sizeof(_Enc)), "conn": _ioc(0xA7, ctypes.sizeof(_Conn)),
         "addfb": _ioc(0xAE, ctypes.sizeof(_Fb)), "dirty": _ioc(0xB1, ctypes.sizeof(_Dirty)),
         "create": _ioc(0xB2, ctypes.sizeof(_Create)), "map": _ioc(0xB3, ctypes.sizeof(_Map)),
         "rmfb": _ioc(0xAF, 4), "destroy": _ioc(0xB4, 4), "set_master": 0x641E, "drop_master": 0x641F}
CONNECTED = 1


def _call(fd, name, struct):
    req = IOCTL[name]
    if req > 0x7FFFFFFF:  # fcntl takes a signed C int; the kernel only looks at the bits
        req -= 1 << 32
    fcntl.ioctl(fd, req, struct, True)  # the structure is the writable buffer the kernel fills in
    return struct


def _array(values_or_count):
    n = values_or_count if isinstance(values_or_count, int) else len(values_or_count)
    arr = (ctypes.c_uint32 * max(1, n))()
    if not isinstance(values_or_count, int):
        for i, v in enumerate(values_or_count):
            arr[i] = v
    return arr


class DrmSink:
    """A KMS dumb buffer scanned out on the first connected output, at its preferred mode."""

    def __init__(self, dev=None):
        self.fd = self.buf = self.fb_id = self.handle = None
        self.gfx = self.dirty_refused = False
        last = None
        for path in ([dev] if dev else sorted(glob.glob("/dev/dri/card*"))):
            try:
                self.path = path
                self._open()
                return
            except (OSError, Unsupported) as e:
                last = e
                self._close()
        raise Unsupported(f"no usable DRM device: {last}")

    def _open(self):
        fd = self.fd = os.open(self.path, os.O_RDWR | os.O_CLOEXEC)
        try:
            fcntl.ioctl(fd, IOCTL["set_master"])  # plain number, fits a signed int
        except OSError as e:
            log(f"drm set_master refused ({e}); the mode set below fails if another program owns the screen")
        res = _call(fd, "res", _Res())  # counts first
        crtcs, conns = _array(res.count_crtcs), _array(res.count_connectors)
        fbs, encs = _array(res.count_fbs), _array(res.count_encoders)
        res.crtc_id_ptr, res.connector_id_ptr = ctypes.addressof(crtcs), ctypes.addressof(conns)
        res.fb_id_ptr, res.encoder_id_ptr = ctypes.addressof(fbs), ctypes.addressof(encs)
        _call(fd, "res", res)
        for i in range(res.count_connectors):
            conn = _call(fd, "conn", _Conn(connector_id=conns[i]))
            if conn.connection != CONNECTED or not conn.count_modes:
                continue
            modes = (_Mode * conn.count_modes)()
            enc_ids = _array(conn.count_encoders)
            conn = _Conn(connector_id=conns[i], count_modes=conn.count_modes, modes_ptr=ctypes.addressof(modes),
                         count_encoders=conn.count_encoders, encoders_ptr=ctypes.addressof(enc_ids))
            conn = _call(fd, "conn", conn)
            enc = _call(fd, "enc", _Enc(encoder_id=conn.encoder_id or enc_ids[0]))
            crtc_id = enc.crtc_id or next((crtcs[k] for k in range(res.count_crtcs) if enc.possible_crtcs >> k & 1), 0)
            if crtc_id:
                self.mode, self.crtc_id, self.conn_id = modes[0], crtc_id, conns[i]
                break
        else:
            raise Unsupported("no connected output with a mode")
        self.w, self.h = self.mode.hdisplay, self.mode.vdisplay
        dumb = _call(fd, "create", _Create(width=self.w, height=self.h, bpp=32))
        self.handle, self.pitch, self.buf_size = dumb.handle, dumb.pitch, dumb.size
        self.fb_id = _call(fd, "addfb", _Fb(width=self.w, height=self.h, pitch=self.pitch, bpp=32, depth=24,
                                            handle=self.handle)).fb_id
        off = _call(fd, "map", _Map(handle=self.handle)).offset
        self.buf = mmap.mmap(fd, self.buf_size, mmap.MAP_SHARED, mmap.PROT_READ | mmap.PROT_WRITE, offset=off)
        connectors = _array([self.conn_id])
        _call(fd, "setcrtc", _Crtc(set_connectors_ptr=ctypes.addressof(connectors), count_connectors=1,
                                   crtc_id=self.crtc_id, fb_id=self.fb_id, mode_valid=1, mode=self.mode))

    def _close(self):
        """Closing the device lets the kernel put its own text console back on the screen."""
        if self.buf is not None:
            self.buf.close()
        if self.fd is not None:
            os.close(self.fd)
        self.fd = self.buf = self.fb_id = self.handle = None

    def size(self):
        return self.w, self.h

    def present(self, bgra, rows=None):
        """Copy pixel rows [y0, y1) (all of them when rows is None) into the scanout buffer."""
        if self.fd is None:  # released for a shell: take the screen back
            self._open()
        if not self.gfx:
            set_console_mode(KD_GRAPHICS)
            self.gfx = True
        y0, y1 = rows if rows else (0, self.h)
        row = self.w * 4
        if y1 > y0:
            if self.pitch == row:
                self.buf[y0 * row:y1 * row] = bytes(bgra[y0 * row:y1 * row])
            else:
                for y in range(y0, y1):
                    self.buf[y * self.pitch:y * self.pitch + row] = bytes(bgra[y * row:(y + 1) * row])
        try:
            _call(self.fd, "dirty", _Dirty(fb_id=self.fb_id))  # needed by some virtual GPUs, refused by others
        except OSError as e:
            if not self.dirty_refused:
                self.dirty_refused = True
                log(f"drm dirtyfb refused ({e}); fine on drivers that scan the buffer out directly")

    def release(self):
        if self.gfx or self.fd is not None:
            self._close()
            set_console_mode(KD_TEXT)
            self.gfx = False
            sys.stdout.write("\033[0m\033[2J\033[H")
            sys.stdout.flush()

    def close(self):
        self.release()


class FbSink:
    """/dev/fb0, 32 bits per pixel, with the console switched to graphics mode while drawing."""

    def __init__(self, dev="/dev/fb0", sysfs="/sys/class/graphics/fb0"):
        try:
            self.w, self.h = (int(v) for v in open(f"{sysfs}/virtual_size").read().split(","))
            bpp = int(open(f"{sysfs}/bits_per_pixel").read())
            self.stride = int(open(f"{sysfs}/stride").read())
            self.fd = os.open(dev, os.O_WRONLY)
        except (OSError, ValueError) as e:
            raise Unsupported(f"framebuffer not usable: {e}")
        if bpp != 32:
            os.close(self.fd)
            raise Unsupported(f"{bpp} bits per pixel is not supported")
        self.gfx = False

    def size(self):
        return self.w, self.h

    def present(self, bgra, rows=None):
        if not self.gfx:
            set_console_mode(KD_GRAPHICS)
            self.gfx = True
        y0, y1 = rows if rows else (0, self.h)
        row = self.w * 4
        if y1 > y0:
            if self.stride == row:
                os.pwrite(self.fd, bytes(bgra[y0 * row:y1 * row]), y0 * row)
            else:
                for y in range(y0, y1):
                    os.pwrite(self.fd, bytes(bgra[y * row:(y + 1) * row]), y * self.stride)

    def release(self):
        """Back to the text console (for a shell or a reboot); the next present() re-enters graphics."""
        if self.gfx:
            set_console_mode(KD_TEXT)
            self.gfx = False
            sys.stdout.write("\033[0m\033[2J\033[H")
            sys.stdout.flush()

    def close(self):
        self.release()
        os.close(self.fd)


# ---- keys ---------------------------------------------------------------------------------------
CSI_TILDE = {"1": curses.KEY_HOME, "3": curses.KEY_DC, "4": curses.KEY_END, "5": curses.KEY_PPAGE,
             "6": curses.KEY_NPAGE, **{str(n): curses.KEY_F0 + i for i, n in
                                       enumerate((11, 12, 13, 14, 15, 17, 18, 19, 20, 21, 23, 24), 1)}}
CSI_LETTER = {"A": curses.KEY_UP, "B": curses.KEY_DOWN, "C": curses.KEY_RIGHT, "D": curses.KEY_LEFT,
              "H": curses.KEY_HOME, "F": curses.KEY_END}


UNICODE_BASE = 0x110000  # typed non-ASCII characters are reported as UNICODE_BASE + codepoint, clear of curses KEY_*


def decode_key(buf):
    """(key, bytes used) for the start of buf, or (None, 0) when more bytes are needed. -1: ignored sequence."""
    if not buf:
        return None, 0
    if buf[0] >= 0xC2:  # the start of a UTF-8 character
        need = 2 if buf[0] < 0xE0 else 3 if buf[0] < 0xF0 else 4
        if len(buf) < need:
            return None, 0
        try:
            return UNICODE_BASE + ord(bytes(buf[:need]).decode("utf-8")), need
        except (UnicodeDecodeError, TypeError):
            return -1, 1
    if buf[0] != 0x1B:
        return buf[0], 1
    if len(buf) == 1:
        return None, 0  # a lone Esc, or the start of a sequence: the caller decides after a short wait
    if buf[1] == ord("O"):  # SS3: F1-F4 on some terminals
        if len(buf) < 3:
            return None, 0
        return (curses.KEY_F0 + 1 + "PQRS".index(chr(buf[2])), 3) if chr(buf[2]) in "PQRS" else (-1, 3)
    if buf[1] != ord("["):
        return 27, 1  # Esc followed by another key: report Esc and keep the rest
    i = 2
    if len(buf) > 2 and buf[2] == ord("["):  # linux console: ESC [ [ A..E are F1-F5
        return (curses.KEY_F0 + 1 + "ABCDE".index(chr(buf[3])), 4) if len(buf) > 3 and chr(buf[3]) in "ABCDE" else (None, 0)
    while i < len(buf) and not 0x40 <= buf[i] <= 0x7E:
        i += 1
    if i >= len(buf):
        return None, 0
    params, final = buf[2:i].decode("ascii", "ignore"), chr(buf[i])
    key = CSI_TILDE.get(params.split(";")[0], -1) if final == "~" else CSI_LETTER.get(final, -1)
    return key, i + 1


# ---- screen -------------------------------------------------------------------------------------
class FbScreen:
    is_fb = True

    def __init__(self, sink, font, palette, keys=None):
        self.sink, self.font = sink, font
        self.pal = [self._pix(c) for c in palette]
        w, h = sink.size()
        self.cols, self.rows = w // font.w, h // font.h
        self.W, self.H = w, h
        self.buf = bytearray(self.pal[0] * (w * h))
        self.cells = self.blank()
        self.prev = None
        self.cache = {}
        self.timeout_ms = -1
        self.pending = bytearray()
        self.keys = keys  # a scripted key list (previews and tests) instead of the keyboard
        self.saved, self.raw = None, False  # the terminal's own settings, and whether cbreak is on
        self.images = None  # loaded on first use
        self.image_rows = {}  # (side, bg) -> (full rows, dim rows)
        self.overlay = self.last_overlay = None  # (x, y, side, fill) of the mascot, drawn after the cells
        self.every = int(os.environ.get("AXIOM_FB_EVERY", "0") or 0)
        path = os.environ.get("AXIOM_FB_TEXT")  # test hook: the screen's characters, for harnesses
        self.text_path = path if path and os.path.realpath(os.path.dirname(path)) == TEXT_DIR else None
        if path and not self.text_path:
            log(f"AXIOM_FB_TEXT ignored: {path} is not a file directly under {TEXT_DIR}")
        self.presents = 0
        if keys is None and os.isatty(0):
            self.saved = termios.tcgetattr(0)
            self.cbreak()

    def cbreak(self):
        if self.saved and not self.raw:
            tty.setcbreak(0)
            self.raw = True

    def cooked(self):
        if self.saved and self.raw:
            termios.tcsetattr(0, termios.TCSADRAIN, self.saved)
            self.raw = False

    @staticmethod
    def _pix(hexcolour):
        r, g, b = (int(hexcolour[i:i + 2], 16) for i in (0, 2, 4))
        return bytes((b, g, r, 255))

    def blank(self):
        return [[(" ", 7, 0, False)] * self.cols for _ in range(self.rows)]

    # curses-compatible surface
    def getmaxyx(self):
        return self.rows, self.cols

    def keypad(self, _flag):
        pass

    def timeout(self, ms):
        self.timeout_ms = ms

    def erase(self):
        self.cells = self.blank()
        self.overlay = None

    def mascot(self, rows, top, fill):
        """Show the mascot image in `rows` cell rows from cell row `top`; False when no image of that size
        exists (the caller then draws the pixel-art face)."""
        side = rows * self.font.h
        if self.images is None:
            self.images = load_images()
        if side not in self.images or side > self.W or (top + rows) * self.font.h > self.H:
            return False
        self.overlay = ((self.W - side) // 2, top * self.font.h, side, max(0.0, min(1.0, fill)))
        return True

    def paint_mascot(self):
        x, y, side, fill = self.overlay
        split = side - int(round(fill * side))  # rows from here down are filled, as the pixel art fills from the feet
        for strength, wanted in ((1.0, split < side), (DIM, split > 0)):
            key = (side, x, y, strength, self.pal[0])
            if wanted and key not in self.image_rows:  # built on first use, so a full-colour mascot costs one pass
                self.image_rows[key] = blend_rows(self.images[side], side, self.pal[0][:3], strength)
        full = self.image_rows.get((side, x, y, 1.0, self.pal[0]))
        dim = self.image_rows.get((side, x, y, DIM, self.pal[0]))
        for r in range(side):
            off = ((y + r) * self.W + x) * 4
            self.buf[off:off + side * 4] = full[r] if r >= split else dim[r]

    def addnstr(self, y, x, text, n, attr=0):
        fg, bg, bold = (attr >> 8) & 15, (attr >> 12) & 15, bool(attr & curses.A_BOLD)
        for i, ch in enumerate(text[:n]):
            if 0 <= y < self.rows and 0 <= x + i < self.cols:
                self.cells[y][x + i] = (ch, fg, bg, bold)

    def addstr(self, y, x, text, attr=0):
        self.addnstr(y, x, text, len(text), attr)

    def refresh(self):
        self.cbreak()  # re-enter after a shell
        fw, fh = self.font.w, self.font.h
        if (self.overlay and self.overlay[:3]) != (self.last_overlay and self.last_overlay[:3]):
            self.prev = None  # the mascot moved, appeared or went: repaint everything under it
        self.last_overlay = self.overlay
        full = self.prev is None
        lo, hi = self.rows, -1  # the cell rows that changed, so only those pixel rows are sent to the screen
        for r in range(self.rows):
            row = self.cells[r]
            for c in range(self.cols):
                cell = row[c]
                if self.prev is not None and self.prev[r][c] == cell:
                    continue
                lo, hi = min(lo, r), max(hi, r)
                for dy, line in enumerate(self.cell_pixels(cell)):
                    off = ((r * fh + dy) * self.W + c * fw) * 4
                    self.buf[off:off + fw * 4] = line
        self.prev = [list(row) for row in self.cells]
        y0, y1 = (lo * fh, (hi + 1) * fh) if hi >= 0 else (0, 0)
        if self.overlay:
            self.paint_mascot()
            y0, y1 = min(y0, self.overlay[1]) if hi >= 0 else self.overlay[1], max(y1, self.overlay[1] + self.overlay[2])
        self.sink.present(self.buf, None if full else (y0, y1))
        if self.text_path:
            self.mirror_text()
        self.presents += 1
        if self.every and hasattr(self.sink, "snapshot") and self.presents % self.every == 0:
            self.sink.snapshot()

    def mirror_text(self):
        """Pixel drawing bypasses /dev/vcs, so tests read the characters from this file instead."""
        text = "\n".join("".join(c[0] for c in row).rstrip() for row in self.cells)
        try:
            fd = os.open(self.text_path, os.O_WRONLY | os.O_CREAT | os.O_TRUNC | os.O_NOFOLLOW, 0o600)
            with os.fdopen(fd, "w") as fh:
                fh.write(text + "\n")
        except OSError as e:
            log(f"screen text mirror failed: {e}")
            self.text_path = None

    def cell_pixels(self, cell):
        """The cell's pixel rows (cached): foreground bold maps to the bright twin, as on the console."""
        if cell in self.cache:
            return self.cache[cell]
        ch, fg, bg, bold = cell
        fgp, bgp = self.pal[fg + 8 if bold and fg < 8 else fg], self.pal[bg]
        fw, fh = self.font.w, self.font.h
        if ch in HALF:
            top, bot = (fgp if HALF[ch][0] else bgp), (fgp if HALF[ch][1] else bgp)
            rows = [top * fw] * (fh // 2) + [bot * fw] * (fh - fh // 2)
        elif ch == " ":
            rows = [bgp * fw] * fh
        else:
            rows = [b"".join(fgp if bits >> (fw - 1 - x) & 1 else bgp for x in range(fw))
                    for bits in self.font.rows(ch)]
        self.cache[cell] = rows
        return rows

    def getch(self):
        if self.keys is not None:
            if hasattr(self.sink, "snapshot"):
                self.sink.snapshot()
            if not self.keys:
                raise SystemExit(0)  # the scripted run is over
            return self.keys.pop(0)
        deadline = None if self.timeout_ms < 0 else time.monotonic() + self.timeout_ms / 1000
        while True:
            key, used = decode_key(self.pending)
            if used:
                del self.pending[:used]
                return key
            wait = 0.05 if self.pending else (None if deadline is None else max(0, deadline - time.monotonic()))
            if not select.select([0], [], [], wait)[0]:
                if self.pending:  # a lone Esc: nothing followed it
                    del self.pending[:1]
                    return 27
                return -1
            self.pending += os.read(0, 64)

    def end(self):
        self.cooked()
        self.sink.close()


# ---- entry points -------------------------------------------------------------------------------
ACTIVE = None  # the live FbScreen, so tui.endwin() can release the console for a shell or reboot


def parse_keys(spec):
    """AXIOM_FB_KEYS="enter,right,text:abc,f2" -> key codes."""
    keys = []
    for part in filter(None, (p.strip() for p in spec.split(","))):
        keys += [ord(ch) for ch in part[5:]] if part.startswith("text:") else [KEYNAMES[part]]
    return keys


def open_sink(backend="auto"):
    """DRM first (it reaches the screen on every KMS driver), then fbdev; Unsupported when neither works."""
    errors = []
    for name, sink in (("drm", DrmSink), ("fbdev", FbSink)):
        if backend in ("auto", name):
            try:
                opened = sink()
                log(f"pixel renderer: {name}")
                return opened
            except Unsupported as e:
                errors.append(f"{name}: {e}")
    raise Unsupported("; ".join(errors) or f"unknown backend {backend}")


def open_screen(palette, env=None):
    """An FbScreen for this environment, or None to use curses (AXIOM_UI=curses, no usable framebuffer)."""
    env = os.environ if env is None else env
    if env.get("AXIOM_UI") == "curses":
        return None
    try:
        font = load_font()
        if env.get("AXIOM_FB_PNG"):
            size = tuple(int(v) for v in env.get("AXIOM_FB_SIZE", "1600x900").split("x"))
            keys = parse_keys(env["AXIOM_FB_KEYS"]) if env.get("AXIOM_FB_KEYS") else None
            return FbScreen(PngSink(env["AXIOM_FB_PNG"], size), font, palette, keys)
        if env.get("TERM") != "linux" or not os.isatty(0):
            return None
        return FbScreen(open_sink(env.get("AXIOM_FB_BACKEND", "auto")), font, palette)
    except Unsupported as e:
        log(f"pixel renderer unavailable ({e}); using the text console")
        return None


def run(fn, palette):
    """curses.wrapper replacement: fn(screen) on the framebuffer when possible, else on curses."""
    global ACTIVE
    scr = open_screen(palette)
    if scr is None:
        return curses.wrapper(fn)
    ACTIVE = scr
    signal.signal(signal.SIGTERM, lambda *_: sys.exit(0))  # greetd ends the greeter with SIGTERM
    try:
        return fn(scr)
    finally:
        ACTIVE = None
        scr.end()


def release():
    """Hand the screen back to the text console; True when the framebuffer was in use."""
    if ACTIVE is None:
        return False
    if hasattr(ACTIVE.sink, "release"):
        ACTIVE.sink.release()
    ACTIVE.cooked()
    ACTIVE.prev = None  # the shell overwrote the screen: redraw everything next time
    return True
