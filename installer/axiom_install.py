"""Axiom installer backend (Phase 6, ADR-020/021). Python stdlib only.

Validates the form, builds archinstall's config/credentials, runs archinstall
with an argv list (never a shell string), applies the Axiom overlay in the target
and records the Developer Hub profile. Progress is JSON lines on stdout.

Secrets: the password is hashed with `openssl passwd -6 -stdin`; hash and LUKS
passphrase live only in 0600 files on tmpfs that are removed after the run.
"""
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import uuid

TARGET = "/mnt"
USER_RE = re.compile(r"^[a-z_][a-z0-9_-]{0,31}$")
HOST_RE = re.compile(r"^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$")
EMAIL_RE = re.compile(r"^[^@\s]{1,64}@[^@\s]{1,190}\.[^@\s]{2,}$")
LAYOUT_RE = re.compile(r"^[a-z0-9_]{2,12}$")
LOCALE_RE = re.compile(r"^[a-z]{2,3}_[A-Z]{2}$")
RESERVED = {"root", "daemon", "bin", "sys", "sync", "games", "man", "lp", "mail", "news", "uucp", "proxy",
            "www-data", "backup", "list", "irc", "nobody", "systemd-network", "polkitd", "git", "axiom", "admin"}
COMMON_PW = {"password", "password1", "12345678", "123456789", "1234567890", "qwertyuiop", "iloveyou1",
             "letmein123", "welcome123", "administrator", "axiom12345", "install", "changeme123"}
ESP_MIB = 1024
ENV = {"PATH": "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin", "LC_ALL": "C.UTF-8"}

# Desktop set mirrors the Phase 3/5 package list (iso/phase3/packages.x86_64).
BASE_PACKAGES = [
    "base-devel", "git", "nano", "vim", "openssh", "sudo", "zsh", "btrfs-progs", "cryptsetup",
    "networkmanager", "wpa_supplicant", "polkit", "dbus", "pipewire", "pipewire-pulse", "pipewire-alsa",
    "wireplumber", "alsa-utils", "mesa", "libglvnd", "wayland", "wayland-protocols", "labwc",
    "xdg-desktop-portal", "xdg-desktop-portal-wlr", "xdg-desktop-portal-gtk", "gvfs", "quickshell",
    "qt6-declarative", "qt6-wayland", "qt6-svg", "qt6-5compat", "noto-fonts", "ttf-dejavu", "inter-font",
    "ttf-jetbrains-mono", "adwaita-icon-theme", "hicolor-icon-theme", "foot", "mousepad", "firefox",
    "libnotify", "xdg-utils", "glib2", "bluez", "bluez-utils", "power-profiles-daemon", "upower",
    "wlr-randr", "brightnessctl", "xkeyboard-config", "greetd", "python", "linux-firmware",
    "qemu-guest-agent", "mkinitcpio", "intel-ucode", "amd-ucode",
]
SERVICES = ["NetworkManager", "bluetooth", "power-profiles-daemon", "systemd-timesyncd", "qemu-guest-agent"]
# Axiom-owned files copied from the live medium into the target (nothing else).
OVERLAY = [
    "/etc/axiom", "/etc/polkit-1/rules.d/50-axiom-session-power.rules",
    "/etc/polkit-1/rules.d/51-axiom-system-settings.rules", "/etc/xdg/foot", "/etc/xdg/gtk-3.0",
    "/etc/xdg/gtk-4.0", "/etc/xdg/mimeapps.list", "/etc/pam.d/axiom-lock", "/usr/local/lib/axiom-greeter", "/usr/local/lib/axiom-provision",
    "/usr/local/bin/axiom-provision",
    "/etc/systemd/system/power-profiles-daemon.service.d",
    "/usr/local/bin/axiom-app", "/usr/local/bin/axiom-greeting", "/usr/local/bin/axiom-session",
    "/usr/local/bin/axiom-shell", "/usr/local/bin/axiom-terminal", "/usr/local/share/axiom",
    "/usr/local/share/applications", "/usr/local/share/icons",
]


class FormError(ValueError):
    pass


def emit(event, **kw):
    print(json.dumps({"event": event, **kw}), flush=True)


# ---- validation ----------------------------------------------------------------
def check_password(pw, username=""):
    if len(pw) < 10:
        raise FormError("password must be at least 10 characters")
    if pw.lower() in COMMON_PW or (username and pw.lower() == username.lower()):
        raise FormError("password is too common or equals the username")
    if len(set(pw)) < 4:
        raise FormError("password needs at least 4 different characters")
    if "\n" in pw or "\x00" in pw:
        raise FormError("password contains control characters")


def validate_form(f, zoneinfo="/usr/share/zoneinfo"):
    """Return a cleaned copy of form f or raise FormError. Everything is data, never shell."""
    out = {}
    user = f.get("username", "")
    if not USER_RE.match(user) or user in RESERVED:
        raise FormError("invalid or reserved username")
    out["username"] = user
    name = f.get("fullname", "").strip()
    if not name or len(name) > 64 or re.search(r"[\x00-\x1f:,=]", name):
        raise FormError("invalid full name")
    out["fullname"] = name
    host = f.get("hostname", "")
    if not HOST_RE.match(host):
        raise FormError("invalid hostname")
    out["hostname"] = host
    check_password(f.get("password", ""), user)
    out["password"] = f["password"]
    tz = f.get("timezone", "")
    if not re.match(r"^[A-Za-z0-9_+-]+(/[A-Za-z0-9_+-]+){0,2}$", tz) or not os.path.isfile(os.path.join(zoneinfo, tz)):
        raise FormError("unknown timezone")
    out["timezone"] = tz
    if not LAYOUT_RE.match(f.get("keyboard", "us")):
        raise FormError("invalid keyboard layout")
    out["keyboard"] = f.get("keyboard", "us")
    if not LOCALE_RE.match(f.get("locale", "en_US")):
        raise FormError("invalid locale")
    out["locale"] = f.get("locale", "en_US")
    gname, gmail = f.get("git_name", "").strip(), f.get("git_email", "").strip()
    if gname or gmail:
        if not gname or re.search(r"[\x00-\x1f<>]", gname) or len(gname) > 100:
            raise FormError("invalid git name")
        if not EMAIL_RE.match(gmail):
            raise FormError("invalid git email")
    out["git_name"], out["git_email"] = gname, gmail
    out["luks"] = bool(f.get("luks"))
    if out["luks"]:
        check_password(f.get("luks_passphrase", ""))
        out["luks_passphrase"] = f["luks_passphrase"]
    out["hub"] = [str(i) for i in f.get("hub", [])]
    if any(not re.match(r"^[a-z0-9][a-z0-9._-]{0,63}$", i) for i in out["hub"]):
        raise FormError("invalid hub item id")
    return out


# ---- disks ----------------------------------------------------------------------
def list_disks(lsblk_json=None):
    """Whole disks that are safe targets: not removable/optical, nothing mounted, not the live medium."""
    if lsblk_json is None:
        lsblk_json = subprocess.run(
            ["lsblk", "-J", "-b", "-o", "NAME,PATH,SIZE,MODEL,SERIAL,TYPE,RM,RO,MOUNTPOINTS"],
            capture_output=True, text=True, check=True, env=ENV).stdout
    disks = []
    for d in json.loads(lsblk_json).get("blockdevices", []):
        if d.get("type") != "disk" or d.get("ro") or d.get("rm"):
            continue
        mounts = [m for m in (d.get("mountpoints") or []) if m]
        for c in d.get("children") or []:
            mounts += [m for m in (c.get("mountpoints") or []) if m]
            for cc in c.get("children") or []:
                mounts += [m for m in (cc.get("mountpoints") or []) if m]
        if mounts:
            continue
        disks.append({"path": d["path"], "size": int(d["size"]), "model": (d.get("model") or "").strip(),
                      "serial": (d.get("serial") or "").strip()})
    return disks


def check_target(path, size, disks=None):
    """Re-validate right before writing: must still be a listed safe disk of the same size."""
    for d in (disks if disks is not None else list_disks()):
        if d["path"] == path and d["size"] == size:
            return d
    raise FormError("target disk is not a safe, unchanged disk")


# ---- archinstall config -----------------------------------------------------------
def _size(unit, value):
    return {"sector_size": {"unit": "B", "value": 512}, "unit": unit, "value": value}


def build_config(f, disk_path, disk_bytes):
    root_mib = disk_bytes // (1024 * 1024) - ESP_MIB - 2
    if root_mib < 8 * 1024:
        raise FormError("disk is too small (need at least 10 GiB)")
    root_id, esp_id = str(uuid.uuid4()), str(uuid.uuid4())
    subvols = [("@", "/"), ("@home", "/home"), ("@log", "/var/log"), ("@pkg", "/var/cache/pacman/pkg"),
               ("@snapshots", "/.snapshots")]
    cfg = {
        "archinstall-language": "English",
        "bootloader_config": {"bootloader": "Systemd-boot", "uki": False, "removable": False},
        "disk_config": {"config_type": "default_layout", "device_modifications": [{
            "device": disk_path, "wipe": True, "partitions": [
                {"btrfs": [], "dev_path": None, "flags": ["boot", "esp"], "fs_type": "fat32",
                 "size": _size("MiB", ESP_MIB), "mount_options": [], "mountpoint": "/boot", "obj_id": esp_id,
                 "start": _size("MiB", 1), "status": "create", "type": "primary"},
                {"btrfs": [{"name": n, "mountpoint": m} for n, m in subvols], "dev_path": None, "flags": [],
                 "fs_type": "btrfs", "size": _size("MiB", root_mib), "mount_options": ["compress=zstd"],
                 "mountpoint": None, "obj_id": root_id, "start": _size("MiB", ESP_MIB + 1),
                 "status": "create", "type": "primary"}]}]},
        "hostname": f["hostname"], "kernels": ["linux", "linux-lts"],
        "locale_config": {"kb_layout": f["keyboard"], "sys_enc": "UTF-8", "sys_lang": f["locale"]},
        "network_config": {"type": "nm"}, "ntp": True, "offline": False,
        "packages": BASE_PACKAGES, "services": SERVICES,
        "swap": {"enabled": True, "algorithm": "zstd"}, "timezone": f["timezone"], "script": "guided",
    }
    if f["luks"]:
        cfg["disk_encryption"] = {"encryption_type": "luks", "partitions": [root_id], "lvm_volumes": []}
    return cfg


def hash_password(pw):
    """sha512-crypt hash; the password goes to openssl on stdin, never argv."""
    return subprocess.run(["openssl", "passwd", "-6", "-stdin"], input=pw + "\n", capture_output=True,
                          text=True, check=True, env=ENV).stdout.strip()


def build_creds(f):
    creds = {"users": [{"username": f["username"], "enc_password": hash_password(f["password"]),
                        "sudo": True, "groups": ["wheel", "video", "input", "audio", "rfkill", "tty"]}]}
    if f["luks"]:
        creds["encryption_password"] = f["luks_passphrase"]
    return creds


# ---- profile --------------------------------------------------------------------------
def build_profile(f):
    """Developer Hub profile: selection only, no secrets (ADR-021)."""
    return {"schema": 1, "user": f["username"], "git": {"name": f["git_name"], "email": f["git_email"]},
            "hub": f["hub"], "applied": {}}


# ---- install --------------------------------------------------------------------------------
def run(cmd, **kw):
    return subprocess.run(cmd, check=True, env=ENV, **kw)


def apply_overlay(target=TARGET, paths=OVERLAY):
    for p in paths:
        if not os.path.exists(p):
            raise FileNotFoundError(f"overlay source missing: {p}")
        dst = os.path.join(target, p.lstrip("/"))
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        if os.path.isdir(p):
            shutil.copytree(p, dst, symlinks=True, dirs_exist_ok=True)
        else:
            shutil.copy2(p, dst)


def propagate_console(target=TARGET, cmdline="/proc/cmdline"):
    """Copy the live medium's console= options to the installed boot entries (serial testing/recovery)."""
    try:
        opts = [t for t in open(cmdline).read().split() if re.match(r"^console=[a-zA-Z0-9,]+$", t)]
    except OSError:
        return
    entries = os.path.join(target, "boot/loader/entries")
    if not opts or not os.path.isdir(entries):
        return
    for name in os.listdir(entries):
        path = os.path.join(entries, name)
        lines = open(path).read().splitlines()
        lines = [(l.rstrip() + " " + " ".join(o for o in opts if o not in l)).rstrip() if l.startswith("options") else l
                 for l in lines]
        open(path, "w").write("\n".join(lines) + "\n")


def post_install(f, target=TARGET):
    emit("step", name="overlay", pct=80)
    apply_overlay(target)
    shutil.copy2("/etc/axiom/os-release", os.path.join(target, "etc/os-release")) if os.path.exists(
        "/etc/axiom/os-release") else None
    emit("step", name="account", pct=88)
    home = os.path.join(target, "home", f["username"])
    chroot = ["arch-chroot", target]
    run(chroot + ["usermod", "-c", f["fullname"], "-s", "/usr/bin/zsh", f["username"]])
    run(chroot + ["passwd", "-l", "root"])
    # Axiom interactive shell config; without a .zshrc zsh starts its first-run wizard.
    shutil.copy2("/etc/axiom/zshrc", os.path.join(home, ".zshrc"))
    run(chroot + ["chown", f"{f['username']}:{f['username']}", f"/home/{f['username']}/.zshrc"])
    run(chroot + ["install", "-d", "-m", "0700", "-o", f["username"], "-g", f["username"],
                  f"/home/{f['username']}/.config/axiom"])
    prof = json.dumps(build_profile(f), indent=2) + "\n"
    run(chroot + ["install", "-d", "-m", "0755", "/var/lib/axiom"])
    for dst in ("/var/lib/axiom/profile.json", f"/home/{f['username']}/.config/axiom/dev-profile.json"):
        with open(os.path.join(target, dst.lstrip("/")), "w") as fh:
            fh.write(prof)
        os.chmod(os.path.join(target, dst.lstrip("/")), 0o644 if dst.startswith("/var") else 0o600)
    run(chroot + ["chown", f"{f['username']}:{f['username']}", f"/home/{f['username']}/.config/axiom/dev-profile.json"])
    if f["git_name"]:
        gc = f"/home/{f['username']}/.gitconfig"
        for key, val in (("user.name", f["git_name"]), ("user.email", f["git_email"])):
            run(chroot + ["git", "config", "--file", gc, key, val])
        run(chroot + ["chown", f"{f['username']}:{f['username']}", gc])
    # Login manager: greetd + the Axiom greeter; installed systems never autologin.
    os.makedirs(os.path.join(target, "etc/greetd"), exist_ok=True)
    with open(os.path.join(target, "etc/greetd/config.toml"), "w") as fh:
        fh.write('[terminal]\nvt = 1\n\n[default_session]\ncommand = "/usr/local/lib/axiom-greeter/axiom-greeter"\nuser = "greeter"\n')
    run(chroot + ["systemctl", "enable", "greetd.service"])
    shutil.copy2("/usr/local/lib/axiom-provision/axiom-provision.service", os.path.join(target, "etc/systemd/system/axiom-provision.service"))
    run(chroot + ["systemctl", "enable", "axiom-provision.service"])
    # sudo for wheel (password required)
    with open(os.path.join(target, "etc/sudoers.d/10-wheel"), "w") as fh:
        fh.write("%wheel ALL=(ALL:ALL) ALL\n")
    os.chmod(os.path.join(target, "etc/sudoers.d/10-wheel"), 0o440)
    propagate_console(target)
    emit("step", name="post-install-done", pct=95)


def kill_users(target=TARGET, proc="/proc", kill=os.kill):
    """SIGKILL every process whose root or cwd is under target (pacstrap/pacman left behind by a killed run)."""
    killed = []
    for pid in os.listdir(proc):
        if not pid.isdigit() or int(pid) == os.getpid():
            continue
        for link in ("root", "cwd"):
            try:
                dest = os.readlink(os.path.join(proc, pid, link))
            except OSError:
                continue
            if dest == target or dest.startswith(target.rstrip("/") + "/"):
                kill(int(pid), 9)
                killed.append(int(pid))
                break
    return killed


def cleanup(target=TARGET):
    """Leave the machine retryable after a failed run: no stragglers, nothing mounted, LUKS closed."""
    import time
    kill_users(target)
    for _ in range(5):
        subprocess.run(["umount", "-R", target], env=ENV, capture_output=True)
        if subprocess.run(["findmnt", target], env=ENV, capture_output=True).returncode != 0:
            break
        kill_users(target)
        time.sleep(1)
    if os.path.isdir("/dev/mapper"):
        for name in os.listdir("/dev/mapper"):
            if name != "control":
                subprocess.run(["cryptsetup", "close", name], env=ENV, capture_output=True)


def install(f, disk_path, disk_bytes, target=TARGET):
    check_target(disk_path, disk_bytes)
    cfg = build_config(f, disk_path, disk_bytes)
    with tempfile.TemporaryDirectory(dir="/run", prefix="axiom-inst-") as tmp:
        os.chmod(tmp, 0o700)
        cp, kp = os.path.join(tmp, "config.json"), os.path.join(tmp, "creds.json")
        for path, data in ((cp, cfg), (kp, build_creds(f))):
            fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
            with os.fdopen(fd, "w") as fh:
                json.dump(data, fh)
        emit("step", name="archinstall", pct=5)
        log = open("/var/log/axiom-installer.log", "ab")
        try:
            run(["archinstall", "--config", cp, "--creds", kp, "--silent", "--skip-version-check",
                 "--skip-wkd", "--mountpoint", target], stdout=log, stderr=subprocess.STDOUT)
            post_install(f, target)
            subprocess.run(["sync"], env=ENV)
            cleanup(target)  # flushed and unmounted: safe to remove the medium and reboot
        except BaseException:
            cleanup(target)  # leave the machine retryable: nothing mounted, LUKS closed
            raise
    emit("done", pct=100)


def main(argv):
    form = json.load(sys.stdin)
    try:
        f = validate_form(form)
        install(f, form["disk"], int(form["disk_bytes"]))
    except FormError as e:
        emit("error", message=str(e))
        return 2
    except subprocess.CalledProcessError as e:
        emit("error", message=f"{e.cmd[0]} failed with exit {e.returncode}; see /var/log/axiom-installer.log")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
