# PostgreSQL

## When to use
- You need an open-source, standards-oriented relational database for a new application.
- You want a database that runs on Linux with no per-seat licensing questions.
- You need a server that multiple clients or applications can connect to over the network.
- You want to learn SQL with a mature, widely documented engine.

## How it works
- It uses a client/server model: the `postgres` server process manages the data files and accepts connections.
- Each client connection gets its own server process; clients can run on other hosts over TCP/IP.
- A server hosts databases, each a separate namespace for tables and other objects.
- Data lives in tables of rows and typed columns, defined and queried with SQL (`CREATE`, `INSERT`, `SELECT`).
- `psql` is the interactive client: run SQL and backslash commands such as `\l` (list databases) and `\dt` (list tables).

## Not for
- Teams that have already standardized on SQL Server features such as SQL Server Agent or T-SQL-specific code.
- Embedded, single-file storage inside an app; SQLite is lighter.
- Very small or throwaway local datasets where a full server adds needless overhead.

## Sources
- https://www.postgresql.org/docs/current/tutorial-start.html
- https://www.postgresql.org/docs/current/tutorial-arch.html
