# 🌐 Cloudflare DNS Setup Guide

## 🎯 **Simplified Setup: Subpaths Only**

We're using the **subpath-only approach** for cleaner URLs and easier management.

### **What You'll Have:**
- ✅ `https://chrislawrence.ca/dashboard` → Organizr
- ✅ `https://chrislawrence.ca/uptime` → Uptime Kuma
- ✅ `https://chrislawrence.ca/docker` → Portainer
- ✅ `https://chrislawrence.ca/metrics` → Grafana
- ✅ `https://chrislawrence.ca/prometheus` → Prometheus
- ✅ `https://chrislawrence.ca/containers` → cAdvisor
- ✅ `https://chrislawrence.ca/system` → Glances
- ✅ `https://chrislawrence.ca/tools` → IT-Tools

## 📋 **Step-by-Step Cloudflare Setup**

### **Step 1: Add chrislawrence.ca to Cloudflare**

1. **Login to Cloudflare Dashboard**
   - Go to https://dash.cloudflare.com/
   - Login with your account

2. **Add Site (if not already added)**
   - Click "Add a Site"
   - Enter: `chrislawrence.ca`
   - Choose your plan (Free is fine)
   - Follow the nameserver setup if needed

### **Step 2: Configure DNS Records**

In your Cloudflare DNS settings, you need **only ONE record**:

| Type | Name | Content | Proxy Status | TTL |
|------|------|---------|--------------|-----|
| **CNAME** | `chrislawrence.ca` | `7bbb8d12-6cf4-4556-8c5f-006fb7bab126.cfargotunnel.com` | ✅ Proxied | Auto |

**OR** (if you prefer A record):

| Type | Name | Content | Proxy Status | TTL |
|------|------|---------|--------------|-----|
| **A** | `chrislawrence.ca` | `192.0.2.1` | ✅ Proxied | Auto |

> **Note**: The exact content depends on your tunnel setup. Use the CNAME approach with your tunnel domain.

### **Step 3: Configure Cloudflare Tunnel**

1. **Go to Cloudflare Zero Trust Dashboard**
   - Navigate to: Access → Tunnels
   - Find your tunnel: `hephaestus-homelab`

2. **Update Public Hostname**
   - Edit your tunnel configuration
   - Add/Update hostname: `chrislawrence.ca`
   - Service: `http://localhost:80`
   - Save changes

### **Step 4: Update Local Tunnel Config**

```bash
# Copy the simplified config
cp ~/github/hephaestus-homelab/cloudflare-tunnel-config-template.yml ~/.cloudflared/config.yml

# Restart the tunnel
cd ~/github/hephaestus-homelab
docker compose -f docker-compose-infrastructure.yml restart cloudflared
```

## 🔒 **Security Configuration**

### **Cloudflare Access (Optional but Recommended)**

For the `/dashboard` path, set up Cloudflare Access:

1. **Go to Zero Trust → Access → Applications**
2. **Add Application**:
   - **Application name**: "Hephaestus Dashboard"
   - **Subdomain**: Leave blank
   - **Domain**: `chrislawrence.ca`
   - **Path**: `/dashboard*`
3. **Create Policy**:
   - **Policy name**: "Admin Only"
   - **Action**: Allow
   - **Include**: Your email address
4. **Save**

This adds an extra security layer before the basic auth.

## 🧪 **Testing Your Setup**

### **Test Commands**
```bash
# Test main domain
curl -I https://chrislawrence.ca/

# Test dashboard (should redirect to /dashboard/)
curl -I https://chrislawrence.ca/dashboard

# Test services (will require auth)
curl -I https://chrislawrence.ca/uptime -u admin:admin123
curl -I https://chrislawrence.ca/docker -u admin:admin123
curl -I https://chrislawrence.ca/metrics -u admin:admin123
```

### **Browser Testing**
1. Visit `https://chrislawrence.ca/` (should redirect to `/dashboard/`)
2. Login with your credentials
3. Test each subpath:
   - `https://chrislawrence.ca/dashboard`
   - `https://chrislawrence.ca/uptime`
   - `https://chrislawrence.ca/docker`
   - etc.

## 🚨 **Troubleshooting**

### **Common Issues**

#### **"This site can't be reached"**
- Check DNS propagation: https://dnschecker.org/
- Verify tunnel is running: `docker compose ps cloudflared`
- Check tunnel logs: `docker compose logs cloudflared`

#### **"502 Bad Gateway"**
- Caddy might be down: `docker compose ps caddy`
- Check Caddy logs: `docker compose logs caddy`
- Verify port 80 is accessible: `curl -I http://localhost:80`

#### **Authentication Issues**
- Verify basic auth credentials in Caddyfile
- Check if Cloudflare Access is blocking requests
- Test local access first: `curl -I http://192.168.50.70:80/dashboard -u admin:admin123`

### **Verification Checklist**
- [ ] DNS record points to tunnel
- [ ] Tunnel is running and healthy
- [ ] Caddy is running with correct configuration
- [ ] Local subpath routing works
- [ ] Public access works through tunnel
- [ ] Authentication is working
- [ ] All services are accessible via subpaths

## 📊 **What We're NOT Setting Up**

We're **skipping** these subdomain DNS records (simpler approach):
- ❌ `uptime.hephaestus.chrislawrence.ca`
- ❌ `grafana.hephaestus.chrislawrence.ca`
- ❌ `portainer.hephaestus.chrislawrence.ca`
- ❌ `prometheus.hephaestus.chrislawrence.ca`
- ❌ `cadvisor.hephaestus.chrislawrence.ca`
- ❌ `glances.hephaestus.chrislawrence.ca`

**Why?** Because everything works through the main domain subpaths!

---

## 🎯 **Summary**

**One DNS record** → **All services accessible** → **Clean URLs** → **Easy management**

After this setup:
- **Public Access**: `https://chrislawrence.ca/[service]`
- **Organizr Embedding**: `http://192.168.50.70:808X` (local proxy ports)
- **Direct Service Access**: `http://192.168.50.70:[port]` (local only)

**Ready to implement!** 🚀
