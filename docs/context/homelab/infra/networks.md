# Hephaestus Homelab - Network Architecture

## Overview

This document outlines the Docker network architecture for the Hephaestus Homelab infrastructure. All services are designed to work together through a unified network system that enables secure, efficient communication between containers.

## Network Architecture

### Primary Network: `homelab-web`

The homelab uses a single primary network called `homelab-web` that serves as the backbone for all service communication.

```yaml
networks:
  homelab-web:
    driver: bridge
```

### Network Design Principles

1. **Single Network Backbone**: All services communicate through the `homelab-web` network
2. **External Network References**: Apps reference the network as `web` with external name `homelab-web`
3. **Service Isolation**: Internal networks for service-specific components (databases, caches)
4. **Security**: Services can communicate with each other while maintaining logical separation

## Network Configuration Files

### Infrastructure Files (Network Creators)

These files **create** the `homelab-web` network:

#### 1. Main Infrastructure Stack
- **File**: `/home/chris/github/hephaestus-homelab/docker-compose-infrastructure.yml`
- **Purpose**: Core infrastructure services (Caddy, Portainer, Uptime Kuma, etc.)
- **Network**: Creates `homelab-web` network

#### 2. Proxy Stack
- **File**: `/home/chris/github/hephaestus-homelab/proxy/docker-compose.yml`
- **Purpose**: Caddy reverse proxy and Cloudflare tunnel
- **Network**: References external `homelab-web` network

#### 3. Monitoring Stack
- **File**: `/home/chris/github/hephaestus-homelab/grafana-stack/docker-compose.yml`
- **Purpose**: Grafana, Prometheus, monitoring tools
- **Network**: References external `homelab-web` network

### Application Files (Network Users)

These files **consume** the `homelab-web` network:

#### Standard Pattern for Apps
```yaml
networks:
  web:
    external: true
    name: homelab-web
```

#### App Files Using This Pattern:
- `/home/chris/apps/*/docker-compose-homelab.yml` (all homelab-integrated apps)
- `/home/chris/apps/daedalOS/docker-compose-homelab.yml`
- `/home/chris/apps/CapitolScope/docker-compose.yml`
- `/home/chris/apps/n8n/docker-compose.yml`
- And 15+ other application compose files

## Service Communication

### Port Mapping Strategy

| Service Category | Port Range | Purpose |
|-----------------|------------|---------|
| Infrastructure | 3000-3099 | Core services (Grafana, Prometheus, etc.) |
| Proxy Services | 8000-8099 | Caddy proxy endpoints |
| Applications | 8100-8199 | Custom applications |
| Development | 8200-8299 | Development/testing services |

### Key Service Ports

| Service | Port | Network Access |
|---------|------|----------------|
| Caddy Proxy | 80, 443 | External + Internal |
| Grafana | 3000 | Internal + Proxy |
| Prometheus | 9090 | Internal + Proxy |
| Portainer | 9000 | Internal + Proxy |
| Uptime Kuma | 3001 | Internal + Proxy |
| daedalOS | 8158 | Internal + Proxy |
| CapitolScope API | 8120 | Internal + Proxy |
| CapitolScope Frontend | 8121 | Internal + Proxy |
| MagicPages API | 8100 | Internal + Proxy |
| n8n | 5678 | Internal + Proxy |
| Obsidian | 8060 | Internal + Proxy |
| Minecraft | 25565 | External + Internal |

## Internal Service Networks

Many services use additional internal networks for component isolation:

### CapitolScope
```yaml
networks:
  web:                    # External access
    external: true
    name: homelab-web
  capitolscope-internal:  # Internal components
    driver: bridge
```

### MagicPages
```yaml
networks:
  web:                    # External access
    external: true
    name: homelab-web
  magicpages-internal:    # Internal components
    driver: bridge
```

### Minecraft
```yaml
networks:
  web:                    # External access
    external: true
    name: homelab-web
  minecraft-internal:     # Internal components
    driver: bridge
```

## Network Security

### Access Patterns

1. **External Access**: Services exposed through Caddy proxy (HTTPS)
2. **Internal Access**: Direct container-to-container communication
3. **Development Access**: Local port mapping for development

### Security Considerations

- **No Direct External Access**: Most services only accessible through Caddy proxy
- **Internal Communication**: Services can communicate freely within the network
- **Isolation**: Database and cache services use internal networks
- **TLS Termination**: All external traffic encrypted via Caddy

## Adding New Services

### For New Applications

1. **Create docker-compose file** in `/home/chris/apps/your-app/`
2. **Use standard network pattern**:
   ```yaml
   networks:
     web:
       external: true
       name: homelab-web
   ```
3. **Add service to network**:
   ```yaml
   services:
     your-service:
       networks:
         - web
   ```
4. **Configure Caddy proxy** in `/home/chris/github/hephaestus-homelab/proxy/Caddyfile`

### For Infrastructure Services

1. **Add to main infrastructure file** or create separate stack
2. **Use homelab-web network directly**:
   ```yaml
   networks:
     homelab-web:
       driver: bridge
   ```

## Network Troubleshooting

### Common Issues

1. **Services can't communicate**: Check network name consistency
2. **Port conflicts**: Verify port mapping in service definitions
3. **External access issues**: Check Caddy proxy configuration

### Debugging Commands

```bash
# List all networks
docker network ls

# Inspect homelab-web network
docker network inspect homelab-web

# Check service connectivity
docker exec -it <container> ping <other-container>

# View network traffic
docker network logs homelab-web
```

### Network Health Check

```bash
# Verify all services can reach each other
docker exec -it caddy ping grafana
docker exec -it grafana ping prometheus
docker exec -it capitolscope ping magicpages-api
```

## Deployment Order

1. **Infrastructure Stack**: `docker compose -f docker-compose-infrastructure.yml up -d`
2. **Proxy Stack**: `docker compose -f proxy/docker-compose.yml up -d`
3. **Monitoring Stack**: `docker compose -f grafana-stack/docker-compose.yml up -d`
4. **Applications**: Individual app stacks as needed

## Network Monitoring

### Key Metrics

- **Network Traffic**: Monitor via Prometheus + Grafana
- **Service Health**: Uptime Kuma monitoring
- **Container Communication**: Docker network logs

### Alerting

- **Network Partition**: Alert if services can't communicate
- **High Latency**: Monitor inter-service communication times
- **Port Conflicts**: Detect port mapping issues

## Best Practices

1. **Consistent Naming**: Always use `web` for external network, `homelab-web` for internal
2. **Port Management**: Document all port assignments
3. **Security**: Use internal networks for sensitive components
4. **Monitoring**: Include network health in service monitoring
5. **Documentation**: Update this file when adding new services

## Related Documentation

- [Service Architecture](./services.md) - Overall service design
- [Deployment Guide](./deployment.md) - How to deploy services
- [Security Guide](./security.md) - Network security practices
- [Monitoring Guide](./monitoring.md) - Network monitoring setup

---

**Last Updated**: $(date)
**Network Version**: 1.0
**Compatible With**: Docker Compose v2.0+, Docker Engine 27.x
