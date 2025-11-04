# 🤖 MCP Master Guide - Hephaestus Homelab

> Complete guide for the Docker MCP Server infrastructure

**Status:** ✅ All 40 MCP servers enabled  
**Date:** 2025-11-04  
**Location:** Hephaestus Homelab

---

## 📚 Table of Contents

1. [Quick Start](#quick-start)
2. [Documentation Index](#documentation-index)
3. [Enabled Servers](#enabled-servers)
4. [Authentication Status](#authentication-status)
5. [Integration Status](#integration-status)
6. [Common Commands](#common-commands)
7. [Troubleshooting](#troubleshooting)

---

## 🚀 Quick Start

### Step 1: Verify Setup ✅

```bash
# List all enabled servers (should show 40)
docker mcp server ls

# Check MCP Gateway status
docker mcp gateway status
```

### Step 2: Configure Authentication

```bash
# GitHub (most important)
docker mcp oauth authorize github

# List OAuth status
docker mcp oauth ls
```

See: [Authentication Guide](mcp-authentication-guide.md)

### Step 3: Test in Cursor IDE

1. Open Cursor IDE
2. In chat, try: `@mcp github list my repositories`
3. See: [Cursor Integration](mcp-cursor-integration.md)

### Step 4: Create n8n Workflows

See: [n8n Integration Guide](mcp-n8n-integration.md)

---

## 📖 Documentation Index

### Core Documentation

| Document | Description | Status |
|----------|-------------|--------|
| [Setup Checklist](mcp-setup-checklist.md) | Complete list of 40 servers with priorities | ✅ Complete |
| [Catalog Browsing](mcp-catalog-browsing.md) | How to browse and search the catalog | ✅ Complete |
| [Authentication Guide](mcp-authentication-guide.md) | OAuth and API key configuration | ✅ Complete |
| [Cursor Integration](mcp-cursor-integration.md) | Connect to Cursor IDE | ✅ Complete |
| [n8n Integration](mcp-n8n-integration.md) | Workflow automation | ✅ Complete |

### Scripts

| Script | Purpose | Location |
|--------|---------|----------|
| `enable-mcp-servers.sh` | Enable servers by priority | `/home/chris/github/hephaestus-infra/scripts/` |

---

## ✅ Enabled Servers (40 Total)

### Core Infrastructure (9)
- ✅ `github` - Repository management
- ✅ `dockerhub` - Container registry
- ✅ `git` - Git operations
- ✅ `filesystem` - File system access
- ✅ `desktop-commander` - Terminal commands
- ✅ `postgres` - PostgreSQL database
- ✅ `mongodb` - MongoDB operations
- ✅ `redis` - Redis cache
- ✅ `grafana` - Metrics & dashboards

### DevOps & API (9)
- ✅ `openapi` - OpenAPI specs
- ✅ `openapi-schema` - Schema validation
- ✅ `postman` - API testing
- ✅ `mcp-api-gateway` - API gateway
- ✅ `node-code-sandbox` - Node.js execution
- ✅ `playwright` - Browser automation
- ✅ `puppeteer` - Chrome automation
- ✅ `firecrawl` - Web scraping
- ✅ `fetch` - HTTP requests

### Productivity (6)
- ✅ `notion` - Notion workspace
- ✅ `obsidian` - Obsidian vaults
- ✅ `linear` - Issue tracking (⚠️ OAuth warning)
- ✅ `slack` - Team communication
- ✅ `markdownify` - HTML to Markdown
- ✅ `context7` - Code documentation

### AI & Search (8)
- ✅ `sequentialthinking` - Problem solving
- ✅ `memory` - Persistent memory
- ✅ `wolfram-alpha` - Computational queries
- ✅ `brave` - Web search
- ✅ `tavily` - AI search
- ✅ `wikipedia-mcp` - Wikipedia
- ✅ `duckduckgo` - Private search
- ✅ `time` - Time operations

### Business & Data (8)
- ✅ `stripe` - Payment processing
- ✅ `airtable-mcp-server` - Airtable DB
- ✅ `nasdaq-data-link` - Financial data
- ✅ `mcp-discord` - Discord integration
- ✅ `youtube_transcript` - Video transcripts
- ✅ `apify-mcp-server` - Web scraping
- ✅ `google-maps` - Maps API
- ✅ `waystation` - Waystation (⚠️ OAuth warning)

---

## 🔐 Authentication Status

| Service | Method | Status | Priority |
|---------|--------|--------|----------|
| GitHub | OAuth | ⚠️ Not authorized | 🔴 High |
| Stripe | API Key | ⚠️ Needs config | 🟠 Medium |
| Grafana | API Token | ⚠️ Needs config | 🟠 Medium |
| Databases | Connection URI | ✅ Local defaults | 🟢 Low |
| Linear | OAuth | ⚠️ Warning (non-blocking) | 🟢 Low |
| Waystation | OAuth | ⚠️ Warning (non-blocking) | 🟢 Low |

### Quick Auth Setup

```bash
# Priority 1: GitHub
docker mcp oauth authorize github

# Priority 2: Set API keys (via env vars or Docker Desktop UI)
# See: /home/chris/github/hephaestus-infra/docs/mcp-authentication-guide.md
```

---

## 🔌 Integration Status

### Cursor IDE
- **Status:** Ready to configure
- **Method:** Auto-discovery via Docker MCP Gateway
- **Test:** `@mcp github list repositories` in Cursor chat
- **Docs:** [Cursor Integration](mcp-cursor-integration.md)

### n8n Workflows
- **Status:** Ready to integrate
- **Method:** HTTP Request nodes to `http://localhost:3000/mcp/`
- **Location:** `/home/chris/apps/n8n/`
- **Docs:** [n8n Integration](mcp-n8n-integration.md)

### Other Integrations
- VS Code: Similar to Cursor
- Jupyter Notebooks: Python client
- CLI: Direct `docker mcp` commands

---

## 🛠️ Common Commands

### Server Management

```bash
# List all available servers
docker mcp server list

# List enabled servers
docker mcp server ls

# Enable a server
docker mcp server enable <server-name>

# Disable a server
docker mcp server disable <server-name>

# Disable all servers
docker mcp server reset

# Inspect server details
docker mcp server inspect <server-name>
```

### OAuth Management

```bash
# List OAuth apps
docker mcp oauth ls

# Authorize a service
docker mcp oauth authorize <service>

# Revoke authorization
docker mcp oauth revoke <service>
```

### Gateway Management

```bash
# Start MCP Gateway
docker mcp gateway run

# Check gateway status
docker mcp gateway status

# Stop gateway
docker mcp gateway stop
```

---

## 🎯 Use Case Examples

### Magic Pages Project
```bash
# Servers in use:
- stripe (payment processing)
- playwright (browser automation)
- postgres (database)
- github (version control)
- openapi (API documentation)
```

### CapitolScope Project
```bash
# Servers in use:
- nasdaq-data-link (financial data)
- brave/tavily (research)
- youtube_transcript (content analysis)
- postgres (data storage)
- github (version control)
```

### Homelab Operations
```bash
# Servers in use:
- grafana (monitoring)
- dockerhub (container management)
- filesystem (file operations)
- desktop-commander (system commands)
- redis (caching)
```

---

## 🐛 Troubleshooting

### Issue: Servers not showing in Cursor

```bash
# 1. Check Docker Desktop is running
# 2. Verify servers are enabled
docker mcp server ls

# 3. Check MCP Gateway
docker mcp gateway status

# 4. Restart Cursor IDE
```

### Issue: OAuth errors (GPG key)

```bash
# Install/configure GPG
sudo apt install gnupg
gpg --gen-key

# Try authorization again
docker mcp oauth authorize github
```

### Issue: Linear/Waystation warnings

**Status:** Non-blocking warnings. Servers are enabled but OAuth setup failed.

**Solution:** 
- Continue with other servers
- Try authorizing later: `docker mcp oauth authorize linear`
- Or use API keys instead of OAuth

### Issue: Server not found

```bash
# Use exact names from catalog
docker mcp server list

# Examples:
# ✅ postgres (not postgresql)
# ✅ dockerhub (not docker-hub)
# ✅ github (lowercase)
```

---

## 📊 System Requirements

- ✅ Docker Desktop installed
- ✅ MCP Toolkit extension enabled
- ✅ Sufficient disk space for server images
- ✅ Network access for OAuth flows

---

## 🔄 Maintenance

### Weekly Tasks
- [ ] Check for MCP Toolkit updates
- [ ] Review OAuth token expiration
- [ ] Monitor server usage in Cursor

### Monthly Tasks
- [ ] Update server configurations
- [ ] Review and disable unused servers
- [ ] Check for new servers in catalog

### As Needed
- [ ] Renew OAuth tokens
- [ ] Rotate API keys
- [ ] Update documentation

---

## 📈 Next Steps

1. **Immediate:**
   - ✅ Configure GitHub OAuth
   - ✅ Test basic Cursor integration
   - ✅ Set up local database connections

2. **This Week:**
   - ✅ Configure Stripe for Magic Pages
   - ✅ Set up Grafana monitoring
   - ✅ Create first n8n workflow

3. **This Month:**
   - ✅ Add search API keys (Brave, Tavily)
   - ✅ Configure productivity tools (Notion, Linear)
   - ✅ Build comprehensive automation workflows

---

## 🔗 External Resources

- [Docker MCP Toolkit Docs](https://docs.docker.com/ai/mcp-catalog-and-toolkit/)
- [MCP Protocol Spec](https://modelcontextprotocol.io/)
- [Cursor IDE Docs](https://cursor.sh/docs)
- [n8n Documentation](https://docs.n8n.io/)

---

## 📝 Change Log

### 2025-11-04
- ✅ Enabled all 40 MCP servers
- ✅ Created comprehensive documentation
- ✅ Set up integration guides for Cursor and n8n
- ⚠️ OAuth warnings for Linear and Waystation (non-blocking)
- 🔜 Pending: GitHub OAuth configuration
- 🔜 Pending: API key configuration for external services

---

## 🆘 Support

### Documentation
All documentation in: `/home/chris/github/hephaestus-infra/docs/`

### Scripts
All scripts in: `/home/chris/github/hephaestus-infra/scripts/`

### Configuration
- Docker MCP config: `~/.docker/mcp/`
- Cursor MCP config: `~/.cursor/mcp-config.json`
- n8n location: `/home/chris/apps/n8n/`

---

**Last Updated:** 2025-11-04  
**Maintained by:** Chris  
**Status:** ✅ Production Ready

