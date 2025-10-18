# Hephaestus Homelab - Server Specifications

## Hardware Specifications

### Dell OptiPlex 7040
- **CPU**: Intel Core i5/i7 (6th Gen)
- **RAM**: 16GB+ DDR4 recommended
- **Storage**: SSD for OS + applications
- **Network**: Gigabit Ethernet
- **Hostname**: Hephaestus
- **OS**: Ubuntu Server 24.04 LTS

## Network Configuration

### Static IP Configuration
- **Local IP**: `192.168.50.70/24`
- **Public IP**: `24.69.104.19`
- **Gateway**: `192.168.50.1`
- **DNS**: `1.1.1.1`, `8.8.8.8`
- **Interface**: `enp0s31f6` (use `ip link show` to verify)

### Network Topology
```
Internet
    ↓
Router (192.168.50.1)
    ↓
Hephaestus (192.168.50.70) ←→ LAN devices
    ↓
Docker Network: homelab-web (bridge: 172.20.0.0/16)
    ↓
Containers (caddy, apps, monitoring)
```

## Docker Network Configuration

```yaml
networks:
  homelab-web:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

## Complete Port Mapping

### Infrastructure Services
| Service | Internal Port | External Access | Purpose | Status |
|---------|--------------|-----------------|---------|--------|
| **Portainer** | 9000 | Via Cloudflare Tunnel | Docker Management | 🟢 Running |
| **Uptime Kuma** | 3001 | Via Cloudflare Tunnel | Monitoring | 🟢 Running |
| **Grafana** | 3000 | Via Cloudflare Tunnel | Metrics Dashboard | 🟢 Running |
| **Prometheus** | 9090 | Via Cloudflare Tunnel | Metrics Collection | 🟢 Running |
| **Glances** | 61208 | LAN Only | System Monitor | 🟢 Running |
| **cAdvisor** | 8080 | LAN Only | Container Metrics | 🟢 Running |
| **Node Exporter** | 9100 | LAN Only | Host Metrics | 🟢 Running |
| **IT-Tools** | 8081 | LAN Only | IT Utilities | 🟢 Running |
| **Organizr** | 8082 | Via Cloudflare Tunnel | Central Dashboard | 🟢 Running |

### Application Services
| Application | Internal Port | External Access | Purpose | Status |
|-------------|--------------|-----------------|---------|--------|
| **Magic Pages API** | 8100 | Via Cloudflare Tunnel | Django API | 🟡 Pending |
| **Magic Pages Frontend** | 8101 | Via Cloudflare Tunnel | Static Site | 🟡 Pending |
| **Portfolio** | 8110 | Via Cloudflare Tunnel | Flask App | 🟡 Pending |
| **CapitolScope** | 8120 | Via Cloudflare Tunnel | FastAPI App | 🟡 Pending |
| **SchedShare** | 8130 | Via Cloudflare Tunnel | Flask App | 🟡 Pending |

### Port Range Organization
```
8000-8009: Magic Pages ecosystem
8010-8019: Portfolio & personal projects  
8020-8029: CapitolScope & political tools
8030-8039: SchedShare & scheduling tools
8040-8049: Future services
8050-8059: Development/testing
```

## Domain Mapping

| Domain | Service | Internal Target | Port |
|--------|---------|----------------|------|
| `hephaestus.chrislawrence.ca` | Admin Panel | Portainer | 9000 |
| `uptime.chrislawrence.ca` | Monitoring | Uptime Kuma | 3001 |
| `grafana.chrislawrence.ca` | Metrics | Grafana | 3000 |
| `api.magicpages.chrislawrence.ca` | API | Magic Pages API | 8100 |
| `magicpages.chrislawrence.ca` | Frontend | Magic Pages Frontend | 8101 |
| `portfolio.chrislawrence.ca` | Portfolio | Portfolio App | 8110 |
| `capitolscope.chrislawrence.ca` | CapitolScope | CapitolScope App | 8120 |
| `schedshare.chrislawrence.ca` | SchedShare | SchedShare App | 8130 |
| `dashboard.hephaestus.chrislawrence.ca` | Dashboard | Organizr | 8082 |

## Security Zones

### Public Access (via Cloudflare Tunnel)
- All web applications
- Monitoring dashboards (Grafana, Uptime Kuma, Prometheus)
- API endpoints
- Portainer (Docker management)

### LAN Only Access
- Glances (system monitoring)
- cAdvisor (container metrics)
- Node Exporter (host metrics)
- IT-Tools (IT utilities)

### No External Access
- Database ports (Postgres, Redis)
- Internal service communication

## Cloudflare Tunnel Configuration

### Tunnel Details
- **Tunnel ID**: `3a9f1023-0d6c-49ff-900d-32403e4309f8`
- **Tunnel Name**: `hephaestus-tunnel`
- **Config File**: `~/.cloudflared/config.yml`
- **Credentials**: `~/.cloudflared/3a9f1023-0d6c-49ff-900d-32403e4309f8.json`

### Tunnel Management Commands
```bash
# Start tunnel manually (for testing)
cloudflared tunnel run hephaestus-tunnel

# Install as system service
sudo cloudflared service install
sudo systemctl enable cloudflared
sudo systemctl start cloudflared

# Check tunnel status
sudo systemctl status cloudflared
```

## Local Access URLs

### Direct LAN Access
```
Portainer (Docker management) - http://192.168.50.70:9000
Grafana (Metrics dashboard) - http://192.168.50.70:3000
Uptime Kuma (Uptime monitoring) - http://192.168.50.70:3001
Prometheus (Metrics collection) - http://192.168.50.70:9090
cAdvisor (Container metrics) - http://192.168.50.70:8080
Glances (System monitoring) - http://192.168.50.70:61208
IT-Tools (IT utilities) - http://192.168.50.70:8081
Organizr (Central dashboard) - http://192.168.50.70:8082
```

### Public Access (via Cloudflare Tunnel)
```
Admin Panel: https://hephaestus.chrislawrence.ca
Monitoring: https://uptime.chrislawrence.ca
Metrics: https://grafana.chrislawrence.ca
API: https://api.magicpages.chrislawrence.ca
Frontend: https://magicpages.chrislawrence.ca
Portfolio: https://portfolio.chrislawrence.ca
CapitolScope: https://capitolscope.chrislawrence.ca
SchedShare: https://schedshare.chrislawrence.ca
Dashboard: https://dashboard.hephaestus.chrislawrence.ca
```

## Docker Management Commands

### Essential Commands
```bash
# Navigate to project
cd ~/github/hephaestus-homelab

# Start all services
docker compose up -d

# Check service status
docker compose ps

# View logs
docker compose logs -f [service]

# Restart specific service
docker compose restart [service]

# Stop all services
docker compose down

# Update all containers
docker compose pull
docker compose up -d
```

### Health Checks
```bash
# Test internal connectivity
curl -I http://localhost:9000  # Portainer
curl -I http://localhost:3001  # Uptime Kuma
curl -I http://localhost:3000  # Grafana

# Test Docker network
docker network inspect homelab-web
docker exec caddy ping uptime-kuma
```

### Troubleshooting
```bash
# Find what's using a port
sudo lsof -i :80
sudo lsof -i :443

# Check disk space
df -h

# Check memory
free -h

# Recreate network
docker network rm homelab-web
docker network create homelab-web
```

## Environment Variables

Key environment variables from `.env`:
```bash
DOMAIN=chrislawrence.ca
CLOUDFLARE_TUNNEL_TOKEN=eyJhIjoi...
# Application-specific secrets
MAGIC_PAGES_SECRET_KEY=...
CAPITOLSCOPE_SECRET_KEY=...
SCHEDSHARE_SECRET_KEY=...
# Organizr API Key
ORGANIZR_API_KEY=m6anohg2zwu3emo13e4r
```

## Directory Structure

```
~/github/hephaestus-homelab/
├── docker-compose-infrastructure.yml
├── .env
├── proxy/
│   └── Caddyfile
├── scripts/
│   ├── backup.sh
│   └── health-check.sh
└── docs/
    ├── SETUP.md
    ├── NETWORKING.md
    ├── PORTS.md
    └── SERVER_CONTEXT.md

~/apps/
├── magic-pages-api/
├── magic-pages-frontend/
├── capitolscope/
├── schedshare/
└── portfolio/
```

## Common Issues & Solutions

### Port Conflicts
```bash
# Find conflicting process
sudo lsof -i :PORT
# Kill process
sudo kill -9 PID
```

### Network Issues
```bash
# Restart networking
sudo systemctl restart systemd-networkd
sudo netplan apply
```

### Docker Issues
```bash
# Restart Docker
sudo systemctl restart docker
# Clean up
docker system prune -a
```

## Quick Reference

### Essential Ports
- **9000**: Portainer
- **3001**: Uptime Kuma
- **3000**: Grafana
- **9090**: Prometheus

### Application Ports
- **8100**: Magic Pages API
- **8101**: Magic Pages Frontend
- **8110**: Portfolio
- **8120**: CapitolScope
- **8130**: SchedShare

### Monitoring Ports
- **9090**: Prometheus
- **61208**: Glances
- **8080**: cAdvisor
- **9100**: Node Exporter
- **8081**: IT-Tools
- **8082**: Organizr

## Related Documentation

- [Network Architecture](./networks.md) - Docker network setup
- [DNS & Cloudflare Configuration](./dns-cloudflare.md) - Tunnel and DNS setup
- [Security Configuration](./security.md) - Authentication and access control
- [Deployment Guide](./deployment.md) - Service deployment procedures
- [Service Architecture](./services.md) - Service definitions and management

---

**Last Updated**: $(date)
**Server Version**: 1.0
**Compatible With**: Ubuntu Server 24.04 LTS, Docker Engine 27.x
