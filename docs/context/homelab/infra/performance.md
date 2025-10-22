# Hephaestus Homelab - Performance Monitoring & Optimization

## Overview

This document outlines performance monitoring, optimization procedures, and capacity planning for the Hephaestus Homelab infrastructure. It ensures optimal system performance and helps identify bottlenecks.

## 📊 **Performance Baselines**

### **System Resource Baselines**

#### **CPU Usage**
- **Normal**: 10-30% average
- **Peak**: 50-70% during updates
- **Alert**: >80% sustained for 5+ minutes

#### **Memory Usage**
- **Normal**: 4-8GB (50-60% of 16GB)
- **Peak**: 10-12GB during heavy operations
- **Alert**: >90% sustained for 5+ minutes

#### **Disk Usage**
- **Normal**: 60-80% of available space
- **Peak**: 85% during backups
- **Alert**: >90% sustained

#### **Network Usage**
- **Normal**: 1-10 Mbps
- **Peak**: 50-100 Mbps during updates
- **Alert**: >200 Mbps sustained

### **Service Performance Baselines**

#### **Response Times**
- **Caddy**: <100ms
- **Portfolio**: <200ms
- **CapitolScope**: <300ms
- **MagicPages**: <400ms
- **Grafana**: <500ms

#### **Database Performance**
- **PostgreSQL**: <50ms query time
- **Redis**: <10ms response time
- **Connection Pool**: 10-20 connections

## 🔍 **Performance Monitoring**

### **System Monitoring**

#### **CPU Monitoring**
```bash
# Real-time CPU usage
htop
top

# CPU usage over time
vmstat 1 10

# CPU usage by process
ps aux --sort=-%cpu | head -10
```

#### **Memory Monitoring**
```bash
# Memory usage
free -h
cat /proc/meminfo

# Memory usage by process
ps aux --sort=-%mem | head -10

# Memory usage by container
docker stats --no-stream
```

#### **Disk Monitoring**
```bash
# Disk usage
df -h
du -sh /var/lib/docker/volumes/*

# Disk I/O
iotop
iostat -x 1 5

# Disk performance
dd if=/dev/zero of=/tmp/test bs=1M count=1000
```

#### **Network Monitoring**
```bash
# Network usage
iftop
nethogs

# Network statistics
cat /proc/net/dev

# Network connections
netstat -tlnp
ss -tlnp
```

### **Docker Performance Monitoring**

#### **Container Resource Usage**
```bash
# Real-time container stats
docker stats

# Container resource usage
docker stats --no-stream

# Container resource limits
docker inspect [container_name] | grep -E "(Memory|Cpu)"
```

#### **Docker System Usage**
```bash
# Docker system usage
docker system df

# Docker system events
docker system events --since 1h

# Docker system prune
docker system prune -f
```

### **Application Performance Monitoring**

#### **Web Application Performance**
```bash
# Response time testing
curl -w "@curl-format.txt" -o /dev/null -s http://localhost:80
curl -w "@curl-format.txt" -o /dev/null -s http://localhost:8110
curl -w "@curl-format.txt" -o /dev/null -s http://localhost:8120
```

#### **Database Performance**
```bash
# PostgreSQL performance
docker compose -f docker-compose-infrastructure.yml exec postgres psql -U user -d database -c "SELECT * FROM pg_stat_activity;"
docker compose -f docker-compose-infrastructure.yml exec postgres psql -U user -d database -c "SELECT * FROM pg_stat_statements ORDER BY mean_time DESC LIMIT 10;"

# Redis performance
docker compose -f docker-compose-infrastructure.yml exec redis redis-cli info stats
docker compose -f docker-compose-infrastructure.yml exec redis redis-cli info memory
```

## 📈 **Performance Optimization**

### **System Optimization**

#### **CPU Optimization**
```bash
# Set CPU governor
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Check CPU frequency
cat /proc/cpuinfo | grep MHz

# Monitor CPU temperature
sensors
```

#### **Memory Optimization**
```bash
# Clear page cache
sudo sync
echo 3 | sudo tee /proc/sys/vm/drop_caches

# Check memory usage
free -h
cat /proc/meminfo

# Monitor memory leaks
valgrind --tool=memcheck [application]
```

#### **Disk Optimization**
```bash
# Optimize disk I/O
echo noop | sudo tee /sys/block/sda/queue/scheduler

# Check disk health
sudo smartctl -a /dev/sda

# Optimize filesystem
sudo tune2fs -o journal_data_writeback /dev/sda1
```

#### **Network Optimization**
```bash
# Optimize network buffers
echo 'net.core.rmem_max = 16777216' | sudo tee -a /etc/sysctl.conf
echo 'net.core.wmem_max = 16777216' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

### **Docker Optimization**

#### **Container Resource Limits**
```yaml
# docker-compose.yml
services:
  portfolio:
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 2G
        reservations:
          cpus: '1.0'
          memory: 512M
```

#### **Docker Daemon Optimization**
```json
# /etc/docker/daemon.json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
```

#### **Docker Network Optimization**
```bash
# Optimize Docker network
docker network create --driver bridge --opt com.docker.network.bridge.enable_icc=true --opt com.docker.network.bridge.enable_ip_masquerade=true homelab-web
```

### **Database Optimization**

#### **PostgreSQL Optimization**
```bash
# PostgreSQL configuration
docker compose -f docker-compose-infrastructure.yml exec postgres psql -U user -d database -c "SHOW shared_buffers;"
docker compose -f docker-compose-infrastructure.yml exec postgres psql -U user -d database -c "SHOW work_mem;"
docker compose -f docker-compose-infrastructure.yml exec postgres psql -U user -d database -c "SHOW max_connections;"
```

#### **Redis Optimization**
```bash
# Redis configuration
docker compose -f docker-compose-infrastructure.yml exec redis redis-cli config get maxmemory
docker compose -f docker-compose-infrastructure.yml exec redis redis-cli config get maxmemory-policy

# Set Redis limits
docker compose -f docker-compose-infrastructure.yml exec redis redis-cli config set maxmemory 256mb
docker compose -f docker-compose-infrastructure.yml exec redis redis-cli config set maxmemory-policy allkeys-lru
```

### **Application Optimization**

#### **Django Optimization**
```python
# settings.py
DEBUG = False
ALLOWED_HOSTS = ['localhost', '192.168.50.70']

# Database optimization
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'database',
        'USER': 'user',
        'PASSWORD': 'password',
        'HOST': 'postgres',
        'PORT': '5432',
        'OPTIONS': {
            'MAX_CONNS': 20,
            'MIN_CONNS': 5,
        }
    }
}

# Caching
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

#### **FastAPI Optimization**
```python
# main.py
from fastapi import FastAPI
from fastapi.middleware.gzip import GZipMiddleware

app = FastAPI()
app.add_middleware(GZipMiddleware, minimum_size=1000)

# Database connection pooling
from sqlalchemy import create_engine
from sqlalchemy.pool import QueuePool

engine = create_engine(
    "postgresql://user:password@postgres:5432/database",
    poolclass=QueuePool,
    pool_size=20,
    max_overflow=30
)
```

#### **Flask Optimization**
```python
# app.py
from flask import Flask
from flask_caching import Cache

app = Flask(__name__)
cache = Cache(app, config={'CACHE_TYPE': 'redis', 'CACHE_REDIS_URL': 'redis://redis:6379/2'})

# Database connection pooling
from sqlalchemy import create_engine
from sqlalchemy.pool import QueuePool

engine = create_engine(
    "postgresql://user:password@postgres:5432/database",
    poolclass=QueuePool,
    pool_size=10,
    max_overflow=20
)
```

## 📊 **Performance Metrics**

### **System Metrics**

#### **CPU Metrics**
- **Usage**: `node_cpu_seconds_total`
- **Load**: `node_load1`, `node_load5`, `node_load15`
- **Temperature**: `node_hwmon_temp_celsius`

#### **Memory Metrics**
- **Usage**: `node_memory_MemTotal_bytes`, `node_memory_MemAvailable_bytes`
- **Swap**: `node_memory_SwapTotal_bytes`, `node_memory_SwapFree_bytes`

#### **Disk Metrics**
- **Usage**: `node_filesystem_size_bytes`, `node_filesystem_free_bytes`
- **I/O**: `node_disk_read_bytes_total`, `node_disk_written_bytes_total`

#### **Network Metrics**
- **Traffic**: `node_network_receive_bytes_total`, `node_network_transmit_bytes_total`
- **Errors**: `node_network_receive_errs_total`, `node_network_transmit_errs_total`

### **Docker Metrics**

#### **Container Metrics**
- **CPU**: `container_cpu_usage_seconds_total`
- **Memory**: `container_memory_usage_bytes`
- **Network**: `container_network_receive_bytes_total`
- **Filesystem**: `container_fs_usage_bytes`

#### **Docker System Metrics**
- **Images**: `docker_images_size_bytes`
- **Volumes**: `docker_volumes_size_bytes`
- **Networks**: `docker_networks_size_bytes`

### **Application Metrics**

#### **Web Application Metrics**
- **Response Time**: `http_request_duration_seconds`
- **Request Rate**: `http_requests_total`
- **Error Rate**: `http_requests_total{status=~"5.."}`
- **Active Connections**: `http_connections_active`

#### **Database Metrics**
- **Query Time**: `pg_stat_statements_mean_time`
- **Connections**: `pg_stat_activity_count`
- **Cache Hit Rate**: `pg_stat_database_blks_hit / pg_stat_database_blks_read`

## 🚨 **Performance Alerts**

### **System Alerts**

#### **CPU Alerts**
```yaml
# Prometheus alert rule
- alert: HighCPUUsage
  expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "High CPU usage detected"
    description: "CPU usage is above 80% for more than 5 minutes"
```

#### **Memory Alerts**
```yaml
- alert: HighMemoryUsage
  expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 90
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "High memory usage detected"
    description: "Memory usage is above 90% for more than 5 minutes"
```

#### **Disk Alerts**
```yaml
- alert: HighDiskUsage
  expr: (1 - (node_filesystem_free_bytes / node_filesystem_size_bytes)) * 100 > 90
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "High disk usage detected"
    description: "Disk usage is above 90% for more than 5 minutes"
```

### **Application Alerts**

#### **Response Time Alerts**
```yaml
- alert: HighResponseTime
  expr: http_request_duration_seconds{quantile="0.95"} > 1
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "High response time detected"
    description: "95th percentile response time is above 1 second"
```

#### **Error Rate Alerts**
```yaml
- alert: HighErrorRate
  expr: rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) > 0.05
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "High error rate detected"
    description: "Error rate is above 5% for more than 5 minutes"
```

## 📈 **Capacity Planning**

### **Resource Projections**

#### **CPU Projections**
- **Current**: 10-30% average
- **6 months**: 20-40% average
- **12 months**: 30-50% average
- **Upgrade needed**: When >70% sustained

#### **Memory Projections**
- **Current**: 4-8GB (50-60%)
- **6 months**: 6-10GB (60-70%)
- **12 months**: 8-12GB (70-80%)
- **Upgrade needed**: When >90% sustained

#### **Disk Projections**
- **Current**: 60-80% usage
- **6 months**: 70-85% usage
- **12 months**: 80-90% usage
- **Upgrade needed**: When >95% usage

### **Scaling Strategies**

#### **Vertical Scaling**
- **CPU**: Upgrade to higher core count
- **Memory**: Add more RAM
- **Disk**: Add more storage
- **Network**: Upgrade network interface

#### **Horizontal Scaling**
- **Load Balancing**: Multiple Caddy instances
- **Database Clustering**: PostgreSQL cluster
- **Application Scaling**: Multiple app instances
- **Microservices**: Split monolithic applications

## 🔧 **Performance Testing**

### **Load Testing**

#### **Web Application Load Testing**
```bash
# Install Apache Bench
sudo apt install apache2-utils

# Test Caddy performance
ab -n 1000 -c 10 http://localhost:80/

# Test application performance
ab -n 1000 -c 10 http://localhost:8110/
ab -n 1000 -c 10 http://localhost:8120/
```

#### **Database Load Testing**
```bash
# PostgreSQL load testing
docker compose -f docker-compose-infrastructure.yml exec postgres psql -U user -d database -c "SELECT pg_stat_statements_reset();"
# Run application load
# Check performance
docker compose -f docker-compose-infrastructure.yml exec postgres psql -U user -d database -c "SELECT * FROM pg_stat_statements ORDER BY mean_time DESC LIMIT 10;"
```

### **Stress Testing**

#### **System Stress Testing**
```bash
# CPU stress test
stress --cpu 4 --timeout 60s

# Memory stress test
stress --vm 2 --vm-bytes 1G --timeout 60s

# Disk stress test
stress --io 4 --timeout 60s
```

#### **Application Stress Testing**
```bash
# Application stress test
ab -n 10000 -c 100 http://localhost:80/
ab -n 10000 -c 100 http://localhost:8110/
ab -n 10000 -c 100 http://localhost:8120/
```

## 📋 **Performance Checklist**

### **Daily Performance Check**
- [ ] Check CPU usage: `htop`
- [ ] Check memory usage: `free -h`
- [ ] Check disk usage: `df -h`
- [ ] Check container stats: `docker stats --no-stream`
- [ ] Check response times: `curl -w "@curl-format.txt" -o /dev/null -s http://localhost:80`

### **Weekly Performance Check**
- [ ] Review performance metrics in Grafana
- [ ] Check for performance alerts
- [ ] Review database performance
- [ ] Check application response times
- [ ] Review system resource usage

### **Monthly Performance Check**
- [ ] Run performance tests
- [ ] Review capacity planning
- [ ] Optimize system configuration
- [ ] Update performance baselines
- [ ] Review scaling strategies

## Related Documentation

- [Incident Response](./incident-response.md) - Troubleshooting procedures
- [Backup & Recovery](./backup-recovery.md) - Data protection procedures
- [Maintenance Procedures](./maintenance.md) - Regular maintenance tasks
- [Service Dependencies](./dependencies.md) - Service relationship mapping
- [Monitoring Setup](./monitoring.md) - Comprehensive monitoring

---

**Last Updated**: $(date)
**Performance Version**: 1.0
**Compatible With**: Ubuntu Server 24.04 LTS, Docker Engine 27.x
