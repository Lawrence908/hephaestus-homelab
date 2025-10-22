# Hephaestus Homelab - Backup & Recovery Procedures

## Overview

This document outlines comprehensive backup and recovery procedures for the Hephaestus Homelab infrastructure, including data protection, disaster recovery, and business continuity planning.

## 🎯 **Backup Strategy**

### **Backup Tiers**

#### **Tier 1: Critical Data (Daily)**
- Application databases (PostgreSQL, Redis)
- Application data volumes
- Configuration files
- SSL certificates

#### **Tier 2: System Configuration (Weekly)**
- Docker Compose files
- Environment variables
- Caddy configuration
- Cloudflare tunnel configuration

#### **Tier 3: Full System (Monthly)**
- Complete system image
- All Docker volumes
- System configuration
- Log files

### **Backup Locations**
- **Local**: `/home/chris/backups/`
- **Remote**: Cloud storage (AWS S3, Google Drive, etc.)
- **Offsite**: External drive or cloud provider

## 📦 **Backup Procedures**

### **Automated Backup Script**

Create `/home/chris/github/hephaestus-homelab/scripts/backup.sh`:

```bash
#!/bin/bash
# Hephaestus Homelab Backup Script

set -e

# Configuration
BACKUP_DIR="/home/chris/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="hephaestus_backup_${DATE}"
BACKUP_PATH="${BACKUP_DIR}/${BACKUP_NAME}"

# Create backup directory
mkdir -p "${BACKUP_PATH}"

echo "=== Starting Hephaestus Backup ==="
echo "Date: $(date)"
echo "Backup Path: ${BACKUP_PATH}"

# 1. Database Backups
echo "Backing up databases..."
mkdir -p "${BACKUP_PATH}/databases"

# PostgreSQL databases
docker compose -f docker-compose-infrastructure.yml exec -T postgres pg_dump -U user -d database > "${BACKUP_PATH}/databases/postgres_${DATE}.sql"

# Redis backup
docker compose -f docker-compose-infrastructure.yml exec -T redis redis-cli BGSAVE
docker cp $(docker compose -f docker-compose-infrastructure.yml ps -q redis):/data/dump.rdb "${BACKUP_PATH}/databases/redis_${DATE}.rdb"

# 2. Docker Volumes
echo "Backing up Docker volumes..."
mkdir -p "${BACKUP_PATH}/volumes"

# List all volumes
docker volume ls --format "{{.Name}}" | while read volume; do
    echo "Backing up volume: ${volume}"
    docker run --rm -v "${volume}":/data -v "${BACKUP_PATH}/volumes":/backup alpine tar czf "/backup/${volume}_${DATE}.tar.gz" -C /data .
done

# 3. Configuration Files
echo "Backing up configuration files..."
mkdir -p "${BACKUP_PATH}/config"

# Docker Compose files
cp -r /home/chris/github/hephaestus-homelab/*.yml "${BACKUP_PATH}/config/"
cp -r /home/chris/github/hephaestus-homelab/proxy/ "${BACKUP_PATH}/config/"
cp -r /home/chris/github/hephaestus-homelab/grafana-stack/ "${BACKUP_PATH}/config/"

# Environment files
cp /home/chris/github/hephaestus-homelab/.env "${BACKUP_PATH}/config/"

# Caddy configuration
cp /home/chris/github/hephaestus-homelab/proxy/Caddyfile "${BACKUP_PATH}/config/"

# Cloudflare tunnel configuration
cp ~/.cloudflared/config.yml "${BACKUP_PATH}/config/"
cp ~/.cloudflared/*.json "${BACKUP_PATH}/config/" 2>/dev/null || true

# 4. Application Data
echo "Backing up application data..."
mkdir -p "${BACKUP_PATH}/applications"

# Magic Pages data
if [ -d "/home/chris/apps/magic-pages-api" ]; then
    cp -r /home/chris/apps/magic-pages-api/ "${BACKUP_PATH}/applications/"
fi

# CapitolScope data
if [ -d "/home/chris/apps/capitolscope" ]; then
    cp -r /home/chris/apps/capitolscope/ "${BACKUP_PATH}/applications/"
fi

# SchedShare data
if [ -d "/home/chris/apps/schedshare" ]; then
    cp -r /home/chris/apps/schedshare/ "${BACKUP_PATH}/applications/"
fi

# Portfolio data
if [ -d "/home/chris/apps/portfolio" ]; then
    cp -r /home/chris/apps/portfolio/ "${BACKUP_PATH}/applications/"
fi

# 5. System Configuration
echo "Backing up system configuration..."
mkdir -p "${BACKUP_PATH}/system"

# System configuration
sudo cp -r /etc/ "${BACKUP_PATH}/system/etc/"
sudo cp -r /var/lib/docker/ "${BACKUP_PATH}/system/docker/"

# 6. Create backup manifest
echo "Creating backup manifest..."
cat > "${BACKUP_PATH}/manifest.txt" << EOF
Hephaestus Homelab Backup
Date: $(date)
Backup Name: ${BACKUP_NAME}
Backup Path: ${BACKUP_PATH}

Contents:
- Databases: postgres_${DATE}.sql, redis_${DATE}.rdb
- Volumes: $(ls "${BACKUP_PATH}/volumes" | wc -l) volume backups
- Configuration: Docker Compose files, Caddyfile, Cloudflare config
- Applications: $(ls "${BACKUP_PATH}/applications" | wc -l) application directories
- System: /etc, /var/lib/docker

Backup Size: $(du -sh "${BACKUP_PATH}" | cut -f1)
EOF

# 7. Compress backup
echo "Compressing backup..."
cd "${BACKUP_DIR}"
tar czf "${BACKUP_NAME}.tar.gz" "${BACKUP_NAME}"
rm -rf "${BACKUP_NAME}"

echo "=== Backup Complete ==="
echo "Backup file: ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"
echo "Size: $(du -sh "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz" | cut -f1)"
```

### **Make Script Executable**
```bash
chmod +x /home/chris/github/hephaestus-homelab/scripts/backup.sh
```

### **Automated Backup Schedule**

#### **Daily Backups (Critical Data)**
```bash
# Add to crontab
crontab -e

# Add this line for daily backups at 2 AM
0 2 * * * /home/chris/github/hephaestus-homelab/scripts/backup.sh >> /home/chris/backups/backup.log 2>&1
```

#### **Weekly Backups (Full System)**
```bash
# Add to crontab for weekly full backups
0 3 * * 0 /home/chris/github/hephaestus-homelab/scripts/backup.sh --full >> /home/chris/backups/backup.log 2>&1
```

## 🔄 **Recovery Procedures**

### **Database Recovery**

#### **PostgreSQL Recovery**
```bash
# Stop application services
docker compose -f docker-compose-infrastructure.yml stop magic-pages-api capitolscope

# Restore database
docker compose -f docker-compose-infrastructure.yml exec -T postgres psql -U user -d database < /home/chris/backups/databases/postgres_YYYYMMDD_HHMMSS.sql

# Restart services
docker compose -f docker-compose-infrastructure.yml start magic-pages-api capitolscope
```

#### **Redis Recovery**
```bash
# Stop Redis
docker compose -f docker-compose-infrastructure.yml stop redis

# Restore Redis data
docker cp /home/chris/backups/databases/redis_YYYYMMDD_HHMMSS.rdb $(docker compose -f docker-compose-infrastructure.yml ps -q redis):/data/dump.rdb

# Restart Redis
docker compose -f docker-compose-infrastructure.yml start redis
```

### **Volume Recovery**

#### **Restore Docker Volume**
```bash
# Stop services using the volume
docker compose -f docker-compose-infrastructure.yml stop [service]

# Remove existing volume
docker volume rm [volume_name]

# Restore volume from backup
docker run --rm -v [volume_name]:/data -v /home/chris/backups/volumes:/backup alpine tar xzf "/backup/[volume_name]_YYYYMMDD_HHMMSS.tar.gz" -C /data

# Restart services
docker compose -f docker-compose-infrastructure.yml start [service]
```

### **Configuration Recovery**

#### **Restore Configuration Files**
```bash
# Restore Docker Compose files
cp -r /home/chris/backups/config/*.yml /home/chris/github/hephaestus-homelab/
cp -r /home/chris/backups/config/proxy/ /home/chris/github/hephaestus-homelab/
cp -r /home/chris/backups/config/grafana-stack/ /home/chris/github/hephaestus-homelab/

# Restore environment file
cp /home/chris/backups/config/.env /home/chris/github/hephaestus-homelab/

# Restore Cloudflare configuration
cp /home/chris/backups/config/config.yml ~/.cloudflared/
cp /home/chris/backups/config/*.json ~/.cloudflared/ 2>/dev/null || true
```

### **Application Recovery**

#### **Restore Application Data**
```bash
# Restore application directories
cp -r /home/chris/backups/applications/magic-pages-api/ /home/chris/apps/
cp -r /home/chris/backups/applications/capitolscope/ /home/chris/apps/
cp -r /home/chris/backups/applications/schedshare/ /home/chris/apps/
cp -r /home/chris/backups/applications/portfolio/ /home/chris/apps/

# Rebuild and restart applications
cd /home/chris/apps/magic-pages-api
docker compose -f docker-compose-homelab.yml up -d --build
```

## 🚨 **Disaster Recovery**

### **Complete System Recovery**

#### **1. Hardware Replacement**
```bash
# Install Ubuntu Server 24.04 LTS
# Follow setup.md procedures
# Restore from backup
```

#### **2. Restore from Backup**
```bash
# Extract backup
cd /home/chris/backups
tar xzf hephaestus_backup_YYYYMMDD_HHMMSS.tar.gz

# Restore configuration
cp -r hephaestus_backup_YYYYMMDD_HHMMSS/config/* /home/chris/github/hephaestus-homelab/

# Restore applications
cp -r hephaestus_backup_YYYYMMDD_HHMMSS/applications/* /home/chris/apps/

# Restore Docker volumes
# (See volume recovery procedures above)

# Restore databases
# (See database recovery procedures above)
```

#### **3. Verify Recovery**
```bash
# Check all services are running
docker compose -f docker-compose-infrastructure.yml ps

# Test critical services
curl -I http://localhost:80
curl -I http://localhost:9000
curl -I http://localhost:3001

# Test public access
curl -I https://chrislawrence.ca
curl -I https://chrislawrence.ca/portfolio
```

## 🔍 **Backup Verification**

### **Backup Integrity Checks**

#### **Verify Backup Contents**
```bash
# List backup contents
tar -tzf /home/chris/backups/hephaestus_backup_YYYYMMDD_HHMMSS.tar.gz

# Check backup size
ls -lh /home/chris/backups/hephaestus_backup_YYYYMMDD_HHMMSS.tar.gz

# Verify database backups
file /home/chris/backups/databases/postgres_YYYYMMDD_HHMMSS.sql
file /home/chris/backups/databases/redis_YYYYMMDD_HHMMSS.rdb
```

#### **Test Recovery Procedures**
```bash
# Test database recovery in test environment
# Test volume recovery in test environment
# Test configuration recovery in test environment
```

### **Backup Monitoring**

#### **Backup Success Notifications**
```bash
# Add to backup script
if [ $? -eq 0 ]; then
    echo "Backup completed successfully at $(date)" | mail -s "Hephaestus Backup Success" chris@chrislawrence.ca
else
    echo "Backup failed at $(date)" | mail -s "Hephaestus Backup Failure" chris@chrislawrence.ca
fi
```

#### **Backup Size Monitoring**
```bash
# Check backup sizes
du -sh /home/chris/backups/*

# Alert if backup size is unusual
BACKUP_SIZE=$(du -s /home/chris/backups/hephaestus_backup_$(date +%Y%m%d)*.tar.gz | cut -f1)
if [ $BACKUP_SIZE -lt 1000000 ]; then  # Less than 1GB
    echo "Warning: Backup size is unusually small: ${BACKUP_SIZE}KB" | mail -s "Hephaestus Backup Warning" chris@chrislawrence.ca
fi
```

## 📊 **Backup Retention Policy**

### **Retention Schedule**
- **Daily backups**: Keep for 7 days
- **Weekly backups**: Keep for 4 weeks
- **Monthly backups**: Keep for 12 months
- **Yearly backups**: Keep indefinitely

### **Cleanup Script**
```bash
#!/bin/bash
# Backup cleanup script

BACKUP_DIR="/home/chris/backups"
DATE=$(date +%Y%m%d)

# Remove backups older than 7 days
find "${BACKUP_DIR}" -name "hephaestus_backup_*.tar.gz" -mtime +7 -delete

# Remove daily backups older than 4 weeks
find "${BACKUP_DIR}" -name "hephaestus_backup_*_daily.tar.gz" -mtime +28 -delete

# Remove weekly backups older than 12 months
find "${BACKUP_DIR}" -name "hephaestus_backup_*_weekly.tar.gz" -mtime +365 -delete

echo "Backup cleanup completed at $(date)"
```

## 🔐 **Backup Security**

### **Encryption**
```bash
# Encrypt backups before storage
gpg --symmetric --cipher-algo AES256 /home/chris/backups/hephaestus_backup_YYYYMMDD_HHMMSS.tar.gz

# Decrypt when needed
gpg --decrypt /home/chris/backups/hephaestus_backup_YYYYMMDD_HHMMSS.tar.gz.gpg > /home/chris/backups/hephaestus_backup_YYYYMMDD_HHMMSS.tar.gz
```

### **Access Control**
```bash
# Set proper permissions
chmod 600 /home/chris/backups/*
chown chris:chris /home/chris/backups/*

# Secure backup directory
chmod 700 /home/chris/backups/
```

## 📋 **Backup Checklist**

### **Daily Backup Tasks**
- [ ] Verify backup script ran successfully
- [ ] Check backup log for errors
- [ ] Verify backup size is reasonable
- [ ] Test database backup integrity
- [ ] Check disk space for backups

### **Weekly Backup Tasks**
- [ ] Run full system backup
- [ ] Test recovery procedures
- [ ] Verify backup retention policy
- [ ] Check backup encryption
- [ ] Review backup logs

### **Monthly Backup Tasks**
- [ ] Test complete disaster recovery
- [ ] Verify all backup types are working
- [ ] Review backup retention policy
- [ ] Update backup procedures if needed
- [ ] Test backup restoration procedures

## 🚨 **Emergency Contacts**

### **Backup Issues**
- **Primary**: chris@chrislawrence.ca
- **Backup**: [backup contact]
- **Emergency**: [emergency contact]

### **Recovery Support**
- **Database Recovery**: [database expert]
- **System Recovery**: [system expert]
- **Network Recovery**: [network expert]

## Related Documentation

- [Incident Response](./incident-response.md) - Troubleshooting procedures
- [Maintenance Procedures](./maintenance.md) - Regular maintenance tasks
- [Service Dependencies](./dependencies.md) - Service relationship mapping
- [Deployment Guide](./deployment.md) - Service deployment procedures

---

**Last Updated**: $(date)
**Backup Version**: 1.0
**Compatible With**: Docker Compose v2.0+, Docker Engine 27.x
