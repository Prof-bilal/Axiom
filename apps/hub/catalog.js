.pragma library

// Axiom Hub catalog. size_mb and min_ram_gb are null where no reliable figure was found.
// verified: true only when the install source was confirmed in research; the others are
// shown with a 'not verified' note and install only if the source is reachable.
var CATALOG = [
 {
  "id": "vscode",
  "name": "Visual Studio Code",
  "category": "Development",
  "summary": "Powerful and lightweight source code editor.",
  "publisher": "Microsoft",
  "license": "Proprietary",
  "sources": [
   {
    "type": "flatpak",
    "ref": "com.visualstudio.code"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 4,
  "weight": "heavy",
  "light_alt": "zed",
  "featured": true,
  "popular": true,
  "verified": true
 },
 {
  "id": "vscodium",
  "name": "VSCodium",
  "category": "Development",
  "summary": "VS Code without telemetry.",
  "publisher": "VSCodium",
  "license": "MIT",
  "sources": [
   {
    "type": "flatpak",
    "ref": "com.vscodium.codium"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 4,
  "weight": "heavy",
  "light_alt": "helix",
  "featured": false,
  "popular": true,
  "verified": true
 },
 {
  "id": "androidstudio",
  "name": "Android Studio",
  "category": "Development",
  "summary": "IDE for Android development.",
  "publisher": "Google",
  "license": "Apache-2.0",
  "sources": [
   {
    "type": "flatpak",
    "ref": "com.google.AndroidStudio"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 8,
  "weight": "heavy",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "intellij",
  "name": "IntelliJ IDEA Community",
  "category": "Development",
  "summary": "JVM IDE from JetBrains.",
  "publisher": "JetBrains",
  "license": "Apache-2.0",
  "sources": [
   {
    "type": "flatpak",
    "ref": "com.jetbrains.IntelliJ-IDEA-Community"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 4,
  "weight": "heavy",
  "light_alt": "kate",
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "zed",
  "name": "Zed",
  "category": "Development",
  "summary": "High-performance code editor written in Rust.",
  "publisher": "Zed Industries",
  "license": "GPL-3.0",
  "sources": [
   {
    "type": "flatpak",
    "ref": "dev.zed.Zed"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 2,
  "weight": "light",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "neovim",
  "name": "Neovim",
  "category": "Development",
  "summary": "Modal terminal editor, a Vim fork.",
  "publisher": "Neovim",
  "license": "Apache-2.0",
  "sources": [
   {
    "type": "pacman",
    "ref": "neovim"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 1,
  "weight": "light",
  "light_alt": null,
  "featured": false,
  "popular": true,
  "verified": true
 },
 {
  "id": "helix",
  "name": "Helix",
  "category": "Development",
  "summary": "Modal terminal editor with built-in language server support.",
  "publisher": "Helix",
  "license": "MPL-2.0",
  "sources": [
   {
    "type": "pacman",
    "ref": "helix"
   }
  ],
  "size_mb": 208,
  "min_ram_gb": 1,
  "weight": "light",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "emacs",
  "name": "Emacs",
  "category": "Development",
  "summary": "Extensible editor; the terminal build is light.",
  "publisher": "GNU",
  "license": "GPL-3.0",
  "sources": [
   {
    "type": "flatpak",
    "ref": "org.gnu.emacs"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 1,
  "weight": "light",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "kate",
  "name": "Kate",
  "category": "Development",
  "summary": "KDE text editor and IDE-lite.",
  "publisher": "KDE",
  "license": "GPL-2.0",
  "sources": [
   {
    "type": "flatpak",
    "ref": "org.kde.kate"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 1,
  "weight": "light",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "sublime",
  "name": "Sublime Text",
  "category": "Development",
  "summary": "Fast proprietary text editor.",
  "publisher": "Sublime HQ",
  "license": "Proprietary",
  "sources": [
   {
    "type": "manual",
    "ref": "https://www.sublimetext.com/download"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 1,
  "weight": "light",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "geany",
  "name": "Geany",
  "category": "Development",
  "summary": "Lightweight GTK IDE.",
  "publisher": "Geany",
  "license": "GPL-2.0",
  "sources": [
   {
    "type": "pacman",
    "ref": "geany"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 1,
  "weight": "light",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "lapce",
  "name": "Lapce",
  "category": "Development",
  "summary": "Rust code editor.",
  "publisher": "Lapce",
  "license": "Apache-2.0",
  "sources": [
   {
    "type": "flatpak",
    "ref": "dev.lapce.lapce"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 1,
  "weight": "light",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "opencode",
  "name": "OpenCode",
  "category": "Development",
  "summary": "Terminal coding agent. Needs a model provider.",
  "publisher": "SST",
  "license": "MIT",
  "sources": [
   {
    "type": "npm",
    "ref": "opencode-ai"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 1,
  "weight": "light",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "codex",
  "name": "OpenAI Codex CLI",
  "category": "Development",
  "summary": "Terminal coding agent from OpenAI.",
  "publisher": "OpenAI",
  "license": "Apache-2.0",
  "sources": [
   {
    "type": "npm",
    "ref": "@openai/codex"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 1,
  "weight": "light",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "claudecode",
  "name": "Claude Code",
  "category": "Development",
  "summary": "Terminal coding agent from Anthropic.",
  "publisher": "Anthropic",
  "license": "Proprietary",
  "sources": [
   {
    "type": "npm",
    "ref": "@anthropic-ai/claude-code"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 4,
  "weight": "light",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "aider",
  "name": "Aider",
  "category": "Development",
  "summary": "AI pair programming in your terminal.",
  "publisher": "Aider",
  "license": "Apache-2.0",
  "sources": [
   {
    "type": "pip",
    "ref": "aider-chat"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 1,
  "weight": "light",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "geminicli",
  "name": "Gemini CLI",
  "category": "Development",
  "summary": "Terminal AI agent from Google.",
  "publisher": "Google",
  "license": "Apache-2.0",
  "sources": [
   {
    "type": "npm",
    "ref": "@google/gemini-cli"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 1,
  "weight": "light",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "goose",
  "name": "Goose",
  "category": "Development",
  "summary": "AI agent for the desktop and terminal.",
  "publisher": "Block",
  "license": "Apache-2.0",
  "sources": [
   {
    "type": "manual",
    "ref": "https://github.com/block/goose"
   }
  ],
  "size_mb": null,
  "min_ram_gb": null,
  "weight": "light",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "lmstudio",
  "name": "LM Studio",
  "category": "Development",
  "summary": "Run local language models with a GUI.",
  "publisher": "LM Studio",
  "license": "Free, closed source",
  "sources": [
   {
    "type": "manual",
    "ref": "https://lmstudio.ai"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 16,
  "weight": "heavy",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "ollama",
  "name": "Ollama",
  "category": "Development",
  "summary": "Local model runner.",
  "publisher": "Ollama",
  "license": "MIT",
  "sources": [
   {
    "type": "manual",
    "ref": "https://ollama.com/download"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 8,
  "weight": "heavy",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "jan",
  "name": "Jan",
  "category": "Development",
  "summary": "Offline ChatGPT alternative.",
  "publisher": "Jan",
  "license": "AGPL-3.0 (disputed)",
  "sources": [
   {
    "type": "manual",
    "ref": "https://jan.ai"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 8,
  "weight": "heavy",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "openwebui",
  "name": "Open WebUI",
  "category": "Development",
  "summary": "Self-hosted web UI for LLMs.",
  "publisher": "Open WebUI",
  "license": "MIT",
  "sources": [
   {
    "type": "pip",
    "ref": "open-webui"
   }
  ],
  "size_mb": null,
  "min_ram_gb": null,
  "weight": "medium",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "cursor",
  "name": "Cursor",
  "category": "Development",
  "summary": "AI code editor (VS Code fork).",
  "publisher": "Anysphere",
  "license": "Proprietary",
  "sources": [
   {
    "type": "manual",
    "ref": "https://cursor.com"
   }
  ],
  "size_mb": null,
  "min_ram_gb": null,
  "weight": "medium",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "gpt4all",
  "name": "GPT4All",
  "category": "Development",
  "summary": "Offline desktop chat with local models.",
  "publisher": "Nomic AI",
  "license": "MIT",
  "sources": [
   {
    "type": "flatpak",
    "ref": "io.gpt4all.gpt4all"
   },
   {
    "type": "manual",
    "ref": "https://gpt4all.io"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 16,
  "weight": "heavy",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "docker",
  "name": "Docker",
  "category": "Development",
  "summary": "Build, share and run containers.",
  "publisher": "Docker",
  "license": "Apache-2.0",
  "sources": [
   {
    "type": "pacman",
    "ref": "docker"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 2,
  "weight": "medium",
  "light_alt": "podman",
  "featured": false,
  "popular": true,
  "verified": true
 },
 {
  "id": "podman",
  "name": "Podman",
  "category": "Development",
  "summary": "Daemonless, rootless container engine.",
  "publisher": "Red Hat",
  "license": "Apache-2.0",
  "sources": [
   {
    "type": "pacman",
    "ref": "podman"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 1,
  "weight": "light",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "dockerdesktop",
  "name": "Docker Desktop",
  "category": "Development",
  "summary": "GUI and VM-backed Docker for desktops.",
  "publisher": "Docker",
  "license": "Proprietary",
  "sources": [
   {
    "type": "manual",
    "ref": "https://docs.docker.com/desktop/setup/install/linux/"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 4,
  "weight": "heavy",
  "light_alt": "podman",
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "colima",
  "name": "Colima",
  "category": "Development",
  "summary": "Container runtime in a Lima VM.",
  "publisher": "Colima",
  "license": "MIT",
  "sources": [
   {
    "type": "manual",
    "ref": "https://github.com/abiosoft/colima"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 2,
  "weight": "medium",
  "light_alt": "podman",
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "portainer",
  "name": "Portainer CE",
  "category": "Development",
  "summary": "Web UI for Docker and Podman.",
  "publisher": "Portainer",
  "license": "zlib",
  "sources": [
   {
    "type": "manual",
    "ref": "https://www.portainer.io"
   }
  ],
  "size_mb": null,
  "min_ram_gb": null,
  "weight": "medium",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "kubectl",
  "name": "kubectl",
  "category": "Development",
  "summary": "Kubernetes command-line tool.",
  "publisher": "Kubernetes",
  "license": "Apache-2.0",
  "sources": [
   {
    "type": "pacman",
    "ref": "kubectl"
   }
  ],
  "size_mb": null,
  "min_ram_gb": null,
  "weight": "light",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "helm",
  "name": "Helm",
  "category": "Development",
  "summary": "Kubernetes package manager.",
  "publisher": "CNCF",
  "license": "Apache-2.0",
  "sources": [
   {
    "type": "pacman",
    "ref": "helm"
   }
  ],
  "size_mb": null,
  "min_ram_gb": null,
  "weight": "light",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "k9s",
  "name": "k9s",
  "category": "Development",
  "summary": "Terminal UI for Kubernetes.",
  "publisher": "Derailed",
  "license": "Apache-2.0",
  "sources": [
   {
    "type": "pacman",
    "ref": "k9s"
   }
  ],
  "size_mb": null,
  "min_ram_gb": null,
  "weight": "light",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "terraform",
  "name": "Terraform",
  "category": "Development",
  "summary": "Infrastructure as code CLI.",
  "publisher": "HashiCorp",
  "license": "BSL",
  "sources": [
   {
    "type": "pacman",
    "ref": "terraform"
   }
  ],
  "size_mb": null,
  "min_ram_gb": null,
  "weight": "light",
  "light_alt": "opentofu",
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "opentofu",
  "name": "OpenTofu",
  "category": "Development",
  "summary": "Open-source Terraform fork.",
  "publisher": "OpenTofu",
  "license": "MPL-2.0",
  "sources": [
   {
    "type": "pacman",
    "ref": "opentofu"
   }
  ],
  "size_mb": null,
  "min_ram_gb": null,
  "weight": "light",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "ansible",
  "name": "Ansible",
  "category": "Development",
  "summary": "Agentless configuration management.",
  "publisher": "Red Hat",
  "license": "GPL-3.0",
  "sources": [
   {
    "type": "pacman",
    "ref": "ansible"
   }
  ],
  "size_mb": null,
  "min_ram_gb": null,
  "weight": "light",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "vagrant",
  "name": "Vagrant",
  "category": "Development",
  "summary": "Scripted VM environments.",
  "publisher": "HashiCorp",
  "license": "BSL",
  "sources": [
   {
    "type": "pacman",
    "ref": "vagrant"
   }
  ],
  "size_mb": null,
  "min_ram_gb": null,
  "weight": "heavy",
  "light_alt": "podman",
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "virtualbox",
  "name": "VirtualBox",
  "category": "System",
  "summary": "Type-2 hypervisor.",
  "publisher": "Oracle",
  "license": "GPL-2.0",
  "sources": [
   {
    "type": "pacman",
    "ref": "virtualbox"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 4,
  "weight": "heavy",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "lens",
  "name": "Lens",
  "category": "Development",
  "summary": "Desktop Kubernetes IDE.",
  "publisher": "Lens",
  "license": "MIT",
  "sources": [
   {
    "type": "manual",
    "ref": "https://k8slens.dev"
   }
  ],
  "size_mb": null,
  "min_ram_gb": null,
  "weight": "heavy",
  "light_alt": "k9s",
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "sqlserver",
  "name": "SQL Server 2022",
  "category": "Development",
  "summary": "Enterprise relational database. Linux needs a container or repo install.",
  "publisher": "Microsoft",
  "license": "Free developer edition",
  "sources": [
   {
    "type": "manual",
    "ref": "https://learn.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 2,
  "weight": "heavy",
  "light_alt": "postgresql",
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "postgresql",
  "name": "PostgreSQL",
  "category": "Development",
  "summary": "Advanced open-source relational database.",
  "publisher": "PostgreSQL",
  "license": "PostgreSQL",
  "sources": [
   {
    "type": "pacman",
    "ref": "postgresql"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 2,
  "weight": "medium",
  "light_alt": "sqlitebrowser",
  "featured": false,
  "popular": true,
  "verified": true
 },
 {
  "id": "mariadb",
  "name": "MariaDB",
  "category": "Development",
  "summary": "MySQL-compatible relational database.",
  "publisher": "MariaDB",
  "license": "GPL-2.0",
  "sources": [
   {
    "type": "pacman",
    "ref": "mariadb"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 1,
  "weight": "medium",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "mongodb",
  "name": "MongoDB Community",
  "category": "Development",
  "summary": "Document database.",
  "publisher": "MongoDB",
  "license": "SSPL",
  "sources": [
   {
    "type": "manual",
    "ref": "https://wiki.archlinux.org/title/MongoDB"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 4,
  "weight": "heavy",
  "light_alt": "sqlitebrowser",
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "redis",
  "name": "Valkey (Redis-compatible)",
  "category": "Development",
  "summary": "In-memory key-value store. Arch replaced Redis with Valkey in April 2025.",
  "publisher": "Linux Foundation",
  "license": "BSD-3-Clause",
  "sources": [
   {
    "type": "pacman",
    "ref": "valkey"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 1,
  "weight": "light",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "sqlite",
  "name": "SQLite",
  "category": "Development",
  "summary": "Embedded file database.",
  "publisher": "SQLite",
  "license": "Public domain",
  "sources": [
   {
    "type": "pacman",
    "ref": "sqlite"
   }
  ],
  "size_mb": null,
  "min_ram_gb": null,
  "weight": "light",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "pgadmin",
  "name": "pgAdmin 4",
  "category": "Development",
  "summary": "PostgreSQL administration GUI.",
  "publisher": "pgAdmin",
  "license": "PostgreSQL",
  "sources": [
   {
    "type": "manual",
    "ref": "https://www.pgadmin.org/download/"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 1,
  "weight": "medium",
  "light_alt": "sqlitebrowser",
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "azuredatastudio",
  "name": "Azure Data Studio",
  "category": "Development",
  "summary": "Retired in February 2026. Use VS Code with the MSSQL extension instead.",
  "publisher": "Microsoft",
  "license": "Microsoft EULA",
  "sources": [
   {
    "type": "manual",
    "ref": "https://learn.microsoft.com/en-us/azure-data-studio/whats-happening-azure-data-studio"
   }
  ],
  "size_mb": null,
  "min_ram_gb": null,
  "weight": "medium",
  "light_alt": "vscode",
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "tableplus",
  "name": "TablePlus",
  "category": "Development",
  "summary": "Native multi-database GUI.",
  "publisher": "TablePlus",
  "license": "Proprietary",
  "sources": [
   {
    "type": "manual",
    "ref": "https://tableplus.com/linux/install"
   }
  ],
  "size_mb": null,
  "min_ram_gb": null,
  "weight": "medium",
  "light_alt": "sqlitebrowser",
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "dbeaver",
  "name": "DBeaver Community",
  "category": "Development",
  "summary": "Universal database GUI (Java).",
  "publisher": "DBeaver",
  "license": "Apache-2.0",
  "sources": [
   {
    "type": "flatpak",
    "ref": "io.dbeaver.DBeaverCommunity"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 4,
  "weight": "heavy",
  "light_alt": "sqlitebrowser",
  "featured": false,
  "popular": true,
  "verified": true
 },
 {
  "id": "sqlitebrowser",
  "name": "DB Browser for SQLite",
  "category": "Development",
  "summary": "Light GUI for SQLite files.",
  "publisher": "DB4S",
  "license": "GPL-3.0",
  "sources": [
   {
    "type": "flatpak",
    "ref": "org.sqlitebrowser.sqlitebrowser"
   }
  ],
  "size_mb": 17,
  "min_ram_gb": 1,
  "weight": "light",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "firefox",
  "name": "Firefox",
  "category": "Internet",
  "summary": "Fast and private web browser.",
  "publisher": "Mozilla",
  "license": "MPL-2.0",
  "sources": [
   {
    "type": "flatpak",
    "ref": "org.mozilla.firefox"
   },
   {
    "type": "pacman",
    "ref": "firefox"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 2,
  "weight": "medium",
  "light_alt": null,
  "featured": true,
  "popular": false,
  "verified": true
 },
 {
  "id": "chromium",
  "name": "Chromium",
  "category": "Internet",
  "summary": "Open-source web browser.",
  "publisher": "Chromium",
  "license": "BSD",
  "sources": [
   {
    "type": "flatpak",
    "ref": "org.chromium.Chromium"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 2,
  "weight": "heavy",
  "light_alt": "firefox",
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "brave",
  "name": "Brave",
  "category": "Internet",
  "summary": "Chromium browser with privacy features.",
  "publisher": "Brave",
  "license": "MPL-2.0",
  "sources": [
   {
    "type": "flatpak",
    "ref": "com.brave.Browser"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 2,
  "weight": "heavy",
  "light_alt": "firefox",
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "thunderbird",
  "name": "Thunderbird",
  "category": "Internet",
  "summary": "Email, calendar and contacts.",
  "publisher": "Mozilla",
  "license": "MPL-2.0",
  "sources": [
   {
    "type": "flatpak",
    "ref": "org.mozilla.thunderbird"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 2,
  "weight": "medium",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "discord",
  "name": "Discord",
  "category": "Internet",
  "summary": "Chat, voice and communities.",
  "publisher": "Discord",
  "license": "Proprietary",
  "sources": [
   {
    "type": "flatpak",
    "ref": "com.discordapp.Discord"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 2,
  "weight": "medium",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "libreoffice",
  "name": "LibreOffice",
  "category": "Productivity",
  "summary": "Full office suite.",
  "publisher": "The Document Foundation",
  "license": "MPL-2.0",
  "sources": [
   {
    "type": "flatpak",
    "ref": "org.libreoffice.LibreOffice"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 2,
  "weight": "medium",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "onlyoffice",
  "name": "OnlyOffice",
  "category": "Productivity",
  "summary": "Office suite with Microsoft format support.",
  "publisher": "ONLYOFFICE",
  "license": "AGPL-3.0",
  "sources": [
   {
    "type": "flatpak",
    "ref": "org.onlyoffice.desktopeditors"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 2,
  "weight": "medium",
  "light_alt": "libreoffice",
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "obsidian",
  "name": "Obsidian",
  "category": "Productivity",
  "summary": "A second brain for your thoughts.",
  "publisher": "Obsidian",
  "license": "Proprietary",
  "sources": [
   {
    "type": "flatpak",
    "ref": "md.obsidian.Obsidian"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 1,
  "weight": "light",
  "light_alt": null,
  "featured": false,
  "popular": true,
  "verified": true
 },
 {
  "id": "keepassxc",
  "name": "KeePassXC",
  "category": "Utilities",
  "summary": "Offline password manager.",
  "publisher": "KeePassXC",
  "license": "GPL-3.0",
  "sources": [
   {
    "type": "flatpak",
    "ref": "org.keepassxc.KeePassXC"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 1,
  "weight": "light",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "bitwarden",
  "name": "Bitwarden",
  "category": "Utilities",
  "summary": "Password manager (Electron).",
  "publisher": "Bitwarden",
  "license": "GPL-3.0",
  "sources": [
   {
    "type": "flatpak",
    "ref": "com.bitwarden.desktop"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 1,
  "weight": "medium",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "gimp",
  "name": "GIMP",
  "category": "Graphics",
  "summary": "Image editing software.",
  "publisher": "GIMP",
  "license": "GPL-3.0",
  "sources": [
   {
    "type": "flatpak",
    "ref": "org.gimp.GIMP"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 4,
  "weight": "medium",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "krita",
  "name": "Krita",
  "category": "Graphics",
  "summary": "Digital painting.",
  "publisher": "KDE",
  "license": "GPL-3.0",
  "sources": [
   {
    "type": "flatpak",
    "ref": "org.kde.krita"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 4,
  "weight": "medium",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "inkscape",
  "name": "Inkscape",
  "category": "Graphics",
  "summary": "Vector graphics editor.",
  "publisher": "Inkscape",
  "license": "GPL-3.0",
  "sources": [
   {
    "type": "flatpak",
    "ref": "org.inkscape.Inkscape"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 2,
  "weight": "medium",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "blender",
  "name": "Blender",
  "category": "Graphics",
  "summary": "3D creation suite.",
  "publisher": "Blender Foundation",
  "license": "GPL-3.0",
  "sources": [
   {
    "type": "flatpak",
    "ref": "org.blender.Blender"
   }
  ],
  "size_mb": 455,
  "min_ram_gb": 8,
  "weight": "heavy",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "vlc",
  "name": "VLC media player",
  "category": "Multimedia",
  "summary": "Plays almost any media file.",
  "publisher": "VideoLAN",
  "license": "GPL-2.0",
  "sources": [
   {
    "type": "flatpak",
    "ref": "org.videolan.VLC"
   },
   {
    "type": "pacman",
    "ref": "vlc"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 1,
  "weight": "light",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "obs",
  "name": "OBS Studio",
  "category": "Multimedia",
  "summary": "Streaming and screen recording.",
  "publisher": "OBS Project",
  "license": "GPL-2.0",
  "sources": [
   {
    "type": "flatpak",
    "ref": "com.obsproject.Studio"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 4,
  "weight": "heavy",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "kdenlive",
  "name": "Kdenlive",
  "category": "Multimedia",
  "summary": "Video editor.",
  "publisher": "KDE",
  "license": "GPL-3.0",
  "sources": [
   {
    "type": "flatpak",
    "ref": "org.kde.kdenlive"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 8,
  "weight": "heavy",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "wireshark",
  "name": "Wireshark",
  "category": "System",
  "summary": "Network protocol analyzer. Live capture needs the native package.",
  "publisher": "Wireshark",
  "license": "GPL-2.0",
  "sources": [
   {
    "type": "flatpak",
    "ref": "org.wireshark.Wireshark"
   },
   {
    "type": "pacman",
    "ref": "wireshark-qt"
   }
  ],
  "size_mb": 54,
  "min_ram_gb": 2,
  "weight": "medium",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "steam",
  "name": "Steam",
  "category": "Games",
  "summary": "Game store and client.",
  "publisher": "Valve",
  "license": "Proprietary",
  "sources": [
   {
    "type": "flatpak",
    "ref": "com.valvesoftware.Steam"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 4,
  "weight": "heavy",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "lutris",
  "name": "Lutris",
  "category": "Games",
  "summary": "Open game manager for Wine and emulators.",
  "publisher": "Lutris",
  "license": "GPL-3.0",
  "sources": [
   {
    "type": "flatpak",
    "ref": "net.lutris.Lutris"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 2,
  "weight": "medium",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "heroic",
  "name": "Heroic Games Launcher",
  "category": "Games",
  "summary": "Epic, GOG and Amazon games.",
  "publisher": "Heroic",
  "license": "GPL-3.0",
  "sources": [
   {
    "type": "flatpak",
    "ref": "com.heroicgameslauncher.hgl"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 2,
  "weight": "medium",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "bottles",
  "name": "Bottles",
  "category": "Games",
  "summary": "Graphical Wine prefix manager.",
  "publisher": "Bottles",
  "license": "GPL-3.0",
  "sources": [
   {
    "type": "flatpak",
    "ref": "com.usebottles.bottles"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 2,
  "weight": "medium",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "itch",
  "name": "itch",
  "category": "Games",
  "summary": "itch.io storefront client.",
  "publisher": "itch.io",
  "license": "MIT",
  "sources": [
   {
    "type": "manual",
    "ref": "https://itch.io/app"
   }
  ],
  "size_mb": null,
  "min_ram_gb": null,
  "weight": "light",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "protonup",
  "name": "ProtonUp-Qt",
  "category": "Games",
  "summary": "Installs Proton-GE and Wine-GE builds.",
  "publisher": "DavidoTek",
  "license": "GPL-3.0",
  "sources": [
   {
    "type": "flatpak",
    "ref": "net.davidotek.pupgui2"
   }
  ],
  "size_mb": null,
  "min_ram_gb": null,
  "weight": "light",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "gamemode",
  "name": "GameMode",
  "category": "Games",
  "summary": "Applies performance tweaks while a game runs.",
  "publisher": "Feral Interactive",
  "license": "BSD",
  "sources": [
   {
    "type": "pacman",
    "ref": "gamemode"
   }
  ],
  "size_mb": null,
  "min_ram_gb": null,
  "weight": "light",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "mangohud",
  "name": "MangoHud",
  "category": "Games",
  "summary": "Vulkan and OpenGL FPS overlay.",
  "publisher": "MangoHud",
  "license": "MIT",
  "sources": [
   {
    "type": "pacman",
    "ref": "mangohud"
   }
  ],
  "size_mb": null,
  "min_ram_gb": null,
  "weight": "light",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "retroarch",
  "name": "RetroArch",
  "category": "Games",
  "summary": "Frontend for emulators and game engines.",
  "publisher": "Libretro",
  "license": "GPL-3.0",
  "sources": [
   {
    "type": "flatpak",
    "ref": "org.libretro.RetroArch"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 1,
  "weight": "light",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "dolphin",
  "name": "Dolphin",
  "category": "Games",
  "summary": "GameCube and Wii emulator.",
  "publisher": "Dolphin",
  "license": "GPL-2.0",
  "sources": [
   {
    "type": "flatpak",
    "ref": "org.DolphinEmu.dolphin-emu"
   }
  ],
  "size_mb": null,
  "min_ram_gb": null,
  "weight": "heavy",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "prism",
  "name": "Prism Launcher",
  "category": "Games",
  "summary": "Open-source Minecraft launcher.",
  "publisher": "Prism Launcher",
  "license": "GPL-3.0",
  "sources": [
   {
    "type": "flatpak",
    "ref": "org.prismlauncher.PrismLauncher"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 2,
  "weight": "medium",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "git",
  "name": "Git",
  "category": "Development",
  "summary": "Fast and secure version control.",
  "publisher": "Git",
  "license": "GPL-2.0",
  "sources": [
   {
    "type": "pacman",
    "ref": "git"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 1,
  "weight": "light",
  "light_alt": null,
  "featured": false,
  "popular": true,
  "verified": true
 },
 {
  "id": "anki",
  "name": "Anki",
  "category": "Education",
  "summary": "Spaced repetition flashcards.",
  "publisher": "Anki",
  "license": "AGPL-3.0",
  "sources": [
   {
    "type": "flatpak",
    "ref": "net.ankiweb.Anki"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 1,
  "weight": "light",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
 {
  "id": "gcompris",
  "name": "GCompris",
  "category": "Education",
  "summary": "Educational games for children.",
  "publisher": "KDE",
  "license": "GPL-3.0",
  "sources": [
   {
    "type": "flatpak",
    "ref": "org.kde.gcompris"
   }
  ],
  "size_mb": null,
  "min_ram_gb": 1,
  "weight": "light",
  "light_alt": null,
  "featured": false,
  "popular": false,
  "verified": true
 },
  {"id": "waydroid", "name": "Waydroid", "category": "System", "summary": "Run Android apps in a container on Linux.", "publisher": "Waydroid project", "license": "GPL-3.0", "sources": [{"type": "pacman", "ref": "waydroid"}], "size_mb": null, "min_ram_gb": null, "weight": "medium", "light_alt": null, "featured": false, "popular": false, "verified": true},
  {"id": "nix", "name": "Nix", "category": "System", "summary": "Package manager for reproducible installs (multi-user daemon).", "publisher": "NixOS project", "license": "LGPL-2.1", "sources": [{"type": "pacman", "ref": "nix"}], "size_mb": null, "min_ram_gb": null, "weight": "light", "light_alt": null, "featured": false, "popular": false, "verified": true},
  {"id": "cuda-toolkit", "name": "NVIDIA CUDA Toolkit", "category": "Development", "summary": "GPU compute toolkit for NVIDIA cards.", "publisher": "NVIDIA", "license": "NVIDIA proprietary", "sources": [{"type": "pacman", "ref": "cuda"}], "size_mb": null, "min_ram_gb": null, "weight": "heavy", "light_alt": null, "featured": false, "popular": false, "verified": true},
  {"id": "yabridge", "name": "yabridge", "category": "Games", "summary": "Run Windows VST plugins in Linux DAWs through Wine.", "publisher": "robbert-vdh", "license": "GPL-3.0", "sources": [{"type": "pacman", "ref": "yabridge"}], "size_mb": null, "min_ram_gb": null, "weight": "light", "light_alt": null, "featured": false, "popular": false, "verified": true},
  {"id": "unityhub", "name": "Unity Hub", "category": "Development", "summary": "Manage Unity editor versions and projects.", "publisher": "Unity Technologies", "license": "Proprietary", "sources": [{"type": "manual", "ref": "https://unity.com/download"}], "size_mb": null, "min_ram_gb": 4, "weight": "medium", "light_alt": null, "featured": false, "popular": false, "verified": false},
  {"id": "davinci-resolve", "name": "DaVinci Resolve", "category": "Graphics", "summary": "Professional video editing, colour and audio.", "publisher": "Blackmagic Design", "license": "Free and Studio (proprietary)", "sources": [{"type": "manual", "ref": "https://www.blackmagicdesign.com/products/davinciresolve"}], "size_mb": null, "min_ram_gb": 16, "weight": "heavy", "light_alt": null, "featured": false, "popular": false, "verified": false},
  {"id": "plex", "name": "Plex Media Server", "category": "Multimedia", "summary": "Stream your media library to any device.", "publisher": "Plex", "license": "Proprietary", "sources": [{"type": "manual", "ref": "https://www.plex.tv/media-server-downloads/"}], "size_mb": null, "min_ram_gb": 2, "weight": "light", "light_alt": null, "featured": false, "popular": false, "verified": false},
  {"id": "zoom", "name": "Zoom", "category": "Internet", "summary": "Video meetings client.", "publisher": "Zoom Video Communications", "license": "Proprietary", "sources": [{"type": "manual", "ref": "https://zoom.us/download"}], "size_mb": null, "min_ram_gb": 4, "weight": "medium", "light_alt": null, "featured": false, "popular": false, "verified": false},
  {"id": "teams-for-linux", "name": "Microsoft Teams (unofficial client)", "category": "Internet", "summary": "Unofficial Electron wrapper for Microsoft Teams on Linux.", "publisher": "Community (teams-for-linux)", "license": "GPL-3.0", "sources": [{"type": "manual", "ref": "https://github.com/IsmaelMartinez/teams-for-linux"}], "size_mb": null, "min_ram_gb": null, "weight": "medium", "light_alt": null, "featured": false, "popular": false, "verified": false},
  {"id": "comfyui", "name": "ComfyUI", "category": "Graphics", "summary": "Node-based interface for Stable Diffusion image generation.", "publisher": "Comfy Org", "license": "GPL-3.0", "sources": [{"type": "manual", "ref": "https://github.com/comfyanonymous/ComfyUI"}], "size_mb": null, "min_ram_gb": 16, "weight": "heavy", "light_alt": null, "featured": false, "popular": false, "verified": false},
  {"id": "text-generation-webui", "name": "text-generation-webui", "category": "Development", "summary": "Web UI for running local language models.", "publisher": "oobabooga", "license": "AGPL-3.0", "sources": [{"type": "manual", "ref": "https://github.com/oobabooga/text-generation-webui"}], "size_mb": null, "min_ram_gb": 16, "weight": "heavy", "light_alt": null, "featured": false, "popular": false, "verified": false},
  {"id": "frigate", "name": "Frigate NVR", "category": "System", "summary": "Network video recorder with object detection.", "publisher": "Frigate project", "license": "MIT", "sources": [{"type": "manual", "ref": "https://frigate.video"}], "size_mb": null, "min_ram_gb": 8, "weight": "heavy", "light_alt": null, "featured": false, "popular": false, "verified": false},
  {"id": "immich", "name": "Immich", "category": "Productivity", "summary": "Self-hosted photo and video backup.", "publisher": "Immich project", "license": "AGPL-3.0", "sources": [{"type": "manual", "ref": "https://immich.app"}], "size_mb": null, "min_ram_gb": 4, "weight": "heavy", "light_alt": null, "featured": false, "popular": false, "verified": false},
  {"id": "vllm", "name": "vLLM", "category": "Development", "summary": "High-throughput LLM inference server.", "publisher": "vLLM project", "license": "Apache-2.0", "sources": [{"type": "pip", "ref": "vllm"}], "size_mb": null, "min_ram_gb": 16, "weight": "heavy", "light_alt": null, "featured": false, "popular": false, "verified": false},
  {"id": "cemu", "name": "Cemu", "category": "Games", "summary": "Wii U emulator.", "publisher": "Cemu project", "license": "MPL-2.0", "sources": [{"type": "manual", "ref": "https://cemu.info"}], "size_mb": null, "min_ram_gb": 8, "weight": "heavy", "light_alt": null, "featured": false, "popular": false, "verified": false},
  {"id": "rockstar-launcher", "name": "Rockstar Games Launcher (via Lutris)", "category": "Games", "summary": "Rockstar launcher, run through Lutris and Wine.", "publisher": "Rockstar Games", "license": "Proprietary", "sources": [{"type": "manual", "ref": "https://lutris.net"}], "size_mb": null, "min_ram_gb": 4, "weight": "medium", "light_alt": null, "featured": false, "popular": false, "verified": false}
]
