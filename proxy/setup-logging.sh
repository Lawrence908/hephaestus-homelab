#!/bin/bash

# Caddy Logging Setup Script
# Ensures logging configuration is always present and working

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Caddy Logging Setup ===${NC}"
echo "Setting up persistent logging configuration..."
echo

# Configuration
LOG_DIR="./logs"
ANALYSIS_DIR="$LOG_DIR/analysis"
FILTERED_DIR="$LOG_DIR/filtered"
SCRIPT_DIR="$(dirname "$0")"

# Function to create directory structure
create_directories() {
    echo -e "${GREEN}Creating log directory structure...${NC}"
    
    # Create main directories
    mkdir -p "$LOG_DIR"
    mkdir -p "$ANALYSIS_DIR"
    mkdir -p "$FILTERED_DIR"
    
    # Set proper permissions
    chmod 755 "$LOG_DIR"
    chmod 755 "$ANALYSIS_DIR"
    chmod 755 "$FILTERED_DIR"
    
    echo -e "  ✓ Created $LOG_DIR"
    echo -e "  ✓ Created $ANALYSIS_DIR"
    echo -e "  ✓ Created $FILTERED_DIR"
}

# Function to create log validation script
create_log_validator() {
    local validator_file="$SCRIPT_DIR/validate-logging.sh"
    
    cat > "$validator_file" << 'EOF'
#!/bin/bash

# Caddy Logging Validator
# Checks if logging is working correctly

LOG_DIR="./logs"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Caddy Logging Validator ===${NC}"

# Check if log directories exist
echo -e "${GREEN}Checking log directories...${NC}"
for dir in "$LOG_DIR" "$LOG_DIR/analysis" "$LOG_DIR/filtered"; do
    if [[ -d "$dir" ]]; then
        echo -e "  ✓ $dir exists"
    else
        echo -e "  ${RED}✗ $dir missing${NC}"
        exit 1
    fi
done

# Check if log files are being created
echo -e "\n${GREEN}Checking log file creation...${NC}"
sleep 2  # Wait for logs to be created

log_files=(
    "$LOG_DIR/caddy.json"
    "$LOG_DIR/caddy-errors.json"
    "$LOG_DIR/chrislawrence-ca.json"
    "$LOG_DIR/chrislawrence-ca-errors.json"
)

for log_file in "${log_files[@]}"; do
    if [[ -f "$log_file" ]]; then
        size=$(stat -f%z "$log_file" 2>/dev/null || stat -c%s "$log_file" 2>/dev/null || echo "0")
        echo -e "  ✓ $log_file exists (${size} bytes)"
    else
        echo -e "  ${YELLOW}⚠ $log_file not yet created (may take a few minutes)${NC}"
    fi
done

# Check if Caddy is running
echo -e "\n${GREEN}Checking Caddy status...${NC}"
if docker compose ps caddy | grep -q "Up"; then
    echo -e "  ✓ Caddy is running"
else
    echo -e "  ${RED}✗ Caddy is not running${NC}"
    exit 1
fi

# Test log analysis tools
echo -e "\n${GREEN}Testing log analysis tools...${NC}"
if [[ -f "./log-analyzer.sh" && -x "./log-analyzer.sh" ]]; then
    echo -e "  ✓ log-analyzer.sh is executable"
else
    echo -e "  ${RED}✗ log-analyzer.sh missing or not executable${NC}"
fi

if [[ -f "./log-filter.sh" && -x "./log-filter.sh" ]]; then
    echo -e "  ✓ log-filter.sh is executable"
else
    echo -e "  ${RED}✗ log-filter.sh missing or not executable${NC}"
fi

echo -e "\n${GREEN}Logging validation complete!${NC}"
EOF

    chmod +x "$validator_file"
    echo -e "  ✓ Created log validator: $validator_file"
}

# Function to create log monitoring service
create_log_monitor() {
    local monitor_file="$SCRIPT_DIR/monitor-logs.sh"
    
    cat > "$monitor_file" << 'EOF'
#!/bin/bash

# Caddy Log Monitor Service
# Monitors logs and ensures they're working

LOG_DIR="./logs"
CHECK_INTERVAL=60  # Check every minute

while true; do
    # Check if log files exist and are being written to
    for log_file in "$LOG_DIR"/*.json; do
        if [[ -f "$log_file" ]]; then
            # Check if file has been modified in the last 5 minutes
            if [[ $(find "$log_file" -mmin -5) ]]; then
                echo "$(date): $log_file is active"
            else
                echo "$(date): WARNING - $log_file not updated in 5 minutes"
            fi
        fi
    done
    
    sleep $CHECK_INTERVAL
done
EOF

    chmod +x "$monitor_file"
    echo -e "  ✓ Created log monitor: $monitor_file"
}

# Function to create backup script
create_backup_script() {
    local backup_file="$SCRIPT_DIR/backup-logs.sh"
    
    cat > "$backup_file" << 'EOF'
#!/bin/bash

# Caddy Log Backup Script
# Creates backups of log files

LOG_DIR="./logs"
BACKUP_DIR="./logs/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR"

echo "Creating log backup: $DATE"
tar -czf "$BACKUP_DIR/caddy-logs-$DATE.tar.gz" "$LOG_DIR"/*.json "$LOG_DIR"/*.log 2>/dev/null || true

# Keep only last 7 backups
ls -t "$BACKUP_DIR"/caddy-logs-*.tar.gz | tail -n +8 | xargs rm -f 2>/dev/null || true

echo "Backup created: $BACKUP_DIR/caddy-logs-$DATE.tar.gz"
EOF

    chmod +x "$backup_file"
    echo -e "  ✓ Created backup script: $backup_file"
}

# Function to create systemd service (if running on host)
create_systemd_service() {
    local service_file="/tmp/caddy-logging.service"
    
    cat > "$service_file" << EOF
[Unit]
Description=Caddy Logging Monitor
After=docker.service
Requires=docker.service

[Service]
Type=simple
User=chris
WorkingDirectory=$SCRIPT_DIR
ExecStart=$SCRIPT_DIR/monitor-logs.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

    echo -e "  ✓ Created systemd service template: $service_file"
    echo -e "  ${YELLOW}To install: sudo cp $service_file /etc/systemd/system/ && sudo systemctl enable caddy-logging${NC}"
}

# Function to create Docker health check
create_docker_healthcheck() {
    local healthcheck_file="$SCRIPT_DIR/docker-healthcheck.sh"
    
    cat > "$healthcheck_file" << 'EOF'
#!/bin/bash

# Docker health check for logging
LOG_DIR="./logs"

# Check if log directories exist
if [[ ! -d "$LOG_DIR" ]]; then
    echo "Log directory missing"
    exit 1
fi

# Check if Caddy is writing logs
if [[ -f "$LOG_DIR/caddy.json" ]]; then
    # Check if file has been modified in last 2 minutes
    if [[ $(find "$LOG_DIR/caddy.json" -mmin -2) ]]; then
        echo "Logging is working"
        exit 0
    else
        echo "Logs not being written"
        exit 1
    fi
else
    echo "Log files not found"
    exit 1
fi
EOF

    chmod +x "$healthcheck_file"
    echo -e "  ✓ Created Docker health check: $healthcheck_file"
}

# Main setup function
main() {
    echo -e "${GREEN}Setting up persistent Caddy logging...${NC}"
    
    # Create directory structure
    create_directories
    
    # Create utility scripts
    create_log_validator
    create_log_monitor
    create_backup_script
    create_docker_healthcheck
    
    # Create systemd service (optional)
    create_systemd_service
    
    echo -e "\n${GREEN}=== Setup Complete ===${NC}"
    echo -e "Log directories created in: $LOG_DIR"
    echo -e "Analysis tools available:"
    echo -e "  - ./validate-logging.sh    # Check if logging is working"
    echo -e "  - ./log-analyzer.sh        # Analyze logs"
    echo -e "  - ./log-filter.sh          # Filter logs"
    echo -e "  - ./monitor-logs.sh        # Monitor logs"
    echo -e "  - ./backup-logs.sh         # Backup logs"
    
    echo -e "\n${YELLOW}Next steps:${NC}"
    echo -e "1. Restart Caddy: docker compose restart caddy"
    echo -e "2. Validate logging: ./validate-logging.sh"
    echo -e "3. Monitor logs: ./monitor-logs.sh &"
    
    echo -e "\n${BLUE}To make logging permanent:${NC}"
    echo -e "1. Add to your deployment pipeline"
    echo -e "2. Set up log rotation in crontab"
    echo -e "3. Consider using the systemd service"
}

# Run main function
main "$@"

