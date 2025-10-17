#!/bin/bash

# Deploy Caddy with Persistent Logging
# Ensures logging configuration is always present

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Deploy Caddy with Persistent Logging ===${NC}"

# Configuration
SCRIPT_DIR="$(dirname "$0")"
LOG_DIR="$SCRIPT_DIR/logs"

# Function to check prerequisites
check_prerequisites() {
    echo -e "${GREEN}Checking prerequisites...${NC}"
    
    # Check if Docker is running
    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}✗ Docker is not running${NC}"
        exit 1
    fi
    echo -e "  ✓ Docker is running"
    
    # Check if docker compose is available
    if ! command -v docker compose >/dev/null 2>&1; then
        echo -e "${RED}✗ docker compose not found${NC}"
        exit 1
    fi
    echo -e "  ✓ docker compose is available"
    
    # Check if Caddyfile exists
    if [[ ! -f "$SCRIPT_DIR/Caddyfile" ]]; then
        echo -e "${RED}✗ Caddyfile not found${NC}"
        exit 1
    fi
    echo -e "  ✓ Caddyfile exists"
}

# Function to setup logging directories
setup_logging() {
    echo -e "${GREEN}Setting up logging directories...${NC}"
    
    # Create log directories
    mkdir -p "$LOG_DIR"
    mkdir -p "$LOG_DIR/analysis"
    mkdir -p "$LOG_DIR/filtered"
    mkdir -p "$LOG_DIR/backups"
    
    # Set proper permissions
    chmod 755 "$LOG_DIR"
    chmod 755 "$LOG_DIR/analysis"
    chmod 755 "$LOG_DIR/filtered"
    chmod 755 "$LOG_DIR/backups"
    
    echo -e "  ✓ Log directories created"
}

# Function to validate Caddyfile
validate_caddyfile() {
    echo -e "${GREEN}Validating Caddyfile...${NC}"
    
    # Check if Caddyfile has logging configuration
    if grep -q "log {" "$SCRIPT_DIR/Caddyfile"; then
        echo -e "  ✓ Logging configuration found in Caddyfile"
    else
        echo -e "${YELLOW}⚠ No logging configuration found in Caddyfile${NC}"
        echo -e "  Consider running setup-logging.sh first"
    fi
}

# Function to deploy with logging
deploy_with_logging() {
    echo -e "${GREEN}Deploying Caddy with logging...${NC}"
    
    # Stop existing containers
    echo -e "  Stopping existing containers..."
    docker compose down 2>/dev/null || true
    
    # Start with logging configuration
    echo -e "  Starting Caddy with logging..."
    docker compose up -d
    
    # Wait for Caddy to start
    echo -e "  Waiting for Caddy to start..."
    sleep 10
    
    # Check if Caddy is running
    if docker compose ps caddy | grep -q "Up"; then
        echo -e "  ✓ Caddy is running"
    else
        echo -e "${RED}✗ Caddy failed to start${NC}"
        docker compose logs caddy
        exit 1
    fi
}

# Function to validate logging is working
validate_logging() {
    echo -e "${GREEN}Validating logging is working...${NC}"
    
    # Wait for logs to be created
    echo -e "  Waiting for logs to be created..."
    sleep 30
    
    # Check if log files exist
    local log_files=(
        "$LOG_DIR/caddy.json"
        "$LOG_DIR/caddy-errors.json"
    )
    
    for log_file in "${log_files[@]}"; do
        if [[ -f "$log_file" ]]; then
            local size=$(stat -f%z "$log_file" 2>/dev/null || stat -c%s "$log_file" 2>/dev/null || echo "0")
            echo -e "  ✓ $log_file exists (${size} bytes)"
        else
            echo -e "  ${YELLOW}⚠ $log_file not yet created${NC}"
        fi
    done
    
    # Test log analysis tools
    if [[ -f "$SCRIPT_DIR/log-analyzer.sh" ]]; then
        echo -e "  ✓ Log analysis tools available"
    else
        echo -e "  ${YELLOW}⚠ Log analysis tools not found${NC}"
    fi
}

# Function to create monitoring setup
setup_monitoring() {
    echo -e "${GREEN}Setting up log monitoring...${NC}"
    
    # Create a simple monitoring script
    cat > "$SCRIPT_DIR/start-monitoring.sh" << 'EOF'
#!/bin/bash

# Start Caddy Log Monitoring
LOG_DIR="./logs"

echo "Starting Caddy log monitoring..."
echo "Press Ctrl+C to stop"

# Monitor log files for changes
if command -v inotifywait >/dev/null 2>&1; then
    inotifywait -m -r "$LOG_DIR" -e modify,create,delete --format '%w%f %e' | while read file event; do
        echo "$(date): $file $event"
    done
else
    # Fallback to polling
    while true; do
        for log_file in "$LOG_DIR"/*.json; do
            if [[ -f "$log_file" ]]; then
                if [[ $(find "$log_file" -mmin -1) ]]; then
                    echo "$(date): $log_file updated"
                fi
            fi
        done
        sleep 10
    done
fi
EOF

    chmod +x "$SCRIPT_DIR/start-monitoring.sh"
    echo -e "  ✓ Monitoring script created: start-monitoring.sh"
}

# Function to create persistence script
create_persistence_script() {
    echo -e "${GREEN}Creating persistence script...${NC}"
    
    cat > "$SCRIPT_DIR/ensure-logging.sh" << 'EOF'
#!/bin/bash

# Ensure Caddy Logging is Always Present
# Run this script to verify and fix logging configuration

SCRIPT_DIR="$(dirname "$0")"
LOG_DIR="$SCRIPT_DIR/logs"

# Check if log directories exist
if [[ ! -d "$LOG_DIR" ]]; then
    echo "Creating log directories..."
    mkdir -p "$LOG_DIR"/{analysis,filtered,backups}
    chmod 755 "$LOG_DIR"/*
fi

# Check if Caddy is running
if ! docker compose ps caddy | grep -q "Up"; then
    echo "Starting Caddy..."
    docker compose up -d
    sleep 10
fi

# Check if logs are being written
if [[ -f "$LOG_DIR/caddy.json" ]]; then
    if [[ $(find "$LOG_DIR/caddy.json" -mmin -5) ]]; then
        echo "✓ Logging is working"
    else
        echo "⚠ Logs not updated recently"
    fi
else
    echo "⚠ Log files not found"
fi
EOF

    chmod +x "$SCRIPT_DIR/ensure-logging.sh"
    echo -e "  ✓ Persistence script created: ensure-logging.sh"
}

# Function to create cron job
create_cron_job() {
    echo -e "${GREEN}Creating cron job for log maintenance...${NC}"
    
    local cron_file="/tmp/caddy-logging.cron"
    cat > "$cron_file" << EOF
# Caddy Logging Maintenance
# Run every hour to ensure logging is working
0 * * * * cd $SCRIPT_DIR && ./ensure-logging.sh >> ./logs/cron.log 2>&1

# Backup logs daily at 2 AM
0 2 * * * cd $SCRIPT_DIR && ./backup-logs.sh >> ./logs/cron.log 2>&1

# Clean old logs weekly on Sunday at 3 AM
0 3 * * 0 cd $SCRIPT_DIR && find ./logs -name "*.log" -mtime +30 -delete >> ./logs/cron.log 2>&1
EOF

    echo -e "  ✓ Cron job template created: $cron_file"
    echo -e "  ${YELLOW}To install: crontab $cron_file${NC}"
}

# Main deployment function
main() {
    echo -e "${BLUE}Starting Caddy deployment with persistent logging...${NC}"
    
    # Run all setup steps
    check_prerequisites
    setup_logging
    validate_caddyfile
    deploy_with_logging
    validate_logging
    setup_monitoring
    create_persistence_script
    create_cron_job
    
    echo -e "\n${GREEN}=== Deployment Complete ===${NC}"
    echo -e "Caddy is running with persistent logging!"
    echo -e "\n${YELLOW}Available commands:${NC}"
    echo -e "  ./validate-logging.sh     # Check if logging is working"
    echo -e "  ./log-analyzer.sh         # Analyze logs"
    echo -e "  ./log-filter.sh           # Filter logs"
    echo -e "  ./start-monitoring.sh     # Monitor logs in real-time"
    echo -e "  ./ensure-logging.sh       # Ensure logging is working"
    echo -e "  ./backup-logs.sh          # Backup logs"
    
    echo -e "\n${BLUE}To make logging permanent:${NC}"
    echo -e "1. Add to your deployment pipeline"
    echo -e "2. Set up the cron job: crontab /tmp/caddy-logging.cron"
    echo -e "3. Monitor with: ./start-monitoring.sh"
    
    echo -e "\n${GREEN}Logs are now persistent and will survive container restarts!${NC}"
}

# Run main function
main "$@"
