# Homelab Orchestration Scripts

These scripts orchestrate multiple docker compose projects across apps and infrastructure while keeping each project isolated. Uses `docker compose` for all operations.

## One-time setup

```bash
chmod +x /home/chris/*.sh
/home/chris/setup-networks.sh --verbose
```

## Start everything

```bash
/home/chris/start-homelab.sh --parallel --concurrency 4
```

- Start only a category:
```bash
/home/chris/start-homelab.sh --category infra
```
- Start a specific service:
```bash
/home/chris/manage-services.sh up --service grafana
```

## Manage services

```bash
# Bring apps up
/home/chris/manage-services.sh up --category app
# Stop infra
/home/chris/manage-services.sh down --category infra
# Logs for one project
/home/chris/manage-services.sh logs --service n8n
```

## Health checks

```bash
/home/chris/check-services.sh --category monitoring --max-retries 20 --interval 3
```

## Backups

```bash
/home/chris/backup-services.sh --dest /home/chris/backups --verify
```

## Configuration

- `homelab.config` (optional): sourced by scripts for overrides.
- `service-categories.yml`: map path substrings to `infra|db|app|monitoring`.
- `health.yml`: example health overrides (HTTP/TCP).
- Logs saved under `/home/chris/logs/homelab-YYYYmmdd.log`.

## Notes

- Ensure each compose file attaches to the `homelab-web` network.
- Scripts never modify compose files; they orchestrate only.
- Use `--dry-run` to preview actions safely.