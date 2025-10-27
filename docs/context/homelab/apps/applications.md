# Hephaestus Homelab - Application Services

## Overview

This document outlines the application services running in the Hephaestus Homelab, including custom applications, APIs, and specialized services.

## Application Categories

### Public Web Applications
Public-facing web applications accessible without authentication:

#### Portfolio
- **Purpose**: Personal portfolio website
- **Technology**: Flask/Python
- **Port**: 5000
- **Public URL**: `https://portfolio.chrislawrence.ca`
- **Status**: ✅ Active

#### SchedShare
- **Purpose**: Schedule sharing application
- **Technology**: Flask/Python
- **Port**: 5000
- **Public URL**: `https://schedshare.chrislawrence.ca`
- **Status**: ✅ Active

#### CapitolScope
- **Purpose**: Political data analysis platform
- **Technology**: React/Node.js (Frontend), Python (Backend)
- **Ports**: 8000 (Backend), 5173 (Frontend)
- **Public URL**: `https://capitolscope.chrislawrence.ca`
- **Status**: ✅ Active

#### MagicPages
- **Purpose**: Content management system
- **Technology**: Django/Python
- **Port**: 8000
- **Public URLs**:
  - `https://magicpages.chrislawrence.ca` (Main interface)
  - `https://api.magicpages.chrislawrence.ca` (API endpoint)
- **Status**: ✅ Active

#### EventSphere
- **Purpose**: Event management system
- **Technology**: Python/Flask
- **Port**: 5000
- **Public URL**: `https://eventsphere.chrislawrence.ca`
- **Status**: ✅ Active

### Protected Services
Services requiring Cloudflare Access authentication:

#### Development Environment
- **Purpose**: Development tools and environments
- **Public URL**: `https://dev.chrislawrence.ca`
- **Access Policy**: Admin/Public/Friends
- **Status**: ✅ Active

#### Monitoring Dashboard
- **Purpose**: System monitoring and metrics
- **Public URL**: `https://monitor.chrislawrence.ca`
- **Access Policy**: Admin/Public/Friends
- **Status**: ✅ Active

#### IoT Services
- **Purpose**: IoT device management and monitoring
- **Public URL**: `https://iot.chrislawrence.ca`
- **Access Policy**: Admin/Public/Friends
- **Status**: ✅ Active

#### Minecraft Server
- **Purpose**: Game server with management interface
- **Public URL**: `https://minecraft.chrislawrence.ca`
- **Access Policy**: Admin/Public/Friends
- **Status**: ✅ Active

#### AI Services
- **Purpose**: AI inference and model management
- **Public URL**: `https://ai.chrislawrence.ca`
- **Access Policy**: Admin/Public/Friends
- **Status**: ✅ Active

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
# Public applications (no authentication)
portfolio.chrislawrence.ca:80 {
    reverse_proxy portfolio:5000 {
        header_up Host {host}
        header_up X-Forwarded-Proto {scheme}
        header_up X-Forwarded-For {remote}
        header_up X-Real-IP {remote}
    }
}

schedshare.chrislawrence.ca:80 {
    reverse_proxy schedshare:5000 {
        header_up Host {host}
        header_up X-Forwarded-Proto {scheme}
        header_up X-Forwarded-For {remote}
        header_up X-Real-IP {remote}
    }
}

capitolscope.chrislawrence.ca:80 {
    reverse_proxy capitolscope-frontend:5173 {
        header_up Host {host}
        header_up X-Forwarded-Proto {scheme}
        header_up X-Forwarded-For {remote}
        header_up X-Real-IP {remote}
    }
}

magicpages.chrislawrence.ca:80 {
    reverse_proxy magicpages-api:8000 {
        header_up Host localhost
        header_up X-Forwarded-Proto {scheme}
        header_up X-Forwarded-For {remote}
        header_up X-Real-IP {remote}
    }
}

api.magicpages.chrislawrence.ca:80 {
    reverse_proxy magicpages-api:8000 {
        header_up Host localhost
        header_up X-Forwarded-Proto {scheme}
        header_up X-Forwarded-For {remote}
        header_up X-Real-IP {remote}
    }
}

eventsphere.chrislawrence.ca:80 {
    reverse_proxy mongo-events:5000 {
        header_up Host {host}
        header_up X-Forwarded-Proto {scheme}
        header_up X-Forwarded-For {remote}
        header_up X-Real-IP {remote}
    }
}

# Protected applications (Cloudflare Access handles authentication)
dev.chrislawrence.ca:80 {
    reverse_proxy dev-services:8080
}

monitor.chrislawrence.ca:80 {
    reverse_proxy monitoring-stack:3000
}

iot.chrislawrence.ca:80 {
    reverse_proxy iot-services:8080
}

minecraft.chrislawrence.ca:80 {
    reverse_proxy minecraft-server:8080
}

ai.chrislawrence.ca:80 {
    reverse_proxy ai-services:8080
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
# Test public applications
curl -I https://chrislawrence.ca
curl -I https://portfolio.chrislawrence.ca
curl -I https://schedshare.chrislawrence.ca
curl -I https://capitolscope.chrislawrence.ca
curl -I https://magicpages.chrislawrence.ca
curl -I https://api.magicpages.chrislawrence.ca
curl -I https://eventsphere.chrislawrence.ca

# Test protected applications (should redirect to Cloudflare Access)
curl -I https://dev.chrislawrence.ca
curl -I https://monitor.chrislawrence.ca
curl -I https://iot.chrislawrence.ca
curl -I https://minecraft.chrislawrence.ca
curl -I https://ai.chrislawrence.ca
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



