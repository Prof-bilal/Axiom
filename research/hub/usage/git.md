# Git

## When to use
- You want a full history of changes to a project, with the ability to go back to any earlier snapshot.
- You are working on code with others and need to combine, review and share changes.
- You want to try a change on a separate branch before it lands in the main line.
- You are keeping a copy of a project on several machines, each with the full history.

## How it works
- A repository is a set of files plus its recorded history; each commit is a snapshot of chosen changes.
- Files are tracked or untracked; edits move a tracked file to modified, and git add stages it.
- git status shows each file's state, and git diff shows changes before or after staging.
- git commit records the staged content as a new snapshot with a message.
- Each clone holds the full history, so you can work offline and sync later.

## Not for
- Backing up large binary files; a backup tool fits better.
- Live co-editing of documents; use a document editor.

## Sources
- https://git-scm.com/book/en/v2/Getting-Started-About-Version-Control.html
- https://git-scm.com/book/en/v2/Git-Basics-Recording-Changes-to-the-Repository.html
