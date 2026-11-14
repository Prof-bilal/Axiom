# Bottles

## When to use
- You want a graphical manager for separate Windows environments, so each Windows app or game gets its own setup.
- A Windows program needs a specific Wine version or runner that you want to set per environment.
- You need to tweak a Windows app's environment variables or DLL overrides without using the terminal.
- You want to run Windows software outside Steam or the store launchers.

## How it works
- A "bottle" is a Windows prefix: an isolated environment with its own files and settings.
- Each bottle uses a runner, which is the compatibility layer (such as Wine) that runs Windows software.
- You create a bottle, then add programs or installers to it from the app.
- Per-bottle settings cover runner choice and environment or DLL options; the app also includes a task view for Wine processes.
- Dependencies for an app can be installed into its bottle.

## Not for
- Store-managed games across Epic, GOG and Amazon; use Heroic Games Launcher.
- Emulators and mixed launcher libraries; use Lutris.

## Sources
- https://docs.usebottles.com/
