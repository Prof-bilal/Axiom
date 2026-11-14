#!/usr/bin/env python3
"""Build docs/hub/<id>.md for every Axiom Hub catalog app.

Joins: apps/hub/catalog.js (what the Hub ships), research/hub/details/<id>.md
(overview, facts, screenshots), research/hub/install/<id>.md (install options,
manual steps, errors; mostly unverified drafts), research/hub/logos/*.md (logo
URLs), research/hub/flathub.json (screenshots, version and licence from the
Flathub appstream API), research/hub/verified.json (install commands checked against a source in
this session), and apps/hub/icons/<id>.png (the bundled icon). Also writes
docs/hub/README.md, an index of what is verified and what is still missing.

Run: python3 scripts/gen-hub-docs.py
"""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
RES = ROOT / "research" / "hub"
OUT = ROOT / "docs" / "hub"


def catalog():
    s = (ROOT / "apps/hub/catalog.js").read_text()
    return json.loads(s[s.index("[", s.index("var CATALOG")):])


def sections(path):
    """Map '## Heading' -> body text for one markdown file ({} if missing)."""
    if not path.exists():
        return {}
    out, cur = {}, None
    for line in path.read_text().splitlines():
        m = re.match(r"^##\s+(.*)", line)
        if m:
            cur = m.group(1).strip()
            out[cur] = []
        elif cur:
            out[cur].append(line)
    return {k: "\n".join(v).strip() for k, v in out.items()}


def status_line(path):
    if not path.exists():
        return ""
    m = re.search(r"^Status:\s*(.*)$", path.read_text(), re.M)
    return m.group(1).strip() if m else ""


def logos():
    """id -> (url, status) from the Flathub index and the press-kit check."""
    found = {}
    for name in ("index.md", "press-kit.md"):
        p = RES / "logos" / name
        if not p.exists():
            continue
        for line in p.read_text().splitlines():
            parts = [x.strip() for x in line.strip().strip("|").split("|")]
            if len(parts) < 3 or not re.fullmatch(r"[a-z0-9]+", parts[0]):
                continue
            url = parts[1]
            st = parts[-1] if name == "press-kit.md" else ("verified-200" if url.startswith("http") else "not-found")
            if not url.startswith("http"):
                st = "not-found"
            if parts[0] not in found or found[parts[0]][1] != "verified-200":
                found[parts[0]] = (url, st)
    return found


def screenshot_count(text):
    return len(re.findall(r"!\[[^\]]*\]\(http", text or ""))


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    verified = json.loads((RES / "verified.json").read_text()) if (RES / "verified.json").exists() else {}
    flathub = json.loads((RES / "flathub.json").read_text()) if (RES / "flathub.json").exists() else {}
    logo = logos()
    rows = []
    hub_details = {}
    for a in catalog():
        i = a["id"]
        det = sections(RES / "details" / f"{i}.md")
        ins = sections(RES / "install" / f"{i}.md")
        icon = ROOT / "apps/hub/icons" / f"{i}.png"
        fh = flathub.get(i) if "error" not in flathub.get(i, {"error": 1}) else None
        fh_shots = fh["screenshots"] if fh else []
        shots = max(screenshot_count(det.get("Screenshots")), len(fh_shots))
        v = verified.get(i)
        lg = logo.get(i, ("", "not-found"))
        has_logo = icon.exists() or lg[1] == "verified-200"

        md = [f"# {a['name']}", ""]
        md.append(f"- Id: `{i}` · Category: {a['category']} · Weight: {a['weight']} · Licence (catalog): {a['license']}")
        md.append(f"- Catalog sources: " + ", ".join(f"{s['type']} `{s['ref']}`" for s in a["sources"]))
        md.append(f"- Install verified: {'yes' if v else 'no'} · Screenshots: {shots} of 3 · Logo: {'yes' if has_logo else 'no'}")
        md += ["", "## Overview", det.get("Overview") or a["summary"], ""]
        md += ["## Facts", det.get("Facts") or "Not researched yet.", ""]
        if fh:
            md += ["Flathub data (" + fh["source"] + "):",
                   f"- Flatpak id: `{fh['ref']}` · Developer: {fh.get('developer') or 'n/a'} · Licence: {fh.get('license') or 'n/a'}",
                   f"- Latest version on Flathub: {fh.get('version') or 'n/a'} (released {fh.get('released') or 'n/a'})" + (" · END OF LIFE on Flathub" if fh.get("end_of_life") else ""),
                   ""]
        md.append("## Logo")
        if icon.exists():
            md.append(f"Bundled icon: `apps/hub/icons/{i}.png`.")
        if lg[0].startswith("http"):
            md.append(f"Official logo: {lg[0]} ({lg[1]}).")
        if not has_logo:
            md.append("Not found. The Hub shows a letter tile.")
        md += ["", "## Screenshots"]
        if fh_shots:
            md += [f"![{x.get('caption') or a['name'] + ' screenshot ' + str(n + 1)}]({x['url']})" for n, x in enumerate(fh_shots)]
            md += [f"Source: {fh['source']}", ""]
        if det.get("Screenshots") and not (fh_shots and "Not found" in det.get("Screenshots")):
            md += [det["Screenshots"], ""]
        elif not fh_shots:
            md += ["Not found.", ""]
        md.append("## Install (verified against a source)")
        if v:
            md += ["| Method | Command | Needs root |", "|---|---|---|"]
            md += [f"| {m['method']} | `{m['command']}` | {m['root']} |" for m in v["methods"]]
            md += [""] + [f"- {n}" for n in v.get("notes", [])]
            md += [""] + [f"- Source: {s}" for s in v.get("sources", [])]
        else:
            md.append("Not verified yet. Use the draft below only after checking it.")
        md.append("")
        st = status_line(RES / "install" / f"{i}.md")
        md.append("## Install options (research draft" + (f"; {st}" if st else "") + ")")
        md += [ins.get("Install options") or "Not researched yet.", ""]
        if ins.get("Manual install"):
            md += ["## Manual install (draft)", ins["Manual install"], ""]
        md += ["## Possible errors and fixes (draft)", ins.get("Possible errors and fixes") or "Not researched yet.", ""]
        srcs = sorted(set(re.findall(r"https?://\S+", (det.get("Sources") or "") + "\n" + (ins.get("Sources") or ""))))
        md += ["## Sources"] + [f"- {s.rstrip(').,')}" for s in srcs] + [""]
        (OUT / f"{i}.md").write_text("\n".join(md))
        use = sections(RES / "usage" / f"{i}.md")
        cj_path = RES / "commands" / f"{i}.json"
        cj = json.loads(cj_path.read_text()) if cj_path.exists() else None
        if v:
            cmds = [{"method": m["method"], "command": m["command"], "root": m["root"], "source": ""} for m in v["methods"]]
            cstatus = "Verified against an official source (install section above)."
        elif cj:
            cmds = [{"method": c["method"], "command": c["command"], "root": "yes" if c["needs_root"] else "no", "source": c["source"]} for c in cj["commands"]]
            cstatus = f"{cj['status'].capitalize()}: {cj['note']}"
        else:
            cmds, cstatus = [], "Not researched yet."
        hub_details[i] = {"overview": det.get("Overview", ""),
                          "shots": [{"url": x["url"], "caption": x.get("caption") or ""} for x in fh_shots]
                                   + [{"url": "screenshots/" + p.name, "caption": ""} for p in sorted((ROOT / "apps/hub/screenshots").glob(f"{i}-*"))],
                          "when": use.get("When to use", ""), "how": use.get("How it works", ""), "notFor": use.get("Not for", ""),
                          "commands": cmds, "commandsStatus": cstatus}
        rows.append((i, a["name"], a["category"], bool(v), shots, has_logo))

    (ROOT / "apps/hub/details.js").write_text(".pragma library\n\n// Generated by scripts/gen-hub-docs.py. Do not edit.\nvar DETAILS = "
                                              + json.dumps(hub_details, indent=1, ensure_ascii=False) + ";\n")
    done_v = sum(r[3] for r in rows)
    done_s = sum(r[4] >= 3 for r in rows)
    done_l = sum(r[5] for r in rows)
    idx = ["# Axiom Hub app docs", "",
           f"{len(rows)} apps. Install verified: {done_v}. Three or more screenshots: {done_s}. Logo: {done_l}.",
           "", "Generated by `scripts/gen-hub-docs.py` from `research/hub/`. Do not edit the app files by hand.", "",
           "| App | Category | Install verified | Screenshots | Logo |", "|---|---|---|---|---|"]
    idx += [f"| [{n}]({i}.md) | {c} | {'yes' if v else 'no'} | {s} | {'yes' if l else 'no'} |" for i, n, c, v, s, l in rows]
    (OUT / "README.md").write_text("\n".join(idx) + "\n")
    print(f"wrote {len(rows)} app docs; install verified {done_v}, screenshots>=3 {done_s}, logo {done_l}")


if __name__ == "__main__":
    main()
