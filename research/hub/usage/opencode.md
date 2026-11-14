# OpenCode
## When to use
- You want a terminal coding agent that is not tied to one model provider.
- You want to switch between models and providers from inside one tool.
- You work in a terminal and want a TUI with sessions you can resume.
- You want to add your own commands, plugins, or MCP servers.
## How it works
- Run `opencode` in a project directory to open the TUI.
- Connect a provider with `/connect`, then choose a model with `/models`.
- `/new` starts a session; `/sessions` lists and switches sessions.
- Reference files with `@`, run shell commands with `!`, and use `/undo` and `/redo` for file changes in a Git repo.
## Not for
- Users who want a fully managed agent with no API key or provider setup; use Claude Code or Codex.
- Non-terminal workflows; use an IDE agent or a desktop tool instead.

## Sources
https://opencode.ai/docs/
https://opencode.ai/docs/tui/
