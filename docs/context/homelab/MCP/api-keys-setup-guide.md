# 🔑 MCP API Keys Setup Guide

> Complete guide to obtaining API keys for all 40 MCP servers

**Last Updated:** 2025-11-04  
**Environment File:** `~/.docker/mcp/.env`

---

## 📋 Quick Start

1. **Copy the template:**
   ```bash
   cp ~/.docker/mcp/.env.template ~/.docker/mcp/.env
   ```

2. **Edit the file:**
   ```bash
   nano ~/.docker/mcp/.env
   # or
   vim ~/.docker/mcp/.env
   ```

3. **Fill in only the keys you need** (see priorities below)

4. **Restart the MCP gateway**

---

## 🎯 Priority Guide

### 🔴 **HIGH PRIORITY** (Start here)

These are essential for core functionality:

#### 1. GitHub
- **Why:** Repository access, code browsing, PR/issue management
- **Get from:** https://github.com/settings/tokens
- **Steps:**
  1. Click "Generate new token" → "Generate new token (classic)"
  2. Select scopes:
     - ✅ `repo` (Full control of private repositories)
     - ✅ `read:org` (Read org membership)
     - ✅ `read:user` (Read user profile)
  3. Generate and copy token
  4. Add to `.env`: `GITHUB_PERSONAL_ACCESS_TOKEN=ghp_...`

#### 2. Stripe (for Magic Pages)
- **Why:** Payment processing
- **Get from:** https://dashboard.stripe.com/apikeys
- **Steps:**
  1. Sign in to Stripe Dashboard
  2. Go to Developers → API keys
  3. Use **Test mode** for development
  4. Copy "Secret key" (starts with `sk_test_`)
  5. Add to `.env`: `STRIPE_SECRET_KEY=sk_test_...`

#### 3. Grafana (for homelab monitoring)
- **Why:** Query dashboards and metrics
- **Get from:** Your Grafana instance (http://grafana.local:3000)
- **Steps:**
  1. Log in to Grafana
  2. Go to Configuration → API Keys (or `/org/apikeys`)
  3. Click "Add API key"
  4. Name: "MCP Gateway", Role: "Viewer" or "Editor"
  5. Copy the key
  6. Add to `.env`: `GRAFANA_API_KEY=glsa_...`

---

### 🟠 **MEDIUM PRIORITY** (Add as needed)

#### 4. Brave Search
- **Why:** Web search capabilities
- **Get from:** https://brave.com/search/api/
- **Steps:**
  1. Sign up for Brave Search API
  2. Choose free tier (2,000 queries/month)
  3. Get API key from dashboard
  4. Add to `.env`: `BRAVE_API_KEY=BSA...`
- **Cost:** Free tier available

#### 5. Tavily
- **Why:** AI-optimized search
- **Get from:** https://tavily.com/
- **Steps:**
  1. Sign up for account
  2. Get API key from dashboard
  3. Add to `.env`: `TAVILY_API_TOKEN=tvly-...`
- **Cost:** Free tier: 1,000 requests/month

#### 6. Nasdaq Data Link (for CapitolScope)
- **Why:** Financial market data
- **Get from:** https://data.nasdaq.com/sign-up
- **Steps:**
  1. Create free account
  2. Go to Account Settings → API Key
  3. Copy API key
  4. Add to `.env`: `NASDAQ_DATA_LINK_API_KEY=...`
- **Cost:** Free tier available

#### 7. Wolfram Alpha
- **Why:** Computational queries
- **Get from:** https://products.wolframalpha.com/api/
- **Steps:**
  1. Sign up for developer account
  2. Create an AppID
  3. Free tier: 2,000 queries/month
  4. Add to `.env`: `WOLFRAM_ALPHA_API_KEY=...`
- **Cost:** Free tier available

---

### 🟢 **LOWER PRIORITY** (Optional)

#### 8. Notion
- **Why:** Workspace integration
- **Get from:** https://www.notion.so/my-integrations
- **Steps:**
  1. Go to https://www.notion.so/my-integrations
  2. Click "New integration"
  3. Give it a name, select workspace
  4. Copy "Internal Integration Token"
  5. Share pages/databases with the integration
  6. Add to `.env`: `NOTION_INTERNAL_INTEGRATION_TOKEN=secret_...`

#### 9. Slack
- **Why:** Workspace access, messaging
- **Get from:** https://api.slack.com/apps
- **Steps:**
  1. Create new app or use existing
  2. Go to OAuth & Permissions
  3. Add Bot Token Scopes (channels:read, chat:write, etc.)
  4. Install app to workspace
  5. Copy "Bot User OAuth Token"
  6. Add to `.env`: `SLACK_BOT_TOKEN=xoxb-...`

#### 10. Discord
- **Why:** Discord bot integration
- **Get from:** https://discord.com/developers/applications
- **Steps:**
  1. Create new application
  2. Go to Bot section
  3. Create bot and copy token
  4. Add to `.env`: `DISCORD_TOKEN=...`

#### 11. Google Maps
- **Why:** Maps and geolocation
- **Get from:** https://console.cloud.google.com/
- **Steps:**
  1. Create Google Cloud project
  2. Enable Maps JavaScript API
  3. Create credentials → API key
  4. Restrict key to Maps API
  5. Add to `.env`: `GOOGLE_MAPS_API_KEY=AIza...`
- **Cost:** $200 free credit/month

#### 12. Firecrawl
- **Why:** Web scraping service
- **Get from:** https://firecrawl.dev/
- **Steps:**
  1. Sign up for account
  2. Get API key from dashboard
  3. Add to `.env`: `FIRECRAWL_API_KEY=...`

#### 13. Apify
- **Why:** Web scraping platform
- **Get from:** https://console.apify.com/
- **Steps:**
  1. Sign up for account
  2. Go to Settings → Integrations
  3. Copy API token
  4. Add to `.env`: `APIFY_MCP_SERVER_APIFY_TOKEN=...`

#### 14. Airtable
- **Why:** Database operations
- **Get from:** https://airtable.com/create/tokens
- **Steps:**
  1. Create personal access token
  2. Select scopes (data.records:read, data.records:write)
  3. Select bases to access
  4. Add to `.env`: `AIRTABLE_MCP_SERVER_API_KEY=...`

#### 15. Postman
- **Why:** API testing
- **Get from:** https://web.postman.co/settings/me/api-keys
- **Steps:**
  1. Go to Settings → API Keys
  2. Generate API Key
  3. Add to `.env`: `POSTMAN_POSTMAN_API_KEY=...`

---

## 🗄️ **Database Connections**

#### PostgreSQL
```bash
POSTGRES_URL=postgresql://username:password@host:port/database

# Examples:
# Local: postgresql://postgres:password@localhost:5432/mydb
# Remote: postgresql://user:pass@192.168.50.70:5432/production
```

#### MongoDB
```bash
MONGODB_CONNECTION_STRING=mongodb://username:password@host:port/database

# Examples:
# Local: mongodb://localhost:27017
# With auth: mongodb://admin:password@localhost:27017
# Remote: mongodb://user:pass@192.168.50.70:27017/mydb
```

#### Redis
```bash
# Leave empty if no password
REDIS_PASSWORD=

# Or set password if secured
REDIS_PASSWORD=your_redis_password
```

---

## ✅ **Services That DON'T Need API Keys**

These work out of the box:

- ✅ **git** - Uses local git config
- ✅ **filesystem** - Local file access
- ✅ **desktop-commander** - Local commands
- ✅ **openapi** - Reads OpenAPI specs
- ✅ **openapi-schema** - Schema validation
- ✅ **playwright** - Browser automation
- ✅ **puppeteer** - Browser automation
- ✅ **fetch** - HTTP requests
- ✅ **markdownify** - HTML to Markdown
- ✅ **memory** - Local storage
- ✅ **sequentialthinking** - Local processing
- ✅ **time** - Time operations
- ✅ **wikipedia-mcp** - Public API
- ✅ **duckduckgo** - Public API
- ✅ **context7** - Local processing
- ✅ **node-code-sandbox** - Local execution

---

## 📝 Configuration File Format

Your `~/.docker/mcp/.env` should look like:

```bash
# Core services (fill these first)
GITHUB_PERSONAL_ACCESS_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxx
STRIPE_SECRET_KEY=sk_test_xxxxxxxxxxxxxxxxxxxxx
GRAFANA_API_KEY=glsa_xxxxxxxxxxxxxxxxxxxxx

# Databases (use local defaults or customize)
POSTGRES_URL=postgresql://localhost:5432/postgres
MONGODB_CONNECTION_STRING=mongodb://localhost:27017
REDIS_PASSWORD=

# Search services (add as needed)
BRAVE_API_KEY=BSA_xxxxxxxxxxxxxxxxxxxxx
TAVILY_API_TOKEN=tvly-xxxxxxxxxxxxxxxxxxxxx
NASDAQ_DATA_LINK_API_KEY=xxxxxxxxxxxxxxxxxxxxx

# Leave empty what you don't use
NOTION_INTERNAL_INTEGRATION_TOKEN=
SLACK_BOT_TOKEN=
DISCORD_TOKEN=
```

---

## 🔒 Security Best Practices

1. **Never commit `.env` to git**
   ```bash
   echo ".env" >> ~/.gitignore
   ```

2. **Use test/development keys** for non-production

3. **Restrict API key permissions** to minimum needed

4. **Rotate keys regularly** (every 90 days)

5. **Use separate keys per environment** (dev/staging/prod)

6. **Keep `.env.template` updated** but without actual keys

---

## 🚀 After Adding Keys

1. **Verify the file:**
   ```bash
   cat ~/.docker/mcp/.env
   ```

2. **Restart the MCP gateway:**
   ```bash
   pkill -f "docker mcp gateway"
   /home/chris/github/hephaestus-infra/scripts/start-mcp-gateway.sh
   ```

3. **Test in Cursor:**
   ```
   @mcp github list my repositories
   @mcp stripe list customers
   ```

---

## 💰 Cost Summary

| Service | Free Tier | Paid Starts At |
|---------|-----------|----------------|
| GitHub | ✅ Unlimited | N/A |
| Stripe | ✅ Free (pay-as-you-go) | Transaction fees |
| Grafana | ✅ Self-hosted free | N/A |
| Brave Search | ✅ 2,000/month | $5/month |
| Tavily | ✅ 1,000/month | $29/month |
| Nasdaq | ✅ Limited | $50/month |
| Wolfram Alpha | ✅ 2,000/month | $5/month |
| Google Maps | ✅ $200 credit | Pay-as-you-go |
| Most others | ✅ Free tier | Varies |

---

## 🔗 Quick Links

- **GitHub Tokens:** https://github.com/settings/tokens
- **Stripe Dashboard:** https://dashboard.stripe.com/apikeys
- **Brave Search:** https://brave.com/search/api/
- **Tavily:** https://tavily.com/
- **Nasdaq Data:** https://data.nasdaq.com/
- **Wolfram Alpha:** https://products.wolframalpha.com/api/
- **Google Cloud:** https://console.cloud.google.com/
- **Notion:** https://www.notion.so/my-integrations
- **Slack:** https://api.slack.com/apps
- **Discord:** https://discord.com/developers/applications

---

## 📚 Related Documentation

- [MCP Master Guide](/home/chris/github/hephaestus-infra/docs/context/homelab/MCP/MCP-MASTER-GUIDE.md)
- [Authentication Guide](/home/chris/github/hephaestus-infra/docs/context/homelab/MCP/mcp-authentication-guide.md)
- [Cursor Integration](/home/chris/github/hephaestus-infra/docs/context/homelab/MCP/cursor-remote-config.md)

---

**Last Updated:** 2025-11-04  
**Status:** ✅ Ready to configure



