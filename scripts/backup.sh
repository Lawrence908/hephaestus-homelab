#!/bin/bash

################################################################################
# Hephaestus Homelab Backup Script
# 
# Backs up Docker volumes, configurations, and application data
# Run manually or via cron job
#
# Usage: ./scripts/backup.sh
# Cron:  0 2 * * * /home/chris/github/hephaestus-homelab/scripts/backup.sh
################################################################################

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="${BACKUP_DESTINATION:-/mnt/backup/hephaestus}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="hephaestus_backup_${TIMESTAMP}"
TEMP_BACKUP="/tmp/${BACKUP_NAME}"
RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-30}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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

# Check if running as user with docker access
check_permissions() {
    if ! docker ps &> /dev/null; then
        log_error "Cannot access Docker. Make sure you're in the docker group or run with appropriate permissions."
        exit 1
    fi
}

# Create backup directories
create_backup_dirs() {
    log_info "Creating backup directories..."
    mkdir -p "$TEMP_BACKUP"/{volumes,configs,apps}
    mkdir -p "$BACKUP_DIR"
}

# Backup Docker volumes
backup_volumes() {
    log_info "Backing up Docker volumes..."
    
    local volumes=(
        "portainer_data"
        "uptime-kuma_data"
        "grafana_data"
        "prometheus_data"
        "caddy_data"
        "caddy_config"
        "capitolscope_db_data"
    )
    
    for volume in "${volumes[@]}"; do
        if docker volume inspect "$volume" &> /dev/null; then
            log_info "  - Backing up volume: $volume"
            docker run --rm \
                -v "${volume}:/data:ro" \
                -v "${TEMP_BACKUP}/volumes:/backup" \
                alpine \
                tar czf "/backup/${volume}.tar.gz" -C /data .
        else
            log_warn "  - Volume $volume does not exist, skipping"
        fi
    done
}

# Backup configuration files
backup_configs() {
    log_info "Backing up configuration files..."
    
    cd "$PROJECT_DIR"
    
    # Backup compose and configs (exclude node_modules, __pycache__, etc.)
    tar czf "${TEMP_BACKUP}/configs/compose-configs.tar.gz" \
        --exclude='node_modules' \
        --exclude='__pycache__' \
        --exclude='*.pyc' \
        --exclude='.git' \
        --exclude='data' \
        --exclude='*.log' \
        docker-compose.yml \
        proxy/ \
        grafana-stack/ \
        .gitignore \
        2>/dev/null || log_warn "Some config files might be missing"
    
    # Backup .env separately (encrypted)
    if [ -f ".env" ]; then
        log_info "  - Backing up .env file (will be encrypted if GPG available)"
        if command -v gpg &> /dev/null; then
            gpg --batch --yes --passphrase "${BACKUP_ENCRYPTION_KEY:-hephaestus}" \
                --symmetric --cipher-algo AES256 \
                -o "${TEMP_BACKUP}/configs/env.gpg" .env 2>/dev/null || \
                cp .env "${TEMP_BACKUP}/configs/env.backup"
        else
            cp .env "${TEMP_BACKUP}/configs/env.backup"
            log_warn "  - GPG not available, .env backed up unencrypted"
        fi
    fi
}

# Backup application data (databases, uploads, etc.)
backup_app_data() {
    log_info "Backing up application data..."
    
    # CapitolScope database dump
    if docker ps --format '{{.Names}}' | grep -q '^capitolscope-db$'; then
        log_info "  - Dumping CapitolScope database"
        docker exec capitolscope-db pg_dump -U "${POSTGRES_USER:-capitolscope}" \
            "${POSTGRES_DB:-capitolscope_production}" | \
            gzip > "${TEMP_BACKUP}/apps/capitolscope_db.sql.gz"
    fi
    
    # Magic Pages API static/media files
    if [ -d "${MAGIC_PAGES_API_PATH:-/home/chris/apps/magic-pages-api}" ]; then
        local mp_path="${MAGIC_PAGES_API_PATH:-/home/chris/apps/magic-pages-api}"
        if [ -d "$mp_path/static" ] || [ -d "$mp_path/media" ]; then
            log_info "  - Backing up Magic Pages static/media files"
            tar czf "${TEMP_BACKUP}/apps/magic-pages-media.tar.gz" \
                -C "$mp_path" \
                --exclude='*.pyc' \
                --exclude='__pycache__' \
                static/ media/ 2>/dev/null || true
        fi
    fi
}

# Create final backup archive
create_final_archive() {
    log_info "Creating final backup archive..."
    
    cd /tmp
    tar czf "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz" "$BACKUP_NAME"
    
    # Calculate size
    local size=$(du -h "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz" | cut -f1)
    log_info "Backup created: ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz (${size})"
}

# Cleanup old backups
cleanup_old_backups() {
    log_info "Cleaning up old backups (keeping last ${RETENTION_DAYS} days)..."
    
    find "$BACKUP_DIR" -name "hephaestus_backup_*.tar.gz" -type f -mtime +${RETENTION_DAYS} -delete
    
    local remaining=$(find "$BACKUP_DIR" -name "hephaestus_backup_*.tar.gz" -type f | wc -l)
    log_info "Remaining backups: $remaining"
}

# Cleanup temporary files
cleanup_temp() {
    log_info "Cleaning up temporary files..."
    rm -rf "$TEMP_BACKUP"
}

# Send notification (optional)
send_notification() {
    local status=$1
    local message=$2
    
    # Discord webhook (if configured)
    if [ -n "${DISCORD_WEBHOOK_URL:-}" ]; then
        curl -H "Content-Type: application/json" \
             -X POST \
             -d "{\"content\": \"🔧 **Hephaestus Backup ${status}**\n${message}\"}" \
             "${DISCORD_WEBHOOK_URL}" &> /dev/null || true
    fi
    
    # Email notification (if configured)
    if [ -n "${ALERT_EMAIL:-}" ] && command -v mail &> /dev/null; then
        echo "$message" | mail -s "Hephaestus Backup ${status}" "${ALERT_EMAIL}" || true
    fi
}

# Main backup process
main() {
    log_info "========================================="
    log_info "Starting Hephaestus Homelab Backup"
    log_info "========================================="
    
    # Check permissions
    check_permissions
    
    # Load environment variables
    if [ -f "${PROJECT_DIR}/.env" ]; then
        set -a
        source "${PROJECT_DIR}/.env"
        set +a
    fi
    
    # Create directories
    create_backup_dirs
    
    # Perform backups
    backup_volumes
    backup_configs
    backup_app_data
    
    # Create final archive
    create_final_archive
    
    # Cleanup
    cleanup_old_backups
    cleanup_temp
    
    log_info "========================================="
    log_info "Backup completed successfully!"
    log_info "Location: ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"
    log_info "========================================="
    
    # Send success notification
    send_notification "Success" "Backup completed successfully at $(date)"
}

# Error handler
trap 'log_error "Backup failed at line $LINENO"; cleanup_temp; send_notification "Failed" "Backup failed at line $LINENO"; exit 1' ERR

# Run main function
main "$@"

