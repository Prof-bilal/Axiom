# GameMode

## When to use
- A game stutters or runs below its target frame rate and you want the system to favor it while it runs.
- You launch games from a terminal or a launcher that lacks built-in GameMode support.
- You want to apply the same performance settings to several games through one config file.
- You want to check which optimizations are active for a running game.

## How it works
- GameMode is a daemon (gamemoded) plus a client library that lets a game request temporary system optimizations.
- You request it by prefixing a command with gamemoderun, for example gamemoderun followed by the game binary.
- In Steam, set the launch options to gamemoderun %command%.
- Launchers with built-in support turn it on automatically.
- Settings live in gamemode.ini; the file is read from system and user locations, and GPU settings are only honored from the system-level /etc file.

## Not for
- Frame-rate overlays or measurements; use MangoHud.
- Making a non-game program faster in general; GameMode is aimed at games.

## Sources
- https://www.mankier.com/1/gamemoderun
