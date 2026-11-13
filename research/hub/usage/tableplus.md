# TablePlus

## When to use
- You work across several databases (PostgreSQL, MySQL, SQLite, MongoDB, Redis, and more) and want one native app.
- You edit table data by hand and want inline editing, filters, and import/export.
- You make changes to production-like data and want Safe Mode to guard against accidental edits.
- You want a fast, lightweight GUI rather than a Java-based tool.

## How it works
- Create a connection and pick the database driver; many connections can be open at once.
- The query editor (Cmd+Return or Cmd+E) runs the selected query with Run Current, or every statement with Run All.
- The data browser supports inline editing, advanced filters, and import/export; a right-click export covers only the current page.
- Safe Mode has levels that require the database password before changes are sent; GUI edits wait in Code Review until committed.

## Not for
- Scripted or repeatable schema changes; use migration tools.
- Not found: the pages used give no comparison with other GUIs or licensing terms.

## Sources
- https://tableplus.com/docs/
- https://docs.tableplus.com/gui-tools/code-review-and-safemode/safe-mode
