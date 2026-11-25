"""Axiom Hub search engine: one local index over the Arch repos and Flathub (ADR-037).

Unprivileged and stdlib only. It reads the local pacman sync database (no root, no `pacman -Sy`)
and the Flathub AppStream index (HTTPS, cached, conditional GET, refreshed at most daily), and writes
one SQLite FTS5 index under $XDG_CACHE_HOME/axiom-hub. Search never installs and never runs root.

Apps are merged only by AppStream id (Flathub id, or the id the distro catalogue gives a pacman
package, or the curated override table). A name match alone never merges two sources.
"""
import gzip
import json
import os
import re
import sqlite3
import subprocess
import sys
import time
import urllib.error
import urllib.request
import xml.etree.ElementTree as ET

FLATHUB_URL = "https://dl.flathub.org/repo/appstream/x86_64/appstream.xml.gz"
FLATHUB_ICON = "https://dl.flathub.org/repo/appstream/x86_64/icons/128x128/"
TTL_SECONDS = 24 * 3600
SCHEMA = "2"  # bump when the index tables change; an older index is rebuilt, never read
LANG = "{http://www.w3.org/XML/1998/namespace}lang"
OFFICIAL_REPOS = {"core", "extra", "multilib"}
DISTRO_CATALOGS = ("/usr/share/swcatalog/xml", "/var/lib/swcatalog/xml")
# pacman package -> AppStream id, for packages the distro catalogue does not map. Add entries when a real
# mismatch is found; never add a pair by guessing.
OVERRIDES = {"mousepad": "org.xfce.mousepad"}
# Language packs, docs and debug/dev splits are packages, not things a person installs from a store.
NOT_AN_APP = re.compile(r"(-i18n-|-l10n-|-langpack-|-docs?$|-debug$|-devel$|-headers$)")
TRUST_ORDER = {"official": 0, "verified": 1, "community": 2, "unverified": 3}


def cache_dir():
    base = os.environ.get("AXIOM_HUB_CACHE") or os.path.join(
        os.environ.get("XDG_CACHE_HOME") or os.path.expanduser("~/.cache"), "axiom-hub")
    os.makedirs(base, exist_ok=True)
    return base


# ---- pacman ------------------------------------------------------------------------------------
def parse_pacman_search(text):
    """`pacman -Ss` prints a header line and an indented summary line per hit."""
    out, lines, i = [], str(text or "").splitlines(), 0
    while i < len(lines):
        m = re.match(r"^(\S+)/(\S+)\s+(\S+)(\s+\[installed(?:: ([^\]]+))?\])?", lines[i])
        if not m:
            i += 1
            continue
        nxt = lines[i + 1] if i + 1 < len(lines) else ""
        described = bool(re.match(r"^\s+\S", nxt))
        out.append({"repo": m.group(1), "name": m.group(2), "version": m.group(3),
                    "installed": bool(m.group(4)), "summary": nxt.strip() if described else ""})
        i += 2 if described else 1
    return out


def size_mb(text):
    m = re.search(r"([\d.]+)\s*(KiB|MiB|GiB|B)\b", text or "")
    if not m or float(m.group(1)) <= 0:
        return 0 if m else None
    mb = float(m.group(1)) * {"B": 1 / 1048576, "KiB": 1 / 1024, "MiB": 1, "GiB": 1024}[m.group(2)]
    return max(1, round(mb))  # a non-zero download never reads as 0 MB


def parse_pacman_info(text):
    f = {}
    for line in str(text or "").splitlines():
        m = re.match(r"^(\S[^:]*?)\s*:\s?(.*)$", line)
        if m:
            f[m.group(1).strip()] = m.group(2).strip()
    if not f.get("Name"):
        return None
    return {"name": f["Name"], "repo": f.get("Repository"), "version": f.get("Version"),
            "arch": f.get("Architecture"), "licence": f.get("Licenses"),
            "download_mb": size_mb(f.get("Download Size")), "installed_mb": size_mb(f.get("Installed Size")),
            "publisher": f.get("Packager"), "signed": "Signature" in f.get("Validated By", "")}


def run_pacman(args):
    # LC_ALL=C: the parser reads pacman's English output, whatever the user's language is.
    return subprocess.run(["pacman"] + args, capture_output=True, text=True, timeout=120,
                          env={**os.environ, "LC_ALL": "C"}).stdout


# ---- Flathub AppStream -------------------------------------------------------------------------
def _plain(el, tag):
    """First child `tag` without an xml:lang (the untranslated text)."""
    for c in el.findall(tag):
        if LANG not in c.attrib and (c.text or "").strip():
            return c.text.strip()
    return ""


def parse_flathub(fileobj):
    """Yield one dict per desktop or console application in a Flathub appstream.xml stream."""
    for _, el in ET.iterparse(fileobj):
        if el.tag != "component":
            continue
        # Flathub still lists some apps (Firefox, for one) with the legacy type "desktop"; a Flatpak bundle makes it an app.
        kind = {"desktop-application": "app", "desktop": "app", "console-application": "cli"}.get(el.get("type"))
        bundle = next((b for b in el.findall("bundle") if b.get("type") == "flatpak"), None)
        if kind and bundle is not None and (el.findtext("id") or "").strip():
            custom = {v.get("key"): (v.text or "") for v in el.findall("custom/value")}
            rel = [(int(r.get("timestamp") or 0), r.get("version") or "") for r in el.findall("releases/release")]
            icon = next((i.text for i in el.findall("icon") if i.get("type") == "cached" and i.get("height") in ("128", "64")), "")
            dev = el.find("developer")
            yield {"id": el.findtext("id").strip(), "name": _plain(el, "name"), "summary": _plain(el, "summary"),
                   "kind": kind, "licence": el.findtext("project_license") or "",
                   "publisher": (_plain(dev, "name") if dev is not None else "") or el.findtext("developer_name") or "",
                   "version": max(rel)[1] if rel else "", "icon": icon or "",
                   "verified": custom.get("flathub::verification::verified") == "true",
                   "categories": [c.text for c in el.findall("categories/category") if c.text]}
        el.clear()


def parse_distro_catalog(fileobj):
    """AppStream catalogue shipped by the distro: {pacman package name: {"id": AppStream id, "kind": app|cli|package}}."""
    out = {}
    for _, el in ET.iterparse(fileobj):
        if el.tag == "component":
            cid, pkg = (el.findtext("id") or "").strip(), (el.findtext("pkgname") or "").strip()
            kind = {"desktop-application": "app", "desktop": "app", "console-application": "cli"}.get(el.get("type"), "package")
            if cid and pkg:
                out[pkg] = {"id": cid, "kind": kind}
            el.clear()
    return out


def load_distro_map(dirs=DISTRO_CATALOGS):
    out = {}
    for d in dirs:
        if not os.path.isdir(d):
            continue
        for name in sorted(os.listdir(d)):
            if name.endswith((".xml", ".xml.gz")):
                path = os.path.join(d, name)
                try:
                    with (gzip.open(path, "rb") if name.endswith(".gz") else open(path, "rb")) as fh:
                        out.update(parse_distro_catalog(fh))
                except (OSError, ET.ParseError):
                    continue  # a broken catalogue only costs matching quality
    return out


def fetch_flathub(dest, now=None, opener=urllib.request.urlopen):
    """Conditional download. Returns "fresh", "not-modified" or "stale" (network failed, old copy kept)."""
    if not FLATHUB_URL.startswith("https://"):
        raise ValueError("Flathub index must be fetched over HTTPS")
    etag_path = dest + ".etag"
    now = now or time.time()
    if os.path.exists(dest) and now - os.path.getmtime(dest) < TTL_SECONDS:
        return "fresh"
    req = urllib.request.Request(FLATHUB_URL, headers={"User-Agent": "axiom-hub"})
    if os.path.exists(dest) and os.path.exists(etag_path):
        req.add_header("If-None-Match", open(etag_path).read().strip())
    try:
        with opener(req, timeout=60) as r:
            data = r.read()
            etag = r.headers.get("ETag", "")
    except urllib.error.HTTPError as e:
        if e.code == 304:
            os.utime(dest, (now, now))
            return "not-modified"
        return "stale" if os.path.exists(dest) else _raise(e)
    except (urllib.error.URLError, OSError) as e:
        return "stale" if os.path.exists(dest) else _raise(e)
    tmp = dest + ".part"
    with open(tmp, "wb") as fh:
        fh.write(data)
    os.replace(tmp, dest)
    if etag:
        open(etag_path, "w").write(etag)
    return "fresh"


def _raise(e):
    raise e


# ---- index -------------------------------------------------------------------------------------
def build_index(db_path, flathub, pacman, distro_map, overrides=OVERRIDES):
    """Write the merged index to db_path (atomically). flathub and pacman are lists of dicts."""
    apps = {}  # key -> {name, summary, kind, icon, sources:[...]}
    # Ids are reverse-DNS under a domain, so they are compared without case (Arch: org.videolan.vlc, Flathub: org.videolan.VLC).
    by_lower = {f["id"].lower(): f["id"] for f in flathub}
    for f in flathub:
        a = apps.setdefault(f["id"], {"name": f["name"], "summary": f["summary"], "kind": f["kind"], "icon": f["icon"], "cats": f["categories"], "sources": []})
        a["sources"].append({"type": "flatpak", "ref": f["id"], "version": f["version"], "publisher": f["publisher"],
                             "trust": "verified" if f["verified"] else "unverified", "licence": f["licence"]})
    for p in pacman:
        if NOT_AN_APP.search(p["name"]):
            continue
        entry = distro_map.get(p["name"]) or {}
        cid = overrides.get(p["name"]) or entry.get("id")
        cid = by_lower.get((cid or "").lower(), cid)
        key = cid if cid in apps else (cid or "pacman:" + p["name"])
        # A pacman-only app still counts as an app or a cli tool when the distro catalogue says so.
        a = apps.setdefault(key, {"name": p["name"], "summary": p["summary"], "kind": entry.get("kind", "package"), "icon": "", "cats": [], "sources": []})
        if not a["summary"]:
            a["summary"] = p["summary"]
        official = p["repo"] in OFFICIAL_REPOS
        a["sources"].append({"type": "pacman", "ref": p["name"], "version": p["version"], "publisher": p["repo"],
                             "trust": "official" if official else "community", "licence": ""})
    tmp = db_path + ".part"
    if os.path.exists(tmp):
        os.remove(tmp)
    db = sqlite3.connect(tmp)
    db.execute("create table apps(key text primary key, name text, summary text, kind text, icon text, cats text, sources text)")
    db.execute("create virtual table fts using fts5(key unindexed, name, summary, refs, tokenize='unicode61 remove_diacritics 2')")
    for key, a in apps.items():
        refs = " ".join(s["ref"] for s in a["sources"])
        db.execute("insert into apps values(?,?,?,?,?,?,?)", (key, a["name"], a["summary"], a["kind"], a["icon"], json.dumps(a["cats"]), json.dumps(a["sources"])))
        db.execute("insert into fts values(?,?,?,?)", (key, a["name"], a["summary"], refs))
    db.execute("create table meta(k text primary key, v text)")
    db.execute("insert into meta values('built', ?)", (str(int(time.time())),))
    db.execute("insert into meta values('schema', ?)", (SCHEMA,))
    db.commit()
    db.close()
    os.replace(tmp, db_path)
    return len(apps)


def fts_query(text):
    """Quote every word so user input can never be FTS syntax. The last word is a prefix match."""
    words = re.findall(r"\w+", text or "", re.UNICODE)[:8]
    if not words:
        return None
    return " ".join(['"%s"' % w for w in words[:-1]] + ['"%s"*' % words[-1]])


def index_ok(db_path):
    """True when the index exists and was built by this schema version."""
    if not os.path.exists(db_path):
        return False
    try:
        db = sqlite3.connect(db_path)
        row = db.execute("select v from meta where k = 'schema'").fetchone()
        db.close()
        return bool(row) and row[0] == SCHEMA
    except sqlite3.Error:
        return False


def search(db_path, text, limit=30):
    q = fts_query(text)
    if not q or not index_ok(db_path):
        return []
    db = sqlite3.connect(db_path)
    rows = db.execute("select a.key, a.name, a.summary, a.kind, a.icon, a.cats, a.sources from fts join apps a on a.key = fts.key "
                      "where fts match ? order by bm25(fts, 0, 10, 2, 5) limit ?", (q, limit * 3)).fetchall()
    db.close()
    needle = (text or "").strip().lower()
    out = []
    for key, name, summary, kind, icon, cats, sources in rows:
        srcs = json.loads(sources)
        srcs.sort(key=lambda s: TRUST_ORDER.get(s["trust"], 9))  # official repo first (owner decision)
        exact = name.lower() == needle or key.lower() == needle or any(s["ref"].lower() == needle for s in srcs)
        out.append({"id": key, "name": name, "summary": summary, "kind": kind,
                    "icon": FLATHUB_ICON + icon if icon else "", "categories": json.loads(cats), "sources": srcs, "exact": exact})
    out.sort(key=lambda a: (not a["exact"], a["kind"] == "package", TRUST_ORDER.get(a["sources"][0]["trust"], 9)))
    return out[:limit]


# ---- installed apps ----------------------------------------------------------------------------
REF_RE = re.compile(r"^[A-Za-z0-9][A-Za-z0-9@._+-]*$")


def state_path():
    base = os.environ.get("AXIOM_HUB_STATE") or os.path.join(
        os.environ.get("XDG_STATE_HOME") or os.path.expanduser("~/.local/state"), "axiom-hub")
    os.makedirs(base, exist_ok=True)
    return os.path.join(base, "installed.json")


def load_record(path):
    try:
        data = json.load(open(path))
    except (OSError, ValueError):
        return []
    if not isinstance(data, list):
        return []
    # One bad entry is skipped, not the whole list.
    return [r for r in data if isinstance(r, dict) and r.get("type") in ("pacman", "flatpak")
            and isinstance(r.get("ref"), str) and REF_RE.match(r["ref"])]


def record(action, kind, ref, path=None):
    """Remember what the Hub installed, so a bare package it installed (no AppStream data) still shows as installed."""
    if action not in ("install", "remove") or kind not in ("pacman", "flatpak") or not REF_RE.match(ref or ""):
        raise ValueError("bad record request")
    path = path or state_path()
    items = [r for r in load_record(path) if not (r["type"] == kind and r["ref"] == ref)]
    if action == "install":
        items.append({"type": kind, "ref": ref})
    tmp = path + ".part"
    with open(tmp, "w") as fh:
        json.dump(items, fh)
    os.replace(tmp, path)
    return len(items)


def installed_apps(db_path, pacman_names, flatpak_ids, hub_refs):
    """Apps with at least one installed source. Apps (kind app or cli) show whenever installed; a bare package
    shows only if the Hub installed it, so base packages and dependencies do not fill the list."""
    if not index_ok(db_path):
        return []
    pm, fp = set(pacman_names), set(flatpak_ids)
    mine = {(r["type"], r["ref"]) for r in hub_refs}
    db = sqlite3.connect(db_path)
    rows = db.execute("select key, name, summary, kind, icon, cats, sources from apps").fetchall()
    db.close()
    out = []
    for key, name, summary, kind, icon, cats, sources in rows:
        srcs = json.loads(sources)
        on = [s["type"] for s in srcs if (s["type"] == "pacman" and s["ref"] in pm) or (s["type"] == "flatpak" and s["ref"] in fp)]
        hub_owned = any((s["type"], s["ref"]) in mine and s["type"] in on for s in srcs)
        if on and (kind in ("app", "cli") or hub_owned):
            srcs.sort(key=lambda s: TRUST_ORDER.get(s["trust"], 9))
            out.append({"id": key, "name": name, "summary": summary, "kind": kind,
                        "icon": FLATHUB_ICON + icon if icon else "", "categories": json.loads(cats),
                        "sources": srcs, "installed": sorted(set(on))})
    out.sort(key=lambda a: a["name"].lower())
    return out


def run_names(argv):
    """Names printed one per line by a read-only listing command; a missing tool means none installed."""
    try:
        r = subprocess.run(argv, capture_output=True, text=True, timeout=60, env={**os.environ, "LC_ALL": "C"})
    except (OSError, subprocess.SubprocessError):
        return []
    return [l.strip() for l in r.stdout.splitlines() if l.strip()] if r.returncode == 0 else []


# ---- commands ----------------------------------------------------------------------------------
def refresh(force=False, runner=run_pacman, opener=urllib.request.urlopen):
    base = cache_dir()
    xml = os.path.join(base, "appstream.xml.gz")
    if force and os.path.exists(xml):
        os.utime(xml, (0, 0))
    state = fetch_flathub(xml, opener=opener)
    with gzip.open(xml, "rb") as fh:
        flathub = list(parse_flathub(fh))
    pacman = parse_pacman_search(runner(["-Ss", ""]))
    n = build_index(os.path.join(base, "index.sqlite"), flathub, pacman, load_distro_map())
    return {"flathub": state, "apps": n}


def main(argv):
    if len(argv) >= 2 and argv[1] == "refresh":
        print(json.dumps(refresh(force="--force" in argv)))
        return 0
    if len(argv) >= 3 and argv[1] == "search":
        db = os.path.join(cache_dir(), "index.sqlite")
        if not index_ok(db):
            refresh()
        print(json.dumps({"results": search(db, " ".join(argv[2:]))}))
        return 0
    if len(argv) >= 2 and argv[1] == "installed":
        db = os.path.join(cache_dir(), "index.sqlite")
        if not index_ok(db):
            refresh()
        apps = installed_apps(db, run_names(["pacman", "-Qq"]), run_names(["flatpak", "list", "--app", "--columns=application"]),
                              load_record(state_path()))
        print(json.dumps({"results": apps}))
        return 0
    if len(argv) == 5 and argv[1] == "record":
        try:
            print(json.dumps({"recorded": record(argv[2], argv[3], argv[4])}))
            return 0
        except ValueError as e:
            print(str(e), file=sys.stderr)
            return 2
    print("usage: axiom-hub refresh [--force] | search <query> | installed | record <install|remove> <pacman|flatpak> <ref>", file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
