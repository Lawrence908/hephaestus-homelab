# Hephaestus Homelab - Monitoring & Observability

## Overview

This document outlines the comprehensive monitoring setup for the Hephaestus Homelab, including Uptime Kuma, Grafana, Prometheus, and associated monitoring tools.

## Monitoring Stack Components

### Core Monitoring Services

| Tool | Purpose | Access | Status |
|------|---------|--------|--------|
| **Uptime Kuma** | Website/service uptime monitoring | `https://chrislawrence.ca/uptime` | ✅ Active |
| **Grafana** | Metrics visualization & dashboards | `https://chrislawrence.ca/metrics` | ✅ Active |
| **Prometheus** | Metrics collection & storage | `https://chrislawrence.ca/prometheus` | ✅ Active |
| **cAdvisor** | Container resource usage | `https://chrislawrence.ca/containers` | ✅ Active |
| **Node Exporter** | Host system metrics | Internal only | ✅ Active |
| **Glances** | Real-time system monitor | `https://chrislawrence.ca/system` | ✅ Active |

### Data Flow Architecture

```
[Containers] → cAdvisor → Prometheus → Grafana
[Host System] → Node Exporter → Prometheus → Grafana
[Services] → Uptime Kuma → Alerts
```

## Uptime Kuma Configuration

### Initial Setup
1. **Access Uptime Kuma**: `https://chrislawrence.ca/uptime`
2. **Create Admin Account**: First visitor sets up admin account
3. **Configure Monitors**: Add service monitors

### Service Monitors

#### HTTP/HTTPS Monitors
| Name | Monitor Type | URL | Interval |
|------|-------------|-----|----------|
| Portfolio | HTTP(s) | `https://chrislawrence.ca/portfolio` | 60s |
| CapitolScope | HTTP(s) | `https://chrislawrence.ca/capitolscope` | 60s |
| SchedShare | HTTP(s) | `https://chrislawrence.ca/schedshare` | 60s |
| MagicPages API | HTTP(s) | `https://chrislawrence.ca/magicpages-api` | 60s |
| MagicPages Frontend | HTTP(s) | `https://chrislawrence.ca/magicpages` | 60s |
| Portainer | HTTP(s) | `https://chrislawrence.ca/docker` | 120s |
| Grafana | HTTP(s) | `https://chrislawrence.ca/metrics` | 120s |

#### Docker Container Monitors
| Container | Monitor Type | Configuration |
|-----------|-------------|---------------|
| Caddy | Docker Container | `unix:///var/run/docker.sock` |
| Portainer | Docker Container | `unix:///var/run/docker.sock` |
| Grafana | Docker Container | `unix:///var/run/docker.sock` |

#### Ping Monitors
| Name | Hostname | Interval |
|------|----------|----------|
| Hephaestus Host | `192.168.50.70` | 60s |

### Status Pages
Create public status page:
1. Go to **Status Pages** → **+ New Status Page**
2. **Slug**: `status`
3. **Title**: Hephaestus Services
4. **Public**: Yes
5. Add monitors to display

### Notifications

#### Discord Notifications
1. Create Discord webhook in server settings
2. In Uptime Kuma: **Settings** → **Notifications**
3. **Notification Type**: Discord
4. **Discord Webhook URL**: Paste URL
5. **Friendly Name**: Discord Alerts

#### Email Notifications
1. **Notification Type**: Email (SMTP)
2. **SMTP Host**: smtp.gmail.com
3. **SMTP Port**: 587
4. **Security**: TLS
5. **Username**: your-email@gmail.com
6. **Password**: App-specific password

#### Telegram Notifications
1. Create Telegram bot via @BotFather
2. Get Chat ID from @userinfobot
3. Configure in Uptime Kuma:
   - **Bot Token**: From BotFather
   - **Chat ID**: From userinfobot

## Grafana Configuration

### Initial Setup
1. **Access Grafana**: `https://chrislawrence.ca/metrics`
2. **Login**: Username `admin`, password from `.env`
3. **Change Password**: Click profile icon → Change Password

### Data Sources
Prometheus should be pre-configured:
- **URL**: `http://prometheus:9090`
- **Access**: Server (default)
- **Save & Test**

### Import Hephaestus Dashboard
1. Go to **Dashboards** → **Import**
2. Click **Upload JSON file**
3. Select `/grafana-stack/dashboards/hephaestus-overview.json`
4. Click **Import**

**Dashboard shows**:
- System CPU usage
- Memory usage
- Disk I/O
- Network traffic
- Container CPU usage (top 5)
- Container memory usage (top 5)
- Uptime Kuma monitor status

### Additional Dashboards
Import from Grafana.com:
- **cAdvisor**: Dashboard ID `14282`
- **Node Exporter Full**: Dashboard ID `1860`
- **Docker Monitoring**: Dashboard ID `893`

## Prometheus Metrics

### Available Metrics

#### Node Exporter (System Metrics)
- `node_cpu_seconds_total` - CPU usage
- `node_memory_MemAvailable_bytes` - Available memory
- `node_disk_read_bytes_total` - Disk read
- `node_disk_written_bytes_total` - Disk write
- `node_network_receive_bytes_total` - Network RX
- `node_network_transmit_bytes_total` - Network TX

#### cAdvisor (Container Metrics)
- `container_cpu_usage_seconds_total` - Container CPU
- `container_memory_usage_bytes` - Container memory
- `container_network_receive_bytes_total` - Container network RX
- `container_fs_usage_bytes` - Container filesystem usage

#### Uptime Kuma
- `uptimekuma_up` - Monitor status (1 = up, 0 = down)
- `uptimekuma_response_time` - Response time in ms

### Query Examples

#### CPU Usage by Container
```promql
rate(container_cpu_usage_seconds_total{name!=""}[5m]) * 100
```

#### Memory Usage Percentage
```promql
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
```

#### Disk Space Remaining
```promql
node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"} * 100
```

#### Uptime Percentage (24h)
```promql
avg_over_time(uptimekuma_up[24h]) * 100
```

### Application Metrics Integration

#### Django (Magic Pages API)
```python
# requirements.txt
django-prometheus

# settings.py
INSTALLED_APPS += ['django_prometheus']
MIDDLEWARE = ['django_prometheus.middleware.PrometheusBeforeMiddleware'] + MIDDLEWARE + ['django_prometheus.middleware.PrometheusAfterMiddleware']

# urls.py
path('metrics/', include('django_prometheus.urls')),
```

#### FastAPI (CapitolScope)
```python
# requirements.txt
prometheus-fastapi-instrumentator

# main.py
from prometheus_fastapi_instrumentator import Instrumentator
app = FastAPI()
Instrumentator().instrument(app).expose(app)
```

#### Flask (Portfolio, SchedShare)
```python
# requirements.txt
prometheus-flask-exporter

# app.py
from prometheus_flask_exporter import PrometheusMetrics
app = Flask(__name__)
metrics = PrometheusMetrics(app)
```

## System Monitoring

### Glances Real-time Monitoring
- **Access**: `https://chrislawrence.ca/system`
- **Features**:
  - CPU, memory, disk, network in real-time
  - Per-process resource usage
  - Docker container monitoring
  - Historical graphs

### Container Stats
```bash
# Real-time stats
docker stats

# Specific container
docker stats caddy

# One-time snapshot
docker stats --no-stream
```

### System Resources
```bash
# Check disk space
df -h

# Check memory
free -h

# Check CPU
htop
```

## Alerting Configuration

### Grafana Alerts

#### Create Alert Rule
1. Go to **Alerting** → **Alert rules** → **New alert rule**
2. **Alert name**: High Memory Usage
3. **Query**:
   ```promql
   (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 80
   ```
4. **Condition**: Above 80 for 5 minutes
5. **Folder**: Hephaestus
6. **Evaluation group**: System Alerts
7. **Pending period**: 5m

#### Contact Points
1. **Alerting** → **Contact points** → **New contact point**
2. **Name**: Discord Alerts
3. **Type**: Discord
4. **Webhook URL**: Your Discord webhook

#### Notification Policies
1. **Alerting** → **Notification policies**
2. Edit default policy
3. **Default contact point**: Discord Alerts
4. **Grouping**: By alertname

### Example Alert Rules

#### Container Down
```promql
up{job="docker"} == 0
```

#### High Disk Usage
```promql
(node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100 < 10
```

#### High CPU Load
```promql
node_load5 / count(node_cpu_seconds_total{mode="idle"}) > 0.8
```

#### Container Restart Loop
```promql
rate(container_start_time_seconds[5m]) > 1
```

## Log Management

### View Logs
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f caddy
docker compose logs -f magic-pages-api

# Last N lines
docker compose logs --tail=100 grafana

# Since timestamp
docker compose logs --since=1h uptime-kuma
```

### Caddy Access Logs
```bash
# Uptime Kuma access
docker exec caddy tail -f /data/logs/uptime.log

# Magic Pages API access
docker exec caddy tail -f /data/logs/magic-pages-api.log
```

### Log Rotation
Docker handles log rotation via daemon config:
```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

## Performance Tuning

### Identify Bottlenecks
```bash
# CPU bottleneck
docker stats --no-stream | sort -k3 -h

# Memory bottleneck
docker stats --no-stream | sort -k7 -h

# Disk I/O
sudo iotop
```

### Optimize Containers
```yaml
# Increase container resources
magic-pages-api:
  deploy:
    resources:
      limits:
        cpus: '2.0'
        memory: 2G
      reservations:
        cpus: '1.0'
        memory: 512M
```

### Database Tuning
```yaml
# Postgres optimization
capitolscope-db:
  command:
    - postgres
    - -c
    - shared_buffers=256MB
    - -c
    - max_connections=100
    - -c
    - work_mem=16MB
```

### Prometheus Storage
```yaml
# Adjust retention
prometheus:
  command:
    - --storage.tsdb.retention.time=30d
    - --storage.tsdb.retention.size=10GB
```

## Monitoring Checklist

### Daily
- [ ] Check Uptime Kuma status page
- [ ] Review Grafana dashboards for anomalies
- [ ] Check for container restarts: `docker compose ps`

### Weekly
- [ ] Review Uptime Kuma incident history
- [ ] Check disk space: `df -h`
- [ ] Clean up Docker: `docker system prune -f`
- [ ] Review Grafana alerts

### Monthly
- [ ] Update Grafana dashboards
- [ ] Review and tune alert thresholds
- [ ] Check Prometheus storage size
- [ ] Export and backup monitoring configs

## Troubleshooting

### Prometheus Not Scraping
```bash
# Check targets
curl http://192.168.50.70:9090/targets

# Restart service
docker compose restart cadvisor
```

### Grafana Dashboard Shows "No Data"
1. Check Prometheus is running: `docker compose ps prometheus`
2. Verify data source configuration
3. Test query in Prometheus UI
4. Check time range is appropriate

### Uptime Kuma Not Monitoring
1. Check container is running: `docker compose ps uptime-kuma`
2. Verify DNS resolution: `nslookup chrislawrence.ca`
3. Test service accessibility
4. Wait for monitor interval to complete

## Quick Commands

```bash
# View all service status
docker compose ps

# Check resource usage
docker stats

# View Grafana
https://chrislawrence.ca/metrics

# View Uptime Kuma
https://chrislawrence.ca/uptime

# Check Prometheus targets
http://192.168.50.70:9090/targets

# Real-time system monitoring
https://chrislawrence.ca/system

# View logs
docker compose logs -f
```

## Related Documentation

- [Service Architecture](./services.md) - Service definitions and management
- [Network Architecture](./networks.md) - Docker network setup
- [Security Configuration](./security.md) - Authentication and access control
- [Deployment Guide](./deployment.md) - Service deployment procedures

---

**Last Updated**: $(date)
**Monitoring Version**: 1.0
**Compatible With**: Grafana v10.x, Prometheus v2.x, Uptime Kuma v1.x


