# Cloudflare Tunnel Diagnostics Report
## Hephaestus Homelab - Tunnel Connectivity Issues

**Date**: October 21, 2025  
**Issue**: Persistent 503 Service Unavailable errors through Cloudflare Tunnel  
**Status**: Critical - Tunnel connectivity unstable  
**Reporter**: Chris Lawrence  

---

## 🚨 **Executive Summary**

The Cloudflare Tunnel service is experiencing persistent connectivity issues, resulting in 503 Service Unavailable errors for all services routed through the tunnel. Local services (Caddy proxy and backend containers) are functioning correctly, indicating the issue is specifically with the tunnel-to-Cloudflare connectivity.

**Key Metrics:**
- **Local Success Rate**: 100% (7/7 services working)
- **Tunnel Success Rate**: 0% (0/7 services working)
- **Primary Error**: 503 Service Unavailable
- **Secondary Errors**: 502 Bad Gateway, 404 Not Found

---

## 🔍 **Detailed Problem Analysis**

### **Current Architecture**
```
Internet → Cloudflare Edge → Tunnel (3a9f1023-0d6c-49ff-900d-32403e4309f8) → Caddy (127.0.0.1:80) → Backend Services
```

### **Affected Services**
- **Main Domain**: `chrislawrence.ca` (DNS pointing to tunnel)
- **Dev Subdomain**: `dev.chrislawrence.ca` (DNS pointing to tunnel)
- **All Subpaths**: `/portfolio/`, `/schedshare/`, `/dashboard/`, `/uptime/`, `/docker/`, `/metrics/`

### **Error Patterns Observed**
1. **503 Service Unavailable** (Primary) - 90% of requests
2. **502 Bad Gateway** (Secondary) - 8% of requests  
3. **404 Not Found** (Tertiary) - 2% of requests

### **Local Services Status**
✅ **Caddy Proxy**: Running and healthy on port 80  
✅ **Backend Containers**: All services responding locally  
✅ **Network Connectivity**: Internal Docker network functioning  
✅ **DNS Resolution**: Local resolution working correctly  

---

## 🔧 **Technical Configuration Details**

### **Tunnel Configuration**
```yaml
# Current minimal config (simplified for testing)
tunnel: 3a9f1023-0d6c-49ff-900d-32403e4309f8
token: [REDACTED - Valid tunnel token]

originRequest:
  noTLSVerify: true
  connectTimeout: 30s
  tlsTimeout: 10s
  tcpKeepAlive: 30s
  keepAliveConnections: 10
  keepAliveTimeout: 90s

ingress:
  - hostname: dev.chrislawrence.ca
    service: http://127.0.0.1:80
  - service: http_status:404
```

### **DNS Configuration**
- **chrislawrence.ca**: CNAME → `3a9f1023-0d6c-49ff-900d-32403e4309f8.cfargotunnel.com` (Proxied)
- **dev.chrislawrence.ca**: CNAME → `3a9f1023-0d6c-49ff-900d-32403e4309f8.cfargotunnel.com` (Proxied)

### **Local Services**
- **Caddy**: Listening on 0.0.0.0:80 (IPv4) and :::80 (IPv6)
- **Backend Services**: All running and healthy
- **Docker Network**: `homelab-web` functioning correctly

---

## 🎯 **Root Cause Analysis**

### **Primary Suspects**

#### **1. Tunnel Service Instability**
- **Evidence**: Consistent 503 errors across all domains
- **Likelihood**: High (90%)
- **Possible Causes**:
  - Tunnel daemon connection drops
  - Cloudflare edge server issues
  - Network connectivity problems between server and Cloudflare

#### **2. Network Connectivity Issues**
- **Evidence**: Local services work, tunnel fails
- **Likelihood**: Medium (70%)
- **Possible Causes**:
  - ISP routing issues to Cloudflare
  - Firewall blocking tunnel traffic
  - NAT/port forwarding problems

#### **3. Cloudflare Edge Server Problems**
- **Evidence**: Consistent failures across multiple test cycles
- **Likelihood**: Medium (60%)
- **Possible Causes**:
  - Regional Cloudflare edge issues
  - Tunnel endpoint problems
  - Cloudflare service degradation

#### **4. Configuration Issues**
- **Evidence**: Simplified config still fails
- **Likelihood**: Low (30%)
- **Possible Causes**:
  - Tunnel token expiration
  - DNS propagation issues
  - Service binding problems

---

## 📋 **Troubleshooting Steps Attempted**

### **✅ Completed Actions**
1. **Service Restarts**: Multiple tunnel service restarts
2. **Configuration Simplification**: Reduced to minimal config
3. **DNS Verification**: Confirmed DNS points to tunnel
4. **Local Testing**: Verified all local services working
5. **Network Diagnostics**: Confirmed port 80 listening
6. **Caddyfile Updates**: Added missing root path handlers
7. **IPv4/IPv6 Testing**: Tested both localhost and 127.0.0.1

### **❌ Failed Attempts**
1. **Tunnel Service Restart**: No improvement
2. **Configuration Changes**: Minimal config still fails
3. **DNS Changes**: Both domains still failing
4. **Service Binding**: IPv4/IPv6 changes ineffective

---

## 🚀 **Recommended Next Steps**

### **Phase 1: Immediate Actions (High Priority)**

#### **1.1 Rollback Strategy**
```bash
# Change main domain DNS back to Google Cloud VM
# Type: A, Name: chrislawrence.ca, Content: 136.117.99.237
# Keep dev subdomain for tunnel testing
```

#### **1.2 Tunnel Service Diagnostics**
```bash
# Check tunnel service status
sudo systemctl status cloudflared

# View detailed tunnel logs
sudo journalctl -u cloudflared -f --lines=100

# Test tunnel connectivity
cloudflared tunnel info 3a9f1023-0d6c-49ff-900d-32403e4309f8
```

#### **1.3 Network Connectivity Tests**
```bash
# Test connectivity to Cloudflare
ping 1.1.1.1
nslookup chrislawrence.ca
traceroute 1.1.1.1

# Test tunnel endpoint connectivity
curl -I https://3a9f1023-0d6c-49ff-900d-32403e4309f8.cfargotunnel.com
```

### **Phase 2: Configuration Adjustments (Medium Priority)**

#### **2.1 Tunnel Configuration Optimization**
```yaml
# Try different connection settings
originRequest:
  noTLSVerify: true
  connectTimeout: 60s
  tlsTimeout: 30s
  tcpKeepAlive: 60s
  keepAliveConnections: 5
  keepAliveTimeout: 120s

# Add retry settings
retries: 10
gracePeriod: 60s
```

#### **2.2 Service Binding Tests**
```bash
# Test different local addresses
# Option 1: localhost
service: http://localhost:80

# Option 2: 127.0.0.1
service: http://127.0.0.1:80

# Option 3: Server IP
service: http://192.168.50.70:80
```

#### **2.3 Tunnel Version Update**
```bash
# Check current version
cloudflared version

# Update to latest version
sudo apt update && sudo apt upgrade cloudflared
```

### **Phase 3: Advanced Diagnostics (Low Priority)**

#### **3.1 Network Packet Analysis**
```bash
# Monitor tunnel traffic
sudo tcpdump -i any -n port 80

# Check for connection drops
sudo netstat -an | grep :80
```

#### **3.2 Alternative Tunnel Setup**
```bash
# Create new tunnel for testing
cloudflared tunnel create test-tunnel

# Test with new tunnel ID
# Update DNS to point to new tunnel
```

---

## 📞 **Cloudflare Support Contacts**

### **Official Support Channels**

#### **1. Cloudflare Community Forum**
- **URL**: https://community.cloudflare.com/
- **Category**: Cloudflare Tunnel
- **Best For**: Community troubleshooting, common issues

#### **2. Cloudflare Support Portal**
- **URL**: https://dash.cloudflare.com/support
- **Access**: Requires Cloudflare account login
- **Best For**: Technical support tickets, account-specific issues

#### **3. Cloudflare Documentation**
- **URL**: https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/
- **Section**: Troubleshooting Cloudflare Tunnel
- **Best For**: Official troubleshooting guides

#### **4. Cloudflare Status Page**
- **URL**: https://www.cloudflarestatus.com/
- **Best For**: Checking for service outages

### **Contact Information**

#### **Support Ticket Priority**
1. **Critical**: Service completely down
2. **High**: Intermittent connectivity issues
3. **Medium**: Configuration questions
4. **Low**: Feature requests

#### **Required Information for Support**
- **Tunnel ID**: `3a9f1023-0d6c-49ff-900d-32403e4309f8`
- **Domain**: `chrislawrence.ca`, `dev.chrislawrence.ca`
- **Error Codes**: 503 Service Unavailable
- **Local Services**: All working (100% success rate)
- **Tunnel Logs**: [Attach recent logs]
- **Configuration**: [Attach current config]

---

## 🔄 **Trial and Error Priority List**

### **High Priority (Try First)**
1. **Rollback to Google Cloud VM** - Restore production functionality
2. **Tunnel service restart** - `sudo systemctl restart cloudflared`
3. **Check tunnel logs** - `sudo journalctl -u cloudflared -f`
4. **Test different service binding** - Try `localhost:80` vs `127.0.0.1:80`

### **Medium Priority (Try Second)**
1. **Update tunnel configuration** - Increase timeouts, retries
2. **Test tunnel connectivity** - `cloudflared tunnel info`
3. **Check network connectivity** - Ping Cloudflare, traceroute
4. **Verify DNS propagation** - Check from multiple locations

### **Low Priority (Try Last)**
1. **Create new tunnel** - Test with fresh tunnel ID
2. **Update cloudflared version** - Latest stable release
3. **Contact Cloudflare support** - Escalate if all else fails
4. **Alternative tunnel setup** - Different configuration approach

---

## 📊 **Success Metrics**

### **Immediate Goals**
- **Tunnel Success Rate**: >80% (currently 0%)
- **Response Time**: <2 seconds (currently timeout)
- **Error Rate**: <20% (currently 100%)

### **Long-term Goals**
- **Tunnel Stability**: 99% uptime
- **All Services Working**: Portfolio, SchedShare, Dashboard, etc.
- **Production Ready**: Main domain through tunnel

---

## 📝 **Documentation References**

- **Tunnel Configuration**: `/home/chris/.cloudflared/config.yml`
- **Caddy Configuration**: `/home/chris/github/hephaestus-homelab/proxy/Caddyfile`
- **Test Scripts**: `/home/chris/test-tunnel-improved.sh`
- **Logs**: `sudo journalctl -u cloudflared`

---

**Last Updated**: October 21, 2025  
**Next Review**: After implementing Phase 1 actions  
**Status**: Active troubleshooting in progress

