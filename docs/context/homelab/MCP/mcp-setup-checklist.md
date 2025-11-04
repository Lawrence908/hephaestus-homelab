# 🤖 MCP Server Setup Checklist

> Comprehensive list of MCP servers to enable for the Hephaestus homelab

## 📊 Available MCP Servers in Catalog

Total available: **40 servers**

---

## ✅ Recommended MCP Servers by Category

### 🔥 **Must-Have: Core Infrastructure** (Priority 1)

- [ ] `github` - Repository management, code browsing, PR/Issues
- [ ] `dockerhub` - Container registry operations  
- [ ] `git` - Git operations and automation
- [ ] `filesystem` - Local file system access
- [ ] `desktop-commander` - Run terminal commands via MCP

**Enable command:**
```bash
docker mcp server enable github dockerhub git filesystem desktop-commander
```

---

### 💾 **Must-Have: Databases** (Priority 1)

- [ ] `postgres` - PostgreSQL database operations
- [ ] `mongodb` - MongoDB NoSQL operations
- [ ] `redis` - Redis caching and data structures

**Enable command:**
```bash
docker mcp server enable postgres mongodb redis
```

---

### 📈 **Must-Have: Monitoring & Observability** (Priority 1)

- [ ] `grafana` - Metrics dashboards and queries

**Enable command:**
```bash
docker mcp server enable grafana
```

---

### ⚙️ **Must-Have: DevOps & API Tools** (Priority 2)

- [ ] `openapi` - OpenAPI/Swagger spec interaction
- [ ] `openapi-schema` - OpenAPI schema management
- [ ] `postman` - API testing and collections
- [ ] `mcp-api-gateway` - API gateway management
- [ ] `node-code-sandbox` - Run Node.js code in isolated environment

**Enable command:**
```bash
docker mcp server enable openapi openapi-schema postman mcp-api-gateway node-code-sandbox
```

---

### 🌐 **Must-Have: Web Automation & Scraping** (Priority 2)

- [ ] `playwright` - Browser automation (for Magic Pages)
- [ ] `puppeteer` - Chrome automation and testing
- [ ] `firecrawl` - Web scraping and crawling
- [ ] `fetch` - HTTP requests and URL content fetching

**Enable command:**
```bash
docker mcp server enable playwright puppeteer firecrawl fetch
```

---

### 📝 **Should-Have: Productivity & Documentation** (Priority 3)

- [ ] `notion` - Notion workspace integration (if you use it)
- [ ] `obsidian` - Obsidian vault access (if you use it)
- [ ] `linear` - Linear project management (if you use it)
- [ ] `slack` - Slack workspace archives
- [ ] `markdownify` - HTML to Markdown conversion
- [ ] `context7` - Code documentation for LLMs

**Enable command:**
```bash
docker mcp server enable notion obsidian linear slack markdownify context7
```

---

### 💰 **Should-Have: Payment & Business Tools** (Priority 3)

- [ ] `stripe` - Stripe payment processing (for Magic Pages)
- [ ] `airtable-mcp-server` - Airtable database operations

**Enable command:**
```bash
docker mcp server enable stripe airtable-mcp-server
```

---

### 🧠 **Should-Have: AI & Intelligence** (Priority 3)

- [ ] `sequentialthinking` - Dynamic problem-solving through reflection
- [ ] `memory` - Persistent memory system for AI
- [ ] `wolfram-alpha` - Computational intelligence

**Enable command:**
```bash
docker mcp server enable sequentialthinking memory wolfram-alpha
```

---

### 🔍 **Should-Have: Search & Research** (Priority 3)

- [ ] `brave` - Brave Search API
- [ ] `tavily` - Web search optimized for AI
- [ ] `wikipedia-mcp` - Wikipedia content access
- [ ] `duckduckgo` - DuckDuckGo search

**Enable command:**
```bash
docker mcp server enable brave tavily wikipedia-mcp duckduckgo
```

---

### 📊 **Nice-to-Have: Data & Communication** (Priority 4)

- [ ] `mcp-discord` - Discord integration
- [ ] `youtube_transcript` - YouTube video transcripts
- [ ] `nasdaq-data-link` - Financial data (for CapitolScope)
- [ ] `time` - Time and timezone operations
- [ ] `apify-mcp-server` - Web scraping platform
- [ ] `google-maps` - Google Maps API

**Enable command:**
```bash
docker mcp server enable mcp-discord youtube_transcript nasdaq-data-link time apify-mcp-server google-maps
```

---

### 🔧 **Optional: Specialized Tools** (Priority 5)

- [ ] `waystation` - Waystation integration

**Enable command:**
```bash
docker mcp server enable waystation
```

---

## 🚀 Quick Setup: Enable All Recommended Servers

### Option 1: Enable Everything at Once

```bash
# All 40 servers
docker mcp server enable \
  github dockerhub git filesystem desktop-commander \
  postgres mongodb redis \
  grafana \
  openapi openapi-schema postman mcp-api-gateway node-code-sandbox \
  playwright puppeteer firecrawl fetch \
  notion obsidian linear slack markdownify context7 \
  stripe airtable-mcp-server \
  sequentialthinking memory wolfram-alpha \
  brave tavily wikipedia-mcp duckduckgo \
  mcp-discord youtube_transcript nasdaq-data-link time apify-mcp-server google-maps \
  waystation
```

### Option 2: Enable Just Essentials (Recommended Start)

```bash
# Core infrastructure + databases + monitoring (9 servers)
docker mcp server enable \
  github dockerhub git filesystem desktop-commander \
  postgres mongodb redis \
  grafana
```

### Option 3: Enable by Priority

```bash
# Priority 1 (Core + Databases + Monitoring)
docker mcp server enable github dockerhub git filesystem desktop-commander postgres mongodb redis grafana

# Priority 2 (DevOps + Web Automation)
docker mcp server enable openapi openapi-schema postman mcp-api-gateway node-code-sandbox playwright puppeteer firecrawl fetch

# Priority 3 (Productivity + AI + Search)
docker mcp server enable notion linear slack markdownify context7 stripe sequentialthinking memory wolfram-alpha brave tavily wikipedia-mcp

# Priority 4 (Data & Communication)
docker mcp server enable mcp-discord youtube_transcript nasdaq-data-link time apify-mcp-server google-maps
```

---

## 📋 Management Commands

```bash
# List all available servers
docker mcp server list

# List enabled servers
docker mcp server list --json | jq -r '.[] | select(.enabled == true)'

# Disable a server
docker mcp server disable <server-name>

# Check server status
docker mcp server status <server-name>
```

---

## 🎯 Homelab-Specific Recommendations

### For Magic Pages Project:
- ✅ `stripe` - Payment processing
- ✅ `playwright` / `puppeteer` - Browser automation
- ✅ `openapi` - API documentation
- ✅ `postgres` / `mongodb` - Database operations

### For CapitolScope Project:
- ✅ `nasdaq-data-link` - Financial data
- ✅ `brave` / `tavily` - Research and search
- ✅ `youtube_transcript` - Content analysis

### For General Homelab:
- ✅ `grafana` - Monitoring dashboards
- ✅ `dockerhub` - Container management
- ✅ `github` - Code repository access
- ✅ `filesystem` - Local file operations
- ✅ `desktop-commander` - System commands

---

## 🔗 Next Steps

1. **Enable core servers** using Priority 1 commands
2. **Configure authentication** for servers that need it (GitHub, Stripe, etc.)
3. **Test integration** with Cursor IDE
4. **Add to n8n** workflows as needed
5. **Document server configurations** in homelab docs

---

## 📚 Resources

- [Docker MCP Toolkit Docs](https://docs.docker.com/ai/mcp-catalog-and-toolkit/)
- [MCP Protocol Spec](https://modelcontextprotocol.io/)
- Homelab MCP Integration: `/home/chris/github/hephaestus-infra/docs/mcp/`

---

**Last Updated:** 2025-11-04  
**Status:** Ready for implementation

