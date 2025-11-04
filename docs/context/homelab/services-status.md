# Hephaestus Homelab - Service Status Tracker

## Overview

Complete tracking document for all homelab services with local, proxy, and public access URLs. This document provides real-time status of all services and their accessibility.

## 🎯 Current Status Overview

### ✅ Working Services (All Public Subdomains)
- **Landing Page**: `https://chrislawrence.ca` ✅
- **Portfolio**: `https://portfolio.chrislawrence.ca` ✅
- **SchedShare**: `https://schedshare.chrislawrence.ca` ✅
- **CapitolScope**: `https://capitolscope.chrislawrence.ca` ✅
- **MagicPages**: `https://magicpages.chrislawrence.ca` ✅
- **MagicPages API**: `https://api.magicpages.chrislawrence.ca` ✅
- **EventSphere**: `https://eventsphere.chrislawrence.ca` ✅

### 🔒 Protected Services (Cloudflare Access)
- **Dev Environment**: `https://dev.chrislawrence.ca` ✅
- **Monitor**: `https://monitor.chrislawrence.ca` ✅
- **IoT Services**: `https://iot.chrislawrence.ca` ✅
- **Minecraft**: `https://minecraft.chrislawrence.ca` ✅
- **AI Services**: `https://ai.chrislawrence.ca` ✅
- **n8n **: `https://n8n.chrislawrence.ca` 🟡 Pending
- **Dashboard**: `https://dev.chrislawrence.ca/dashboard` ✅
- **Docker**: `https://dev.chrislawrence.ca/docker` ✅
- **Uptime**: `https://dev.chrislawrence.ca/uptime` ✅
- **Metrics**: `https://dev.chrislawrence.ca/metrics` ✅
- **Prometheus**: `https://dev.chrislawrence.ca/prometheus` ✅
- **Containers**: `https://dev.chrislawrence.ca/containers` ✅
- **System**: `https://dev.chrislawrence.ca/system` ✅
- **Tools**: `https://dev.chrislawrence.ca/tools` ✅
- **Notes**: `https://dev.chrislawrence.ca/notes` ✅
- **MQTT**: `https://dev.chrislawrence.ca/mqtt` ✅
- **Meshtastic**: `https://dev.chrislawrence.ca/meshtastic` ✅
- **Node-RED**: `https://dev.chrislawrence.ca/nodered` ✅
- **Grafana IoT**: `https://dev.chrislawrence.ca/grafana-iot` ✅
- **InfluxDB**: `https://dev.chrislawrence.ca/influxdb` ✅

### 🎉 Cloudflare Tunnel Status
- **Tunnel ID**: `de5fbdaa-4497-4a7e-828f-7dba6d7b0c90`
- **Status**: ✅ Active and routing all traffic correctly
- **DNS**: ✅ All subdomains configured via Published Application Routes
- **Access Control**: ✅ Public/Protected separation working perfectly

## 📊 Complete Service Links Table

### 🌍 Public Services (No Authentication Required)

| Service | Public URL | Status | Backend Service | Notes |
|---------|------------|--------|-----------------|-------|
| **Landing Page** | `https://chrislawrence.ca` | ✅ Working | Static HTML | Bootstrap dark theme |
| **Portfolio** | `https://portfolio.chrislawrence.ca` | ✅ Working | portfolio:5000 | Flask application |
| **SchedShare** | `https://schedshare.chrislawrence.ca` | ✅ Working | schedshare:5000 | Schedule sharing app |
| **CapitolScope** | `https://capitolscope.chrislawrence.ca` | ✅ Working | capitolscope-frontend:5173 | Political data platform |
| **MagicPages** | `https://magicpages.chrislawrence.ca` | ✅ Working | magicpages-api:8000 | Content management |
| **MagicPages API** | `https://api.magicpages.chrislawrence.ca` | ✅ Working | magicpages-api:8000 | Django API |
| **EventSphere** | `https://eventsphere.chrislawrence.ca` | ✅ Working | mongo-events:5000 | Event management |

### 🔒 Protected Services (Cloudflare Access Required)

| Service | Public URL | Status | Access Policy | Notes |
|---------|------------|--------|---------------|-------|
| **Dev Environment** | `https://dev.chrislawrence.ca` | ✅ Working | Admin/Public/Friends | Development tools |
| **Monitor** | `https://monitor.chrislawrence.ca` | ✅ Working | Admin/Public/Friends | Monitoring dashboard |
| **IoT Services** | `https://iot.chrislawrence.ca` | ✅ Working | Admin/Public/Friends | IoT device management |
| **Minecraft** | `https://minecraft.chrislawrence.ca` | ✅ Working | Admin/Public/Friends | Game server |
| **AI Services** | `https://ai.chrislawrence.ca` | ✅ Working | Admin/Public/Friends | AI inference services |
| **Dashboard** | `https://dev.chrislawrence.ca/dashboard` | ✅ Working | Admin/Public/Friends | Organizr dashboard |
| **Docker** | `https://dev.chrislawrence.ca/docker` | ✅ Working | Admin/Public/Friends | Portainer |
| **Uptime** | `https://dev.chrislawrence.ca/uptime` | ✅ Working | Admin/Public/Friends | Uptime Kuma |
| **Metrics** | `https://dev.chrislawrence.ca/metrics` | ✅ Working | Admin/Public/Friends | Grafana |
| **Prometheus** | `https://dev.chrislawrence.ca/prometheus` | ✅ Working | Admin/Public/Friends | Prometheus |
| **Containers** | `https://dev.chrislawrence.ca/containers` | ✅ Working | Admin/Public/Friends | cAdvisor |
| **System** | `https://dev.chrislawrence.ca/system` | ✅ Working | Admin/Public/Friends | Glances |
| **Tools** | `https://dev.chrislawrence.ca/tools` | ✅ Working | Admin/Public/Friends | IT-Tools |
| **n8n** | `https://dev.chrislawrence.ca/n8n` | ✅ Working | Admin/Public/Friends | n8n automation |
| **Notes** | `https://dev.chrislawrence.ca/notes` | ✅ Working | Admin/Public/Friends | Obsidian |
| **MQTT** | `https://dev.chrislawrence.ca/mqtt` | ✅ Working | Admin/Public/Friends | MQTT Explorer |
| **Meshtastic** | `https://dev.chrislawrence.ca/meshtastic` | ✅ Working | Admin/Public/Friends | Meshtastic Web |
| **Node-RED** | `https://dev.chrislawrence.ca/nodered` | ✅ Working | Admin/Public/Friends | Node-RED |
| **Grafana IoT** | `https://dev.chrislawrence.ca/grafana-iot` | ✅ Working | Admin/Public/Friends | Grafana IoT |
| **InfluxDB** | `https://dev.chrislawrence.ca/influxdb` | ✅ Working | Admin/Public/Friends | InfluxDB |

## 🎯 Quick Reference URLs

### ✅ Currently Working (All Services)
- **Landing Page**: `https://chrislawrence.ca`
- **Portfolio**: `https://portfolio.chrislawrence.ca`
- **SchedShare**: `https://schedshare.chrislawrence.ca`
- **CapitolScope**: `https://capitolscope.chrislawrence.ca`
- **MagicPages**: `https://magicpages.chrislawrence.ca`
- **MagicPages API**: `https://api.magicpages.chrislawrence.ca`
- **EventSphere**: `https://eventsphere.chrislawrence.ca`

### 🔒 Protected Services (Cloudflare Access)
- **Dev Environment**: `https://dev.chrislawrence.ca`
- **Monitor**: `https://monitor.chrislawrence.ca`
- **IoT Services**: `https://iot.chrislawrence.ca`
- **Minecraft**: `https://minecraft.chrislawrence.ca`
- **AI Services**: `https://ai.chrislawrence.ca`
- **Dashboard**: `https://dev.chrislawrence.ca/dashboard`
- **Docker**: `https://dev.chrislawrence.ca/docker`
- **Uptime**: `https://dev.chrislawrence.ca/uptime`
- **Metrics**: `https://dev.chrislawrence.ca/metrics`
- **Prometheus**: `https://dev.chrislawrence.ca/prometheus`
- **Containers**: `https://dev.chrislawrence.ca/containers`
- **System**: `https://dev.chrislawrence.ca/system`
- **Tools**: `https://dev.chrislawrence.ca/tools`
- **n8n**: `https://dev.chrislawrence.ca/n8n`
- **Notes**: `https://dev.chrislawrence.ca/notes`
- **MQTT**: `https://dev.chrislawrence.ca/mqtt`
- **Meshtastic**: `https://dev.chrislawrence.ca/meshtastic`
- **Node-RED**: `https://dev.chrislawrence.ca/nodered`
- **Grafana IoT**: `https://dev.chrislawrence.ca/grafana-iot`
- **InfluxDB**: `https://dev.chrislawrence.ca/influxdb`

## 🎉 Success Summary

### What We Accomplished
1. ✅ **Fixed Cloudflare Tunnel** - New tunnel `de5fbdaa-4497-4a7e-828f-7dba6d7b0c90` working perfectly
2. ✅ **Subdomain Routing** - All 13 subdomains properly configured and accessible
3. ✅ **Public/Protected Separation** - Clear access control with Cloudflare Access
4. ✅ **Caddy Configuration** - Fixed port specifications for `auto_https off`
5. ✅ **Backend Services** - All applications running and accessible
6. ✅ **DNS Management** - Published Application Routes configured correctly

### Key Technical Fixes
- **Port Specification**: Added `:80` to all domain names in Caddyfile when `auto_https off` is used
- **Service Routing**: Fixed MagicPages to route to existing API instead of non-existent frontend
- **Tunnel Configuration**: Updated to use new tunnel ID and token
- **Access Control**: Implemented "default deny with explicit allow" security model

## 📊 Status Legend

- ✅ **Working**: Service is running and accessible
- 🔄 **Error**: Service has issues but partially working
- ❌ **Not Working**: Service is not running or not accessible
- 🟡 **Pending**: Service configured but not started
- 🔒 **Private**: LAN-only access
- 🌍 **Public**: Accessible via public domain

## 🔄 Next Steps

1. ✅ **Cloudflare Tunnel Setup** - Complete
2. ✅ **Subdomain Configuration** - Complete
3. ✅ **Public Services** - All working
4. ✅ **Protected Services** - All working with Cloudflare Access
5. 🔄 **Future Enhancements**:
   - Add more applications to protected subdomains
   - Implement additional monitoring
   - Expand AI services
   - Add IoT device integrations

## Service Health Checks

### Public Services
```bash
# Test all public services
curl -I https://chrislawrence.ca
curl -I https://portfolio.chrislawrence.ca
curl -I https://schedshare.chrislawrence.ca
curl -I https://capitolscope.chrislawrence.ca
curl -I https://magicpages.chrislawrence.ca
curl -I https://api.magicpages.chrislawrence.ca
curl -I https://eventsphere.chrislawrence.ca
```

### Protected Services (Should redirect to Cloudflare Access)
```bash
# Test protected services
curl -I https://dev.chrislawrence.ca
curl -I https://monitor.chrislawrence.ca
curl -I https://iot.chrislawrence.ca
curl -I https://minecraft.chrislawrence.ca
curl -I https://ai.chrislawrence.ca

# Test admin services under dev subdomain
curl -I https://dev.chrislawrence.ca/dashboard
curl -I https://dev.chrislawrence.ca/docker
curl -I https://dev.chrislawrence.ca/uptime
curl -I https://dev.chrislawrence.ca/metrics
curl -I https://dev.chrislawrence.ca/prometheus
curl -I https://dev.chrislawrence.ca/containers
curl -I https://dev.chrislawrence.ca/system
curl -I https://dev.chrislawrence.ca/tools
curl -I https://dev.chrislawrence.ca/n8n
curl -I https://dev.chrislawrence.ca/notes
curl -I https://dev.chrislawrence.ca/mqtt
curl -I https://dev.chrislawrence.ca/meshtastic
curl -I https://dev.chrislawrence.ca/nodered
curl -I https://dev.chrislawrence.ca/grafana-iot
curl -I https://dev.chrislawrence.ca/influxdb
```

### Tunnel Status
```bash
# Check tunnel status
docker compose -f proxy/docker-compose.yml ps cloudflared
docker compose -f proxy/docker-compose.yml logs cloudflared
```

## Related Documentation

- [Application Services](./applications.md) - Application services and management
- [Infrastructure Services](./infra/services.md) - Service architecture and definitions
- [Network Architecture](./infra/networks.md) - Docker network setup
- [Deployment Guide](./infra/deployment.md) - Service deployment procedures

---

**Last Updated**: 2025-01-27
**Status**: ✅ All services working perfectly
**Tunnel**: de5fbdaa-4497-4a7e-828f-7dba6d7b0c90
**Next Priority**: Future enhancements and additional services
