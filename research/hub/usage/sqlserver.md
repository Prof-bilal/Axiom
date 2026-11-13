# SQL Server 2022

## When to use
- You need a Microsoft-compatible enterprise relational database running on a Linux server or VM.
- Your application or team already uses SQL Server features such as T-SQL, SQL Server Agent jobs, or Always On availability groups.
- You want the same database engine and feature set that runs on Windows, on Linux.
- You want a Linux container for local testing or CI, with an image from Microsoft Container Registry.

## How it works
- It uses the same Database Engine as SQL Server on Windows, so features behave consistently across platforms.
- Install directly on a supported Linux machine or VM (RHEL, Ubuntu, SLES, or Azure VMs), or run it in a Linux container.
- Connect with `sqlcmd`, the MSSQL extension for VS Code, SSMS (from Windows), or SSDT.
- SQL Server Agent is available and enabled with the `mssql-conf` utility.
- Some features, such as PolyBase, Machine Learning Services, and full-text search, need extra packages.
- WSL 2 installs are for development only and are not supported for production.

## Not for
- Small, lightweight projects that want an open-source engine with no licensing questions; PostgreSQL or MariaDB fit better.
- WSL 2 production workloads, which Microsoft explicitly does not support.
- Licensing and edition questions: the Linux overview points to Microsoft's license terms rather than stating them. Not found there.

## Sources
- https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-overview
