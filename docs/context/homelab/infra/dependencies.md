# Hephaestus Homelab - Service Dependencies & Dependencies

## Overview

This document outlines the service dependency relationships, startup order, and failure impact analysis for the Hephaestus Homelab infrastructure. It ensures proper service orchestration and helps identify potential failure points.

## 🔗 **Service Dependency Tree**

### **Critical Path Dependencies**

```
Internet
    ↓
Cloudflare Tunnel (cloudflared)
    ↓
Caddy (Reverse Proxy)
    ↓
┌─────────────────┬─────────────────┬─────────────────┐
│   Applications   │   Monitoring    │   Management    │
│                 │                 │                 │
│ Portfolio       │ Uptime Kuma     │ Portainer       │
│ CapitolScope    │ Grafana         │ Watchtower      │
│ SchedShare      │ Prometheus      │                 │
│ MagicPages      │ cAdvisor        │                 │
│ n8n             │ Glances         │                 │
└─────────────────┴─────────────────┴─────────────────┘
    ↓
┌─────────────────┬─────────────────┐
│   Databases     │   Storage       │
│                 │                 │
│ PostgreSQL      │ Docker Volumes  │
│ Redis           │ Application     │
│ InfluxDB        │ Data            │
└─────────────────┴─────────────────┘
```

### **Network Dependencies**

```
Docker Network: homelab-web
    ↓
┌─────────────────────────────────────────────────────────┐
│                    All Services                        │
│                                                         │
│ Caddy ←→ Portfolio ←→ PostgreSQL                       │
│ Caddy ←→ CapitolScope ←→ PostgreSQL                    │
│ Caddy ←→ SchedShare ←→ Redis                           │
│ Caddy ←→ MagicPages ←→ PostgreSQL                      │
│ Caddy ←→ n8n ←→ PostgreSQL                            │
│                                                         │
│ Caddy ←→ Portainer ←→ Docker Socket                    │
│ Caddy ←→ Uptime Kuma ←→ All Services                   │
│ Caddy ←→ Grafana ←→ Prometheus                         │
│ Caddy ←→ Prometheus ←→ cAdvisor                         │
│ Caddy ←→ cAdvisor ←→ All Containers                    │
└─────────────────────────────────────────────────────────┘
```

## 📊 **Service Dependency Matrix**

### **Infrastructure Services**

| Service | Depends On | Required For | Startup Order |
|---------|------------|--------------|---------------|
| **homelab-web** | Docker | All services | 1 |
| **Caddy** | homelab-web | All web services | 2 |
| **Cloudflare Tunnel** | Caddy | Public access | 3 |
| **Portainer** | homelab-web | Container management | 4 |
| **Watchtower** | homelab-web | Auto-updates | 5 |

### **Database Services**

| Service | Depends On | Required For | Startup Order |
|---------|------------|--------------|---------------|
| **PostgreSQL** | homelab-web | MagicPages, CapitolScope | 6 |
| **Redis** | homelab-web | SchedShare, caching | 7 |
| **InfluxDB** | homelab-web | IoT monitoring | 8 |

### **Monitoring Services**

| Service | Depends On | Required For | Startup Order |
|---------|------------|--------------|---------------|
| **Prometheus** | homelab-web | Metrics collection | 9 |
| **Grafana** | Prometheus | Metrics visualization | 10 |
| **Uptime Kuma** | homelab-web | Service monitoring | 11 |
| **cAdvisor** | homelab-web | Container metrics | 12 |
| **Node Exporter** | homelab-web | Host metrics | 13 |
| **Glances** | homelab-web | System monitoring | 14 |

### **Application Services**

| Service | Depends On | Required For | Startup Order |
|---------|------------|--------------|---------------|
| **Portfolio** | Caddy | Public access | 15 |
| **CapitolScope** | Caddy, PostgreSQL | Public access | 16 |
| **SchedShare** | Caddy, Redis | Public access | 17 |
| **MagicPages** | Caddy, PostgreSQL | Public access | 18 |
| **n8n** | Caddy, PostgreSQL | Automation | 19 |

## 🚀 **Startup Order Procedures**

### **Phase 1: Infrastructure (Order 1-5)**
```bash
# 1. Create Docker network
docker network create homelab-web

# 2. Start Caddy (reverse proxy)
docker compose -f docker-compose-infrastructure.yml up -d caddy

# 3. Start Cloudflare Tunnel
docker compose -f docker-compose-infrastructure.yml up -d cloudflared

# 4. Start Portainer (container management)
docker compose -f docker-compose-infrastructure.yml up -d portainer

# 5. Start Watchtower (auto-updates)
docker compose -f docker-compose-infrastructure.yml up -d watchtower
```

### **Phase 2: Databases (Order 6-8)**
```bash
# 6. Start PostgreSQL
docker compose -f docker-compose-infrastructure.yml up -d postgres

# 7. Start Redis
docker compose -f docker-compose-infrastructure.yml up -d redis

# 8. Start InfluxDB (if needed)
docker compose -f docker-compose-infrastructure.yml up -d influxdb
```

### **Phase 3: Monitoring (Order 9-14)**
```bash
# 9. Start Prometheus
docker compose -f docker-compose-infrastructure.yml up -d prometheus

# 10. Start Grafana
docker compose -f docker-compose-infrastructure.yml up -d grafana

# 11. Start Uptime Kuma
docker compose -f docker-compose-infrastructure.yml up -d uptime-kuma

# 12. Start cAdvisor
docker compose -f docker-compose-infrastructure.yml up -d cadvisor

# 13. Start Node Exporter
docker compose -f docker-compose-infrastructure.yml up -d node-exporter

# 14. Start Glances
docker compose -f docker-compose-infrastructure.yml up -d glances
```

### **Phase 4: Applications (Order 15-19)**
```bash
# 15. Start Portfolio
cd /home/chris/apps/portfolio
docker compose -f docker-compose-homelab.yml up -d

# 16. Start CapitolScope
cd /home/chris/apps/capitolscope
docker compose -f docker-compose-homelab.yml up -d

# 17. Start SchedShare
cd /home/chris/apps/schedshare
docker compose -f docker-compose-homelab.yml up -d

# 18. Start MagicPages
cd /home/chris/apps/magic-pages-api
docker compose -f docker-compose-homelab.yml up -d

# 19. Start n8n
cd /home/chris/apps/n8n
docker compose -f docker-compose-homelab.yml up -d
```

## 🔍 **Dependency Health Checks**

### **Network Health Check**
```bash
# Check Docker network
docker network inspect homelab-web

# Test network connectivity
docker exec -it caddy ping -c 1 postgres
docker exec -it caddy ping -c 1 redis
docker exec -it caddy ping -c 1 portfolio
```

### **Service Health Check**
```bash
# Check service dependencies
docker compose -f docker-compose-infrastructure.yml ps

# Test service connectivity
curl -I http://localhost:80  # Caddy
curl -I http://localhost:9000  # Portainer
curl -I http://localhost:3001  # Uptime Kuma
curl -I http://localhost:3000  # Grafana
```

### **Database Health Check**
```bash
# Test PostgreSQL connection
docker compose -f docker-compose-infrastructure.yml exec postgres psql -U user -d database -c "SELECT 1;"

# Test Redis connection
docker compose -f docker-compose-infrastructure.yml exec redis redis-cli ping

# Test InfluxDB connection
docker compose -f docker-compose-infrastructure.yml exec influxdb influx ping
```

## 🚨 **Failure Impact Analysis**

### **Critical Service Failures**

#### **Caddy Failure**
- **Impact**: All web services unavailable
- **Affected Services**: All applications, monitoring, management
- **Recovery Time**: 2-5 minutes
- **Recovery Procedure**:
  ```bash
  docker compose -f docker-compose-infrastructure.yml restart caddy
  docker compose -f docker-compose-infrastructure.yml logs caddy
  ```

#### **Cloudflare Tunnel Failure**
- **Impact**: Public access unavailable
- **Affected Services**: All public-facing services
- **Recovery Time**: 5-10 minutes
- **Recovery Procedure**:
  ```bash
  sudo systemctl restart cloudflared
  sudo journalctl -u cloudflared -f
  ```

#### **PostgreSQL Failure**
- **Impact**: Database-dependent applications down
- **Affected Services**: MagicPages, CapitolScope, n8n
- **Recovery Time**: 5-15 minutes
- **Recovery Procedure**:
  ```bash
  docker compose -f docker-compose-infrastructure.yml restart postgres
  docker compose -f docker-compose-infrastructure.yml logs postgres
  ```

### **Non-Critical Service Failures**

#### **Monitoring Service Failure**
- **Impact**: Monitoring and alerting unavailable
- **Affected Services**: Grafana, Prometheus, Uptime Kuma
- **Recovery Time**: 2-5 minutes
- **Recovery Procedure**:
  ```bash
  docker compose -f docker-compose-infrastructure.yml restart [service]
  ```

#### **Application Service Failure**
- **Impact**: Specific application unavailable
- **Affected Services**: Individual applications
- **Recovery Time**: 2-5 minutes
- **Recovery Procedure**:
  ```bash
  cd /home/chris/apps/[application]
  docker compose -f docker-compose-homelab.yml restart
  ```

## 🔄 **Dependency Recovery Procedures**

### **Cascade Failure Recovery**

#### **Network Failure**
```bash
# Recreate Docker network
docker network rm homelab-web
docker network create homelab-web

# Restart all services
docker compose -f docker-compose-infrastructure.yml down
docker compose -f docker-compose-infrastructure.yml up -d
```

#### **Database Failure**
```bash
# Restart database services
docker compose -f docker-compose-infrastructure.yml restart postgres redis

# Wait for databases to be ready
sleep 30

# Restart dependent services
docker compose -f docker-compose-infrastructure.yml restart caddy
```

#### **Application Failure**
```bash
# Restart application services
cd /home/chris/apps/[application]
docker compose -f docker-compose-homelab.yml restart

# Check application health
curl -I http://localhost:[port]
```

### **Dependency Verification**

#### **Service Dependency Check**
```bash
# Check if all dependencies are running
docker compose -f docker-compose-infrastructure.yml ps | grep -E "(Up|healthy)"

# Check service connectivity
docker exec -it caddy sh -lc 'curl -I http://portfolio:5000/'
docker exec -it caddy sh -lc 'curl -I http://magic-pages-api:8000/'
```

#### **Database Dependency Check**
```bash
# Check database connections
docker compose -f docker-compose-infrastructure.yml exec postgres psql -U user -d database -c "SELECT count(*) FROM pg_stat_activity;"

# Check Redis connections
docker compose -f docker-compose-infrastructure.yml exec redis redis-cli info clients
```

## 📊 **Dependency Monitoring**

### **Service Dependency Monitoring**

#### **Uptime Kuma Monitors**
Configure monitors for:
- **Caddy**: `http://localhost:80`
- **PostgreSQL**: `tcp://localhost:5432`
- **Redis**: `tcp://localhost:6379`
- **Portainer**: `http://localhost:9000`
- **Grafana**: `http://localhost:3000`

#### **Prometheus Alerts**
Configure alerts for:
- **Service down**: `up{job="docker"} == 0`
- **Database connection**: `pg_up == 0`
- **Redis connection**: `redis_up == 0`
- **High dependency load**: `rate(container_cpu_usage_seconds_total[5m]) > 0.8`

### **Dependency Health Dashboard**

#### **Grafana Dashboard**
Create dashboard with:
- **Service Status**: All services up/down status
- **Dependency Tree**: Visual dependency mapping
- **Response Times**: Inter-service communication times
- **Error Rates**: Service failure rates

## 🔧 **Dependency Optimization**

### **Service Startup Optimization**

#### **Parallel Startup**
```bash
# Start services in parallel where possible
docker compose -f docker-compose-infrastructure.yml up -d postgres redis
docker compose -f docker-compose-infrastructure.yml up -d prometheus grafana
docker compose -f docker-compose-infrastructure.yml up -d caddy cloudflared
```

#### **Health Check Dependencies**
```bash
# Add health checks to docker-compose.yml
services:
  postgres:
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "user"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
```

### **Dependency Caching**

#### **Redis Caching**
```bash
# Configure Redis for dependency caching
docker compose -f docker-compose-infrastructure.yml exec redis redis-cli config set maxmemory 256mb
docker compose -f docker-compose-infrastructure.yml exec redis redis-cli config set maxmemory-policy allkeys-lru
```

#### **Application Caching**
```bash
# Configure application caching
# In Django settings.py
CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': 'redis://redis:6379/1',
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
        }
    }
}
```

## 📋 **Dependency Checklist**

### **Pre-Deployment Checklist**
- [ ] Verify all dependencies are available
- [ ] Check network connectivity
- [ ] Verify database connections
- [ ] Test service health checks
- [ ] Verify configuration files

### **Post-Deployment Checklist**
- [ ] Verify all services are running
- [ ] Test service connectivity
- [ ] Check dependency health
- [ ] Verify monitoring is working
- [ ] Test public access

### **Maintenance Checklist**
- [ ] Review dependency relationships
- [ ] Update dependency documentation
- [ ] Test dependency recovery procedures
- [ ] Verify monitoring alerts
- [ ] Update startup procedures

## Related Documentation

- [Incident Response](./incident-response.md) - Troubleshooting procedures
- [Backup & Recovery](./backup-recovery.md) - Data protection procedures
- [Maintenance Procedures](./maintenance.md) - Regular maintenance tasks
- [Performance Monitoring](./performance.md) - System optimization
- [Deployment Guide](./deployment.md) - Service deployment procedures

---

**Last Updated**: $(date)
**Dependencies Version**: 1.0
**Compatible With**: Docker Compose v2.0+, Docker Engine 27.x
