# Caddy Logging Persistence Guide

This guide ensures that Caddy logging configuration is always present and working, even after restarts, updates, or deployments.

## 🎯 **Quick Start - Make Logging Permanent**

### **1. Initial Setup**
```bash
# Run the setup script to create all necessary directories and scripts
./setup-logging.sh

# Deploy with logging enabled
./deploy-with-logging.sh
```

### **2. Verify Logging is Working**
```bash
# Check if logging is working
./validate-logging.sh

# Monitor logs in real-time
./start-monitoring.sh
```

## 🔧 **Persistence Methods**

### **Method 1: Docker Compose Override (Recommended)**
```bash
# Deploy with logging persistence
docker compose -f docker-compose.yml -f logging-persistence.yml up -d

# This ensures logging is always configured
```

### **Method 2: Volume Mounts in Main Compose**
The main `docker-compose.yml` now includes:
```yaml
volumes:
  - ./logs:/data/logs  # This ensures logs persist
```

### **Method 3: Automated Maintenance**
```bash
# Set up cron job for automatic maintenance
crontab /tmp/caddy-logging.cron

# Or run manually
./ensure-logging.sh
```

## 📁 **Directory Structure**

```
proxy/
├── logs/                          # Main log directory (persistent)
│   ├── caddy.json                 # Global Caddy logs
│   ├── caddy-errors.json          # Global error logs
│   ├── chrislawrence-ca.json      # Main domain logs
│   ├── chrislawrence-ca-errors.json # Main domain errors
│   ├── chrislawrence-ca-access.log # Access logs
│   ├── analysis/                  # Log analysis output
│   ├── filtered/                  # Filtered logs
│   └── backups/                   # Log backups
├── Caddyfile                      # Caddy configuration (with logging)
├── docker-compose.yml             # Main compose file
├── logging-persistence.yml        # Logging override
├── setup-logging.sh              # Initial setup
├── deploy-with-logging.sh        # Deployment with logging
├── validate-logging.sh           # Validation script
├── log-analyzer.sh               # Log analysis
├── log-filter.sh                 # Log filtering
├── start-monitoring.sh           # Real-time monitoring
├── ensure-logging.sh             # Persistence check
└── backup-logs.sh                # Log backup
```

## 🚀 **Deployment Strategies**

### **Strategy 1: Always Use Logging Override**
```bash
# Always deploy with logging
docker compose -f docker-compose.yml -f logging-persistence.yml up -d
```

### **Strategy 2: Include in Main Compose**
The main `docker-compose.yml` now includes logging by default, so:
```bash
# Standard deployment includes logging
docker compose up -d
```

### **Strategy 3: Automated Deployment**
```bash
# Use the deployment script
./deploy-with-logging.sh
```

## 🔍 **Monitoring and Maintenance**

### **Real-time Monitoring**
```bash
# Monitor logs in real-time
./start-monitoring.sh

# Or use Docker
docker exec caddy-log-analyzer /usr/local/bin/log-analyzer.sh
```

### **Log Analysis**
```bash
# Analyze logs
./log-analyzer.sh

# Filter noisy logs
./log-filter.sh

# Check log health
./validate-logging.sh
```

### **Backup and Restore**
```bash
# Backup logs
./backup-logs.sh

# Restore from backup
tar -xzf logs/backups/caddy-logs-YYYYMMDD_HHMMSS.tar.gz
```

## 🛠️ **Troubleshooting**

### **Logs Not Being Created**
```bash
# Check if directories exist
ls -la logs/

# Check Caddy status
docker compose ps caddy

# Check Caddy logs
docker compose logs caddy
```

### **Logs Not Persisting**
```bash
# Check volume mounts
docker inspect caddy | grep -A 10 "Mounts"

# Verify directory permissions
ls -la logs/
```

### **Log Analysis Not Working**
```bash
# Check if tools are executable
ls -la *.sh

# Run validation
./validate-logging.sh
```

## 📊 **Log Rotation and Cleanup**

### **Automatic Rotation**
Logs are automatically rotated based on size:
- **Global logs**: 50MB max, 10 files kept
- **Error logs**: 10MB max, 20 files kept
- **Access logs**: 100MB max, 5 files kept

### **Manual Cleanup**
```bash
# Clean old logs (older than 30 days)
find logs/ -name "*.json" -mtime +30 -delete

# Clean old backups (older than 7 days)
find logs/backups/ -name "*.tar.gz" -mtime +7 -delete
```

## 🔄 **Automation and CI/CD**

### **GitHub Actions Example**
```yaml
name: Deploy with Logging
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy with logging
        run: |
          ./setup-logging.sh
          ./deploy-with-logging.sh
          ./validate-logging.sh
```

### **Cron Job for Maintenance**
```bash
# Add to crontab
0 * * * * cd /path/to/proxy && ./ensure-logging.sh
0 2 * * * cd /path/to/proxy && ./backup-logs.sh
```

## 🎛️ **Configuration Options**

### **Log Levels**
- `INFO`: General information (default)
- `WARN`: Warnings and potential issues
- `ERROR`: Critical errors only
- `DEBUG`: Detailed debugging (not recommended for production)

### **Log Formats**
- `json`: Structured JSON (recommended)
- `console`: Human-readable format
- `common_log`: Apache-style access logs

### **Output Destinations**
- `file`: Write to files (default)
- `stdout`: Write to console
- `stderr`: Write to error stream

## 📈 **Performance Considerations**

### **High Log Volume**
If logs are growing too quickly:
1. Increase log rotation frequency
2. Use log filtering to reduce noise
3. Consider adjusting log levels
4. Use separate log files for different services

### **Disk Space Management**
```bash
# Check disk usage
du -sh logs/

# Set up automatic cleanup
echo "0 3 * * 0 find logs/ -name '*.json' -mtime +30 -delete" | crontab -
```

## 🔒 **Security Considerations**

### **Log File Permissions**
```bash
# Set proper permissions
chmod 755 logs/
chmod 644 logs/*.json
chmod 644 logs/*.log
```

### **Sensitive Data**
- Logs may contain sensitive information
- Consider log sanitization for production
- Use proper access controls for log directories

## 📋 **Checklist for Persistence**

- [ ] Log directories created (`./logs/`)
- [ ] Caddyfile includes logging configuration
- [ ] Docker Compose includes log volume mounts
- [ ] Log analysis tools are executable
- [ ] Validation script passes
- [ ] Monitoring is working
- [ ] Backup script is functional
- [ ] Cron job is set up (optional)
- [ ] Documentation is updated

## 🆘 **Emergency Recovery**

### **If Logging Stops Working**
```bash
# Restart with logging
docker compose down
./setup-logging.sh
docker compose up -d
./validate-logging.sh
```

### **If Logs Are Lost**
```bash
# Restore from backup
tar -xzf logs/backups/caddy-logs-YYYYMMDD_HHMMSS.tar.gz

# Or start fresh
./setup-logging.sh
./deploy-with-logging.sh
```

## 📞 **Support**

If you encounter issues:
1. Run `./validate-logging.sh` to check status
2. Check `./logs/cron.log` for maintenance logs
3. Review Docker logs: `docker compose logs caddy`
4. Ensure all scripts are executable: `chmod +x *.sh`

---

**Remember**: Logging persistence is now built into your deployment process. The configuration will survive container restarts, updates, and redeployments as long as you use the provided scripts and configurations.

