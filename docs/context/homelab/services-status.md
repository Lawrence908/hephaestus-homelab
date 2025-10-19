# Hephaestus Homelab - Service Status Tracker

## Overview

Complete tracking document for all homelab services with local, proxy, and public access URLs. This document provides real-time status of all services and their accessibility.

## 🎯 Current Status Overview

### ✅ Working Services
- Portfolio (Public)
- SchedShare (Proxy working)
- EventSphere (Proxy working)
- Organizr (Proxy working)
- Portainer (Proxy working)
- Uptime Kuma (Proxy working)
- Grafana (Proxy working)
- Prometheus (Proxy working)
- cAdvisor (Proxy working)
- Glances (Proxy working)
- IT-Tools (Proxy working)
- MagicPages (Proxy working)
- n8n (Proxy working)
- CapitolScope Backend (Proxy working)
- CapitolScope Frontend (Proxy working)
- Obsidian (Direct HTTPS access working)

### 🤖 AI Services (New)
- Ollama (Local LLM inference)
- Open WebUI (AI chat interface)
- ComfyUI (Image generation)
- OpenRouter Proxy (Cloud AI access)
- Model Manager (Model management)

## 📊 Complete Service Links Table

### 🏠 Infrastructure Services

| Service | Direct Port (LAN) | Proxy Port (LAN) | Public URL | Status | Notes |
|---------|------------------|------------------|------------|--------|-------|
| **Organizr** | `http://192.168.50.70:8082` | N/A (Main Dashboard) | `https://dashboard.chrislawrence.ca` | ✅ Working | Public access via Cloudflare |
| **Portainer** | `http://192.168.50.70:9000` | `http://192.168.50.70:8084` | `https://chrislawrence.ca/docker` | ✅ Working | Proxy configured and working |
| **Uptime Kuma** | `http://192.168.50.70:3001` | `http://192.168.50.70:8083` | `https://chrislawrence.ca/uptime` | ✅ Working | Proxy configured and working |
| **Grafana** | `http://192.168.50.70:3000` | `http://192.168.50.70:8085` | `https://chrislawrence.ca/metrics` | ✅ Working | Proxy configured and working |
| **Prometheus** | `http://192.168.50.70:9090` | `http://192.168.50.70:8086` | `https://chrislawrence.ca/prometheus` | ✅ Working | Proxy configured and working |
| **cAdvisor** | `http://192.168.50.70:8080` | `http://192.168.50.70:8087` | `https://chrislawrence.ca/containers` | ✅ Working | Proxy configured and working |
| **Glances** | `http://192.168.50.70:61208` | `http://192.168.50.70:8088` | `https://chrislawrence.ca/system` | ✅ Working | Proxy configured and working |
| **IT-Tools** | `http://192.168.50.70:8081` | `http://192.168.50.70:8089` | `https://chrislawrence.ca/tools` | ✅ Working | Proxy configured and working |

### 📱 Application Services

| Application | Direct Port (LAN) | Public URL | Status | Notes |
|-------------|------------------|------------|--------|-------|
| **Portfolio** | `http://192.168.50.70:8110` | `https://chrislawrence.ca/portfolio` | ✅ Working | Public access confirmed |
| **SchedShare** | `http://192.168.50.70:8130` | `https://chrislawrence.ca/schedshare` | ✅ Working | Public access configured |
| **MagicPages API** | `http://192.168.50.70:8100` | `http://192.168.50.70:8091` | `https://chrislawrence.ca/magicpages-api` | ✅ Working | Proxy configured and working |
| **MagicPages Frontend** | `http://192.168.50.70:8101` | N/A | `https://chrislawrence.ca/magicpages` | ✅ Working | Direct access working |
| **CapitolScope Frontend** | `http://192.168.50.70:5173` | `http://192.168.50.70:8121` | `https://chrislawrence.ca/capitolscope` | ✅ Working | Public access configured |
| **CapitolScope Backend** | `http://192.168.50.70:8001` | `http://192.168.50.70:8120` | `https://chrislawrence.ca/capitolscope/api` | ✅ Working | Public access configured |
| **EventSphere** | `http://192.168.50.70:8140` | `https://chrislawrence.ca/eventsphere` | ✅ Working | Public access configured |
| **n8n** | `http://192.168.50.70:5678` | `http://192.168.50.70:8092` | `https://chrislawrence.ca/n8n` | ✅ Working | Proxy configured and working |
| **Obsidian** | `https://192.168.50.70:8061` | `https://192.168.50.70:8061` | `https://chrislawrence.ca/notes` | ✅ Working | Use direct HTTPS - middle-click for full screen |

### 🤖 AI Inference Services

| Service | Direct Port (LAN) | Proxy Port (LAN) | Public URL | Status | Notes |
|---------|------------------|------------------|------------|--------|-------|
| **Ollama API** | `http://192.168.50.70:11434` | N/A | `https://chrislawrence.ca/ai/api` | 🟡 Pending | Local LLM inference engine |
| **Open WebUI** | `http://192.168.50.70:8189` | `http://192.168.50.70:8161` | `https://chrislawrence.ca/ai` | ✅ Working | Proxy configured and working |
| **ComfyUI** | `http://192.168.50.70:8188` | `http://192.168.50.70:8162` | `https://chrislawrence.ca/comfyui` | 🟡 Pending | Image generation workflows |
| **OpenRouter Proxy** | `http://192.168.50.70:8190` | `http://192.168.50.70:8163` | `https://chrislawrence.ca/openrouter` | ✅ Working | Backend proxy configured and working |
| **Model Manager** | `http://192.168.50.70:8191` | `http://192.168.50.70:8164` | `https://chrislawrence.ca/models` | 🟡 Pending | Model download and management |

### 🔧 IoT & Communication Services

| Service | Direct Port (LAN) | Public URL | Status | Notes |
|---------|------------------|------------|--------|-------|
| **MQTT Explorer** | `http://192.168.50.70:8152` | `https://chrislawrence.ca/mqtt` | ❌ Not Working | Needs deployment |
| **Home Assistant** | `http://192.168.50.70:8154` | `https://chrislawrence.ca/homeassistant` | ❌ Not Working | Needs deployment |
| **Node-RED** | `http://192.168.50.70:8155` | `https://chrislawrence.ca/nodered` | ❌ Not Working | Needs deployment |
| **Grafana IoT** | `http://192.168.50.70:8156` | `https://chrislawrence.ca/grafana-iot` | ❌ Not Working | Needs deployment |

## 🎯 Organizr Tab Configuration

### ✅ Working Tabs (Ready for Organizr)
```
Portfolio: https://chrislawrence.ca/portfolio
SchedShare: http://192.168.50.70:8130
EventSphere: http://192.168.50.70:8140
Obsidian: https://192.168.50.70:8061 (middle-click for full screen - HTTPS required)
```

### 🔄 Needs Proxy Ports (For iframe embedding)
```
Portainer: http://192.168.50.70:8084 (proxy to 9000)
Uptime Kuma: http://192.168.50.70:8083 (proxy to 3001)
Grafana: http://192.168.50.70:8085 (proxy to 3000)
Prometheus: http://192.168.50.70:8086 (proxy to 9090)
cAdvisor: http://192.168.50.70:8087 (proxy to 8080)
Glances: http://192.168.50.70:8088 (proxy to 61208)
IT-Tools: http://192.168.50.70:8089 (proxy to 8081)
```

### ❌ Needs Deployment/Fixing
```
MagicPages API: http://192.168.50.70:8100 (error)
MagicPages Frontend: http://192.168.50.70:8101 (error)
CapitolScope: http://192.168.50.70:8120 (not working)
Obsidian: https://192.168.50.70:8061 (not working)
```

## 🔧 Immediate Action Items

### Priority 1: Fix Infrastructure Services
1. **Configure Caddy proxy ports** for infrastructure services (8083-8089)
2. **Test each proxy port** individually
3. **Add to Organizr** as working tabs

### Priority 2: Fix Application Services
1. **Debug MagicPages** error
2. **Deploy CapitolScope** 
3. **Configure Obsidian** HTTPS
4. **Deploy n8n** automation

### Priority 3: Public Access
1. **Configure Cloudflare Tunnel** for remaining services
2. **Test public URLs** 
3. **Update Organizr** with public URLs where appropriate

## 📋 Quick Reference URLs

### ✅ Currently Working
- **Organizr Dashboard**: `https://dashboard.chrislawrence.ca`
- **Portfolio**: `https://chrislawrence.ca/portfolio`
- **SchedShare**: `https://chrislawrence.ca/schedshare`
- **EventSphere**: `https://chrislawrence.ca/eventsphere`
- **CapitolScope Frontend**: `https://chrislawrence.ca/capitolscope`
- **CapitolScope Backend**: `https://chrislawrence.ca/capitolscope/api`

### 🔄 Needs Testing
- **Obsidian**: `https://192.168.50.70:8061` (cannot use through Organizr)
- **MagicPages API**: `http://192.168.50.70:8100` (error)
- **MagicPages Frontend**: `http://192.168.50.70:8101` (error)

### ❌ Not Deployed
- **Meshtastic MQTT Explorer**: `http://192.168.50.70:8152`
- **Home Assistant**: `http://192.168.50.70:8154`
- **Node-RED**: `http://192.168.50.70:8155`
- **Grafana IoT**: `http://192.168.50.70:8156`

## 🚨 Known Issues

### MagicPages Error
- API and Frontend both showing errors
- Need to check container logs
- Verify database connections
- Check environment variables

### Infrastructure Services Not Working
- All proxy ports (8083-8089) need Caddy configuration
- Services may be running but not accessible via proxy
- Need to verify Caddy routing rules

### HTTPS Services
- Obsidian requires HTTPS (Selkies limitation)
- Need proper SSL certificate configuration
- May need separate Caddy configuration

## 📊 Status Legend

- ✅ **Working**: Service is running and accessible
- 🔄 **Error**: Service has issues but partially working
- ❌ **Not Working**: Service is not running or not accessible
- 🟡 **Pending**: Service configured but not started
- 🔒 **Private**: LAN-only access
- 🌍 **Public**: Accessible via public domain

## 🔄 Next Steps

1. **Fix Caddy proxy configuration** for infrastructure services
2. **Debug MagicPages** application errors
3. **Deploy missing applications** (CapitolScope, n8n, etc.)
4. **Configure public access** for remaining services
5. **Update Organizr** with all working service URLs
6. **Test all links** and update this tracker

## Service Health Checks

### Infrastructure Services
```bash
# Check service status
docker compose -f docker-compose-infrastructure.yml ps

# Test proxy ports
curl -I http://192.168.50.70:8083 -u admin:admin123  # Uptime Kuma
curl -I http://192.168.50.70:8084 -u admin:admin123  # Portainer
curl -I http://192.168.50.70:8085 -u admin:admin123  # Grafana
curl -I http://192.168.50.70:8086 -u admin:admin123  # Prometheus
curl -I http://192.168.50.70:8087 -u admin:admin123  # cAdvisor
curl -I http://192.168.50.70:8088 -u admin:admin123  # Glances
curl -I http://192.168.50.70:8089 -u admin:admin123  # IT-Tools
```

### Application Services
```bash
# Test application services
curl -I http://192.168.50.70:8110  # Portfolio
curl -I http://192.168.50.70:8130  # SchedShare
curl -I http://192.168.50.70:8140  # EventSphere
curl -I http://192.168.50.70:8100  # MagicPages API
curl -I http://192.168.50.70:8101  # MagicPages Frontend
curl -I http://192.168.50.70:8120  # CapitolScope Backend
curl -I http://192.168.50.70:8121  # CapitolScope Frontend
```

### Public Access Tests
```bash
# Test public URLs
curl -I https://chrislawrence.ca/portfolio
curl -I https://chrislawrence.ca/schedshare
curl -I https://chrislawrence.ca/eventsphere
curl -I https://chrislawrence.ca/capitolscope
curl -I https://chrislawrence.ca/capitolscope/api
curl -I https://chrislawrence.ca/magicpages-api
curl -I https://chrislawrence.ca/docker -u admin:admin123
curl -I https://chrislawrence.ca/uptime -u admin:admin123
curl -I https://chrislawrence.ca/metrics -u admin:admin123
```

## Related Documentation

- [Application Services](./applications.md) - Application services and management
- [Infrastructure Services](./infra/services.md) - Service architecture and definitions
- [Network Architecture](./infra/networks.md) - Docker network setup
- [Deployment Guide](./infra/deployment.md) - Service deployment procedures

---

**Last Updated**: $(date)
**Status**: 🔄 Multiple services need configuration  
**Next Priority**: Fix infrastructure proxy ports and debug MagicPages
