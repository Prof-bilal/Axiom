#!/usr/bin/env bash
# HISTORICAL ARCHIVE: superseded Omarchy-derived build wrapper. Do not run as
# the active Axiom builder; retained only for migration evidence.
# Build the pinned Omarchy-derived Axiom foundation without editing upstream
# worktrees. The staged tree is disposable; only the build inputs and evidence
# are retained under iso/out/phase2.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OMARCHY_SRC="$ROOT/workspace/upstream/omarchy-v4.0.6"
ISO_SRC="$ROOT/workspace/upstream/omarchy-iso-main"
OUT="$ROOT/iso/out/phase2"
WORK="$ROOT/iso/work-phase2"
SOURCE_DATE_EPOCH="${SOURCE_DATE_EPOCH:-1792436745}"
IMAGE="${AXIOM_ARCHISO_IMAGE:-archlinux:latest}"

die() { echo "build-phase2-foundation: $*" >&2; exit 1; }
command -v docker >/dev/null || die "docker is required"
command -v git >/dev/null || die "git is required"
command -v sha256sum >/dev/null || die "sha256sum is required"
[[ -e "$OMARCHY_SRC/.git" ]] || die "missing pinned Omarchy source: $OMARCHY_SRC"
[[ -e "$ISO_SRC/.git" ]] || die "missing pinned omarchy-iso source: $ISO_SRC"
[[ -d "$ISO_SRC/archiso/configs/releng" ]] || {
  die "omarchy-iso archiso submodule is not initialized"
}

omarchy_rev="$(git -C "$OMARCHY_SRC" rev-parse HEAD)"
iso_rev="$(git -C "$ISO_SRC" rev-parse HEAD)"
[[ "$omarchy_rev" == 237f1b4071a0bff2296c6d740ba2b9fd695ebfa0 ]] ||
  die "unexpected Omarchy revision: $omarchy_rev"
[[ "$iso_rev" == 3c36557fd58fe8dcd963f47eb9145f48a543a658 ]] ||
  die "unexpected omarchy-iso revision: $iso_rev"

image_digest="$(docker image inspect "$IMAGE" --format '{{index .RepoDigests 0}}' 2>/dev/null || true)"
[[ -n "$image_digest" ]] || die "Docker image is not available: $IMAGE"

rm -rf "$WORK"
mkdir -p "$WORK/iso" "$WORK/omarchy" "$OUT"
cp -a "$ISO_SRC/." "$WORK/iso/"
cp -a "$OMARCHY_SRC/." "$WORK/omarchy/"
rm -rf "$WORK/iso/.git" "$WORK/omarchy/.git"

# Arch releng's historical broadcom-wl package was removed from the current
# rolling repository; Omarchy's maintained broadcom-wl-dkms entry remains in
# its own package set. Record this compatibility adjustment instead of letting
# the builder silently resolve a different package.
sed -i '/^broadcom-wl$/d' "$WORK/iso/archiso/configs/releng/packages.x86_64"

# The stable image's optional hardware list is broader than the pinned package
# mirror currently serves. Keep the generic foundation and QEMU-relevant audio,
# graphics, kernel, snapshot and firmware inputs; leave laptop/vendor drivers
# for their own hardware matrix rather than making the foundation build depend
# on an unavailable vendor package.
awk '
  /^#/ { print; next }
  $1 == "base" || $1 == "btrfs-progs" || $1 == "egl-wayland" ||
  $1 == "gst-plugin-pipewire" || $1 == "gtk4-layer-shell" ||
  $1 == "libpulse" || $1 == "limine" || $1 == "limine-mkinitcpio-hook" ||
  $1 == "limine-snapper-sync" || $1 == "linux-omarchy" ||
  $1 == "linux-omarchy-headers" || $1 == "pipewire" ||
  $1 == "pipewire-alsa" || $1 == "pipewire-jack" ||
  $1 == "pipewire-pulse" || $1 == "qt6-wayland" || $1 == "snapper" ||
  $1 == "sof-firmware" || $1 == "webp-pixbuf-loader" ||
  $1 == "zram-generator" { print }
' "$WORK/omarchy/install/omarchy-other.packages" > "$WORK/omarchy/install/omarchy-other.packages.phase2"
mv "$WORK/omarchy/install/omarchy-other.packages.phase2" \
  "$WORK/omarchy/install/omarchy-other.packages"

# Keep the first foundation artifact focused on the graphical/session and
# recovery contract. Application bundles are provisioned in later phases and
# account for most of the mutable mirror download size.
awk '
  /^#/ { print; next }
  $1 == "alsa-utils" || $1 == "avahi" || $1 == "bash-completion" ||
  $1 == "bat" || $1 == "bluez" || $1 == "bluez-tools" ||
  $1 == "bluez-utils" || $1 == "bolt" || $1 == "brightnessctl" ||
  $1 == "btop" || $1 == "cups" || $1 == "cups-filters" ||
  $1 == "cups-pk-helper" || $1 == "eza" || $1 == "expac" ||
  $1 == "fd" || $1 == "fcitx5" || $1 == "fcitx5-gtk" ||
  $1 == "fcitx5-qt" || $1 == "foot" || $1 == "fontconfig" ||
  $1 == "fzf" || $1 == "git" || $1 == "gnome-keyring" ||
  $1 == "grim" || $1 == "gum" || $1 == "hyprland" ||
  $1 == "hyprland-guiutils" || $1 == "hyprland-preview-share-picker" ||
  $1 == "hyprpicker" || $1 == "hyprsunset" || $1 == "imagemagick" ||
  $1 == "imv" || $1 == "inetutils" || $1 == "inotify-tools" ||
  $1 == "inxi" || $1 == "jq" || $1 == "less" || $1 == "networkmanager" ||
  $1 == "noto-fonts" || $1 == "noto-fonts-cjk" ||
  $1 == "noto-fonts-emoji" || $1 == "nss-mdns" || $1 == "nvim" ||
  $1 == "pacman-contrib" || $1 == "pamixer" || $1 == "power-profiles-daemon" ||
  $1 == "python-gobject" || $1 == "qt6-imageformats" || $1 == "quickshell" ||
  $1 == "ripgrep" || $1 == "sddm" || $1 == "slurp" || $1 == "socat" ||
  $1 == "starship" || $1 == "system-config-printer" || $1 == "tmux" ||
  $1 == "ttf-ia-writer" || $1 == "ttf-jetbrains-mono-nerd-basic" ||
  $1 == "tzupdate" || $1 == "udiskie" || $1 == "ufw" ||
  $1 == "unzip" || $1 == "uwsm" || $1 == "wireless-regdb" ||
  $1 == "wireplumber" || $1 == "wl-clipboard" || $1 == "wtype" ||
  $1 == "xdg-desktop-portal-gtk" || $1 == "xdg-desktop-portal-hyprland" ||
  $1 == "xdg-terminal-exec" || $1 == "yaru-icon-theme" || $1 == "zoxide" { print }
' "$WORK/omarchy/install/omarchy-base.packages" > "$WORK/omarchy/install/omarchy-base.packages.phase2"
mv "$WORK/omarchy/install/omarchy-base.packages.phase2" \
  "$WORK/omarchy/install/omarchy-base.packages"
# The Phase 2 image must boot offline; first-boot AI/tool provisioning and
# browser-native messaging are deliberately later-phase work.
sed -i \
  -e '/user\/chromium\.sh/d' \
  -e '/user\/mise-work\.sh/d' \
  -e '/user\/mise\.sh/d' \
  "$WORK/omarchy/install/user/all.sh"
sed -i '/systemctl enable docker\.socket/d' \
  "$WORK/omarchy/install/config/enable-services.sh"
sed -i '/install_ufw_docker_rules/d' "$WORK/omarchy/install/config/firewall.sh"
sed -i 's/linux-t2 git gum/linux-omarchy git gum/' "$WORK/iso/builder/build-iso.sh"

# The upstream ISO profile still carries Omarchy's visible boot-menu labels and
# its historical T2 kernel name.  Rewrite every bootloader template in the
# staged profile so the generated media both boots the package we ship and does
# not expose upstream product identity at the first screen.
find "$WORK/iso/configs/grub" "$WORK/iso/configs/syslinux" -type f -print0 |
  xargs -0 sed -i \
    -e 's/linux-t2/linux-omarchy/g' \
    -e 's/Omarchy/Axiom/g'

# Visible identity remains limited to the foundation boot/session labels.
# The Phase 3 shell payload and autostart replacement are intentionally absent
# until a new shell specification is authorized.
sed -i \
  -e 's/^Name=Omarchy (Hyprland uwsm)$/Name=Axiom (Hyprland uwsm)/' \
  -e 's/^Comment=Omarchy Hyprland session managed by uwsm$/Comment=Axiom Hyprland session managed by uwsm/' \
  "$WORK/omarchy/default/wayland-sessions/omarchy.desktop"
sed -i \
  -e 's/^Name=Omarchy$/Name=Axiom/' \
  -e 's/^Description=Omarchy splash screen\.$/Description=Axiom foundation splash screen./' \
  "$WORK/omarchy/default/plymouth/omarchy.plymouth"
sed -i 's/^Description=.*/Description=Axiom login theme./' \
  "$WORK/omarchy/default/sddm/omarchy/metadata.desktop"

sed -i \
  -e 's/^iso_name="omarchy"$/iso_name="axiom"/' \
  -e 's/^iso_label="OMARCHY_/iso_label="AXIOM_/' \
  -e 's/^iso_publisher="Omarchy <https:\/\/omarchy.org>"$/iso_publisher="Axiom <https:\/\/github.com\/Prof-bilal\/Axiom>"/' \
  -e 's/^iso_application="Omarchy Installer"$/iso_application="Axiom Foundation"/' \
  "$WORK/iso/configs/profiledef.sh"

rm -rf "$OUT/current"
mkdir -p "$OUT/current" "$OUT/cache"
printf 'omarchy_revision=%s\niso_revision=%s\narchiso_submodule=%s\nsource_date_epoch=%s\ndocker_image=%s\n' \
  "$omarchy_rev" "$iso_rev" "$(git -C "$ISO_SRC/archiso" rev-parse HEAD)" \
  "$SOURCE_DATE_EPOCH" "$image_digest" > "$OUT/current/inputs.txt"
printf '%s\n' \
  'Removed obsolete releng package broadcom-wl.' \
  'Filtered omarchy-other.packages to generic/QEMU foundation inputs; vendor hardware drivers remain deferred.' \
  'Filtered omarchy-base.packages to desktop foundation inputs; application provisioning remains deferred.' \
  'Disabled first-boot browser-native messaging and networked AI/tool provisioning in the foundation image.' \
  'Removed Docker socket/UFW-Docker setup from the generic foundation; privileged container integration is later-gated.' \
  'Removed builder arch_packages linux-t2; the generic linux-omarchy kernel remains.' \
  'Pinned Omarchy is ISO-only; its legacy automated installer references removed install.sh/helpers/all.sh and is not treated as a Phase 2 release installer.' \
  > "$OUT/current/compatibility-adjustments.txt"
printf 'staged from %s\n' "$iso_rev" > "$OUT/current/staged-iso-status.txt"
printf 'staged from %s\n' "$omarchy_rev" > "$OUT/current/staged-omarchy-status.txt"

docker run --rm --privileged \
  -e "SOURCE_DATE_EPOCH=$SOURCE_DATE_EPOCH" \
  -e "HOST_UID=$(id -u)" -e "HOST_GID=$(id -g)" \
  -e "OMARCHY_MIRROR=stable" -e "OMARCHY_INSTALLER_REF=v4.0.6" \
  -v "$OUT/current:/out" \
  -v "$WORK/iso/archiso:/archiso:ro" \
  -v "$WORK/iso/builder:/builder:ro" \
  -v "$WORK/iso/configs:/configs:ro" \
  -v "$WORK/omarchy:/omarchy:ro" \
  -v "$OUT/cache:/var/cache/airootfs/var/cache/omarchy" \
  -v "/var/cache/pacman/pkg:/var/cache/pacman/pkg" \
  "$image_digest" /builder/build-iso.sh \
  2>&1 | tee "$OUT/current/build.log"

iso="$(find "$OUT/current" -maxdepth 1 -type f -name '*.iso' -printf '%p\n' | sort | tail -n1)"
[[ -n "$iso" ]] || die "build completed without an ISO"
sha256sum "$iso" | tee "$OUT/current/iso.sha256"
docker image inspect "$IMAGE" --format '{{json .}}' > "$OUT/current/docker-image.json"
bsdtar -tf "$iso" | rg -n 'axiom|omarchy|loader|grub' > "$OUT/current/iso-identity-paths.txt" || true
echo "Built $iso"
