# Hephaestus Homelab - Routing & URL Structure

Complete routing guide for accessing services via different methods: direct ports, subdomains, and subpaths.

## 🌐 **URL Structure Overview**

### **Access Methods**
1. **Direct Port Access** (LAN only) - `http://192.168.50.70:PORT`
2. **Subdomain Access** (Public via Cloudflare) - `https://service.hephaestus.chrislawrence.ca`
3. **Subpath Access** (For embedding) - `http://192.168.50.70/service/`

## 📊 **Complete Routing Table**

### **🏠 Infrastructure Services**
| Service | Direct Port (LAN) | Organizr Proxy Port | Public URL | Status |
|---------|-------------------|-------------------|------------|--------|
| **Organizr** | `http://192.168.50.70:8082` | N/A (Main Dashboard) | `chrislawrence.ca/dashboard` | 🟢 Working |
| **Uptime Kuma** | `http://192.168.50.70:3001` | `http://192.168.50.70:8083` | `chrislawrence.ca/uptime` | 🟢 Working |
| **Portainer** | `http://192.168.50.70:9000` | `http://192.168.50.70:8084` | `chrislawrence.ca/docker` | 🟢 Working |
| **Grafana** | `http://192.168.50.70:3000` | `http://192.168.50.70:8085` | `chrislawrence.ca/metrics` | 🟡 Needs Config |
| **Prometheus** | `http://192.168.50.70:9090` | `http://192.168.50.70:8086` | `chrislawrence.ca/prometheus` | 🟡 Needs Config |
| **cAdvisor** | `http://192.168.50.70:8080` | `http://192.168.50.70:8087` | `chrislawrence.ca/containers` | 🟡 Needs Config |
| **Glances** | `http://192.168.50.70:61208` | `http://192.168.50.70:8088` | `chrislawrence.ca/system` | 🟡 Needs Config |
| **IT-Tools** | `http://192.168.50.70:8081` | `http://192.168.50.70:8089` | `chrislawrence.ca/tools` | 🟡 Needs Config |
| **Obsidian (Selkies)** | `https://192.168.50.70:8061` | N/A (HTTPS required) | `https://chrislawrence.ca/notes` | 🟢 Working |

### **📱 Application Services**
| Application | Port | Public URL | Access Level | Status |
|-------------|------|------------|--------------|--------|
| **Magic Pages API** | 8100 | `chrislawrence.ca/magicpages-api` | Public (Testing) | 🟡 Pending |
| **Magic Pages Frontend** | 8101 | `chrislawrence.ca/pages` | Public (Testing) | 🟡 Pending |
| **Portfolio** | 8110 | `chrislawrence.ca/portfolio` | Public (Home Page) | 🟡 Pending |
| **CapitolScope** | 8120 | `chrislawrence.ca/capitolscope` | Public | 🟡 Pending |
| **SchedShare** | 8130 | `chrislawrence.ca/schedshare` | Public | 🟡 Pending |
| **EventSphere (mongo-events-demo)** | 8140 | `chrislawrence.ca/eventsphere` | Public (Testing) | 🟡 Pending |
| **n8n** | 8141 | `chrislawrence.ca/n8n` | Private by default (Auth required) | 🟡 Pending |
| **Minecraft Server** | 25565 (TCP) | N/A (non-HTTP) | LAN-only (or manual port forward) | 🟡 Pending |

## 🎯 **Organizr Tab URLs (Recommended)**

Use these proxy ports for embedding in Organizr (removes X-Frame-Options):

### **✅ Working URLs**
- **Uptime Kuma**: `http://192.168.50.70:8083/dashboard` (Proxy with iframe support)

### **🔄 Next to Configure**
- **Portainer**: `http://192.168.50.70:8084` (Will proxy to port 9000)
- **Grafana**: `http://192.168.50.70:8085` (Will proxy to port 3000)
- **Prometheus**: `http://192.168.50.70:8086` (Will proxy to port 9090)
- **cAdvisor**: `http://192.168.50.70:8087` (Will proxy to port 8080)
- **Glances**: `http://192.168.50.70:8088` (Will proxy to port 61208)
- **IT-Tools**: `http://192.168.50.70:8089` (Will proxy to port 8081)

### **🎯 Strategy**
Each service gets a dedicated proxy port (808X) that:
- Removes `X-Frame-Options` headers
- Sets permissive `Content-Security-Policy`
- Maintains authentication
- Enables iframe embedding in Organizr

## 🌍 **Public URL Planning**

### **Logical Subdomain Structure**
Organized by function and purpose:

#### **🏠 Core Infrastructure**
- `dashboard.hephaestus.chrislawrence.ca` → Organizr (Main entry point)
- `docker.hephaestus.chrislawrence.ca` → Portainer (Container management)

#### **📊 Monitoring & Metrics**
- `uptime.hephaestus.chrislawrence.ca` → Uptime Kuma (Service monitoring)
- `metrics.hephaestus.chrislawrence.ca` → Grafana (Metrics dashboard)
- `prometheus.hephaestus.chrislawrence.ca` → Prometheus (Metrics collection)
- `containers.hephaestus.chrislawrence.ca` → cAdvisor (Container metrics)
- `system.hephaestus.chrislawrence.ca` → Glances (System monitoring)

#### **🛠️ Tools & Utilities**
- `tools.hephaestus.chrislawrence.ca` → IT-Tools (Network utilities)

#### **📱 Applications** (Future)
- `portfolio.hephaestus.chrislawrence.ca` → Portfolio App
- `api.hephaestus.chrislawrence.ca` → Magic Pages API
- `pages.hephaestus.chrislawrence.ca` → Magic Pages Frontend
- `capitol.hephaestus.chrislawrence.ca` → CapitolScope
- `schedule.hephaestus.chrislawrence.ca` → SchedShare

### **🎯 URL Hierarchy Logic**
1. **Short & Memorable** - Easy to type and remember
2. **Function-Based** - Groups related services logically
3. **Consistent Naming** - Follows predictable patterns
4. **Future-Proof** - Allows for expansion

## 🔧 **Subpath Configuration Issues**

### **Uptime Kuma Problems**
1. **WebSocket Endpoints**: `/socket.io/` requests fail
2. **Static Assets**: `/icon.svg`, `/assets/*` requests fail
3. **API Endpoints**: Various API calls fail

### **Root Cause**
Uptime Kuma expects to run at the root path (`/`) and doesn't support subpath deployment without additional configuration.

## ✅ **Recommended Solutions**

### **Option 1: Direct Port Access (Simplest)**
Use direct port access for all services in Organizr:

```
Portainer: http://192.168.50.70:9000
Uptime Kuma: http://192.168.50.70:3001/dashboard
Grafana: http://192.168.50.70:3000
Prometheus: http://192.168.50.70:9090
cAdvisor: http://192.168.50.70:8080
Glances: http://192.168.50.70:61208
```

### **Option 2: Subdomain Access (Public)**
Use public subdomains for services that support iframe embedding:

```
Portainer: https://hephaestus.chrislawrence.ca
Grafana: https://grafana.hephaestus.chrislawrence.ca
Prometheus: https://prometheus.hephaestus.chrislawrence.ca
```

### **Option 3: Hybrid Approach (Recommended)**
- **Direct ports** for services that work well (most services)
- **Subdomains** for services that need public access
- **Avoid subpaths** unless specifically needed and properly configured

## 🛠️ **Caddy Configuration Patterns**

### **Basic Service (No Embedding Issues)**
```caddy
service.hephaestus.chrislawrence.ca {
    basic_auth {
        admin $2a$14$w9sGeM752W5OBJfOXiRSWupEl2w75yu5WNIuNF9KMjBz42B4rrR7S
    }
    reverse_proxy service-container:port
}
```

### **Service with Embedding Support**
```caddy
service.hephaestus.chrislawrence.ca {
    basic_auth {
        admin $2a$14$w9sGeM752W5OBJfOXiRSWupEl2w75yu5WNIuNF9KMjBz42B4rrR7S
    }
    
    header {
        -X-Frame-Options
        Content-Security-Policy "frame-ancestors 'self' dashboard.hephaestus.chrislawrence.ca organizr.hephaestus.chrislawrence.ca localhost:8082"
    }
    
    reverse_proxy service-container:port {
        header_down -X-Frame-Options
    }
}
```

### **Complex Service with Assets (Like Uptime Kuma)**
```caddy
# Main service
service.hephaestus.chrislawrence.ca {
    basic_auth {
        admin $2a$14$w9sGeM752W5OBJfOXiRSWupEl2w75yu5WNIuNF9KMjBz42B4rrR7S
    }
    
    header {
        -X-Frame-Options
        Content-Security-Policy "frame-ancestors *"
    }
    
    reverse_proxy service-container:port {
        header_down -X-Frame-Options
    }
}

# Subpath for embedding (if needed)
:80 {
    handle_path /service/* {
        reverse_proxy service-container:port {
            header_down -X-Frame-Options
        }
        header {
            -X-Frame-Options
            Content-Security-Policy "frame-ancestors *"
        }
    }
    
    # Handle assets
    handle /assets/* {
        reverse_proxy service-container:port
    }
    
    # Handle API endpoints
    handle /api/* {
        reverse_proxy service-container:port
    }
    
    # Handle WebSocket endpoints
    handle /socket.io/* {
        reverse_proxy service-container:port
    }
}
```

## 🚨 **Current Issues & Fixes**

### **Uptime Kuma Subpath Issues**
The current `/uptime/*` configuration is incomplete. Missing endpoints:
- `/socket.io/*` - WebSocket connections
- `/icon.svg` - Favicon
- Various API endpoints

### **✅ Successful Solution**
Use dedicated proxy ports for iframe embedding:

1. **Create proxy port** (e.g., 8083 for Uptime Kuma)
2. **Configure Caddy** to remove X-Frame-Options headers
3. **Update Organizr** tab URL to proxy port
4. **Test embedding** - should work perfectly!

## 📋 **Implementation Roadmap**

### **✅ Phase 1: Proof of Concept (Completed)**
1. ✅ Uptime Kuma proxy port 8083 working
2. ✅ X-Frame-Options removal confirmed
3. ✅ Organizr embedding successful

### **🔄 Phase 2: Expand to All Services (In Progress)**
1. 🔄 Add proxy ports 8084-8089 for remaining services
2. 🔄 Test each service in Organizr
3. 🔄 Update Caddy port mappings

### **⏳ Phase 3: Public Subdomains**
1. ⏳ Implement public subdomain routing
2. ⏳ Add Cloudflare DNS entries
3. ⏳ Test public access with authentication

### **⏳ Phase 4: Optimization**
1. ⏳ Performance tuning
2. ⏳ SSL certificate management
3. ⏳ Load balancing if needed

## 🔗 **Quick Reference URLs**

### **Organizr Dashboard**
- **LAN**: `http://192.168.50.70:8082`
- **Public**: `https://dashboard.hephaestus.chrislawrence.ca`

### **Obsidian (Notes)**
- **Direct HTTPS (LAN)**: `https://192.168.50.70:8061`  (required by Selkies)
- **Public Subpath**: `https://chrislawrence.ca/notes`
- Tip: In Organizr, configure the Obsidian tab to open in a new tab using one of the URLs above (iframes over HTTP will fail due to HTTPS requirement).

### **Service Management**
- **Portainer**: `http://192.168.50.70:9000`
- **Caddy Admin**: Not exposed (security)

### **Monitoring Stack**
- **Uptime Kuma**: `http://192.168.50.70:3001`
- **Grafana**: `http://192.168.50.70:3000`
- **Prometheus**: `http://192.168.50.70:9090`

### **System Monitoring**
- **Glances**: `http://192.168.50.70:61208`
- **cAdvisor**: `http://192.168.50.70:8080`

## 🔒 **Security Considerations**

### **Authentication Layers**
1. **Caddy Basic Auth** - First line of defense
2. **Cloudflare Tunnel** - Public access protection
3. **Service-level Auth** - Individual service authentication

### **Network Security**
- **LAN-only services** use direct port access
- **Public services** go through Cloudflare Tunnel
- **No direct internet exposure** of service ports

### **Iframe Security**
- **CSP headers** control embedding permissions
- **X-Frame-Options** removed only where needed
- **frame-ancestors** directive limits embedding sources

---

## 🚀 **Next Steps Implementation**

### **Step 1: Add Remaining Proxy Ports**
Add to `docker-compose-infrastructure.yml`:
```yaml
caddy:
  ports:
    - "80:80"
    - "8083:8083"  # Uptime Kuma (✅ Done)
    - "8084:8084"  # Portainer
    - "8085:8085"  # Grafana
    - "8086:8086"  # Prometheus
    - "8087:8087"  # cAdvisor
    - "8088:8088"  # Glances
    - "8089:8089"  # IT-Tools
```

### **Step 2: Add Caddy Configurations**
For each service, add to `Caddyfile`:
```caddy
# Service proxy for Organizr embedding (port 808X)
:808X {
    basic_auth {
        admin $2a$14$w9sGeM752W5OBJfOXiRSWupEl2w75yu5WNIuNF9KMjBz42B4rrR7S
    }

    reverse_proxy service-container:port {
        header_down -X-Frame-Options
        header_down -Content-Security-Policy
    }

    header {
        -X-Frame-Options
        Content-Security-Policy "frame-ancestors *"
    }
}
```

### **Step 3: Test Each Service**
1. Restart Caddy after configuration changes
2. Test proxy port: `curl -I http://192.168.50.70:808X -u admin:admin123`
3. Verify no X-Frame-Options header
4. Add to Organizr and test embedding

### **Step 4: Add Public Subdomains**
Once proxy ports work, add public routing for each service.

---

**Last Updated**: October 13, 2025  
**Status**: ✅ Uptime Kuma Working - Ready to Expand  
**Next**: Implement proxy ports 8084-8089 for remaining services
