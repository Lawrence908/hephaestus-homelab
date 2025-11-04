# ⚡ n8n Workflow Integration with MCP Servers

> Automate your homelab workflows using 40 MCP servers in n8n

**Status:** MCP servers ready for n8n integration ✅  
**Date:** 2025-11-04

---

## 📋 Overview

Integrate your enabled MCP servers with n8n workflows to:
- Automate GitHub operations (PR creation, issue tracking)
- Schedule database backups and queries
- Monitor infrastructure via Grafana
- Process payments via Stripe
- Scrape and analyze web content
- And much more with all 40 MCP servers!

---

## 🚀 Quick Setup

### Prerequisites

1. **n8n running** (you have it at `/home/chris/apps/n8n/`)
2. **Docker MCP Gateway active**
3. **MCP servers enabled** (✅ Done - 40 servers)

### Connection Method

n8n connects to MCP servers via HTTP API calls to the Docker MCP Gateway.

---

## ⚙️ n8n Configuration

### Method 1: HTTP Request Node (Recommended)

Use n8n's **HTTP Request** node to call MCP servers:

1. Add **HTTP Request** node
2. Set URL: `http://localhost:3000/mcp/<server-name>/<operation>`
3. Configure authentication (if needed)
4. Parse response

### Method 2: Function Node + Docker CLI

Use n8n's **Execute Command** node:

```javascript
const { execSync } = require('child_process');

// Example: List GitHub repos
const result = execSync('docker mcp server inspect github').toString();
return [{ json: JSON.parse(result) }];
```

---

## 📚 n8n Workflow Examples

### Example 1: Daily GitHub Backup

**Workflow:** Backup all repositories daily

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│  Schedule   │───▶│  HTTP Req    │───▶│   MongoDB   │
│  (Daily)    │    │  (GitHub)    │    │  (Store)    │
└─────────────┘    └──────────────┘    └─────────────┘
```

**HTTP Request Node Config:**
```json
{
  "method": "POST",
  "url": "http://localhost:3000/mcp/github/list-repositories",
  "authentication": "oAuth2",
  "body": {
    "owner": "your-username"
  }
}
```

---

### Example 2: Stripe Payment Monitoring

**Workflow:** Monitor Stripe payments and send alerts

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐    ┌──────────┐
│  Schedule   │───▶│  HTTP Req    │───▶│    Filter   │───▶│  Discord │
│  (Hourly)   │    │  (Stripe)    │    │  (If > $100)│    │  Alert   │
└─────────────┘    └──────────────┘    └─────────────┘    └──────────┘
```

**HTTP Request Node Config:**
```json
{
  "method": "GET",
  "url": "http://localhost:3000/mcp/stripe/list-charges",
  "headers": {
    "Authorization": "Bearer {{$env.STRIPE_API_KEY}}"
  },
  "qs": {
    "created[gte]": "{{$now.minus({hours: 1}).toSeconds()}}"
  }
}
```

---

### Example 3: Grafana Metrics Report

**Workflow:** Generate daily Grafana metrics report

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐    ┌──────────┐
│  Schedule   │───▶│  HTTP Req    │───▶│  Markdown   │───▶│   Slack  │
│  (Daily 9AM)│    │  (Grafana)   │    │  Format     │    │  Post    │
└─────────────┘    └──────────────┘    └─────────────┘    └──────────┘
```

**HTTP Request Node Config:**
```json
{
  "method": "POST",
  "url": "http://localhost:3000/mcp/grafana/query-dashboard",
  "headers": {
    "Authorization": "Bearer {{$env.GRAFANA_API_TOKEN}}"
  },
  "body": {
    "dashboard": "homelab-overview",
    "timeRange": "24h"
  }
}
```

---

### Example 4: Web Scraping Pipeline

**Workflow:** Scrape competitor pricing daily

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐    ┌──────────┐
│  Schedule   │───▶│  HTTP Req    │───▶│   MongoDB   │───▶│  Analyze │
│  (Daily)    │    │ (Playwright) │    │  (Store)    │    │  Changes │
└─────────────┘    └──────────────┘    └─────────────┘    └──────────┘
```

**HTTP Request Node Config:**
```json
{
  "method": "POST",
  "url": "http://localhost:3000/mcp/playwright/scrape-page",
  "body": {
    "url": "https://competitor.com/pricing",
    "selector": ".pricing-table",
    "screenshot": true
  }
}
```

---

### Example 5: Database Backup Automation

**Workflow:** Backup PostgreSQL to S3 daily

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐    ┌──────────┐
│  Schedule   │───▶│  Execute Cmd │───▶│  Compress   │───▶│   S3     │
│  (Daily 3AM)│    │  (Postgres)  │    │   .gz       │    │  Upload  │
└─────────────┘    └──────────────┘    └─────────────┘    └──────────┘
```

**Execute Command Node:**
```bash
docker mcp server inspect postgres | jq '.connection_string' | \
  xargs -I {} pg_dump {} > /backup/db_$(date +%Y%m%d).sql
```

---

## 🔧 n8n Node Configurations

### Generic MCP HTTP Request Template

Create a reusable HTTP Request template:

```json
{
  "name": "MCP Request",
  "type": "n8n-nodes-base.httpRequest",
  "typeVersion": 1,
  "position": [250, 300],
  "parameters": {
    "method": "POST",
    "url": "=http://localhost:3000/mcp/{{$json.server}}/{{$json.operation}}",
    "authentication": "genericCredentialType",
    "genericAuthType": "httpHeaderAuth",
    "options": {
      "timeout": 30000
    },
    "bodyParameters": {
      "parameters": "={{$json.params}}"
    }
  }
}
```

### MCP Function Helper

Create a reusable function for MCP calls:

```javascript
// n8n Function Node
async function callMCP(server, operation, params = {}) {
  const response = await this.helpers.httpRequest({
    method: 'POST',
    url: `http://localhost:3000/mcp/${server}/${operation}`,
    body: params,
    headers: {
      'Content-Type': 'application/json'
    }
  });
  return response;
}

// Usage example
const repos = await callMCP('github', 'list-repositories', {
  owner: 'your-username'
});

return repos;
```

---

## 🎯 Real-World Homelab Workflows

### Workflow 1: Magic Pages Deployment Pipeline

```
1. GitHub Webhook (PR merged) →
2. MCP Git (pull latest) →
3. MCP Docker (build image) →
4. MCP Kubernetes (deploy) →
5. MCP Playwright (run tests) →
6. MCP Slack (notify team)
```

### Workflow 2: CapitolScope Data Pipeline

```
1. Schedule (daily) →
2. MCP Nasdaq-Data-Link (fetch stock data) →
3. MCP Brave (search news) →
4. MCP YouTube-Transcript (get video transcripts) →
5. MCP PostgreSQL (store data) →
6. MCP OpenAI (analyze sentiment) →
7. MCP Discord (post insights)
```

### Workflow 3: Homelab Monitoring

```
1. Schedule (every 5 min) →
2. MCP Grafana (get metrics) →
3. MCP Redis (cache results) →
4. If CPU > 80%:
   - MCP Desktop-Commander (run diagnostics)
   - MCP Slack (alert)
   - MCP MongoDB (log incident)
```

### Workflow 4: Automated Documentation

```
1. GitHub Webhook (code pushed) →
2. MCP Filesystem (read changed files) →
3. MCP Context7 (generate docs) →
4. MCP Markdownify (format) →
5. MCP GitHub (create PR with docs) →
6. MCP Linear (create review task)
```

---

## 📦 n8n Custom Node Package

Create a custom n8n node package for MCP:

### Package Structure

```
n8n-nodes-docker-mcp/
├── package.json
├── nodes/
│   ├── DockerMCP/
│   │   ├── DockerMCP.node.ts
│   │   ├── DockerMCP.node.json
│   │   └── docker-mcp.svg
│   └── GenericFunctions.ts
└── credentials/
    └── DockerMcpApi.credentials.ts
```

### Installation

```bash
cd /home/chris/apps/n8n/
npm install n8n-nodes-docker-mcp

# Or create custom node (see n8n docs)
```

---

## 🔐 Authentication in n8n

### Set Environment Variables

Edit n8n docker compose [[memory:9849171]]:

```yaml
# /home/chris/apps/n8n/n8n/docker-compose.local.yml
services:
  n8n:
    environment:
      # Existing vars...
      
      # MCP Authentication
      - GITHUB_TOKEN=${GITHUB_TOKEN}
      - STRIPE_API_KEY=${STRIPE_API_KEY}
      - GRAFANA_API_TOKEN=${GRAFANA_API_TOKEN}
      - BRAVE_API_KEY=${BRAVE_API_KEY}
      - TAVILY_API_KEY=${TAVILY_API_KEY}
      - MONGODB_URI=mongodb://localhost:27017
      - POSTGRES_URI=postgresql://localhost:5432
      - REDIS_URL=redis://localhost:6379
```

### Use Credentials in Workflows

Reference in HTTP Request nodes:
```
{{$env.STRIPE_API_KEY}}
{{$env.GITHUB_TOKEN}}
```

---

## 🧪 Testing MCP Integration

### Test Workflow

Create a simple test workflow:

1. **Manual Trigger** node
2. **HTTP Request** node:
   - Method: GET
   - URL: `http://localhost:3000/mcp/github/list-repositories`
3. **Code** node to parse response
4. **Slack/Discord** node to output results

### Debugging

Enable n8n debug mode:
```bash
cd /home/chris/apps/n8n/
docker compose logs -f n8n
```

---

## 💡 Best Practices

### 1. Error Handling

Always add error workflows:
```
HTTP Request → [On Error] → Log to MongoDB → Alert on Slack
```

### 2. Rate Limiting

Use **Wait** nodes between API calls:
```
Loop → HTTP Request → Wait (1 second) → Next iteration
```

### 3. Caching

Use Redis MCP server to cache frequent queries:
```
Check Redis → [If miss] → Call API → Store in Redis → Return
```

### 4. Monitoring

Log all MCP operations:
```
Every workflow → [On completion] → Log to MongoDB with timestamp, duration, status
```

---

## 📊 Performance Optimization

1. **Batch operations** - Group multiple MCP calls
2. **Parallel execution** - Use n8n's split/merge nodes
3. **Cache results** - Use Redis MCP server
4. **Schedule wisely** - Avoid peak hours for heavy operations
5. **Use webhooks** - Instead of polling when possible

---

## 🔗 Integration with Other Services

### Combine MCP with n8n Native Nodes

```
GitHub Native Node → MCP Playwright (test) → MCP Stripe (process payment)
```

### Trigger MCP from External Sources

```
Webhook → Parse payload → MCP operation → Response
```

---

## 📚 Ready-to-Use Workflow Templates

I can create n8n workflow JSON templates for:

1. ✅ GitHub CI/CD Pipeline
2. ✅ Stripe Payment Monitoring
3. ✅ Grafana Alert System
4. ✅ Web Scraping Pipeline
5. ✅ Database Backup Automation
6. ✅ Documentation Generator
7. ✅ Homelab Health Check
8. ✅ Social Media Automation

Would you like me to generate specific workflow JSON files?

---

## 🔗 Related Documentation

- [MCP Setup Checklist](/home/chris/github/hephaestus-infra/docs/mcp-setup-checklist.md)
- [MCP Authentication Guide](/home/chris/github/hephaestus-infra/docs/mcp-authentication-guide.md)
- [Cursor IDE Integration](/home/chris/github/hephaestus-infra/docs/mcp-cursor-integration.md)

---

**Last Updated:** 2025-11-04  
**Status:** Ready for implementation  
**n8n Location:** `/home/chris/apps/n8n/`

