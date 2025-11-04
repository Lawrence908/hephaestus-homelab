# 🛠️ MCP Scripts

> Automation scripts for Docker MCP Server management

---

## 📋 Available Scripts

### 1. `enable-mcp-servers.sh`

**Purpose:** Enable MCP servers by priority level or project

**Usage:**
```bash
# Enable all 40 servers
./enable-mcp-servers.sh all

# Enable only core infrastructure (Priority 1)
./enable-mcp-servers.sh essential
# or
./enable-mcp-servers.sh 1

# Enable by priority
./enable-mcp-servers.sh 2  # DevOps & Web Automation
./enable-mcp-servers.sh 3  # Productivity + AI + Search
./enable-mcp-servers.sh 4  # Data & Communication

# Enable for specific projects
./enable-mcp-servers.sh magic-pages
./enable-mcp-servers.sh capitol-scope

# Show help
./enable-mcp-servers.sh help
```

**What it does:**
- Enables MCP servers based on priority or project needs
- Shows colorized output for success/failure
- Groups servers logically
- Provides next steps after completion

---

### 2. `configure-mcp-auth.sh`

**Purpose:** Interactive authentication setup for MCP servers

**Usage:**
```bash
# Run interactive setup
./configure-mcp-auth.sh
```

**What it does:**
- Guides you through OAuth setup (GitHub, etc.)
- Prompts for API keys (Stripe, Brave, Grafana, etc.)
- Configures database connection strings
- Creates `~/.mcp_env` file with all credentials
- Provides option to source environment immediately

**Configuration saved to:**
- `~/.mcp_env` - All API keys and tokens
- Can be added to `~/.bashrc` for persistence
- Can be used in docker compose files [[memory:9849171]]

**Interactive prompts for:**
- **HIGH Priority:** Stripe, Grafana
- **MEDIUM Priority:** Brave, Tavily, Nasdaq
- **LOW Priority:** Wolfram Alpha, Google Maps, Airtable
- **OPTIONAL:** Notion, Linear, Slack
- **Database URIs:** MongoDB, PostgreSQL, Redis

---

## 🚀 Quick Start Workflow

### First Time Setup

1. **Enable core servers:**
   ```bash
   ./enable-mcp-servers.sh essential
   ```

2. **Configure authentication:**
   ```bash
   ./configure-mcp-auth.sh
   ```

3. **Load environment:**
   ```bash
   source ~/.mcp_env
   ```

4. **Test in Cursor:**
   Open Cursor IDE and try: `@mcp github list repositories`

---

### Project-Specific Setup

#### For Magic Pages:
```bash
./enable-mcp-servers.sh magic-pages
./configure-mcp-auth.sh
# (Enter Stripe API key when prompted)
```

#### For CapitolScope:
```bash
./enable-mcp-servers.sh capitol-scope
./configure-mcp-auth.sh
# (Enter Nasdaq API key when prompted)
```

---

## 📁 Script Locations

```
/home/chris/github/hephaestus-infra/scripts/
├── enable-mcp-servers.sh      # Enable MCP servers
├── configure-mcp-auth.sh      # Configure authentication
└── README.md                  # This file
```

---

## 🔗 Related Documentation

- [MCP Master Guide](../docs/MCP-MASTER-GUIDE.md)
- [Setup Checklist](../docs/mcp-setup-checklist.md)
- [Authentication Guide](../docs/mcp-authentication-guide.md)
- [Cursor Integration](../docs/mcp-cursor-integration.md)
- [n8n Integration](../docs/mcp-n8n-integration.md)

---

## 💡 Tips

1. **Run scripts from any directory** - They use absolute paths
2. **Scripts are idempotent** - Safe to run multiple times
3. **Check help first** - `./script-name.sh help` for options
4. **Source env after auth** - `source ~/.mcp_env` to load API keys
5. **Add to bashrc** - `echo 'source ~/.mcp_env' >> ~/.bashrc` for persistence

---

## 🐛 Troubleshooting

### Issue: Permission Denied

```bash
chmod +x *.sh
```

### Issue: Script Not Found

```bash
# Ensure you're in the scripts directory
cd /home/chris/github/hephaestus-infra/scripts/

# Or use absolute path
/home/chris/github/hephaestus-infra/scripts/enable-mcp-servers.sh
```

### Issue: OAuth Fails

- Ensure Docker Desktop is running
- Update MCP Toolkit extension
- Try manual OAuth: `docker mcp oauth authorize github`

---

**Last Updated:** 2025-11-04  
**Status:** ✅ Production Ready

