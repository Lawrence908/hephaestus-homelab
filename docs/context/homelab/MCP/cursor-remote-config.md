# 🔗 Cursor IDE Remote MCP Configuration

> Connect Cursor IDE from your PC to MCP servers running on Linux server

**Server IP:** `192.168.50.70`  
**Setup:** Docker Engine CLI (not Docker Desktop)  
**Access:** Remote network connection

---

## 🎯 Architecture

```
┌─────────────────────┐         ┌─────────────────────────┐
│   Your PC           │         │   Linux Server          │
│                     │         │   (192.168.50.70)       │
│  ┌───────────────┐  │         │                         │
│  │  Cursor IDE   │  │  HTTP   │  ┌──────────────────┐   │
│  │               │──┼────────▶│  │ MCP Gateway      │   │
│  │  mcp.json     │  │  :3000  │  │ Port 3000        │   │
│  └───────────────┘  │         │  └────────┬─────────┘   │
│                     │         │           │             │
└─────────────────────┘         │           │             │
                                │  ┌────────▼─────────┐   │
                                │  │ 40 MCP Servers   │   │
                                │  │ (via Docker CLI) │   │
                                │  └──────────────────┘   │
                                └─────────────────────────┘
```

---

## 🚀 Setup Instructions

### Step 1: Start MCP Gateway on Linux Server

**Option A: Using the Script (Recommended)**

```bash
# On the Linux server (hephaestus)
/home/chris/github/hephaestus-infra/scripts/start-mcp-gateway.sh
```

This will:
- Start the gateway on port 3000
- Enable all 40 servers
- Run in the background
- Show you the connection details

**Option B: Manual Start**

```bash
# On the Linux server
docker mcp gateway run --port 3000 --enable-all-servers &
```

**Option C: docker compose (persistent service)**

```bash
cd /home/chris/github/hephaestus-infra
docker compose -f docker-compose.mcp-gateway.yml up -d
```

---

### Step 2: Configure Cursor on Your PC

**Location:** `~/.cursor/mcp.json` (or `C:\Users\YourName\.cursor\mcp.json` on Windows)

Create or edit the file with this configuration:

```json
{
  "mcpServers": {
    "hephaestus": {
      "type": "http",
      "url": "http://192.168.50.70:3000",
      "enabled": true,
      "description": "Hephaestus homelab MCP servers (40 servers)"
    }
  }
}
```

**Alternative with multiple endpoints:**

```json
{
  "mcpServers": {
    "hephaestus-all": {
      "type": "http",
      "url": "http://192.168.50.70:3000",
      "enabled": true,
      "description": "All 40 MCP servers on homelab"
    }
  }
}
```

---

### Step 3: Restart Cursor IDE

Close and reopen Cursor IDE to load the new MCP configuration.

---

### Step 4: Test Connection

In Cursor chat, try:

```
@mcp list available servers
```

Or:

```
@mcp github list my repositories
```

Or:

```
Can you use the MCP server to list my Docker containers?
```

---

## ✅ Verification Checklist

### On Linux Server:

```bash
# Check gateway is running
ps aux | grep "docker mcp gateway"

# Check port is open
netstat -tlnp | grep 3000
# or
ss -tlnp | grep 3000

# View gateway logs
tail -f ~/.docker/mcp/gateway.log

# Test locally
curl http://localhost:3000/health
```

### On Your PC:

```bash
# Test network connectivity
curl http://192.168.50.70:3000/health

# Or from browser
# Open: http://192.168.50.70:3000/health
```

### In Cursor IDE:

- Check MCP status in Cursor settings
- Try `@mcp` command in chat
- Should see 40 available servers

---

## 🔧 Management Commands

### On Linux Server:

```bash
# Start gateway (script)
/home/chris/github/hephaestus-infra/scripts/start-mcp-gateway.sh

# Stop gateway
pkill -f "docker mcp gateway run"

# Restart gateway
pkill -f "docker mcp gateway run" && \
/home/chris/github/hephaestus-infra/scripts/start-mcp-gateway.sh

# View logs
tail -f ~/.docker/mcp/gateway.log

# Check status
docker mcp server ls
docker mcp oauth ls
```

### Using docker compose:

```bash
cd /home/chris/github/hephaestus-infra

# Start
docker compose -f docker-compose.mcp-gateway.yml up -d

# Stop
docker compose -f docker-compose.mcp-gateway.yml down

# View logs
docker compose -f docker-compose.mcp-gateway.yml logs -f

# Restart
docker compose -f docker-compose.mcp-gateway.yml restart
```

---

## 🔐 Security Considerations

### 1. Firewall Rules

The gateway is exposed on your local network (192.168.50.70:3000). Ensure:

```bash
# Check if port is accessible
sudo ufw status
sudo ufw allow from 192.168.50.0/24 to any port 3000 comment "MCP Gateway"
```

### 2. Network Access

- Only accessible on local network (192.168.50.x)
- Not exposed to internet
- Use Tailscale/VPN for remote access from outside network

### 3. Authentication

- GitHub OAuth: Already configured
- API keys: Stored in `~/.mcp_env`
- Secrets: Managed by Docker

---

## 🐛 Troubleshooting

### Issue: Connection Refused

**Check on server:**
```bash
# Is gateway running?
ps aux | grep "docker mcp gateway"

# Is port open?
netstat -tlnp | grep 3000

# Check firewall
sudo ufw status
```

**Test from PC:**
```bash
# Can you reach the server?
ping 192.168.50.70

# Can you reach the port?
telnet 192.168.50.70 3000
# or
curl http://192.168.50.70:3000/health
```

### Issue: Gateway Won't Start

```bash
# Check logs
cat ~/.docker/mcp/gateway.log

# Check if port is already in use
netstat -tlnp | grep 3000

# Try different port
docker mcp gateway run --port 3001 --enable-all-servers &
```

### Issue: MCP Not Showing in Cursor

1. **Verify mcp.json location:**
   - Linux/Mac: `~/.cursor/mcp.json`
   - Windows: `C:\Users\YourName\.cursor\mcp.json`

2. **Check JSON syntax:**
   ```bash
   cat ~/.cursor/mcp.json | jq .
   ```

3. **Restart Cursor completely**

4. **Check Cursor logs** (in Cursor: Help → Show Logs)

### Issue: "OAuth Not Authorized" Errors

This is expected for GitHub until you authorize:

```bash
# On the Linux server
docker mcp oauth authorize github
```

Then test again in Cursor.

---

## 📊 Available Servers (40 Total)

Once connected, you'll have access to:

- **Infrastructure:** github, dockerhub, git, filesystem, desktop-commander
- **Databases:** postgres, mongodb, redis
- **Monitoring:** grafana
- **APIs:** openapi, postman, mcp-api-gateway
- **Automation:** playwright, puppeteer, firecrawl, fetch
- **Productivity:** notion, obsidian, linear, slack
- **AI:** sequentialthinking, memory, wolfram-alpha
- **Search:** brave, tavily, wikipedia, duckduckgo
- **Business:** stripe, airtable, nasdaq-data-link
- **Communication:** mcp-discord, youtube_transcript
- And more!

---

## 💡 Pro Tips

1. **Use Tailscale for remote access** outside your local network
2. **Create systemd service** for automatic gateway startup
3. **Monitor gateway logs** for debugging: `tail -f ~/.docker/mcp/gateway.log`
4. **Test locally first** on the server before testing from PC
5. **Use specific server names** in Cursor: `@mcp github <command>`

---

## 🔗 Related Documentation

- [MCP Master Guide](/home/chris/github/hephaestus-infra/docs/context/homelab/MCP/MCP-MASTER-GUIDE.md)
- [MCP Setup Checklist](/home/chris/github/hephaestus-infra/docs/context/homelab/MCP/mcp-setup-checklist.md)
- [Authentication Guide](/home/chris/github/hephaestus-infra/docs/context/homelab/MCP/mcp-authentication-guide.md)

---

## 📝 Example mcp.json for Your PC

**Copy this to `~/.cursor/mcp.json` on your PC:**

```json
{
  "mcpServers": {
    "hephaestus": {
      "type": "http",
      "url": "http://192.168.50.70:3000",
      "enabled": true,
      "description": "Hephaestus homelab - 40 MCP servers",
      "timeout": 30000
    }
  }
}
```

---

**Last Updated:** 2025-11-04  
**Status:** ✅ Ready for remote connection  
**Server:** hephaestus (192.168.50.70)



