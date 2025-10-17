# Caddy Logging Configuration for Hephaestus Homelab

This document describes the enhanced logging setup for the Caddy reverse proxy in the Hephaestus Homelab.

## Overview

The logging configuration has been improved to provide:
- **Structured JSON logging** for better parsing and analysis
- **Separate error logs** for easier troubleshooting
- **Log rotation** to prevent disk space issues
- **Filtered logs** to reduce noise
- **Real-time monitoring** capabilities

## Log Structure

```
/data/logs/
├── caddy.json                    # Global Caddy logs (INFO level)
├── caddy-errors.json            # Global error logs (ERROR level)
├── chrislawrence-ca.json         # Main domain logs (INFO level)
├── chrislawrence-ca-errors.json  # Main domain errors (ERROR level)
├── chrislawrence-ca-access.log   # Access logs (Common Log Format)
├── dashboard.json                # Dashboard logs (INFO level)
├── dashboard-errors.json         # Dashboard errors (ERROR level)
├── analysis/                     # Log analysis output
│   ├── global-errors.txt
│   ├── main-domain-errors.txt
│   └── summary.txt
└── filtered/                     # Filtered logs
    ├── caddy-filtered.txt
    ├── main-domain-filtered.txt
    └── realtime-monitor.sh
```

## Log Rotation Configuration

| Log Type | Max Size | Keep Files | Retention |
|----------|----------|------------|-----------|
| Global logs | 50MB | 10 files | 720 hours (30 days) |
| Error logs | 10MB | 20 files | 168 hours (7 days) |
| Access logs | 100MB | 5 files | 168 hours (7 days) |
| Main domain | 50MB | 15 files | 720 hours (30 days) |

## Usage

### 1. Analyze Logs

```bash
# Run the log analyzer
./log-analyzer.sh

# This will create analysis reports in /data/logs/analysis/
```

### 2. Filter Logs

```bash
# Filter out noise from logs
./log-filter.sh

# This creates filtered versions in /data/logs/filtered/
```

### 3. Real-time Monitoring

```bash
# Monitor logs in real-time (filtered)
/data/logs/filtered/realtime-monitor.sh

# Or monitor all logs
tail -f /data/logs/caddy.json | jq -r '.msg'
```

### 4. Docker Compose with Logging

```bash
# Start with enhanced logging
docker compose -f docker-compose.yml -f docker-compose.logging.yml up -d

# Access log analysis tools
docker compose exec log-analyzer /usr/local/bin/log-analyzer.sh
```

## Log Analysis Examples

### Find Recent Errors
```bash
# Get last 10 errors
jq -r 'select(.level == "error") | "\(.ts | strftime("%Y-%m-%d %H:%M:%S")) | \(.msg)"' \
    /data/logs/caddy-errors.json | tail -10
```

### Monitor Specific Service
```bash
# Monitor portfolio service errors
jq -r 'select(.level == "error" and (.msg | contains("portfolio"))) | .msg' \
    /data/logs/chrislawrence-ca-errors.json
```

### Analyze Access Patterns
```bash
# Top 10 most accessed paths
jq -r 'select(.request != null) | .request.uri' /data/logs/chrislawrence-ca.json | \
    sort | uniq -c | sort -nr | head -10
```

### Check Service Health
```bash
# Check for service connection issues
jq -r 'select(.msg | contains("connection refused") or contains("server misbehaving")) | .msg' \
    /data/logs/caddy-errors.json
```

## Log Levels

- **ERROR**: Critical issues requiring immediate attention
- **WARN**: Potential issues that should be monitored
- **INFO**: General information about server operation
- **DEBUG**: Detailed debugging information (not enabled by default)

## Common Log Patterns

### DNS Resolution Issues
```json
{
  "level": "error",
  "msg": "dial tcp: lookup service-name on 127.0.0.11:53: server misbehaving"
}
```

### Connection Refused
```json
{
  "level": "error", 
  "msg": "dial tcp 172.19.0.12:5678: connect: connection refused"
}
```

### Successful Requests
```json
{
  "level": "info",
  "request": {
    "method": "GET",
    "uri": "/portfolio/",
    "status": 200
  }
}
```

## Troubleshooting

### High Log Volume
If logs are growing too quickly:
1. Increase log rotation frequency
2. Use log filtering to reduce noise
3. Consider adjusting log levels

### Missing Logs
If logs aren't appearing:
1. Check Docker volume mounts
2. Verify log directory permissions
3. Ensure Caddy configuration is loaded

### Performance Impact
If logging impacts performance:
1. Reduce log level to WARN or ERROR
2. Increase log rotation frequency
3. Use separate log files for different services

## Monitoring Integration

The structured JSON logs can be easily integrated with:
- **ELK Stack** (Elasticsearch, Logstash, Kibana)
- **Grafana Loki**
- **Prometheus** (with log metrics)
- **Custom monitoring solutions**

Example Logstash configuration:
```ruby
filter {
  if [type] == "caddy" {
    json {
      source => "message"
    }
    date {
      match => [ "ts", "UNIX" ]
    }
  }
}
```

## Maintenance

### Daily Tasks
- Check error logs for new issues
- Monitor log disk usage
- Review access patterns

### Weekly Tasks
- Run log analysis
- Clean up old log files
- Review log rotation settings

### Monthly Tasks
- Analyze log trends
- Update log filtering rules
- Review and optimize log configuration

