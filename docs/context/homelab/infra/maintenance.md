# Hephaestus Homelab - Maintenance & Updates

## Overview

This document outlines regular maintenance procedures, update schedules, and operational tasks for the Hephaestus Homelab infrastructure. It ensures system reliability, security, and performance.

## 📅 **Maintenance Schedule**

### **Daily Tasks**
- [ ] Check service health and status
- [ ] Review system resource usage
- [ ] Monitor backup completion
- [ ] Check security logs
- [ ] Verify public access

### **Weekly Tasks**
- [ ] Update system packages
- [ ] Review and rotate logs
- [ ] Check disk space
- [ ] Test backup procedures
- [ ] Review security alerts

### **Monthly Tasks**
- [ ] Update Docker images
- [ ] Review and update configurations
- [ ] Security audit
- [ ] Performance optimization
- [ ] Documentation updates

### **Quarterly Tasks**
- [ ] Full system backup
- [ ] Security updates
- [ ] Hardware maintenance
- [ ] Disaster recovery testing
- [ ] Capacity planning

## 🔄 **Update Procedures**

### **System Updates**

#### **Ubuntu System Updates**
```bash
# Update package lists
sudo apt update

# Check for available updates
sudo apt list --upgradable

# Update system packages
sudo apt upgrade -y

# Update distribution (if needed)
sudo apt dist-upgrade -y

# Clean up
sudo apt autoremove -y
sudo apt autoclean
```

#### **Docker Updates**
```bash
# Update Docker Engine
sudo apt update
sudo apt upgrade docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Restart Docker service
sudo systemctl restart docker

# Verify Docker version
docker --version
docker compose version
```

### **Application Updates**

#### **Docker Image Updates**
```bash
# Update all images
docker compose -f docker-compose-infrastructure.yml pull

# Update specific service
docker compose -f docker-compose-infrastructure.yml pull [service]

# Restart services with new images
docker compose -f docker-compose-infrastructure.yml up -d
```

#### **Application Code Updates**
```bash
# Update application code
cd /home/chris/apps/[application]
git pull origin main

# Rebuild and restart
docker compose -f docker-compose-homelab.yml up -d --build

# Run database migrations (if needed)
docker compose -f docker-compose-homelab.yml exec [service] python manage.py migrate
```

### **Configuration Updates**

#### **Environment Variable Updates**
```bash
# Update environment variables
vim /home/chris/github/hephaestus-infra/.env

# Restart services to apply changes
docker compose -f docker-compose-infrastructure.yml restart
```

#### **Caddy Configuration Updates**
```bash
# Update Caddyfile
vim /home/chris/github/hephaestus-infra/proxy/Caddyfile

# Validate configuration
docker compose -f docker-compose-infrastructure.yml exec caddy caddy validate --config /etc/caddy/Caddyfile

# Reload Caddy
docker compose -f docker-compose-infrastructure.yml exec caddy caddy reload --config /etc/caddy/Caddyfile
```

## 🧹 **Log Management**

### **Log Rotation**

#### **Docker Log Rotation**
```bash
# Configure Docker daemon log rotation
sudo vim /etc/docker/daemon.json
```

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

```bash
# Restart Docker
sudo systemctl restart docker
```

#### **System Log Rotation**
```bash
# Configure logrotate
sudo vim /etc/logrotate.d/hephaestus
```

```
/home/chris/backups/backup.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
}
```

### **Log Cleanup**

#### **Docker Log Cleanup**
```bash
# Clean up Docker logs
docker system prune -f

# Clean up specific container logs
docker logs [container_name] > /dev/null 2>&1
```

#### **System Log Cleanup**
```bash
# Clean up system logs
sudo journalctl --vacuum-time=7d

# Clean up old log files
sudo find /var/log -name "*.log" -mtime +30 -delete
```

## 🔒 **Security Maintenance**

### **Security Updates**

#### **System Security Updates**
```bash
# Check for security updates
sudo apt list --upgradable | grep -E "(security|critical)"

# Install security updates
sudo apt upgrade -y

# Check for known vulnerabilities
sudo apt audit
```

#### **Docker Security Updates**
```bash
# Update Docker images for security patches
docker compose -f docker-compose-infrastructure.yml pull

# Scan images for vulnerabilities
docker scout cves [image_name]
```

### **Security Audits**

#### **System Security Audit**
```bash
# Check for open ports
sudo netstat -tlnp
sudo ss -tlnp

# Check for suspicious processes
ps aux | grep -E "(nc|netcat|nmap|masscan)"

# Check for unauthorized users
cat /etc/passwd | grep -E "(bash|sh)$"
```

#### **Docker Security Audit**
```bash
# Check running containers
docker ps

# Check container security
docker inspect [container_name] | grep -E "(User|CapAdd|CapDrop)"

# Check for privileged containers
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Command}}" | grep privileged
```

### **Firewall Maintenance**

#### **UFW Firewall Updates**
```bash
# Check firewall status
sudo ufw status verbose

# Update firewall rules
sudo ufw allow from 192.168.50.0/24 to any port 22
sudo ufw allow from 192.168.50.0/24 to any port 80
sudo ufw allow from 192.168.50.0/24 to any port 443

# Reload firewall
sudo ufw reload
```

## 📊 **Performance Maintenance**

### **Resource Monitoring**

#### **System Resource Check**
```bash
# Check CPU usage
htop
top

# Check memory usage
free -h
cat /proc/meminfo

# Check disk usage
df -h
du -sh /var/lib/docker/volumes/*

# Check network usage
iftop
nethogs
```

#### **Docker Resource Check**
```bash
# Check container resource usage
docker stats --no-stream

# Check Docker system usage
docker system df

# Check for resource leaks
docker system events --since 1h
```

### **Performance Optimization**

#### **Database Optimization**
```bash
# PostgreSQL maintenance
docker compose -f docker-compose-infrastructure.yml exec postgres psql -U user -d database -c "VACUUM ANALYZE;"

# Check database size
docker compose -f docker-compose-infrastructure.yml exec postgres psql -U user -d database -c "SELECT pg_size_pretty(pg_database_size('database'));"

# Check slow queries
docker compose -f docker-compose-infrastructure.yml exec postgres psql -U user -d database -c "SELECT query, mean_time, calls FROM pg_stat_statements ORDER BY mean_time DESC LIMIT 10;"
```

#### **Docker Optimization**
```bash
# Clean up unused resources
docker system prune -a

# Clean up unused volumes
docker volume prune -f

# Clean up unused networks
docker network prune -f
```

## 🔧 **Hardware Maintenance**

### **Disk Maintenance**

#### **Disk Health Check**
```bash
# Check disk health
sudo smartctl -a /dev/sda

# Check disk usage
df -h
du -sh /home/chris/*

# Check for disk errors
sudo dmesg | grep -i error
```

#### **Disk Cleanup**
```bash
# Clean up package cache
sudo apt clean

# Clean up old kernels
sudo apt autoremove --purge

# Clean up old logs
sudo find /var/log -name "*.log" -mtime +30 -delete
```

### **Network Maintenance**

#### **Network Health Check**
```bash
# Check network connectivity
ping -c 3 8.8.8.8
ping -c 3 192.168.50.1

# Check DNS resolution
nslookup chrislawrence.ca
dig chrislawrence.ca

# Check network interfaces
ip addr show
ip route show
```

#### **Network Optimization**
```bash
# Check network statistics
cat /proc/net/dev

# Check for network errors
sudo netstat -i

# Check network connections
sudo netstat -tlnp
```

## 📋 **Maintenance Checklists**

### **Daily Maintenance Checklist**
- [ ] Check service status: `docker compose ps`
- [ ] Check system resources: `htop`, `df -h`, `free -h`
- [ ] Check backup completion: `ls -la /home/chris/backups/`
- [ ] Check security logs: `sudo journalctl -u ssh`
- [ ] Test public access: `curl -I https://chrislawrence.ca`

### **Weekly Maintenance Checklist**
- [ ] Update system packages: `sudo apt update && sudo apt upgrade -y`
- [ ] Check disk space: `df -h`
- [ ] Review logs: `docker compose logs --tail=100`
- [ ] Test backup procedures
- [ ] Check security alerts: `sudo journalctl -p err`

### **Monthly Maintenance Checklist**
- [ ] Update Docker images: `docker compose pull`
- [ ] Review configurations
- [ ] Security audit
- [ ] Performance optimization
- [ ] Documentation updates

### **Quarterly Maintenance Checklist**
- [ ] Full system backup
- [ ] Security updates
- [ ] Hardware maintenance
- [ ] Disaster recovery testing
- [ ] Capacity planning

## 🚨 **Maintenance Alerts**

### **Resource Alerts**
```bash
# Disk space alert
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
    echo "Warning: Disk usage is ${DISK_USAGE}%" | mail -s "Hephaestus Disk Alert" chris@chrislawrence.ca
fi

# Memory usage alert
MEM_USAGE=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
if [ $MEM_USAGE -gt 80 ]; then
    echo "Warning: Memory usage is ${MEM_USAGE}%" | mail -s "Hephaestus Memory Alert" chris@chrislawrence.ca
fi
```

### **Service Alerts**
```bash
# Service down alert
if ! docker compose -f docker-compose-infrastructure.yml ps | grep -q "Up"; then
    echo "Warning: Some services are down" | mail -s "Hephaestus Service Alert" chris@chrislawrence.ca
fi
```

## 📊 **Maintenance Monitoring**

### **Automated Maintenance Script**

Create `/home/chris/github/hephaestus-homelab/scripts/maintenance.sh`:

```bash
#!/bin/bash
# Hephaestus Homelab Maintenance Script

set -e

echo "=== Starting Hephaestus Maintenance ==="
echo "Date: $(date)"

# 1. System Updates
echo "Updating system packages..."
sudo apt update
sudo apt upgrade -y

# 2. Docker Updates
echo "Updating Docker images..."
docker compose -f docker-compose-infrastructure.yml pull

# 3. Log Cleanup
echo "Cleaning up logs..."
docker system prune -f
sudo journalctl --vacuum-time=7d

# 4. Disk Cleanup
echo "Cleaning up disk..."
sudo apt autoremove -y
sudo apt autoclean

# 5. Security Updates
echo "Checking for security updates..."
sudo apt list --upgradable | grep -E "(security|critical)"

# 6. Performance Check
echo "Checking system performance..."
df -h
free -h
docker stats --no-stream

echo "=== Maintenance Complete ==="
```

### **Schedule Maintenance**

#### **Daily Maintenance**
```bash
# Add to crontab
crontab -e

# Add this line for daily maintenance at 3 AM
0 3 * * * /home/chris/github/hephaestus-infra/scripts/maintenance.sh >> /home/chris/maintenance.log 2>&1
```

#### **Weekly Maintenance**
```bash
# Add to crontab for weekly maintenance
0 4 * * 0 /home/chris/github/hephaestus-infra/scripts/maintenance.sh --weekly >> /home/chris/maintenance.log 2>&1
```

## 🔄 **Update Procedures**

### **Safe Update Process**

#### **1. Pre-Update Checklist**
- [ ] Backup current configuration
- [ ] Test update in staging environment
- [ ] Schedule maintenance window
- [ ] Notify users of maintenance

#### **2. Update Process**
- [ ] Stop non-critical services
- [ ] Apply updates
- [ ] Restart services
- [ ] Verify functionality
- [ ] Test public access

#### **3. Post-Update Checklist**
- [ ] Verify all services are running
- [ ] Test critical functionality
- [ ] Check performance metrics
- [ ] Update documentation
- [ ] Notify users of completion

### **Rollback Procedures**

#### **Configuration Rollback**
```bash
# Restore from backup
cp /home/chris/backups/config/Caddyfile /home/chris/github/hephaestus-infra/proxy/
cp /home/chris/backups/config/.env /home/chris/github/hephaestus-infra/

# Restart services
docker compose -f docker-compose-infrastructure.yml restart
```

#### **Application Rollback**
```bash
# Revert to previous version
cd /home/chris/apps/[application]
git checkout [previous_commit]

# Rebuild and restart
docker compose -f docker-compose-homelab.yml up -d --build
```

## 📋 **Maintenance Logs**

### **Log Locations**
- **System logs**: `/var/log/syslog`
- **Docker logs**: `docker compose logs`
- **Application logs**: `docker compose logs [service]`
- **Maintenance logs**: `/home/chris/maintenance.log`
- **Backup logs**: `/home/chris/backups/backup.log`

### **Log Analysis**
```bash
# Check maintenance logs
tail -f /home/chris/maintenance.log

# Check for errors
grep -i error /home/chris/maintenance.log

# Check for warnings
grep -i warning /home/chris/maintenance.log
```

## Related Documentation

- [Incident Response](./incident-response.md) - Troubleshooting procedures
- [Backup & Recovery](./backup-recovery.md) - Data protection procedures
- [Service Dependencies](./dependencies.md) - Service relationship mapping
- [Performance Monitoring](./performance.md) - System optimization
- [Deployment Guide](./deployment.md) - Service deployment procedures

---

**Last Updated**: $(date)
**Maintenance Version**: 1.0
**Compatible With**: Ubuntu Server 24.04 LTS, Docker Engine 27.x
