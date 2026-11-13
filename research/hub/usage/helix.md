# Helix
## When to use
- You want a terminal editor with built-in language server support and no plugin setup.
- You like selection-first editing and multiple selections.
- You want Tree-sitter based highlighting and navigation.
- You want a modal editor without writing a Lua or Vimscript config.
## How it works
- Normal mode navigates and runs commands; insert mode (`i`) types text; select/extend mode (`v`) makes selections.
- You select text first, then act on it (for example `c` to change), and multiple selections act together.
- A fuzzy file picker jumps to files and buffers.
- Documentation is at docs.helix-editor.com; `:health` and language config details: Not found.
## Not for
- Users who want to script the editor heavily or use the Vim plugin ecosystem; use Neovim.
- Users who want a GUI with menus and point-and-click; use VS Code or Zed.

## Sources
https://helix-editor.com/
https://docs.helix-editor.com/usage.html
