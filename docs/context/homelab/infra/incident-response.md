# Hephaestus Homelab - Incident Response & Troubleshooting

## Overview

This document provides step-by-step procedures for diagnosing and resolving common issues in the Hephaestus Homelab infrastructure. It serves as a quick reference for troubleshooting and incident response.

## 🚨 **Emergency Procedures**

### **Critical Service Down**
When core services are unavailable:

#### 1. **Immediate Assessment**
```bash
# Check overall system status
docker compose -f docker-compose-infrastructure.yml ps
docker stats --no-stream

# Check system resources
df -h
free -h
uptime
```

#### 2. **Network Connectivity**
```bash
# Test network connectivity
ping -c 3 8.8.8.8
ping -c 3 192.168.50.1
nslookup chrislawrence.ca

# Check Docker network
docker network inspect homelab-web
```

#### 3. **Service Health Checks**
```bash
# Test critical services
curl -I http://localhost:80  # Caddy
curl -I http://localhost:9000  # Portainer
curl -I http://localhost:3001  # Uptime Kuma
curl -I http://localhost:3000  # Grafana
```

### **Complete System Failure**
If the entire system is unresponsive:

#### 1. **Physical Access**
- Check power and network connections
- Verify server is powered on
- Check for hardware issues (fans, lights, beeps)

#### 2. **Boot Issues**
```bash
# If system won't boot
# Boot from USB and check:
sudo fsck /dev/sda1  # Check filesystem
sudo mount /dev/sda1 /mnt
sudo chroot /mnt
```

#### 3. **Network Issues**
```bash
# Check network configuration
ip addr show
ip route show
sudo systemctl status systemd-networkd
sudo netplan apply
```

## 🔧 **Service-Specific Troubleshooting**

### **Caddy (Reverse Proxy) Issues**

#### **Caddy Won't Start**
```bash
# Check Caddy status
docker compose -f docker-compose-infrastructure.yml ps caddy
docker compose -f docker-compose-infrastructure.yml logs caddy

# Validate Caddyfile
docker compose -f docker-compose-infrastructure.yml exec caddy caddy validate --config /etc/caddy/Caddyfile

# Common fixes
docker compose -f docker-compose-infrastructure.yml restart caddy
docker compose -f docker-compose-infrastructure.yml down caddy
docker compose -f docker-compose-infrastructure.yml up -d caddy
```

#### **502 Bad Gateway Errors**
```bash
# Check if upstream services are running
docker compose -f docker-compose-infrastructure.yml ps

# Test upstream connectivity
docker exec -it caddy sh -lc 'curl -I http://portfolio:5000/'
docker exec -it caddy sh -lc 'curl -I http://magic-pages-api:8000/'

# Check Caddy logs for routing issues
docker compose -f docker-compose-infrastructure.yml logs caddy | grep -E "(502|503|upstream)"
```

#### **SSL Certificate Issues**
```bash
# Check certificate status
docker exec -it caddy caddy list-certificates

# Force certificate renewal
docker exec -it caddy caddy reload --config /etc/caddy/Caddyfile
```

### **Cloudflare Tunnel Issues**

#### **Tunnel Connection Problems**
```bash
# Check tunnel status
sudo systemctl status cloudflared
sudo journalctl -u cloudflared -f

# Test tunnel connectivity
cloudflared tunnel info 3a9f1023-0d6c-49ff-900d-32403e4309f8

# Restart tunnel
sudo systemctl restart cloudflared
```

#### **DNS Resolution Issues**
```bash
# Test DNS resolution
dig chrislawrence.ca
nslookup chrislawrence.ca

# Check DNS propagation
# Use: https://dnschecker.org/
```

#### **Tunnel Configuration Issues**
```bash
# Validate tunnel config
cloudflared tunnel --config ~/.cloudflared/config.yml validate

# Test tunnel locally
cloudflared tunnel --config ~/.cloudflared/config.yml run
```

### **Database Issues**

#### **PostgreSQL Connection Problems**
```bash
# Check database status
docker compose -f docker-compose-infrastructure.yml ps postgres
docker compose -f docker-compose-infrastructure.yml logs postgres

# Test database connection
docker compose -f docker-compose-infrastructure.yml exec postgres psql -U user -d database -c "SELECT 1;"

# Check database logs
docker compose -f docker-compose-infrastructure.yml logs postgres | grep -E "(ERROR|FATAL)"
```

#### **Database Performance Issues**
```bash
# Check database connections
docker compose -f docker-compose-infrastructure.yml exec postgres psql -U user -d database -c "SELECT count(*) FROM pg_stat_activity;"

# Check database size
docker compose -f docker-compose-infrastructure.yml exec postgres psql -U user -d database -c "SELECT pg_size_pretty(pg_database_size('database'));"

# Check slow queries
docker compose -f docker-compose-infrastructure.yml exec postgres psql -U user -d database -c "SELECT query, mean_time, calls FROM pg_stat_statements ORDER BY mean_time DESC LIMIT 10;"
```

### **Application Issues**

#### **Django Application Errors**
```bash
# Check application logs
docker compose -f docker-compose-infrastructure.yml logs magic-pages-api

# Test application health
curl -I http://localhost:8100/health/
curl -I http://localhost:8100/admin/

# Check database migrations
docker compose -f docker-compose-infrastructure.yml exec magic-pages-api python manage.py showmigrations

# Run database migrations
docker compose -f docker-compose-infrastructure.yml exec magic-pages-api python manage.py migrate
```

#### **FastAPI Application Errors**
```bash
# Check application logs
docker compose -f docker-compose-infrastructure.yml logs capitolscope

# Test application health
curl -I http://localhost:8120/health
curl -I http://localhost:8120/docs

# Check database migrations
docker compose -f docker-compose-infrastructure.yml exec capitolscope alembic current
docker compose -f docker-compose-infrastructure.yml exec capitolscope alembic upgrade head
```

#### **Flask Application Errors**
```bash
# Check application logs
docker compose -f docker-compose-infrastructure.yml logs portfolio
docker compose -f docker-compose-infrastructure.yml logs schedshare

# Test application health
curl -I http://localhost:8110/
curl -I http://localhost:8130/
```

## 🔍 **Diagnostic Commands**

### **System Diagnostics**
```bash
# System resource usage
htop
iotop
nethogs

# Disk usage
df -h
du -sh /var/lib/docker/volumes/*

# Memory usage
free -h
cat /proc/meminfo

# CPU usage
top
vmstat 1 5
```

### **Docker Diagnostics**
```bash
# Container resource usage
docker stats --no-stream

# Container logs
docker compose -f docker-compose-infrastructure.yml logs --tail=100 [service]

# Container inspection
docker inspect [container_name]

# Network inspection
docker network inspect homelab-web

# Volume inspection
docker volume inspect [volume_name]
```

### **Network Diagnostics**
```bash
# Network connectivity
ping -c 3 8.8.8.8
ping -c 3 192.168.50.1
ping -c 3 chrislawrence.ca

# Port scanning
nmap -p 80,443,3000,3001,9000,9090 localhost

# DNS resolution
dig chrislawrence.ca
nslookup chrislawrence.ca
```

## 🚨 **Common Error Messages & Solutions**

### **Docker Errors**

#### **"Cannot connect to the Docker daemon"**
```bash
# Restart Docker service
sudo systemctl restart docker
sudo systemctl status docker

# Check Docker daemon
sudo dockerd --debug
```

#### **"Port already in use"**
```bash
# Find process using port
sudo lsof -i :80
sudo lsof -i :443

# Kill process
sudo kill -9 [PID]

# Or change port in docker-compose.yml
```

#### **"Network not found"**
```bash
# Recreate network
docker network rm homelab-web
docker network create homelab-web
docker compose -f docker-compose-infrastructure.yml up -d
```

### **Application Errors**

#### **"Database connection failed"**
```bash
# Check database service
docker compose -f docker-compose-infrastructure.yml ps postgres

# Check database logs
docker compose -f docker-compose-infrastructure.yml logs postgres

# Test database connection
docker compose -f docker-compose-infrastructure.yml exec postgres psql -U user -d database
```

#### **"Module not found"**
```bash
# Rebuild container
docker compose -f docker-compose-infrastructure.yml build [service]
docker compose -f docker-compose-infrastructure.yml up -d [service]

# Check container logs
docker compose -f docker-compose-infrastructure.yml logs [service]
```

### **Network Errors**

#### **"Connection refused"**
```bash
# Check service is running
docker compose -f docker-compose-infrastructure.yml ps

# Check port is accessible
telnet localhost 80
telnet localhost 443

# Check firewall
sudo ufw status
sudo iptables -L
```

#### **"DNS resolution failed"**
```bash
# Check DNS configuration
cat /etc/resolv.conf

# Test DNS resolution
nslookup chrislawrence.ca
dig chrislawrence.ca

# Check network connectivity
ping -c 3 8.8.8.8
```

## 🔄 **Recovery Procedures**

### **Service Recovery**
```bash
# Restart specific service
docker compose -f docker-compose-infrastructure.yml restart [service]

# Recreate service
docker compose -f docker-compose-infrastructure.yml down [service]
docker compose -f docker-compose-infrastructure.yml up -d [service]

# Rebuild service
docker compose -f docker-compose-infrastructure.yml build [service]
docker compose -f docker-compose-infrastructure.yml up -d [service]
```

### **Network Recovery**
```bash
# Recreate Docker network
docker network rm homelab-web
docker network create homelab-web
docker compose -f docker-compose-infrastructure.yml up -d

# Restart networking
sudo systemctl restart systemd-networkd
sudo netplan apply
```

### **Database Recovery**
```bash
# Restart database
docker compose -f docker-compose-infrastructure.yml restart postgres

# Check database integrity
docker compose -f docker-compose-infrastructure.yml exec postgres psql -U user -d database -c "SELECT 1;"

# Restore from backup if needed
# (See backup-recovery.md for detailed procedures)
```

## 📞 **Escalation Procedures**

### **When to Escalate**
- Multiple services down simultaneously
- Data corruption or loss
- Security breach suspected
- Hardware failure
- Network infrastructure issues

### **Contact Information**
- **Primary**: chris@chrislawrence.ca
- **Backup**: [backup contact]
- **Emergency**: [emergency contact]

### **Information to Gather Before Escalating**
1. **System Status**: `docker compose ps`
2. **Resource Usage**: `docker stats --no-stream`
3. **Error Logs**: `docker compose logs [service]`
4. **Network Status**: `ping -c 3 8.8.8.8`
5. **Disk Space**: `df -h`
6. **Memory Usage**: `free -h`

## 🔧 **Prevention Measures**

### **Regular Health Checks**
```bash
# Daily health check script
#!/bin/bash
echo "=== Hephaestus Health Check ==="
echo "Date: $(date)"
echo "Uptime: $(uptime)"
echo "Disk Usage:"
df -h
echo "Memory Usage:"
free -h
echo "Docker Status:"
docker compose -f docker-compose-infrastructure.yml ps
echo "Network Connectivity:"
ping -c 1 8.8.8.8
echo "Service Health:"
curl -I http://localhost:80
curl -I http://localhost:9000
curl -I http://localhost:3001
```

### **Monitoring Setup**
- Configure Uptime Kuma monitors for all services
- Set up Grafana alerts for resource usage
- Configure Prometheus alerts for service health
- Set up log monitoring and alerting

## 📋 **Incident Response Checklist**

### **Initial Response**
- [ ] Assess overall system status
- [ ] Check critical services
- [ ] Verify network connectivity
- [ ] Check system resources
- [ ] Review recent changes

### **Diagnosis**
- [ ] Check service logs
- [ ] Test network connectivity
- [ ] Verify service dependencies
- [ ] Check for resource constraints
- [ ] Review configuration changes

### **Resolution**
- [ ] Apply appropriate fix
- [ ] Test service functionality
- [ ] Verify all services are running
- [ ] Test public access
- [ ] Monitor for recurrence

### **Post-Incident**
- [ ] Document incident details
- [ ] Update procedures if needed
- [ ] Review monitoring and alerting
- [ ] Schedule follow-up review

## Related Documentation

- [Backup & Recovery](./backup-recovery.md) - Data protection procedures
- [Maintenance Procedures](./maintenance.md) - Regular maintenance tasks
- [Service Dependencies](./dependencies.md) - Service relationship mapping
- [Performance Monitoring](./performance.md) - System optimization
- [Deployment Guide](./deployment.md) - Service deployment procedures

---

**Last Updated**: $(date)
**Incident Response Version**: 1.0
**Compatible With**: Docker Compose v2.0+, Docker Engine 27.x
