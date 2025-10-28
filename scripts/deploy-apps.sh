#!/bin/bash

# Hephaestus Homelab - Application Deployment Script
# Deploys all applications in the correct order with proper error handling

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Application definitions
declare -A APPS=(
    ["portfolio"]="/home/chris/apps/portfolio"
    ["schedshare"]="/home/chris/apps/schedshare"
    ["capitolscope"]="/home/chris/apps/capitolscope"
    ["mongo-events"]="/home/chris/apps/eventsphere"
    ["magicpages"]="/home/chris/apps/magicpages"
    ["obsidian"]="/home/chris/apps/obsidian"
)

declare -A PORTS=(
    ["portfolio"]="8110"
    ["schedshare"]="8130"
    ["capitolscope"]="8120"
    ["mongo-events"]="8140"
    ["magicpages"]="8100"
    ["obsidian"]="8060"
)

declare -A URLS=(
    ["portfolio"]="https://portfolio.chrislawrence.ca"
    ["schedshare"]="https://schedshare.chrislawrence.ca"
    ["capitolscope"]="https://capitolscope.chrislawrence.ca"
    ["mongo-events"]="https://eventsphere.chrislawrence.ca"
    ["magicpages"]="https://magicpages-api.chrislawrence.ca"
    ["obsidian"]="https://dev.chrislawrence.ca/notes"
)

# Function to check if infrastructure is running
check_infrastructure() {
    log "Checking infrastructure services..."
    
    cd /home/chris/github/hephaestus-infra
    
    if ! docker compose -f docker-compose-infrastructure.yml ps | grep -q "Up"; then
        error "Infrastructure services are not running!"
        log "Starting infrastructure services..."
        docker compose -f docker-compose-infrastructure.yml up -d
        sleep 10
    fi
    
    success "Infrastructure services are running"
}

# Function to deploy a single application
deploy_app() {
    local app_name=$1
    local app_path=${APPS[$app_name]}
    local port=${PORTS[$app_name]}
    
    log "Deploying $app_name..."
    
    if [ ! -d "$app_path" ]; then
        error "Application directory not found: $app_path"
        return 1
    fi
    
    cd "$app_path"
    
    # Check if homelab compose file exists
    if [ ! -f "docker-compose-homelab.yml" ]; then
        error "docker-compose-homelab.yml not found for $app_name"
        return 1
    fi
    
    # Stop existing containers
    log "Stopping existing $app_name containers..."
    docker compose -f docker-compose-homelab.yml down --remove-orphans 2>/dev/null || true
    
    # Build and start
    log "Building and starting $app_name..."
    docker compose -f docker-compose-homelab.yml up -d --build
    
    # Wait for health check
    log "Waiting for $app_name to become healthy..."
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f -s "http://localhost:$port" > /dev/null 2>&1; then
            success "$app_name is healthy on port $port"
            return 0
        fi
        
        log "Attempt $attempt/$max_attempts - waiting for $app_name..."
        sleep 10
        ((attempt++))
    done
    
    error "$app_name failed to become healthy after $max_attempts attempts"
    return 1
}

# Function to test application access
test_app() {
    local app_name=$1
    local url=${URLS[$app_name]}
    
    log "Testing $app_name access..."
    
    if curl -f -s -I "$url" > /dev/null 2>&1; then
        success "$app_name is accessible at $url"
    else
        warning "$app_name may not be accessible at $url (check authentication)"
    fi
}

# Function to show status
show_status() {
    log "Application Status Summary:"
    echo
    printf "%-15s %-8s %-50s %-10s\n" "APPLICATION" "PORT" "URL" "STATUS"
    printf "%-15s %-8s %-50s %-10s\n" "----------" "----" "---" "------"
    
    for app in "${!APPS[@]}"; do
        local port=${PORTS[$app]}
        local url=${URLS[$app]}
        
        if curl -f -s "http://localhost:$port" > /dev/null 2>&1; then
            printf "%-15s %-8s %-50s ${GREEN}%-10s${NC}\n" "$app" "$port" "$url" "RUNNING"
        else
            printf "%-15s %-8s %-50s ${RED}%-10s${NC}\n" "$app" "$port" "$url" "DOWN"
        fi
    done
    echo
}

# Function to restart Caddy
restart_caddy() {
    log "Restarting Caddy to reload configuration..."
    cd /home/chris/github/hephaestus-infra
    docker compose -f docker-compose-infrastructure.yml restart caddy
    sleep 5
    success "Caddy restarted"
}

# Function to restart Cloudflare tunnel
restart_tunnel() {
    log "Restarting Cloudflare tunnel..."
    cd /home/chris/github/hephaestus-infra
    docker compose -f docker-compose-infrastructure.yml restart cloudflared
    sleep 5
    success "Cloudflare tunnel restarted"
}

# Main deployment function
deploy_all() {
    log "Starting deployment of all applications..."
    
    # Check infrastructure
    check_infrastructure
    
    # Deploy applications in order
    local deployment_order=("obsidian" "portfolio" "schedshare" "capitolscope" "mongo-events" "magicpages")
    
    for app in "${deployment_order[@]}"; do
        if deploy_app "$app"; then
            success "$app deployed successfully"
        else
            error "Failed to deploy $app"
            exit 1
        fi
        echo
    done
    
    # Restart services
    restart_caddy
    restart_tunnel
    
    # Wait for services to stabilize
    log "Waiting for services to stabilize..."
    sleep 15
    
    # Test applications
    log "Testing application access..."
    for app in "${deployment_order[@]}"; do
        test_app "$app"
    done
    
    echo
    success "All applications deployed successfully!"
    show_status
}

# Function to stop all applications
stop_all() {
    log "Stopping all applications..."
    
    for app in "${!APPS[@]}"; do
        local app_path=${APPS[$app]}
        log "Stopping $app..."
        cd "$app_path"
        docker compose -f docker-compose-homelab.yml down --remove-orphans 2>/dev/null || true
    done
    
    success "All applications stopped"
}

# Function to show help
show_help() {
    echo "Hephaestus Homelab - Application Deployment Script"
    echo
    echo "Usage: $0 [COMMAND] [APP_NAME]"
    echo
    echo "Commands:"
    echo "  deploy-all    Deploy all applications"
    echo "  deploy APP    Deploy specific application"
    echo "  stop-all      Stop all applications"
    echo "  stop APP      Stop specific application"
    echo "  status        Show application status"
    echo "  restart-caddy Restart Caddy reverse proxy"
    echo "  restart-tunnel Restart Cloudflare tunnel"
    echo "  help          Show this help message"
    echo
    echo "Available applications:"
    for app in "${!APPS[@]}"; do
        echo "  - $app (Port ${PORTS[$app]})"
    done
    echo
}

# Main script logic
case "${1:-help}" in
    "deploy-all")
        deploy_all
        ;;
    "deploy")
        if [ -z "$2" ]; then
            error "Please specify an application name"
            show_help
            exit 1
        fi
        if [ -z "${APPS[$2]}" ]; then
            error "Unknown application: $2"
            show_help
            exit 1
        fi
        check_infrastructure
        deploy_app "$2"
        restart_caddy
        test_app "$2"
        ;;
    "stop-all")
        stop_all
        ;;
    "stop")
        if [ -z "$2" ]; then
            error "Please specify an application name"
            show_help
            exit 1
        fi
        if [ -z "${APPS[$2]}" ]; then
            error "Unknown application: $2"
            show_help
            exit 1
        fi
        app_path=${APPS[$2]}
        log "Stopping $2..."
        cd "$app_path"
        docker compose -f docker-compose-homelab.yml down --remove-orphans
        success "$2 stopped"
        ;;
    "status")
        show_status
        ;;
    "restart-caddy")
        restart_caddy
        ;;
    "restart-tunnel")
        restart_tunnel
        ;;
    "help"|*)
        show_help
        ;;
esac
