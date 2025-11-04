# 🎯 Cursor IDE Integration with MCP Servers

> Connect your 40 enabled MCP servers to Cursor IDE for enhanced AI coding capabilities

**Status:** MCP servers enabled and ready for integration ✅  
**Date:** 2025-11-04

---

## 📋 Overview

Cursor IDE can connect to Docker MCP servers to access:
- GitHub repositories and operations
- Database queries (PostgreSQL, MongoDB, Redis)
- API testing and documentation (OpenAPI, Postman)
- Web automation (Playwright, Puppeteer)
- File system operations
- And all 40 enabled MCP servers!

---

## 🚀 Quick Setup

### Option 1: Automatic Discovery (Recommended)

Docker MCP Toolkit automatically exposes enabled servers to Cursor:

1. **Ensure Docker Desktop is running** with MCP Toolkit enabled
2. **Restart Cursor IDE** to detect MCP servers
3. **Verify connection** in Cursor settings

Cursor should automatically discover all enabled MCP servers via the Docker MCP Gateway.

### Option 2: Manual Configuration

If automatic discovery doesn't work, configure manually:

1. Open **Cursor Settings** → **Extensions** → **MCP**
2. Add MCP Gateway endpoint:
   ```
   http://localhost:3000
   ```
3. Restart Cursor IDE

---

## ⚙️ Configuration File

Cursor uses an MCP configuration file at:
```
~/.cursor/mcp-config.json
```

### Example Configuration

```json
{
  "mcpServers": {
    "docker-mcp": {
      "type": "stdio",
      "command": "docker",
      "args": ["mcp", "gateway", "run"],
      "autoStart": true
    }
  }
}
```

Or connect to the Docker MCP Gateway HTTP endpoint:

```json
{
  "mcpServers": {
    "docker-gateway": {
      "type": "http",
      "url": "http://localhost:3000",
      "enabled": true
    }
  }
}
```

---

## 🧪 Testing Integration

### Test 1: Check MCP Connection

1. Open **Cursor Command Palette** (Cmd/Ctrl + Shift + P)
2. Type: `MCP: Show Available Servers`
3. You should see all 40 enabled servers

### Test 2: Use GitHub MCP Server

In Cursor chat, try:
```
@mcp Use GitHub to list my repositories
```

Or:
```
List all pull requests in hephaestus-infra repository using the GitHub MCP server
```

### Test 3: Query Database

```
@mcp Use PostgreSQL to show all tables in the database
```

### Test 4: File System Operations

```
@mcp Use filesystem to read the contents of /home/chris/github/hephaestus-infra/README.md
```

### Test 5: API Documentation

```
@mcp Use OpenAPI to analyze the Magic Pages API specification
```

---

## 🎯 Common Use Cases

### 1. Repository Management

```
@mcp GitHub - Create a new branch called "feature/mcp-integration" in hephaestus-infra
```

```
@mcp GitHub - List all open issues in the CapitolScope repository
```

### 2. Database Queries

```
@mcp PostgreSQL - Show me the schema for the users table
```

```
@mcp MongoDB - Find all documents in the sessions collection
```

### 3. API Testing

```
@mcp Postman - Run the "Stripe Payment Flow" collection
```

```
@mcp OpenAPI - Generate TypeScript client code for the Magic Pages API
```

### 4. Web Automation

```
@mcp Playwright - Take a screenshot of https://magicpages.dev
```

```
@mcp Puppeteer - Scrape the pricing table from https://example.com
```

### 5. Code Documentation

```
@mcp Context7 - Generate documentation for the current file
```

### 6. Search and Research

```
@mcp Brave - Search for "Model Context Protocol best practices"
```

```
@mcp Wikipedia - Get information about Large Language Models
```

---

## 🛠️ Available MCP Tools in Cursor

### Core Infrastructure (9 servers)
- `github` - Repository operations, PR/issues
- `dockerhub` - Container registry
- `git` - Git operations  
- `filesystem` - File system access
- `desktop-commander` - Terminal commands
- `postgres` - PostgreSQL queries
- `mongodb` - MongoDB operations
- `redis` - Redis cache operations
- `grafana` - Metrics and dashboards

### DevOps & Automation (9 servers)
- `openapi` - API spec interaction
- `openapi-schema` - Schema validation
- `postman` - API testing
- `mcp-api-gateway` - API gateway management
- `node-code-sandbox` - Run Node.js code
- `playwright` - Browser automation
- `puppeteer` - Chrome automation
- `firecrawl` - Web scraping
- `fetch` - HTTP requests

### Productivity (6 servers)
- `notion` - Notion workspace
- `obsidian` - Obsidian vaults
- `linear` - Issue tracking
- `slack` - Team communication
- `markdownify` - HTML to Markdown
- `context7` - Code documentation

### AI & Intelligence (8 servers)
- `sequentialthinking` - Problem solving
- `memory` - Persistent memory
- `wolfram-alpha` - Computational queries
- `brave` - Web search
- `tavily` - AI-optimized search
- `wikipedia-mcp` - Wikipedia content
- `duckduckgo` - Private search
- `time` - Time operations

### Business & Data (8 servers)
- `stripe` - Payment processing
- `airtable-mcp-server` - Airtable databases
- `nasdaq-data-link` - Financial data
- `mcp-discord` - Discord integration
- `youtube_transcript` - Video transcripts
- `apify-mcp-server` - Web scraping platform
- `google-maps` - Maps API
- `waystation` - Waystation integration

---

## 🔧 Troubleshooting

### Issue: MCP Servers Not Showing

**Solution:**
1. Check Docker Desktop is running
2. Verify MCP Gateway is active:
   ```bash
   docker mcp gateway status
   ```
3. Restart Cursor IDE
4. Check Cursor logs: `~/.cursor/logs/`

### Issue: Authentication Errors

**Solution:**
1. Configure OAuth for required services:
   ```bash
   docker mcp oauth authorize github
   ```
2. Set API keys in environment or Docker Desktop UI
3. See [Authentication Guide](/home/chris/github/hephaestus-infra/docs/mcp-authentication-guide.md)

### Issue: Command Not Found

**Solution:**
- Use exact server names from: `docker mcp server ls`
- Try: `@mcp <server-name> <command>`
- Example: `@mcp github list repos` not `@mcp GitHub list repos`

---

## 💡 Pro Tips

### 1. Multi-Server Workflows

Combine multiple MCP servers in one request:
```
@mcp Use GitHub to get the latest commit, then use OpenAPI to test the /api/status endpoint
```

### 2. Context Awareness

MCP servers have access to your current file context:
```
@mcp Use Context7 to document this file and save to docs/
```

### 3. Persistent Memory

Use the memory server for long-term context:
```
@mcp Remember that we use Stripe for payment processing in Magic Pages
```

### 4. Sequential Thinking

For complex problems:
```
@mcp Use SequentialThinking to analyze the best database schema for the users feature
```

---

## 📊 Performance Tips

1. **Enable only needed servers** - While all 40 are enabled, Cursor only loads what it needs
2. **Use specific server names** - More efficient than generic requests
3. **Batch operations** - Combine multiple operations in one prompt
4. **Cache results** - Use the memory server to avoid repeated queries

---

## 🎯 Next Steps

1. ✅ **Test basic connection** - Try a simple GitHub query
2. ✅ **Configure authentication** - Set up OAuth for GitHub
3. ✅ **Test project-specific servers** - Try Stripe for Magic Pages
4. ✅ **Create custom shortcuts** - Add frequently used MCP commands to snippets
5. ✅ **Monitor usage** - Check which servers you use most

---

## 📚 Example Workflows

### Magic Pages Development

```
# Check repository status
@mcp github list recent commits in magic-pages repo

# Test Stripe integration
@mcp stripe get customer list

# Run browser tests
@mcp playwright test checkout flow on localhost:3000

# Query database
@mcp postgres show users table schema
```

### CapitolScope Research

```
# Search for relevant information
@mcp brave search "congressional stock trading data API"

# Get financial data
@mcp nasdaq-data-link get historical stock prices for TSLA

# Generate documentation
@mcp context7 document the data import script
```

### Homelab Monitoring

```
# Check Grafana metrics
@mcp grafana get last 1 hour CPU usage

# Query services
@mcp postgres list all active services

# Check Docker images
@mcp dockerhub list tags for my-homelab-image
```

---

## 🔗 Related Documentation

- [MCP Authentication Guide](/home/chris/github/hephaestus-infra/docs/mcp-authentication-guide.md)
- [MCP Setup Checklist](/home/chris/github/hephaestus-infra/docs/mcp-setup-checklist.md)
- [n8n Integration](/home/chris/github/hephaestus-infra/docs/mcp-n8n-integration.md)

---

**Last Updated:** 2025-11-04  
**Status:** Ready for testing

