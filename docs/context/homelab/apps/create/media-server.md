## Media Server (Plex or Jellyfin) – Containerized, with Synology NAS Library (Prompt)

### Objective
Run a modern media server (Plex or Jellyfin) in containers on the homelab box, while keeping the media library on a Synology NAS. Mount the NAS share on the host for best performance and give the container read access to media and a writable transcode/temp directory on local SSD.

### Why this approach
- Keep the large library centralized on the NAS for redundancy and snapshots.
- Use the server’s CPU/GPU for transcode and UI; containers make upgrades easy.
- Prefer NFS for performance and simple permissions; fall back to CIFS/SMB if needed.

### NAS assumptions
- Synology hostname/IP: `nas.lan` (replace as needed)
- Shared folder: `media` with subfolders like `movies`, `tv`, `music`, `photos`.
- Create a dedicated NAS account (e.g., `mediabox`) with read-only access to the media share.

### Host paths and variables
- MOUNT_ROOT: `/mnt/nas` (NFS or CIFS mount point)
- MEDIA_ROOT: `/mnt/nas/media`
- APPS_ROOT: `/srv/apps`
- PLEX_ROOT: `/srv/apps/plex` (or use `/srv/apps/jellyfin`)
- TRANSCODE_DIR: `/srv/apps/transcode` (fast local SSD)
- PUID/PGID: match the service account on the host that should own config/transcode dirs (e.g., 1000:1000 or Synology-aligned IDs on the host).
- TIMEZONE: e.g., `America/Los_Angeles`

---

### Mount the Synology share on the host
Preferred: NFS (enable NFS v3/v4 on Synology and export the `media` share)

```bash
sudo mkdir -p /mnt/nas/media

# Example NFS mount (adjust IP, paths, and options to your environment)
echo "nas.lan:/volume1/media /mnt/nas/media nfs4 rw,noatime,nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0" | sudo tee -a /etc/fstab

sudo mount -a
```

Alternative: CIFS/SMB (if you can’t use NFS)

```bash
sudo mkdir -p /mnt/nas/media /etc/creds
sudo bash -c 'cat >/etc/creds/syno-media <<EOF
username=mediabox
password=REPLACE_WITH_PASSWORD
domain=WORKGROUP
EOF'
sudo chmod 600 /etc/creds/syno-media

echo "//nas.lan/media /mnt/nas/media cifs ro,uid=1000,gid=1000,vers=3.1.1,iocharset=utf8,file_mode=0444,dir_mode=0555,credentials=/etc/creds/syno-media,nofail 0 0" | sudo tee -a /etc/fstab

sudo mount -a
```

Validation
```bash
df -h | grep /mnt/nas/media
ls -la /mnt/nas/media | head
```

---

### Choose your server: Plex or Jellyfin
Both are excellent. Plex has wider client support and cloud extras; Jellyfin is fully open source and very capable.

You can deploy either stack below. Only run one at a time on the same port mappings.

---

### Plex compose (recommended default)
Create directories and bring up the stack.

```bash
sudo mkdir -p /srv/apps/plex/{config,logs} /srv/apps/transcode
sudo chown -R 1000:1000 /srv/apps/plex /srv/apps/transcode
```

Compose file: `/srv/apps/plex/compose.yml`
```yaml
version: "3.9"

services:
  plex:
    image: lscr.io/linuxserver/plex:latest
    container_name: plex
    environment:
      - PUID=${PUID:-1000}
      - PGID=${PGID:-1000}
      - TZ=${TZ:-America/Los_Angeles}
      # Optional: claim token from plex.tv/claim to auto-link your server
      - PLEX_CLAIM=${PLEX_CLAIM:-}
    volumes:
      - /srv/apps/plex/config:/config
      - /srv/apps/transcode:/transcode
      - /mnt/nas/media:/media:ro
    ports:
      - "32400:32400"       # Web UI / API
      - "1900:1900/udp"     # DLNA (optional)
      - "32469:32469"       # DLNA (optional)
      - "32410:32410/udp"   # GDM network discovery (optional)
      - "32412:32412/udp"
      - "32413:32413/udp"
      - "32414:32414/udp"
    restart: unless-stopped
```

GPU acceleration (optional)
- Intel iGPU (Quick Sync): add `--device /dev/dri` via compose
```yaml
    devices:
      - /dev/dri:/dev/dri
```
- NVIDIA: install drivers + `nvidia-container-toolkit`, then add
```yaml
    deploy:
      resources:
        reservations:
          devices:
            - capabilities: [gpu]
```

Start Plex
```bash
docker compose -f /srv/apps/plex/compose.yml up -d
```

Access: `http://<host>:32400/web` (recommend placing behind your reverse proxy).

Plex library mapping examples in UI
- Movies: `/media/movies`
- TV: `/media/tv`
- Music: `/media/music`
- Photos: `/media/photos`

---

### Jellyfin compose (alternative)
```bash
sudo mkdir -p /srv/apps/jellyfin/{config,cache} /srv/apps/transcode
sudo chown -R 1000:1000 /srv/apps/jellyfin /srv/apps/transcode
```

Compose file: `/srv/apps/jellyfin/compose.yml`
```yaml
version: "3.9"

services:
  jellyfin:
    image: lscr.io/linuxserver/jellyfin:latest
    container_name: jellyfin
    environment:
      - PUID=${PUID:-1000}
      - PGID=${PGID:-1000}
      - TZ=${TZ:-America/Los_Angeles}
    volumes:
      - /srv/apps/jellyfin/config:/config
      - /srv/apps/jellyfin/cache:/cache
      - /srv/apps/transcode:/transcode
      - /mnt/nas/media:/media:ro
    ports:
      - "8096:8096"  # HTTP UI
      # - "8920:8920"  # HTTPS UI (optional)
    restart: unless-stopped
```

GPU acceleration (optional)
- Intel iGPU: add
```yaml
    devices:
      - /dev/dri:/dev/dri
```
- NVIDIA: add runtime and device reservations similar to Plex.

Start Jellyfin
```bash
docker compose -f /srv/apps/jellyfin/compose.yml up -d
```

Access: `http://<host>:8096`.

Jellyfin library mapping examples in UI
- Movies: `/media/movies`
- TV Shows: `/media/tv`
- Music: `/media/music`
- Photos: `/media/photos`

---

### Reverse proxy integration
- Expose only the necessary container ports to your proxy host network.
- Recommended hostnames:
  - Plex: `plex.example.lan`
  - Jellyfin: `jellyfin.example.lan`
- Ensure WebSocket and long-lived requests are allowed by your proxy rules.

### Backups, snapshots, and updates
- Library content is on the NAS → snapshot/replicate at the NAS level.
- Backup app config directories on the host (`/srv/apps/plex/config` or `/srv/apps/jellyfin/config`).
- Update with `docker compose pull && docker compose up -d` on the appropriate stack.

### Security notes
- Mount the NAS as read-only for the media path to prevent accidental writes.
- Keep transcode/temp on local SSD for speed; clean it periodically if space is tight.
- For remote access, use your existing VPN or reverse proxy with SSO where possible.

### Success criteria
- Media share mounts at boot and is readable at `/mnt/nas/media`.
- Plex/Jellyfin shows libraries and plays media without buffering; transcodes when necessary.
- Container restarts survive host reboot; updates are trivial.

### Quick command recap (to run manually)
```bash
# Mount (NFS preferred)
sudo mount -a

# Start Plex OR Jellyfin
docker compose -f /srv/apps/plex/compose.yml up -d
# or
docker compose -f /srv/apps/jellyfin/compose.yml up -d
```

Media Server:

Even with limited local storage, you can totally run something like Jellyfin or Plex in a container and then mount your NAS as a network drive. That way, the media server container can just pull content directly from your NAS. It’s a nice way to keep your media library centralized while using the NAS for storage and the Dell box for compute.


