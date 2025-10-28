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
- **File**: `/home/chris/github/hephaestus-infra/docker-compose-infrastructure.yml`
- **Purpose**: Core infrastructure services (Caddy, Portainer, Uptime Kuma, etc.)
- **Network**: Creates `homelab-web` network

#### 2. Proxy Stack
- **File**: `/home/chris/github/hephaestus-infra/proxy/docker-compose.yml`
- **Purpose**: Caddy reverse proxy and Cloudflare tunnel
- **Network**: References external `homelab-web` network

#### 3. Monitoring Stack
- **File**: `/home/chris/github/hephaestus-infra/grafana-stack/docker-compose.yml`
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

| Service | Port | Network Access | Public URL | Access Type |
|---------|------|----------------|------------|-------------|
| Caddy Proxy | 80, 443 | External + Internal | `https://chrislawrence.ca` | Public |
| Landing Page | 80 | Internal | `https://chrislawrence.ca` | Public |
| Portfolio | 5000 | Internal | `https://portfolio.chrislawrence.ca` | Public |
| SchedShare | 5000 | Internal | `https://schedshare.chrislawrence.ca` | Public |
| CapitolScope Frontend | 5173 | Internal | `https://capitolscope.chrislawrence.ca` | Public |
| CapitolScope Backend | 8000 | Internal | `https://capitolscope.chrislawrence.ca` | Public |
| MagicPages API | 8000 | Internal | `https://magicpages.chrislawrence.ca` | Public |
| EventSphere | 5000 | Internal | `https://eventsphere.chrislawrence.ca` | Public |
| Dev Environment | Various | Internal | `https://dev.chrislawrence.ca` | Protected (Cloudflare Access) |
| Monitor | Various | Internal | `https://monitor.chrislawrence.ca` | Protected (Cloudflare Access) |
| IoT Services | Various | Internal | `https://iot.chrislawrence.ca` | Protected (Cloudflare Access) |
| Minecraft | 25565 | External + Internal | `https://minecraft.chrislawrence.ca` | Protected (Cloudflare Access) |
| AI Services | Various | Internal | `https://ai.chrislawrence.ca` | Protected (Cloudflare Access) |

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

1. **Public Access**: Services exposed through Cloudflare Tunnel with subdomain routing
2. **Protected Access**: Services requiring Cloudflare Access authentication
3. **Internal Access**: Direct container-to-container communication
4. **Development Access**: Local port mapping for development

### Security Considerations

- **No Direct External Access**: Most services only accessible through Cloudflare Tunnel
- **Internal Communication**: Services can communicate freely within the network
- **Isolation**: Database and cache services use internal networks
- **TLS Termination**: All external traffic encrypted via Cloudflare Tunnel
- **Access Control**: Protected services require Cloudflare Access authentication

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
4. **Configure Caddy proxy** in `/home/chris/github/hephaestus-infra/proxy/Caddyfile`

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
docker exec -it caddy ping portfolio
docker exec -it caddy ping schedshare
docker exec -it caddy ping capitolscope-frontend
docker exec -it caddy ping magicpages-api
docker exec -it caddy ping mongo-events

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
