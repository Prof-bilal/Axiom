# Zed (zed)

Status: verified (official docs via search results).

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Official install script | `sh -c "curl -f https://zed.dev/install.sh | sh"` | no | yes | Official fastest path. Script is piped to shell, so review it first if you need to. Needs glibc 2.31+ and Vulkan GPU per docs. |
| Preview channel | `sh -c "ZED_CHANNEL=preview curl -f https://zed.dev/install.sh | sh"` | no | yes | Preview receives updates about a week ahead. |
| Flatpak | `flatpak install flathub dev.zed.Zed` | no (`--user`) | yes | Docs say current Flatpak build exits the sandbox at startup. |
| Distro package | third-party packages named zed or zed-editor | depends | yes | Check distro repos (unverified). |

## Manual install
1. Download the tarball from https://zed.dev/download (unverified exact link).
2. Extract to `~/.local/zed.app` and symlink `~/.local/zed.app/bin/zed` to `~/.local/bin/zed`.
3. Install the desktop file from `~/.local/zed.app/share/applications/` (unverified path).
4. Check: `zed --version`.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| Blank window or crash at start | No working Vulkan driver. | Install your GPU Vulkan driver (Mesa `vulkan-radeon`, `vulkan-intel`, or NVIDIA driver with Vulkan). Check `vulkaninfo`. |
| Script fails: glibc too old | glibc below 2.31. | Upgrade the distro or use Flatpak. |
| `zed: command not found` | `~/.local/bin` not on PATH. | Add it to PATH. |
| Flatpak exits the sandbox / unexpected file access | Known Flatpak issue per Zed docs. | Prefer the install script on Linux. |

## Sources
- https://zed.dev/docs/linux.html
- https://zed.dev/docs/installation.html
- https://zed.dev/blog/zed-on-linux
