# Cursor

## When to use
- You want an AI coding agent that can read a whole codebase, plan a change, and make it.
- You are scoping a larger feature and want a planning step before code is written (Plan Mode).
- You need an agent to fix bugs and then review its own diffs before you merge.
- You work in a VS Code-style editor and want AI built into it rather than in a separate chat.

## How it works
- The core is Agent: you describe a task and it explores the code, edits files, and runs checks.
- Plan Mode drafts the approach first so you can scope the change before building.
- You choose from a set of models that differ in context size, capabilities, and price.
- Plugins, skills, MCP servers, and rules are managed in one place to customize behavior.
- Integrations connect it to Git hosts, JetBrains, Slack, and Linear.

## Not for
- Offline or fully air-gapped work; it relies on hosted models.
- Simple local tab-completion or a minimal editor; a lighter editor with a plugin may suffice.

## Sources
- https://cursor.com/docs
