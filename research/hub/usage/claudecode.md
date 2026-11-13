# Claude Code
## When to use
- You want an agent that reads a codebase, edits many files, runs commands, and verifies the result.
- You want to automate tasks in the terminal, for example writing tests and fixing failures.
- You want commits and pull requests created from the command line.
- You want repeatable project rules through CLAUDE.md, skills, and hooks.
## How it works
- Install, then run `claude` in a project directory; it prompts you to log in on first use.
- Describe a task in plain language; it plans, edits files across the project, and checks the result.
- Use `claude -p "..."` for non-interactive, scriptable runs and pipelines.
- CLAUDE.md is read at the start of each session; MCP connects external tools; hooks run shell commands around actions.
## Not for
- Users who want a free, offline-only tool; it needs a subscription or API account.
- Quick single-file edits where a plain editor is faster; use VS Code or Zed.

## Sources
https://code.claude.com/docs/en/overview
