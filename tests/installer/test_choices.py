"""Installer pick-lists: arrow keys cycle, typing does nothing, a new Region rebuilds City."""
import curses
import importlib.machinery
import importlib.util
import os
import sys
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, "installer"))
sys.path.insert(0, os.path.join(REPO, "tui"))
_loader = importlib.machinery.SourceFileLoader("axiom_installer", os.path.join(REPO, "installer", "axiom-installer"))
installer = importlib.util.module_from_spec(importlib.util.spec_from_loader("axiom_installer", _loader))
_loader.exec_module(installer)

ZONES = {"Europe": ["Berlin", "London"], "UTC": ["UTC"]}


class FakeScreen:
    def __init__(self, keys, record=None):
        self.keys, self.record = list(keys), record

    def getch(self):
        if self.record:
            self.record()
        return self.keys.pop(0)

    def erase(self):
        pass

    def refresh(self):
        pass


class FakeUI:
    """Just enough of axiom_tui.UI for form(): no curses window is opened."""
    w, h = 100, 30

    def __init__(self, keys, record=None):
        self.s = FakeScreen(keys, record)

    def wordmark(self, y):
        return 3

    def steps(self, y, step, total):
        return 1

    def card_geometry(self, x, y):
        return (2, 90, 22)

    def put(self, *args, **kwargs):
        pass

    def footer(self, text):
        pass


class Choices(unittest.TestCase):
    def test_letters_are_ignored_arrows_cycle_and_region_rebuilds_city(self):
        fields = installer.tz_fields(ZONES, "UTC")
        self.assertEqual([f["value"] for f in fields], ["UTC", "UTC"], "default is UTC")
        seen = []

        def record():
            seen.append([f["value"] for f in fields] + [list(fields[1]["choices"])])
        ui = FakeUI([ord("e"), curses.KEY_RIGHT, 10, curses.KEY_LEFT, 10], record)
        installer.form(ui, 1, 6, "Language and time", "", fields)
        self.assertEqual(seen[1][0], "UTC", "a letter changes nothing")
        self.assertEqual(seen[2][0], "Europe", "Right moves the region")
        self.assertEqual(seen[2][1], "Berlin", "the city list was rebuilt for the new region")
        self.assertEqual(seen[2][2], ["Berlin", "London"])
        self.assertEqual(seen[4][1], "London", "Left cycles the city")
        self.assertEqual(installer.tz_name(fields[0]["value"], fields[1]["value"]), "Europe/London")


if __name__ == "__main__":
    unittest.main()
