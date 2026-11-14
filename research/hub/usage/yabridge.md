# yabridge

## When to use
- Your DAW is a 64-bit native Linux app and you need a Windows-only VST2, VST3 or CLAP plugin.
- You run Bitwig Studio, REAPER, Carla or a similar native Linux host.
- You want several Windows plugins to share a few Wine processes (plugin groups).
- You already have Wine Staging and the plugins installed in a Wine prefix.

## How it works
- Wraps Windows plugins so a Linux host can load them; it runs them through Wine.
- Install by extracting the release archive to `~/.local/share/yabridge`, then `yabridgectl` manages the plugin folders.
- `yabridgectl add <folder>` registers a Windows plugin folder; `yabridgectl sync` creates links in `~/.vst/yabridge`, `~/.vst3/yabridge` and `~/.clap/yabridge`. Rerun `sync` after updates or plugin changes.
- Needs Wine Staging; the README says 5.1.1 was tested with Wine Staging 9.21 and that Wine 9.22 and 10.x did not work.

## Not for
- Flatpak DAWs: the README says yabridge does not work with them; use native packages.
- 32-bit-only Wine prefixes without the separate 32-bit build (`bitbridge`).

## Sources
- https://github.com/robbert-vdh/yabridge
- https://github.com/robbert-vdh/yabridge/blob/master/README.md
