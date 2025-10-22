# Hephaestus Homelab - Automation & Maintenance Bots

## Overview

This document outlines automation procedures, maintenance bots, and automated workflows for the Hephaestus Homelab infrastructure. It includes both n8n-based automation and traditional script-based automation.

## 🤖 **n8n Server Maintenance Bot**

### **Bot Overview**
- **Purpose**: Automated server maintenance and monitoring
- **Platform**: n8n workflow automation
- **Access**: `https://chrislawrence.ca/n8n`
- **Status**: In development
- **Integration**: Docker container with homelab-web network

### **n8n Bot Capabilities**

#### **Health Monitoring**
- **Service Status Checks**: Monitor all Docker services
- **Resource Monitoring**: CPU, memory, disk usage alerts
- **Network Connectivity**: Test internal and external connectivity
- **Database Health**: PostgreSQL and Redis health checks
- **Application Health**: Test all application endpoints

#### **Automated Maintenance**
- **Log Rotation**: Clean up old logs automatically
- **Disk Cleanup**: Remove temporary files and old backups
- **Container Updates**: Check for and apply Docker image updates
- **Security Updates**: Monitor and apply system security patches
- **Backup Verification**: Ensure backups are running and valid

#### **Alerting & Notifications**
- **Discord Notifications**: Send alerts to Discord channels
- **Email Alerts**: Send critical alerts via email
- **Slack Integration**: Send status updates to Slack
- **Telegram Bot**: Send maintenance notifications

### **n8n Bot Configuration**

#### **Docker Integration**
```yaml
# n8n service in docker-compose
n8n:
  image: n8nio/n8n:latest
  container_name: n8n
  restart: unless-stopped
  networks:
    - homelab-web
  ports:
    - "5678:5678"
  volumes:
    - n8n_data:/home/node/.n8n
    - /var/run/docker.sock:/var/run/docker.sock:ro
  environment:
    - N8N_BASIC_AUTH_ACTIVE=true
    - N8N_BASIC_AUTH_USER=admin
    - N8N_BASIC_AUTH_PASSWORD=admin123
    - N8N_HOST=0.0.0.0
    - N8N_PORT=5678
    - N8N_PROTOCOL=http
    - N8N_EDITOR_BASE_URL=https://chrislawrence.ca/n8n
```

#### **API Access for Bot**
```bash
# Docker API access
curl -X GET http://localhost:2375/containers/json

# Docker stats API
curl -X GET http://localhost:2375/containers/stats

# Docker logs API
curl -X GET http://localhost:2375/containers/{container_id}/logs
```

### **n8n Workflow Examples**

#### **Daily Health Check Workflow**
```json
{
  "name": "Daily Health Check",
  "nodes": [
    {
      "name": "Check Docker Services",
      "type": "n8n-nodes-base.httpRequest",
      "parameters": {
        "url": "http://localhost:2375/containers/json",
        "method": "GET"
      }
    },
    {
      "name": "Check System Resources",
      "type": "n8n-nodes-base.executeCommand",
      "parameters": {
        "command": "docker stats --no-stream --format 'table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}'"
      }
    },
    {
      "name": "Send Discord Alert",
      "type": "n8n-nodes-base.discord",
      "parameters": {
        "webhookUrl": "https://discord.com/api/webhooks/YOUR_WEBHOOK_URL",
        "text": "Daily health check completed"
      }
    }
  ]
}
```

#### **Automated Backup Workflow**
```json
{
  "name": "Automated Backup",
  "nodes": [
    {
      "name": "Trigger Backup",
      "type": "n8n-nodes-base.cron",
      "parameters": {
        "rule": "0 2 * * *"
      }
    },
    {
      "name": "Run Backup Script",
      "type": "n8n-nodes-base.executeCommand",
      "parameters": {
        "command": "/home/chris/github/hephaestus-homelab/scripts/backup.sh"
      }
    },
    {
      "name": "Verify Backup",
      "type": "n8n-nodes-base.executeCommand",
      "parameters": {
        "command": "ls -la /home/chris/backups/ | tail -1"
      }
    },
    {
      "name": "Send Success Notification",
      "type": "n8n-nodes-base.discord",
      "parameters": {
        "webhookUrl": "https://discord.com/api/webhooks/YOUR_WEBHOOK_URL",
        "text": "Backup completed successfully"
      }
    }
  ]
}
```

## 🔧 **Traditional Automation Scripts**

### **Maintenance Scripts**

#### **Daily Maintenance Script**
```bash
#!/bin/bash
# /home/chris/github/hephaestus-homelab/scripts/daily-maintenance.sh

set -e

echo "=== Daily Maintenance Started ==="
echo "Date: $(date)"

# 1. Check service health
echo "Checking service health..."
docker compose -f docker-compose-infrastructure.yml ps

# 2. Check system resources
echo "Checking system resources..."
df -h
free -h
uptime

# 3. Check disk space
echo "Checking disk space..."
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
    echo "Warning: Disk usage is ${DISK_USAGE}%"
    # Send alert via n8n webhook
    curl -X POST "https://chrislawrence.ca/n8n/webhook/disk-alert" \
         -H "Content-Type: application/json" \
         -d "{\"disk_usage\": ${DISK_USAGE}}"
fi

# 4. Clean up old logs
echo "Cleaning up old logs..."
docker system prune -f
sudo journalctl --vacuum-time=7d

# 5. Check for updates
echo "Checking for updates..."
sudo apt update
UPDATES=$(apt list --upgradable 2>/dev/null | wc -l)
if [ $UPDATES -gt 1 ]; then
    echo "Updates available: $UPDATES"
    # Send update notification via n8n webhook
    curl -X POST "https://chrislawrence.ca/n8n/webhook/updates-available" \
         -H "Content-Type: application/json" \
         -d "{\"updates_count\": ${UPDATES}}"
fi

echo "=== Daily Maintenance Complete ==="
```

#### **Weekly Maintenance Script**
```bash
#!/bin/bash
# /home/chris/github/hephaestus-homelab/scripts/weekly-maintenance.sh

set -e

echo "=== Weekly Maintenance Started ==="
echo "Date: $(date)"

# 1. Update system packages
echo "Updating system packages..."
sudo apt update
sudo apt upgrade -y

# 2. Update Docker images
echo "Updating Docker images..."
docker compose -f docker-compose-infrastructure.yml pull

# 3. Restart services with new images
echo "Restarting services..."
docker compose -f docker-compose-infrastructure.yml up -d

# 4. Clean up Docker system
echo "Cleaning up Docker system..."
docker system prune -f

# 5. Run database maintenance
echo "Running database maintenance..."
docker compose -f docker-compose-infrastructure.yml exec postgres psql -U user -d database -c "VACUUM ANALYZE;"

# 6. Send completion notification
curl -X POST "https://chrislawrence.ca/n8n/webhook/maintenance-complete" \
     -H "Content-Type: application/json" \
     -d "{\"maintenance_type\": \"weekly\", \"status\": \"complete\"}"

echo "=== Weekly Maintenance Complete ==="
```

### **Health Check Scripts**

#### **Service Health Check**
```bash
#!/bin/bash
# /home/chris/github/hephaestus-homelab/scripts/health-check.sh

set -e

echo "=== Service Health Check ==="
echo "Date: $(date)"

# Check critical services
SERVICES=("caddy" "portainer" "uptime-kuma" "grafana" "prometheus")
FAILED_SERVICES=()

for service in "${SERVICES[@]}"; do
    if docker compose -f docker-compose-infrastructure.yml ps | grep -q "${service}.*Up"; then
        echo "✅ ${service} is running"
    else
        echo "❌ ${service} is not running"
        FAILED_SERVICES+=("${service}")
    fi
done

# Check application services
APPS=("portfolio" "capitolscope" "schedshare" "magic-pages-api")
for app in "${APPS[@]}"; do
    if docker compose -f docker-compose-infrastructure.yml ps | grep -q "${app}.*Up"; then
        echo "✅ ${app} is running"
    else
        echo "❌ ${app} is not running"
        FAILED_SERVICES+=("${app}")
    fi
done

# Send alert if services are down
if [ ${#FAILED_SERVICES[@]} -gt 0 ]; then
    echo "Alert: ${#FAILED_SERVICES[@]} services are down: ${FAILED_SERVICES[*]}"
    curl -X POST "https://chrislawrence.ca/n8n/webhook/service-alert" \
         -H "Content-Type: application/json" \
         -d "{\"failed_services\": ${FAILED_SERVICES[*]}}"
fi

echo "=== Health Check Complete ==="
```

## 🔄 **Automation Integration**

### **n8n Webhook Integration**

#### **Webhook Endpoints**
```bash
# Create webhook endpoints in n8n for script integration
# https://chrislawrence.ca/n8n/webhook/disk-alert
# https://chrislawrence.ca/n8n/webhook/updates-available
# https://chrislawrence.ca/n8n/webhook/maintenance-complete
# https://chrislawrence.ca/n8n/webhook/service-alert
```

#### **Script to n8n Communication**
```bash
# Send data to n8n webhook
curl -X POST "https://chrislawrence.ca/n8n/webhook/maintenance-data" \
     -H "Content-Type: application/json" \
     -d '{
       "timestamp": "'$(date -Iseconds)'",
       "disk_usage": "'$(df / | awk "NR==2 {print \$5}" | sed "s/%//")'",
       "memory_usage": "'$(free | awk "NR==2{printf \"%.0f\", \$3*100/\$2}")'",
       "cpu_load": "'$(uptime | awk "{print \$10}" | sed "s/,//")'",
       "services_status": "'$(docker compose -f docker-compose-infrastructure.yml ps --format "table {{.Name}}\t{{.Status}}" | tail -n +2)'"
     }'
```

### **Cron Job Integration**

#### **Cron Schedule**
```bash
# Add to crontab
crontab -e

# Daily maintenance at 3 AM
0 3 * * * /home/chris/github/hephaestus-homelab/scripts/daily-maintenance.sh >> /home/chris/maintenance.log 2>&1

# Weekly maintenance at 4 AM on Sunday
0 4 * * 0 /home/chris/github/hephaestus-homelab/scripts/weekly-maintenance.sh >> /home/chris/maintenance.log 2>&1

# Health check every 6 hours
0 */6 * * * /home/chris/github/hephaestus-homelab/scripts/health-check.sh >> /home/chris/health.log 2>&1
```

## 📊 **Automation Monitoring**

### **n8n Bot Monitoring**

#### **Bot Health Check**
```bash
# Check n8n bot status
curl -I https://chrislawrence.ca/n8n

# Check n8n API
curl -X GET "https://chrislawrence.ca/n8n/api/v1/workflows" \
     -H "Authorization: Bearer YOUR_API_KEY"
```

#### **Bot Performance Metrics**
- **Workflow Execution Time**: Monitor how long workflows take
- **Success Rate**: Track successful vs failed executions
- **Error Rate**: Monitor workflow errors and failures
- **Resource Usage**: Track n8n container resource usage

### **Script Monitoring**

#### **Script Execution Logs**
```bash
# Check maintenance logs
tail -f /home/chris/maintenance.log

# Check health check logs
tail -f /home/chris/health.log

# Check for errors
grep -i error /home/chris/maintenance.log
grep -i error /home/chris/health.log
```

#### **Script Performance Metrics**
- **Execution Time**: How long scripts take to run
- **Success Rate**: Track successful vs failed executions
- **Resource Usage**: Monitor script resource consumption
- **Output Quality**: Verify script outputs and results

## 🚨 **Automation Alerts**

### **n8n Bot Alerts**

#### **Discord Alerts**
```json
{
  "name": "Discord Alert",
  "type": "n8n-nodes-base.discord",
  "parameters": {
    "webhookUrl": "https://discord.com/api/webhooks/YOUR_WEBHOOK_URL",
    "text": "🚨 Server Alert: {{$json.alert_message}}",
    "embeds": [
      {
        "title": "Server Status",
        "color": 16711680,
        "fields": [
          {
            "name": "Service",
            "value": "{{$json.service}}",
            "inline": true
          },
          {
            "name": "Status",
            "value": "{{$json.status}}",
            "inline": true
          },
          {
            "name": "Timestamp",
            "value": "{{$json.timestamp}}",
            "inline": true
          }
        ]
      }
    ]
  }
}
```

#### **Email Alerts**
```json
{
  "name": "Email Alert",
  "type": "n8n-nodes-base.emailSend",
  "parameters": {
    "toEmail": "chris@chrislawrence.ca",
    "subject": "🚨 Hephaestus Server Alert",
    "text": "Server alert: {{$json.alert_message}}",
    "html": "<h2>Server Alert</h2><p>{{$json.alert_message}}</p><p>Service: {{$json.service}}</p><p>Status: {{$json.status}}</p>"
  }
}
```

### **Script Alerts**

#### **Email Notifications**
```bash
# Send email alert from script
echo "Server alert: ${ALERT_MESSAGE}" | mail -s "Hephaestus Server Alert" chris@chrislawrence.ca
```

#### **Discord Notifications**
```bash
# Send Discord webhook from script
curl -X POST "https://discord.com/api/webhooks/YOUR_WEBHOOK_URL" \
     -H "Content-Type: application/json" \
     -d "{\"content\": \"🚨 Server Alert: ${ALERT_MESSAGE}\"}"
```

## 🔧 **Automation Troubleshooting**

### **n8n Bot Issues**

#### **Bot Not Responding**
```bash
# Check n8n container status
docker compose -f docker-compose-infrastructure.yml ps n8n

# Check n8n logs
docker compose -f docker-compose-infrastructure.yml logs n8n

# Restart n8n
docker compose -f docker-compose-infrastructure.yml restart n8n
```

#### **Workflow Execution Failures**
```bash
# Check n8n workflow logs
docker compose -f docker-compose-infrastructure.yml exec n8n n8n list

# Check workflow execution history
docker compose -f docker-compose-infrastructure.yml exec n8n n8n execute --id WORKFLOW_ID
```

### **Script Issues**

#### **Script Execution Failures**
```bash
# Check script permissions
ls -la /home/chris/github/hephaestus-homelab/scripts/

# Make scripts executable
chmod +x /home/chris/github/hephaestus-homelab/scripts/*.sh

# Test script execution
bash -x /home/chris/github/hephaestus-homelab/scripts/daily-maintenance.sh
```

#### **Cron Job Issues**
```bash
# Check cron service
sudo systemctl status cron

# Check cron logs
sudo journalctl -u cron

# Test cron job manually
sudo run-parts /etc/cron.daily/
```

## 📋 **Automation Checklist**

### **n8n Bot Setup**
- [ ] n8n container is running
- [ ] n8n is accessible via web interface
- [ ] Workflows are configured and active
- [ ] Webhook endpoints are working
- [ ] Notifications are configured

### **Script Automation Setup**
- [ ] Maintenance scripts are executable
- [ ] Cron jobs are scheduled
- [ ] Log files are being created
- [ ] Scripts are sending data to n8n
- [ ] Error handling is implemented

### **Integration Testing**
- [ ] n8n webhooks are receiving data
- [ ] Scripts are executing successfully
- [ ] Notifications are being sent
- [ ] Error handling is working
- [ ] Performance is acceptable

## 🚀 **Future Automation Ideas**

### **Advanced n8n Workflows**
- **Predictive Maintenance**: Use machine learning to predict failures
- **Auto-scaling**: Automatically scale services based on load
- **Security Monitoring**: Automated security scanning and alerting
- **Cost Optimization**: Monitor and optimize resource usage

### **Advanced Scripts**
- **Intelligent Backup**: Smart backup scheduling based on changes
- **Performance Tuning**: Automatic performance optimization
- **Security Hardening**: Automated security updates and hardening
- **Disaster Recovery**: Automated disaster recovery procedures

## Related Documentation

- [Incident Response](./incident-response.md) - Troubleshooting procedures
- [Backup & Recovery](./backup-recovery.md) - Data protection procedures
- [Maintenance Procedures](./maintenance.md) - Regular maintenance tasks
- [Service Dependencies](./dependencies.md) - Service relationship mapping
- [Performance Monitoring](./performance.md) - System optimization

---

**Last Updated**: $(date)
**Automation Version**: 1.0
**Compatible With**: n8n v1.x, Docker Compose v2.0+, Docker Engine 27.x
