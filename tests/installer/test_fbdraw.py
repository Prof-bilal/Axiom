"""Framebuffer renderer (ADR-027): font, keys, pixel placement and layout parity with the curses path."""
import curses
import importlib.machinery
import importlib.util
import os
import struct
import sys
import tempfile
import unittest
from unittest import mock

ROOT = os.path.join(os.path.dirname(__file__), "..", "..")
sys.path.insert(0, os.path.join(ROOT, "tui"))
import axiom_tui as t  # noqa: E402
import fbdraw  # noqa: E402

loader = importlib.machinery.SourceFileLoader("axiom_greeter_fb", os.path.join(ROOT, "greeter", "axiom-greeter"))
spec = importlib.util.spec_from_loader("axiom_greeter_fb", loader)
g = importlib.util.module_from_spec(spec)
loader.exec_module(g)

try:
    FONT = fbdraw.load_font()
except fbdraw.Unsupported:
    FONT = None


class MemSink:
    def __init__(self, w=320, h=128):
        self.w, self.h, self.frames = w, h, 0

    def size(self):
        return self.w, self.h

    def present(self, buf, rows=None):
        self.frames += 1
        self.buf = bytes(buf)
        self.rows = rows

    def close(self):
        pass


def screen(w=320, h=128, keys=None):
    return fbdraw.FbScreen(MemSink(w, h), FONT, t.PALETTE, keys=keys if keys is not None else [])


def px(s, x, y):
    off = (y * s.W + x) * 4
    return tuple(s.buf[off:off + 3])  # b, g, r


@unittest.skipIf(FONT is None, "console font not installed on this machine")
class Font(unittest.TestCase):
    def test_is_the_16x32_console_font(self):
        self.assertEqual((FONT.w, FONT.h), (16, 32))

    def test_letters_and_box_lines_have_glyphs(self):
        for ch in "AXIOMaxiom0123 ":
            self.assertIn(ch, FONT.index)
        for ch in "┌─┐│└┘":
            self.assertIn(ch, FONT.index, ch)
        self.assertTrue(any(FONT.rows("A")))
        self.assertFalse(any(FONT.rows(" ")))


class Keys(unittest.TestCase):
    def test_plain_arrow_and_function_keys(self):
        cases = {b"a": (97, 1), b"\n": (10, 1), b"\x7f": (127, 1), b"\x1b[A": (curses.KEY_UP, 3),
                 b"\x1b[B": (curses.KEY_DOWN, 3), b"\x1b[C": (curses.KEY_RIGHT, 3),
                 b"\x1b[D": (curses.KEY_LEFT, 3), b"\x1b[[B": (curses.KEY_F2, 4),
                 b"\x1bOP": (curses.KEY_F1, 3), b"\x1b[21~": (curses.KEY_F10, 5), b"\x1b[3~": (curses.KEY_DC, 4)}
        for raw, want in cases.items():
            self.assertEqual(fbdraw.decode_key(bytearray(raw)), want, raw)

    def test_incomplete_sequences_wait_for_more_bytes(self):
        for raw in (b"\x1b", b"\x1b[", b"\x1b[2", b"\x1bO"):
            self.assertEqual(fbdraw.decode_key(bytearray(raw)), (None, 0), raw)

    def test_esc_followed_by_a_key_is_esc(self):
        self.assertEqual(fbdraw.decode_key(bytearray(b"\x1bx")), (27, 1))

    def test_unknown_sequences_are_ignored_not_misread(self):
        self.assertEqual(fbdraw.decode_key(bytearray(b"\x1b[99Z")), (-1, 5))

    def test_scripted_keys(self):
        self.assertEqual(fbdraw.parse_keys("enter,text:ab,f2,down"),
                         [10, 97, 98, curses.KEY_F2, curses.KEY_DOWN])
        with self.assertRaises(KeyError):
            fbdraw.parse_keys("nonsense")


@unittest.skipIf(FONT is None, "console font not installed on this machine")
class Pixels(unittest.TestCase):
    def test_text_lands_in_its_own_16x32_cell(self):
        s = screen()
        ui = t.UI(s)
        ui.put(1, 3, "A", fg=t.WHITE)
        s.refresh()
        bg = px(s, 0, 0)
        inside = {px(s, 3 * 16 + x, 32 + y) for x in range(16) for y in range(32)}
        self.assertGreater(len(inside), 1)  # glyph pixels differ from the background
        outside = {px(s, x, y) for x in range(0, 320) for y in range(0, 128)
                   if not (3 * 16 <= x < 4 * 16 and 32 <= y < 64)}
        self.assertEqual(outside, {bg})

    def test_half_block_is_an_exact_pixel_half(self):
        s = screen()
        ui = t.UI(s)
        ui.put(0, 0, "▀", fg=t.CYAN, bg=t.BG)
        s.refresh()
        self.assertEqual(px(s, 5, 0), tuple(s.pal[t.CYAN][:3]))
        self.assertEqual(px(s, 5, 15), tuple(s.pal[t.CYAN][:3]))
        self.assertEqual(px(s, 5, 16), tuple(s.pal[t.BG][:3]))
        self.assertEqual(px(s, 5, 31), tuple(s.pal[t.BG][:3]))

    def test_bold_uses_the_bright_twin_like_the_console(self):
        s = screen()
        ui = t.UI(s)
        ui.put(0, 0, "█", fg=t.CYAN, bold=True)
        s.refresh()
        self.assertEqual(px(s, 2, 2), tuple(s.pal[t.CYAN + 8][:3]))

    def test_unchanged_cells_are_not_redrawn(self):
        s = screen()
        ui = t.UI(s)
        ui.put(0, 0, "A")
        s.refresh()
        s.buf[:] = bytes(len(s.buf))  # wipe: only changed cells may be written again
        s.refresh()
        self.assertEqual(set(s.buf), {0})

    def test_screen_text_is_mirrored_for_test_harnesses(self):
        with tempfile.TemporaryDirectory() as d, mock.patch.object(fbdraw, "TEXT_DIR", os.path.realpath(d)), \
                mock.patch.dict(os.environ, {"AXIOM_FB_TEXT": os.path.join(d, "s.txt")}):
            s = screen()
            t.UI(s).put(1, 2, "Step 1 of 6")
            s.refresh()
            lines = open(os.path.join(d, "s.txt")).read().split("\n")
            self.assertEqual(lines[0], "")
            self.assertEqual(lines[1], "  Step 1 of 6")

    def test_png_preview_is_a_valid_png(self):
        with tempfile.TemporaryDirectory() as d:
            sink = fbdraw.PngSink(d, (64, 32))
            sink.present(bytes(64 * 32 * 4))
            data = open(os.path.join(d, "latest.png"), "rb").read()
            self.assertEqual(data[:8], b"\x89PNG\r\n\x1a\n")
            self.assertEqual(struct.unpack(">II", data[16:24]), (64, 32))


@unittest.skipIf(FONT is None, "console font not installed on this machine")
class Mascot(unittest.TestCase):
    def test_asset_has_the_three_sizes(self):
        self.assertEqual(sorted(fbdraw.load_images()), [256, 448, 640])

    def test_a_missing_or_bad_asset_is_empty_not_a_crash(self):
        self.assertEqual(fbdraw.load_images("/nonexistent/penguin_image.bin"), {})
        with tempfile.NamedTemporaryFile() as f:
            f.write(b"junk")
            f.flush()
            self.assertEqual(fbdraw.load_images(f.name), {})

    def test_image_replaces_the_pixel_art_in_the_same_rows_and_fills_from_the_feet(self):
        s = screen(1600, 896)
        rows = t.UI(s).draw_penguin(0, t.penguin_art.MEDIUM, 0.5)
        self.assertEqual(rows, len(t.penguin_art.MEDIUM) // 2)  # same space as the pixel-art face
        s.refresh()
        self.assertEqual(set(s.buf[:4]), set(s.pal[0]))  # outside the image: background
        self.assertEqual(s.overlay[:3], ((1600 - 448) // 2, 0, 448))

    def test_dimmed_part_is_darker_than_the_filled_part_of_the_same_pixel_colour(self):
        s = screen(1600, 896)
        ui = t.UI(s)
        ui.draw_penguin(0, t.penguin_art.MEDIUM, 0.0)
        s.refresh()
        y, x = 330, (1600 - 448) // 2 + 120  # on the left foot
        empty = px(s, x, y)
        s.erase()
        ui.draw_penguin(0, t.penguin_art.MEDIUM, 1.0)
        s.refresh()
        self.assertGreater(sum(px(s, x, y)), sum(empty))

    def test_pixel_art_is_the_fallback_when_no_image_fits_the_screen(self):
        s = screen(320, 128)  # too small for any mascot image
        t.UI(s).draw_penguin(0, t.penguin_art.SMALL, 1.0)
        self.assertIsNone(s.overlay)
        self.assertTrue(any(ch == "▀" for row in s.cells for ch, *_ in row))

    def test_moving_or_removing_the_image_repaints_the_screen(self):
        s = screen(1600, 896)
        ui = t.UI(s)
        ui.draw_penguin(0, t.penguin_art.MEDIUM, 1.0)
        s.refresh()
        s.erase()  # next screen has no mascot
        ui.put(0, 0, "x")
        s.refresh()
        self.assertEqual(px(s, 800, 100), tuple(s.pal[0][:3]))  # the old image is gone


@unittest.skipIf(FONT is None, "console font not installed on this machine")
class Parity(unittest.TestCase):
    """The pixel screen must put every character where the curses screen does (layout unchanged)."""

    class Recorder:
        def __init__(self, h, w):
            self.h, self.w, self.cells = h, w, {}

        def getmaxyx(self):
            return self.h, self.w

        def erase(self):
            self.cells.clear()

        def refresh(self):
            pass

        def keypad(self, _):
            pass

        def mascot(self, rows, top, fill):
            return False  # no image on this screen: the pixel-art penguin is drawn with addstr

        def addnstr(self, y, x, text, n, attr=0):
            for i, ch in enumerate(text[:n]):
                self.cells[(y, x + i)] = ch

        addstr = lambda self, y, x, text, attr=0: self.addnstr(y, x, text, len(text), attr)  # noqa: E731

    def draw_login(self, scr, fb):
        app = g.Login.__new__(g.Login)
        app.ui = t.UI.__new__(t.UI)
        app.ui.s, app.ui._pairs, app.ui.fb = scr, {}, fb
        app.ui.pair = (lambda fg, bg=0: fg << 8 | bg << 12)
        app.msg, app.msg_color, app.dx = "That password didn't work.", g.RED, 0
        app.draw(None, "abc")

    def test_login_text_is_at_the_same_cells_on_both_screens(self):
        fbs = screen(1600, 896)  # 100 x 28 cells
        fbs.images = {}  # no mascot image here: both screens draw the same pixel-art cells
        rec = self.Recorder(fbs.rows, fbs.cols)
        self.draw_login(fbs, True)
        self.draw_login(rec, True)  # box() takes the unicode path for both so the comparison is exact
        got = {(r, c): ch for r, row in enumerate(fbs.cells) for c, (ch, *_rest) in enumerate(row) if ch != " "}
        want = {k: v for k, v in rec.cells.items() if v != " "}
        self.assertEqual(got, want)
        self.assertGreater(len(got), 100)


class FakeKernel:
    """Just enough of the DRM ioctl interface for DrmSink: one connected 1920x1080 output."""
    W, H = 1920, 1080

    def __init__(self):
        self.calls, self.map = [], None

    def ioctl(self, fd, req, arg=None, mutate=True):
        import ctypes
        req &= 0xFFFFFFFF
        name = next((k for k, v in fbdraw.IOCTL.items() if v == req), hex(req))
        self.calls.append((name, arg))
        u32 = ctypes.POINTER(ctypes.c_uint32)
        if name == "res":
            if not arg.crtc_id_ptr:
                arg.count_crtcs = arg.count_connectors = arg.count_encoders = 1
            else:
                ctypes.cast(arg.crtc_id_ptr, u32)[0] = 10
                ctypes.cast(arg.connector_id_ptr, u32)[0] = 20
                ctypes.cast(arg.encoder_id_ptr, u32)[0] = 30
        elif name == "conn":
            arg.connection, arg.count_modes, arg.count_encoders, arg.encoder_id = 1, 1, 1, 30
            if arg.modes_ptr:
                mode = ctypes.cast(arg.modes_ptr, ctypes.POINTER(fbdraw._Mode))[0]
                mode.hdisplay, mode.vdisplay = self.W, self.H
        elif name == "enc":
            arg.crtc_id, arg.possible_crtcs = 10, 1
        elif name == "create":
            arg.handle, arg.pitch, arg.size = 5, self.W * 4, self.W * self.H * 4
        elif name == "addfb":
            arg.fb_id = 7
        elif name == "map":
            arg.offset = 0

    def mmap(self, fd, size, *a, **k):
        class Map(bytearray):
            def close(self_):
                pass
        self.map = Map(size)
        return self.map

    def patched(self):
        return mock.patch.multiple(fbdraw, fcntl=mock.Mock(ioctl=self.ioctl), mmap=mock.Mock(mmap=self.mmap, MAP_SHARED=1,
                                                                                            PROT_READ=1, PROT_WRITE=2),
                                   os=mock.Mock(open=lambda *a, **k: 99, close=lambda fd: None, path=os.path,
                                                O_RDWR=2, O_CLOEXEC=0, environ=os.environ, isatty=os.isatty))


class Drm(unittest.TestCase):
    """The DRM/KMS backend talks to the kernel through fixed ioctl numbers and structure layouts."""

    def test_the_sink_sets_the_mode_with_its_own_buffer(self):
        k = FakeKernel()
        with k.patched():
            sink = fbdraw.DrmSink("/dev/dri/card0")
            self.assertEqual(sink.size(), (1920, 1080))
            setcrtc = next(a for n, a in k.calls if n == "setcrtc")
            self.assertEqual((setcrtc.crtc_id, setcrtc.fb_id, setcrtc.count_connectors, setcrtc.mode_valid), (10, 7, 1, 1))
            self.assertEqual(setcrtc.mode.hdisplay, 1920)

    def test_only_the_changed_rows_are_copied(self):
        k = FakeKernel()
        with k.patched():
            sink = fbdraw.DrmSink("/dev/dri/card0")
            frame = bytes([9]) * (1920 * 1080 * 4)
            sink.present(frame, (2, 4))
            row = 1920 * 4
            self.assertEqual(set(k.map[2 * row:4 * row]), {9})
            self.assertEqual(set(k.map[:2 * row]) | set(k.map[4 * row:]), {0})  # everything else untouched
            sink.present(frame)  # no range: the whole frame
            self.assertEqual(set(k.map), {9})

    def test_released_sink_takes_the_screen_back_on_the_next_frame(self):
        k = FakeKernel()
        with k.patched():
            sink = fbdraw.DrmSink("/dev/dri/card0")
            sink.release()
            self.assertIsNone(sink.fd)
            sink.present(bytes(1920 * 1080 * 4))
            self.assertIsNotNone(sink.fd)
            self.assertGreaterEqual([n for n, _ in k.calls].count("setcrtc"), 2)

    def test_ioctl_numbers_and_struct_sizes_match_the_kernel_headers(self):
        want = {"res": 0xC04064A0, "setcrtc": 0xC06864A2, "enc": 0xC01464A6, "conn": 0xC05064A7,
                "addfb": 0xC01C64AE, "create": 0xC02064B2, "map": 0xC01064B3, "dirty": 0xC01864B1}
        for name, value in want.items():
            self.assertEqual(fbdraw.IOCTL[name], value, name)

    def test_every_request_number_fits_the_signed_ioctl_argument(self):
        for name, req in fbdraw.IOCTL.items():
            signed = req - (1 << 32) if req > 0x7FFFFFFF else req
            self.assertTrue(-(1 << 31) <= signed < (1 << 31), name)

    def test_size_stays_a_method_after_the_buffer_is_set_up(self):
        # regression: an attribute called size used to shadow the size() method and crash at startup
        self.assertTrue(callable(fbdraw.DrmSink.size))
        self.assertIn("buf_size", open(fbdraw.__file__).read())

    def test_a_missing_device_is_unsupported_not_a_crash(self):
        with self.assertRaises(fbdraw.Unsupported):
            fbdraw.DrmSink("/dev/dri/does-not-exist")

    def test_drm_is_tried_first_then_fbdev_then_curses(self):
        order = []

        def fail(name):
            def make():
                order.append(name)
                raise fbdraw.Unsupported(name)
            return make

        with mock.patch.object(fbdraw, "DrmSink", fail("drm")), mock.patch.object(fbdraw, "FbSink", fail("fbdev")):
            with self.assertRaises(fbdraw.Unsupported):
                fbdraw.open_sink("auto")
            self.assertEqual(order, ["drm", "fbdev"])
            order.clear()
            with self.assertRaises(fbdraw.Unsupported):
                fbdraw.open_sink("fbdev")
            self.assertEqual(order, ["fbdev"])  # an explicit backend is the only one tried
        with mock.patch.object(fbdraw, "DrmSink", lambda: "drm-sink"), mock.patch.object(fbdraw, "FbSink", fail("fbdev")):
            self.assertEqual(fbdraw.open_sink("auto"), "drm-sink")

    def test_an_unusable_framebuffer_falls_back_to_curses(self):
        with mock.patch.object(fbdraw, "open_sink", side_effect=fbdraw.Unsupported("none")):
            if FONT is not None:
                self.assertIsNone(fbdraw.open_screen(t.PALETTE, env={"TERM": "linux"}) if os.isatty(0) else None)


@unittest.skipIf(FONT is None, "console font not installed on this machine")
class Scan(unittest.TestCase):
    """Fixes from the pre-release scan."""

    def test_only_the_changed_pixel_rows_are_sent_to_the_screen(self):
        s = screen()
        ui = t.UI(s)
        ui.put(1, 2, "A")
        s.refresh()
        self.assertIsNone(s.sink.rows)  # the first frame is a full repaint
        s.erase()
        ui.put(3, 2, "B")  # row 1 loses its A, row 3 gains a B
        s.refresh()
        self.assertEqual(s.sink.rows, (1 * 32, 4 * 32))
        s.erase()
        ui.put(3, 2, "B")
        s.refresh()
        self.assertEqual(s.sink.rows, (0, 0))  # nothing changed: nothing to send

    def test_typed_non_ascii_characters_are_decoded_not_dropped(self):
        self.assertEqual(fbdraw.decode_key(bytearray("é".encode())), (fbdraw.UNICODE_BASE + ord("é"), 2))
        self.assertEqual(fbdraw.decode_key(bytearray("€".encode())), (fbdraw.UNICODE_BASE + ord("€"), 3))
        self.assertEqual(fbdraw.decode_key(bytearray("é".encode()[:1])), (None, 0))  # wait for the rest
        self.assertEqual(fbdraw.decode_key(bytearray(b"\xc3(")), (-1, 1))  # not UTF-8: ignored, not a crash
        self.assertEqual(t.typed_char(ord("a")), "a")
        self.assertEqual(t.typed_char(fbdraw.UNICODE_BASE + ord("é")), "é")
        self.assertIsNone(t.typed_char(curses.KEY_UP))
        self.assertIsNone(t.typed_char(10))

    def test_a_failed_pixel_renderer_leaves_a_log_line(self):
        lines = []
        with mock.patch.object(fbdraw, "log", lines.append), \
                mock.patch.object(fbdraw, "open_sink", side_effect=fbdraw.Unsupported("drm: no card")), \
                mock.patch("os.isatty", return_value=True):
            self.assertIsNone(fbdraw.open_screen(t.PALETTE, env={"TERM": "linux"}))
        self.assertTrue(any("drm: no card" in l and "text console" in l for l in lines), lines)

    def test_the_text_mirror_only_writes_directly_under_its_directory(self):
        with tempfile.TemporaryDirectory() as d, tempfile.TemporaryDirectory() as other:
            d, other = os.path.realpath(d), os.path.realpath(other)
            with mock.patch.object(fbdraw, "TEXT_DIR", d), mock.patch.object(fbdraw, "log", lambda m: None):
                with mock.patch.dict(os.environ, {"AXIOM_FB_TEXT": os.path.join(other, "s.txt")}):
                    self.assertIsNone(screen().text_path)  # outside: refused
                with mock.patch.dict(os.environ, {"AXIOM_FB_TEXT": os.path.join(d, "s.txt")}):
                    ok = screen()
                    self.assertEqual(ok.text_path, os.path.join(d, "s.txt"))
                    victim = os.path.join(other, "victim")
                    open(victim, "w").write("keep")
                    os.symlink(victim, ok.text_path)  # a planted symlink must not redirect the root write
                    ok.refresh()
                    self.assertEqual(open(victim).read(), "keep")
                    self.assertIsNone(ok.text_path)  # and the mirror switches itself off

    def test_hidden_console_errors_are_logged_except_not_a_vt(self):
        import errno
        lines = []
        with mock.patch.object(fbdraw, "log", lines.append):
            with mock.patch.object(fbdraw.fcntl, "ioctl", side_effect=OSError(errno.ENOTTY, "no tty")):
                fbdraw.set_console_mode(fbdraw.KD_GRAPHICS)
            self.assertEqual(lines, [])
            with mock.patch.object(fbdraw.fcntl, "ioctl", side_effect=OSError(errno.EPERM, "denied")):
                fbdraw.set_console_mode(fbdraw.KD_GRAPHICS)
            self.assertEqual(len(lines), 1)


@unittest.skipIf(FONT is None, "console font not installed on this machine")
class EntryPoints(unittest.TestCase):
    def test_curses_can_be_forced(self):
        self.assertIsNone(fbdraw.open_screen(t.PALETTE, env={"AXIOM_UI": "curses", "AXIOM_FB_PNG": "/tmp/x"}))

    def test_no_framebuffer_outside_a_linux_console_falls_back(self):
        self.assertIsNone(fbdraw.open_screen(t.PALETTE, env={"TERM": "xterm-256color"}))

    def test_run_draws_to_png_and_follows_scripted_keys(self):
        seen = []

        def fn(scr):
            ui = t.UI(scr)
            ui.put(0, 0, "hello")
            scr.refresh()
            seen.append(scr.getch())
            seen.append(scr.getch())
            scr.getch()  # script over: the run ends

        with tempfile.TemporaryDirectory() as d, \
                mock.patch.dict(os.environ, {"AXIOM_FB_PNG": d, "AXIOM_FB_KEYS": "down,text:x"}):
            with self.assertRaises(SystemExit):
                t.run(fn)
            self.assertEqual(seen, [curses.KEY_DOWN, ord("x")])
            self.assertTrue(os.path.exists(os.path.join(d, "latest.png")))
            self.assertTrue(os.path.exists(os.path.join(d, "frame-001.png")))

    def test_the_screen_is_released_for_a_shell_and_redrawn_afterwards(self):
        s = screen()
        fbdraw.ACTIVE = s
        try:
            self.assertTrue(t.endwin() is None)
            self.assertIsNone(s.prev)  # forces a full redraw on the next refresh
        finally:
            fbdraw.ACTIVE = None


if __name__ == "__main__":
    unittest.main()
