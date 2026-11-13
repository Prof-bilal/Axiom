# RetroArch

## When to use
- You want one frontend that runs many classic consoles and computers through different emulator and engine cores.
- You want to organize your ROM collection into playlists with history and favorites.
- You want shared settings such as controller mapping, shaders and save handling across several systems.
- You want to run a single retro game with a specific core that you choose.

## How it works
- RetroArch is a frontend; the emulation or game engine work is done by a libretro core.
- You load a core first, then load content such as a ROM file (some systems also need BIOS files).
- Playlists hold lists of content, including History and Favorites; choose a row and select Run.
- The Main Menu is where you load cores and content; the Quick Menu opens during play.
- Close Content in the Quick Menu ends the game and its core, returning you to the Main Menu.

## Not for
- Running one specific emulator with its own dedicated interface, such as Dolphin for GameCube and Wii.
- Store-bought PC games; use Steam, Heroic or Lutris.

## Sources
- https://docs.libretro.com/guides/starting-a-game/
