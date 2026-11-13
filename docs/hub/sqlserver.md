# SQL Server 2022

- Id: `sqlserver` · Category: Development · Weight: heavy · Licence (catalog): Free developer edition
- Catalog sources: manual `https://learn.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker`
- Install verified: yes · Screenshots: 0 of 3 · Logo: yes

## Overview
Microsoft SQL Server is a relational database server with a Linux build, offered in Standard, Enterprise and free Developer editions. It is for teams running Microsoft-stack or enterprise workloads on Linux.

## Facts
- Name: Microsoft SQL Server (2025 for Linux)
- Publisher: Microsoft
- Official website: https://learn.microsoft.com/sql/linux/sql-server-linux-setup
- Licence: commercial; Developer editions are free for development and test only, not production. Source: https://learn.microsoft.com/sql/linux/sql-server-linux-editions-and-components-2025 (search summary)
- Latest version: not found
- Typical install size: not found
- Minimum RAM: 2 GB memory. Source: https://learn.microsoft.com/sql/linux/sql-server-linux-setup (search summary; page date unclear)
- CPU: 2 GHz processor. Source: https://learn.microsoft.com/sql/linux/sql-server-linux-setup
- Disk: 6 GB disk space; XFS or ext4 file system (BTRFS not supported). Source: https://learn.microsoft.com/sql/linux/sql-server-linux-setup
- Linux distributions: RHEL 9/10 and Ubuntu 22.04/24.04 per Microsoft setup page (summary); check the support matrix.

## Logo
Bundled icon: `apps/hub/icons/sqlserver.png`.

## Screenshots
Not found. No screenshot URL recorded in this pass.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Docker container (official quickstart; free Developer edition) | `docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=<strong-password>" -e "MSSQL_PID=Developer" -p 1433:1433 --name sql1 --hostname sql1 -d mcr.microsoft.com/mssql/server:2022-latest` | docker group |
| Podman (same image, rootless) | `podman run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=<strong-password>" -p 1433:1433 --name sql1 -d mcr.microsoft.com/mssql/server:2022-latest` | no |

- The SA password must meet SQL Server's complexity rules or the container stops at start.
- SA_PASSWORD is deprecated; use MSSQL_SA_PASSWORD.
- The password is visible in process listings; change it after first start in production.
- Needs at least 2 GB RAM (4 GB recommended); SQL Server takes 80% of RAM by default unless memory.memorylimitmb is set.
- The Podman command follows the same image; it was not in Microsoft's quickstart.

- Source: https://learn.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker
- Source: https://learn.microsoft.com/en-us/sql/linux/configure/environment-variables

## Install options (research draft; unverified this session. Server runs in a container on Linux.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Container (Docker) | `docker run -e ACCEPT_EULA=Y -e MSSQL_SA_PASSWORD=<set-your-own> -p 1433:1433 -d mcr.microsoft.com/mssql/server:2022-latest` | root or docker group | yes | Unverified tag. Password must be set by the user; do not store it in the repo. |
| Vendor package | follow https://learn.microsoft.com/sql/linux/ (apt/dnf/zypper repo, `mssql-server`, then `sudo /opt/mssql/bin/mssql-conf setup`) | yes | yes | Unverified. |

## Manual install (draft)
Use the vendor package steps in Microsoft Learn; run `mssql-conf setup` yourself to set the SA password.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| Container exits: password policy | Weak SA password. | Use a strong password meeting policy. |
| Needs more than 2 GB RAM | Low RAM. | Give the container or VM more memory (Microsoft minimum, unverified). |
| `ACCEPT_EULA` error | EULA not accepted. | Set `ACCEPT_EULA=Y` yourself after reading the licence. |

## Sources
- https://learn.microsoft.com/sql/linux/
- https://learn.microsoft.com/sql/linux/sql-server-linux-editions-and-components-2025
- https://learn.microsoft.com/sql/linux/sql-server-linux-setup
