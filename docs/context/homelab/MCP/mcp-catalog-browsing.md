# 🔍 Browsing the MCP Catalog

## 📋 List All Available Servers

### Basic List
```bash
docker mcp server list
```

Output: Comma-separated list of all available servers

### JSON Format
```bash
docker mcp server list --json
```

Output: JSON array of server names

### Pretty Print with jq
```bash
docker mcp server list --json | jq -r '.[]'
```

Output: One server per line

---

## 🔎 Finding Specific Servers

### Search for Servers by Keyword
```bash
docker mcp server list | tr ',' '\n' | grep -i "search_term"
```

Examples:
```bash
# Find database-related servers
docker mcp server list | tr ',' '\n' | grep -i "db\|database\|mongo\|postgres\|redis"

# Find API-related servers
docker mcp server list | tr ',' '\n' | grep -i "api\|openapi"

# Find automation servers
docker mcp server list | tr ',' '\n' | grep -i "auto\|script\|command"
```

---

## 📊 Server Status and Details

### Check if a Server is Enabled
```bash
docker mcp server status <server-name>
```

### List Only Enabled Servers
```bash
# This will show which servers are currently enabled
docker mcp gateway status
```

---

## ⚙️ Managing Servers

### Enable a Server
```bash
docker mcp server enable <server-name>
```

### Disable a Server
```bash
docker mcp server disable <server-name>
```

### Enable Multiple Servers at Once
```bash
docker mcp server enable server1 server2 server3
```

---

## 🎯 Complete Catalog (as of 2025-11-04)

**Total: 40 servers**

1. airtable-mcp-server
2. apify-mcp-server
3. brave
4. context7
5. desktop-commander
6. dockerhub
7. duckduckgo
8. fetch
9. filesystem
10. firecrawl
11. git
12. github
13. google-maps
14. grafana
15. linear
16. markdownify
17. mcp-api-gateway
18. mcp-discord
19. memory
20. mongodb
21. nasdaq-data-link
22. node-code-sandbox
23. notion
24. obsidian
25. openapi
26. openapi-schema
27. playwright
28. postgres
29. postman
30. puppeteer
31. redis
32. sequentialthinking
33. slack
34. stripe
35. tavily
36. time
37. waystation
38. wikipedia-mcp
39. wolfram-alpha
40. youtube_transcript

---

## 🔧 Docker Desktop UI

For a visual browsing experience:

1. Open **Docker Desktop**
2. Go to **Extensions** in the left sidebar
3. Install **MCP Toolkit** (if not already installed)
4. Navigate to the **MCP Toolkit** section
5. Browse the **Catalog** tab
6. Click on any server to see:
   - Description
   - Configuration options
   - Authentication requirements
   - Enable/disable toggle

---

## 💡 Quick Reference Commands

```bash
# List all servers
docker mcp server list

# List in JSON format
docker mcp server list --json

# Pretty print server list
docker mcp server list --json | jq -r '.[]' | sort

# Count total servers
docker mcp server list --json | jq 'length'

# Enable a server
docker mcp server enable github

# Disable a server
docker mcp server disable github

# Check MCP Gateway status
docker mcp gateway status

# Get help
docker mcp --help
docker mcp server --help
```

---

## 📝 Notes

- Server names are **case-sensitive**
- Use exact names from the catalog (e.g., `dockerhub` not `docker-hub`)
- Use `postgres` not `postgresql`
- Some servers require authentication/API keys after enabling
- The catalog is curated and maintained by Docker/Anthropic

---

## 🔗 Related Documentation

- [MCP Setup Checklist](/home/chris/github/hephaestus-infra/docs/mcp-setup-checklist.md)
- [Enable MCP Servers Script](/home/chris/github/hephaestus-infra/scripts/enable-mcp-servers.sh)
- [Docker MCP Toolkit Docs](https://docs.docker.com/ai/mcp-catalog-and-toolkit/)

