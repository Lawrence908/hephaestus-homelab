#!/bin/bash

################################################################################
# Hephaestus Homelab Update Script
#
# Updates system packages, Docker images, and cleans up unused resources
# Can be run manually or via cron
#
# Usage: ./scripts/update.sh [--auto]
#        --auto : Non-interactive mode (auto-confirms prompts)
################################################################################

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
AUTO_MODE=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --auto)
            AUTO_MODE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--auto]"
            exit 1
            ;;
    esac
done

# Logging
log_info() {
    echo -e "${GREEN}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Confirmation prompt
confirm() {
    if [ "$AUTO_MODE" = true ]; then
        return 0
    fi
    
    local prompt="$1"
    read -p "${prompt} [y/N]: " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# Check permissions
check_permissions() {
    if ! docker ps &> /dev/null; then
        log_error "Cannot access Docker. Make sure you're in the docker group."
        exit 1
    fi
    
    if [ "$EUID" -eq 0 ]; then
        log_warn "Running as root. Consider running as regular user in docker group."
    fi
}

# Update system packages
update_system() {
    log_step "Updating system packages..."
    
    if ! confirm "Update system packages (apt update && upgrade)?"; then
        log_info "Skipping system update"
        return 0
    fi
    
    sudo apt update
    
    # Show upgradable packages
    local upgradable=$(apt list --upgradable 2>/dev/null | grep -c upgradable || echo "0")
    log_info "Upgradable packages: $upgradable"
    
    if [ "$upgradable" -gt 0 ]; then
        sudo apt upgrade -y
        log_info "System packages updated successfully"
    else
        log_info "System is already up to date"
    fi
}

# Update Docker images
update_docker_images() {
    log_step "Updating Docker images..."
    
    cd "$PROJECT_DIR"
    
    if ! confirm "Pull latest Docker images?"; then
        log_info "Skipping Docker image updates"
        return 0
    fi
    
    # Pull new images
    log_info "Pulling latest images..."
    docker compose pull
    
    # Restart services with new images
    if confirm "Restart services with updated images?"; then
        log_info "Restarting services..."
        docker compose up -d --remove-orphans
        log_info "Services restarted successfully"
    else
        log_warn "Services not restarted. Run 'docker compose up -d' manually to apply updates."
    fi
}

# Update Grafana stack
update_grafana_stack() {
    log_step "Updating Grafana monitoring stack..."
    
    cd "$PROJECT_DIR/grafana-stack"
    
    if ! confirm "Update Grafana stack?"; then
        log_info "Skipping Grafana stack update"
        return 0
    fi
    
    docker compose pull
    docker compose up -d --remove-orphans
    log_info "Grafana stack updated successfully"
    
    cd "$PROJECT_DIR"
}

# Prune unused Docker resources
cleanup_docker() {
    log_step "Cleaning up Docker resources..."
    
    # Show current usage
    log_info "Current Docker disk usage:"
    docker system df
    echo
    
    if ! confirm "Remove unused Docker images, containers, and networks?"; then
        log_info "Skipping Docker cleanup"
        return 0
    fi
    
    # Prune stopped containers
    log_info "Removing stopped containers..."
    docker container prune -f
    
    # Prune unused networks
    log_info "Removing unused networks..."
    docker network prune -f
    
    # Prune unused images
    log_info "Removing unused images..."
    docker image prune -a -f
    
    # Prune build cache
    log_info "Removing build cache..."
    docker builder prune -a -f
    
    # Show new usage
    echo
    log_info "Docker disk usage after cleanup:"
    docker system df
}

# Check container health
check_health() {
    log_step "Checking container health..."
    
    cd "$PROJECT_DIR"
    
    # List all containers with their status
    log_info "Container status:"
    docker compose ps
    
    # Check for unhealthy containers
    local unhealthy=$(docker compose ps --filter "health=unhealthy" --format "{{.Service}}" 2>/dev/null || true)
    
    if [ -n "$unhealthy" ]; then
        log_warn "Unhealthy containers detected: $unhealthy"
        
        if confirm "Restart unhealthy containers?"; then
            for service in $unhealthy; do
                log_info "Restarting $service..."
                docker compose restart "$service"
            done
        fi
    else
        log_info "All containers are healthy"
    fi
}

# Update Git repository
update_repo() {
    log_step "Updating Hephaestus homelab repository..."
    
    cd "$PROJECT_DIR"
    
    # Check if git repo
    if [ ! -d ".git" ]; then
        log_warn "Not a git repository. Skipping repo update."
        return 0
    fi
    
    if ! confirm "Pull latest changes from git?"; then
        log_info "Skipping repository update"
        return 0
    fi
    
    # Stash local changes if any
    if ! git diff-index --quiet HEAD --; then
        log_warn "Local changes detected. Stashing..."
        git stash
    fi
    
    # Pull latest changes
    local current_branch=$(git branch --show-current)
    log_info "Pulling latest changes from $current_branch..."
    
    if git pull origin "$current_branch"; then
        log_info "Repository updated successfully"
    else
        log_warn "Failed to pull changes. You may need to manually resolve conflicts."
    fi
}

# Check for security updates
check_security() {
    log_step "Checking for security updates..."
    
    # Check unattended-upgrades status
    if systemctl is-active --quiet unattended-upgrades; then
        log_info "Unattended-upgrades is active (automatic security updates enabled)"
    else
        log_warn "Unattended-upgrades is not active. Consider enabling automatic security updates."
        
        if confirm "Enable automatic security updates?"; then
            sudo apt install unattended-upgrades -y
            sudo dpkg-reconfigure -plow unattended-upgrades
        fi
    fi
    
    # Check for pending security updates
    local security_updates=$(apt list --upgradable 2>/dev/null | grep -i security | wc -l || echo "0")
    
    if [ "$security_updates" -gt 0 ]; then
        log_warn "Security updates available: $security_updates"
        
        if confirm "Install security updates now?"; then
            sudo apt upgrade -y
        fi
    else
        log_info "No pending security updates"
    fi
}

# Generate update report
generate_report() {
    log_step "Generating update report..."
    
    local report_file="/tmp/hephaestus_update_report_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "======================================"
        echo "Hephaestus Homelab Update Report"
        echo "Generated: $(date)"
        echo "======================================"
        echo
        echo "System Information:"
        echo "  OS: $(lsb_release -d | cut -f2-)"
        echo "  Kernel: $(uname -r)"
        echo "  Uptime: $(uptime -p)"
        echo
        echo "Docker Information:"
        docker --version
        docker compose version
        echo
        echo "Container Status:"
        docker compose ps --format "table"
        echo
        echo "Disk Usage:"
        df -h / | tail -n 1
        echo
        echo "Docker Disk Usage:"
        docker system df
        echo
        echo "======================================"
    } > "$report_file"
    
    log_info "Report saved to: $report_file"
    
    if confirm "Display report now?"; then
        cat "$report_file"
    fi
}

# Send notification
send_notification() {
    local status=$1
    local message=$2
    
    # Load environment variables if available
    if [ -f "${PROJECT_DIR}/.env" ]; then
        set -a
        source "${PROJECT_DIR}/.env"
        set +a
    fi
    
    # Discord webhook (if configured)
    if [ -n "${DISCORD_WEBHOOK_URL:-}" ]; then
        curl -H "Content-Type: application/json" \
             -X POST \
             -d "{\"content\": \"🔄 **Hephaestus Update ${status}**\n${message}\"}" \
             "${DISCORD_WEBHOOK_URL}" &> /dev/null || true
    fi
}

# Main update process
main() {
    log_info "========================================="
    log_info "Hephaestus Homelab Update Script"
    log_info "Mode: $([ "$AUTO_MODE" = true ] && echo "Automatic" || echo "Interactive")"
    log_info "========================================="
    echo
    
    # Check permissions
    check_permissions
    
    # Run update steps
    update_system
    echo
    
    update_repo
    echo
    
    update_docker_images
    echo
    
    update_grafana_stack
    echo
    
    cleanup_docker
    echo
    
    check_health
    echo
    
    check_security
    echo
    
    generate_report
    
    log_info "========================================="
    log_info "Update process completed!"
    log_info "========================================="
    
    # Send success notification
    send_notification "Complete" "Update process completed successfully at $(date)"
    
    # Suggest reboot if kernel was updated
    if [ -f /var/run/reboot-required ]; then
        log_warn "System reboot required (kernel update detected)"
        
        if confirm "Reboot system now?"; then
            log_info "Rebooting in 10 seconds... (Ctrl+C to cancel)"
            sleep 10
            sudo reboot
        else
            log_warn "Remember to reboot the system soon to apply kernel updates"
        fi
    fi
}

# Error handler
trap 'log_error "Update failed at line $LINENO"; send_notification "Failed" "Update failed at line $LINENO"; exit 1' ERR

# Run main function
main "$@"

