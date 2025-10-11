# Cloudflare Tunnel Troubleshooting Guide

## Current Issue
Cloudflare Tunnel is connected and showing as "HEALTHY" in the dashboard, but external access to services via the tunnel is failing with connection timeouts.

## Symptoms
- ✅ Tunnel shows "HEALTHY" status in Cloudflare dashboard
- ✅ Multiple tunnel connections registered (4 connections active)
- ✅ DNS resolution working: `hephaestus.chrislawrence.ca` → `100.64.0.1`
- ❌ External access times out: `curl -I https://hephaestus.chrislawrence.ca`
- ❌ Local service access also failing: `curl -I http://localhost:9000`
- ❌ Services running but not accessible

## Root Cause Analysis

### 1. Tunnel Configuration Issues
**Problem**: The tunnel is connected but routes are not properly configured.
**Evidence**: Dashboard shows "Routes: --" (empty)
**Solution**: Configure Public Hostnames in Cloudflare dashboard

### 2. Local Service Accessibility
**Problem**: Services are running but not accessible locally
**Evidence**: `curl -I http://localhost:9000` times out
**Solution**: Check Docker networking and service configurations

### 3. Network Configuration
**Problem**: Docker containers may have network connectivity issues
**Evidence**: Grafana logs show "no route to host" errors
**Solution**: Fix Docker networking configuration

## Step-by-Step Troubleshooting

### Step 1: Verify Cloudflare Dashboard Configuration
1. Go to **Cloudflare Zero Trust → Access → Tunnels**
2. Click on **"hephaestus-tunnel"**
3. Go to **"Public Hostnames"** tab
4. Verify these hostnames are configured:
   ```
   hephaestus.chrislawrence.ca → http://caddy:80
   portainer.hephaestus.chrislawrence.ca → http://caddy:80
   grafana.hephaestus.chrislawrence.ca → http://caddy:80
   prometheus.hephaestus.chrislawrence.ca → http://caddy:80
   uptime.hephaestus.chrislawrence.ca → http://caddy:80
   cadvisor.hephaestus.chrislawrence.ca → http://caddy:80
   glances.hephaestus.chrislawrence.ca → http://caddy:80
   ```

### Step 2: Test Local Service Accessibility
```bash
# Test individual services
curl -I http://localhost:9000    # Portainer
curl -I http://localhost:3000    # Grafana
curl -I http://localhost:9090    # Prometheus
curl -I http://localhost:3001    # Uptime Kuma
curl -I http://localhost:8080    # cAdvisor
curl -I http://localhost:61208   # Glances
```

### Step 3: Check Docker Network Configuration
```bash
# Check if services are running
docker compose ps

# Check service logs
docker compose logs caddy
docker compose logs cloudflared

# Test internal Docker networking
docker exec -it caddy curl -I http://portainer:9000
```

### Step 4: Verify Caddy Configuration
```bash
# Check Caddy logs
docker compose logs caddy

# Test Caddy directly
curl -I http://localhost:80
```

### Step 5: Test Tunnel Connectivity
```bash
# Check tunnel status
docker compose logs cloudflared --tail 20

# Test from external device
# Use your laptop/phone to access:
# https://hephaestus.chrislawrence.ca
# https://portainer.hephaestus.chrislawrence.ca
```

## Common Issues and Solutions

### Issue 1: Empty Routes in Dashboard
**Problem**: Dashboard shows "Routes: --"
**Solution**: 
1. Go to tunnel configuration
2. Add Public Hostnames for each service
3. Ensure all point to `http://caddy:80`

### Issue 2: Local Services Not Accessible
**Problem**: `curl -I http://localhost:9000` times out
**Solution**:
1. Check if services are actually running: `docker compose ps`
2. Check service logs for errors
3. Verify port mappings in docker-compose.yml
4. Test with `docker exec` from inside containers

### Issue 3: Tunnel Connected But No Traffic
**Problem**: Tunnel shows healthy but no external access
**Solution**:
1. Verify Public Hostnames are configured
2. Check that hostnames point to correct internal services
3. Ensure Caddy is running and accessible
4. Test tunnel with simple HTTP service first

### Issue 4: DNS Resolution Issues
**Problem**: Domain doesn't resolve or resolves to wrong IP
**Solution**:
1. Verify DNS A record: `hephaestus.chrislawrence.ca` → `100.64.0.1`
2. Check DNS propagation: `nslookup hephaestus.chrislawrence.ca`
3. Clear DNS cache if needed

## Debugging Commands

### Check Service Status
```bash
# All services
docker compose ps

# Specific service logs
docker compose logs [service-name] --tail 20

# Service health
docker compose exec [service-name] curl -I http://localhost:[port]
```

### Test Network Connectivity
```bash
# Test local access
curl -I http://localhost:9000
curl -I http://localhost:3000

# Test Docker internal networking
docker exec -it caddy curl -I http://portainer:9000
docker exec -it caddy curl -I http://grafana:3000
```

### Check Tunnel Status
```bash
# Tunnel logs
docker compose logs cloudflared --tail 20

# Tunnel metrics (if available)
curl http://localhost:20242/metrics
```

## Expected Results

### Successful Configuration
- ✅ All services accessible locally
- ✅ Tunnel shows multiple connections
- ✅ Dashboard shows configured routes
- ✅ External access works from any device
- ✅ SSL certificates automatically provided by Cloudflare

### Service URLs (when working)
```
https://hephaestus.chrislawrence.ca          # Main site
https://portainer.hephaestus.chrislawrence.ca    # Docker management
https://grafana.hephaestus.chrislawrence.ca      # Monitoring dashboards
https://prometheus.hephaestus.chrislawrence.ca   # Metrics
https://uptime.hephaestus.chrislawrence.ca       # Uptime monitoring
https://cadvisor.hephaestus.chrislawrence.ca      # Container metrics
https://glances.hephaestus.chrislawrence.ca      # System metrics
```

## Next Steps

1. **Verify Cloudflare Dashboard**: Ensure all Public Hostnames are configured
2. **Test Local Services**: Make sure services are accessible locally first
3. **Check Caddy Configuration**: Ensure reverse proxy is working
4. **Test External Access**: Use different device/network to test
5. **Monitor Logs**: Watch for any error messages during testing

## Emergency Fallback

If tunnel continues to fail:
1. **Use direct port access**: `http://your-ip:9000` (temporary)
2. **Set up VPN**: Use Tailscale or WireGuard for secure access
3. **Check firewall**: Ensure ports are open if using direct access
4. **Contact support**: Cloudflare support for tunnel-specific issues

---

**Last Updated**: 2025-10-11
**Status**: Tunnel connected but external access failing
**Priority**: High - Services need to be accessible externally
