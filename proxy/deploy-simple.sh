#!/bin/bash

# Simple Caddy deployment with logging
# Avoids permission issues by letting Docker create the directories

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Simple Caddy Deployment with Logging ===${NC}"

# Check if Caddyfile has logging configuration
if grep -q "log {" Caddyfile; then
    echo -e "${GREEN}✓ Logging configuration found in Caddyfile${NC}"
else
    echo -e "${RED}✗ No logging configuration found in Caddyfile${NC}"
    exit 1
fi

# Deploy Caddy
echo -e "${GREEN}Deploying Caddy...${NC}"
docker compose up -d

# Wait for Caddy to start
echo -e "${GREEN}Waiting for Caddy to start...${NC}"
sleep 10

# Check if Caddy is running
if docker compose ps caddy | grep -q "Up"; then
    echo -e "${GREEN}✓ Caddy is running${NC}"
else
    echo -e "${RED}✗ Caddy failed to start${NC}"
    docker compose logs caddy
    exit 1
fi

# Wait for logs to be created
echo -e "${GREEN}Waiting for logs to be created...${NC}"
sleep 30

# Check if log files exist
if [[ -d "logs" ]]; then
    echo -e "${GREEN}✓ Logs directory created${NC}"
    ls -la logs/
else
    echo -e "${YELLOW}⚠ Logs directory not yet created${NC}"
fi

# Check if log files exist
if [[ -f "logs/caddy.json" ]]; then
    size=$(stat -f%z "logs/caddy.json" 2>/dev/null || stat -c%s "logs/caddy.json" 2>/dev/null || echo "0")
    echo -e "${GREEN}✓ Caddy logs created (${size} bytes)${NC}"
else
    echo -e "${YELLOW}⚠ Caddy logs not yet created${NC}"
fi

echo -e "\n${GREEN}=== Deployment Complete ===${NC}"
echo -e "Caddy is running with logging!"
echo -e "\n${YELLOW}Available commands:${NC}"
echo -e "  docker compose logs caddy     # View Caddy logs"
echo -e "  docker compose ps            # Check container status"
echo -e "  ls -la logs/                 # Check log files"
echo -e "  ./log-analyzer.sh            # Analyze logs (if available)"
echo -e "  ./log-filter.sh              # Filter logs (if available)"

echo -e "\n${BLUE}Logging is now configured and persistent!${NC}"

