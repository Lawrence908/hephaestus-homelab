# Hephaestus Homelab - Service Links Tracker

Complete tracking document for all homelab services with local, proxy, and public access URLs.

## 🎯 **Current Status Overview**

### **✅ Working Services**
- Portfolio (Public)
- SchedShare (Local only)
- EventSphere (Local only)
- Organizr (Public)
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

### **❌ Not Working**
- Obsidian (Docker compose syntax error)

---

## 📊 **Complete Service Links Table**

### **🏠 Infrastructure Services**

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

### **📱 Application Services**

| Application | Direct Port (LAN) | Public URL | Status | Notes |
|-------------|------------------|------------|--------|-------|
| **Portfolio** | `http://192.168.50.70:8110` | `https://chrislawrence.ca/portfolio` | ✅ Working | Public access confirmed |
| **SchedShare** | `http://192.168.50.70:8130` | `https://chrislawrence.ca/schedshare` | ✅ Working | Local only, public pending |
| **MagicPages API** | `http://192.168.50.70:8100` | `http://192.168.50.70:8091` | `https://chrislawrence.ca/magicpages-api` | ✅ Working | Proxy configured and working |
| **MagicPages Frontend** | `http://192.168.50.70:8101` | N/A | `https://chrislawrence.ca/magicpages` | ✅ Working | Direct access working |
| **CapitolScope Frontend** | `http://192.168.50.70:5173` | `http://192.168.50.70:8121` | `https://chrislawrence.ca/capitolscope-frontend` | ✅ Working | Proxy configured and working |
| **CapitolScope Backend** | `http://192.168.50.70:8001` | `http://192.168.50.70:8120` | `https://chrislawrence.ca/capitolscope` | ✅ Working | Proxy configured and working |
| **EventSphere** | `http://192.168.50.70:8140` | `https://chrislawrence.ca/eventsphere` | ✅ Working | Local only, public pending |
| **n8n** | `http://192.168.50.70:5678` | `http://192.168.50.70:8092` | `https://chrislawrence.ca/n8n` | ✅ Working | Proxy configured and working |
| **Obsidian** | `https://192.168.50.70:8061` | `https://chrislawrence.ca/notes` | ❌ Not Working | HTTPS required, needs config |

### **🔧 IoT & Communication Services**

| Service | Direct Port (LAN) | Public URL | Status | Notes |
|---------|------------------|------------|--------|-------|
| **MQTT Explorer** | `http://192.168.50.70:8152` | `https://chrislawrence.ca/mqtt` | ❌ Not Working | Needs deployment |
| **Home Assistant** | `http://192.168.50.70:8154` | `https://chrislawrence.ca/homeassistant` | ❌ Not Working | Needs deployment |
| **Node-RED** | `http://192.168.50.70:8155` | `https://chrislawrence.ca/nodered` | ❌ Not Working | Needs deployment |
| **Grafana IoT** | `http://192.168.50.70:8156` | `https://chrislawrence.ca/grafana-iot` | ❌ Not Working | Needs deployment |

---

## 🎯 **Organizr Tab Configuration**

### **✅ Working Tabs (Ready for Organizr)**
```
Portfolio: https://chrislawrence.ca/portfolio
SchedShare: http://192.168.50.70:8130
EventSphere: http://192.168.50.70:8140
```

### **🔄 Needs Proxy Ports (For iframe embedding)**
```
Portainer: http://192.168.50.70:8084 (proxy to 9000)
Uptime Kuma: http://192.168.50.70:8083 (proxy to 3001)
Grafana: http://192.168.50.70:8085 (proxy to 3000)
Prometheus: http://192.168.50.70:8086 (proxy to 9090)
cAdvisor: http://192.168.50.70:8087 (proxy to 8080)
Glances: http://192.168.50.70:8088 (proxy to 61208)
IT-Tools: http://192.168.50.70:8089 (proxy to 8081)
```

### **❌ Needs Deployment/Fixing**
```
MagicPages API: http://192.168.50.70:8100 (error)
MagicPages Frontend: http://192.168.50.70:8101 (error)
CapitolScope: http://192.168.50.70:8120 (not working)
Obsidian: https://192.168.50.70:8061 (not working)
```

---

## 🔧 **Immediate Action Items**

### **Priority 1: Fix Infrastructure Services**
1. **Configure Caddy proxy ports** for infrastructure services (8083-8089)
2. **Test each proxy port** individually
3. **Add to Organizr** as working tabs

### **Priority 2: Fix Application Services**
1. **Debug MagicPages** error
2. **Deploy CapitolScope** 
3. **Configure Obsidian** HTTPS
4. **Deploy n8n** automation

### **Priority 3: Public Access**
1. **Configure Cloudflare Tunnel** for remaining services
2. **Test public URLs** 
3. **Update Organizr** with public URLs where appropriate

---

## 📋 **Quick Reference URLs**

### **✅ Currently Working**
- **Organizr Dashboard**: `https://dashboard.chrislawrence.ca`
- **Portfolio**: `https://chrislawrence.ca/portfolio`
- **SchedShare**: `http://192.168.50.70:8130`
- **EventSphere**: `http://192.168.50.70:8140`

### **🔄 Needs Testing**
- **MagicPages API**: `http://192.168.50.70:8100` (error)
- **MagicPages Frontend**: `http://192.168.50.70:8101` (error)

### **❌ Not Deployed**
- **CapitolScope**: `http://192.168.50.70:8120`
- **Obsidian**: `https://192.168.50.70:8061`
- **All Infrastructure Services**: Need proxy port configuration

---

## 🚨 **Known Issues**

### **MagicPages Error**
- API and Frontend both showing errors
- Need to check container logs
- Verify database connections
- Check environment variables

### **Infrastructure Services Not Working**
- All proxy ports (8083-8089) need Caddy configuration
- Services may be running but not accessible via proxy
- Need to verify Caddy routing rules

### **HTTPS Services**
- Obsidian requires HTTPS (Selkies limitation)
- Need proper SSL certificate configuration
- May need separate Caddy configuration

---

## 📊 **Status Legend**

- ✅ **Working**: Service is running and accessible
- 🔄 **Error**: Service has issues but partially working
- ❌ **Not Working**: Service is not running or not accessible
- 🟡 **Pending**: Service configured but not started
- 🔒 **Private**: LAN-only access
- 🌍 **Public**: Accessible via public domain

---

## 🔄 **Next Steps**

1. **Fix Caddy proxy configuration** for infrastructure services
2. **Debug MagicPages** application errors
3. **Deploy missing applications** (CapitolScope, n8n, etc.)
4. **Configure public access** for remaining services
5. **Update Organizr** with all working service URLs
6. **Test all links** and update this tracker

---

**Last Updated**: October 13, 2025  
**Status**: 🔄 Multiple services need configuration  
**Next Priority**: Fix infrastructure proxy ports and debug MagicPages
