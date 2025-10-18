# Hephaestus Homelab - Deployment & Service Management

## Overview

This document outlines the deployment procedures, service management, and operational procedures for the Hephaestus Homelab infrastructure.

## Deployment Architecture

### Implementation Summary
1. **808X Proxy Ports** (8085-8089) for Organizr iframe embedding
2. **chrislawrence.ca Subpath Routing** for public access
3. **81XX App Port Structure** (staged for future deployment)
4. **Cloudflare Tunnel Configuration** for public routing

## Service Ports & Routing

### Port Mapping Strategy

| Service Category | Port Range | Purpose |
|-----------------|------------|---------|
| Infrastructure | 3000-3099 | Core services (Grafana, Prometheus, etc.) |
| Proxy Services | 8000-8099 | Caddy proxy endpoints |
| Applications | 8100-8199 | Custom applications |
| Development | 8200-8299 | Development/testing services |

### Key Service Ports

| Service | Port | Network Access | Public URL |
|---------|------|----------------|------------|
| Caddy Proxy | 80, 443 | External + Internal | `https://chrislawrence.ca` |
| Grafana | 3000 | Internal + Proxy | `https://chrislawrence.ca/metrics` |
| Prometheus | 9090 | Internal + Proxy | `https://chrislawrence.ca/prometheus` |
| Portainer | 9000 | Internal + Proxy | `https://chrislawrence.ca/docker` |
| Uptime Kuma | 3001 | Internal + Proxy | `https://chrislawrence.ca/uptime` |
| CapitolScope API | 8120 | Internal + Proxy | `https://chrislawrence.ca/capitolscope` |
| CapitolScope Frontend | 8121 | Internal + Proxy | `https://chrislawrence.ca/capitolscope` |
| MagicPages API | 8100 | Internal + Proxy | `https://chrislawrence.ca/magicpages-api` |
| n8n | 5678 | Internal + Proxy | `https://chrislawrence.ca/n8n` |
| Obsidian | 8060 | Internal + Proxy | `https://chrislawrence.ca/notes` |
| Minecraft | 25565 | External + Internal | Direct access |

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

## Deployment Procedures

### Phase 1: Infrastructure Deployment

```bash
# Navigate to homelab directory
cd ~/github/hephaestus-homelab

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

# Update tunnel configuration (MANUAL STEP - contains secrets)
# Copy from cloudflare-tunnel-config-template.yml

# Restart Cloudflare Tunnel
sudo systemctl restart cloudflared

# Check tunnel status
sudo systemctl status cloudflared
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
- **Main Infrastructure**: `/home/chris/github/hephaestus-homelab/docker-compose-infrastructure.yml`
- **Proxy Stack**: `/home/chris/github/hephaestus-homelab/proxy/docker-compose.yml`
- **Monitoring Stack**: `/home/chris/github/hephaestus-homelab/grafana-stack/docker-compose.yml`

#### Application Files (Network Users)
- **Pattern**: `/home/chris/apps/*/docker-compose-homelab.yml`
- **Examples**:
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

# Test public access
curl -I https://chrislawrence.ca/dashboard -u admin:admin123
curl -I https://chrislawrence.ca/uptime -u admin:admin123
curl -I https://chrislawrence.ca/docker -u admin:admin123
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
- **Magic Pages API**: Port 8100 → `https://chrislawrence.ca/magicpages-api`
- **Magic Pages Frontend**: Port 8101 → `https://chrislawrence.ca/magicpages`
- **Portfolio App**: Port 8110 → `https://chrislawrence.ca/portfolio`
- **CapitolScope**: Port 8120 → `https://chrislawrence.ca/capitolscope`
- **SchedShare**: Port 8130 → `https://chrislawrence.ca/schedshare`

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
