# 🔐 MCP Server Authentication Guide

> Configure authentication for MCP servers in the Hephaestus homelab

**Status:** All 40 MCP servers enabled ✅  
**Date:** 2025-11-04

---

## 📋 Authentication Overview

MCP servers use different authentication methods:
- **OAuth 2.0** - For services like GitHub, Linear, Notion, Slack
- **API Keys** - For services like Stripe, Brave, OpenAI
- **No Auth** - For local services like filesystem, git, docker

---

## 🔑 OAuth Authentication

### Available OAuth Providers

Check which OAuth providers are available:
```bash
docker mcp oauth ls
```

Current output:
```
gdrive | not authorized
github | not authorized
```

### Authorize OAuth Apps

```bash
# Authorize GitHub
docker mcp oauth authorize github

# Authorize Google Drive (if needed)
docker mcp oauth authorize gdrive
```

### OAuth Troubleshooting

**Issue:** OAuth warnings during enable (Linear, Waystation)
```
Warning: Failed to register OAuth provider for linear: HTTP 500
```

**Solution:** These warnings are non-blocking. The servers are enabled but need auth later:
```bash
# Try authorizing after enabling
docker mcp oauth authorize linear
```

If still fails, check:
1. GPG keys are properly configured
2. Docker Desktop is updated to latest version
3. MCP Toolkit extension is updated

---

## 🔑 Servers Requiring Authentication

### Priority 1: Core Services

#### 1. GitHub
- **Method:** OAuth 2.0
- **Required for:** Repository access, PR/Issue management
- **Setup:**
```bash
docker mcp oauth authorize github
```
- **Permissions needed:** 
  - `repo` (full control of private repositories)
  - `read:org` (read org data)
  - `read:user` (read user profile)

#### 2. DockerHub
- **Method:** Docker CLI authentication (already configured)
- **Required for:** Private registry access
- **Setup:** Uses existing `docker login` credentials

---

### Priority 2: Development Tools

#### 3. Stripe
- **Method:** API Key
- **Required for:** Payment processing (Magic Pages)
- **Setup:**
```bash
# Get API key from: https://dashboard.stripe.com/apikeys
# Set environment variable or configure via Docker Desktop UI
export STRIPE_API_KEY="sk_test_..."
```

#### 4. Notion
- **Method:** OAuth 2.0 or Integration Token
- **Required for:** Workspace access
- **Setup:**
```bash
docker mcp oauth authorize notion
# OR use integration token:
export NOTION_API_KEY="secret_..."
```

#### 5. Linear
- **Method:** OAuth 2.0 or Personal API Key
- **Required for:** Issue tracking
- **Setup:**
```bash
docker mcp oauth authorize linear
# OR use API key from: https://linear.app/settings/api
export LINEAR_API_KEY="lin_api_..."
```

#### 6. Slack
- **Method:** OAuth 2.0 or Bot Token
- **Required for:** Workspace history/messaging
- **Setup:**
```bash
docker mcp oauth authorize slack
# OR use bot token:
export SLACK_BOT_TOKEN="xoxb-..."
```

---

### Priority 3: Search & Data

#### 7. Brave Search
- **Method:** API Key
- **Required for:** Web search
- **Setup:**
```bash
# Get API key from: https://brave.com/search/api/
export BRAVE_API_KEY="BSA..."
```

#### 8. Tavily
- **Method:** API Key
- **Required for:** AI-optimized search
- **Setup:**
```bash
# Get API key from: https://tavily.com/
export TAVILY_API_KEY="tvly-..."
```

#### 9. Wolfram Alpha
- **Method:** App ID
- **Required for:** Computational queries
- **Setup:**
```bash
# Get App ID from: https://products.wolframalpha.com/api/
export WOLFRAM_APP_ID="..."
```

#### 10. Nasdaq Data Link
- **Method:** API Key
- **Required for:** Financial data (CapitolScope)
- **Setup:**
```bash
# Get API key from: https://data.nasdaq.com/
export NASDAQ_API_KEY="..."
```

---

### Priority 4: Monitoring & Infrastructure

#### 11. Grafana
- **Method:** API Token or Basic Auth
- **Required for:** Dashboard queries
- **Setup:**
```bash
# Create service account token in Grafana UI
export GRAFANA_API_TOKEN="glsa_..."
export GRAFANA_URL="http://grafana.local:3000"
```

#### 12. MongoDB
- **Method:** Connection String
- **Required for:** Database operations
- **Setup:**
```bash
export MONGODB_URI="mongodb://username:password@localhost:27017"
```

#### 13. PostgreSQL
- **Method:** Connection String
- **Required for:** Database operations
- **Setup:**
```bash
export POSTGRES_URI="postgresql://username:password@localhost:5432/dbname"
```

#### 14. Redis
- **Method:** Connection String
- **Required for:** Cache operations
- **Setup:**
```bash
export REDIS_URL="redis://localhost:6379"
```

---

## 🎯 Configuration Methods

### Method 1: Docker Desktop UI (Recommended)

1. Open **Docker Desktop**
2. Go to **MCP Toolkit** extension
3. Click on a server in the **Catalog**
4. Click **Configure** or **Settings**
5. Enter authentication credentials
6. Click **Save**

### Method 2: Environment Variables

Create a `.env` file:
```bash
# /home/chris/.config/docker/mcp/.env

# Core Services
GITHUB_TOKEN="ghp_..."

# Payment & Business
STRIPE_API_KEY="sk_..."

# Search & Data
BRAVE_API_KEY="BSA..."
TAVILY_API_KEY="tvly-..."
WOLFRAM_APP_ID="..."
NASDAQ_API_KEY="..."

# Productivity
NOTION_API_KEY="secret_..."
LINEAR_API_KEY="lin_api_..."
SLACK_BOT_TOKEN="xoxb-..."

# Infrastructure
GRAFANA_API_TOKEN="glsa_..."
GRAFANA_URL="http://grafana.local:3000"
MONGODB_URI="mongodb://localhost:27017"
POSTGRES_URI="postgresql://localhost:5432"
REDIS_URL="redis://localhost:6379"

# Homelab Specific
AIRTABLE_API_KEY="key..."
GOOGLE_MAPS_API_KEY="AIza..."
```

### Method 3: OAuth CLI Flow

```bash
# List available OAuth apps
docker mcp oauth ls

# Authorize via browser
docker mcp oauth authorize <service>

# Revoke authorization
docker mcp oauth revoke <service>
```

---

## 🚀 Quick Setup Script

Create a setup script for API keys:

```bash
#!/bin/bash
# /home/chris/github/hephaestus-infra/scripts/configure-mcp-auth.sh

echo "🔐 MCP Authentication Configuration"
echo "===================================="
echo ""

# GitHub OAuth
echo "Configuring GitHub OAuth..."
docker mcp oauth authorize github

# Prompt for API keys
read -p "Enter Stripe API Key (or press Enter to skip): " STRIPE_KEY
if [ ! -z "$STRIPE_KEY" ]; then
    export STRIPE_API_KEY="$STRIPE_KEY"
fi

read -p "Enter Brave Search API Key (or press Enter to skip): " BRAVE_KEY
if [ ! -z "$BRAVE_KEY" ]; then
    export BRAVE_API_KEY="$BRAVE_KEY"
fi

# Database connections (use local defaults)
export MONGODB_URI="mongodb://localhost:27017"
export POSTGRES_URI="postgresql://localhost:5432"
export REDIS_URL="redis://localhost:6379"
export GRAFANA_URL="http://grafana.local:3000"

echo ""
echo "✅ Authentication configuration complete!"
echo ""
echo "To persist these settings, add them to:"
echo "  ~/.bashrc or ~/.config/docker/mcp/.env"
```

---

## 📊 Authentication Status Check

```bash
# Check OAuth status
docker mcp oauth ls

# Inspect server configuration
docker mcp server inspect <server-name>

# List enabled servers
docker mcp server ls
```

---

## 🔧 Troubleshooting

### Issue: GPG Key Error
```
gpg: ed25519: skipped: No public key
```

**Solution:**
1. Ensure GPG is installed: `sudo apt install gnupg`
2. Generate a GPG key: `gpg --gen-key`
3. Try authorization again

### Issue: OAuth HTTP 500
```
HTTP 500: provider `linear`: not found
```

**Solution:**
1. Update Docker Desktop to latest version
2. Update MCP Toolkit extension
3. Try using API keys instead of OAuth

### Issue: Server Not Found
```
server postgresql not found in catalog
```

**Solution:**
- Use exact server name from catalog: `postgres` not `postgresql`
- Check available servers: `docker mcp server list`

---

## 📝 Next Steps

1. ✅ Configure GitHub OAuth first (most important)
2. ✅ Set up database connections (local defaults work)
3. ✅ Add Stripe key for Magic Pages
4. ✅ Add search API keys (Brave, Tavily) as needed
5. ✅ Configure productivity tools (Notion, Linear) if used

---

## 🔗 Related Documentation

- [MCP Setup Checklist](/home/chris/github/hephaestus-infra/docs/mcp-setup-checklist.md)
- [MCP Catalog Browsing](/home/chris/github/hephaestus-infra/docs/mcp-catalog-browsing.md)
- [Cursor IDE Integration](/home/chris/github/hephaestus-infra/docs/mcp-cursor-integration.md)
- [n8n Workflow Integration](/home/chris/github/hephaestus-infra/docs/mcp-n8n-integration.md)

---

**Last Updated:** 2025-11-04  
**Status:** Ready for configuration

