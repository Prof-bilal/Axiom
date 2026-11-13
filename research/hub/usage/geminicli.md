# Gemini CLI
## When to use
- You want a terminal agent powered by Google's Gemini models.
- You want file references with `@` and slash commands in one prompt.
- You want to plan changes in a read-only mode before editing with `/plan`.
- You want to extend it with MCP servers or custom commands.
## How it works
- Install with npm (`@google/gemini-cli`) and start `gemini` in a project folder.
- `@<path>` injects a file or directory into the prompt; git-ignored files are excluded by default.
- Slash commands include `/chat` and `/resume`, `/model`, `/mcp`, `/memory`, `/init`, and `/plan`.
- Sandboxing and trusted folders limit tool execution.
## Not for
- Check first: the official page says Gemini CLI was replaced by Antigravity CLI on June 18, 2026 for unpaid tier and Google One users, so check that first.
- Users who need approval-mode details: Not found in the reference page reviewed.

## Sources
https://geminicli.com/docs/
https://geminicli.com/docs/reference/commands
