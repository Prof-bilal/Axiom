"""Hub search engine (system/hub/hubengine.py): parsers, merge rules, search, safe refresh."""
import gzip
import io
import json
import os
import sys
import tempfile
import unittest
import urllib.error

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(HERE)), "system", "hub"))
import hubengine as h  # noqa: E402

PACMAN_SS = """extra/firefox 160.0.1-1 [installed: 158.0.1-1]
    Fast, Private & Safe Web Browser
extra/firefox-i18n-de 160.0.1-1
    German language pack for Firefox
extra/mousepad 0.7.0-1
    Simple text editor
extra/ripgrep 15.2.0-1
    Line-oriented search tool
chaotic/odd-tool 1.0-1
    Third party repo tool
extra/nosummary 1.0-1
extra/gtk3+ 1:3.24.49-1
    toolkit
"""

FLATHUB = b"""<?xml version="1.0"?>
<components version="0.8" origin="flatpak">
  <component type="desktop-application"><id>org.mozilla.firefox</id><name>Firefox</name>
    <name xml:lang="de">Feuerfuchs</name><summary>Browse the web</summary>
    <project_license>MPL-2.0</project_license><developer id="org.mozilla"><name>Mozilla</name></developer>
    <icon type="cached" width="128" height="128">org.mozilla.firefox.png</icon>
    <bundle type="flatpak">app/org.mozilla.firefox/x86_64/stable</bundle>
    <releases><release timestamp="100" version="1.0"/><release timestamp="300" version="3.0"/></releases>
    <categories><category>Network</category><category>WebBrowser</category></categories>
    <custom><value key="flathub::verification::verified">true</value></custom></component>
  <component type="desktop-application"><id>org.xfce.mousepad</id><name>Mousepad</name><summary>Text editor</summary>
    <bundle type="flatpak">app/org.xfce.mousepad/x86_64/stable</bundle><releases><release timestamp="5" version="0.7.0"/></releases></component>
  <component type="desktop-application"><id>com.example.Sketchy</id><name>Sketchy Editor</name><summary>Edits things</summary>
    <bundle type="flatpak">app/com.example.Sketchy/x86_64/stable</bundle></component>
  <component type="console-application"><id>com.example.cli</id><name>Cli Thing</name><summary>A cli</summary>
    <bundle type="flatpak">app/com.example.cli/x86_64/stable</bundle></component>
  <component type="desktop"><id>org.videolan.VLC</id><name>VLC</name><summary>Media player</summary>
    <bundle type="flatpak">app/org.videolan.VLC/x86_64/stable</bundle></component>
  <component type="runtime"><id>org.freedesktop.Platform</id><name>Platform</name></component>
  <component type="addon"><id>com.example.addon</id><name>Addon</name>
    <bundle type="flatpak">app/com.example.addon/x86_64/stable</bundle></component>
</components>"""


def offline(req, timeout=0):
    """Opener for tests that must never reach the network: the old cached copy is kept."""
    raise urllib.error.URLError("offline")


def apps():
    return list(h.parse_flathub(io.BytesIO(FLATHUB)))


class Parsers(unittest.TestCase):
    def test_pacman_search_hits_and_summaries(self):
        hits = h.parse_pacman_search(PACMAN_SS)
        names = [x["name"] for x in hits]
        self.assertIn("gtk3+", names)
        fx = hits[0]
        self.assertEqual((fx["repo"], fx["version"], fx["installed"]), ("extra", "160.0.1-1", True))

    def test_hit_without_summary_does_not_swallow_the_next(self):
        hits = {x["name"]: x for x in h.parse_pacman_search(PACMAN_SS)}
        self.assertEqual(hits["nosummary"]["summary"], "")
        self.assertEqual(hits["gtk3+"]["summary"], "toolkit")

    def test_garbage_gives_no_hits(self):
        self.assertEqual(h.parse_pacman_search("error: nope\n$(id);rm -rf /"), [])
        self.assertEqual(h.parse_pacman_search(None), [])

    def test_sizes(self):
        self.assertEqual(h.size_mb("1.5 GiB"), 1536)
        self.assertEqual(h.size_mb("3 B"), 1)
        self.assertEqual(h.size_mb("0 B"), 0)
        self.assertIsNone(h.size_mb("junk"))

    def test_flathub_keeps_apps_and_cli_only_untranslated_text_latest_version(self):
        a = {x["id"]: x for x in apps()}
        self.assertEqual(set(a), {"org.mozilla.firefox", "org.xfce.mousepad", "com.example.Sketchy", "com.example.cli", "org.videolan.VLC"})
        fx = a["org.mozilla.firefox"]
        self.assertEqual((fx["name"], fx["version"], fx["verified"], fx["publisher"]), ("Firefox", "3.0", True, "Mozilla"))
        self.assertEqual(a["com.example.cli"]["kind"], "cli")
        self.assertFalse(a["com.example.Sketchy"]["verified"])

    def test_distro_catalog_maps_pkgname_to_id(self):
        xml = b"<components><component><id>org.mozilla.firefox</id><pkgname>firefox</pkgname></component></components>"
        self.assertEqual(h.parse_distro_catalog(io.BytesIO(xml)), {"firefox": {"id": "org.mozilla.firefox", "kind": "package"}})


class Index(unittest.TestCase):
    def setUp(self):
        self.d = tempfile.mkdtemp()
        self.db = os.path.join(self.d, "i.sqlite")
        self.pac = h.parse_pacman_search(PACMAN_SS)

    def build(self, distro=None):
        return h.build_index(self.db, apps(), self.pac, distro or {})

    def test_language_packs_are_not_indexed(self):
        self.build()
        self.assertEqual([r for r in h.search(self.db, "firefox-i18n-de") if "i18n" in r["name"]], [])

    def test_override_merges_pacman_and_flatpak_by_appstream_id(self):
        self.build()
        r = h.search(self.db, "mousepad")[0]
        self.assertEqual({s["type"] for s in r["sources"]}, {"pacman", "flatpak"})
        self.assertEqual(r["sources"][0]["type"], "pacman")  # official repo first

    def test_distro_catalogue_merges_firefox(self):
        self.build({"firefox": {"id": "org.mozilla.firefox", "kind": "app"}})
        r = [x for x in h.search(self.db, "firefox") if x["id"] == "org.mozilla.firefox"][0]
        self.assertEqual([s["trust"] for s in r["sources"]], ["official", "verified"])

    def test_legacy_desktop_type_is_an_app_and_ids_match_without_case(self):
        a = {x["id"]: x for x in apps()}
        self.assertEqual(a["org.videolan.VLC"]["kind"], "app")
        self.pac += h.parse_pacman_search("extra/vlc 3.0-1\n    Media player\n")
        self.build({"vlc": {"id": "org.videolan.vlc", "kind": "app"}})  # Arch lower-cases the id
        r = [x for x in h.search(self.db, "vlc") if x["id"] == "org.videolan.VLC"][0]
        self.assertEqual({s["type"] for s in r["sources"]}, {"pacman", "flatpak"})

    def test_name_alone_never_merges(self):
        self.build()
        fx = [x for x in h.search(self.db, "firefox")]
        self.assertGreaterEqual(len(fx), 2)  # pacman:firefox and org.mozilla.firefox stay separate without an id link

    def test_trust_classes(self):
        self.build()
        t = {s["ref"]: s["trust"] for r in h.search(self.db, "tool") for s in r["sources"]}
        self.assertEqual(t["odd-tool"], "community")
        sk = h.search(self.db, "sketchy")[0]
        self.assertEqual(sk["sources"][0]["trust"], "unverified")

    def test_exact_match_ranks_first_and_packages_after_apps(self):
        self.build({"firefox": {"id": "org.mozilla.firefox", "kind": "app"}})
        first = h.search(self.db, "firefox")[0]
        self.assertEqual((first["id"], first["exact"]), ("org.mozilla.firefox", True))
        kinds = [r["kind"] for r in h.search(self.db, "e")]
        self.assertEqual(kinds, sorted(kinds, key=lambda k: k == "package"))  # apps before bare packages

    def test_categories_come_from_flathub_and_pacman_only_apps_have_none(self):
        self.build()
        fx = [x for x in h.search(self.db, "firefox") if x["id"] == "org.mozilla.firefox"][0]
        self.assertEqual(fx["categories"], ["Network", "WebBrowser"])
        rg = h.search(self.db, "ripgrep")[0]
        self.assertEqual(rg["categories"], [])

    def test_prefix_search_and_icon_url(self):
        self.build()
        r = h.search(self.db, "firef")
        self.assertTrue(r)
        fx = [x for x in r if x["id"] == "org.mozilla.firefox"][0]
        self.assertEqual(fx["icon"], h.FLATHUB_ICON + "org.mozilla.firefox.png")

    def test_search_input_is_never_fts_syntax(self):
        self.build()
        for evil in ['"', 'a" OR "b', "NEAR(", "*", "firefox*)", "'; drop table apps;--", ""]:
            h.search(self.db, evil)  # must not raise
        self.assertEqual(h.fts_query("a b"), '"a" "b"*')
        self.assertIsNone(h.fts_query("!!!"))

    def test_an_index_from_an_older_schema_is_not_read(self):
        import sqlite3
        db = sqlite3.connect(self.db)
        db.execute("create table apps(key text, name text, summary text, kind text, icon text, sources text)")
        db.execute("create virtual table fts using fts5(key unindexed, name, summary, refs)")
        db.execute("create table meta(k text primary key, v text)")
        db.commit()
        db.close()
        self.assertFalse(h.index_ok(self.db))
        self.assertEqual(h.search(self.db, "x"), [])  # no traceback, the CLI rebuilds instead

    def test_a_current_index_is_ok(self):
        self.build()
        self.assertTrue(h.index_ok(self.db))

    def test_search_without_an_index_is_empty_not_an_error(self):
        self.assertEqual(h.search(os.path.join(self.d, "none.sqlite"), "x"), [])


class Installed(unittest.TestCase):
    def setUp(self):
        self.d = tempfile.mkdtemp()
        self.db = os.path.join(self.d, "i.sqlite")
        pac = h.parse_pacman_search(PACMAN_SS + "extra/base 3-1\n    Base\nextra/neovim 0.10-1\n    Editor\n")
        h.build_index(self.db, apps(), pac, {"firefox": {"id": "org.mozilla.firefox", "kind": "app"}, "ripgrep": {"id": "rg.desktop", "kind": "cli"}})

    def test_installed_apps_come_from_the_system_lists(self):
        r = h.installed_apps(self.db, ["firefox", "zsh"], ["org.xfce.mousepad"], [])
        by = {a["id"]: a for a in r}
        self.assertEqual(by["org.mozilla.firefox"]["installed"], ["pacman"])
        self.assertEqual(by["org.xfce.mousepad"]["installed"], ["flatpak"])

    def test_bare_packages_only_show_if_the_hub_installed_them(self):
        self.assertEqual([a["name"] for a in h.installed_apps(self.db, ["base", "neovim"], [], [])], [])
        mine = [{"type": "pacman", "ref": "neovim"}]
        names = [a["name"] for a in h.installed_apps(self.db, ["base", "neovim"], [], mine)]
        self.assertEqual(names, ["neovim"])

    def test_a_pacman_only_app_known_to_the_distro_catalogue_shows_as_installed(self):
        r = h.installed_apps(self.db, ["ripgrep"], [], [])
        self.assertEqual([(a["name"], a["kind"]) for a in r], [("ripgrep", "cli")])

    def test_nothing_installed_gives_nothing(self):
        self.assertEqual(h.installed_apps(self.db, [], [], []), [])
        self.assertEqual(h.installed_apps(os.path.join(self.d, "none"), ["firefox"], [], []), [])

    def test_record_install_and_remove_roundtrip_atomically(self):
        p = os.path.join(self.d, "state", "installed.json")
        os.makedirs(os.path.dirname(p))
        self.assertEqual(h.record("install", "pacman", "neovim", p), 1)
        self.assertEqual(h.record("install", "pacman", "neovim", p), 1, "twice is still one entry")
        self.assertEqual(h.record("install", "flatpak", "org.a.B", p), 2)
        self.assertEqual(h.record("remove", "pacman", "neovim", p), 1)
        self.assertEqual(h.load_record(p), [{"type": "flatpak", "ref": "org.a.B"}])
        self.assertFalse(os.path.exists(p + ".part"))

    def test_record_rejects_bad_input(self):
        p = os.path.join(self.d, "x.json")
        for bad in [("install", "npm", "x"), ("nuke", "pacman", "x"), ("install", "pacman", "a;b"), ("install", "pacman", "-Syu"), ("install", "pacman", "")]:
            with self.assertRaises(ValueError, msg=str(bad)):
                h.record(*bad, path=p)
        self.assertFalse(os.path.exists(p))

    def test_a_damaged_state_file_reads_as_empty(self):
        p = os.path.join(self.d, "bad.json")
        open(p, "w").write("{not json")
        self.assertEqual(h.load_record(p), [])
        open(p, "w").write(json.dumps([{"type": "pacman", "ref": "ok"}, {"type": "pacman", "ref": "a;b"}, "junk", {"type": "npm", "ref": "x"}]))
        self.assertEqual(h.load_record(p), [{"type": "pacman", "ref": "ok"}])


class Fetch(unittest.TestCase):
    def setUp(self):
        self.dest = os.path.join(tempfile.mkdtemp(), "a.xml.gz")

    def opener(self, body=b"data", etag='"e1"'):
        class R(io.BytesIO):
            headers = {"ETag": etag}
            def __enter__(s): return s
            def __exit__(s, *a): return False
        return lambda req, timeout=0: R(body)

    def test_first_fetch_writes_file_and_etag_atomically(self):
        self.assertEqual(h.fetch_flathub(self.dest, opener=self.opener()), "fresh")
        self.assertEqual(open(self.dest, "rb").read(), b"data")
        self.assertEqual(open(self.dest + ".etag").read(), '"e1"')
        self.assertFalse(os.path.exists(self.dest + ".part"))

    def test_recent_copy_is_not_downloaded_again(self):
        h.fetch_flathub(self.dest, opener=self.opener())
        def boom(*a, **k): raise AssertionError("must not hit the network")
        self.assertEqual(h.fetch_flathub(self.dest, opener=boom), "fresh")

    def test_old_copy_sends_etag_and_304_keeps_it(self):
        h.fetch_flathub(self.dest, opener=self.opener())
        os.utime(self.dest, (0, 0))
        seen = {}
        def op(req, timeout=0):
            seen["inm"] = req.get_header("If-none-match")
            raise urllib.error.HTTPError(req.full_url, 304, "nm", {}, None)
        self.assertEqual(h.fetch_flathub(self.dest, opener=op), "not-modified")
        self.assertEqual(seen["inm"], '"e1"')
        self.assertEqual(open(self.dest, "rb").read(), b"data")

    def test_network_failure_keeps_the_old_copy(self):
        h.fetch_flathub(self.dest, opener=self.opener())
        os.utime(self.dest, (0, 0))
        def down(req, timeout=0): raise urllib.error.URLError("offline")
        self.assertEqual(h.fetch_flathub(self.dest, opener=down), "stale")

    def test_no_copy_and_no_network_is_an_error(self):
        def down(req, timeout=0): raise urllib.error.URLError("offline")
        with self.assertRaises(urllib.error.URLError):
            h.fetch_flathub(self.dest, opener=down)

    def test_index_url_is_https(self):
        self.assertTrue(h.FLATHUB_URL.startswith("https://dl.flathub.org/"))


class Refresh(unittest.TestCase):
    def test_refresh_end_to_end_with_fixtures(self):
        d = tempfile.mkdtemp()
        os.environ["AXIOM_HUB_CACHE"] = d
        try:
            with gzip.open(os.path.join(d, "appstream.xml.gz"), "wb") as fh:
                fh.write(FLATHUB)
            r = h.refresh(runner=lambda args: PACMAN_SS, opener=offline)
            self.assertEqual(r["flathub"], "fresh")
            self.assertGreater(r["apps"], 3)
            self.assertTrue(h.search(os.path.join(d, "index.sqlite"), "sketchy"))
            # a second refresh right after is skipped: a fresh index is not rebuilt
            again = h.refresh(runner=lambda args: self.fail("must not rebuild a fresh index"))
            self.assertTrue(again["skipped"])
            self.assertEqual(h.refresh(force=True, runner=lambda args: PACMAN_SS, opener=offline)["flathub"], "stale")
        finally:
            del os.environ["AXIOM_HUB_CACHE"]


class Catalogs(unittest.TestCase):
    def test_catalogue_directories_can_be_overridden_for_tests(self):
        d = tempfile.mkdtemp()
        with gzip.open(os.path.join(d, "x.xml.gz"), "wb") as fh:
            fh.write(b'<components><component type="console-application"><id>rg.desktop</id><pkgname>ripgrep</pkgname></component></components>')
        os.environ["AXIOM_HUB_CATALOGS"] = d
        try:
            self.assertEqual(h.load_distro_map(), {"ripgrep": {"id": "rg.desktop", "kind": "cli"}})
        finally:
            del os.environ["AXIOM_HUB_CATALOGS"]

    def test_a_broken_catalogue_file_is_skipped(self):
        d = tempfile.mkdtemp()
        open(os.path.join(d, "bad.xml"), "w").write("<not xml")
        self.assertEqual(h.load_distro_map([d]), {})


class RefreshLock(unittest.TestCase):
    def test_concurrent_refreshes_do_not_corrupt_each_other(self):
        import threading
        d = tempfile.mkdtemp()
        os.environ["AXIOM_HUB_CACHE"] = d
        try:
            with gzip.open(os.path.join(d, "appstream.xml.gz"), "wb") as fh:
                fh.write(FLATHUB)
            results, errors = [], []

            def work():
                try:
                    results.append(h.refresh(force=True, runner=lambda args: PACMAN_SS, opener=offline))
                except Exception as e:  # noqa: BLE001 - the test reports any failure
                    errors.append(e)
            threads = [threading.Thread(target=work) for _ in range(4)]
            [t.start() for t in threads]
            [t.join() for t in threads]
            self.assertEqual(errors, [])
            self.assertEqual(len(results), 4)
            self.assertTrue(h.index_ok(os.path.join(d, "index.sqlite")))
        finally:
            del os.environ["AXIOM_HUB_CACHE"]


if __name__ == "__main__":
    unittest.main()
