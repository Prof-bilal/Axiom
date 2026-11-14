# MariaDB

## When to use
- You are moving from MySQL and want a drop-in, MySQL-derived relational database.
- You want an open-source server with all code under GPL, LGPL, or BSD and no closed-source modules.
- You need replication or parallel replication for read scaling or availability.
- You want built-in features such as window functions, recursive CTEs, CHECK constraints, and system-versioned tables.

## How it works
- It is an open-source relational database server derived from MySQL.
- Data is held by storage engines; ColumnStore suits analytics, and MyRocks offers strong compression.
- Documentation covers quickstart install, server usage, security (users, roles, authentication), and high availability.
- Clients connect with the command-line and graphical tools listed under Clients & Utilities, then run SQL.
- Compatibility with MySQL is described per release in its compatibility pages; check those before a migration.

## Not for
- Projects that need PostgreSQL-specific features or its extension ecosystem; PostgreSQL fits better.
- Enterprise T-SQL workloads; SQL Server 2022 fits better.
- Cluster-wide clustering details such as Galera: the pages I read did not describe them. Not found.

## Sources
- https://mariadb.com/docs/server/
- https://mariadb.com/kb/en/mariadb-vs-mysql-features/
