# Hephaestus Homelab - Context Documentation

## Overview

This directory contains comprehensive documentation for the Hephaestus Homelab infrastructure, organized for use with AI assistants and automation systems. The documentation is structured to provide complete context about the server setup, services, and operational procedures.

## Documentation Structure

### Infrastructure (`infra/`)
Core infrastructure documentation:

- **[networks.md](./infra/networks.md)** - Docker network architecture and configuration
- **[dns-cloudflare.md](./infra/dns-cloudflare.md)** - DNS and Cloudflare tunnel configuration
- **[security.md](./infra/security.md)** - Security configuration and authentication
- **[deployment.md](./infra/deployment.md)** - Deployment procedures and service management
- **[services.md](./infra/services.md)** - Service architecture and definitions
- **[monitoring.md](./infra/monitoring.md)** - Comprehensive monitoring setup
- **[server-specs.md](./infra/server-specs.md)** - Hardware specifications and server details
- **[setup.md](./infra/setup.md)** - Installation and setup procedures

### Applications (`applications.md`)
Application services and custom applications:

- **[applications.md](./applications.md)** - Application services and management
- **[services-status.md](./services-status.md)** - Real-time service status tracking

## Quick Reference

### Server Details
- **Domain**: `chrislawrence.ca`
- **Tunnel ID**: `3a9f1023-0d6c-49ff-900d-32403e4309f8`
- **Network**: `homelab-web`
- **Local IP**: `192.168.50.70`
- **Tailscale Host**: `hephaestus.tailaa3ef2.ts.net`

### Key Services
- **Caddy**: Reverse proxy and SSL termination
- **Portainer**: Container management
- **Grafana**: Metrics visualization
- **Prometheus**: Metrics collection
- **Uptime Kuma**: Service monitoring

### Public URLs
- **Dev Dashboard**: `https://dev.chrislawrence.ca`
- **Docker**: `https://dev.chrislawrence.ca/docker`
- **Metrics**: `https://dev.chrislawrence.ca/metrics`
- **Uptime**: `https://uptime.chrislawrence.ca`
- **Portfolio**: `https://portfolio.chrislawrence.ca`
- **n8n**: `https://n8n.chrislawrence.ca`

## Service Ports

### Infrastructure Ports
| Service | Port | Purpose |
|---------|------|---------|
| Caddy | 80, 443 | Reverse proxy |
| Grafana | 3000 | Metrics visualization |
| Prometheus | 9090 | Metrics collection |
| Portainer | 9000 | Container management |
| Uptime Kuma | 3001 | Service monitoring |
| Dashy | 8082 | Dashboard |
| Organizr | 8086 | Unified dashboard |
| IT-Tools | 8081 | Network utilities |
| Glances | 61208 | System monitoring |
| cAdvisor | 8080 | Container metrics |
| Node Exporter | 9100 | Host metrics |

### Application Ports
| Service | Port | Purpose |
|---------|------|---------|
| Portfolio | 8110 | Personal portfolio |
| CapitolScope API | 8120 | Political data API |
| CapitolScope Frontend | 8121 | Political data UI |
| SchedShare | 8130 | Schedule sharing |
| EventSphere | 8140 | Event management |
| MagicPages API | 8100 | Content management API |
| MagicPages Frontend | 8101 | Content management UI |

### Development & Automation Ports
| Service | Port | Purpose |
|---------|------|---------|
| n8n | 5678 | Workflow automation |
| Obsidian | 8060 | Note-taking |

### Specialized Services Ports
| Service | Port | Purpose |
|---------|------|---------|
| Home Assistant | 8154 | IoT device management |
| MQTT Explorer | 8152 | MQTT monitoring |
| Node-RED | 8155 | Automation flows |
| InfluxDB | 8157 | Time-series database |
| Minecraft Map | 8159 | Game server map |
| Open WebUI | 8189 | AI interface |
| ComfyUI | 8188 | AI image generation |
| OpenRouter Proxy | 8190 | AI API proxy |
| Model Manager | 8191 | AI model management |

## Common Commands

### Service Management
```bash
# Start infrastructure
docker compose -f docker-compose-infrastructure.yml up -d

# Start proxy
docker compose -f proxy/docker-compose.yml up -d

# Start monitoring
docker compose -f grafana-stack/docker-compose.yml up -d

# Check status
docker compose -f docker-compose-infrastructure.yml ps
```

### Network Management
```bash
# Check network
docker network inspect homelab-web

# Test connectivity
docker exec -it caddy ping grafana
```

### Tunnel Management
```bash
# Check tunnel status
sudo systemctl status cloudflared

# Restart tunnel
sudo systemctl restart cloudflared

# View tunnel logs
sudo journalctl -u cloudflared -f
```

## Security Configuration

### Authentication Layers
1. **Cloudflare Access** - Primary protection for admin services
2. **Caddy Basic Auth** - Secondary authentication layer
3. **Service-level Auth** - Individual service authentication

### Protected Services
- `/dashboard/*` - Organizr dashboard
- `/docker/*` - Portainer
- `/uptime/*` - Uptime Kuma
- `/metrics/*` - Grafana
- `/prometheus/*` - Prometheus
- `/containers/*` - cAdvisor
- `/system/*` - Glances
- `/tools/*` - IT-Tools

### Public Services
- `/portfolio/*` - Portfolio app
- `/capitolscope/*` - CapitolScope app
- `/schedshare/*` - SchedShare app
- `/magicpages/*` - Magic Pages app

## Monitoring & Alerting

### Health Checks
```bash
# Check service health
curl -I http://192.168.50.70:3000  # Grafana
curl -I http://192.168.50.70:3001  # Uptime Kuma
curl -I http://192.168.50.70:9000  # Portainer

# Check proxy ports
curl -I http://192.168.50.70:8085 -u admin:admin123  # Grafana proxy
curl -I http://192.168.50.70:8086 -u admin:admin123  # Prometheus proxy
```

### Public Access Tests
```bash
# Test public access
curl -I https://chrislawrence.ca/dashboard -u admin:admin123
curl -I https://chrislawrence.ca/uptime -u admin:admin123
curl -I https://chrislawrence.ca/docker -u admin:admin123
```

## Troubleshooting

### Common Issues

#### Services Not Starting
```bash
# Check Docker status
docker ps
docker compose -f docker-compose-infrastructure.yml ps

# Check service logs
docker compose -f docker-compose-infrastructure.yml logs caddy
```

#### Network Issues
```bash
# Check network connectivity
docker network inspect homelab-web
docker exec -it caddy ping grafana
```

#### Public Access Issues
```bash
# Check tunnel status
sudo systemctl status cloudflared
sudo journalctl -u cloudflared -f

# Test local routing
curl -I http://localhost:80/dashboard -u admin:admin123
```

## Context Pack Integration

This documentation is designed for integration with the context pack system. Each document includes:

- **YAML Front Matter**: Metadata for indexing
- **Structured Content**: Organized for AI consumption
- **Cross-References**: Links between related documents
- **Code Examples**: Executable commands and configurations

### Context Pack Usage
```bash
# Reindex documentation
python3 $CONTEXT_HOME/tools/reindex.py --root $CONTEXT_HOME

# Include private content
python3 $CONTEXT_HOME/tools/reindex.py --root $CONTEXT_HOME --include-private

# Update SQLite index
make -C $CONTEXT_HOME fts
```

## Maintenance

### Regular Tasks
- [ ] Review service logs weekly
- [ ] Update documentation monthly
- [ ] Test backup procedures quarterly
- [ ] Review security configuration quarterly

### Documentation Updates
- [ ] Update service configurations
- [ ] Add new services to documentation
- [ ] Update troubleshooting procedures
- [ ] Review and update security policies

## Related Documentation

- [Network Architecture](./infra/networks.md) - Docker network setup
- [DNS & Cloudflare Configuration](./infra/dns-cloudflare.md) - Tunnel and DNS setup
- [Security Configuration](./infra/security.md) - Authentication and access control
- [Deployment Guide](./infra/deployment.md) - Service deployment procedures
- [Service Architecture](./infra/services.md) - Service definitions and management
- [Application Services](./applications.md) - Application services and management

---

**Last Updated**: $(date)
**Documentation Version**: 1.0
**Compatible With**: Context Pack v1.0, Docker Compose v2.0+
