# Hephaestus Homelab - Deployment & Service Management

## Overview

This document outlines the deployment procedures, service management, and operational procedures for the Hephaestus Homelab infrastructure.

## Deployment Architecture

### Implementation Summary
1. **Subdomain Routing** - Each service has its own subdomain (e.g., `portfolio.chrislawrence.ca`, `schedshare.chrislawrence.ca`)
2. **Cloudflare Access Integration** - Protected subdomains use Cloudflare Access for authentication
3. **Public vs Protected Services** - Clear separation between public and admin-only services
4. **Cloudflare Tunnel Configuration** - Secure public access via tunnel `de5fbdaa-4497-4a7e-828f-7dba6d7b0c90`

## Service Ports & Routing

### Port Mapping Strategy

| Service Category | Port Range | Purpose |
|-----------------|------------|---------|
| Infrastructure | 3000-3099 | Core services (Grafana, Prometheus, etc.) |
| Proxy Services | 8000-8099 | Caddy proxy endpoints |
| Applications | 8100-8199 | Custom applications |
| Development | 8200-8299 | Development/testing services |

### Key Service Ports

| Service | Port | Network Access | Public URL | Access Type |
|---------|------|----------------|------------|-------------|
| Caddy Proxy | 80, 443 | External + Internal | `https://chrislawrence.ca` | Public |
| Landing Page | 80 | Internal | `https://chrislawrence.ca` | Public |
| Portfolio | 5000 | Internal | `https://portfolio.chrislawrence.ca` | Public |
| SchedShare | 5000 | Internal | `https://schedshare.chrislawrence.ca` | Public |
| CapitolScope Frontend | 5173 | Internal | `https://capitolscope.chrislawrence.ca` | Public |
| CapitolScope Backend | 8000 | Internal | `https://capitolscope.chrislawrence.ca` | Public |
| MagicPages API | 8000 | Internal | `https://magicpages.chrislawrence.ca` | Public |
| MagicPages API | 8000 | Internal | `https://api.magicpages.chrislawrence.ca` | Public |
| EventSphere | 5000 | Internal | `https://eventsphere.chrislawrence.ca` | Public |
| Dev Environment | Various | Internal | `https://dev.chrislawrence.ca` | Protected (Cloudflare Access) |
| Monitor | Various | Internal | `https://monitor.chrislawrence.ca` | Protected (Cloudflare Access) |
| IoT Services | Various | Internal | `https://iot.chrislawrence.ca` | Protected (Cloudflare Access) |
| Minecraft | 25565 | External + Internal | `https://minecraft.chrislawrence.ca` | Protected (Cloudflare Access) |
| AI Services | Various | Internal | `https://ai.chrislawrence.ca` | Protected (Cloudflare Access) |

### Organizr Proxy Ports (Iframe Embedding)

| Service | Organizr Tab URL | Purpose |
|---------|------------------|---------|
| **Uptime Kuma** | `http://192.168.50.70:8083` | Service monitoring |
| **Portainer** | `http://192.168.50.70:8084` | Container management |
| **Grafana** | `http://192.168.50.70:8085` | Metrics dashboard |
| **Prometheus** | `http://192.168.50.70:8086` | Metrics collection |
| **cAdvisor** | `http://192.168.50.70:8087` | Container metrics |
| **Glances** | `http://192.168.50.70:8088` | System monitoring |
| **IT-Tools** | `http://192.168.50.70:8089` | Network utilities |
| **daedalOS** | `http://192.168.50.70:8158` | Browser desktop environment |

## Deployment Procedures

### Phase 1: Infrastructure Deployment

```bash
# Navigate to homelab directory
cd ~/github/hephaestus-infra

# Deploy main infrastructure stack
docker compose -f docker-compose-infrastructure.yml up -d

# Deploy proxy stack
docker compose -f proxy/docker-compose.yml up -d

# Deploy monitoring stack
docker compose -f grafana-stack/docker-compose.yml up -d

# Check service status
docker compose -f docker-compose-infrastructure.yml ps
```

### Phase 2: Cloudflare Tunnel Update

```bash
# Backup current config
cp ~/.cloudflared/config.yml ~/.cloudflared/config.yml.backup

# Update tunnel configuration with new tunnel ID
# Tunnel ID: de5fbdaa-4497-4a7e-828f-7dba6d7b0c90
# Token: eyJhIjoiOWU2MjZkY2FmZmIxZDE0YmNmZDc0YzM3NGQ5MDRjZmUiLCJ0IjoiZGU1ZmJkYWEtNDQ5Ny00YTdlLTgyOGYtN2RiYTZkN2IwYzkwIiwicyI6Ik9HUmpZVEJrTm1JdFltUTVaQzAwTkRFM0xUa3laR1V0WW1VME5qSXlNV1V6TTJJdyJ9

# Restart Cloudflare Tunnel
docker compose -f proxy/docker-compose.yml restart cloudflared

# Check tunnel status
docker compose -f proxy/docker-compose.yml logs cloudflared
```

### Phase 3: Application Deployment

```bash
# Deploy individual applications as needed
cd ~/apps/your-app
docker compose -f docker-compose-homelab.yml up -d

# Or use the main deployment script
~/start-homelab.sh
```

## Service Management

### Docker Compose Files

#### Infrastructure Files (Network Creators)
- **Main Infrastructure**: `/home/chris/github/hephaestus-infra/docker-compose-infrastructure.yml`
- **Proxy Stack**: `/home/chris/github/hephaestus-infra/proxy/docker-compose.yml`
- **Monitoring Stack**: `/home/chris/github/hephaestus-infra/grafana-stack/docker-compose.yml`

#### Application Files (Network Users)
- **Pattern**: `/home/chris/apps/*/docker-compose-homelab.yml`
- **Examples**:
  - `/home/chris/apps/daedalOS/docker-compose-homelab.yml`
  - `/home/chris/apps/CapitolScope/docker-compose.yml`
  - `/home/chris/apps/n8n/docker-compose.yml`
  - `/home/chris/apps/MagicPages/docker-compose.yml`

### Standard Network Pattern for Apps
```yaml
networks:
  web:
    external: true
    name: homelab-web
```

## Deployment Order

### Critical Path
1. **Infrastructure Stack**: `docker compose -f docker-compose-infrastructure.yml up -d`
2. **Proxy Stack**: `docker compose -f proxy/docker-compose.yml up -d`
3. **Monitoring Stack**: `docker compose -f grafana-stack/docker-compose.yml up -d`
4. **Applications**: Individual app stacks as needed

### Dependencies
- All services depend on `homelab-web` network
- Proxy services depend on Caddy
- Applications depend on infrastructure services

## Testing Procedures

### Service Health Checks

```bash
# Test infrastructure services
curl -I http://192.168.50.70:3000  # Grafana
curl -I http://192.168.50.70:3001  # Uptime Kuma
curl -I http://192.168.50.70:9000  # Portainer

# Test proxy ports
curl -I http://192.168.50.70:8085 -u admin:admin123  # Grafana proxy
curl -I http://192.168.50.70:8086 -u admin:admin123  # Prometheus proxy
curl -I http://192.168.50.70:8087 -u admin:admin123  # cAdvisor proxy
curl -I http://192.168.50.70:8158  # daedalOS proxy

# Test public access
curl -I https://chrislawrence.ca
curl -I https://portfolio.chrislawrence.ca
curl -I https://schedshare.chrislawrence.ca
curl -I https://capitolscope.chrislawrence.ca
curl -I https://magicpages.chrislawrence.ca
curl -I https://eventsphere.chrislawrence.ca

# Test protected access (should redirect to Cloudflare Access)
curl -I https://dev.chrislawrence.ca
curl -I https://monitor.chrislawrence.ca
curl -I https://iot.chrislawrence.ca
curl -I https://minecraft.chrislawrence.ca
curl -I https://ai.chrislawrence.ca
```

### Organizr Integration Tests
1. Login to Organizr at `http://192.168.50.70:8082`
2. Add each proxy port as Organizr tab
3. Verify iframe embedding works without errors
4. Test functionality within Organizr interface
5. Confirm no console errors in browser

## Monitoring & Maintenance

### Service Monitoring
- **Uptime Kuma**: Service availability monitoring
- **Grafana**: Metrics and performance monitoring
- **Prometheus**: Metrics collection and alerting
- **cAdvisor**: Container resource monitoring
- **Glances**: System resource monitoring

### Log Management
```bash
# View service logs
docker compose -f docker-compose-infrastructure.yml logs caddy
docker compose -f docker-compose-infrastructure.yml logs grafana
docker compose -f proxy/docker-compose.yml logs cloudflared

# Follow logs in real-time
docker compose -f docker-compose-infrastructure.yml logs -f caddy
```

### Backup Procedures
```bash
# Backup Docker volumes
docker run --rm -v caddy_data:/data -v caddy_config:/config -v /backup:/backup alpine tar czf /backup/caddy-backup-$(date +%Y%m%d).tar.gz -C /data . -C /config .

# Backup application data
tar czf /backup/apps-backup-$(date +%Y%m%d).tar.gz /home/chris/apps/
```

## Troubleshooting

### Common Issues

#### Services Can't Communicate
```bash
# Check network connectivity
docker network inspect homelab-web
docker exec -it caddy ping grafana
docker exec -it grafana ping prometheus
```

#### Proxy Port Not Responding
```bash
# Check Caddy status
docker compose -f docker-compose-infrastructure.yml ps caddy
docker compose -f docker-compose-infrastructure.yml logs caddy

# Validate Caddyfile syntax
docker compose -f docker-compose-infrastructure.yml exec caddy caddy validate --config /etc/caddy/Caddyfile
```

#### Public Access Issues
```bash
# Check Cloudflare Tunnel
sudo systemctl status cloudflared
sudo journalctl -u cloudflared -f

# Test local routing
curl -I http://localhost:80/dashboard -u admin:admin123
```

#### Iframe Embedding Issues
```bash
# Check for X-Frame-Options header (should be absent)
curl -I http://192.168.50.70:808X -u admin:admin123 | grep -i frame

# Check CSP header
curl -I http://192.168.50.70:808X -u admin:admin123 | grep -i content-security
```

### Rollback Procedures
1. **Immediate**: Revert Caddyfile from Git history
2. **Container Issues**: Restart with previous docker-compose
3. **DNS Issues**: Revert Cloudflare Tunnel config from backup
4. **Emergency**: Use direct port access as fallback

## Future Application Deployment

### Staged Application Ports
- **Magic Pages API**: Port 8100 → `https://api.magicpages.chrislawrence.ca`
- **Magic Pages Frontend**: Port 8101 → `https://magicpages.chrislawrence.ca`
- **Portfolio App**: Port 8110 → `https://portfolio.chrislawrence.ca`
- **CapitolScope**: Port 8120 → `https://capitolscope.chrislawrence.ca`
- **SchedShare**: Port 8130 → `https://schedshare.chrislawrence.ca`

### Deployment Steps for New Applications
1. Uncomment relevant sections in Caddyfile
2. Deploy applications with 81XX port structure
3. Test application routing
4. Update documentation

## Automation & Scripts

### Deployment Scripts
- **Main Deployment**: `~/start-homelab.sh`
- **Network Setup**: `~/setup-networks.sh`
- **Test Routing**: `./test-routing.sh`

### Monitoring Scripts
```bash
# Service health check
#!/bin/bash
services=("caddy" "grafana" "prometheus" "portainer" "uptime-kuma")
for service in "${services[@]}"; do
    if docker ps | grep -q "$service"; then
        echo "✅ $service is running"
    else
        echo "❌ $service is not running"
    fi
done
```

## Related Documentation

- [Network Architecture](./networks.md) - Docker network setup
- [DNS & Cloudflare Configuration](./dns-cloudflare.md) - Tunnel and DNS setup
- [Security Configuration](./security.md) - Authentication and access control

---

**Last Updated**: $(date)
**Deployment Version**: 1.0
**Compatible With**: Docker Compose v2.0+, Docker Engine 27.x



