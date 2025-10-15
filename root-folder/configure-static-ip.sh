#!/bin/bash

################################################################################
# Hephaestus Homelab - Static IP Configuration Script
# 
# Run this script when you get home and connect to your router
# This will set up a static IP for your homelab server
#
# Usage: ./configure-static-ip.sh
################################################################################

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# Get current network info
get_network_info() {
    log_step "Gathering current network information..."
    
    # Get current IP
    CURRENT_IP=$(ip route get 8.8.8.8 | awk '{print $7; exit}')
    log_info "Current IP: $CURRENT_IP"
    
    # Get interface name
    INTERFACE=$(ip route get 8.8.8.8 | awk '{print $5; exit}')
    log_info "Network interface: $INTERFACE"
    
    # Get gateway
    GATEWAY=$(ip route | grep default | awk '{print $3}' | head -n1)
    log_info "Gateway: $GATEWAY"
    
    # Get DNS servers
    DNS_SERVERS=$(systemd-resolve --status | grep "DNS Servers" | awk '{print $3, $4}' | head -n1)
    log_info "DNS Servers: $DNS_SERVERS"
    
    # Get subnet
    SUBNET=$(ip route | grep "$INTERFACE" | grep -v default | awk '{print $1}' | head -n1)
    log_info "Subnet: $SUBNET"
}

# Create netplan configuration
create_netplan_config() {
    log_step "Creating static IP configuration..."
    
    # Extract network prefix from current IP
    NETWORK_PREFIX=$(echo "$CURRENT_IP" | cut -d. -f1-3)
    STATIC_IP="${NETWORK_PREFIX}.100"  # Use .100 for homelab server
    
    log_info "Proposed static IP: $STATIC_IP"
    
    # Create netplan config
    sudo tee /etc/netplan/01-static-ip.yaml << EOF
network:
  version: 2
  ethernets:
    $INTERFACE:
      dhcp4: false
      addresses:
        - $STATIC_IP/24
      gateway4: $GATEWAY
      nameservers:
        addresses: [8.8.8.8, 1.1.1.1, $DNS_SERVERS]
EOF

    log_info "Netplan configuration created at /etc/netplan/01-static-ip.yaml"
    log_info "Static IP will be: $STATIC_IP"
}

# Test configuration
test_configuration() {
    log_step "Testing netplan configuration..."
    
    if sudo netplan try --timeout=10; then
        log_info "Configuration test successful!"
        return 0
    else
        log_error "Configuration test failed!"
        return 1
    fi
}

# Apply configuration
apply_configuration() {
    log_step "Applying static IP configuration..."
    
    sudo netplan apply
    log_info "Static IP configuration applied!"
    
    # Wait for network to stabilize
    sleep 5
    
    # Verify new IP
    NEW_IP=$(ip route get 8.8.8.8 | awk '{print $7; exit}')
    log_info "New IP address: $NEW_IP"
    
    if [ "$NEW_IP" = "$STATIC_IP" ]; then
        log_info "✅ Static IP configuration successful!"
    else
        log_warn "IP address may still be changing. Check in a few minutes."
    fi
}

# Update router DHCP reservation (instructions)
show_router_instructions() {
    log_step "Router Configuration Instructions"
    
    echo -e "${YELLOW}IMPORTANT: Configure your router's DHCP reservation${NC}"
    echo
    echo "To prevent IP conflicts, you should reserve this IP in your router:"
    echo "  • Static IP: $STATIC_IP"
    echo "  • MAC Address: $(cat /sys/class/net/$INTERFACE/address)"
    echo
    echo "Router settings to configure:"
    echo "  1. Login to your router admin panel"
    echo "  2. Find 'DHCP Reservations' or 'Static DHCP'"
    echo "  3. Add reservation for MAC: $(cat /sys/class/net/$INTERFACE/address)"
    echo "  4. Reserve IP: $STATIC_IP"
    echo "  5. Save and reboot router if needed"
    echo
    echo "Common router admin URLs:"
    echo "  • 192.168.1.1 (most common)"
    echo "  • 192.168.0.1"
    echo "  • 10.0.0.1"
    echo
}

# Update Cloudflare tunnel config if needed
update_tunnel_config() {
    log_step "Checking if Cloudflare tunnel needs updates..."
    
    # Check if tunnel is running
    if systemctl is-active --quiet cloudflared; then
        log_info "Cloudflare tunnel is running - no changes needed"
        log_info "Your domains will continue to work:"
        echo "  • https://hephaestus.chrislawrence.ca"
        echo "  • https://uptime.chrislawrence.ca"
        echo "  • https://grafana.chrislawrence.ca"
    else
        log_warn "Cloudflare tunnel not running. Start it with:"
        echo "  sudo systemctl start cloudflared"
    fi
}

# Create backup of current config
backup_current_config() {
    log_step "Backing up current network configuration..."
    
    # Backup current netplan configs
    sudo cp -r /etc/netplan /etc/netplan.backup.$(date +%Y%m%d_%H%M%S)
    log_info "Current configuration backed up to /etc/netplan.backup.*"
}

# Main function
main() {
    log_info "========================================="
    log_info "Hephaestus Homelab Static IP Setup"
    log_info "========================================="
    echo
    
    # Check if running as root
    if [ "$EUID" -eq 0 ]; then
        log_error "Don't run this script as root. Run as regular user with sudo access."
        exit 1
    fi
    
    # Check if netplan is available
    if ! command -v netplan &> /dev/null; then
        log_error "netplan not available. This script is for Ubuntu 18.04+"
        exit 1
    fi
    
    # Get network information
    get_network_info
    echo
    
    # Confirm with user
    read -p "Do you want to proceed with static IP configuration? [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Configuration cancelled."
        exit 0
    fi
    
    # Backup current config
    backup_current_config
    
    # Create netplan config
    create_netplan_config
    echo
    
    # Test configuration
    if test_configuration; then
        # Apply configuration
        apply_configuration
        echo
        
        # Show router instructions
        show_router_instructions
        
        # Update tunnel info
        update_tunnel_config
        
        log_info "========================================="
        log_info "Static IP configuration complete!"
        log_info "========================================="
        echo
        log_info "Your homelab server is now accessible at:"
        echo "  • Static IP: $STATIC_IP"
        echo "  • Cloudflare domains: https://hephaestus.chrislawrence.ca"
        echo
        log_warn "Remember to configure DHCP reservation in your router!"
        
    else
        log_error "Configuration test failed. Reverting to DHCP..."
        sudo netplan apply
        log_info "Reverted to DHCP configuration."
        exit 1
    fi
}

# Error handler
trap 'log_error "Script failed at line $LINENO"; exit 1' ERR

# Run main function
main "$@"


