"""Unit tests for installer/axiom_install.py (stdlib unittest, no root, no QEMU).

    python3 -m unittest discover -s tests/installer -v
"""
import json
import os
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "installer"))
import axiom_install as ai  # noqa: E402

GOOD = {"username": "dev", "fullname": "Dev User", "hostname": "axiom-box", "password": "correct-horse-9",
        "timezone": "UTC", "keyboard": "us", "locale": "en_US", "git_name": "Dev User",
        "git_email": "dev@example.com", "hub": ["git", "neovim"]}
ZONES = tempfile.mkdtemp()
open(os.path.join(ZONES, "UTC"), "w").close()
os.makedirs(os.path.join(ZONES, "Europe"))
open(os.path.join(ZONES, "Europe", "Berlin"), "w").close()


def v(**kw):
    return ai.validate_form({**GOOD, **kw}, ZONES)


LSBLK = json.dumps({"blockdevices": [
    {"name": "vda", "path": "/dev/vda", "size": 25769803776, "model": "QEMU", "serial": "x", "type": "disk",
     "rm": False, "ro": False, "mountpoints": [None], "children": [
         {"name": "vda1", "mountpoints": [None]}]},
    {"name": "sr0", "path": "/dev/sr0", "size": 2e9, "type": "rom", "rm": True, "ro": True, "mountpoints": ["/run/archiso/bootmnt"]},
    {"name": "loop0", "path": "/dev/loop0", "size": 1e9, "type": "loop", "rm": False, "ro": True, "mountpoints": ["/run/archiso/airootfs"]},
    {"name": "vdb", "path": "/dev/vdb", "size": 1e10, "type": "disk", "rm": False, "ro": False, "mountpoints": [None],
     "children": [{"name": "vdb1", "mountpoints": ["/mnt"]}]},
    {"name": "sdb", "path": "/dev/sdb", "size": 1e10, "type": "disk", "rm": True, "ro": False, "mountpoints": [None]},
]})


class Validation(unittest.TestCase):
    def test_good(self):
        self.assertEqual(v()["username"], "dev")

    def test_username(self):
        for bad in ["", "Root", "root", "1abc", "a b", "a;rm -rf /", "x" * 33, "dev$(id)", "../x", "axiom"]:
            with self.assertRaises(ai.FormError, msg=bad):
                v(username=bad)

    def test_password(self):
        for bad in ["short", "password", "aaaaaaaaaaaa", "dev", "install", "has\nnewline-12"]:
            with self.assertRaises(ai.FormError, msg=bad):
                v(password=bad)
        with self.assertRaises(ai.FormError):
            v(username="longuser1", password="longuser1")

    def test_hostname(self):
        for bad in ["", "-a", "a_b", "A", "a" * 64, "a b", "a;b"]:
            with self.assertRaises(ai.FormError, msg=bad):
                v(hostname=bad)

    def test_timezone(self):
        self.assertEqual(v(timezone="Europe/Berlin")["timezone"], "Europe/Berlin")
        for bad in ["../../etc/passwd", "Mars/Base", "/etc/passwd", "", "UTC;x"]:
            with self.assertRaises(ai.FormError, msg=bad):
                v(timezone=bad)

    def test_git_identity(self):
        with self.assertRaises(ai.FormError):
            v(git_email="not-an-email")
        with self.assertRaises(ai.FormError):
            v(git_name="a<b>", git_email="a@b.co")
        with self.assertRaises(ai.FormError):
            v(git_name="", git_email="a@b.co")
        self.assertEqual(v(git_name="", git_email="")["git_name"], "")

    def test_fullname_rejects_passwd_field_separators(self):
        for bad in ["a:b", "a,b", "a\nb", ""]:
            with self.assertRaises(ai.FormError, msg=bad):
                v(fullname=bad)

    def test_luks_needs_strong_passphrase(self):
        with self.assertRaises(ai.FormError):
            v(luks=True, luks_passphrase="weak")
        self.assertTrue(v(luks=True, luks_passphrase="a-long-passphrase")["luks"])

    def test_hub_ids(self):
        with self.assertRaises(ai.FormError):
            v(hub=["ok", "bad id; rm"])


class Disks(unittest.TestCase):
    def test_only_safe_disks(self):
        self.assertEqual([d["path"] for d in ai.list_disks(LSBLK)], ["/dev/vda"])

    def test_target_recheck(self):
        d = ai.list_disks(LSBLK)
        self.assertEqual(ai.check_target("/dev/vda", 25769803776, d)["path"], "/dev/vda")
        for path, size in [("/dev/vdb", 1e10), ("/dev/sr0", 2e9), ("/dev/vda", 1), ("/dev/loop0", 1e9)]:
            with self.assertRaises(ai.FormError):
                ai.check_target(path, int(size), d)


class Config(unittest.TestCase):
    def test_layout(self):
        cfg = ai.build_config(v(), "/dev/vda", 24 * 1024 ** 3)
        esp, root = cfg["disk_config"]["device_modifications"][0]["partitions"]
        self.assertEqual(esp["mountpoint"], "/boot")
        self.assertEqual(root["fs_type"], "btrfs")
        self.assertIn({"name": "@", "mountpoint": "/"}, root["btrfs"])
        self.assertNotIn("disk_encryption", cfg)
        self.assertEqual(cfg["kernels"], ["linux", "linux-lts"])  # LTS is the fallback boot entry
        total = esp["size"]["value"] + root["size"]["value"] + 1
        self.assertLessEqual(total, 24 * 1024)

    def test_luks(self):
        cfg = ai.build_config(v(luks=True, luks_passphrase="a-long-passphrase"), "/dev/vda", 24 * 1024 ** 3)
        root = cfg["disk_config"]["device_modifications"][0]["partitions"][1]
        self.assertEqual(cfg["disk_encryption"]["partitions"], [root["obj_id"]])
        self.assertNotIn("a-long-passphrase", json.dumps(cfg))

    def test_small_disk_rejected(self):
        with self.assertRaises(ai.FormError):
            ai.build_config(v(), "/dev/vda", 4 * 1024 ** 3)

    def test_creds_hash_not_plaintext(self):
        creds = ai.build_creds(v())
        blob = json.dumps(creds)
        self.assertNotIn("correct-horse-9", blob)
        self.assertTrue(creds["users"][0]["enc_password"].startswith("$6$"))
        self.assertNotIn("root_enc_password", creds)

    def test_profile_has_no_secrets(self):
        p = json.dumps(ai.build_profile(v(luks=True, luks_passphrase="a-long-passphrase")))
        self.assertNotIn("correct-horse-9", p)
        self.assertNotIn("a-long-passphrase", p)
        self.assertNotIn("password", p)

    def test_no_shell_metacharacters_reach_argv(self):
        # every value that becomes part of a command is validated before use
        for field, bad in [("hostname", "a;reboot"), ("username", "x`id`"), ("timezone", "UTC;id")]:
            with self.assertRaises(ai.FormError):
                v(**{field: bad})



class Cleanup(unittest.TestCase):
    def test_kill_users_only_targets_processes_under_target(self):
        d = tempfile.mkdtemp()
        for pid, root in (("101", "/mnt"), ("102", "/mnt/usr"), ("103", "/"), ("104", "/mntx"), ("abc", "/mnt")):
            os.makedirs(os.path.join(d, pid))
            os.symlink(root, os.path.join(d, pid, "root"))
            os.symlink("/", os.path.join(d, pid, "cwd"))
        hit = []
        self.assertEqual(sorted(ai.kill_users("/mnt", d, lambda p, s: hit.append((p, s)))), [101, 102])
        self.assertEqual(sorted(hit), [(101, 9), (102, 9)])


class Progress(unittest.TestCase):
    # Lines copied from real archinstall/pacman output (including carriage-return redraws).
    DL1 = "\r Total (  3/159)       329.6 MiB  2012 KiB/s 03:04 [##########------------]  47%"
    DL1_END = " Total (150/159)       838.0 MiB  2.10 MiB/s 00:01 [#####################-]  99%"
    INST1 = "(111/159) installing cryptsetup                    [######################] 100%"

    def test_two_rounds_move_forward_smoothly(self):
        tr = ai.ProgressTracker()
        seen = [tr.pct]
        for chunk in (":: Retrieving packages...\n" + self.DL1, self.DL1_END, self.INST1,
                      ":: Retrieving packages...\n Total (  0/324)         0.0   B  0.00   B/s 00:00 [---]   0%",
                      "(200/324) installing firefox   [####] 100%", "==> Building image from preset: default"):
            tr.feed(chunk)
            seen.append(tr.pct)
        self.assertEqual(seen, sorted(seen), "percent must never go backwards")
        self.assertGreater(seen[-1], 80)
        self.assertLess(seen[-1], 100)

    def test_package_names_in_the_listing_do_not_move_the_bar(self):
        tr = ai.ProgressTracker()
        tr.feed("Packages (324) mkinitcpio-39-1  mkinitcpio-busybox-0.2-1  systemd-boot-1  linux-firmware-2026")
        tr.feed(":: Retrieving packages...\n" + self.DL1)
        self.assertLess(tr.pct, 40)
        self.assertEqual(tr.stage, "Downloading Axiom")

    def test_real_boot_step_markers_do_move_it(self):
        tr = ai.ProgressTracker()
        tr.feed(":: Retrieving packages...\n" + self.INST1)
        tr.feed("==> Building image from preset: /etc/mkinitcpio.d/linux.preset: 'default'")
        self.assertGreaterEqual(tr.pct, 85)
        self.assertEqual(tr.stage, "Setting up startup")

    def test_stage_and_detail_text(self):
        tr = ai.ProgressTracker()
        tr.feed(":: Retrieving packages...\n" + self.DL1)
        self.assertEqual(tr.stage, "Downloading Axiom")
        self.assertIn("329.6 MiB downloaded at 2012 KiB/s", tr.detail)
        tr.feed(self.INST1)
        self.assertEqual(tr.stage, "Installing the system")
        self.assertEqual(tr.detail, "Package 111 of 159: cryptsetup")

    def test_disk_phase_is_capped_before_downloads(self):
        tr = ai.ProgressTracker()
        for _ in range(30):
            tr.feed("luks2 formatting mapper dev: /dev/mapper/root")
        self.assertLessEqual(tr.pct, 7)
        self.assertEqual(tr.stage, "Preparing the disk")

    def test_garbage_is_ignored_and_never_reaches_100(self):
        tr = ai.ProgressTracker()
        self.assertFalse(tr.feed("\x00\xff random \r\r\n noise (a/b) installing"))
        tr.feed("(999/999) installing x")
        self.assertLess(tr.pct, 100)

    def test_eta(self):
        self.assertIsNone(ai.eta_minutes(5, 600))
        self.assertIsNone(ai.eta_minutes(50, 10))
        self.assertEqual(ai.eta_minutes(50, 300), 5)
        self.assertGreaterEqual(ai.eta_minutes(99, 3000), 1)


if __name__ == "__main__":
    unittest.main()
