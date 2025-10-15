# 🚨 Organizr Container Proxy Fixes - Complete Troubleshooting Guide

## 🎯 **Current Status Overview**

### ✅ **Working Services**
- **Portfolio** - Public access working
- **SchedShare** - Local access working  
- **EventSphere** - Local access working
- **Organizr** - Main dashboard working

### ❌ **Broken Services (Need Fixes)**
- **MagicPages** - Error (needs investigation)
- **CapitolScope** - Not working
- **Obsidian** - Not working
- **IT-Tools** - Not working
- **Uptime Kuma** - Not working
- **Glances** - Not working
- **Portainer** - Not working
- **Prometheus** - Not working

## 🔧 **Systematic Fix Approach**

### **Phase 1: Infrastructure Services (Priority 1)**
Fix core monitoring and management services first:

#### **1.1 Portainer (Docker Management)**
**Current Issue**: Not accessible via Organizr
**Expected URL**: `http://192.168.50.70:8084`
**Direct URL**: `http://192.168.50.70:9000`

**Diagnostic Steps**:
```bash
# Check if Portainer container is running
docker ps | grep portainer

# Check if port 8084 is accessible
curl -I http://192.168.50.70:8084

# Check Caddy logs for Portainer proxy
docker logs caddy | grep -i portainer

# Test direct Portainer access
curl -I http://192.168.50.70:9000
```

**Expected Fix**:
- Verify Caddy proxy configuration for port 8084
- Check if Portainer container is healthy
- Test Organizr tab URL: `http://192.168.50.70:8084`

#### **1.2 Uptime Kuma (Monitoring)**
**Current Issue**: Not accessible via Organizr
**Expected URL**: `http://192.168.50.70:8083`
**Direct URL**: `http://192.168.50.70:3001`

**Diagnostic Steps**:
```bash
# Check Uptime Kuma container
docker ps | grep uptime-kuma

# Test proxy port
curl -I http://192.168.50.70:8083

# Test direct access
curl -I http://192.168.50.70:3001

# Check Caddy configuration
docker exec caddy cat /etc/caddy/Caddyfile | grep -A 10 ":8083"
```

**Expected Fix**:
- Verify Uptime Kuma container is running
- Check Caddy proxy port 8083 configuration
- Test Organizr tab URL: `http://192.168.50.70:8083`

#### **1.3 Prometheus (Metrics Collection)**
**Current Issue**: Not accessible via Organizr
**Expected URL**: `http://192.168.50.70:8086`
**Direct URL**: `http://192.168.50.70:9090`

**Diagnostic Steps**:
```bash
# Check Prometheus container
docker ps | grep prometheus

# Test proxy port
curl -I http://192.168.50.70:8086

# Test direct access
curl -I http://192.168.50.70:9090

# Check Prometheus logs
docker logs prometheus
```

**Expected Fix**:
- Verify Prometheus container is healthy
- Check Caddy proxy port 8086 configuration
- Test Organizr tab URL: `http://192.168.50.70:8086`

#### **1.4 Grafana (Metrics Dashboard)**
**Current Issue**: Not accessible via Organizr
**Expected URL**: `http://192.168.50.70:8085`
**Direct URL**: `http://192.168.50.70:3000`

**Diagnostic Steps**:
```bash
# Check Grafana container
docker ps | grep grafana

# Test proxy port
curl -I http://192.168.50.70:8085

# Test direct access
curl -I http://192.168.50.70:3000

# Check Grafana logs
docker logs grafana
```

**Expected Fix**:
- Verify Grafana container is healthy
- Check Caddy proxy port 8085 configuration
- Test Organizr tab URL: `http://192.168.50.70:8085`

#### **1.5 Glances (System Monitoring)**
**Current Issue**: Not accessible via Organizr
**Expected URL**: `http://192.168.50.70:8088`
**Direct URL**: `http://192.168.50.70:61208`

**Diagnostic Steps**:
```bash
# Check Glances container
docker ps | grep glances

# Test proxy port
curl -I http://192.168.50.70:8088

# Test direct access
curl -I http://192.168.50.70:61208

# Check Glances logs
docker logs glances
```

**Expected Fix**:
- Verify Glances container is healthy
- Check Caddy proxy port 8088 configuration
- Test Organizr tab URL: `http://192.168.50.70:8088`

#### **1.6 IT-Tools (Network Utilities)**
**Current Issue**: Not accessible via Organizr
**Expected URL**: `http://192.168.50.70:8089`
**Direct URL**: `http://192.168.50.70:8081`

**Diagnostic Steps**:
```bash
# Check IT-Tools container
docker ps | grep it-tools

# Test proxy port
curl -I http://192.168.50.70:8089

# Test direct access
curl -I http://192.168.50.70:8081

# Check IT-Tools logs
docker logs it-tools
```

**Expected Fix**:
- Verify IT-Tools container is healthy
- Check Caddy proxy port 8089 configuration
- Test Organizr tab URL: `http://192.168.50.70:8089`

### **Phase 2: Application Services (Priority 2)**
Fix application services after infrastructure is stable:

#### **2.1 MagicPages (Django API)**
**Current Issue**: Error (needs investigation)
**Expected URL**: `http://192.168.50.70:8091`
**Public URL**: `chrislawrence.ca/magicpages-api`

**Diagnostic Steps**:
```bash
# Check MagicPages container
docker ps | grep magicpages

# Test proxy port
curl -I http://192.168.50.70:8091

# Test direct access
curl -I http://192.168.50.70:8000

# Check MagicPages logs
docker logs magicpages-api

# Check Django configuration
docker exec magicpages-api python manage.py check
```

**Expected Fix**:
- Verify MagicPages container is healthy
- Check Django ALLOWED_HOSTS configuration
- Verify database connectivity
- Test Organizr tab URL: `http://192.168.50.70:8091`

#### **2.2 CapitolScope (Political Data App)**
**Current Issue**: Not working
**Expected URL**: `http://192.168.50.70:8120`
**Public URL**: `chrislawrence.ca/capitolscope`

**Diagnostic Steps**:
```bash
# Check CapitolScope container
docker ps | grep capitolscope

# Test direct access
curl -I http://192.168.50.70:8120

# Check CapitolScope logs
docker logs capitolscope

# Check if service is running
docker exec capitolscope ps aux
```

**Expected Fix**:
- Verify CapitolScope container is healthy
- Check FastAPI application startup
- Verify database connectivity
- Test Organizr tab URL: `http://192.168.50.70:8120`

#### **2.3 Obsidian (Notes)**
**Current Issue**: Not working
**Expected URL**: `http://192.168.50.70:8090`
**Public URL**: `chrislawrence.ca/notes`

**Diagnostic Steps**:
```bash
# Check Obsidian container
docker ps | grep obsidian

# Test proxy port
curl -I http://192.168.50.70:8090

# Test direct access
curl -I http://192.168.50.70:3001

# Check Obsidian logs
docker logs obsidian-notes

# Check if Selkies is running
docker exec obsidian-notes ps aux
```

**Expected Fix**:
- Verify Obsidian container is healthy
- Check Selkies configuration
- Verify authentication headers
- Test Organizr tab URL: `http://192.168.50.70:8090`

## 🛠️ **Systematic Troubleshooting Process**

### **Step 1: Container Health Check**
```bash
# Check all container status
cd ~/github/hephaestus-homelab
docker compose -f docker-compose-infrastructure.yml ps

# Check for unhealthy containers
docker ps --filter "health=unhealthy"

# Check container logs for errors
docker logs portainer
docker logs uptime-kuma
docker logs grafana
docker logs prometheus
docker logs glances
docker logs it-tools
```

### **Step 2: Port Accessibility Test**
```bash
# Test all proxy ports
for port in 8083 8084 8085 8086 8087 8088 8089 8090 8091 8092; do
    echo "Testing port $port..."
    curl -I http://192.168.50.70:$port || echo "Port $port failed"
done

# Test direct ports
for port in 3001 9000 3000 9090 61208 8081; do
    echo "Testing direct port $port..."
    curl -I http://192.168.50.70:$port || echo "Direct port $port failed"
done
```

### **Step 3: Caddy Configuration Verification**
```bash
# Check Caddy configuration
docker exec caddy caddy validate --config /etc/caddy/Caddyfile

# Check Caddy logs
docker logs caddy

# Test Caddy admin API
curl http://localhost:2019/config/
```

### **Step 4: Network Connectivity Test**
```bash
# Test Docker network
docker network inspect web

# Test container-to-container connectivity
docker exec caddy ping portainer
docker exec caddy ping uptime-kuma
docker exec caddy ping grafana
docker exec caddy ping prometheus
docker exec caddy ping glances
docker exec caddy ping it-tools
```

## 🔧 **Common Fix Patterns**

### **Pattern 1: Container Not Running**
```bash
# Restart specific container
docker compose -f docker-compose-infrastructure.yml restart [service-name]

# Check container logs
docker logs [container-name]

# Check resource usage
docker stats [container-name]
```

### **Pattern 2: Port Not Accessible**
```bash
# Check if port is bound
sudo netstat -tlnp | grep :8084

# Check Caddy port mapping
docker port caddy

# Restart Caddy
docker compose -f docker-compose-infrastructure.yml restart caddy
```

### **Pattern 3: Proxy Configuration Issues**
```bash
# Validate Caddyfile syntax
docker exec caddy caddy validate --config /etc/caddy/Caddyfile

# Reload Caddy configuration
docker exec caddy caddy reload --config /etc/caddy/Caddyfile

# Check Caddy logs for proxy errors
docker logs caddy | grep -i proxy
```

### **Pattern 4: Service-Specific Issues**
```bash
# Check service health endpoints
curl http://192.168.50.70:3001/api/status  # Uptime Kuma
curl http://192.168.50.70:3000/api/health  # Grafana
curl http://192.168.50.70:9090/-/healthy   # Prometheus

# Check service configuration
docker exec [container-name] env
docker exec [container-name] ps aux
```

## 📋 **Organizr Tab Configuration**

### **Working Tab URLs (After Fixes)**
```
Portainer: http://192.168.50.70:8084
Uptime Kuma: http://192.168.50.70:8083
Grafana: http://192.168.50.70:8085
Prometheus: http://192.168.50.70:8086
Glances: http://192.168.50.70:8088
IT-Tools: http://192.168.50.70:8089
Obsidian: http://192.168.50.70:8090
MagicPages: http://192.168.50.70:8091
```

### **Tab Configuration Steps**
1. **Access Organizr**: `http://192.168.50.70:8082`
2. **Go to Settings** → **Tabs**
3. **Add New Tab** for each service
4. **Set Tab URL** to proxy port (808X)
5. **Test Tab** by clicking on it
6. **Verify Embedding** works properly

## 🚨 **Emergency Recovery Commands**

### **Complete Infrastructure Restart**
```bash
# Stop all services
cd ~/github/hephaestus-homelab
docker compose -f docker-compose-infrastructure.yml down

# Clean up any orphaned containers
docker system prune -f

# Restart all services
docker compose -f docker-compose-infrastructure.yml up -d

# Check status
docker compose -f docker-compose-infrastructure.yml ps
```

### **Caddy Configuration Reset**
```bash
# Backup current Caddyfile
cp proxy/Caddyfile proxy/Caddyfile.backup

# Restart Caddy
docker compose -f docker-compose-infrastructure.yml restart caddy

# Check Caddy logs
docker logs caddy
```

### **Network Reset**
```bash
# Recreate Docker network
docker network rm web
docker network create web

# Restart all services
docker compose -f docker-compose-infrastructure.yml up -d
```

## 📊 **Success Verification Checklist**

### **Infrastructure Services**
- [ ] Portainer accessible at `http://192.168.50.70:8084`
- [ ] Uptime Kuma accessible at `http://192.168.50.70:8083`
- [ ] Grafana accessible at `http://192.168.50.70:8085`
- [ ] Prometheus accessible at `http://192.168.50.70:8086`
- [ ] Glances accessible at `http://192.168.50.70:8088`
- [ ] IT-Tools accessible at `http://192.168.50.70:8089`

### **Application Services**
- [ ] MagicPages accessible at `http://192.168.50.70:8091`
- [ ] CapitolScope accessible at `http://192.168.50.70:8120`
- [ ] Obsidian accessible at `http://192.168.50.70:8090`

### **Organizr Integration**
- [ ] All tabs load in Organizr
- [ ] No iframe errors
- [ ] Proper authentication
- [ ] Responsive design

## 🎯 **Priority Order for Fixes**

### **High Priority (Fix First)**
1. **Portainer** - Docker management essential
2. **Uptime Kuma** - Service monitoring
3. **Grafana** - Metrics visualization
4. **Prometheus** - Data collection

### **Medium Priority**
5. **Glances** - System monitoring
6. **IT-Tools** - Network utilities
7. **Obsidian** - Personal notes

### **Lower Priority**
8. **MagicPages** - Application (can be fixed later)
9. **CapitolScope** - Application (can be fixed later)

## 🔄 **Testing Protocol**

### **After Each Fix**
1. **Test Direct Access**: `curl -I http://192.168.50.70:PORT`
2. **Test Proxy Access**: `curl -I http://192.168.50.70:808X`
3. **Test Organizr Tab**: Add tab and verify it loads
4. **Check Logs**: `docker logs [container-name]`
5. **Verify Headers**: Check for X-Frame-Options removal

### **Final Verification**
1. **All containers running**: `docker ps`
2. **All proxy ports working**: Test each 808X port
3. **All Organizr tabs working**: Test each tab
4. **No error logs**: Check all container logs
5. **Performance check**: Verify response times

---

## 🚀 **Quick Start Commands**

### **Begin Troubleshooting**
```bash
# Navigate to project
cd ~/github/hephaestus-homelab

# Check current status
docker compose -f docker-compose-infrastructure.yml ps

# Start systematic testing
for port in 8083 8084 8085 8086 8087 8088 8089; do
    echo "Testing port $port..."
    curl -I http://192.168.50.70:$port || echo "Port $port failed"
done
```

### **Fix Portainer First**
```bash
# Check Portainer
docker ps | grep portainer
curl -I http://192.168.50.70:9000
curl -I http://192.168.50.70:8084

# If broken, restart
docker compose -f docker-compose-infrastructure.yml restart portainer caddy
```

---

**Last Updated**: October 13, 2025  
**Status**: 🚨 Multiple Services Broken - Systematic Fix Required  
**Next**: Start with Portainer and work through infrastructure services
