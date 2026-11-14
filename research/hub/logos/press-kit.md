# Axiom Hub press-kit logo check (research only)

Format: id | logo URL | source page | licence or usage note | format | status
Method: official project or vendor pages and their GitHub READMEs were fetched and scanned for logo image references; each candidate URL was checked with curl (HEAD, following redirects). "verified-200" means the URL returned an image content type. Logos were not saved into the repo. Trademark use remains subject to each vendor's brand policy.

vscode | https://code.visualstudio.com/assets/branding/app-icon.png | https://code.visualstudio.com/brand | Microsoft brand guidelines apply | png | verified-200
neovim | https://raw.githubusercontent.com/neovim/neovim.github.io/master/static/logos/neovim-logo-300x87.png | https://github.com/neovim/neovim (README logo, served from neovim.github.io) | Apache-2.0 project; wordmark usage per project | png | verified-200
helix | https://raw.githubusercontent.com/helix-editor/helix/master/logo.svg | https://github.com/helix-editor/helix (README, logo.svg) | MPL-2.0 project | svg | verified-200
cursor | https://ptht05hbb1ssoooe.public.blob.vercel-storage.com/assets/brand/brand-logo-10.svg | https://cursor.com/brand | Cursor brand; variant not identified as the primary logo | svg | found-unconfirmed
opencode | https://raw.githubusercontent.com/anomalyco/opencode/dev/.github/assets/logo-ornate-light.svg | https://github.com/sst/opencode (README; repo now resolves to anomalyco/opencode) | MIT project; project logo | svg | verified-200
codex | none | https://github.com/openai/codex (README has no logo image) | OpenAI brand policy applies | n/a | not-found
claudecode | none | https://github.com/anthropics/claude-code (README has no logo image) | Anthropic brand policy applies | n/a | not-found
aider | none | https://github.com/Aider-AI/aider (only UI icons found, e.g. brain.svg; not a logo) | n/a | n/a | not-found
geminicli | none | https://github.com/google-gemini/gemini-cli (README has no logo image) | Google brand policy applies | n/a | not-found
goose | none | https://github.com/block/goose (README has no logo image) | n/a | n/a | not-found
ollama | none | https://github.com/ollama/ollama (README has no logo image) | n/a | n/a | not-found
openwebui | none | https://github.com/open-webui/open-webui (README has no logo image) | n/a | n/a | not-found
docker | https://www.docker.com/app/uploads/2026/02/Docker_Logo_660x400.png | https://www.docker.com/company/newsroom/media-resources/ | Docker media-resource terms apply | png | verified-200
colima | https://raw.githubusercontent.com/abiosoft/colima/main/colima.png | https://github.com/abiosoft/colima (README, colima-logo) | MIT project; project logo | png | verified-200
portainer | none | https://github.com/portainer/portainer (only a GitHub banner image found, not a logo) | n/a | n/a | not-found
kubectl | https://raw.githubusercontent.com/kubernetes/kubernetes/master/logo/logo.png | https://github.com/kubernetes/kubernetes (logo/ directory) | CNCF/Kubernetes trademark and logo usage guidelines apply | png | verified-200
helm | none | https://github.com/helm/helm (README has no logo image) | CNCF trademark guidelines apply | n/a | not-found
k9s | https://raw.githubusercontent.com/derailed/k9s/master/assets/imhotep_logo.png | https://github.com/derailed/k9s (README, assets/imhotep_logo.png) | Apache-2.0 project; mascot logo | png | verified-200
terraform | none | https://www.hashicorp.com/brand (HTTP 429 rate limit, no logo extracted) | HashiCorp/IBM brand policy applies | n/a | not-found
opentofu | https://raw.githubusercontent.com/opentofu/brand-artifacts/main/full/transparent/SVG/on-light.svg | https://github.com/opentofu/opentofu (README, brand-artifacts repo) | OpenTofu brand artifacts; check brand-artifacts licence | svg | verified-200
ansible | none | https://github.com/ansible/ansible (README has no logo image) | Red Hat trademark policy applies | n/a | not-found
vagrant | none | https://github.com/hashicorp/vagrant (README has no logo image) | HashiCorp brand policy applies | n/a | not-found
sqlserver | none | https://www.microsoft.com/en-us/sql-server (no logo extracted) | Microsoft brand guidelines apply | n/a | not-found
postgresql | none | https://www.postgresql.org/about/policies/trademarks/ (no logo extracted) | PostgreSQL trademark policy applies | n/a | not-found
mariadb | https://mariadb.org/wp-content/uploads/2019/10/mariadb_logo.svg | https://mariadb.org/about/ | MariaDB trademark policy applies | svg | verified-200
redis | none | https://redis.io/about/brand/ (HTTP 404) | Redis brand policy applies | n/a | not-found
sqlite | none | https://www.sqlite.org/ (no logo extracted) | SQLite is public domain; no logo file found | n/a | not-found
azuredatastudio | none | https://github.com/microsoft/azuredatastudio (README has no logo image) | Microsoft brand guidelines apply | n/a | not-found
tableplus | none | https://tableplus.com/ (only favicons found) | TablePlus brand policy applies | n/a | not-found
mangohud | none | https://github.com/flightlessmango/MangoHud (README has no logo image) | MIT project | n/a | not-found
git | none | https://git-scm.com/downloads/logos (no logo extracted) | Git logo licence to be checked on the page | n/a | not-found

Counts (31 ids): verified-200 = 10 (vscode, neovim, helix, opencode, docker, colima, kubectl, k9s, opentofu, mariadb); found-unconfirmed = 1 (cursor); not-found = 20.
Ids with no logo: codex, claudecode, aider, geminicli, goose, ollama, openwebui, portainer, helm, terraform, ansible, vagrant, sqlserver, postgresql, redis, sqlite, azuredatastudio, tableplus, mangohud, git.
