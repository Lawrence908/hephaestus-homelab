# Storage Upgrade: 16TB Seagate HDD Setup

## Overview
Adding a 16TB Seagate HDD to the Hephaestus homelab for media storage, databases, and application data.

## Hardware Specifications
- **Drive**: Seagate 16TB HDD (3.5")
- **Mount Point**: `/mnt/storage`
- **Device**: `/dev/sdb1` (assuming /dev/sda is current SSD)
- **Filesystem**: ext4
- **Purpose**: Data storage, databases, media files

## Storage Layout Strategy

### Directory Structure
```
/mnt/storage/
├── databases/                 # Database data directories
│   ├── postgres/             # PostgreSQL databases
│   ├── redis/                # Redis data
│   ├── mongodb/              # MongoDB data
│   └── mysql/                # MySQL databases (if needed)
├── media/                    # Media files and uploads
│   ├── magicpages/           # Magic Pages media
│   ├── portfolio/            # Portfolio assets
│   ├── capitolscope/         # CapitolScope uploads
│   └── schedshare/           # SchedShare files
├── app-data/                 # Application persistent data
│   ├── magicpages/           # App-specific data
│   ├── capitolscope/         # CapitolScope data
│   └── schedshare/           # SchedShare data
├── backups/                  # Automated backups
│   ├── databases/            # Database backups
│   ├── media/                # Media backups
│   └── system/               # System backups
└── logs/                     # Application logs
    ├── magicpages/
    ├── capitolscope/
    └── schedshare/
```

## Installation Commands

### 1. Partition and Format the Drive
```bash
# List available drives
lsblk

# Create partition (assuming /dev/sdb is the new drive)
sudo fdisk /dev/sdb
# In fdisk: n (new), p (primary), 1 (partition), enter (default start), enter (default end), w (write)

# Format with ext4
sudo mkfs.ext4 /dev/sdb1

# Create mount point
sudo mkdir -p /mnt/storage

# Mount the drive
sudo mount /dev/sdb1 /mnt/storage

# Set proper permissions
sudo chown -R chris:chris /mnt/storage
sudo chmod 755 /mnt/storage
```

### 2. Make Mount Permanent
```bash
# Get UUID of the new drive
sudo blkid /dev/sdb1

# Add to /etc/fstab (replace UUID with actual value)
echo "UUID=your-uuid-here /mnt/storage ext4 defaults 0 2" | sudo tee -a /etc/fstab

# Test mount
sudo umount /mnt/storage
sudo mount -a
```

### 3. Create Directory Structure
```bash
# Create main directories
sudo mkdir -p /mnt/storage/{databases,media,app-data,backups,logs}

# Create subdirectories
sudo mkdir -p /mnt/storage/databases/{postgres,redis,mongodb,mysql}
sudo mkdir -p /mnt/storage/media/{magicpages,portfolio,capitolscope,schedshare}
sudo mkdir -p /mnt/storage/app-data/{magicpages,capitolscope,schedshare}
sudo mkdir -p /mnt/storage/backups/{databases,media,system}
sudo mkdir -p /mnt/storage/logs/{magicpages,capitolscope,schedshare}

# Set permissions
sudo chown -R chris:chris /mnt/storage
sudo chmod -R 755 /mnt/storage
```

## Docker Volume Configuration

### Updated Docker Compose Structure
```yaml
# Example for Magic Pages API
services:
  magicpages-api:
    image: your-magicpages-api:latest
    volumes:
      - /mnt/storage/databases/postgres:/var/lib/postgresql/data
      - /mnt/storage/media/magicpages:/app/media
      - /mnt/storage/app-data/magicpages:/app/data
      - /mnt/storage/logs/magicpages:/app/logs
    environment:
      - DATABASE_URL=postgresql://user:pass@postgres:5432/magicpages
      - MEDIA_ROOT=/app/media
      - DATA_ROOT=/app/data

  postgres:
    image: postgres:15
    volumes:
      - /mnt/storage/databases/postgres:/var/lib/postgresql/data
    environment:
      - POSTGRES_DB=magicpages
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
```

## Backup Strategy

### Automated Backup Script
```bash
#!/bin/bash
# /home/chris/github/hephaestus-homelab/scripts/backup-storage.sh

BACKUP_DIR="/mnt/storage/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Database backups
docker exec postgres pg_dump -U user magicpages > $BACKUP_DIR/databases/magicpages_$DATE.sql
docker exec redis redis-cli BGSAVE

# Media backup (rsync to preserve permissions)
rsync -av /mnt/storage/media/ $BACKUP_DIR/media/

# App data backup
rsync -av /mnt/storage/app-data/ $BACKUP_DIR/app-data/

# Cleanup old backups (keep 30 days)
find $BACKUP_DIR -name "*.sql" -mtime +30 -delete
```

### Cron Job for Automated Backups
```bash
# Add to crontab
0 2 * * * /home/chris/github/hephaestus-homelab/scripts/backup-storage.sh
```

## Performance Considerations

### 1. Database Optimization
- Use the HDD for data storage only
- Keep database WAL files on SSD for performance
- Consider SSD caching for frequently accessed data

### 2. Media Storage
- Perfect for large media files
- Consider CDN for frequently accessed static assets
- Implement proper file organization

### 3. Monitoring
```bash
# Monitor disk usage
df -h /mnt/storage

# Monitor I/O
iostat -x 1

# Check disk health
sudo smartctl -a /dev/sdb
```

## Security Considerations

### 1. Permissions
```bash
# Set restrictive permissions for sensitive data
sudo chmod 700 /mnt/storage/databases
sudo chmod 755 /mnt/storage/media
sudo chmod 750 /mnt/storage/app-data
```

### 2. Backup Encryption
```bash
# Encrypt sensitive backups
gpg --symmetric --cipher-algo AES256 /mnt/storage/backups/databases/
```

## Integration with Existing Setup

### 1. Update Docker Compose Files
- Modify existing `docker-compose-infrastructure.yml`
- Add new volume mounts for databases
- Update environment variables

### 2. Update Documentation
- Add new mount points to `SERVER_CONTEXT.md`
- Update backup procedures
- Document new storage layout

### 3. Monitoring Integration
- Add disk usage monitoring to Grafana
- Set up alerts for disk space
- Monitor I/O performance

## Expected Benefits

1. **Massive Storage**: 16TB for unlimited growth
2. **Performance**: SSD for containers, HDD for data
3. **Organization**: Clear separation of concerns
4. **Backup**: Centralized backup location
5. **Scalability**: Room for many more services

## Next Steps

1. **Install the drive** (physical installation)
2. **Run the setup commands** above
3. **Update Docker Compose** files
4. **Test the setup** with a small database
5. **Set up monitoring** and alerts
6. **Implement backup strategy**

---

**Estimated Setup Time**: 2-3 hours  
**Storage Capacity**: 16TB  
**Expected Performance**: Good for data storage, excellent for capacity