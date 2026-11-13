# yabridge install guide

Status: Verified against the official README (GitHub, master branch); the install and `yabridgectl` commands were not run on a machine here, and the README version (5.1.1) was not confirmed as the latest release.


## Install options

| Method | Command | Needs root | Verified? |
|---|---|---|---|
| Manual archive | Download the release archive from https://github.com/robbert-vdh/yabridge/releases, extract to `~/.local/share` so `~/.local/share/yabridge/yabridgectl` exists | No | Verified: https://github.com/robbert-vdh/yabridge/blob/master/README.md |
| Add to PATH (optional) | `export PATH="$PATH:$HOME/.local/share/yabridge"` in `~/.bashrc` | No | Verified: https://github.com/robbert-vdh/yabridge/blob/master/README.md |
| Add VST2 folder | `yabridgectl add "$HOME/.wine/drive_c/Program Files/Steinberg/VstPlugins"` | No | Verified: https://github.com/robbert-vdh/yabridge/blob/master/README.md |
| Add VST3 folder | `yabridgectl add "$HOME/.wine/drive_c/Program Files/Common Files/VST3"` | No | Verified: https://github.com/robbert-vdh/yabridge/blob/master/README.md |
| Add CLAP folder | `yabridgectl add "$HOME/.wine/drive_c/Program Files/Common Files/CLAP"` | No | Verified: https://github.com/robbert-vdh/yabridge/blob/master/README.md |
| Sync plugins | `yabridgectl sync` | No | Verified: https://github.com/robbert-vdh/yabridge/blob/master/README.md |
| Distro package (Arch, Fedora COPR, openSUSE, NixOS) | Distro-specific package names not given in the README | Not stated | Not verified |

Note: the README says the binaries target Ubuntu 20.04 and newer. Realtime and Xorg fixes need sudo, but they are optional.

## Possible errors and fixes

**Error: `002b:err:module:__wine_process_init`**
- Cause: Wine is too old for this yabridge version.
- Fix: upgrade Wine (Wine Staging).
- Source: https://github.com/robbert-vdh/yabridge/blob/master/README.md

**Error: `0024:err:process:exec_process`**
- Cause: the Wine prefix is 32-bit only, so the 64-bit `yabridge-host.exe` cannot run.
- Fix: use a 64-bit Wine prefix.
- Source: https://github.com/robbert-vdh/yabridge/blob/master/README.md

**Warning: `RLIMIT_RTTIME` of 200000**
- Cause: rtkit limits the DAW (common with PipeWire or GNOME 45+).
- Fix: grant realtime privileges; on GNOME 45+ the README says you can mask `rtkit-daemon.service` (sudo).
- Source: https://github.com/robbert-vdh/yabridge/blob/master/README.md

**Warning: memory locking limits**
- Fix: on Arch/Manjaro install `realtime-privileges` and add your user to the `realtime` group; on Debian/Ubuntu add your user to `audio` if `/etc/security/limits.d/audio.conf` exists; then reboot.
- Source: https://github.com/robbert-vdh/yabridge/blob/master/README.md

**Error: `cmd.exe` reports the maximum number of clients**
- Cause: Xorg client limit reached.
- Fix: use plugin groups, or raise `MaxClients` in `/etc/X11/xorg.conf.d/99-maxclients.conf` and reboot.
- Source: https://github.com/robbert-vdh/yabridge/blob/master/README.md

**Symptom: plugin hangs or stale processes**
- Fix: `wineserver -k`.
- Source: https://github.com/robbert-vdh/yabridge/blob/master/README.md

**Error: `JS_EXEC_FAILED` (ujam, LoopCloud)**
- Fix: set `disable_pipes = true` for those plugins.
- Source: https://github.com/robbert-vdh/yabridge/blob/master/README.md

**Error: `Mount option 'unhide' is not allowed`**
- Fix: add the `udf_allow` line to `/etc/udisks2/mount_options.conf` as shown in the README.
- Source: https://github.com/robbert-vdh/yabridge/blob/master/README.md

