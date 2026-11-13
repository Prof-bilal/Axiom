# SQLite

## When to use
- An application or device needs local structured storage without running a database server.
- You are shipping a desktop or mobile app whose data should be one file that is easy to copy or back up.
- You want a local cache, test stand-in, or offline store for a larger database.
- You are analysing imported CSV data or teaching SQL with a simple setup.

## How it works
- SQLite is a library linked into the application, which issues SQL directly. There is no separate server.
- The whole database is a single cross-platform file.
- Many readers can run at once, but only one writer can write at any instant; writers queue behind a short lock.
- No administration is needed, so it suits devices and apps that must run unattended.

## Not for
- Many clients or machines writing to one database over a network; use client/server engines such as PostgreSQL.
- Write-heavy, high-traffic sites that need several servers or many simultaneous writers.
- Very large datasets approaching terabyte scale, which the official page says should use client/server well before that point.

## Sources
- https://www.sqlite.org/whentouse.html
