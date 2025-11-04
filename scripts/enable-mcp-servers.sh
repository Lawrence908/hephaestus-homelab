#!/bin/bash
# 🤖 MCP Server Enablement Script
# Enables MCP servers for Hephaestus homelab based on priority

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🤖 Hephaestus MCP Server Setup${NC}"
echo -e "${BLUE}================================${NC}\n"

# Function to enable servers
enable_servers() {
    local priority=$1
    shift
    local servers=("$@")
    
    echo -e "${YELLOW}Enabling Priority $priority servers...${NC}"
    for server in "${servers[@]}"; do
        echo -n "  - Enabling $server... "
        if docker mcp server enable "$server" &>/dev/null; then
            echo -e "${GREEN}✓${NC}"
        else
            echo -e "${RED}✗ (already enabled or error)${NC}"
        fi
    done
    echo ""
}

# Parse arguments
PRIORITY=${1:-all}

case $PRIORITY in
    1|essential)
        echo -e "${GREEN}Installing Priority 1: Core Infrastructure + Databases + Monitoring${NC}\n"
        enable_servers 1 \
            github dockerhub git filesystem desktop-commander \
            postgres mongodb redis \
            grafana
        ;;
    
    2|devops)
        echo -e "${GREEN}Installing Priority 2: DevOps & Web Automation${NC}\n"
        enable_servers 2 \
            openapi openapi-schema postman mcp-api-gateway node-code-sandbox \
            playwright puppeteer firecrawl fetch
        ;;
    
    3|productivity)
        echo -e "${GREEN}Installing Priority 3: Productivity + AI + Search${NC}\n"
        enable_servers 3 \
            notion obsidian linear slack markdownify context7 \
            stripe airtable-mcp-server \
            sequentialthinking memory wolfram-alpha \
            brave tavily wikipedia-mcp duckduckgo
        ;;
    
    4|extras)
        echo -e "${GREEN}Installing Priority 4: Data & Communication${NC}\n"
        enable_servers 4 \
            mcp-discord youtube_transcript nasdaq-data-link time apify-mcp-server google-maps waystation
        ;;
    
    all)
        echo -e "${GREEN}Installing ALL MCP servers (40 servers)${NC}\n"
        
        echo -e "${BLUE}Priority 1: Core Infrastructure${NC}"
        enable_servers 1 \
            github dockerhub git filesystem desktop-commander \
            postgres mongodb redis grafana
        
        echo -e "${BLUE}Priority 2: DevOps & Web Automation${NC}"
        enable_servers 2 \
            openapi openapi-schema postman mcp-api-gateway node-code-sandbox \
            playwright puppeteer firecrawl fetch
        
        echo -e "${BLUE}Priority 3: Productivity + AI + Search${NC}"
        enable_servers 3 \
            notion obsidian linear slack markdownify context7 \
            stripe airtable-mcp-server \
            sequentialthinking memory wolfram-alpha \
            brave tavily wikipedia-mcp duckduckgo
        
        echo -e "${BLUE}Priority 4: Data & Communication${NC}"
        enable_servers 4 \
            mcp-discord youtube_transcript nasdaq-data-link time apify-mcp-server google-maps waystation
        ;;
    
    magic-pages)
        echo -e "${GREEN}Installing MCP servers for Magic Pages project${NC}\n"
        enable_servers "Magic Pages" \
            stripe playwright puppeteer openapi postgres mongodb redis \
            github git filesystem desktop-commander
        ;;
    
    capitol-scope)
        echo -e "${GREEN}Installing MCP servers for CapitolScope project${NC}\n"
        enable_servers "CapitolScope" \
            nasdaq-data-link brave tavily youtube_transcript \
            postgres mongodb redis github git filesystem desktop-commander
        ;;
    
    help|--help|-h)
        echo "Usage: $0 [OPTION]"
        echo ""
        echo "Options:"
        echo "  all               Enable all 40 MCP servers (default)"
        echo "  1 | essential     Enable Priority 1: Core + Databases + Monitoring (9 servers)"
        echo "  2 | devops        Enable Priority 2: DevOps & Web Automation (9 servers)"
        echo "  3 | productivity  Enable Priority 3: Productivity + AI + Search (14 servers)"
        echo "  4 | extras        Enable Priority 4: Data & Communication (7 servers)"
        echo "  magic-pages       Enable servers for Magic Pages project"
        echo "  capitol-scope     Enable servers for CapitolScope project"
        echo "  help              Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0                    # Enable all servers"
        echo "  $0 essential          # Enable just core infrastructure"
        echo "  $0 1                  # Same as essential"
        echo "  $0 magic-pages        # Enable Magic Pages specific servers"
        exit 0
        ;;
    
    *)
        echo -e "${RED}Unknown option: $PRIORITY${NC}"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac

echo -e "${GREEN}✅ MCP Server setup complete!${NC}\n"
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Configure authentication for servers that need it:"
echo "     - GitHub: Set up OAuth token"
echo "     - Stripe: Add API key"
echo "     - Notion/Linear/Slack: Configure workspace access"
echo ""
echo "  2. Test integration with Cursor IDE"
echo ""
echo "  3. View enabled servers:"
echo "     docker mcp server list"
echo ""
echo "  4. Check MCP Gateway status:"
echo "     docker mcp gateway status"

