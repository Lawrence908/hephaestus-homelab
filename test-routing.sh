#!/bin/bash

# Hephaestus Homelab - Routing & Proxy Testing Script
# Tests all 808X proxy ports and chrislawrence.ca subpaths

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BASIC_AUTH="admin:admin123"
LOCAL_IP="192.168.50.70"
DOMAIN="chrislawrence.ca"

echo -e "${BLUE}🚀 Hephaestus Homelab Routing Test${NC}"
echo "=================================================="

# Function to test endpoint
test_endpoint() {
    local url=$1
    local description=$2
    local expected_header=$3
    
    echo -n "Testing $description... "
    
    if curl -s -I -u "$BASIC_AUTH" "$url" > /tmp/curl_output 2>&1; then
        if [ -n "$expected_header" ]; then
            if grep -q "$expected_header" /tmp/curl_output; then
                echo -e "${RED}❌ Found $expected_header (should be removed)${NC}"
                return 1
            else
                echo -e "${GREEN}✅ $expected_header properly removed${NC}"
                return 0
            fi
        else
            if grep -q "200 OK\|302 Found\|301 Moved" /tmp/curl_output; then
                echo -e "${GREEN}✅ OK${NC}"
                return 0
            else
                echo -e "${RED}❌ Failed${NC}"
                cat /tmp/curl_output
                return 1
            fi
        fi
    else
        echo -e "${RED}❌ Connection failed${NC}"
        return 1
    fi
}

# Function to test CSP header
test_csp_header() {
    local url=$1
    local description=$2
    
    echo -n "Testing $description CSP... "
    
    if curl -s -I -u "$BASIC_AUTH" "$url" | grep -q "Content-Security-Policy.*frame-ancestors"; then
        echo -e "${GREEN}✅ CSP frame-ancestors found${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  CSP frame-ancestors not found${NC}"
        return 1
    fi
}

echo -e "\n${YELLOW}📊 Testing 808X Proxy Ports (Organizr Embedding)${NC}"
echo "=================================================="

# Test proxy ports for iframe compatibility
test_endpoint "http://$LOCAL_IP:8083" "Uptime Kuma Proxy (8083)" "X-Frame-Options"
test_csp_header "http://$LOCAL_IP:8083" "Uptime Kuma Proxy (8083)"

test_endpoint "http://$LOCAL_IP:8084" "Portainer Proxy (8084)" "X-Frame-Options"
test_csp_header "http://$LOCAL_IP:8084" "Portainer Proxy (8084)"

test_endpoint "http://$LOCAL_IP:8085" "Grafana Proxy (8085)" "X-Frame-Options"
test_csp_header "http://$LOCAL_IP:8085" "Grafana Proxy (8085)"

test_endpoint "http://$LOCAL_IP:8086" "Prometheus Proxy (8086)" "X-Frame-Options"
test_csp_header "http://$LOCAL_IP:8086" "Prometheus Proxy (8086)"

test_endpoint "http://$LOCAL_IP:8087" "cAdvisor Proxy (8087)" "X-Frame-Options"
test_csp_header "http://$LOCAL_IP:8087" "cAdvisor Proxy (8087)"

test_endpoint "http://$LOCAL_IP:8088" "Glances Proxy (8088)" "X-Frame-Options"
test_csp_header "http://$LOCAL_IP:8088" "Glances Proxy (8088)"

test_endpoint "http://$LOCAL_IP:8089" "IT-Tools Proxy (8089)" "X-Frame-Options"
test_csp_header "http://$LOCAL_IP:8089" "IT-Tools Proxy (8089)"

echo -e "\n${YELLOW}🌐 Testing Public Subpaths (chrislawrence.ca)${NC}"
echo "=================================================="

# Test public subpaths (these will fail until Cloudflare Tunnel is updated)
echo -e "${BLUE}Note: These tests require Cloudflare Tunnel configuration update${NC}"

test_endpoint "https://$DOMAIN/" "Root Redirect" ""
test_endpoint "https://$DOMAIN/dashboard/" "Dashboard Subpath" ""
test_endpoint "https://$DOMAIN/uptime/" "Uptime Subpath" ""
test_endpoint "https://$DOMAIN/docker/" "Docker Subpath" ""
test_endpoint "https://$DOMAIN/metrics/" "Metrics Subpath" ""
test_endpoint "https://$DOMAIN/prometheus/" "Prometheus Subpath" ""
test_endpoint "https://$DOMAIN/containers/" "Containers Subpath" ""
test_endpoint "https://$DOMAIN/system/" "System Subpath" ""
test_endpoint "https://$DOMAIN/tools/" "Tools Subpath" ""

echo -e "\n${YELLOW}🔧 Testing Direct Service Ports${NC}"
echo "=================================================="

# Test direct service access
test_endpoint "http://$LOCAL_IP:9000" "Portainer Direct" ""
test_endpoint "http://$LOCAL_IP:3001" "Uptime Kuma Direct" ""
test_endpoint "http://$LOCAL_IP:3000" "Grafana Direct" ""
test_endpoint "http://$LOCAL_IP:9090" "Prometheus Direct" ""
test_endpoint "http://$LOCAL_IP:8080" "cAdvisor Direct" ""
test_endpoint "http://$LOCAL_IP:61208" "Glances Direct" ""
test_endpoint "http://$LOCAL_IP:8081" "IT-Tools Direct" ""
test_endpoint "http://$LOCAL_IP:8082" "Organizr Direct" ""

echo -e "\n${BLUE}📋 Organizr Tab URLs (Use these in Organizr)${NC}"
echo "=================================================="
echo "✅ Uptime Kuma:  http://$LOCAL_IP:8083"
echo "✅ Portainer:    http://$LOCAL_IP:8084"
echo "✅ Grafana:      http://$LOCAL_IP:8085"
echo "✅ Prometheus:   http://$LOCAL_IP:8086"
echo "✅ cAdvisor:     http://$LOCAL_IP:8087"
echo "✅ Glances:      http://$LOCAL_IP:8088"
echo "✅ IT-Tools:     http://$LOCAL_IP:8089"

echo -e "\n${BLUE}🔄 Deployment Commands${NC}"
echo "=================================================="
echo "1. Restart Caddy:"
echo "   cd ~/github/hephaestus-infra"
echo "   docker compose -f docker-compose-infrastructure.yml restart caddy"
echo ""
echo "2. Update Cloudflare Tunnel:"
echo "   cp cloudflare-tunnel-config-template.yml ~/.cloudflared/config.yml"
echo "   sudo systemctl restart cloudflared"
echo ""
echo "3. Test Caddy configuration:"
echo "   docker compose -f docker-compose-infrastructure.yml exec caddy caddy validate --config /etc/caddy/Caddyfile"

echo -e "\n${GREEN}🎉 Test completed!${NC}"

# Cleanup
rm -f /tmp/curl_output
