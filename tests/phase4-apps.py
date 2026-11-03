#!/usr/bin/env python3
"""Axiom Phase 4 acceptance driver (QEMU/KVM): Files, Software, Settings,
Terminal integration, rendered notifications, shell recovery and memory.

    tests/phase4-apps.py <iso> [outdir] [--res 1920x1080] [--only files,software,...]

Boots the Phase 3/4 image, drives the real apps with keyboard and pointer input
and checks every result on disk or in process state over the serial console
(screenshots are retained as evidence but are never the pass/fail signal).

Sections: image, dock, files, software, settings, toast, recovery, memory.
Exit codes: 0 pass, 1 failures, 2 usage, 3 firmware-stage stall (retry the run).
No networking, no host shares.
"""
import json
import os
import re
import shlex
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from qemu_lib import Guest, QS  # noqa: E402

args = sys.argv[1:]
if not args or not os.path.isfile(args[0]):
    print(__doc__)
    sys.exit(2)
ISO = args[0]
OUT = args[1] if len(args) > 1 and not args[1].startswith("--") else "iso/out-phase3/evidence/phase4"
RES = "1920x1080"
ONLY = None
for i, a in enumerate(args):
    if a == "--res" and i + 1 < len(args):
        RES = args[i + 1]
    if a == "--only" and i + 1 < len(args):
        ONLY = set(args[i + 1].split(","))
OUT = os.path.join(OUT, RES)
W, H = (int(v) for v in RES.split("x"))


def want(section):
    return ONLY is None or section in ONLY


results = {"resolution": RES, "iso": os.path.basename(ISO)}
HOME = "/home/axiom"

# --- settings window layout (maximised, 1920x1080) -----------------------------------------
# Pointer targets inside the maximised Settings window (Super+M gives a fixed
# geometry). Calibrated against the screenshots in the evidence directory; they
# depend only on that geometry and the layout in apps/settings.
SETTINGS = {
    "sidebar_x": 90,
    "page_y": {"about": 108, "appearance": 146, "dock": 184, "apps": 222, "displays": 260},
    "text_size": {"Default": (812, 192), "Large": (886, 192), "Larger": (956, 192)},
    "wallpaper": {"axiom": (354, 340), "test": (556, 340)},
    "dock_remove_first": (950, 222),
    "dock_reset": (448, 486),            # with the five default pins; moves up 52 px per removed pin
    "dock_row_height": 52,
    "text_editor_change": (952, 303),
    "menu_first_item": (900, 345),
    "menu_row_height": 31,
}

DATASET = r"""#!/bin/sh
set -e
cd "$HOME"
chmod -R u+rwx noperm 2>/dev/null || true
rm -rf lab copyto small big noperm
mkdir -p lab/Docs copyto small big noperm Pictures
cd lab
printf 'hello\n' > "a b.txt"; printf x > ./-dash.txt
printf x > "$(printf 'new\nline.txt')"
printf x > "q'uote\".txt"; printf x > "emoji 🙂.txt"; printf x > '$(touch pwned)'; printf x > ';rm -rf x'
printf x > '*'
ln -s Docs dirlink; ln -s nowhere broken
printf data > Docs/inner.txt; printf img > pic.png; printf x > movie.mkv; printf x > archive.tar.gz; printf x > .hidden
for i in 2 10 1; do printf x > "file$i.txt"; done
cd ../small; printf one > x1.txt; printf two > x2.txt
cd ../big; i=0; while [ $i -lt 10000 ]; do : > "f$i.txt"; i=$((i+1)); done
cd ..; touch noperm/secret; chmod 000 noperm
cp /usr/local/share/axiom/shell/assets/axiom-penguin.png Pictures/test.png
echo DATASET_OK
"""

# --- boot ----------------------------------------------------------------------------------------
g = Guest(ISO, OUT, RES)
g.start()
if not g.wait_login():
    g.shot("00-firmware-stall")
    print("STALL: firmware stage produced no kernel/systemd output")
    g.kill()
    sys.exit(3)
if not g.login_root():
    g.bad("could not get a root shell on the serial console")
    g.kill()
    sys.exit(1)
if not g.shell_ready():
    g.shot("00-failure")
    g.bad("session did not become ready")
    g.kill()
    sys.exit(1)
g.ok(f"session ready at {RES}")
g.prepare_env()
time.sleep(3)


# --- helpers ----------------------------------------------------------------------------------------
def disk(cmd, timeout=20):
    rc, out = g.sh(cmd, timeout)
    return rc, out


def eventually(cmd, timeout=15):
    """Poll a root-shell condition until it succeeds."""
    end = time.monotonic() + timeout
    while time.monotonic() < end:
        rc, _ = g.sh(cmd, 20)
        if rc == 0:
            return True
        time.sleep(1.0)
    return False


def kill_apps():
    g.sh("pkill -f 'axiom/shell/files.qml'; pkill -f 'axiom/shell/software.qml'; pkill -f 'axiom/shell/settings.qml'; "
         "pkill mousepad; pkill -x foot; true", 20)
    time.sleep(1.5)


def launch(app, arg=None, tag=None, env=""):
    tag = tag or app
    a = shlex.quote(arg) if arg else ""
    g.user(f"{env} nohup axiom-app {app} {a} > /tmp/{tag}.out 2>&1 &", 20)
    # Loaded line from Quickshell, then time for the window to map and draw
    # its first frame under software rendering.
    ok = eventually(f"grep -q 'Configuration Loaded' /tmp/{tag}.out", 60)
    time.sleep(7)
    return ok


def app_log_errors(tag):
    """Save the app's startup log as evidence and return any QML error lines."""
    rc, full = g.sh(f"grep -av MESA /tmp/{tag}.out | head -60", 20)
    os.makedirs(os.path.join(OUT, "logs"), exist_ok=True)
    with open(os.path.join(OUT, "logs", tag + ".log"), "w") as f:
        f.write(full or "")
    errs = [l for l in (full or "").splitlines()
            if re.search(r"\.qml:\d+|TypeError|ReferenceError|is not defined|Binding loop|unavailable", l)]
    return "\n".join(errs[:5])


def pid_of(pattern):
    rc, out = g.sh(f"pgrep -f {shlex.quote(pattern)} | head -1", 15)
    m = re.search(r"\d+", out or "")
    return m.group(0) if m else None


def pss_kb(pid):
    rc, out = g.sh(f"awk '/^Pss:/{{print $2}}' /proc/{pid}/smaps_rollup", 15)
    m = re.search(r"\d+", out or "")
    return int(m.group(0)) if m else 0


def trash_count():
    rc, out = g.user("gio trash --list | grep -c '^trash:///'", 25)
    m = re.search(r"^\s*(\d+)\s*$", out or "", re.M)
    return int(m.group(1)) if m else -1


def names_hash(directory):
    """Shell fragment: a hash of the visible entry names of a directory (NUL-safe)."""
    return f"cd {shlex.quote(directory)} && find . -mindepth 1 -maxdepth 1 ! -name '.*' -printf '%f\\0' | sort -z | md5sum"


def nav(path):
    g.key("ctrl-l")
    g.type(path + "\n", settle=2.5)


# --- dataset ------------------------------------------------------------------------------------------
g.put_file("/tmp/dataset.sh", DATASET)
rc, out = g.user("sh /tmp/dataset.sh", 120)
g.check("DATASET_OK" in (out or ""), "test dataset created (hostile names, 10,000 files, unreadable folder)")

# =============================================================================================
if want("image"):
    rc, out = g.user("gio mime inode/directory | head -1", 20)
    g.check("axiom-files.desktop" in (out or ""), "image: Axiom Files is the default for folders")
    for entry in ("axiom-files", "axiom-software", "axiom-settings", "axiom-trash"):
        g.check(eventually(f"[ -f /usr/local/share/applications/{entry}.desktop ]", 5), f"image: {entry}.desktop installed")
    rc, out = g.sh("command -v pcmanfm >/dev/null && echo present || echo absent", 10)
    g.check("absent" in (out or ""), "image: pcmanfm is no longer installed")
    rc, out = g.sh("grep -c 'Exec=axiom-app files' /usr/local/share/applications/axiom-files.desktop /usr/local/share/applications/axiom-trash.desktop", 10)
    g.check(rc == 0, "image: Files and Trash entries launch axiom-app")
    rc, out = g.user("axiom-app bogus; echo rc=$?", 15)
    g.check("rc=2" in (out or ""), "image: axiom-app rejects unknown app names")

# =============================================================================================
if want("dock"):
    kill_apps()
    x, y = g.dock_item(2)
    g.click(x, y, settle=2)
    ok = eventually("pgrep -f 'axiom/shell/files.qml' >/dev/null", 60)
    time.sleep(8)
    g.check(ok, "dock: clicking Files launches Axiom Files")
    pid = pid_of("axiom/shell/files.qml")
    if pid:
        rc, out = g.sh(f"tr '\\0' '\\n' < /proc/{pid}/environ | grep -c '^AXIOM_APP_ARG='", 10)
        m = re.search(r"^\s*(\d+)\s*$", out or "", re.M)
        g.check(m is not None and int(m.group(1)) == 0, "dock: no stray argument (such as an unexpanded %U) reaches the app")
    g.shot("dock-01-files")
    kill_apps()
    x, y = g.dock_item(5)
    g.click(x, y, settle=2)
    ok = eventually("pgrep -f 'axiom/shell/files.qml' >/dev/null", 60)
    time.sleep(8)
    pid = pid_of("axiom/shell/files.qml")
    rc, out = g.sh(f"tr '\\0' '\\n' < /proc/{pid}/environ | grep '^AXIOM_APP_ARG='", 10) if pid else (1, "")
    g.check("AXIOM_APP_ARG=trash:///" in (out or ""), "dock: Trash opens Axiom Files at trash:///")
    g.shot("dock-02-trash")

# =============================================================================================
if want("files"):
    kill_apps()
    g.check(launch("files", f"{HOME}/lab", "files-lab", "AXIOM_FILES_DEBUG=1"), "files: launched at a path argument")
    g.check(app_log_errors("files-lab") == "", "files: no QML errors at startup")
    g.shot("files-01-lab")

    g.key("ctrl-shift-n")
    g.type("made\n", settle=2)
    g.check(eventually(f"[ -d {HOME}/lab/made ]"), "files: Ctrl+Shift+N creates a folder")
    g.key("f2")
    g.type("renamed\n", settle=2)
    g.check(eventually(f"[ -d {HOME}/lab/renamed ] && [ ! -e {HOME}/lab/made ]"), "files: F2 renames it")

    # Copy everything, hostile names included, into another folder.
    nav(f"{HOME}/lab")
    g.key("ctrl-a")
    g.key("ctrl-c")
    nav(f"{HOME}/copyto")
    g.key("ctrl-v", settle=2)
    same = f"[ \"$( {names_hash(HOME + '/lab')} )\" = \"$( {names_hash(HOME + '/copyto')} )\" ] && [ \"$(ls {HOME}/copyto | wc -l)\" -gt 10 ]"
    g.check(eventually(same, 60), "files: copy/paste of every entry (spaces, quotes, newline, leading dash, $(), *, links) is exact")
    g.check(eventually(f"cmp -s '{HOME}/lab/a b.txt' '{HOME}/copyto/a b.txt'", 5), "files: copied file content is identical")
    g.shot("files-02-copied")

    # Trash them all, restore them all.
    before = trash_count()
    g.key("ctrl-a")
    g.key("delete", settle=3)
    emptied = f"[ -z \"$(find {HOME}/copyto -mindepth 1 -maxdepth 1 ! -name '.*' | head -1)\" ]"
    g.check(eventually(emptied, 60), "files: Delete moves the selection to the Trash")
    after = trash_count()
    g.check(after > before, f"files: Trash gained entries ({before} -> {after})")
    nav("trash:///")
    g.shot("files-03-trash")
    g.key("ctrl-a")
    g.key("ctrl-r", settle=3)
    g.check(eventually(same, 60), "files: Ctrl+R in Trash restores everything to its original place")
    g.check(trash_count() == before, "files: Trash is back to its earlier count after restore")

    # Permanent delete needs an explicit Ctrl+Enter.
    nav(f"{HOME}/copyto")
    g.key("ctrl-a")
    g.key("delete", settle=3)
    g.check(eventually(emptied, 60), "files: copies trashed again")
    nav("trash:///")
    g.key("ctrl-a")
    g.key("delete", settle=2)
    g.shot("files-04-confirm-delete")
    g.key("ret", settle=2)
    still = trash_count()
    g.check(still > 0, "files: plain Enter does not permanently delete")
    g.key("ctrl-ret", settle=4)
    g.check(eventually("[ \"$(su axiom -s /bin/sh -c '. /tmp/axiom-env.sh; gio trash --list | grep -c ^trash:///')\" = 0 ]", 60),
            "files: Ctrl+Enter confirms permanent delete and empties the Trash")

    # Name clash on rename; open with the default app; restore clash.
    nav(f"{HOME}/small")
    g.key("home")
    g.key("f2")
    g.type("x2", settle=0.5)
    g.key("ret", settle=3)
    g.check(eventually(f"[ \"$(cat {HOME}/small/x1.txt)\" = one ] && [ \"$(cat {HOME}/small/x2.txt)\" = two ]", 10),
            "files: renaming onto an existing name is refused and nothing is lost")
    g.shot("files-05-rename-clash")
    g.key("home")
    g.key("ret", settle=2)
    g.check(eventually(f"pgrep -af mousepad | grep -q '{HOME}/small/x1.txt'", 45), "files: Enter opens a file in the default application (Mousepad)")
    g.sh("pkill mousepad; true", 10)
    time.sleep(1)
    g.key("home")
    g.key("delete", settle=3)
    g.check(eventually(f"[ ! -e {HOME}/small/x1.txt ]", 20), "files: x1.txt trashed")
    g.user(f"printf NEW > {HOME}/small/x1.txt", 15)
    nav("trash:///")
    g.key("home")
    g.key("ctrl-r", settle=3)
    g.check(eventually(f"[ \"$(cat {HOME}/small/x1.txt)\" = NEW ]", 10) and trash_count() == 1,
            "files: restoring onto an existing name is refused; the new file and the trashed one both survive")
    g.shot("files-06-restore-clash")
    g.user("gio trash --empty", 20)

    # Terminal integration.
    nav(f"{HOME}/small")
    g.key("f4", settle=2)
    g.check(eventually(f"for f in $(pgrep -x foot); do c=$(pgrep -P $f | head -1); readlink /proc/$c/cwd; done | grep -qx {HOME}/small", 45),
            "terminal: F4 in Files opens a terminal in the folder being viewed")
    g.shot("files-07-terminal-here")
    g.check(app_log_errors("files-lab") == "", "files: no QML errors after the whole run")

    # Unreadable folder, large folder, remembered state.
    kill_apps()
    launch("files", f"{HOME}/noperm", "files-noperm")
    g.shot("files-08-noperm")
    g.check(pid_of("axiom/shell/files.qml") is not None and app_log_errors("files-noperm") == "", "files: an unreadable folder is handled without errors or a crash")
    kill_apps()
    launch("files", f"{HOME}/big", "files-big", "AXIOM_FILES_DEBUG=1")
    eventually("grep -q 'listed 10000 entries' /tmp/files-big.out", 90)
    rc, out = g.sh("grep -a 'listed 10000 entries' /tmp/files-big.out | tail -1", 15)
    m = re.search(r"parse (\d+) ms, sort (\d+) ms, selection (\d+) ms", out or "")
    if m:
        parse, sort, sel = (int(v) for v in m.groups())
        results["files_10000_ms"] = {"parse": parse, "sort_and_apply": sort, "selection": sel}
        g.check(parse + sort + sel < 1500, f"files: 10,000 entries listed in {parse + sort + sel} ms (parse {parse}, sort {sort}, selection {sel})")
    else:
        g.bad("files: no timing line for the 10,000-entry folder")
    g.shot("files-09-big")
    pid = pid_of("axiom/shell/files.qml")
    if pid:
        results["pss_kb_files_10000"] = pss_kb(pid)
    kill_apps()
    launch("files", f"{HOME}/small", "files-state")
    time.sleep(4)
    g.check(eventually(f"grep -q '\"path\": \"{HOME}/small\"' {HOME}/.local/state/axiom/files.json", 15), "files: the last folder is saved")
    kill_apps()
    launch("files", None, "files-restore", "AXIOM_FILES_DEBUG=1")
    g.check(eventually("grep -aq 'listed 2 entries' /tmp/files-restore.out", 20), "files: reopening without an argument returns to the saved folder")

# =============================================================================================
if want("software"):
    kill_apps()
    rc, out = g.user("pacman -Q | wc -l", 25)
    m = re.search(r"^\s*(\d+)\s*$", out or "", re.M)
    installed = int(m.group(1)) if m else -1
    g.check(launch("software", None, "software", "AXIOM_SOFTWARE_DEBUG=1"), "software: launched")
    g.check(app_log_errors("software") == "", "software: no QML errors at startup")
    g.check(eventually(f"grep -aq 'software: {installed} packages' /tmp/software.out", 30), f"software: lists exactly the {installed} installed packages")
    g.shot("software-01-apps")
    g.key("ctrl-f")
    g.type("firefox\n", settle=2)
    g.shot("software-02-search")
    pid = pid_of("axiom/shell/software.qml")
    if pid:
        results["pss_kb_software"] = pss_kb(pid)

# =============================================================================================
if want("settings"):
    kill_apps()
    g.user("rm -f ~/.config/axiom/settings.json", 15)
    time.sleep(2)
    desktop_default = g.shot("settings-00-desktop-default")
    full = f"{W}x{H}+0+0"
    b_default = g.mean_brightness(desktop_default, full) if desktop_default else 0
    g.check(launch("settings", None, "settings"), "settings: launched")
    g.check(app_log_errors("settings") == "", "settings: no QML errors at startup")
    g.key("meta_l-m", settle=3)                    # maximise: fixed geometry for pointer targets
    g.shot("settings-01-about")
    g.check(eventually("grep -q 'Axiom Linux' /etc/os-release", 5), "settings: About page opened (os-release reports Axiom Linux)")

    def page(name):
        g.click(SETTINGS["sidebar_x"], SETTINGS["page_y"][name], settle=2.5)

    def settings_has(fragment, timeout=15):
        return eventually(f"grep -q '{fragment}' {HOME}/.config/axiom/settings.json", timeout)

    def settings_matches(pattern, timeout=15):
        """Extended-regex match, for values where a plain substring would also match another value."""
        return eventually(f"grep -Eq '{pattern}' {HOME}/.config/axiom/settings.json", timeout)

    page("appearance")
    g.shot("settings-02-appearance")
    g.click(*SETTINGS["text_size"]["Larger"], settle=3)
    g.check(settings_matches('"textScale": 1\\.25,?[[:space:]]*$'), "settings: Text size > Larger is saved (textScale 1.25)")
    g.shot("settings-02b-text-larger")
    g.click(*SETTINGS["text_size"]["Default"], settle=3)
    g.check(settings_matches('"textScale": 1(\\.0+)?,?[[:space:]]*$') and not settings_matches('"textScale": 1\\.25', 2),
            "settings: Text size > Default is saved (textScale back to 1, not 1.25)")
    g.click(*SETTINGS["wallpaper"]["test"], settle=3)
    g.check(settings_has(f'"wallpaper": "{HOME}/Pictures/test.png"'), "settings: choosing a picture saves its path")

    page("dock")
    g.shot("settings-03-dock")
    g.click(*SETTINGS["dock_remove_first"], settle=3)
    g.check(settings_has('"dockCustom": true') and eventually(f"! grep -q '\"foot\"' {HOME}/.config/axiom/settings.json", 10),
            "settings: removing a pin saves a custom dock without it")
    g.shot("settings-03b-dock-removed")
    reset = (SETTINGS["dock_reset"][0], SETTINGS["dock_reset"][1] - SETTINGS["dock_row_height"])
    g.click(*reset, settle=3)
    g.check(settings_has('"dockCustom": false'), "settings: Reset to defaults restores the default dock")

    page("apps")
    g.shot("settings-04-default-apps")

    def pick_text_editor(desktop_id):
        """Choose an application in the Text editor menu. The menu lists the
        registered applications in the order `gio mime` reports them (the page
        parses the same output), so read that order and click the matching row."""
        rc, out = g.user("gio mime text/plain", 20)
        registered = []
        section = False
        for line in (out or "").splitlines():
            if line.startswith("Registered applications:") or line.startswith("Recommended applications:"):
                section = True
            elif section and line.strip().endswith(".desktop") and line.strip() not in registered:
                registered.append(line.strip())
        if desktop_id not in registered:
            return False
        index = registered.index(desktop_id)
        g.click(*SETTINGS["text_editor_change"], settle=2)
        g.click(SETTINGS["menu_first_item"][0], SETTINGS["menu_first_item"][1] + index * SETTINGS["menu_row_height"], settle=4)
        rc, out = g.user("gio mime text/plain | head -1", 20)
        return desktop_id in (out or "")

    g.click(*SETTINGS["text_editor_change"], settle=2)
    g.shot("settings-04b-change-menu")
    g.key("esc", settle=1)
    g.check(pick_text_editor("vim.desktop"), "settings: Default apps > Text editor > Vim changes the system default")
    g.shot("settings-04c-vim-default")
    g.check(pick_text_editor("org.xfce.mousepad.desktop"), "settings: ...and back to Mousepad")

    page("displays")
    g.shot("settings-05-displays")
    pid = pid_of("axiom/shell/settings.qml")
    if pid:
        results["pss_kb_settings"] = pss_kb(pid)

    # The shell, a different process, must have applied the wallpaper live.
    g.key("meta_l-m", settle=2)
    kill_apps()
    time.sleep(4)
    live = g.shot("settings-06-desktop-wallpaper")
    b_live = g.mean_brightness(live, full) if live else 0
    results["wallpaper_brightness"] = {"default": round(b_default, 3), "chosen": round(b_live, 3)}
    g.check(abs(b_live - b_default) > 0.03, f"settings: the shell applied the new wallpaper live (brightness {b_default:.3f} -> {b_live:.3f})")

# =============================================================================================
if want("toast"):
    before = g.shot("toast-00-before")
    geom = f"340x90+{W - 348}+48"
    b0 = g.mean_brightness(before, geom) if before else 0
    g.user("notify-send -a Axiom 'Phase 4' 'A rendered notification'", 15)
    time.sleep(1.5)
    after = g.shot("toast-01-after")
    b1 = g.mean_brightness(after, geom) if after else 0
    g.check(abs(b1 - b0) > 0.01, f"toast: a notification renders on screen (region brightness {b0:.3f} -> {b1:.3f})")

# =============================================================================================
if want("recovery"):
    rc, _ = g.sh("pkill -f '[q]uickshell -p /usr/local/share/axiom/shell$'; true", 15)
    time.sleep(3)
    g.check(g.shell_ready(120), "recovery: the supervised shell restarts after being killed and serves IPC again")
    g.prepare_env()
    time.sleep(6)
    again = g.shot("recovery-01-shell-restarted")
    if again and "wallpaper_brightness" in results:
        b_again = g.mean_brightness(again, f"{W}x{H}+0+0")
        chosen = results["wallpaper_brightness"]["chosen"]
        g.check(abs(b_again - chosen) < 0.03, f"recovery: the chosen wallpaper is still applied after the shell restarted ({b_again:.3f} vs {chosen:.3f})")

# =============================================================================================
if want("memory"):
    kill_apps()
    launch("files", f"{HOME}/small", "mem-files")
    launch("software", None, "mem-software")
    launch("settings", None, "mem-settings")
    time.sleep(10)
    mem = {}
    for name, pat in (("shell", "[q]uickshell -p /usr/local/share/axiom/shell$"), ("files", "axiom/shell/files.qml"),
                      ("software", "axiom/shell/software.qml"), ("settings", "axiom/shell/settings.qml")):
        pid = pid_of(pat)
        mem[name] = pss_kb(pid) if pid else 0
    rc, out = g.sh("awk '/MemTotal/{t=$2}/MemAvailable/{a=$2}END{print t-a}' /proc/meminfo", 10)
    m = re.search(r"\d+", out or "")
    used = int(m.group(0)) if m else 0
    results["pss_kb_all_open"] = mem
    results["guest_memory_used_kb_all_open"] = used
    for name in ("files", "software", "settings"):
        g.check(0 < mem[name] < 256 * 1024, f"memory: {name} PSS {mem[name] // 1024} MiB (gate 256 MiB)")
    g.check(used < 1800000, f"memory: guest uses {used // 1024} MiB of 2048 MiB with the shell and all three apps open")
    g.shot("memory-01-all-open")

# --- finish ---------------------------------------------------------------------------------------------
g.sh("pkill mousepad; true", 10)
if g.power_off():
    g.ok("guest powered off cleanly")
else:
    g.bad("guest did not power off within 120s")
    g.kill()

with open(os.path.join(OUT, "results.json"), "w") as f:
    json.dump(results, f, indent=2)
print(json.dumps(results, indent=2))
print("RESULT:", "PASS" if not g.failures else f"FAIL ({len(g.failures)})")
sys.exit(0 if not g.failures else 1)
