# Aider
## When to use
- You want AI pair programming in the terminal with a small, explicit set of files.
- You want every AI change committed to Git so it is easy to review and undo.
- You want to choose between code, ask, and architect modes for each task.
- You want to ask questions about code without letting the tool edit anything.
## How it works
- Add the files to edit with `aider <files>` on the command line or `/add` in the chat.
- Aider pulls in related context automatically through a repo map.
- Use `/ask` to discuss without changes, `/code` to edit, and `/architect` for a two-model plan-then-edit flow.
- Use `/undo` to revert AI changes; changes are committed to Git.
- `--message` and `--yes` scripting flags: Not found in the pages I could read.
## Not for
- Large multi-step agentic work across a whole repo with autonomous tool use; use Claude Code or Codex.
- Projects not in Git, where auto-commit and undo are less useful.

## Sources
https://aider.chat/docs/usage.html
https://aider.chat/docs/usage/modes.html
