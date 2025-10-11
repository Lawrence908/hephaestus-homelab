# Uptime Kuma Migration Guide

## Migration Summary

Successfully migrated Uptime Kuma from Synology DS218+ NAS to Dell OptiPlex 7040 homelab.

## What Was Migrated

### Database Files
- `kuma.db` - Main SQLite database (1.8MB)
- `kuma.db-shm` - Shared memory file (32KB) 
- `kuma.db-wal` - Write-ahead log file (420KB)
- `config.yaml` - Configuration file

### Monitor Configurations
- **NASty** - http://192.168.50.50:5000 (60s interval)
- **Portfolio** - https://chrislawrence.ca (367s interval)
- **SchedShare** - https://schedshare.chrislawrence.ca (313s interval)
- **CapitolScope** - https://capitolscope.chrislawrence.ca (271s interval)
- **Magic Pages** - https://magicpages.com (227s interval)
- **Magic Pages API** - https://api.magicpages.com (30s interval, with basic auth)

### Notification Setup
- Telegram notifications configured with bot token
- All monitors linked to Telegram alert system

## File Locations

### Source (NAS Migration Files)
- Original files: `/home/chris/github/hephaestus-homelab/docs/prompts/Kuma/`
- Backup JSON: `Uptime_Kuma_Backup_2025_10_11-05_46_09.json`

### Destination (New Homelab)
- Database files: `/home/chris/github/hephaestus-homelab/data/uptime-kuma/`
- Docker service: Configured in `docker-compose-infrastructure.yml`

## Docker Configuration

The Uptime Kuma service is configured in `docker-compose-infrastructure.yml`:

```yaml
uptime-kuma:
  image: louislam/uptime-kuma:1
  container_name: uptime-kuma
  restart: unless-stopped
  networks:
    - web
  ports:
    - "3001:3001"
  volumes:
    - ./data/uptime-kuma:/app/data
  labels:
    - "com.centurylinklabs.watchtower.enable=true"
  security_opt:
    - no-new-privileges:true
```

## Access Information

- **Local Access**: http://192.168.50.60:3001
- **Remote Access**: https://nasty.chrislawrence.ca (via Cloudflare Tunnel)
- **Network**: Connected to `web` bridge network
- **Port**: 3001 (internal and external)

## Migration Steps Completed

1. ✅ Copied database files from NAS backup
2. ✅ Created proper directory structure (`./data/uptime-kuma/`)
3. ✅ Updated docker-compose volume mapping
4. ✅ Preserved all monitor configurations
5. ✅ Maintained notification settings

## Next Steps

### To Start the Service
```bash
cd /home/chris/github/hephaestus-homelab
docker-compose -f docker-compose-infrastructure.yml up -d uptime-kuma
```

### To Verify Migration
1. Access http://192.168.50.60:3001
2. Check that all monitors are present and configured
3. Verify Telegram notifications are working
4. Test monitor status and alerting

### Cleanup (Optional)
After confirming everything works, you can remove the temporary files:
```bash
rm -rf /home/chris/github/hephaestus-homelab/docs/prompts/Kuma/
```

## Security Notes

- Service runs with `no-new-privileges:true` for security
- Database files are properly mounted as volumes
- Service is behind Caddy reverse proxy for HTTPS
- Cloudflare Tunnel provides secure remote access

## Monitoring Integration

Uptime Kuma is integrated with the broader monitoring stack:
- **Grafana** (port 3000) - Metrics visualization
- **Prometheus** (port 9090) - Metrics collection  
- **cAdvisor** (port 8080) - Container metrics
- **Glances** (port 61208) - System monitoring

All services are configured for automatic updates via Watchtower.
