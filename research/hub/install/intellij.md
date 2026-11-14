# IntelliJ IDEA Community (intellij)

Status: unverified. Search quota ran out; all methods below come from model knowledge and must be checked.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Flatpak | `flatpak install flathub com.jetbrains.IntelliJ-IDEA-Community` | no (`--user`) | yes | ID unverified. Launch: `flatpak run com.jetbrains.IntelliJ-IDEA-Community`. |
| Snap | `sudo snap install intellij-idea-community --classic` | yes | yes | Name unverified. Classic confinement. |
| JetBrains Toolbox | download from https://www.jetbrains.com/toolbox-app/ | no | yes | Recommended for updates. Toolbox is an AppImage/tarball (unverified). |
| Tarball | download `ideaIC-*.tar.gz` from https://www.jetbrains.com/idea/download/ | no (in `~/.local/opt`) | yes | Launch `bin/idea.sh`. |

## Manual install
1. Download `ideaIC-<version>.tar.gz` from https://www.jetbrains.com/idea/download/#section=linux (unverified URL).
2. `mkdir -p ~/.local/opt && tar -xzf ~/Downloads/ideaIC-*.tar.gz -C ~/.local/opt`.
3. Run `~/.local/opt/idea-IC-*/bin/idea.sh`.
4. Check: the first-run wizard starts.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| `Unable to load JDK` or IDE will not start | Bundled JBR issue or missing libs. | Install X11/GTK libs listed in JetBrains docs (unverified). |
| Blank window or font problems on Wayland | Wayland rendering. | Set `-Dsun.java2d.xrender=...` per JetBrains docs; use `JETBRAINS_WAYLAND`-style options only if documented (unverified). |
| Low RAM, slow indexing | Default heap too large. | Edit `Help > Edit Custom VM Options`. |
| Flatpak cannot see project files | Sandbox. | `flatpak override --user --filesystem=xdg-documents com.jetbrains.IntelliJ-IDEA-Community` (unverified). |

## Sources
- https://www.jetbrains.com/idea/download/
- https://www.jetbrains.com/toolbox-app/
- https://flathub.org (search for IntelliJ, unverified)
