#!/bin/bash
# 🔐 MCP Authentication Configuration Script
# Interactive setup for MCP server authentication

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔐 MCP Authentication Configuration${NC}"
echo -e "${BLUE}====================================${NC}\n"

# Function to prompt for input
prompt_for_key() {
    local service=$1
    local var_name=$2
    local description=$3
    local priority=$4
    
    echo -e "\n${YELLOW}[$priority] $service${NC}"
    echo -e "   $description"
    read -p "   Enter API key (or press Enter to skip): " key
    
    if [ ! -z "$key" ]; then
        export "$var_name"="$key"
        echo -e "   ${GREEN}✓ Configured${NC}"
        echo "export $var_name=\"$key\"" >> ~/.mcp_env
        return 0
    else
        echo -e "   ${YELLOW}⊘ Skipped${NC}"
        return 1
    fi
}

# Create or reset env file
> ~/.mcp_env

echo -e "${BLUE}Step 1: OAuth Authentication${NC}"
echo -e "${BLUE}=============================${NC}\n"

# GitHub OAuth (most important)
echo -e "${YELLOW}[HIGH PRIORITY] GitHub OAuth${NC}"
echo "   This will open your browser for authorization..."
read -p "   Configure GitHub OAuth now? (y/N): " github_oauth

if [[ $github_oauth =~ ^[Yy]$ ]]; then
    if docker mcp oauth authorize github 2>&1; then
        echo -e "   ${GREEN}✓ GitHub OAuth configured${NC}"
    else
        echo -e "   ${RED}✗ GitHub OAuth failed${NC}"
        echo -e "   ${YELLOW}You can try again later: docker mcp oauth authorize github${NC}"
    fi
else
    echo -e "   ${YELLOW}⊘ Skipped - configure later with: docker mcp oauth authorize github${NC}"
fi

echo -e "\n${BLUE}Step 2: API Keys${NC}"
echo -e "${BLUE}================${NC}"

# High Priority
echo -e "\n${BLUE}HIGH PRIORITY (for active projects)${NC}"
prompt_for_key "Stripe" "STRIPE_API_KEY" "Payment processing for Magic Pages" "HIGH"
prompt_for_key "Grafana" "GRAFANA_API_TOKEN" "Homelab monitoring dashboards" "HIGH"

# Medium Priority
echo -e "\n${BLUE}MEDIUM PRIORITY (search & research)${NC}"
prompt_for_key "Brave Search" "BRAVE_API_KEY" "Web search capabilities" "MEDIUM"
prompt_for_key "Tavily" "TAVILY_API_KEY" "AI-optimized search" "MEDIUM"
prompt_for_key "Nasdaq Data Link" "NASDAQ_API_KEY" "Financial data for CapitolScope" "MEDIUM"

# Lower Priority
echo -e "\n${BLUE}LOWER PRIORITY (nice-to-have)${NC}"
prompt_for_key "Wolfram Alpha" "WOLFRAM_APP_ID" "Computational intelligence" "LOW"
prompt_for_key "Google Maps" "GOOGLE_MAPS_API_KEY" "Maps and geolocation" "LOW"
prompt_for_key "Airtable" "AIRTABLE_API_KEY" "Airtable database access" "LOW"

# Productivity tools
echo -e "\n${BLUE}PRODUCTIVITY TOOLS (if you use them)${NC}"
prompt_for_key "Notion" "NOTION_API_KEY" "Notion workspace integration" "OPTIONAL"
prompt_for_key "Linear" "LINEAR_API_KEY" "Linear project management" "OPTIONAL"
prompt_for_key "Slack" "SLACK_BOT_TOKEN" "Slack workspace access" "OPTIONAL"

echo -e "\n${BLUE}Step 3: Database Connections${NC}"
echo -e "${BLUE}=============================${NC}\n"

# Database connections (use defaults or customize)
echo -e "${YELLOW}Database Connection Strings${NC}"
echo "   Using local defaults (modify if needed)"

echo "export MONGODB_URI=\"mongodb://localhost:27017\"" >> ~/.mcp_env
echo "export POSTGRES_URI=\"postgresql://localhost:5432\"" >> ~/.mcp_env
echo "export REDIS_URL=\"redis://localhost:6379\"" >> ~/.mcp_env

read -p "   Use custom database URIs? (y/N): " custom_db

if [[ $custom_db =~ ^[Yy]$ ]]; then
    read -p "   MongoDB URI: " mongo_uri
    [ ! -z "$mongo_uri" ] && echo "export MONGODB_URI=\"$mongo_uri\"" >> ~/.mcp_env
    
    read -p "   PostgreSQL URI: " pg_uri
    [ ! -z "$pg_uri" ] && echo "export POSTGRES_URI=\"$pg_uri\"" >> ~/.mcp_env
    
    read -p "   Redis URL: " redis_url
    [ ! -z "$redis_url" ] && echo "export REDIS_URL=\"$redis_url\"" >> ~/.mcp_env
fi

echo -e "   ${GREEN}✓ Database connections configured${NC}"

# Grafana URL
echo "export GRAFANA_URL=\"http://grafana.local:3000\"" >> ~/.mcp_env

echo -e "\n${GREEN}✅ Configuration Complete!${NC}\n"

# Summary
echo -e "${BLUE}Summary${NC}"
echo -e "${BLUE}=======${NC}\n"

echo "Configuration saved to: ~/.mcp_env"
echo ""
echo "To use these settings in your current shell:"
echo -e "  ${YELLOW}source ~/.mcp_env${NC}"
echo ""
echo "To make permanent, add to ~/.bashrc:"
echo -e "  ${YELLOW}echo 'source ~/.mcp_env' >> ~/.bashrc${NC}"
echo ""
echo -e "${BLUE}For Docker compose (n8n), add to docker-compose.yml:${NC}"
echo "  environment:"
echo "    - GITHUB_TOKEN=\${GITHUB_TOKEN}"
echo "    - STRIPE_API_KEY=\${STRIPE_API_KEY}"
echo "    - (etc...)"
echo ""

echo -e "${BLUE}OAuth Status:${NC}"
docker mcp oauth ls

echo ""
echo -e "${BLUE}Enabled Servers:${NC}"
docker mcp server ls | tr ',' '\n' | head -10
echo "   ... (and $(docker mcp server ls | tr ',' '\n' | wc -l) more)"

echo ""
echo -e "${GREEN}Next Steps:${NC}"
echo "  1. Source the environment: ${YELLOW}source ~/.mcp_env${NC}"
echo "  2. Test in Cursor IDE: ${YELLOW}@mcp github list repositories${NC}"
echo "  3. Check documentation: ${YELLOW}/home/chris/github/hephaestus-infra/docs/${NC}"
echo ""
echo -e "${BLUE}Documentation:${NC}"
echo "  - MCP Master Guide: docs/MCP-MASTER-GUIDE.md"
echo "  - Authentication: docs/mcp-authentication-guide.md"
echo "  - Cursor Integration: docs/mcp-cursor-integration.md"
echo "  - n8n Integration: docs/mcp-n8n-integration.md"
echo ""

# Offer to source now
read -p "Source ~/.mcp_env in current shell now? (Y/n): " source_now
if [[ ! $source_now =~ ^[Nn]$ ]]; then
    set +e
    source ~/.mcp_env
    set -e
    echo -e "${GREEN}✓ Environment variables loaded${NC}"
fi

echo ""
echo -e "${GREEN}🎉 All done!${NC}"

