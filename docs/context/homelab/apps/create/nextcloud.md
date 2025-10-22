## Nextcloud – Self‑Hosted File Sharing and Phone Photo Backup (Prompt)

### Objective
Replace Google One for general file sharing and automatic mobile photo backup using a self‑hosted Nextcloud stack. Data lives on the NAS; the app runs on the homelab host. Access securely from LAN and remotely via your reverse proxy.

### Why Nextcloud
- Full control over files and photos; no SaaS fees.
- First‑party mobile apps for automatic camera uploads (iOS/Android).
- Rich app ecosystem: calendars/contacts, document editing, shared links, and more.

### Architecture
- Nextcloud application container (PHP + Web)
- Postgres database for reliability and performance
- Redis for locking/memcache
- Data directory on NAS (mounted on host, passed to container)

### Host paths and variables
- NC_ROOT: `/srv/apps/nextcloud`
- NC_DATA: `/mnt/nas/nextcloud-data` (on Synology share; see mounting below)
- TIMEZONE: `America/Los_Angeles`
- PUID/PGID: host user/group for file ownership (e.g., 1000:1000)

---

### Mount Synology share on the host (NFS preferred)
Enable NFS on Synology for the `nextcloud-data` shared folder.

```bash
sudo mkdir -p /mnt/nas/nextcloud-data
echo "nas.lan:/volume1/nextcloud-data /mnt/nas/nextcloud-data nfs4 rw,noatime,nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0" | sudo tee -a /etc/fstab
sudo mount -a
```

Validate the mount
```bash
df -h | grep nextcloud-data
ls -la /mnt/nas/nextcloud-data | head
```

Permissions tip
- Prefer to create the folder on Synology and grant the `mediabox` or service account read/write.
- On the host, ensure the mount presents writable permissions for your chosen `PUID:PGID`.

---

### Directory bootstrap (host)
```bash
sudo mkdir -p /srv/apps/nextcloud/{db,redis,config}
sudo chown -R 1000:1000 /srv/apps/nextcloud
```

Optional `.env` for secrets: `/srv/apps/nextcloud/config/.env`
```env
POSTGRES_PASSWORD=change_me
POSTGRES_DB=nextcloud
POSTGRES_USER=nextcloud
REDIS_PASSWORD=change_me
NEXTCLOUD_TRUSTED_DOMAIN=cloud.example.lan
TZ=America/Los_Angeles
PUID=1000
PGID=1000
```

---

### Docker compose stack (Nextcloud + Postgres + Redis)
File: `/srv/apps/nextcloud/compose.yml`

```yaml
version: "3.9"

services:
  nextcloud:
    image: lscr.io/linuxserver/nextcloud:latest
    container_name: nextcloud
    env_file:
      - /srv/apps/nextcloud/config/.env
    environment:
      - PUID=${PUID:-1000}
      - PGID=${PGID:-1000}
      - TZ=${TZ:-America/Los_Angeles}
      - POSTGRES_DB=${POSTGRES_DB:-nextcloud}
      - POSTGRES_USER=${POSTGRES_USER:-nextcloud}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-change_me}
      - POSTGRES_HOST=postgres
      - REDIS_HOST=redis
      - REDIS_HOST_PASSWORD=${REDIS_PASSWORD:-change_me}
      - NEXTCLOUD_TRUSTED_DOMAINS=${NEXTCLOUD_TRUSTED_DOMAIN:-cloud.example.lan}
    volumes:
      - /srv/apps/nextcloud/config:/config
      - /mnt/nas/nextcloud-data:/data
    depends_on:
      - postgres
      - redis
    ports:
      - "8088:443"   # expose HTTPS from the container to host port 8088
    restart: unless-stopped

  postgres:
    image: postgres:16-alpine
    container_name: nextcloud-postgres
    env_file:
      - /srv/apps/nextcloud/config/.env
    environment:
      - POSTGRES_DB=${POSTGRES_DB:-nextcloud}
      - POSTGRES_USER=${POSTGRES_USER:-nextcloud}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-change_me}
    volumes:
      - /srv/apps/nextcloud/db:/var/lib/postgresql/data
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    container_name: nextcloud-redis
    command: ["redis-server","--requirepass","${REDIS_PASSWORD:-change_me}"]
    volumes:
      - /srv/apps/nextcloud/redis:/data
    restart: unless-stopped

networks:
  default:
    name: nextcloud
```

Start the stack
```bash
docker compose -f /srv/apps/nextcloud/compose.yml up -d
```

Access on LAN: `https://<host>:8088` (self-signed initially). Recommended: place behind your reverse proxy at `https://cloud.example.lan` with a TLS cert.

---

### Nextcloud initial setup
1. Open the site and create the admin account.
2. In Database setup, choose PostgreSQL and use:
   - Database user: `nextcloud`
   - Database password: value from `.env`
   - Database name: `nextcloud`
   - Host: `postgres`
3. Confirm the data directory is `/data` (mounted to NAS path). Finish setup.

Post‑install hardening
- Settings → Administration → Overview: enable recommended background jobs via Cron.
- Enable memory caching with Redis (already configured via envs).
- Set trusted domain(s) to your hostname.

Background jobs
- For small deployments, the built-in WebCron is fine. For Cron: add a host cron entry calling `docker compose exec -T nextcloud crontab -l` guidance or use a lightweight `supercronic` sidecar. Optional for MVP.

---

### Mobile photo backup
1. Install the Nextcloud mobile app (iOS/Android).
2. Add the server URL (your LAN/remote hostname) and login.
3. Enable automatic camera uploads; set destination folder (e.g., `/Photos/Camera Uploads`).
4. Optionally enable background/foreground refresh and cellular usage policies.

Sharing & collaboration
- Create shared links with optional passwords/expiry.
- Family accounts can have their own private space plus a shared family folder.

External storage (optional)
- If you want Nextcloud to reference existing NAS folders without moving data, enable the “External storage support” app and mount additional shares read-only or read-write per need.

Backups & maintenance
- Snapshot the NAS data directory and back up `/srv/apps/nextcloud/db` and `/srv/apps/nextcloud/config` regularly.
- Updates: `docker compose -f /srv/apps/nextcloud/compose.yml pull && docker compose -f /srv/apps/nextcloud/compose.yml up -d`.

Security notes
- Use your reverse proxy for TLS and HTTPS-only access; consider SSO.
- Keep admin user strong and enable 2FA for accounts.

Success criteria
- Mobile app uploads new photos automatically to `/Photos/Camera Uploads`.
- Files are accessible from web and desktop clients; sharing links work.
- Nightly snapshots exist for both data and database volumes.

Quick commands
```bash
# start
docker compose -f /srv/apps/nextcloud/compose.yml up -d

# update
docker compose -f /srv/apps/nextcloud/compose.yml pull && docker compose -f /srv/apps/nextcloud/compose.yml up -d
```


