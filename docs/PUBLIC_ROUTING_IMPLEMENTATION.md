# Public Routing Implementation Plan

## 🎯 **Objective**
Implement public access to all homelab services via `chrislawrence.ca` subpaths with proper authentication, SSL, and Organizr integration.

## 📊 **Current Status**
- ✅ Organizr working at `http://192.168.50.70:8082`
- ✅ Uptime Kuma proxy working at `http://192.168.50.70:8083`
- ✅ Portainer proxy working at `http://192.168.50.70:8084`
- ✅ Cloudflare Tunnel active and configured

## 🗺️ **Target URL Structure**

### **Infrastructure Services** (Ready for Public Access)
```
chrislawrence.ca/dashboard   → Organizr (Main entry point)
chrislawrence.ca/uptime      → Uptime Kuma (Service monitoring)
chrislawrence.ca/docker      → Portainer (Container management)
chrislawrence.ca/metrics     → Grafana (Metrics dashboard)
chrislawrence.ca/prometheus  → Prometheus (Metrics collection)
chrislawrence.ca/containers  → cAdvisor (Container metrics)
chrislawrence.ca/system      → Glances (System monitoring)
chrislawrence.ca/tools       → IT-Tools (Network utilities)
```

### **Application Services** (Future Deployment)
```
chrislawrence.ca/magicpages-api         → Magic Pages API (Port 8100) - For testing only, will be moved to api.magicpages.com later, maybe I will port that over to cloudflare at that time rather than DNS through GoDaddy currently.
chrislawrence.ca/pages       → Magic Pages Frontend (Port 8101) - For testing only, will be moved to magicpages.com later, maybe I will port that over to cloudflare at that time rather than DNS through GoDaddy currently.
chrislawrence.ca/portfolio   → Portfolio App (Port 8110) - Currently live at chrislawrence.ca - could stay there, or I use that as a "Home" page to connect to user facing docker containers (it could be like a cool Home page?) then /portfolio is the current portfolio website? I like that.
chrislawrence.ca/capitolscope     → CapitolScope (Port 8120)
chrislawrence.ca/schedshare    → SchedShare (Port 8130) - currently at schedshare.chrislawrence.ca (we'll route this to chrislawrence.ca/schedshare when we enact this switch)
```

### **🔒 Security Strategy**
- **Public Services**: Portfolio (Home page), CapitolScope, SchedShare, Magic Pages (testing)
- **Protected Services**: Organizr dashboard behind Cloudflare Access - main entry point for infrastructure
- **Internal-Only**: Monitoring tools (Grafana, Prometheus, etc.) accessible only through Organizr tabs

## 🔧 **Implementation Steps**

### **Phase 1: Complete Organizr Proxy Ports**

#### **Step 1.1: Add Remaining Proxy Ports**
Update `docker-compose-infrastructure.yml`:
```yaml
caddy:
  ports:
    - "80:80"
    - "443:443"  # Add HTTPS support
    - "8083:8083"  # Uptime Kuma (✅ Done)
    - "8084:8084"  # Portainer (✅ Done)
    - "8085:8085"  # Grafana
    - "8086:8086"  # Prometheus
    - "8087:8087"  # cAdvisor
    - "8088:8088"  # Glances
    - "8089:8089"  # IT-Tools
```

#### **Step 1.2: Add Caddy Proxy Configurations**
Add to `Caddyfile` for each service:
```caddy
# Grafana proxy for Organizr embedding (port 8085)
:8085 {
    basic_auth {
        admin $2a$14$w9sGeM752W5OBJfOXiRSWupEl2w75yu5WNIuNF9KMjBz42B4rrR7S
    }

    reverse_proxy grafana:3000 {
        header_down -X-Frame-Options
        header_down -Content-Security-Policy
    }

    header {
        -X-Frame-Options
        Content-Security-Policy "frame-ancestors *"
    }
}

# Repeat pattern for: Prometheus (8086), cAdvisor (8087), Glances (8088), IT-Tools (8089)
```

### **Phase 2: Public Subpath Routing**

#### **Step 2.1: Main Caddy Configuration**
Update `Caddyfile` to handle `chrislawrence.ca` subpaths:
```caddy
chrislawrence.ca {
    # Protected dashboard (Cloudflare Access + Basic Auth)
    handle_path /dashboard/* {
        basic_auth {
            admin $2a$14$w9sGeM752W5OBJfOXiRSWupEl2w75yu5WNIuNF9KMjBz42B4rrR7S
        }
        reverse_proxy organizr:80
    }

    # Public applications (no auth required)
    handle_path /portfolio/* {
        reverse_proxy portfolio:8010
    }

    handle_path /capitolscope/* {
        reverse_proxy capitolscope:8020
    }

    handle_path /schedshare/* {
        reverse_proxy schedshare:8030
    }

    # Monitoring services
    handle_path /uptime/* {
        reverse_proxy uptime-kuma:3001 {
            header_down -X-Frame-Options
        }
        header {
            -X-Frame-Options
            Content-Security-Policy "frame-ancestors 'self'"
        }
    }

    handle_path /docker/* {
        reverse_proxy portainer:9000 {
            header_down -X-Frame-Options
        }
    }

    handle_path /metrics/* {
        reverse_proxy grafana:3000 {
            header_down -X-Frame-Options
        }
    }

    handle_path /prometheus/* {
        reverse_proxy prometheus:9090
    }

    handle_path /containers/* {
        reverse_proxy cadvisor:8080
    }

    handle_path /system/* {
        reverse_proxy glances:61208
    }

    handle_path /tools/* {
        reverse_proxy it-tools:8081
    }

    # Default redirect to dashboard
    redir / /dashboard/
}
```

#### **Step 2.2: Cloudflare Tunnel Configuration**
Update `~/.cloudflared/config.yml`:
```yaml
tunnel: hephaestus-homelab
credentials-file: /home/chris/.cloudflared/7bbb8d12-6cf4-4556-8c5f-006fb7bab126.json

ingress:
  # Main domain routing
  - hostname: chrislawrence.ca
    service: http://localhost:80
  
  # Legacy subdomain support (optional)
  - hostname: dashboard.hephaestus.chrislawrence.ca
    service: http://localhost:8082
  - hostname: uptime.hephaestus.chrislawrence.ca
    service: http://localhost:8083
  - hostname: docker.hephaestus.chrislawrence.ca
    service: http://localhost:8084
  
  # Catch-all
  - service: http_status:404
```

### **Phase 3: Application Port Migration**

#### **Step 3.1: Update Application Ports**
When deploying applications, use new port structure:
```yaml
# Magic Pages API
magic-pages-api:
  ports:
    - "8100:8000"  # Changed from 8000

# Magic Pages Frontend  
magic-pages-frontend:
  ports:
    - "8101:80"    # Changed from 80

# Portfolio
portfolio:
  ports:
    - "8110:8010"  # Changed from 8010

# CapitolScope
capitolscope:
  ports:
    - "8120:8020"  # Changed from 8020

# SchedShare
schedshare:
  ports:
    - "8130:8030"  # Changed from 8030
```

#### **Step 3.2: Add Application Routing**
Extend `chrislawrence.ca` configuration:
```caddy
chrislawrence.ca {
    # ... existing infrastructure routes ...

    # Application routes
    handle_path /api/* {
        reverse_proxy magic-pages-api:8000
    }

    handle_path /pages/* {
        reverse_proxy magic-pages-frontend:80
    }

    handle_path /portfolio/* {
        reverse_proxy portfolio:8010
    }

    handle_path /capitol/* {
        reverse_proxy capitolscope:8020
    }

    handle_path /schedule/* {
        reverse_proxy schedshare:8030
    }
}
```

## 🔒 **Security Configuration**

### **Authentication Strategy**
1. **Public Services** (Portfolio, CapitolScope, SchedShare, Magic Pages):
   - No authentication required
   - Direct public access via `chrislawrence.ca/{service}`

2. **Protected Infrastructure** (Organizr Dashboard):
   - **Cloudflare Access** - Primary protection for `/dashboard`
   - **Caddy Basic Auth** - Secondary layer
   - Access to monitoring tools only through Organizr tabs

3. **Internal Services** (Grafana, Prometheus, etc.):
   - No direct public access
   - Only accessible through Organizr proxy ports for embedding
   - Protected by Organizr's authentication layer

### **SSL/TLS Configuration**
```caddy
chrislawrence.ca {
    # Automatic HTTPS via Cloudflare
    tls {
        dns cloudflare {env.CLOUDFLARE_API_TOKEN}
    }
    
    # Security headers
    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "SAMEORIGIN"
        Referrer-Policy "strict-origin-when-cross-origin"
    }
    
    # ... route configurations ...
}
```

## 🧪 **Testing Plan**

### **Phase 1 Testing**
```bash
# Test proxy ports
curl -I http://192.168.50.70:8085 -u admin:admin123  # Grafana
curl -I http://192.168.50.70:8086 -u admin:admin123  # Prometheus
curl -I http://192.168.50.70:8087 -u admin:admin123  # cAdvisor
curl -I http://192.168.50.70:8088 -u admin:admin123  # Glances
curl -I http://192.168.50.70:8089 -u admin:admin123  # IT-Tools

# Verify no X-Frame-Options headers
```

### **Phase 2 Testing**
```bash
# Test public subpaths
curl -I https://chrislawrence.ca/dashboard -u admin:admin123
curl -I https://chrislawrence.ca/uptime -u admin:admin123
curl -I https://chrislawrence.ca/docker -u admin:admin123

# Test redirects and routing
curl -L https://chrislawrence.ca/  # Should redirect to /dashboard/
```

### **Organizr Integration Testing**
1. Add each proxy port to Organizr tabs
2. Verify iframe embedding works
3. Test functionality within Organizr interface

## 📋 **Deployment Checklist**

### **Pre-deployment**
- [ ] Backup current Caddyfile
- [ ] Backup current docker-compose configurations
- [ ] Document current working state

### **Phase 1 Deployment**
- [ ] Add proxy ports to docker-compose-infrastructure.yml
- [ ] Add proxy configurations to Caddyfile
- [ ] Restart Caddy container
- [ ] Test all proxy ports
- [ ] Add services to Organizr
- [ ] Test Organizr embedding

### **Phase 2 Deployment**
- [ ] Add public subpath routing to Caddyfile
- [ ] Update Cloudflare Tunnel configuration
- [ ] Restart Cloudflare Tunnel
- [ ] Test public access
- [ ] Verify authentication
- [ ] Test SSL certificates

### **Phase 3 Deployment** (Future)
- [ ] Deploy applications with new port structure
- [ ] Add application routing to Caddyfile
- [ ] Test application access
- [ ] Update documentation

## 🚨 **Rollback Plan**

If issues occur:
1. **Immediate**: Revert to previous Caddyfile
2. **Container Issues**: Restart with previous docker-compose
3. **DNS Issues**: Revert Cloudflare Tunnel config
4. **Emergency**: Use direct port access as fallback

## 📚 **Documentation Updates**

After successful deployment:
- [ ] Update ROUTING.md with final configurations
- [ ] Update PORTS.md with new port assignments
- [ ] Create user guide for public access
- [ ] Document troubleshooting procedures

---

**Created**: October 13, 2025  
**Status**: Ready for Implementation  
**Next Action**: Begin Phase 1 - Complete Organizr proxy ports
