# MangoHud

## When to use
- You want to see FPS, frame time and CPU or GPU load while a game runs.
- You are checking whether a game is hitting temperature, power or VRAM limits.
- You are testing whether a change such as a GameMode or driver setting actually helps.
- You want a per-game overlay that you can configure separately for each title.

## How it works
- MangoHud is a Vulkan and OpenGL overlay that draws live metrics on top of a running game.
- It is enabled by running the game through mangohud, for example mangohud followed by the program.
- In Steam, add mangohud %command% to the launch options; in Lutris, add mangohud to the command prefix.
- Metrics include FPS (on by default), frame time, CPU and GPU load, temperatures, power, memory and clocks.
- Settings come from a config file: a per-app file in ~/.config/MangoHud/ overrides the global one, and MANGOHUD_CONFIG can set options inline.

## Not for
- Changing system performance settings; use GameMode.
- Capturing video of gameplay; use OBS Studio.

## Sources
- https://github.com/flightlessmango/MangoHud
