# Hephaestus Homelab - Service Status Tracker

## Overview

Complete tracking document for all homelab services with local, Tailscale, and public access URLs. This document provides real-time status of all services and their accessibility across multiple access methods.

## 🎯 Current Status Overview

### ✅ Working Services (All Public Subdomains)
- **Landing Page**: `https://chrislawrence.ca` ✅
- **Portfolio**: `https://portfolio.chrislawrence.ca` ✅
- **SchedShare**: `https://schedshare.chrislawrence.ca` ✅
- **CapitolScope**: `https://capitolscope.chrislawrence.ca` ✅
- **MagicPages**: `https://magicpages.chrislawrence.ca` ✅
- **MagicPages API**: `https://magicpages-api.chrislawrence.ca` ✅
- **EventSphere**: `https://eventsphere.chrislawrence.ca` ✅

### 🔒 Protected Services (Cloudflare Access)
- **Dev Environment**: `https://dev.chrislawrence.ca` ✅
- **Monitor**: `https://monitor.chrislawrence.ca` ✅
- **IoT Services**: `https://iot.chrislawrence.ca` ✅
- **Minecraft**: `https://minecraft.chrislawrence.ca` ✅
- **AI Services**: `https://ai.chrislawrence.ca` ✅
- **n8n**: `https://n8n.chrislawrence.ca` ✅

### 🎉 Cloudflare Tunnel Status
- **Tunnel ID**: `3a9f1023-0d6c-49ff-900d-32403e4309f8`
- **Status**: ✅ Active and routing all traffic correctly
- **DNS**: ✅ All subdomains configured via Published Application Routes
- **Access Control**: ✅ Public/Protected separation working perfectly

## 📊 Complete Service Catalog

### 🌐 Infrastructure & Monitoring Services

| Service | Local URL | Tailscale URL | Public URL | Port | Status |
|---------|-----------|---------------|------------|------|--------|
| **Caddy** | `http://192.168.50.70:80` | `http://hephaestus.tailaa3ef2.ts.net` | N/A | 80 | ✅ Active |
| **Portainer** | `http://192.168.50.70:9000` | `http://hephaestus.tailaa3ef2.ts.net:9000` | `https://dev.chrislawrence.ca/docker` | 9000 | ✅ Active |
| **Uptime Kuma** | `http://192.168.50.70:3001` | `http://hephaestus.tailaa3ef2.ts.net:3001` | `https://uptime.chrislawrence.ca` | 3001 | ✅ Active |
| **Grafana** | `http://192.168.50.70:3000` | `http://hephaestus.tailaa3ef2.ts.net:3000` | `https://dev.chrislawrence.ca/metrics` | 3000 | ✅ Active |
| **Prometheus** | `http://192.168.50.70:9090` | `http://hephaestus.tailaa3ef2.ts.net:9090` | `https://dev.chrislawrence.ca/prometheus` | 9090 | ✅ Active |
| **Dashy** | `http://192.168.50.70:8082` | `http://hephaestus.tailaa3ef2.ts.net:8082` | `https://dev.chrislawrence.ca` | 8082 | ✅ Active |
| **Organizr** | `http://192.168.50.70:8086` | `http://hephaestus.tailaa3ef2.ts.net:8086` | `https://dev.chrislawrence.ca/organizr` | 8086 | ✅ Active |
| **IT-Tools** | `http://192.168.50.70:8081` | `http://hephaestus.tailaa3ef2.ts.net:8081` | `https://dev.chrislawrence.ca/tools` | 8081 | ✅ Active |
| **Glances** | `http://192.168.50.70:61208` | `http://hephaestus.tailaa3ef2.ts.net:61208` | `https://dev.chrislawrence.ca/system` | 61208 | ✅ Active |
| **cAdvisor** | `http://192.168.50.70:8080` | `http://hephaestus.tailaa3ef2.ts.net:8080` | `https://dev.chrislawrence.ca/containers` | 8080 | ✅ Active |
| **Node Exporter** | `http://192.168.50.70:9100` | `http://hephaestus.tailaa3ef2.ts.net:9100` | N/A | 9100 | ✅ Active |

### 🚀 Application Services

| Service | Local URL | Tailscale URL | Public URL | Port | Status |
|---------|-----------|---------------|------------|------|--------|
| **Portfolio** | `http://192.168.50.70:8110` | `http://hephaestus.tailaa3ef2.ts.net:8110` | `https://portfolio.chrislawrence.ca` | 8110 | ✅ Active |
| **SchedShare** | `http://192.168.50.70:8130` | `http://hephaestus.tailaa3ef2.ts.net:8130` | `https://schedshare.chrislawrence.ca` | 8130 | ✅ Active |
| **CapitolScope Frontend** | `http://192.168.50.70:8121` | `http://hephaestus.tailaa3ef2.ts.net:8121` | `https://capitolscope.chrislawrence.ca` | 8121 | ✅ Active |
| **CapitolScope API** | `http://192.168.50.70:8120` | `http://hephaestus.tailaa3ef2.ts.net:8120` | N/A | 8120 | ✅ Active |
| **MagicPages Frontend** | `http://192.168.50.70:8101` | `http://hephaestus.tailaa3ef2.ts.net:8101` | `https://magicpages.chrislawrence.ca` | 8101 | ✅ Active |
| **MagicPages API** | `http://192.168.50.70:8100` | `http://hephaestus.tailaa3ef2.ts.net:8100` | `https://magicpages-api.chrislawrence.ca` | 8100 | ✅ Active |
| **EventSphere** | `http://192.168.50.70:8140` | `http://hephaestus.tailaa3ef2.ts.net:8140` | `https://eventsphere.chrislawrence.ca` | 8140 | ✅ Active |

### 🛠️ Development Tools

| Service | Local URL | Tailscale URL | Public URL | Port | Status |
|---------|-----------|---------------|------------|------|--------|
| **n8n** | `http://192.168.50.70:5678` | `http://hephaestus.tailaa3ef2.ts.net:5678` | `https://n8n.chrislawrence.ca` | 5678 | ✅ Active |
| **Obsidian** | `http://192.168.50.70:8060` | `http://hephaestus.tailaa3ef2.ts.net:8060` | `https://dev.chrislawrence.ca/notes` | 8060 | ✅ Active |

### ⚡ Specialized Services (IoT, AI, Gaming)

| Service | Local URL | Tailscale URL | Public URL | Port | Status |
|---------|-----------|---------------|------------|------|--------|
| **Home Assistant** | `http://192.168.50.70:8154` | `http://hephaestus.tailaa3ef2.ts.net:8154` | `https://iot.chrislawrence.ca/homeassistant` | 8154 | ✅ Active |
| **MQTT Explorer** | `http://192.168.50.70:8152` | `http://hephaestus.tailaa3ef2.ts.net:8152` | `https://iot.chrislawrence.ca/mqtt` | 8152 | ✅ Active |
| **Node-RED** | `http://192.168.50.70:8155` | `http://hephaestus.tailaa3ef2.ts.net:8155` | `https://iot.chrislawrence.ca/nodered` | 8155 | ✅ Active |
| **Grafana IoT** | N/A | N/A | `https://iot.chrislawrence.ca/grafana` | 3002 | ✅ Active |
| **InfluxDB** | `http://192.168.50.70:8157` | `http://hephaestus.tailaa3ef2.ts.net:8157` | `https://iot.chrislawrence.ca/influxdb` | 8157 | ✅ Active |
| **Minecraft Map** | `http://192.168.50.70:8159` | `http://hephaestus.tailaa3ef2.ts.net:8159` | `https://minecraft-map.chrislawrence.ca` | 8159 | ✅ Active |
| **Open WebUI** | `http://192.168.50.70:8189` | `http://hephaestus.tailaa3ef2.ts.net:8189` | `https://ai.chrislawrence.ca/webui` | 8189 | ✅ Active |
| **ComfyUI** | N/A | N/A | `https://ai.chrislawrence.ca/comfyui` | 8188 | 🟡 Configured |
| **OpenRouter Proxy** | `http://192.168.50.70:8190` | `http://hephaestus.tailaa3ef2.ts.net:8190` | `https://ai.chrislawrence.ca/openrouter` | 8190 | ✅ Active |
| **Model Manager** | N/A | N/A | `https://ai.chrislawrence.ca/models` | 8191 | 🟡 Configured |

## 🎯 Quick Reference URLs

### Public Access (No Authentication)
```
https://chrislawrence.ca
https://portfolio.chrislawrence.ca
https://schedshare.chrislawrence.ca
https://capitolscope.chrislawrence.ca
https://magicpages.chrislawrence.ca
https://magicpages-api.chrislawrence.ca
https://eventsphere.chrislawrence.ca
```

### Protected Access (Cloudflare Access Required)
```
https://dev.chrislawrence.ca
https://monitor.chrislawrence.ca
https://uptime.chrislawrence.ca
https://iot.chrislawrence.ca
https://minecraft.chrislawrence.ca
https://ai.chrislawrence.ca
https://n8n.chrislawrence.ca
```

### Local Network Access (192.168.50.70)
```
http://192.168.50.70:80       # Caddy
http://192.168.50.70:3000     # Grafana
http://192.168.50.70:3001     # Uptime Kuma
http://192.168.50.70:8082     # Dashy
http://192.168.50.70:9000     # Portainer
http://192.168.50.70:9090     # Prometheus
```

### Tailscale Access (hephaestus.tailaa3ef2.ts.net)
```
http://hephaestus.tailaa3ef2.ts.net       # Caddy
http://hephaestus.tailaa3ef2.ts.net:3000  # Grafana
http://hephaestus.tailaa3ef2.ts.net:3001  # Uptime Kuma
http://hephaestus.tailaa3ef2.ts.net:8082  # Dashy
http://hephaestus.tailaa3ef2.ts.net:9000  # Portainer
http://hephaestus.tailaa3ef2.ts.net:9090  # Prometheus
```

## 🔧 Service Port Ranges

### Port Assignment Strategy
- **80-443**: Reverse proxy (Caddy)
- **3000-3999**: Core infrastructure (Grafana, Uptime Kuma)
- **5000-5999**: Development tools (n8n)
- **8000-8099**: System tools (cAdvisor, IT-Tools, etc.)
- **8100-8149**: Application services
- **8150-8199**: Specialized services (IoT, AI, Gaming)
- **9000-9999**: Management & metrics (Portainer, Prometheus)
- **61208**: Glances system monitoring

## 📋 Service Health Checks

### Public Services Health Check
```bash
# Test all public services
curl -I https://chrislawrence.ca
curl -I https://portfolio.chrislawrence.ca
curl -I https://schedshare.chrislawrence.ca
curl -I https://capitolscope.chrislawrence.ca
curl -I https://magicpages.chrislawrence.ca
curl -I https://magicpages-api.chrislawrence.ca
curl -I https://eventsphere.chrislawrence.ca
```

### Protected Services Health Check (Should redirect to Cloudflare Access)
```bash
curl -I https://dev.chrislawrence.ca
curl -I https://monitor.chrislawrence.ca
curl -I https://iot.chrislawrence.ca
curl -I https://minecraft.chrislawrence.ca
curl -I https://ai.chrislawrence.ca
curl -I https://n8n.chrislawrence.ca
curl -I https://uptime.chrislawrence.ca
```

### Local Services Health Check
```bash
# Infrastructure services
curl -I http://192.168.50.70:80
curl -I http://192.168.50.70:3000
curl -I http://192.168.50.70:3001
curl -I http://192.168.50.70:9000
curl -I http://192.168.50.70:9090

# Application services
curl -I http://192.168.50.70:8110  # Portfolio
curl -I http://192.168.50.70:8130  # SchedShare
curl -I http://192.168.50.70:8121  # CapitolScope
curl -I http://192.168.50.70:8101  # MagicPages
curl -I http://192.168.50.70:8140  # EventSphere
```

### Tunnel Status
```bash
# Check tunnel status
sudo systemctl status cloudflared

# View tunnel logs
sudo journalctl -u cloudflared -f

# Test tunnel connectivity
docker compose -f proxy/docker-compose.yml ps cloudflared
docker compose -f proxy/docker-compose.yml logs cloudflared
```

## 🎉 Success Summary

### What We Accomplished
1. ✅ **Cloudflare Tunnel** - Active tunnel `3a9f1023-0d6c-49ff-900d-32403e4309f8` routing all traffic
2. ✅ **Multi-Access Architecture** - Local, Tailscale, and Public access methods
3. ✅ **Subdomain Routing** - All subdomains properly configured and accessible
4. ✅ **Public/Protected Separation** - Clear access control with Cloudflare Access
5. ✅ **Comprehensive Service Catalog** - 30+ services documented with all access methods
6. ✅ **Port Standardization** - Organized port ranges for easy management

### Key Technical Implementation
- **Access Methods**: Three-tier access (Local LAN, Tailscale VPN, Public Internet)
- **Port Management**: Organized port ranges by service category
- **Security Layers**: Cloudflare Access + Caddy auth + service-level auth
- **Service Discovery**: Dashy dashboard + comprehensive documentation

## 📊 Status Legend

- ✅ **Active**: Service is running and accessible
- 🟡 **Configured**: Service configured but may not be started
- 🔄 **Partial**: Service has issues but partially working
- ❌ **Down**: Service is not running or not accessible
- 🔒 **Private**: LAN-only access
- 🌍 **Public**: Accessible via public domain

## 🔄 Future Enhancements

1. 🟡 **ComfyUI Integration** - Complete AI image generation setup
2. 🟡 **Model Manager** - Centralized AI model management
3. 🟡 **Additional Monitoring** - Expand metrics collection
4. 🟡 **IoT Device Integration** - Add more IoT devices to Home Assistant
5. 🟡 **Backup Automation** - Automated backup procedures for all services

## Related Documentation

- **[Service Architecture](./infra/services.md)** - Detailed service definitions and architecture
- **[Application Services](./apps/applications.md)** - Application service documentation
- **[Network Architecture](./infra/networks.md)** - Docker network configuration
- **[Security Configuration](./infra/security.md)** - Authentication and access control
- **[Monitoring Setup](./infra/monitoring.md)** - Comprehensive monitoring configuration

## Service Configuration Reference

For machine-readable service configuration with all ports, URLs, and management details:
- **[services-config.json](./services-config.json)** - Complete service configuration database

---

**Last Updated**: 2025-11-04
**Status**: ✅ All critical services operational
**Tunnel ID**: `3a9f1023-0d6c-49ff-900d-32403e4309f8`
**Network**: `homelab-web` (192.168.50.70)
**Access Methods**: Local Network, Tailscale VPN, Public Internet
