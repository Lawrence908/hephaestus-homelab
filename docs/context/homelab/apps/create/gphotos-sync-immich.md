## GPhotos Sync + Immich – Containerized Backup and Library UI (Prompt)

### Objective
Back up my Google Photos to local storage on my server/NAS nightly using `gphotos-sync`, then browse/search them with Immich. The backup must be incremental, read‑only from Google, and safe from accidental deletions. Immich should index the same library read‑only.

### High-level Architecture
- `gphotos-sync` pulls from Google Photos API to a local library directory on the NAS.
- A scheduler container (supercronic) starts a short‑lived `gphotos-sync` job daily.
- Immich stack (server + DB + Redis + ML) indexes and serves the same library mounted read‑only as an External Library in the UI.
- No inbound ports are exposed for gphotos-sync; Immich is exposed via reverse proxy or LAN.

### Host paths and variables
- CONFIG_DIR: `/srv/apps/gphotos-sync/config` (holds `client_secret.json` and generated `token.json`)
- CRON_DIR: `/srv/apps/gphotos-sync/cron`
- LIBRARY_DIR: `/srv/photos/google-photos` (target mirror of Google Photos)
- IMMICH_DATA: `/srv/apps/immich` (configs, uploads if desired)
- TIMEZONE: `America/Los_Angeles` (example)
- PUID/PGID: set to the NAS user/group that owns the library directory (e.g., Synology often 1026:100)

### Prerequisites
1. Create a new project in Google Cloud Console.
2. Enable the “Google Photos Library API”.
3. Create OAuth 2.0 Client ID (Application type: Desktop app) and download `client_secret.json`.
4. Required scope: `https://www.googleapis.com/auth/photoslibrary.readonly`.

### Directory bootstrap (commands to run)
```bash
sudo mkdir -p /srv/apps/gphotos-sync/{config,cron} /srv/photos/google-photos /srv/apps/immich
sudo chown -R ${USER}:${USER} /srv/apps/gphotos-sync /srv/photos/google-photos /srv/apps/immich

# Place the downloaded client_secret.json here before first run:
#   /srv/apps/gphotos-sync/config/client_secret.json

# Create the cron file to trigger the job daily at 02:30
cat >/srv/apps/gphotos-sync/cron/gphotos.cron <<'CRON'
30 2 * * * /usr/bin/docker start -a gphotos-sync-run
CRON
```

### Compose file – GPhotos Sync scheduler and job
Create or extend a compose file (e.g., `/srv/apps/gphotos-sync/compose.yml`) with the following services.

```yaml
version: "3.9"

services:
  gphotos-sync-init:
    image: ghcr.io/gilesknap/gphotos-sync:latest
    container_name: gphotos-sync-init
    user: "${PUID:-1000}:${PGID:-1000}"
    environment:
      - TZ=${TZ:-America/Los_Angeles}
    volumes:
      - /srv/apps/gphotos-sync/config:/config
      - /srv/photos/google-photos:/storage
    entrypoint: ["/bin/sh","-lc"]
    command: >
      "gphotos-sync --loglevel INFO --progress --albums-path by-album /storage"
    # Run once to complete OAuth; token.json will be generated in /config.

  gphotos-sync-run:
    image: ghcr.io/gilesknap/gphotos-sync:latest
    container_name: gphotos-sync-run
    user: "${PUID:-1000}:${PGID:-1000}"
    environment:
      - TZ=${TZ:-America/Los_Angeles}
    volumes:
      - /srv/apps/gphotos-sync/config:/config
      - /srv/photos/google-photos:/storage
    entrypoint: ["/bin/sh","-lc"]
    command: >
      "gphotos-sync --loglevel INFO --progress --albums-path by-album /storage"
    healthcheck:
      test: ["CMD-SHELL","test -f /config/token.json"]
      interval: 1m
      timeout: 5s
      retries: 3
    restart: "no"  # one-shot job; triggered by cron

  gphotos-sync-cron:
    image: ghcr.io/aptible/supercronic:latest
    container_name: gphotos-sync-cron
    depends_on:
      - gphotos-sync-run
    environment:
      - TZ=${TZ:-America/Los_Angeles}
    volumes:
      - /srv/apps/gphotos-sync/cron:/crontabs:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
    command: ["/crontabs/gphotos.cron"]
    restart: unless-stopped
```

Notes
- You can tune behavior with a `/srv/apps/gphotos-sync/config/config.yaml` file. Avoid `--do-delete` unless you truly want deletions mirrored.
- Trigger a manual sync anytime: `docker compose -f /srv/apps/gphotos-sync/compose.yml start gphotos-sync-run`.

### First-time OAuth flow (commands to run)
```bash
# 1) Start init interactively to complete OAuth
docker compose -f /srv/apps/gphotos-sync/compose.yml up gphotos-sync-init

# 2) Once token.json exists in /srv/apps/gphotos-sync/config/, remove the init container
docker compose -f /srv/apps/gphotos-sync/compose.yml rm -f gphotos-sync-init

# 3) Start the scheduler
docker compose -f /srv/apps/gphotos-sync/compose.yml up -d gphotos-sync-cron
```

### Compose file – Immich stack
Place this as `/srv/apps/immich/compose.yml`. It mounts the Google Photos library read‑only at `/external/google-photos`. Use Immich’s UI to add this as an External Library.

```yaml
version: "3.9"

services:
  immich-server:
    image: ghcr.io/immich-app/immich-server:release
    container_name: immich-server
    depends_on:
      - immich-redis
      - immich-database
      - immich-machine-learning
    environment:
      - TZ=${TZ:-America/Los_Angeles}
      - DB_HOST=immich-database
      - DB_PORT=5432
      - DB_USERNAME=postgres
      - DB_PASSWORD=${IMMICH_DB_PASSWORD:-immich}
      - DB_DATABASE_NAME=immich
      - REDIS_HOSTNAME=immich-redis
      - IMMICH_LOG_LEVEL=info
      # Optional: where uploads/imports go (separate from external library)
      - UPLOAD_LOCATION=/usr/src/app/upload
    volumes:
      - /srv/apps/immich/upload:/usr/src/app/upload
      - /srv/apps/immich/config:/config
      - /srv/photos/google-photos:/external/google-photos:ro
    ports:
      - "2283:2283"  # expose or place behind your proxy
    restart: unless-stopped

  immich-machine-learning:
    image: ghcr.io/immich-app/immich-machine-learning:release
    container_name: immich-machine-learning
    environment:
      - TZ=${TZ:-America/Los_Angeles}
    volumes:
      - /srv/apps/immich/ml-cache:/cache
    restart: unless-stopped

  immich-redis:
    image: redis:7-alpine
    container_name: immich-redis
    restart: unless-stopped

  immich-database:
    image: tensorchord/pgvecto-rs:pg16-v0.2.1
    container_name: immich-database
    environment:
      - POSTGRES_PASSWORD=${IMMICH_DB_PASSWORD:-immich}
      - POSTGRES_DB=immich
    volumes:
      - /srv/apps/immich/db:/var/lib/postgresql/data
    restart: unless-stopped

networks:
  default:
    name: immich
```

Notes
- External Library: in Immich Web UI → Libraries → Add external library → path `/external/google-photos` (read‑only). Let Immich index; do not allow Immich to write to that folder.
- If you already run a reverse proxy (e.g., Caddy/Traefik), map Immich at your chosen hostname and expose only via HTTPS.

### Operations
- Verify nightly runs: check logs for `gphotos-sync-run` and confirm new media appear under `${LIBRARY_DIR}` within 24h.
- Back up both the library and gphotos config directory (`token.json` included) using your NAS snapshots/offsite replication.
- Health: the job is idempotent; re-running is safe.

### Security
- Keep `client_secret.json` and `token.json` private; they grant access to your library (read‑only scope recommended).
- No need to expose any gphotos-sync ports.
- Immich credentials should be secured; place behind your SSO/proxy if desired.

### Success Criteria
- Local mirror updated nightly without deletions unless explicitly enabled.
- Immich indexes the external library and provides fast search/browse.
- Restores possible from local snapshot/offsite replica.

### Quick command recap (run manually, in order)
```bash
# GPhotos: first-time OAuth and scheduler
docker compose -f /srv/apps/gphotos-sync/compose.yml up gphotos-sync-init
docker compose -f /srv/apps/gphotos-sync/compose.yml rm -f gphotos-sync-init
docker compose -f /srv/apps/gphotos-sync/compose.yml up -d gphotos-sync-cron

# Immich stack
docker compose -f /srv/apps/immich/compose.yml up -d
```


