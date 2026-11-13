# Azure Data Studio

- Id: `azuredatastudio` · Category: Development · Weight: medium · Licence (catalog): Microsoft EULA
- Catalog sources: manual `https://learn.microsoft.com/en-us/azure-data-studio/whats-happening-azure-data-studio`
- Install verified: yes · Screenshots: 0 of 3 · Logo: yes

## Overview
Azure Data Studio was Microsoft's cross-platform database tool for SQL Server and Azure SQL. It is retired and no longer supported, so this entry is for users evaluating legacy installs or migration.

## Facts
- Name: Azure Data Studio
- Publisher: Microsoft
- Official website: https://learn.microsoft.com/sql/azure-data-studio/what-is
- Licence: MIT (per the project README). Source: https://cdn.jsdelivr.net/gh/microsoft/azuredatastudio@main/README.md
- Status: retired on February 28, 2026, no longer supported. Source: https://devblogs.microsoft.com/azure-sql/azure-data-studio-retirement/ (search summary)
- Latest version: not found; no current Linux download path confirmed
- Typical install size: not found
- Minimum RAM: not found
- CPU: not found
- Disk: not found
- Replacement suggested by Microsoft: Visual Studio Code with the MSSQL extension. Source: search summary of Microsoft guidance

## Logo
Bundled icon: `apps/hub/icons/azuredatastudio.png`.

## Screenshots
Not found. No screenshot URL recorded in this pass.

## Install (verified against a source)
| Method | Command | Needs root |
|---|---|---|
| Retired; use VS Code with the MSSQL extension | `flatpak install flathub com.visualstudio.code (then install the MSSQL extension)` | no |

- Azure Data Studio support ended on 28 February 2026. Microsoft recommends VS Code with the MSSQL extension, and SSMS for full administration.
- Remove or mark retired in the catalog.

- Source: https://learn.microsoft.com/en-us/azure-data-studio/whats-happening-azure-data-studio
- Source: https://devblogs.microsoft.com/azure-sql/azure-data-studio-is-retired-move-your-azure-sql-workflow-to-vs-code-in-10-minutes/

## Install options (research draft; unverified this session. Microsoft has announced retirement of Azure Data Studio; check current status before listing.)
| Method | Command (argv) | Needs root | Needs network | Notes |
|---|---|---|---|---|
| Tarball | download from Microsoft's Azure Data Studio page, extract to `~/.local/opt`, run `azuredatastudio` | no | yes | Unverified URL and filename. |
| .deb / .rpm | `sudo apt install ./azuredatastudio-*.deb` | yes | yes | Unverified. |
| Snap / Flatpak | unverified | varies | yes | Check stores. |

## Manual install (draft)
Download the tarball and run its launcher; check the app opens.

## Possible errors and fixes (draft)
| Error / symptom | Cause | Fix |
|---|---|---|
| Keyring errors on start | No secret service. | Install and run gnome-keyring or KWallet (unverified). |
| Sandbox error | Electron sandbox. | Fix chrome-sandbox permissions (unverified). |

## Sources
- https://cdn.jsdelivr.net/gh/microsoft/azuredatastudio@main/README.md
- https://learn.microsoft.com/sql/azure-data-studio/
- https://learn.microsoft.com/sql/azure-data-studio/what-is
