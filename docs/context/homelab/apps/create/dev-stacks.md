## Popup Dev Stacks – Batteries‑Included Templates with a Single Launcher (Prompt)

### Objective
Spin up full, isolated dev environments in seconds for your most common stacks (Django, Flask/FastAPI, Node/Next.js, SaaS, E‑commerce) without cluttering the host. Use a single "Dev Launcher" container to scaffold new projects from templates and start stack‑specific compose files on demand.

### Recommendation at a glance
- Use **one small launcher container** that provides a CLI (`devctl`) and ships with curated templates (Cookiecutter + devcontainer metadata).
- Each generated project includes its own **Docker Compose** and **.devcontainer** for VS Code/Cursor, plus Makefiles and scripts.
- Start/stop stacks via compose profiles; remove with a single command. Artifacts live under a `workspace` directory on the host.

Why not one giant container per stack?
- A monolithic image per stack grows quickly and duplicates tooling. A tiny launcher + per‑project templates stays clean, fast, and easy to upgrade.

---

### Host layout
- WORKSPACE: `/srv/workspace` (where projects are created)
- DEVCTL_ROOT: `/srv/apps/dev-launcher`

Prepare directories
```bash
sudo mkdir -p /srv/apps/dev-launcher/{config,cache} /srv/workspace
sudo chown -R 1000:1000 /srv/apps/dev-launcher /srv/workspace
```

Optional env file: `/srv/apps/dev-launcher/config/.env`
```env
TZ=America/Los_Angeles
PUID=1000
PGID=1000
GIT_AUTHOR_NAME=Chris
GIT_AUTHOR_EMAIL=chris@example.com
DEFAULT_LICENSE=MIT
```

---

### Dev Launcher compose
File: `/srv/apps/dev-launcher/compose.yml`
```yaml
version: "3.9"

services:
  devctl:
    image: ghcr.io/hyperupcall/dev-launcher:latest
    # If building yourself, publish a small Python image with cookiecutter, copier, uv, node, and git
    container_name: devctl
    env_file:
      - /srv/apps/dev-launcher/config/.env
    environment:
      - TZ=${TZ:-America/Los_Angeles}
      - PUID=${PUID:-1000}
      - PGID=${PGID:-1000}
    working_dir: /workspace
    volumes:
      - /srv/workspace:/workspace
      - /srv/apps/dev-launcher/cache:/root/.cache
    entrypoint: ["/bin/sh","-lc"]
    command: "devctl --help || echo 'Use docker compose run --rm devctl <cmd>'"
```

Quick usage
```bash
# List templates
docker compose -f /srv/apps/dev-launcher/compose.yml run --rm devctl list

# Create a new project (examples)
docker compose -f /srv/apps/dev-launcher/compose.yml run --rm devctl new django myshop
docker compose -f /srv/apps/dev-launcher/compose.yml run --rm devctl new fastapi myapi
docker compose -f /srv/apps/dev-launcher/compose.yml run --rm devctl new nextjs mysite
docker compose -f /srv/apps/dev-launcher/compose.yml run --rm devctl new saas mymvp

# Launch the stack from inside the new project
cd /srv/workspace/myshop
docker compose up -d
```

---

### What the templates include
Common across all stacks
- `.devcontainer/` for VS Code/Cursor: mounts workspace, installs deps, sets debug.
- `docker-compose.yml` with profiles for `dev`, `test`, and optional `worker`.
- Postgres + Redis when relevant; Mailhog or Mailpit for email testing.
- `Makefile` with `make dev`, `make test`, `make db`, `make lint`, `make reset`.
- CI example (GitHub Actions or Woodpecker) and pre‑commit hooks.

Template: Django (e‑commerce ready)
- Apps: `users`, `catalog`, `orders`, Stripe skeleton.
- Services: `web` (Django), `db` (Postgres), `cache` (Redis), `mailpit`.
- Extras: Celery worker + beat (profile `worker`).

Template: Flask/FastAPI
- FastAPI router scaffold, Pydantic models, SQLAlchemy + Alembic.
- Services: `api`, `db`, `redis`, `mailpit`.

Template: Node/Next.js
- Next.js app with Auth.js, Prisma (Postgres), Tailwind, Playwright tests.
- Services: `web`, `db`, optional `minio` for S3‑like storage.

Template: SaaS MVP
- User auth, teams, billing via Stripe Checkout/Portal, admin dashboard.
- Email templates + background jobs; feature flagging baked in.

Template: E‑commerce
- Option A: Django + Stripe + basic catalog/cart/checkout.
- Option B: Next.js Storefront + MedusaJS backend (profile `backend`).

---

### Example compose snippets per template

Django (file created inside project as `docker-compose.yml`)
```yaml
version: "3.9"
services:
  web:
    build: .
    command: ./manage.py runserver 0.0.0.0:8000
    volumes:
      - .:/app
    environment:
      - DJANGO_DEBUG=1
      - DATABASE_URL=postgresql://postgres:postgres@db:5432/app
      - REDIS_URL=redis://redis:6379/0
    ports:
      - "8000:8000"
    depends_on:
      - db
      - redis
  db:
    image: postgres:16-alpine
    environment:
      - POSTGRES_PASSWORD=postgres
    volumes:
      - pgdata:/var/lib/postgresql/data
  redis:
    image: redis:7-alpine
  mailpit:
    image: axllent/mailpit:latest
    ports:
      - "8025:8025"
volumes:
  pgdata:
```

FastAPI
```yaml
version: "3.9"
services:
  api:
    build: .
    command: uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
    volumes:
      - .:/app
    environment:
      - DATABASE_URL=postgresql://postgres:postgres@db:5432/app
    ports:
      - "8001:8000"
    depends_on:
      - db
  db:
    image: postgres:16-alpine
    environment:
      - POSTGRES_PASSWORD=postgres
    volumes:
      - pgdata:/var/lib/postgresql/data
volumes:
  pgdata:
```

Next.js + Prisma
```yaml
version: "3.9"
services:
  web:
    image: node:20-alpine
    working_dir: /app
    command: sh -lc "npm ci && npm run dev"
    volumes:
      - .:/app
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgresql://postgres:postgres@db:5432/app
  db:
    image: postgres:16-alpine
    environment:
      - POSTGRES_PASSWORD=postgres
    volumes:
      - pgdata:/var/lib/postgresql/data
volumes:
  pgdata:
```

---

### Dev Containers support
Each template ships with `.devcontainer/devcontainer.json` so you can open the folder in VS Code/Cursor and get a pre‑configured containerized dev environment with extensions, debugging, and terminals. The same compose services are referenced by the devcontainer for consistency.

---

### CI/CD as a containerized service
If you want a local runner:
- Deploy **Woodpecker CI** or a **GitHub Actions self‑hosted runner** as a container.
- Point runners at your workspace; cache volumes shared for speed.

Example (GitHub runner)
```yaml
version: "3.9"
services:
  gh-runner:
    image: ghcr.io/actions/actions-runner:latest
    environment:
      - REPO_URL=https://github.com/you/your-repo
      - RUNNER_TOKEN=REPLACE
    volumes:
      - /srv/workspace:/workspace
    restart: unless-stopped
```

---

### Operating the launcher
- Update templates: `docker compose -f /srv/apps/dev-launcher/compose.yml run --rm devctl templates update`.
- Generate project: `devctl new <template> <name>`.
- Start/stop: `docker compose up -d` / `docker compose down` from project dir.
- Clean: `docker compose down -v` to remove named volumes when done.

### Success criteria
- New project up and serving an endpoint/UI in <60 seconds from command run.
- Dev container opens with debugger attached and tests runnable.
- Reproducible across machines with only Docker and your launcher.

### Next steps
- We’ll curate the initial templates you listed: E‑commerce, Service Business, SaaS MVP. Each will simply be a thin veneer over the core stacks above, with ready‑to‑edit UIs and payment stubs (Stripe) where relevant.


