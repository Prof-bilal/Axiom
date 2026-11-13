# Microsoft SQL Server (sqlserver)

Status: unverified this session. Server runs in a container on Linux.

## Install options

| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Container (Docker) | `docker run -e ACCEPT_EULA=Y -e MSSQL_SA_PASSWORD=<set-your-own> -p 1433:1433 -d mcr.microsoft.com/mssql/server:2022-latest` | root or docker group | yes | Unverified tag. Password must be set by the user; do not store it in the repo. |
| Vendor package | follow https://learn.microsoft.com/sql/linux/ (apt/dnf/zypper repo, `mssql-server`, then `sudo /opt/mssql/bin/mssql-conf setup`) | yes | yes | Unverified. |

## Manual install
Use the vendor package steps in Microsoft Learn; run `mssql-conf setup` yourself to set the SA password.

## Possible errors and fixes

| Error / symptom | Cause | Fix |
|---|---|---|
| Container exits: password policy | Weak SA password. | Use a strong password meeting policy. |
| Needs more than 2 GB RAM | Low RAM. | Give the container or VM more memory (Microsoft minimum, unverified). |
| `ACCEPT_EULA` error | EULA not accepted. | Set `ACCEPT_EULA=Y` yourself after reading the licence. |

## Sources
- https://learn.microsoft.com/sql/linux/ (unverified this session)
