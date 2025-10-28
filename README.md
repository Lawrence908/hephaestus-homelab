# Hephaestus Homelab

**Dell OptiPlex 7040 Ubuntu Server 24.04 - Docker-based Homelab Platform**

> *Named after the Greek god of fire and the forge, Hephaestus transforms raw resources into powerful tools. This homelab forges containers, hosts applications, and manages infrastructure with precision and reliability.*

---

## Overview

Hephaestus is a production-ready Docker-based homelab platform designed to replace traditional NAS setups. It provides a complete infrastructure stack for hosting multiple applications, monitoring system health, and managing services through a unified interface.

### Key Features

- **Reverse Proxy**: Caddy with automatic HTTPS
- **Zero-Trust Access**: Cloudflare Tunnel (no port forwarding required)
- **Comprehensive Monitoring**: Grafana + Prometheus + cAdvisor + Glances
- **Uptime Monitoring**: Uptime Kuma with status pages
- **Container Management**: Portainer with web UI
- **Automatic Updates**: Watchtower with label-based control
- **Security**: UFW firewall, Fail2Ban, SSH hardening
- **Automated Backups**: Daily backup scripts with retention

---

## Architecture

```
Internet
    ↓
Cloudflare Tunnel (zero-trust, no open ports)
    ↓
Caddy Reverse Proxy (automatic HTTPS, internal routing)
    ↓
┌─────────────────────────────────────────────────────┐
│  Docker Network: web (bridge)                       │
│                                                      │
│  Infrastructure Services:                           │
│  • Portainer (container management)                 │
│  • Uptime Kuma (uptime monitoring)                  │
│  • Watchtower (auto-updates)                        │
│  • Grafana + Prometheus (metrics & visualization)   │
│  • cAdvisor + Node Exporter (system metrics)        │
│  • Glances (real-time monitoring)                   │
│                                                      │
│  Application Services:                              │
│  • Magic Pages API (Django + Gunicorn)              │
│  • CapitolScope (FastAPI + Postgres)                │
│  • SchedShare (Flask)                               │
│  • Portfolio (Flask)                                │
│  • Magic Pages Frontend (Nginx static)              │
└─────────────────────────────────────────────────────┘
    ↓
Host: Hephaestus (Dell OptiPlex 7040)
Ubuntu Server 24.04 LTS
Static IP: 192.168.50.70
```

---

## Quick Start

### Prerequisites

- Dell OptiPlex 7040 (or similar)
- Ubuntu Server 24.04 LTS installed
- Docker Engine 27.x installed
- Static IP configured (192.168.50.70)
- Domain name with Cloudflare DNS

### 1. Configure Environment

```bash
# Copy environment template
cp .env.example .env

# Edit with your values
nano .env
```

**Required variables**:
- `DOMAIN`: Your domain name
- `CLOUDFLARE_TUNNEL_TOKEN`: From Cloudflare Zero Trust
- `CLOUDFLARE_API_TOKEN`: For automatic DNS/SSL
- Database passwords
- Application secrets

### 2. Create Docker Network

```bash
docker network create web
```

### 3. Start Services

```bash
cd ~/github/hephaestus-homelab

# Start infrastructure services
docker compose up -d

# Check status
docker compose ps

# View logs
docker compose logs -f
```

### 4. Access Services

**Public Services (via Cloudflare Tunnel)**:
- Landing Page: `https://chrislawrence.ca`
- Portfolio: `https://portfolio.chrislawrence.ca`
- SchedShare: `https://schedshare.chrislawrence.ca`
- CapitolScope: `https://capitolscope.chrislawrence.ca`
- MagicPages: `https://magicpages.chrislawrence.ca`
- MagicPages API: `https://api.magicpages.chrislawrence.ca`
- EventSphere: `https://eventsphere.chrislawrence.ca`

**Protected Services (Cloudflare Access Required)**:
- Dev Environment: `https://dev.chrislawrence.ca`
- Monitor: `https://monitor.chrislawrence.ca`
- IoT Services: `https://iot.chrislawrence.ca`
- Minecraft: `https://minecraft.chrislawrence.ca`
- AI Services: `https://ai.chrislawrence.ca`

**LAN Only**:
- Portainer: `http://192.168.50.70:9000`
- Glances: `http://192.168.50.70:61208`
- Prometheus: `http://192.168.50.70:9090`

---

## Documentation

Comprehensive guides are available in the [`docs/`](./docs) directory:

| Document | Description |
|----------|-------------|
| **[SETUP.md](./docs/SETUP.md)** | Complete installation guide from BIOS to deployment |
| **[NETWORKING.md](./docs/NETWORKING.md)** | Static IP, Cloudflare Tunnel, DNS, and Caddy configuration |
| **[SECURITY.md](./docs/SECURITY.md)** | UFW firewall, Fail2Ban, SSH hardening, Docker security |
| **[MONITORING.md](./docs/MONITORING.md)** | Uptime Kuma, Grafana dashboards, Prometheus, alerts |

---

## Services

### Infrastructure

| Service | Version | Purpose | Port(s) |
|---------|---------|---------|---------|
| **Caddy** | 2-alpine | Reverse proxy, automatic HTTPS | 80, 443 |
| **Cloudflared** | latest | Cloudflare Tunnel connector | - |
| **Portainer** | latest | Docker management UI | 9000 |
| **Uptime Kuma** | 1 | Uptime monitoring & status pages | 3001 |
| **Watchtower** | latest | Automatic container updates | - |

### Monitoring

| Service | Version | Purpose | Port(s) |
|---------|---------|---------|---------|
| **Grafana** | latest | Metrics visualization | 3000 |
| **Prometheus** | latest | Metrics collection & storage | 9090 |
| **cAdvisor** | latest | Container metrics | 8080 |
| **Node Exporter** | (in grafana-stack) | Host system metrics | 9100 |
| **Glances** | latest | Real-time system monitor | 61208 |

### Applications

| Service | Stack | Purpose | Port(s) | Public URL |
|---------|-------|---------|----------|------------|
| **Portfolio** | Flask | Personal portfolio site | 5000 | `https://portfolio.chrislawrence.ca` |
| **SchedShare** | Flask | Schedule parsing app | 5000 | `https://schedshare.chrislawrence.ca` |
| **CapitolScope** | React + Python | Political data analysis | 5173 | `https://capitolscope.chrislawrence.ca` |
| **MagicPages** | Django | Content management system | 8000 | `https://magicpages.chrislawrence.ca` |
| **MagicPages API** | Django | API endpoint | 8000 | `https://api.magicpages.chrislawrence.ca` |
| **EventSphere** | Flask | Event management system | 5000 | `https://eventsphere.chrislawrence.ca` |

---

## Management

### Common Commands

```bash
# View all services
docker compose ps

# View logs
docker compose logs -f [service]

# Restart a service
docker compose restart [service]

# Rebuild and restart
docker compose up -d --build [service]

# Stop all services
docker compose down

# Update all images
docker compose pull && docker compose up -d
```

### Maintenance Scripts

```bash
# Daily backup (run manually or via cron)
./scripts/backup.sh

# Update system and Docker images
./scripts/update.sh

# Interactive mode with prompts
./scripts/update.sh

# Automatic mode (no prompts)
./scripts/update.sh --auto
```

### Setup Automated Backups

```bash
# Edit crontab
crontab -e

# Add daily backup at 2 AM
0 2 * * * /home/chris/github/hephaestus-homelab/scripts/backup.sh
```

### Setup Weekly Updates

```bash
# Add weekly update at 3 AM Sunday
0 3 * * 0 /home/chris/github/hephaestus-homelab/scripts/update.sh --auto
```

---

## Security

### Implemented Security Measures

**Network Security**
- No ports forwarded on router (80/443 closed)
- All public traffic through Cloudflare Tunnel
- UFW firewall with default deny
- Docker network isolation

**Access Control**
- SSH key-only authentication
- Password authentication disabled
- Fail2Ban monitoring SSH attempts
- Cloudflare WAF and DDoS protection
- Cloudflare Access for protected services

**Container Security**
- Non-root containers where possible
- Read-only configuration mounts
- Watchtower label-based updates only
- Security options enabled (no-new-privileges)

**Data Protection**
- Automated encrypted backups
- Sensitive data in `.env` (not committed)
- SSL/TLS via Cloudflare (Full strict mode)
- Database credentials isolated

See [SECURITY.md](./docs/SECURITY.md) for detailed configuration.

---

## Monitoring & Alerts

### Health Checks

- **Uptime Kuma**: HTTP/HTTPS endpoint monitoring every 60s
- **Grafana**: System and container metrics dashboards
- **Prometheus**: 15-day metric retention
- **Glances**: Real-time system resource monitoring

### Available Dashboards

1. **Hephaestus Overview** (`grafana-stack/dashboards/hephaestus-overview.json`)
   - CPU, memory, disk usage
   - Network I/O
   - Top containers by resource usage
   - Uptime Kuma monitor status

2. **Uptime Kuma Status Page**
   - Public status page for all services
   - Historical uptime data
   - Incident timeline

### Alert Channels

- Discord webhooks
- Email notifications
- Telegram bots
- Custom webhooks

See [MONITORING.md](./docs/MONITORING.md) for setup instructions.

---

## Project Structure

```
hephaestus-homelab/
├── docker-compose.yml           # Main orchestration file
├── .env.example                 # Environment variable template
├── .gitignore                   # Git ignore rules
├── README.md                    # This file
│
├── proxy/                       # Reverse proxy configuration
│   ├── Caddyfile                # Caddy routing rules
│   ├── docker-compose.yml       # Standalone proxy stack
│   └── nginx-static.conf        # Static site nginx config
│
├── grafana-stack/               # Monitoring stack
│   ├── docker-compose.yml       # Grafana + Prometheus stack
│   ├── prometheus.yml           # Prometheus scrape config
│   ├── datasources.yml          # Grafana data sources
│   └── dashboards/
│       └── hephaestus-overview.json  # Main dashboard
│
├── docs/                        # Documentation
│   ├── SETUP.md                 # Installation guide
│   ├── NETWORKING.md            # Network configuration
│   ├── SECURITY.md              # Security hardening
│   └── MONITORING.md            # Monitoring setup
│
├── scripts/                     # Utility scripts
│   ├── backup.sh                # Automated backup script
│   └── update.sh                # System update script
│
└── prompts/                     # Planning documents (optional)
    ├── 1.install_ubuntu_on_dell7040.md
    ├── 2.Flight plan.md
    ├── 3.yaml.md
    ├── 4.scaffold1.md
    └── 5.scaffold2.md
```

**Note**: Application repositories are stored separately in `~/apps/` and mounted via volume paths in `.env`.

---

## Workflow

### Daily Operations

1. Check Uptime Kuma dashboard
2. Review Grafana metrics for anomalies
3. Check for container restarts: `docker compose ps`

### Weekly Maintenance

1. Run update script: `./scripts/update.sh`
2. Review backup logs
3. Check disk space: `df -h`
4. Clean up Docker: `docker system prune -f`

### Monthly Reviews

1. Audit UFW and Fail2Ban logs
2. Review Cloudflare WAF events
3. Test backup restoration
4. Update documentation
5. Review and tune alert thresholds

---

## Troubleshooting

### Container Won't Start

```bash
# Check logs
docker compose logs [service]

# Check disk space
df -h

# Recreate container
docker compose up -d --force-recreate [service]
```

### Can't Access Services

```bash
# Check Caddy is running
docker compose ps caddy

# Check Caddy logs
docker compose logs caddy

# Test internal connectivity
docker exec caddy ping uptime-kuma

# Verify network
docker network inspect web
```

### Cloudflare Tunnel Issues

```bash
# Check cloudflared logs
docker compose logs cloudflared

# Verify tunnel status in Cloudflare Dashboard
# Zero Trust → Networks → Tunnels

# Restart tunnel
docker compose restart cloudflared
```

---

## Future Enhancements

### Planned Additions

- [ ] Tailscale VPN integration for secure remote access
- [ ] Pi-hole for network-wide ad blocking
- [ ] Nextcloud for file storage and collaboration
- [ ] Alertmanager for advanced alert routing
- [ ] MinIO for S3-compatible object storage
- [ ] GitLab/Gitea for self-hosted Git repositories

### Migration Paths

- **K3s**: Lightweight Kubernetes for orchestration at scale
- **Proxmox**: Virtualization layer for running multiple VMs
- **Docker Swarm**: Multi-node container orchestration

See planning docs in [`prompts/`](./prompts) for architecture evolution.

---

<!-- Contributing section intentionally removed as this repository is tailored to a personal homelab setup. -->

## License

This project is licensed under the MIT License - see LICENSE file for details.

---

## Getting Started Checklist

Follow this checklist to get Hephaestus up and running:

### Pre-Installation
- [ ] Hardware prepared (Dell OptiPlex 7040)
- [ ] Ubuntu Server 24.04 LTS downloaded
- [ ] Bootable USB created
- [ ] Static IP planned (192.168.50.70)

### Installation
- [ ] Ubuntu Server installed
- [ ] Static IP configured
- [ ] SSH access working
- [ ] Docker Engine installed
- [ ] UFW firewall enabled

### Configuration
- [ ] `.env` file created and configured
- [ ] Docker network `web` created

### Cloudflare
- [ ] Cloudflare Tunnel created
- [ ] Tunnel token added to `.env`
- [ ] Public hostnames configured
- [ ] DNS records verified

### Deployment
- [ ] All services started: `docker compose up -d`
- [ ] Container health verified: `docker compose ps`
- [ ] Logs checked for errors
- [ ] Services accessible via Cloudflare Tunnel

### Post-Deployment
- [ ] Uptime Kuma monitors configured
- [ ] Grafana dashboard imported
- [ ] Backup script tested: `./scripts/backup.sh`
- [ ] Backup cron job scheduled
- [ ] Update script tested: `./scripts/update.sh`
- [ ] Fail2Ban installed and configured
- [ ] Security checklist completed

---

**Ready to forge your homelab? Start with [SETUP.md](./docs/SETUP.md)!**

---

<p align="center">
  <strong>Built by the Forge of Hephaestus</strong>
</p>

