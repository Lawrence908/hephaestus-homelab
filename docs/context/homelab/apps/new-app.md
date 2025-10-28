# New App Deployment Guide - Hephaestus Homelab

## 🚀 Quick Start Checklist

### ✅ Pre-Deployment Checklist
- [ ] App container is built and tested locally
- [ ] App runs on homelab-web network
- [ ] App has health check endpoint (optional but recommended)
- [ ] App is configured for subdomain or path-based routing
- [ ] DNS record added to Cloudflare (if using subdomain)

## 📋 Deployment Patterns

### Pattern 1: Public Subdomain (Recommended for Public Apps)
**Use for**: Portfolio apps, public services, user-facing applications

**Example**: `myapp.chrislawrence.ca`

#### Steps:
1. **Add Published Application Route** (Cloudflare Zero Trust → Tunnels → hephaestus → Published application routes):
   ```
   Subdomain: myapp
   Domain: chrislawrence.ca
   Service: http://localhost:80
   ```

2. **Add to Caddyfile** (`github/hephaestus-homelab/proxy/Caddyfile`):
   ```caddy
   # MyApp subdomain
   myapp.chrislawrence.ca:80 {
       reverse_proxy myapp:5000 {
           header_up Host {host}
           header_up X-Forwarded-Proto {scheme}
           header_up X-Forwarded-For {remote}
           header_up X-Real-IP {remote}
       }
       
       log {
           level INFO
           format json
           output file /data/logs/myapp.json {
               roll_size 15mb
               roll_keep 8
               roll_keep_for 168h
           }
       }
   }
   ```

3. **Deploy Container**:
   ```bash
   cd ~/apps/myapp
   docker compose -f docker-compose-homelab.yml up -d
   ```

4. **Test**:
   ```bash
   curl -I https://myapp.chrislawrence.ca/
   ```

### Pattern 2: Admin Service Under dev.chrislawrence.ca
**Use for**: Admin tools, development services, internal utilities

**Example**: `dev.chrislawrence.ca/myapp`

#### Steps:
1. **Add to Caddyfile** (in `dev.chrislawrence.ca:80` block):
   ```caddy
   handle_path /myapp {
       reverse_proxy myapp:5000 {
           header_down -X-Frame-Options
       }
   }
   
   handle_path /myapp/* {
       reverse_proxy myapp:5000 {
           header_down -X-Frame-Options
       }
   }
   ```

2. **Deploy Container**:
   ```bash
   cd ~/apps/myapp
   docker compose -f docker-compose-homelab.yml up -d
   ```

3. **Test**:
   ```bash
   curl -I https://dev.chrislawrence.ca/myapp/
   ```

### Pattern 3: Dedicated Protected Subdomain
**Use for**: Specialized admin services, monitoring tools

**Example**: `myapp.chrislawrence.ca` (with Cloudflare Access)

#### Steps:
1. **Add Published Application Route** (Cloudflare Zero Trust → Tunnels → hephaestus → Published application routes):
   ```
   Subdomain: myapp
   Domain: chrislawrence.ca
   Service: http://localhost:80
   ```

2. **Add Cloudflare Access Policy**:
   - Go to Cloudflare Zero Trust → Access → Applications
   - Add new application: `myapp.chrislawrence.ca`
   - Set access policy (Admin/Public/Friends)

3. **Add to Caddyfile**:
   ```caddy
   # MyApp protected subdomain
   myapp.chrislawrence.ca:80 {
       reverse_proxy myapp:5000 {
           header_up Host {host}
           header_up X-Forwarded-Proto {scheme}
           header_up X-Forwarded-For {remote}
           header_up X-Real-IP {remote}
       }
       
       log {
           level INFO
           format json
           output file /data/logs/myapp.json {
               roll_size 15mb
               roll_keep 8
               roll_keep_for 168h
           }
       }
   }
   ```

4. **Deploy Container**:
   ```bash
   cd ~/apps/myapp
   docker compose -f docker-compose-homelab.yml up -d
   ```

## 🐳 Standard Docker Compose Template

### For Public Apps (`docker-compose-homelab.yml`):
```yaml
version: '3.8'

networks:
  web:
    external: true
    name: homelab-web

services:
  myapp:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: myapp
    restart: unless-stopped
    networks:
      - web
    ports:
      - "81XX:5000"  # Use next available port (8100, 8101, etc.)
    environment:
      - NODE_ENV=production
      - PORT=5000
    volumes:
      - myapp_data:/app/data
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

volumes:
  myapp_data:
```

### For Admin Apps (same template, different port):
```yaml
version: '3.8'

networks:
  web:
    external: true
    name: homelab-web

services:
  myapp:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: myapp
    restart: unless-stopped
    networks:
      - web
    ports:
      - "81XX:5000"  # Use next available port
    environment:
      - NODE_ENV=production
      - PORT=5000
    volumes:
      - myapp_data:/app/data
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

volumes:
  myapp_data:
```

## 🔧 Port Management

### Current Port Allocation:
- **8100**: Magic Pages API
- **8101**: Magic Pages Frontend
- **8110**: Portfolio (chrislawrence-portfolio)
- **8120**: CapitolScope API
- **8130**: SchedShare (CourseSchedule2Calendar)
- **8150-8159**: IoT Services (MQTT, Meshtastic, etc.)
- **8160-8169**: AI Services (OpenWebUI, ComfyUI, etc.)
- **8170-8179**: Available for new apps
- **8180-8189**: Available for new apps
- **8190-8199**: Available for new apps

### Next Available Ports:
- **Public Apps**: 8111, 8112, 8113, 8114, 8115, 8116, 8117, 8118, 8119
- **Admin Apps**: 8170, 8171, 8172, 8173, 8174, 8175, 8176, 8177, 8178, 8179

## 📝 Documentation Updates Required

### 1. Update `services.md`:
Add to appropriate section:
```markdown
- **MyApp**: Description (`https://myapp.chrislawrence.ca`)
```

### 2. Update `services-status.md`:
Add to appropriate table:
```markdown
| **MyApp** | `https://myapp.chrislawrence.ca` | ✅ Working | myapp:5000 | Description |
```

### 3. Update `test-homelab-monitoring.sh`:
Add to SERVICES array:
```bash
["myapp"]="https://myapp.chrislawrence.ca/"
```

Add to LOCAL_PATHS array:
```bash
["myapp"]="/myapp/"
```

Add to appropriate service category:
```bash
PUBLIC_SERVICES=("main" "portfolio" "schedshare" "capitolscope" "magicpages" "eventsphere" "myapp")
```

## 🚀 Rapid Deployment Commands

### Complete Deployment Script:
```bash
#!/bin/bash
# rapid-deploy.sh

APP_NAME="$1"
APP_PORT="$2"
APP_TYPE="$3"  # "public" or "admin"

if [ -z "$APP_NAME" ] || [ -z "$APP_PORT" ] || [ -z "$APP_TYPE" ]; then
    echo "Usage: $0 <app-name> <port> <public|admin>"
    echo "Example: $0 myapp 8111 public"
    exit 1
fi

echo "🚀 Deploying $APP_NAME on port $APP_PORT as $APP_TYPE service..."

# 1. Deploy container
cd ~/apps/$APP_NAME
docker compose -f docker-compose-homelab.yml up -d

# 2. Wait for container to start
sleep 10

# 3. Test local connectivity
echo "Testing local connectivity..."
curl -I http://localhost:$APP_PORT/ || echo "❌ Local test failed"

# 4. Test public connectivity (if public)
if [ "$APP_TYPE" = "public" ]; then
    echo "Testing public connectivity..."
    curl -I https://$APP_NAME.chrislawrence.ca/ || echo "❌ Public test failed"
fi

# 5. Test admin connectivity (if admin)
if [ "$APP_TYPE" = "admin" ]; then
    echo "Testing admin connectivity..."
    curl -I https://dev.chrislawrence.ca/$APP_NAME/ || echo "❌ Admin test failed"
fi

echo "✅ Deployment complete!"
```

## 🔍 Testing & Validation

### Health Check Commands:
```bash
# Test container status
docker ps | grep myapp

# Test local connectivity
curl -I http://localhost:81XX/

# Test public connectivity
curl -I https://myapp.chrislawrence.ca/

# Test admin connectivity
curl -I https://dev.chrislawrence.ca/myapp/

# Test with monitoring script
./test-homelab-monitoring.sh --service myapp --verbose
```

### Log Monitoring:
```bash
# Container logs
docker logs myapp -f

# Caddy logs
docker logs caddy -f

# Application-specific logs
tail -f /data/logs/myapp.json
```

## 🛠️ Troubleshooting

### Common Issues:

1. **Container won't start**:
   ```bash
   docker logs myapp
   docker compose -f docker-compose-homelab.yml ps
   ```

2. **Caddy routing issues**:
   ```bash
   docker exec caddy caddy validate --config /etc/caddy/Caddyfile
   docker compose -f proxy/docker-compose.yml restart caddy
   ```

3. **DNS not resolving**:
   ```bash
   nslookup myapp.chrislawrence.ca
   dig myapp.chrislawrence.ca
   ```

4. **Cloudflare Access issues**:
   - Check Cloudflare Zero Trust → Access → Applications
   - Verify access policy is correct
   - Test with different browser/incognito

## 📚 Related Documentation

- [Service Architecture](../infra/services.md) - Service definitions and patterns
- [Deployment Guide](../infra/deployment.md) - Infrastructure deployment procedures
- [Security Configuration](../infra/security.md) - Authentication and access control
- [Network Architecture](../infra/networks.md) - Docker network setup

## 🎯 Best Practices

1. **Always use homelab-web network** for internal communication
2. **Include health checks** in docker-compose files
3. **Use structured logging** with Caddy
4. **Test locally first** before deploying publicly
5. **Update documentation** immediately after deployment
6. **Use consistent naming** conventions
7. **Monitor resource usage** after deployment
8. **Keep ports organized** and documented

---

**Last Updated**: $(date)
**Version**: 1.0
**Compatible With**: Docker Compose v2.0+, Caddy v2.x, Cloudflare Tunnel
