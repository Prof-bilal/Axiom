# pgAdmin 4

## When to use
- You administer PostgreSQL servers and want a graphical way to create, change, and inspect database objects.
- You need to run ad hoc SQL and inspect results in a grid before writing scripts.
- You want to check a slow query's execution plan with Explain or Explain Analyze.
- You want to design or visualise a schema with the ERD tool.

## How it works
- Connect to one or more PostgreSQL servers, which are organised into server groups in the object browser tree.
- Use the Query Tool to type SQL and run the whole script, a selection, or the statement at the cursor.
- The Data Output panel shows results in a grid that you can copy, save to CSV, or edit when the result is updatable.
- The Explain panel shows the execution plan (graphical, table, or statistics views); Messages shows errors and timings.

## Not for
- Databases other than PostgreSQL; use a multi-database GUI such as DBeaver or TablePlus instead.
- Automated or scripted administration; use psql or migration tooling for repeatable changes.

## Sources
- https://www.pgadmin.org/docs/pgadmin4/latest/index.html
- https://www.pgadmin.org/docs/pgadmin4/latest/query_tool.html
