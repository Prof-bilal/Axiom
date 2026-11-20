"""The icon and cursor generators run, and the cursor files are valid Xcursor."""
import os, struct, subprocess, sys

ROOT = os.path.join(os.path.dirname(__file__), "..")
CURSORS = os.path.join(ROOT, "iso/phase3/airootfs/usr/share/icons/axiom-cursors/cursors")


def test_generators_check():
    for script in ("gen-icons.py", "gen-cursors.py"):
        r = subprocess.run([sys.executable, os.path.join(ROOT, "scripts", script), "--check"],
                           capture_output=True, text=True)
        assert r.returncode == 0, r.stderr


def test_default_cursor_is_valid_xcursor():
    data = open(os.path.join(CURSORS, "default"), "rb").read()
    magic, header, version, ntoc = struct.unpack("<4s3I", data[:16])
    assert magic == b"Xcur" and header == 16 and ntoc >= 1
    for i in range(ntoc):
        kind, size, off = struct.unpack("<3I", data[16 + 12 * i:28 + 12 * i])
        assert kind == 0xFFFD0002
        h = struct.unpack("<9I", data[off:off + 36])
        assert h[0] == 36 and h[2] == size and h[4] == h[5] == size   # chunk header, nominal size, w == h
        assert 0 <= h[6] < size and 0 <= h[7] < size                  # hotspot inside the image
        assert len(data) >= off + 36 + size * size * 4                # all pixels present


def test_aliases_point_at_a_real_cursor():
    for alias in ("left_ptr", "hand2", "xterm", "watch"):
        assert os.path.exists(os.path.join(CURSORS, alias))
