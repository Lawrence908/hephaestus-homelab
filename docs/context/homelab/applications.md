# Hephaestus Homelab - Application Services

## Overview

This document outlines the application services running in the Hephaestus Homelab, including custom applications, APIs, and specialized services.

## Application Categories

### Web Applications
Public-facing web applications and services:

#### Portfolio
- **Purpose**: Personal portfolio website
- **Technology**: Flask/Python
- **Port**: 8110
- **Public URL**: `https://chrislawrence.ca/portfolio`
- **Status**: Active

#### CapitolScope
- **Purpose**: Political data analysis platform
- **Technology**: React/Node.js
- **Ports**: 8120 (API), 8121 (Frontend)
- **Public URLs**: 
  - `https://chrislawrence.ca/capitolscope` (Frontend)
  - `https://chrislawrence.ca/capitolscope-api` (API)
- **Status**: Active

#### SchedShare
- **Purpose**: Schedule sharing application
- **Technology**: React/Node.js
- **Port**: 8130
- **Public URL**: `https://chrislawrence.ca/schedshare`
- **Status**: Active

#### MagicPages
- **Purpose**: Content management system
- **Technology**: Django/Python
- **Ports**: 8100 (API), 8101 (Frontend)
- **Public URLs**:
  - `https://chrislawrence.ca/magicpages` (Frontend)
  - `https://chrislawrence.ca/magicpages-api` (API)
- **Status**: Active

### Automation & Workflow Services
Services for automation and workflow management:

#### n8n
- **Purpose**: Workflow automation platform
- **Technology**: Node.js
- **Port**: 5678
- **Public URL**: `https://chrislawrence.ca/n8n`
- **Status**: Active

#### Node-RED
- **Purpose**: IoT and automation flows
- **Technology**: Node.js
- **Port**: 1880
- **Public URL**: `https://chrislawrence.ca/nodered`
- **Status**: Active

### Knowledge Management
Services for knowledge management and documentation:

#### Obsidian
- **Purpose**: Note-taking and knowledge management
- **Technology**: Web-based
- **Port**: 8060
- **Public URL**: `https://chrislawrence.ca/notes`
- **Status**: Active

### IoT & Specialized Services
Services for IoT, gaming, and specialized functionality:

#### Minecraft Server
- **Purpose**: Game server with Dynmap
- **Technology**: Java
- **Port**: 25565
- **Public URL**: `https://chrislawrence.ca/minecraft-map`
- **Status**: Active

#### MQTT Explorer
- **Purpose**: IoT device management
- **Technology**: Web-based
- **Port**: 4000
- **Public URL**: `https://chrislawrence.ca/mqtt`
- **Status**: Active

#### Meshtastic Web
- **Purpose**: Mesh networking interface
- **Technology**: Web-based
- **Port**: 8080
- **Public URL**: `https://chrislawrence.ca/meshtastic`
- **Status**: Active

#### Grafana IoT
- **Purpose**: IoT-specific monitoring
- **Technology**: Grafana
- **Port**: 3002
- **Public URL**: `https://chrislawrence.ca/grafana-iot`
- **Status**: Active

#### InfluxDB
- **Purpose**: Time-series database
- **Technology**: InfluxDB
- **Port**: 8086
- **Public URL**: `https://chrislawrence.ca/influxdb`
- **Status**: Active

## Application Architecture

### Standard Application Pattern
```yaml
networks:
  web:
    external: true
    name: homelab-web

services:
  app-api:
    image: app-api:latest
    container_name: app-api
    restart: unless-stopped
    networks:
      - web
    ports:
      - "81XX:8080"
    volumes:
      - app_data:/data
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/app
      - REDIS_URL=redis://redis:6379

  app-frontend:
    image: app-frontend:latest
    container_name: app-frontend
    restart: unless-stopped
    networks:
      - web
    ports:
      - "81XX:3000"
    volumes:
      - app_static:/app/static
    environment:
      - API_URL=http://app-api:8080
```

### Database Services
Many applications use dedicated database services:

#### PostgreSQL
- **Purpose**: Primary database for applications
- **Port**: 5432
- **Access**: Internal only
- **Applications**: MagicPages, CapitolScope

#### Redis
- **Purpose**: Caching and session storage
- **Port**: 6379
- **Access**: Internal only
- **Applications**: All web applications

#### InfluxDB
- **Purpose**: Time-series data storage
- **Port**: 8086
- **Access**: Internal only
- **Applications**: IoT monitoring, metrics

## Application Deployment

### Deployment Process
1. **Create Application Directory**: `/home/chris/apps/your-app/`
2. **Create Docker Compose File**: `docker-compose-homelab.yml`
3. **Configure Network**: Use `homelab-web` network
4. **Set Ports**: Use 81XX port range
5. **Configure Caddy**: Add routing rules
6. **Deploy**: `docker compose -f docker-compose-homelab.yml up -d`

### Example Application Structure
```
/home/chris/apps/your-app/
├── docker-compose-homelab.yml
├── Dockerfile
├── .env
├── src/
├── static/
└── README.md
```

### Caddy Configuration
```caddy
# Application routing
chrislawrence.ca/your-app {
    reverse_proxy app-frontend:3000
    basicauth {
        admin $2a$10$hashed_password
    }
}

# API routing
chrislawrence.ca/your-app-api {
    reverse_proxy app-api:8080
    basicauth {
        admin $2a$10$hashed_password
    }
}
```

## Application Management

### Starting Applications
```bash
# Navigate to application directory
cd ~/apps/your-app

# Start application
docker compose -f docker-compose-homelab.yml up -d

# Check status
docker compose -f docker-compose-homelab.yml ps
```

### Stopping Applications
```bash
# Stop application
docker compose -f docker-compose-homelab.yml down

# Stop with volumes (WARNING: Data loss)
docker compose -f docker-compose-homelab.yml down -v
```

### Updating Applications
```bash
# Update application
docker compose -f docker-compose-homelab.yml pull
docker compose -f docker-compose-homelab.yml up -d
```

### Application Logs
```bash
# View application logs
docker compose -f docker-compose-homelab.yml logs app-service

# Follow logs in real-time
docker compose -f docker-compose-homelab.yml logs -f app-service
```

## Application Monitoring

### Health Checks
```bash
# Check application health
curl http://localhost:81XX/health

# Check application metrics
curl http://localhost:81XX/metrics
```

### Application Metrics
- **Response Time**: Monitor via Prometheus
- **Error Rate**: Monitor via Prometheus
- **Resource Usage**: Monitor via cAdvisor
- **Availability**: Monitor via Uptime Kuma

### Application Alerts
- **Service Down**: Alert when application is unavailable
- **High Error Rate**: Alert when error rate exceeds threshold
- **Resource Usage**: Alert when resource usage is high
- **Response Time**: Alert when response time is slow

## Application Security

### Authentication
- **Cloudflare Access**: Primary authentication for admin applications
- **Caddy Basic Auth**: Secondary authentication layer
- **Application Auth**: Individual application authentication

### Data Protection
- **Database Encryption**: Encrypt sensitive data at rest
- **Network Encryption**: TLS termination at Caddy
- **Backup Encryption**: Encrypt backup data

### Access Control
- **Public Applications**: No authentication required
- **Admin Applications**: Cloudflare Access required
- **API Applications**: Basic authentication required

## Application Development

### Development Environment
```bash
# Start development environment
docker compose -f docker-compose-dev.yml up -d

# Run tests
docker compose -f docker-compose-dev.yml exec app npm test

# Install dependencies
docker compose -f docker-compose-dev.yml exec app npm install
```

### Database Migrations
```bash
# Run database migrations
docker compose -f docker-compose-homelab.yml exec app-api python manage.py migrate

# Create database backup
docker compose -f docker-compose-homelab.yml exec db pg_dump -U user app > backup.sql
```

### Application Updates
```bash
# Update application code
git pull origin main

# Rebuild application
docker compose -f docker-compose-homelab.yml build app-service

# Restart application
docker compose -f docker-compose-homelab.yml restart app-service
```

## Application Troubleshooting

### Common Issues

#### Application Not Starting
```bash
# Check application logs
docker compose -f docker-compose-homelab.yml logs app-service

# Check application status
docker compose -f docker-compose-homelab.yml ps app-service

# Check application configuration
docker compose -f docker-compose-homelab.yml config
```

#### Database Connection Issues
```bash
# Check database status
docker compose -f docker-compose-homelab.yml ps db

# Test database connection
docker compose -f docker-compose-homelab.yml exec app-service ping db

# Check database logs
docker compose -f docker-compose-homelab.yml logs db
```

#### Performance Issues
```bash
# Check resource usage
docker stats app-service

# Check application metrics
curl http://localhost:81XX/metrics

# Check database performance
docker compose -f docker-compose-homelab.yml exec db psql -U user -d app -c "SELECT * FROM pg_stat_activity;"
```

## Related Documentation

- [Infrastructure Services](../infra/services.md) - Core infrastructure services
- [Network Architecture](../infra/networks.md) - Docker network setup
- [Security Configuration](../infra/security.md) - Authentication and access control
- [Deployment Guide](../infra/deployment.md) - Service deployment procedures

---

**Last Updated**: $(date)
**Application Version**: 1.0
**Compatible With**: Docker Compose v2.0+, Docker Engine 27.x
