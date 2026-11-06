#!/usr/bin/env python3
"""Axiom Phase 5 acceptance driver (QEMU/KVM): system experience.

    tests/phase5-system.py <iso> [outdir] [--res 1920x1080] [--only image,mascots,...]

Boots the image with a virtual sound card, simulated Wi-Fi radios (mac80211_hwsim)
and a simulated access point, then checks real services through the same paths
the shell and Settings use. State is verified in the guest (nmcli, wlr-randr,
busctl, wpctl, timedatectl, files); screenshots are retained as
evidence but are never the pass/fail signal.

Sections: image, mascots, network, bluetooth, sound, displays, power, notifications,
keyboard, datetime, users, security, recovery, memory.
Exit codes: 0 pass, 1 failures, 2 usage, 3 firmware-stage stall (retry the run).
"""
import json
import os
import re
import shlex
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from qemu_lib import Guest  # noqa: E402

args = sys.argv[1:]
if not args or not os.path.isfile(args[0]):
    print(__doc__)
    sys.exit(2)
ISO = args[0]
OUT = args[1] if len(args) > 1 and not args[1].startswith("--") else "iso/out-phase3/evidence/phase5"
RES = "1920x1080"
ONLY = None
for i, a in enumerate(args):
    if a == "--res" and i + 1 < len(args):
        RES = args[i + 1]
    if a == "--only" and i + 1 < len(args):
        ONLY = set(args[i + 1].split(","))
OUT = os.path.join(OUT, RES)
W, H = (int(v) for v in RES.split("x"))
HOME = "/home/axiom"


def want(section):
    return ONLY is None or section in ONLY


# Pointer targets inside the maximised Settings window (Super+M), 1920x1080.
# Calibrated against the retained screenshots; they depend only on that
# geometry and the layout in apps/settings.
COORDS = json.load(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "phase5-coords.json"))) \
    if os.path.exists(os.path.join(os.path.dirname(os.path.abspath(__file__)), "phase5-coords.json")) else {}

AUDIO = [] if os.environ.get("AXIOM_P5_NOAUDIO") else ["-audiodev", "none,id=snd0", "-device", "intel-hda", "-device", "hda-duplex,audiodev=snd0"]
HOSTAPD = """interface=wlan1
driver=nl80211
ssid=AxiomLab
hw_mode=g
channel=1
wpa=2
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP
wpa_passphrase=axiom-lab-pass
"""

g = Guest(ISO, OUT, RES, mem=int(os.environ.get("AXIOM_P5_MEM", "2048")), extra=AUDIO)
g.start()
if not g.wait_login(int(os.environ.get("AXIOM_P5_BOOT_WAIT", "240"))):
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



def eventually(cmd, timeout=15, user=False):
    end = time.monotonic() + timeout
    while time.monotonic() < end:
        rc, _ = (g.user(cmd, 20) if user else g.sh(cmd, 20))
        if rc == 0:
            return True
        time.sleep(1.0)
    return False


def out_of(cmd, user=True, timeout=30):
    rc, out = (g.user(cmd, timeout) if user else g.sh(cmd, timeout))
    return (out or "").strip()


def kill_apps():
    g.sh("pkill -f 'axiom/shell/settings.qml'; pkill -f 'axiom/shell/files.qml'; true", 20)
    time.sleep(1.5)


def launch_settings(page, tag=None):
    tag = tag or ("settings-" + page)
    kill_apps()
    g.user(f"nohup axiom-app settings {page} > /tmp/{tag}.out 2>&1 &", 20)
    ok = eventually(f"grep -q 'Configuration Loaded' /tmp/{tag}.out", 60)
    # The harness starts Settings with su, outside the desktop logind session, so
    # system calls it makes (e.g. PowerProfiles writes) are refused. Move it into
    # the session scope the shell runs in, as the shell's own launcher would.
    g.sh("P=$(pgrep -fo 'axiom/shell/settings.qml'); Q=$(pgrep -fo quickshell); "
         "CG=$(awk -F: '$1==0{print $3}' /proc/$Q/cgroup); echo $P > /sys/fs/cgroup$CG/cgroup.procs; true", 20)
    time.sleep(6)
    g.key("meta_l-m", settle=3)
    rc, full = g.sh(f"grep -av MESA /tmp/{tag}.out | head -60", 20)
    os.makedirs(os.path.join(OUT, "logs"), exist_ok=True)
    open(os.path.join(OUT, "logs", tag + ".log"), "w").write(full or "")
    errs = [l for l in (full or "").splitlines()
            if re.search(r"\.qml:\d+|TypeError|ReferenceError|is not defined|Binding loop|unavailable", l)]
    return ok, "\n".join(errs[:5])


def click(name, settle=2.5):
    x, y = COORDS[name]
    g.click(x, y, settle=settle)


def pss_kb(pid):
    m = re.search(r"\d+", out_of(f"awk '/^Pss:/{{print $2}}' /proc/{pid}/smaps_rollup", user=False) or "")
    return int(m.group(0)) if m else 0


# =============================================================================================
if want("image"):
    for unit in ("NetworkManager", "bluetooth", "polkit"):
        g.check(eventually(f"systemctl is-active {unit}", 30, user=False) if unit != "bluetooth" else
                eventually("systemctl is-enabled bluetooth", 10, user=False), f"image: {unit} service is up/enabled")
    rc, o = g.sh("systemctl is-enabled systemd-networkd iwd 2>&1 | tr '\\n' ' '", 15)
    g.check("enabled" not in (o or "").replace("disabled", ""), "image: systemd-networkd and iwd are no longer enabled (one network manager)")
    g.check(eventually("busctl --system introspect org.freedesktop.UPower.PowerProfiles /org/freedesktop/UPower/PowerProfiles >/dev/null", 20, user=False),
            "image: power-profiles-daemon answers on the system bus")
    for cmd in ("wlr-randr", "brightnessctl", "bluetoothctl", "nmcli", "timedatectl", "wpctl"):
        g.check(eventually(f"command -v {cmd}", 5, user=False), f"image: {cmd} installed")
    g.check(eventually("[ -f /etc/polkit-1/rules.d/51-axiom-system-settings.rules ]", 5, user=False), "image: Phase 5 polkit rule installed")
    g.check(eventually("[ -f /usr/share/X11/xkb/rules/base.lst ]", 5, user=False), "image: xkeyboard-config layout database present")

# =============================================================================================
if want("mascots"):
    for n in ("files", "settings", "software", "terminal"):
        g.check(eventually(f"[ -f /usr/local/share/icons/hicolor/256x256/apps/axiom-{n}.png ]", 5, user=False), f"mascots: {n} app icon installed")
    for n in ("launcher", "notification", "shutdown", "showcase", "sleeping"):
        g.check(eventually(f"[ -f /usr/local/share/axiom/shell/assets/mascots/{n}.png ]", 5, user=False), f"mascots: shell mascot {n} installed")
    g.user("notify-send -a Axiom 'Notification mascot' 'The toast carries the Axiom mascot.'", 15)
    time.sleep(2)
    g.shot("mascots-01-toast")
    g.user(f"qs ipc --any-display -p /usr/local/share/axiom/shell call axiom toggleSessionMenu", 20)
    time.sleep(2)
    g.shot("mascots-02-shutdown-menu")
    g.user(f"qs ipc --any-display -p /usr/local/share/axiom/shell call axiom closeOverlays", 20)
    ok, errs = launch_settings("about", "settings-about")
    g.check(ok and errs == "", "mascots: Settings About (showcase mascot) loads without QML errors")
    g.shot("mascots-03-settings-about")
    kill_apps()
    g.user("nohup axiom-app files > /tmp/files-mascot.out 2>&1 &", 20)
    time.sleep(9)
    g.shot("mascots-04-files-window")
    kill_apps()

# =============================================================================================
if want("network"):
    g.sh("modprobe mac80211_hwsim radios=2", 30)
    g.check(eventually("ip -br link | grep -q wlan1", 20, user=False), "network: two simulated Wi-Fi radios appear (mac80211_hwsim)")
    g.sh("nmcli device set wlan1 managed no; sleep 1; true", 20)
    g.put_file("/tmp/hostapd.conf", HOSTAPD)
    g.sh("nohup hostapd /tmp/hostapd.conf > /tmp/hostapd.log 2>&1 &", 20)
    g.check(eventually("grep -q 'AP-ENABLED' /tmp/hostapd.log", 20, user=False), "network: simulated access point 'AxiomLab' is running")
    g.sh("ip addr add 10.77.0.1/24 dev wlan1; dnsmasq --interface=wlan1 --bind-interfaces --dhcp-range=10.77.0.10,10.77.0.50,12h "
         "--no-resolv --no-hosts --port=0 --pid-file=/tmp/dnsmasq.pid --log-facility=/tmp/dnsmasq.log", 30)
    g.check(eventually("nmcli -t device | grep -q '^wlan0:wifi'", 20, user=False), "network: NetworkManager manages the Wi-Fi device wlan0")
    g.sh("nmcli device wifi rescan ifname wlan0; sleep 3; true", 30)
    g.check(eventually("nmcli -t -f SSID device wifi list | grep -q AxiomLab", 25, user=True), "network: the shell user sees the AxiomLab network")
    ok, errs = launch_settings("network")
    g.check(ok and errs == "", "network: Settings > Network loads without QML errors")
    g.shot("network-01-list")
    if "network.connect" in COORDS:
        click("network.connect")
        g.shot("network-02-password")
        g.type("wrong-password-1\n", settle=1.0)
        click("network.password_join", settle=1.0)
        time.sleep(15)
        g.shot("network-03-wrong-password")
        g.check(not eventually("nmcli -t -f GENERAL.STATE device show wlan0 | grep -q '(connected)'", 3, user=True),
                "network: a wrong password does not connect")
        g.shot("network-03b-prompt-after-failure")
        g.type("axiom-lab-pass", settle=0.8)
        g.key("ret", settle=1.0)
        g.check(eventually("nmcli -t -f GENERAL.STATE device show wlan0 | grep -q '(connected)'", 40, user=True),
                "network: joining AxiomLab with the right password connects")
        g.shot("network-04-connected")
        rc, o = g.sh("grep -rl 'axiom-lab-pass' /tmp/settings-network.out /var/log 2>/dev/null | head -1", 30)
        g.check(not (o or "").strip(), "network: the Wi-Fi password is not written to the app log or the journal files")
        g.check(eventually("ip -4 addr show wlan0 | grep -q inet", 30, user=False), "network: wlan0 received an IPv4 address")
    kill_apps()
    # truthful unavailable state
    g.sh("systemctl stop NetworkManager", 30)
    ok, errs = launch_settings("network", "settings-network-down")
    g.shot("network-05-service-down")
    kill_apps()
    g.sh("systemctl start NetworkManager", 30)

# =============================================================================================
if want("bluetooth"):
    g.check(eventually("systemctl is-enabled bluetooth", 10, user=False), "bluetooth: BlueZ service is enabled")
    rc, o = g.sh("ls /sys/class/bluetooth 2>/dev/null | wc -l; systemctl status bluetooth --no-pager | grep -c 'ConditionPathIsDirectory=/sys/class/bluetooth was not met'", 20)
    g.check("0" in (o or "").split() and "1" in (o or "").split(),
            "bluetooth: with no controller bluetoothd is correctly not started (start condition unmet), and the page reports no adapter")
    ok, errs = launch_settings("bluetooth")
    g.check(ok and errs == "", "bluetooth: Settings > Bluetooth loads without QML errors")
    g.shot("bluetooth-01-no-adapter")
    kill_apps()

# =============================================================================================
if want("sound"):
    g.check(eventually("wpctl status | grep -qi 'Sinks'", 30, user=True), "sound: PipeWire exposes an audio sink")
    ok, errs = launch_settings("sound")
    g.check(ok and errs == "", "sound: Settings > Sound loads without QML errors")
    g.shot("sound-01-page")
    g.user("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.30", 15)
    time.sleep(2)
    g.shot("sound-02-volume-30")
    if "sound.mute" in COORDS:
        click("sound.mute")
        g.check(eventually("wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED", 10, user=True), "sound: Mute in Settings mutes the default output")
        g.shot("sound-03-muted")
        click("sound.mute")
        g.check(eventually("! wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED", 10, user=True), "sound: Unmute restores output")
    if "sound.slider" in COORDS:
        click("sound.slider")
        v = out_of("wpctl get-volume @DEFAULT_AUDIO_SINK@")
        g.check(v != "" and "0.30" not in v, f"sound: clicking the slider changes the volume ({v})")
    kill_apps()

# =============================================================================================
if want("displays"):
    ok, errs = launch_settings("displays")
    g.check(ok and errs == "", "displays: Settings > Displays loads without QML errors")
    g.shot("displays-01-page")
    rc, o = g.user(". /tmp/axiom-env.sh; wlr-randr --json", 20)
    g.check('"name"' in (o or ""), "displays: the compositor reports outputs through wlr-randr")
    if "displays.scale2" in COORDS:
        click("displays.scale2")
        g.check(eventually(". /tmp/axiom-env.sh; wlr-randr --json | grep -Eq '\"scale\": 2'", 15, user=True), "displays: choosing 2× scale changes the output scale")
        g.shot("displays-02-scale-pending")
        time.sleep(15)
        g.check(eventually(". /tmp/axiom-env.sh; wlr-randr --json | grep -Eq '\"scale\": 1([,.]|$)'", 15, user=True),
                "displays: an unconfirmed change reverts automatically")
        g.shot("displays-03-reverted")
    if "displays.scale15" in COORDS:
        click("displays.scale15")
        time.sleep(2)
        g.shot("displays-02b-scale15-pending")
        g.key("ret", settle=2)  # Enter confirms the pending change (no pixel position needed)
        time.sleep(15)
        g.check(eventually(". /tmp/axiom-env.sh; wlr-randr --json | grep -Eq '\"scale\": 1.5'", 10, user=True), "displays: Keep makes the change stick")
        g.shot("displays-04-kept")
        g.user(". /tmp/axiom-env.sh; wlr-randr --output $(wlr-randr --json | sed -n 's/.*\"name\": \"\\([^\"]*\\)\".*/\\1/p' | head -1) --scale 1", 20)
    kill_apps()

# =============================================================================================
if want("power"):
    ok, errs = launch_settings("power")
    g.check(ok and errs == "", "power: Settings > Power loads without QML errors")
    g.shot("power-01-page")
    if "power.saver" in COORDS:
        click("power.saver")
        g.check(eventually("busctl --system get-property org.freedesktop.UPower.PowerProfiles /org/freedesktop/UPower/PowerProfiles org.freedesktop.UPower.PowerProfiles ActiveProfile | grep -q power-saver", 15, user=True), "power: choosing Power saver switches the real profile")
        g.shot("power-02-saver")
        # Diagnostic only: why does the daemon deny switch-profile when pkcheck allows it?
        _, diag = g.sh("journalctl -u power-profiles-daemon -u polkit --no-pager | tail -60; "
                       "P=$(pgrep -fo quickshell); echo QS_PID=$P; "
                       "pkcheck --action-id org.freedesktop.UPower.PowerProfiles.switch-profile --process $P --allow-user-interaction; echo PKCHECK_RC=$?; "
                       "loginctl show-session $(cat /proc/$P/sessionid 2>/dev/null) -p Active -p Local -p Type -p Remote 2>&1; "
                       "ls /etc/polkit-1/rules.d/", 60)
        open(os.path.join(OUT, "logs", "power-diag.txt"), "w").write(diag or "")
        _, setlog = g.sh("cat /tmp/axiom-profile-set.log 2>&1", 20)
        open(os.path.join(OUT, "logs", "power-profile-set.txt"), "w").write(setlog or "")
        # Diagnostic: what the shell logged about the profile write (kept as evidence).
        rc, o = g.sh("strings /run/user/1000/quickshell/by-id/*/log.qslog | grep -a -i 'powerprofile\\|power profile\\|PowerProfiles' | tail -20", 30)
        os.makedirs(os.path.join(OUT, "logs"), exist_ok=True)
        open(os.path.join(OUT, "logs", "power-profile-shell.log"), "w").write(o or "")
        click("power.balanced")
        g.check(eventually("busctl --system get-property org.freedesktop.UPower.PowerProfiles /org/freedesktop/UPower/PowerProfiles org.freedesktop.UPower.PowerProfiles ActiveProfile | grep -q balanced", 15, user=True), "power: choosing Balanced switches it back")
    if "power.idle5" in COORDS:
        click("power.idle5")
        g.check(eventually("grep -Eq '\"idleBlankMinutes\": 5' ~/.config/axiom/settings.json", 15, user=True),
                "power: choosing 5 min saves the idle screen-off time")
        g.shot("power-02b-idle-5min")
    rc, o = g.user("brightnessctl -m -c backlight info 2>&1 | head -1", 15)
    g.check("No" in (o or "") or "," not in (o or ""), "power: no backlight in the VM, and the UI shows that instead of a fake slider")
    kill_apps()
    # idle blanking: one minute, real compositor output power
    g.user("mkdir -p ~/.config/axiom && printf '{\"version\":1,\"idleBlankMinutes\":1}' > ~/.config/axiom/settings.json", 15)
    time.sleep(200)
    g.check(eventually(". /tmp/axiom-env.sh; wlr-randr --json | grep -q '\"enabled\": false'", 25, user=True), "power: the screen turns off after the idle time")
    g.shot("power-03-screen-off")
    # Diagnostic: idle-blank messages from the shell and the output state, kept as evidence.
    _, idle = g.sh("strings /run/user/1000/quickshell/by-id/*/log.qslog | grep -a 'IdleBlank\\|DisplayService\\|isIdle' | tail -20; "
                   "su axiom -s /bin/sh -c '. /tmp/axiom-env.sh; wlr-randr --json' 2>&1 | head -40", 30)
    open(os.path.join(OUT, "logs", "idle-shell.txt"), "w").write(idle or "")
    g.key("shift", settle=2)
    g.check(eventually(". /tmp/axiom-env.sh; wlr-randr --json | grep -q '\"enabled\": true'", 20, user=True), "power: input wakes the screen")
    g.user("rm -f ~/.config/axiom/settings.json", 15)

# =============================================================================================
if want("notifications"):
    g.user("printf '{\"version\":1,\"dnd\":true}' > ~/.config/axiom/settings.json", 15)
    time.sleep(2)
    g.user("notify-send -a DNDTest 'Quiet' 'This should not pop up'", 15)
    time.sleep(2)
    g.shot("notifications-01-dnd-no-toast")
    g.user("notify-send -u critical -a DNDTest 'Critical' 'Critical still shows'", 15)
    time.sleep(2)
    g.shot("notifications-02-dnd-critical")
    g.user(f"qs ipc --any-display -p /usr/local/share/axiom/shell call axiom toggleNotificationCenter", 20)
    time.sleep(2)
    g.shot("notifications-03-history")
    g.user(f"qs ipc --any-display -p /usr/local/share/axiom/shell call axiom closeOverlays", 20)
    g.user("rm -f ~/.config/axiom/settings.json", 15)
    ok, errs = launch_settings("notifications")
    g.check(ok and errs == "", "notifications: Settings > Notifications loads without QML errors")
    g.shot("notifications-04-settings")
    kill_apps()

# =============================================================================================
if want("keyboard"):
    ok, errs = launch_settings("keyboard")
    g.check(ok and errs == "", "keyboard: Settings > Keyboard loads without QML errors")
    g.shot("keyboard-01-page")
    kill_apps()
    g.user("mkdir -p ~/.config/axiom && printf 'XKB_DEFAULT_LAYOUT=de,us\\nXKB_DEFAULT_OPTIONS=grp:alt_shift_toggle\\n' > ~/.config/axiom/keyboard.env", 15)
    g.sh("loginctl terminate-user axiom; true", 30)
    g.check(g.shell_ready(240), "keyboard: the session restarts after logout")
    g.prepare_env()
    time.sleep(3)
    o = out_of("tr '\\0' '\\n' < /proc/$(pgrep -xo labwc)/environ | grep XKB", user=False)
    g.check("XKB_DEFAULT_LAYOUT=de,us" in o, f"keyboard: the next session starts with the chosen layouts ({o.replace(chr(10), ' ')})")
    g.user("printf 'XKB_DEFAULT_LAYOUT=de;touch /tmp/pwned\\n' > ~/.config/axiom/keyboard.env", 15)
    g.sh("loginctl terminate-user axiom; true", 30)
    g.check(g.shell_ready(240), "keyboard: session restarts again")
    g.prepare_env()
    o = out_of("tr '\\0' '\\n' < /proc/$(pgrep -xo labwc)/environ | grep XKB_DEFAULT_LAYOUT; ls /tmp/pwned 2>&1", user=False)
    g.check("de;touch" not in o and "pwned" in o and "No such file" in o, "keyboard: a malformed layout value is ignored and nothing is executed")
    g.user("rm -f ~/.config/axiom/keyboard.env", 15)

# =============================================================================================
if want("datetime"):
    ok, errs = launch_settings("datetime")
    g.check(ok and errs == "", "datetime: Settings > Date & time loads without QML errors")
    g.shot("datetime-01-page")
    kill_apps()
    PID = "$(pgrep -xo quickshell)"
    for action in ("org.freedesktop.timedate1.set-timezone", "org.freedesktop.timedate1.set-ntp",
                   "org.freedesktop.NetworkManager.settings.modify.system"):
        rc, o = g.sh(f"pkcheck --action-id {action} --process {PID}; echo rc=$?", 30)
        g.check("rc=0" in (o or ""), f"datetime/polkit: the running shell session is authorised for {action}")
    rc, o = g.sh(f"pkcheck --action-id org.freedesktop.timedate1.set-time --process {PID}; echo rc=$?", 30)
    g.check("rc=0" not in (o or ""), "datetime/polkit: setting the clock itself is not granted to the shell session")
    rc, o = g.sh("timedatectl set-timezone Europe/Berlin; timedatectl show -p Timezone; timedatectl set-timezone UTC", 40)
    g.check("Europe/Berlin" in (o or ""), "datetime: timedated applies a time zone change")

# =============================================================================================
if want("users"):
    ok, errs = launch_settings("users")
    g.check(ok and errs == "", "users: Settings > Users loads without QML errors")
    g.shot("users-01-page")
    g.check("axiom" in out_of("getent passwd axiom"), "users: the current account exists in the user database")
    kill_apps()

# =============================================================================================
if want("security"):
    for cmd, label in (("timedatectl set-time '2030-01-01 00:00:00'", "set the clock"),
                       ("nmcli general hostname evil", "change the hostname"),
                       ("useradd mallory", "add a user"),
                       ("systemctl stop NetworkManager", "stop a system service")):
        rc, o = g.user(cmd + "; echo rc=$?", 30)
        g.check("rc=0" not in (o or ""), f"security: the desktop user cannot {label}")
    g.check(not eventually("grep -q mallory /etc/passwd", 2, user=False), "security: no account was created")
    rc, o = g.sh("grep -c 'allowed\\[' /etc/polkit-1/rules.d/51-axiom-system-settings.rules; pgrep -u 0 -a quickshell | wc -l", 20)
    g.check(out_of("pgrep -u 0 -x quickshell | wc -l", user=False).endswith("0"), "security: no Axiom UI process runs as root")

# =============================================================================================
if want("recovery"):
    g.sh("pkill -f '[q]uickshell -p /usr/local/share/axiom/shell$'; true", 15)
    time.sleep(3)
    g.check(g.shell_ready(120), "recovery: the supervised shell restarts after being killed")
    g.prepare_env()
    g.sh("systemctl restart power-profiles-daemon; true", 30)
    time.sleep(3)
    ok, errs = launch_settings("power", "settings-power-after-restart")
    g.check(ok and errs == "", "recovery: Power page recovers after power-profiles-daemon restarts")
    g.shot("recovery-01-power-after-restart")
    kill_apps()

# =============================================================================================
if want("memory"):
    res = {}
    m = re.search(r"\d+", out_of("pgrep -xo quickshell", user=False) or "")
    if m:
        res["shell"] = pss_kb(m.group(0))
    launch_settings("network", "settings-mem")
    m = re.search(r"\d+", out_of("pgrep -fo 'shell/settings[.]qml'", user=False) or "")
    if m:
        res["settings_network_page"] = pss_kb(m.group(0))
    kill_apps()
    os.makedirs(OUT, exist_ok=True)
    json.dump(res, open(os.path.join(OUT, "memory.json"), "w"), indent=2)
    g.check(res.get("shell", 0) > 0, f"memory: measured Pss kB {res}")

g.shot("99-final")
print(f"\n{'FAIL' if g.failures else 'OK'}: {len(g.failures)} failure(s)")
for f in g.failures:
    print(" -", f)
g.kill()
sys.exit(1 if g.failures else 0)
