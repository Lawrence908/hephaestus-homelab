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

#### Public Web Applications
- **Portfolio**: Personal portfolio website (`https://portfolio.chrislawrence.ca`)
- **SchedShare**: Schedule sharing application (`https://schedshare.chrislawrence.ca`)
- **CapitolScope**: Political data analysis platform (`https://capitolscope.chrislawrence.ca`)
- **MagicPages**: Content management system (`https://magicpages.chrislawrence.ca`)
- **EventSphere**: Event management system (`https://eventsphere.chrislawrence.ca`)

#### Protected Services
- **Dev Environment**: Development tools (`https://dev.chrislawrence.ca`)
- **Monitor**: System monitoring (`https://monitor.chrislawrence.ca`)
- **IoT Services**: IoT device management (`https://iot.chrislawrence.ca`)
- **Minecraft**: Game server (`https://minecraft.chrislawrence.ca`)
- **AI Services**: AI inference (`https://ai.chrislawrence.ca`)
- **Dashboard**: Organizr dashboard (`https://dev.chrislawrence.ca/dashboard`)
- **Docker**: Portainer (`https://dev.chrislawrence.ca/docker`)
- **Uptime**: Uptime Kuma (`https://dev.chrislawrence.ca/uptime`)
- **Metrics**: Grafana (`https://dev.chrislawrence.ca/metrics`)
- **Prometheus**: Prometheus (`https://dev.chrislawrence.ca/prometheus`)
- **Containers**: cAdvisor (`https://dev.chrislawrence.ca/containers`)
- **System**: Glances (`https://dev.chrislawrence.ca/system`)
- **Tools**: IT-Tools (`https://dev.chrislawrence.ca/tools`)
- **n8n**: n8n automation (`https://dev.chrislawrence.ca/n8n`)
- **Notes**: Obsidian (`https://dev.chrislawrence.ca/notes`)
- **MQTT**: MQTT Explorer (`https://dev.chrislawrence.ca/mqtt`)
- **Meshtastic**: Meshtastic Web (`https://dev.chrislawrence.ca/meshtastic`)
- **Node-RED**: Node-RED (`https://dev.chrislawrence.ca/nodered`)
- **Grafana IoT**: Grafana IoT (`https://dev.chrislawrence.ca/grafana-iot`)
- **InfluxDB**: InfluxDB (`https://dev.chrislawrence.ca/influxdb`)

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

#### daedalOS Service Definition
```yaml
services:
  daedalos:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: daedalos
    restart: unless-stopped
    networks:
      - web
    ports:
      - "8158:3000"
    environment:
      - NODE_ENV=production
    volumes:
      - daedalos_data:/app/data
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:3000"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

## Service Communication

### Internal Communication
- **Network**: `homelab-web` (Docker bridge network)
- **DNS**: Container names resolve automatically
- **Ports**: Internal ports only (no external exposure)

### External Communication
- **Public Access**: Through Cloudflare Tunnel with subdomain routing
- **Protected Access**: Through Cloudflare Access authentication
- **Local Access**: Direct port mapping for development
- **Security**: "Default deny with explicit allow" model

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
            Cloudflare Access (Protected Services)
                ↓
            Monitoring & Logging
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
- **Cloudflare Access**: Primary authentication for protected services
- **Public Services**: No authentication required
- **Service Auth**: Individual service authentication where needed

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



