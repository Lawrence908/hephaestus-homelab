# Cloudflare Tunnel Advanced Troubleshooting Guide

## Current Issue: Complete Connectivity Failure Despite Correct Configuration

**Status**: All components appear correctly configured, but external and local access is completely failing.

## Confirmed Working Components
- ✅ **Cloudflare Tunnel**: Connected and healthy (4 active connections)
- ✅ **DNS Resolution**: `hephaestus.chrislawrence.ca` → `100.64.0.1`
- ✅ **Cloudflare Dashboard**: All 7 hostname routes configured correctly
- ✅ **Docker Services**: All containers running (Caddy, Portainer, Grafana, etc.)
- ✅ **Caddyfile**: Properly configured with reverse proxy rules
- ✅ **Network Connectivity**: Host can reach external services (Let's Encrypt API)

## Confirmed Failing Components
- ❌ **External Access**: `curl -I https://hephaestus.chrislawrence.ca` times out
- ❌ **Local Access**: `curl -I http://localhost:80` times out
- ❌ **Service Access**: `curl -I http://localhost:9000` times out
- ❌ **Caddy Health**: Shows as "unhealthy" in Docker

## Root Cause Analysis: The Real Problem

Based on the symptoms, the issue is likely **Docker networking and port binding conflicts**. Here's what's happening:

### 1. **Port Binding Issues**
- Caddy is trying to bind to port 80, but something is preventing it
- Docker port mapping might be conflicting with host services
- Firewall rules might be blocking Docker's port forwarding

### 2. **Docker Network Isolation**
- Services are running but not accessible from host
- Internal Docker networking might be broken
- Caddy can't reach backend services

### 3. **Cloudflare Tunnel Origin Connectivity**
- Tunnel is connected but can't reach the origin (Caddy)
- Origin certificate issues (seen in logs)
- Network routing problems between tunnel and Docker

## Comprehensive Troubleshooting Steps

### **Step 1: Diagnose Port Binding Issues**

```bash
# Check what's actually listening on port 80
sudo netstat -tulnp | grep :80
sudo ss -tulnp | grep :80

# Check if any process is using port 80
sudo lsof -i :80

# Check Docker port mappings
docker port caddy
```

**Expected Results:**
- Should see Docker process listening on `0.0.0.0:80`
- If nothing shows, port binding is failing

### **Step 2: Test Docker Network Connectivity**

```bash
# Check Docker networks
docker network ls
docker network inspect hephaestus-homelab_default

# Test internal Docker connectivity
docker exec -it caddy ping portainer
docker exec -it caddy ping grafana

# Test if Caddy can reach backend services
docker exec -it caddy curl -I http://portainer:9000
docker exec -it caddy curl -I http://grafana:3000
```

**Expected Results:**
- Internal Docker networking should work
- Caddy should be able to reach backend services

### **Step 3: Diagnose Host Network Issues**

```bash
# Check if host can reach Docker's internal network
docker inspect caddy | grep IPAddress

# Test direct connection to Caddy container
docker exec -it caddy curl -I http://localhost:80

# Check if host firewall is blocking
sudo ufw status verbose
sudo iptables -L -n | grep 80
```

### **Step 4: Test Cloudflare Tunnel Origin Connectivity**

```bash
# Check tunnel logs for origin connectivity errors
docker compose logs cloudflared --tail 50

# Test if tunnel can reach Caddy from host
# (This is what cloudflared does internally)
curl -v http://localhost:80

# Check if tunnel is actually trying to connect
# Look for connection attempts in logs
```

### **Step 5: Fix Docker Networking Issues**

If Docker networking is broken, try these fixes:

```bash
# Restart Docker daemon
sudo systemctl restart docker

# Recreate Docker networks
docker compose down
docker network prune -f
docker compose up -d

# Check if services are accessible after restart
curl -I http://localhost:80
curl -I http://localhost:9000
```

### **Step 6: Fix Port Binding Conflicts**

If port 80 is being used by another service:

```bash
# Find what's using port 80
sudo netstat -tulnp | grep :80
sudo lsof -i :80

# If another service is using port 80, stop it
sudo systemctl stop apache2  # if Apache is running
sudo systemctl stop nginx    # if Nginx is running

# Or change Caddy to use a different port
# Edit docker-compose.yml to use port 8080 instead
```

### **Step 7: Fix Cloudflare Tunnel Origin Issues**

The tunnel logs show origin certificate errors. Fix this:

```bash
# Stop the current tunnel
pkill cloudflared

# Run tunnel with proper origin certificate
cloudflared tunnel --no-autoupdate run --token [YOUR_TOKEN] --origincert /path/to/cert.pem

# Or run without origin certificate (less secure but might work)
cloudflared tunnel --no-autoupdate run --token [YOUR_TOKEN] --no-tls-verify
```

## Alternative Solutions

### **Solution 1: Use Different Ports**

If port 80 is problematic, use different ports:

```yaml
# In docker-compose.yml, change Caddy ports
ports:
  - "8080:80"  # Use port 8080 instead

# Update Cloudflare dashboard routes to:
# hephaestus.chrislawrence.ca → http://caddy:8080
```

### **Solution 2: Use Host Networking**

Force Caddy to use host networking:

```yaml
# In docker-compose.yml, change Caddy service
caddy:
  network_mode: host
  # Remove ports section
```

### **Solution 3: Use Nginx Instead of Caddy**

If Caddy continues to fail, switch to Nginx:

```yaml
# Replace Caddy with Nginx
nginx:
  image: nginx:alpine
  container_name: nginx
  ports:
    - "80:80"
  volumes:
    - ./nginx.conf:/etc/nginx/nginx.conf:ro
```

## Debugging Commands

### **Check Service Status**
```bash
# All services
docker compose ps

# Specific service logs
docker compose logs caddy --tail 20
docker compose logs cloudflared --tail 20

# Service health
docker compose exec caddy curl -I http://localhost:80
```

### **Test Network Connectivity**
```bash
# Test local access
curl -v http://localhost:80
curl -v http://localhost:9000

# Test Docker internal networking
docker exec -it caddy curl -I http://portainer:9000
docker exec -it caddy curl -I http://grafana:3000
```

### **Check System Resources**
```bash
# Check if system is running out of resources
free -h
df -h
docker system df

# Check for any error logs
journalctl -u docker --tail 20
dmesg | tail -20
```

## Expected Results After Fixes

### **Successful Configuration**
- ✅ `curl -I http://localhost:80` returns HTTP response
- ✅ `curl -I http://localhost:9000` returns Portainer response
- ✅ `curl -I https://hephaestus.chrislawrence.ca` returns HTTP response
- ✅ All services accessible via Cloudflare Tunnel

### **Service URLs (when working)**
```
https://hephaestus.chrislawrence.ca          # Main site
https://portainer.hephaestus.chrislawrence.ca    # Docker management
https://grafana.hephaestus.chrislawrence.ca      # Monitoring dashboards
https://prometheus.hephaestus.chrislawrence.ca   # Metrics
https://uptime.hephaestus.chrislawrence.ca       # Uptime monitoring
https://cadvisor.hephaestus.chrislawrence.ca      # Container metrics
https://glances.hephaestus.chrislawrence.ca      # System metrics
```

## Emergency Fallback Options

### **Option 1: Direct Port Access**
If tunnel continues to fail, expose services directly:
```yaml
# In docker-compose.yml, expose all ports
ports:
  - "9000:9000"  # Portainer
  - "3000:3000"  # Grafana
  - "9090:9090"  # Prometheus
  # etc.
```

### **Option 2: Use Tailscale**
Set up Tailscale for secure access:
```bash
# Install Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# Access services via Tailscale IP
# http://hephaestus.tailnet.ts.net:9000
```

### **Option 3: Use WireGuard**
Set up WireGuard VPN for secure access.

## Next Steps

1. **Run all diagnostic commands** and provide output
2. **Identify the specific failure point** (port binding, Docker networking, etc.)
3. **Apply the appropriate fix** based on the diagnosis
4. **Test each fix** before moving to the next
5. **Document the solution** for future reference

---

**Last Updated**: 2025-10-11
**Status**: Complete connectivity failure despite correct configuration
**Priority**: Critical - Services need to be accessible
**Next Action**: Run diagnostic commands to identify root cause
