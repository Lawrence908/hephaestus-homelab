# Monitoring & Observability

Complete guide to monitoring Hephaestus using Uptime Kuma, Grafana, Prometheus, and associated tools.

## Table of Contents

1. [Monitoring Stack Overview](#monitoring-stack-overview)
2. [Uptime Kuma Setup](#uptime-kuma-setup)
3. [Grafana Configuration](#grafana-configuration)
4. [Prometheus Metrics](#prometheus-metrics)
5. [System Monitoring](#system-monitoring)
6. [Alerting](#alerting)
7. [Log Management](#log-management)
8. [Performance Tuning](#performance-tuning)

---

## Monitoring Stack Overview

### Components

| Tool | Purpose | Access |
|------|---------|--------|
| **Uptime Kuma** | Website/service uptime monitoring | https://uptime.yourdomain.com |
| **Grafana** | Metrics visualization & dashboards | https://grafana.yourdomain.com |
| **Prometheus** | Metrics collection & storage | https://prometheus.yourdomain.com |
| **cAdvisor** | Container resource usage | Internal only |
| **Node Exporter** | Host system metrics | Internal only |
| **Glances** | Real-time system monitor | http://192.168.50.70:61208 |

### Data Flow

```
[Containers] → cAdvisor → Prometheus → Grafana
[Host System] → Node Exporter → Prometheus → Grafana
[Services] → Uptime Kuma → Alerts
```

---

## Uptime Kuma Setup

### Initial Configuration

1. **Access Uptime Kuma**:
   ```
   https://uptime.yourdomain.com
   ```

2. **Create Admin Account**:
   - First visitor gets to set up the admin account
   - Username: `admin` (or your preference)
   - Password: Strong password
   - Click **Create**

### Add Monitors

#### HTTP/HTTPS Monitors

**Monitor your public services**:

| Name | Monitor Type | URL | Interval |
|------|-------------|-----|----------|
| Magic Pages Frontend | HTTP(s) | https://magicpages.yourdomain.com | 60s |
| Magic Pages API | HTTP(s) | https://api.magicpages.yourdomain.com/health | 60s |
| CapitolScope | HTTP(s) | https://capitolscope.yourdomain.com/health | 60s |
| SchedShare | HTTP(s) | https://schedshare.yourdomain.com/health | 60s |
| Portfolio | HTTP(s) | https://portfolio.yourdomain.com | 60s |
| Portainer | HTTP(s) | https://portainer.yourdomain.com | 120s |
| Grafana | HTTP(s) | https://grafana.yourdomain.com | 120s |

**Steps to add**:
1. Click **+ Add New Monitor**
2. **Monitor Type**: HTTP(s)
3. **Friendly Name**: Enter name from table
4. **URL**: Enter URL from table
5. **Heartbeat Interval**: 60 seconds
6. **Retries**: 3
7. **Accepted Status Codes**: `200-299`
8. **Ignore TLS/SSL Error**: Unchecked (Cloudflare handles SSL)
9. Click **Save**

#### Docker Container Monitors

Monitor container health directly:

1. **Monitor Type**: Docker Container
2. **Docker Host**: `unix:///var/run/docker.sock`
3. **Container Name / ID**: `caddy`, `uptime-kuma`, etc.
4. **Interval**: 120s

**Note**: Uptime Kuma container needs access to Docker socket (already configured in docker-compose.yml).

#### Ping Monitors

Monitor Hephaestus host:

1. **Monitor Type**: Ping
2. **Hostname**: `192.168.50.70` or `hephaestus`
3. **Interval**: 60s

### Status Pages

Create a public status page:

1. Go to **Status Pages**
2. Click **+ New Status Page**
3. **Slug**: `status` (URL will be: https://uptime.yourdomain.com/status/status)
4. **Title**: Hephaestus Services
5. Add monitors to display
6. **Public**: Yes (if you want it publicly accessible)
7. **Save**

Share this with users to show service status.

### Notifications

#### Discord Notifications

1. Create a Discord webhook:
   - Server Settings → Integrations → Webhooks → New Webhook
   - Copy webhook URL
2. In Uptime Kuma: **Settings** → **Notifications**
3. **Notification Type**: Discord
4. **Discord Webhook URL**: Paste URL
5. **Friendly Name**: Discord Alerts
6. **Save**
7. Add to monitors under **Notifications**

#### Email Notifications

1. **Notification Type**: Email (SMTP)
2. **SMTP Host**: smtp.gmail.com (or your provider)
3. **SMTP Port**: 587
4. **Security**: TLS
5. **Username**: your-email@gmail.com
6. **Password**: App-specific password
7. **From Email**: your-email@gmail.com
8. **To Email**: alerts@example.com
9. **Test** and **Save**

#### Telegram Notifications

1. Create a Telegram bot: Message `@BotFather` and create bot
2. Get your Chat ID: Message `@userinfobot`
3. In Uptime Kuma:
   - **Notification Type**: Telegram
   - **Bot Token**: From BotFather
   - **Chat ID**: From userinfobot
   - **Test** and **Save**

### Enable Prometheus Metrics

1. Go to **Settings**
2. Scroll to **Advanced**
3. Enable **Prometheus Export**
4. Metrics available at: `http://uptime-kuma:3001/metrics`
5. Already configured in Prometheus (see `grafana-stack/prometheus.yml`)

---

## Grafana Configuration

### Initial Setup

1. **Access Grafana**:
   ```
   https://grafana.yourdomain.com
   ```

2. **Login**:
   - Username: `admin`
   - Password: From `.env` file (`GRAFANA_ADMIN_PASSWORD`)

3. **Change Password** (if needed):
   - Click profile icon → **Change Password**

### Data Sources

Prometheus should already be configured. Verify:

1. Go to **Configuration** → **Data Sources**
2. You should see **Prometheus** listed
3. Click to verify:
   - URL: `http://prometheus:9090`
   - Access: **Server (default)**
   - Click **Save & Test**

### Import Hephaestus Dashboard

The overview dashboard is pre-configured at `grafana-stack/dashboards/hephaestus-overview.json`.

**Import it**:

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

### Install Additional Dashboards

**From Grafana.com**:

1. Go to [grafana.com/dashboards](https://grafana.com/grafana/dashboards)
2. Search for dashboards:
   - **cAdvisor**: Dashboard ID `14282`
   - **Node Exporter Full**: Dashboard ID `1860`
   - **Docker Monitoring**: Dashboard ID `893`

**Import by ID**:
1. **Dashboards** → **Import**
2. Enter Dashboard ID
3. Select **Prometheus** as data source
4. Click **Import**

### Create Custom Panels

**Example: Application Response Time**

1. Create new dashboard
2. Add panel
3. Query:
   ```promql
   histogram_quantile(0.95, 
     rate(http_request_duration_seconds_bucket[5m])
   )
   ```
4. Panel title: "95th Percentile Response Time"
5. Visualization: Time series
6. Save

---

## Prometheus Metrics

### Available Metrics

**Node Exporter** (system metrics):
- `node_cpu_seconds_total` - CPU usage
- `node_memory_MemAvailable_bytes` - Available memory
- `node_disk_read_bytes_total` - Disk read
- `node_disk_written_bytes_total` - Disk write
- `node_network_receive_bytes_total` - Network RX
- `node_network_transmit_bytes_total` - Network TX

**cAdvisor** (container metrics):
- `container_cpu_usage_seconds_total` - Container CPU
- `container_memory_usage_bytes` - Container memory
- `container_network_receive_bytes_total` - Container network RX
- `container_fs_usage_bytes` - Container filesystem usage

**Uptime Kuma**:
- `uptimekuma_up` - Monitor status (1 = up, 0 = down)
- `uptimekuma_response_time` - Response time in ms

### Query Examples

**CPU usage by container**:
```promql
rate(container_cpu_usage_seconds_total{name!=""}[5m]) * 100
```

**Memory usage percentage**:
```promql
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
```

**Disk space remaining**:
```promql
node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"} * 100
```

**Uptime percentage (24h)**:
```promql
avg_over_time(uptimekuma_up[24h]) * 100
```

### Add Application Metrics

To expose metrics from your apps, add Prometheus client libraries:

**Django (Magic Pages API)**:
```python
# requirements.txt
django-prometheus

# settings.py
INSTALLED_APPS += ['django_prometheus']
MIDDLEWARE = ['django_prometheus.middleware.PrometheusBeforeMiddleware'] + MIDDLEWARE + ['django_prometheus.middleware.PrometheusAfterMiddleware']

# urls.py
path('metrics/', include('django_prometheus.urls')),
```

**FastAPI (CapitolScope)**:
```python
# requirements.txt
prometheus-fastapi-instrumentator

# main.py
from prometheus_fastapi_instrumentator import Instrumentator

app = FastAPI()
Instrumentator().instrument(app).expose(app)
```

**Flask (Portfolio, SchedShare)**:
```python
# requirements.txt
prometheus-flask-exporter

# app.py
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)
metrics = PrometheusMetrics(app)
```

Then update `grafana-stack/prometheus.yml` with correct `/metrics` paths.

---

## System Monitoring

### Glances

Real-time system monitoring dashboard.

**Access**:
```
http://192.168.50.70:61208
```

**Features**:
- CPU, memory, disk, network in real-time
- Per-process resource usage
- Docker container monitoring
- Historical graphs

**Keyboard shortcuts** (when running in terminal):
- `1-5`: Switch between views
- `s`: Sort by CPU/memory
- `d`: Show/hide disk I/O
- `q`: Quit

### Container Stats

**Real-time stats**:
```bash
docker stats
```

**Specific container**:
```bash
docker stats caddy
```

**No stream** (one-time snapshot):
```bash
docker stats --no-stream
```

### System Resources

**Check disk space**:
```bash
df -h
```

**Check memory**:
```bash
free -h
```

**Check CPU**:
```bash
htop
# or
top
```

**Docker disk usage**:
```bash
docker system df
docker system df -v  # Verbose
```

---

## Alerting

### Grafana Alerts

**Create an alert rule**:

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
8. **Save**

**Contact points**:

1. **Alerting** → **Contact points** → **New contact point**
2. **Name**: Discord Alerts
3. **Type**: Discord
4. **Webhook URL**: Your Discord webhook
5. **Test** and **Save**

**Notification policies**:

1. **Alerting** → **Notification policies**
2. Edit default policy
3. **Default contact point**: Discord Alerts
4. **Grouping**: By alertname
5. **Save**

### Example Alert Rules

**Container Down**:
```promql
up{job="docker"} == 0
```

**High Disk Usage**:
```promql
(node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100 < 10
```

**High CPU Load**:
```promql
node_load5 / count(node_cpu_seconds_total{mode="idle"}) > 0.8
```

**Container Restart Loop**:
```promql
rate(container_start_time_seconds[5m]) > 1
```

### Uptime Kuma Alerts

Already configured per monitor. Sends alerts when:
- Service goes down
- Service comes back up
- Service is slow (response time threshold)

---

## Log Management

### View Logs

**All services**:
```bash
docker compose logs -f
```

**Specific service**:
```bash
docker compose logs -f caddy
docker compose logs -f magic-pages-api
```

**Last N lines**:
```bash
docker compose logs --tail=100 grafana
```

**Since timestamp**:
```bash
docker compose logs --since=1h uptime-kuma
```

### Caddy Access Logs

View individual service logs:

```bash
# Uptime Kuma access
docker exec caddy tail -f /data/logs/uptime.log

# Magic Pages API access
docker exec caddy tail -f /data/logs/magic-pages-api.log
```

### Log Rotation

Docker handles log rotation based on daemon config (`/etc/docker/daemon.json`):

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

This keeps the last 3 × 10MB of logs per container.

### Export Logs

**Export to file**:
```bash
docker compose logs --no-color > hephaestus-logs.txt
```

**Filter for errors**:
```bash
docker compose logs | grep -i error
```

---

## Performance Tuning

### Identify Bottlenecks

**CPU bottleneck**:
```bash
docker stats --no-stream | sort -k3 -h
```

**Memory bottleneck**:
```bash
docker stats --no-stream | sort -k7 -h
```

**Disk I/O**:
```bash
sudo iotop
```

### Optimize Containers

**Increase container resources** (docker-compose.yml):

```yaml
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

**Increase Gunicorn workers**:

```yaml
magic-pages-api:
  command: gunicorn config.wsgi:application --bind 0.0.0.0:8000 --workers 4
```

### Database Tuning

**Postgres (CapitolScope)**:

```yaml
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

**Adjust retention** in `grafana-stack/docker-compose.yml`:

```yaml
prometheus:
  command:
    - --storage.tsdb.retention.time=30d  # Keep 30 days
    - --storage.tsdb.retention.size=10GB # Or max 10GB
```

---

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

---

## Troubleshooting

### Prometheus Not Scraping

**Check targets**:
1. Go to Prometheus: `http://192.168.50.70:9090`
2. **Status** → **Targets**
3. Look for DOWN targets

**Fix**:
```bash
# Restart service that's down
docker compose restart cadvisor

# Check if service is on web network
docker network inspect web
```

### Grafana Dashboard Shows "No Data"

**Check**:
1. Prometheus is running: `docker compose ps prometheus`
2. Data source is configured
3. Query is correct (test in Prometheus UI)
4. Time range is appropriate

### Uptime Kuma Not Monitoring

**Check**:
1. Container is running: `docker compose ps uptime-kuma`
2. DNS resolves: `nslookup yourdomain.com`
3. Service is actually reachable
4. Monitor interval hasn't run yet (wait one interval)

---

## Quick Commands

```bash
# View all service status
docker compose ps

# Check resource usage
docker stats

# View Grafana
https://grafana.yourdomain.com

# View Uptime Kuma
https://uptime.yourdomain.com

# Check Prometheus targets
http://192.168.50.70:9090/targets

# Real-time system monitoring
http://192.168.50.70:61208

# View logs
docker compose logs -f
```

---

**Next**: See [SETUP.md](./SETUP.md) for deployment instructions.

