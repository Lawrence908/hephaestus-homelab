#!/bin/bash
# 🚀 Start Docker MCP Gateway for Network Access
# Allows Cursor IDE on remote PC to connect to MCP servers on Linux server

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting Docker MCP Gateway${NC}"
echo -e "${BLUE}===============================${NC}\n"

# Get server IP
SERVER_IP=$(hostname -I | awk '{print $1}')

echo -e "${YELLOW}Server IP: ${SERVER_IP}${NC}\n"

# Check if gateway is already running
if pgrep -f "docker mcp gateway run" > /dev/null; then
    echo -e "${YELLOW}⚠️  MCP Gateway is already running${NC}"
    echo "To stop it, run: pkill -f 'docker mcp gateway run'"
    exit 0
fi

# Source environment variables if available
if [ -f ~/.mcp_env ]; then
    echo -e "${GREEN}✓ Loading environment variables from ~/.mcp_env${NC}"
    set -a
    source ~/.mcp_env
    set +a
fi

# Start the gateway in the background
echo -e "${BLUE}Starting MCP Gateway on port 3100...${NC}"

# Run the gateway with network access
# Note: Using environment variables instead of Docker secrets
nohup docker mcp gateway run \
    --port 3100 \
    --enable-all-servers \
    --log-calls \
    > ~/.docker/mcp/gateway.log 2>&1 &

GATEWAY_PID=$!

echo -e "${GREEN}✓ MCP Gateway started (PID: $GATEWAY_PID)${NC}\n"

# Wait a moment for startup
sleep 3

# Check if it's running
if ps -p $GATEWAY_PID > /dev/null; then
    echo -e "${GREEN}✅ Gateway is running successfully!${NC}\n"
    
    echo -e "${BLUE}Connection Details:${NC}"
    echo -e "  ${YELLOW}Local:${NC}    http://localhost:3100"
    echo -e "  ${YELLOW}Network:${NC}  http://${SERVER_IP}:3100"
    echo ""
    
    echo -e "${BLUE}Cursor IDE Configuration (on your PC):${NC}"
    echo -e "  Edit: ${YELLOW}~/.cursor/mcp.json${NC}"
    echo ""
    echo -e '  {'
    echo -e '    "mcpServers": {'
    echo -e '      "hephaestus": {'
    echo -e '        "type": "http",'
    echo -e "        \"url\": \"http://${SERVER_IP}:3100\","
    echo -e '        "enabled": true'
    echo -e '      }'
    echo -e '    }'
    echo -e '  }'
    echo ""
    
    echo -e "${BLUE}Available Servers (40):${NC}"
    docker mcp server ls | tr ',' '\n' | head -10
    echo "  ... and more"
    echo ""
    
    echo -e "${BLUE}Gateway Logs:${NC}"
    echo -e "  View: ${YELLOW}tail -f ~/.docker/mcp/gateway.log${NC}"
    echo ""
    
    echo -e "${BLUE}Management Commands:${NC}"
    echo -e "  Stop:    ${YELLOW}pkill -f 'docker mcp gateway run'${NC}"
    echo -e "  Restart: ${YELLOW}$0${NC}"
    echo -e "  Status:  ${YELLOW}ps aux | grep 'docker mcp gateway'${NC}"
    echo ""
    
    echo -e "${GREEN}🎉 Ready to use in Cursor IDE!${NC}"
    
else
    echo -e "${RED}✗ Failed to start gateway${NC}"
    echo -e "Check logs: ${YELLOW}cat ~/.docker/mcp/gateway.log${NC}"
    exit 1
fi

