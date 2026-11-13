# OpenAI Codex CLI
## When to use
- You want a terminal agent from OpenAI that reads your repo and edits files.
- You want to run repeatable tasks in scripts or CI with `codex exec`.
- You want to review uncommitted changes or a branch with `/review` before committing.
- You want to hand longer work to Codex cloud.
## How it works
- Run `codex` in a project directory and sign in.
- Describe a task in the interactive session; Codex inspects files, edits them, and runs installed tools.
- `/permissions` controls when Codex can edit files or run commands without asking.
- `codex resume` reopens saved chats; create Git checkpoints before and after tasks to revert.
## Not for
- Users who want a model-agnostic agent across many providers; use OpenCode or Aider.
- Users who want the Claude family of models; use Claude Code.

## Sources
https://learn.chatgpt.com/docs/codex/cli
