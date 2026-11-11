"""Unit tests for the shared console UI helpers (no curses, no terminal)."""
import os
import sys
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "tui"))
import axiom_tui as t  # noqa: E402
import penguin_art as art  # noqa: E402


def glyph_colors(cells):
    return {c for row in cells for (_, fg, bg, _) in row for c in (fg, bg)}


class Penguin(unittest.TestCase):
    def test_art_is_well_formed(self):
        for a in (art.LARGE, art.MEDIUM, art.SMALL):
            self.assertEqual(len(a) % 2, 0, "half blocks need an even number of pixel rows")
            self.assertEqual(len({len(r) for r in a}), 1)
            self.assertTrue(set("".join(a)) <= set(".bwok"))

    def test_empty_is_all_ghost(self):
        cells = t.penguin_cells(art.MEDIUM, 0.0)
        self.assertEqual(glyph_colors(cells) - {t.BG}, {t.GHOST})

    def test_full_uses_brand_colours_only(self):
        cells = t.penguin_cells(art.MEDIUM, 1.0)
        self.assertEqual(glyph_colors(cells) - {t.BG}, {t.CYAN, t.WHITE, t.ORANGE, t.GHOST})

    def test_fill_rises_from_the_feet(self):
        cells = t.penguin_cells(art.MEDIUM, 0.5)
        top, bottom = cells[0], cells[-1]
        self.assertTrue(all(c in (t.BG, t.GHOST) for (_, fg, bg, _) in top for c in (fg, bg)))
        self.assertTrue(any(fg in (t.CYAN, t.WHITE, t.ORANGE) or bg in (t.CYAN, t.WHITE, t.ORANGE)
                            for (_, fg, bg, _) in bottom))

    def test_fill_is_monotonic(self):
        def lit(f):
            return sum(1 for r in t.penguin_cells(art.MEDIUM, f) for (_, fg, bg, _) in r
                       if fg in (t.CYAN, t.WHITE, t.ORANGE) or bg in (t.CYAN, t.WHITE, t.ORANGE))
        counts = [lit(i / 20) for i in range(21)]
        self.assertEqual(counts, sorted(counts))
        self.assertGreater(counts[-1], counts[0])

    def test_colours_stay_in_background_safe_slots(self):
        for row in t.penguin_cells(art.LARGE, 0.7):
            for (_, fg, bg, _) in row:
                self.assertLess(fg, 8)
                self.assertLess(bg, 8)

    def test_clamps_fill(self):
        self.assertEqual(t.penguin_cells(art.SMALL, -3), t.penguin_cells(art.SMALL, 0))
        self.assertEqual(t.penguin_cells(art.SMALL, 9), t.penguin_cells(art.SMALL, 1))

    def test_size_selection(self):
        self.assertIs(t.pick_penguin(40), art.LARGE)
        self.assertIs(t.pick_penguin(16), art.MEDIUM)
        self.assertIs(t.pick_penguin(10), art.SMALL)
        self.assertIsNone(t.pick_penguin(5))


class Text(unittest.TestCase):
    def test_wrap_keeps_paragraphs_and_width(self):
        lines = t.wrap("one two three four five six seven eight nine ten\nsecond", 20)
        self.assertTrue(all(len(l) <= 20 for l in lines))
        self.assertEqual(lines[-1], "second")

    def test_palette_has_sixteen_valid_colours(self):
        self.assertEqual(len(t.PALETTE), 16)
        self.assertTrue(all(len(c) == 6 and int(c, 16) >= 0 for c in t.PALETTE))

    def test_wait_for_framebuffer_gives_up_and_picks_up_a_late_device(self):
        calls = {"n": 0}
        real = t.fb_height
        def late():
            calls["n"] += 1
            return 0 if calls["n"] < 3 else 900
        t.fb_height = late
        try:
            self.assertEqual(t.wait_fb_height(timeout=2, step=0.01), 900)
            t.fb_height = lambda: 0
            self.assertEqual(t.wait_fb_height(timeout=0.05, step=0.01), 0)
        finally:
            t.fb_height = real

    def test_font_applied_compares_columns_with_framebuffer_width(self):
        real_fb, real_ts = t.fb_size, os.get_terminal_size
        class Out:
            def fileno(self):
                return 1
        try:
            t.fb_size = lambda: (1920, 1080)
            os.get_terminal_size = lambda fd: os.terminal_size((120, 33))
            self.assertTrue(t.font_applied(Out()))
            os.get_terminal_size = lambda fd: os.terminal_size((240, 67))  # default 8-pixel font
            self.assertFalse(t.font_applied(Out()))
            t.fb_size = lambda: (0, 0)
            self.assertFalse(t.font_applied(Out()))
        finally:
            t.fb_size, os.get_terminal_size = real_fb, real_ts

    def test_setup_console_is_a_noop_off_the_linux_vt(self):
        import io
        old = os.environ.get("TERM")
        os.environ["TERM"] = "xterm"
        try:
            buf = io.StringIO()
            self.assertFalse(t.setup_console(buf))
            self.assertEqual(buf.getvalue(), "")
        finally:
            if old is None:
                os.environ.pop("TERM")
            else:
                os.environ["TERM"] = old


if __name__ == "__main__":
    unittest.main()
