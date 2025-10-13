# 🚀 Hephaestus Homelab - Public Routing Deployment Guide

## 📋 **Implementation Summary**

This deployment implements:
1. **808X Proxy Ports** (8085-8089) for Organizr iframe embedding
2. **chrislawrence.ca Subpath Routing** for public access
3. **81XX App Port Structure** (staged for future deployment)
4. **Cloudflare Tunnel Configuration** for public routing

## 🔧 **Files Modified**

### 1. **docker-compose-infrastructure.yml**
- ✅ Added proxy ports 8085-8089 to Caddy container
- ✅ Added IT-Tools service (missing from original setup)

### 2. **proxy/Caddyfile**
- ✅ Added 808X proxy configurations with iframe-friendly headers
- ✅ Added chrislawrence.ca subpath routing
- ✅ Staged 81XX app port configurations (commented)

### 3. **cloudflare-tunnel-config-template.yml** (NEW)
- ✅ Template for updated Cloudflare Tunnel configuration
- ✅ Main domain routing to localhost:80
- ✅ Legacy subdomain support maintained

## 🚀 **Deployment Steps**

### **Phase 1: Deploy Infrastructure Changes**

```bash
# Navigate to homelab directory
cd ~/github/hephaestus-homelab

# Validate Caddy configuration
docker compose -f docker-compose-infrastructure.yml exec caddy caddy validate --config /etc/caddy/Caddyfile

# Restart services to apply changes
docker compose -f docker-compose-infrastructure.yml restart caddy

# Check service status
docker compose -f docker-compose-infrastructure.yml ps
```

### **Phase 2: Update Cloudflare Tunnel**

```bash
# Backup current config
cp ~/.cloudflared/config.yml ~/.cloudflared/config.yml.backup

# Copy new configuration (MANUAL STEP - contains secrets)
cp cloudflare-tunnel-config-template.yml ~/.cloudflared/config.yml

# Restart Cloudflare Tunnel
sudo systemctl restart cloudflared

# Check tunnel status
sudo systemctl status cloudflared
```

### **Phase 3: Test Implementation**

```bash
# Run comprehensive test suite
./test-routing.sh

# Test specific proxy ports
curl -I http://192.168.50.70:8085 -u admin:admin123  # Grafana
curl -I http://192.168.50.70:8086 -u admin:admin123  # Prometheus
curl -I http://192.168.50.70:8087 -u admin:admin123  # cAdvisor
curl -I http://192.168.50.70:8088 -u admin:admin123  # Glances
curl -I http://192.168.50.70:8089 -u admin:admin123  # IT-Tools

# Test public subpaths (after Cloudflare Tunnel update)
curl -I https://chrislawrence.ca/dashboard -u admin:admin123
curl -I https://chrislawrence.ca/uptime -u admin:admin123
curl -I https://chrislawrence.ca/docker -u admin:admin123
```

## 📊 **Organizr Configuration**

### **Tab URLs to Use in Organizr**
Use these proxy ports for iframe embedding (X-Frame-Options removed):

| Service | Organizr Tab URL | Purpose |
|---------|------------------|---------|
| **Uptime Kuma** | `http://192.168.50.70:8083` | Service monitoring |
| **Portainer** | `http://192.168.50.70:8084` | Container management |
| **Grafana** | `http://192.168.50.70:8085` | Metrics dashboard |
| **Prometheus** | `http://192.168.50.70:8086` | Metrics collection |
| **cAdvisor** | `http://192.168.50.70:8087` | Container metrics |
| **Glances** | `http://192.168.50.70:8088` | System monitoring |
| **IT-Tools** | `http://192.168.50.70:8089` | Network utilities |

### **Adding Tabs to Organizr**
1. Login to Organizr at `http://192.168.50.70:8082`
2. Go to **Settings** → **Tab Editor**
3. Add new tab with:
   - **Tab Name**: Service name (e.g., "Grafana")
   - **Tab URL**: Proxy port URL (e.g., `http://192.168.50.70:8085`)
   - **Category**: "Infrastructure" or "Monitoring"
   - **Active**: Yes
   - **Ping URL**: Same as Tab URL

## 🌐 **Public Access URLs**

### **Infrastructure Services** (Protected)
- `https://chrislawrence.ca/dashboard` → Organizr (Main entry point)
- `https://chrislawrence.ca/uptime` → Uptime Kuma
- `https://chrislawrence.ca/docker` → Portainer
- `https://chrislawrence.ca/metrics` → Grafana
- `https://chrislawrence.ca/prometheus` → Prometheus
- `https://chrislawrence.ca/containers` → cAdvisor
- `https://chrislawrence.ca/system` → Glances
- `https://chrislawrence.ca/tools` → IT-Tools

### **Future Application Services** (Staged)
- `https://chrislawrence.ca/magicpages-api` → Magic Pages API (Port 8100)
- `https://chrislawrence.ca/pages` → Magic Pages Frontend (Port 8101)
- `https://chrislawrence.ca/portfolio` → Portfolio App (Port 8110)
- `https://chrislawrence.ca/capitolscope` → CapitolScope (Port 8120)
- `https://chrislawrence.ca/schedshare` → SchedShare (Port 8130)

## 🔒 **Security Configuration**

### **Authentication Layers**
1. **Cloudflare Access** - Primary protection for `/dashboard`
2. **Caddy Basic Auth** - Secondary authentication layer
3. **Service-level Auth** - Individual service authentication

### **Header Security**
- **X-Frame-Options**: Removed on 808X proxy ports for iframe embedding
- **Content-Security-Policy**: Set to `frame-ancestors *` on proxy ports
- **HSTS**: Enabled on public domain
- **X-Content-Type-Options**: Set to `nosniff`

## 🧪 **Testing Checklist**

### **✅ Proxy Port Tests**
- [ ] Port 8085 (Grafana) - No X-Frame-Options header
- [ ] Port 8086 (Prometheus) - No X-Frame-Options header  
- [ ] Port 8087 (cAdvisor) - No X-Frame-Options header
- [ ] Port 8088 (Glances) - No X-Frame-Options header
- [ ] Port 8089 (IT-Tools) - No X-Frame-Options header
- [ ] All proxy ports return CSP with `frame-ancestors *`

### **✅ Public Subpath Tests**
- [ ] `https://chrislawrence.ca/` redirects to `/dashboard/`
- [ ] `https://chrislawrence.ca/dashboard` loads Organizr
- [ ] `https://chrislawrence.ca/uptime` loads Uptime Kuma
- [ ] `https://chrislawrence.ca/docker` loads Portainer
- [ ] All subpaths require authentication

### **✅ Organizr Integration Tests**
- [ ] Add each proxy port as Organizr tab
- [ ] Verify iframe embedding works without errors
- [ ] Test functionality within Organizr interface
- [ ] Confirm no console errors in browser

## 🚨 **Troubleshooting**

### **Common Issues**

#### **Proxy Port Not Responding**
```bash
# Check if Caddy is running
docker compose -f docker-compose-infrastructure.yml ps caddy

# Check Caddy logs
docker compose -f docker-compose-infrastructure.yml logs caddy

# Validate Caddyfile syntax
docker compose -f docker-compose-infrastructure.yml exec caddy caddy validate --config /etc/caddy/Caddyfile
```

#### **Public Subpaths Not Working**
```bash
# Check Cloudflare Tunnel status
sudo systemctl status cloudflared

# Check tunnel logs
sudo journalctl -u cloudflared -f

# Test local routing first
curl -I http://localhost:80/dashboard -u admin:admin123
```

#### **Iframe Embedding Issues**
```bash
# Check for X-Frame-Options header (should be absent)
curl -I http://192.168.50.70:808X -u admin:admin123 | grep -i frame

# Check CSP header
curl -I http://192.168.50.70:808X -u admin:admin123 | grep -i content-security
```

### **Rollback Plan**
If issues occur:
1. **Immediate**: Revert Caddyfile from Git history
2. **Container Issues**: Restart with previous docker-compose
3. **DNS Issues**: Revert Cloudflare Tunnel config from backup
4. **Emergency**: Use direct port access as fallback

## 📚 **Next Steps**

### **Application Deployment**
When ready to deploy applications:
1. Uncomment relevant sections in Caddyfile
2. Deploy applications with 81XX port structure
3. Test application routing
4. Update documentation

### **Monitoring**
- Set up alerts for service availability
- Monitor Cloudflare Tunnel health
- Track authentication failures
- Monitor resource usage

---

**Created**: October 13, 2025  
**Status**: Ready for Deployment  
**Next Action**: Execute Phase 1 deployment steps
