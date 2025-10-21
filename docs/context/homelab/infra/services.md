# Hephaestus Homelab - Service Architecture

## Overview

This document outlines the service architecture, service definitions, and operational procedures for all services in the Hephaestus Homelab infrastructure.

## Service Categories

### Infrastructure Services
Core services that provide the foundation for the homelab:

#### Reverse Proxy & Routing
- **Caddy**: Reverse proxy, SSL termination, routing
- **Cloudflare Tunnel**: Secure public access

#### Container Management
- **Portainer**: Docker container management
- **Watchtower**: Automatic container updates

#### Monitoring & Observability
- **Grafana**: Metrics visualization and dashboards
- **Prometheus**: Metrics collection and alerting
- **Uptime Kuma**: Service availability monitoring
- **cAdvisor**: Container resource monitoring
- **Glances**: System resource monitoring

#### Development & Automation
- **n8n**: Workflow automation
- **Node-RED**: IoT and automation flows
- **Obsidian**: Note-taking and knowledge management

### Application Services
Custom applications and services:

#### Web Applications
- **Portfolio**: Personal portfolio website
- **CapitolScope**: Political data analysis platform
- **SchedShare**: Schedule sharing application
- **MagicPages**: Content management system

#### APIs & Backend Services
- **MagicPages API**: Content management API
- **CapitolScope API**: Political data API

#### Specialized Services
- **Minecraft Server**: Game server with Dynmap
- **MQTT Explorer**: IoT device management
- **Meshtastic Web**: Mesh networking interface
- **Grafana IoT**: IoT-specific monitoring
- **InfluxDB**: Time-series database

## Service Definitions

### Infrastructure Stack (`docker-compose-infrastructure.yml`)

#### Caddy (Reverse Proxy)
```yaml
caddy:
  image: caddy:2-alpine
  container_name: caddy
  restart: unless-stopped
  networks:
    - homelab-web
  ports:
    - "80:80"
    - "443:443"
    - "443:443/udp"
    - "8083:8083"  # Uptime Kuma proxy
    - "8084:8084"  # Portainer proxy
    - "8085:8085"  # Grafana proxy
    - "8086:8086"  # Prometheus proxy
    - "8087:8087"  # cAdvisor proxy
    - "8088:8088"  # Glances proxy
    - "8089:8089"  # IT-Tools proxy
  volumes:
    - ./Caddyfile:/etc/caddy/Caddyfile:ro
    - caddy_data:/data
    - caddy_config:/config
```

#### Portainer (Container Management)
```yaml
portainer:
  image: portainer/portainer-ce:latest
  container_name: portainer
  restart: unless-stopped
  networks:
    - homelab-web
  ports:
    - "9000:9000"
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock
    - portainer_data:/data
```

#### Uptime Kuma (Monitoring)
```yaml
uptime-kuma:
  image: louislam/uptime-kuma:1
  container_name: uptime-kuma
  restart: unless-stopped
  networks:
    - homelab-web
  ports:
    - "3001:3001"
  volumes:
    - uptime_kuma_data:/app/data
```

### Monitoring Stack (`grafana-stack/docker-compose.yml`)

#### Grafana (Visualization)
```yaml
grafana:
  image: grafana/grafana:latest
  container_name: grafana
  restart: unless-stopped
  networks:
    - homelab-web
  ports:
    - "3000:3000"
  volumes:
    - grafana_data:/var/lib/grafana
  environment:
    - GF_SECURITY_ADMIN_PASSWORD=admin
```

#### Prometheus (Metrics)
```yaml
prometheus:
  image: prom/prometheus:latest
  container_name: prometheus
  restart: unless-stopped
  networks:
    - homelab-web
  ports:
    - "9090:9090"
  volumes:
    - prometheus_data:/prometheus
    - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
```

### Application Services

#### Standard Application Pattern
```yaml
networks:
  web:
    external: true
    name: homelab-web

services:
  app-service:
    image: app-image:latest
    container_name: app-service
    restart: unless-stopped
    networks:
      - web
    ports:
      - "81XX:8080"  # Application port
    volumes:
      - app_data:/data
    environment:
      - ENV_VAR=value
```

## Service Communication

### Internal Communication
- **Network**: `homelab-web` (Docker bridge network)
- **DNS**: Container names resolve automatically
- **Ports**: Internal ports only (no external exposure)

### External Communication
- **Public Access**: Through Caddy proxy via Cloudflare Tunnel
- **Local Access**: Direct port mapping for development
- **Admin Access**: Through Organizr dashboard

## Service Dependencies

### Critical Path
1. **Docker Network**: `homelab-web` must exist
2. **Caddy**: All external access depends on Caddy
3. **Cloudflare Tunnel**: Public access depends on tunnel
4. **Monitoring**: Services depend on Prometheus/Grafana

### Service Dependencies
```
Cloudflare Tunnel → Caddy → Applications
                ↓
            Prometheus → Grafana
                ↓
            Uptime Kuma
```

## Service Management

### Starting Services
```bash
# Infrastructure services
docker compose -f docker-compose-infrastructure.yml up -d

# Proxy services
docker compose -f proxy/docker-compose.yml up -d

# Monitoring services
docker compose -f grafana-stack/docker-compose.yml up -d

# Application services
cd ~/apps/your-app
docker compose -f docker-compose-homelab.yml up -d
```

### Stopping Services
```bash
# Stop specific service
docker compose -f docker-compose-infrastructure.yml stop caddy

# Stop all services
docker compose -f docker-compose-infrastructure.yml down

# Stop with volumes (WARNING: Data loss)
docker compose -f docker-compose-infrastructure.yml down -v
```

### Updating Services
```bash
# Update specific service
docker compose -f docker-compose-infrastructure.yml pull caddy
docker compose -f docker-compose-infrastructure.yml up -d caddy

# Update all services
docker compose -f docker-compose-infrastructure.yml pull
docker compose -f docker-compose-infrastructure.yml up -d
```

## Service Monitoring

### Health Checks
```bash
# Check service status
docker compose -f docker-compose-infrastructure.yml ps

# Check service logs
docker compose -f docker-compose-infrastructure.yml logs caddy

# Check service health
docker exec -it caddy caddy validate --config /etc/caddy/Caddyfile
```

### Metrics Collection
- **Prometheus**: Collects metrics from all services
- **Grafana**: Visualizes metrics and creates dashboards
- **cAdvisor**: Container resource usage
- **Node Exporter**: System metrics

### Alerting
- **Uptime Kuma**: Service availability alerts
- **Prometheus**: Metric-based alerts
- **Grafana**: Dashboard-based alerts

## Service Configuration

### Environment Variables
```bash
# Caddy configuration
DOMAIN=chrislawrence.ca
CLOUDFLARE_API_TOKEN=your_token
CLOUDFLARE_EMAIL=your_email

# Grafana configuration
GF_SECURITY_ADMIN_PASSWORD=admin
GF_INSTALL_PLUGINS=grafana-clock-panel

# Application configuration
DATABASE_URL=postgresql://user:pass@db:5432/app
REDIS_URL=redis://redis:6379
```

### Volume Management
```bash
# List volumes
docker volume ls

# Inspect volume
docker volume inspect caddy_data

# Backup volume
docker run --rm -v caddy_data:/data -v /backup:/backup alpine tar czf /backup/caddy-data.tar.gz -C /data .
```

## Service Security

### Network Security
- **Internal Networks**: Services communicate through `homelab-web`
- **External Access**: Only through Caddy proxy
- **Port Exposure**: Minimal external port exposure

### Authentication
- **Cloudflare Access**: Primary authentication for admin services
- **Caddy Basic Auth**: Secondary authentication layer
- **Service Auth**: Individual service authentication

### Data Protection
- **Volume Encryption**: Docker volumes can be encrypted
- **Backup Encryption**: Backup data encrypted at rest
- **Network Encryption**: TLS termination at Caddy

## Troubleshooting

### Service Issues
```bash
# Check service logs
docker compose -f docker-compose-infrastructure.yml logs service-name

# Check service status
docker compose -f docker-compose-infrastructure.yml ps service-name

# Restart service
docker compose -f docker-compose-infrastructure.yml restart service-name
```

### Network Issues
```bash
# Check network connectivity
docker network inspect homelab-web

# Test service communication
docker exec -it caddy ping grafana
docker exec -it grafana ping prometheus
```

### Performance Issues
```bash
# Check resource usage
docker stats

# Check service metrics
curl http://localhost:9090/metrics  # Prometheus
curl http://localhost:3000/api/health  # Grafana
```

## Related Documentation

- [Network Architecture](./networks.md) - Docker network setup
- [DNS & Cloudflare Configuration](./dns-cloudflare.md) - Tunnel and DNS setup
- [Security Configuration](./security.md) - Authentication and access control
- [Deployment Guide](./deployment.md) - Service deployment procedures

---

**Last Updated**: $(date)
**Service Version**: 1.0
**Compatible With**: Docker Compose v2.0+, Docker Engine 27.x


