# Hephaestus Port Management

Complete port mapping and connectivity guide for Hephaestus homelab.

## 🌐 Network Architecture

```
Internet → Cloudflare Tunnel → Caddy (Port 80) → Docker Services
```

## 📊 Port Mapping Table

| Service | Internal Port | External Access | Purpose | Status |
|---------|--------------|-----------------|---------|--------|
| **Caddy** | 80 | Via Cloudflare Tunnel | Reverse Proxy | 🟡 Pending |
| **Caddy** | 443 | Via Cloudflare Tunnel | HTTPS Proxy | 🟡 Pending |
| **Portainer** | 9000 | LAN Only | Docker Management | 🟡 Pending |
| **Uptime Kuma** | 3001 | Via Caddy/Tunnel | Monitoring | 🟡 Pending |
| **Grafana** | 3000 | Via Caddy/Tunnel | Metrics Dashboard | 🟡 Pending |
| **Prometheus** | 9090 | Via Caddy/Tunnel | Metrics Collection | 🟡 Pending |
| **Glances** | 61208 | LAN Only | System Monitor | 🟡 Pending |
| **cAdvisor** | 8080 | LAN Only | Container Metrics | 🟡 Pending |
| **Node Exporter** | 9100 | LAN Only | Host Metrics | 🟡 Pending |

Local on X2Go:
Portainer (Docker management) - http://10.0.0.252:9000
Grafana (Metrics dashboard) - http://10.0.0.252:3000
Uptime Kuma (Uptime monitoring) - http://10.0.0.252:3001
Prometheus (Metrics collection) - http://10.0.0.252:9090
cAdvisor (Container metrics) - http://10.0.0.252:8080
Glances (System monitoring) - http://10.0.0.252:61208

## 🚀 Application Ports

| Application | Internal Port | External Access | Purpose | Status |
|-------------|--------------|-----------------|---------|--------|
| **Magic Pages API** | 8000 | Via Caddy/Tunnel | Django API | 🟡 Pending |
| **CapitolScope** | 8001 | Via Caddy/Tunnel | FastAPI App | 🟡 Pending |
| **SchedShare** | 8002 | Via Caddy/Tunnel | Flask App | 🟡 Pending |
| **Portfolio** | 8003 | Via Caddy/Tunnel | Flask App | 🟡 Pending |
| **Magic Pages Frontend** | 80 | Via Caddy/Tunnel | Static Site | 🟡 Pending |

## 🔒 Security Zones

### **Public Access (via Cloudflare Tunnel)**
- All web applications
- Monitoring dashboards (Grafana, Uptime Kuma)
- API endpoints

### **LAN Only Access**
- Portainer (Docker management)
- Glances (system monitoring)
- cAdvisor (container metrics)
- Node Exporter (host metrics)

### **No External Access**
- Database ports (Postgres, Redis)
- Internal service communication

## 🌍 Domain Mapping

| Domain | Service | Internal Target |
|--------|---------|----------------|
| `hephaestus.chrislawrence.ca` | Admin Panel | Portainer |
| `portfolio.chrislawrence.ca` | Portfolio | Portfolio App |
| `api.chrislawrence.ca` | API | Magic Pages API |
| `capitolscope.chrislawrence.ca` | CapitolScope | CapitolScope App |
| `schedshare.chrislawrence.ca` | SchedShare | SchedShare App |
| `magicpages.chrislawrence.ca` | Frontend | Magic Pages Frontend |
| `uptime.chrislawrence.ca` | Monitoring | Uptime Kuma |
| `grafana.chrislawrence.ca` | Metrics | Grafana |

## 🐳 Docker Network Configuration

```yaml
networks:
  web:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

## 🔧 Port Testing Commands

### **Test Internal Connectivity**
```bash
# Test Caddy
curl -I http://localhost:80

# Test Portainer
curl -I http://localhost:9000

# Test Uptime Kuma
curl -I http://localhost:3001
```

### **Test Docker Network**
```bash
# Check network
docker network inspect web

# Test container connectivity
docker exec caddy ping uptime-kuma
docker exec caddy wget -O- http://uptime-kuma:3001
```

### **Test External Access**
```bash
# Test Cloudflare Tunnel
curl -I https://hephaestus.chrislawrence.ca

# Test application endpoints
curl -I https://portfolio.chrislawrence.ca
curl -I https://api.chrislawrence.ca/health
```

## 🚨 Port Conflicts

### **Common Conflicts**
- **Port 80**: Apache, Nginx, other web servers
- **Port 443**: HTTPS services
- **Port 3000**: Development servers
- **Port 9000**: Other management interfaces

### **Resolution**
```bash
# Find what's using a port
sudo lsof -i :80
sudo lsof -i :443
sudo lsof -i :3000

# Kill conflicting processes
sudo kill -9 <PID>
```

## 📝 Port Status Legend

- 🟢 **Running** - Service is active and accessible
- 🟡 **Pending** - Service configured but not started
- 🔴 **Error** - Service failed to start
- ⚪ **Stopped** - Service is stopped
- 🔒 **Blocked** - Port is blocked by firewall

## 🔄 Port Management Commands

### **Start All Services**
```bash
cd ~/github/hephaestus-homelab
docker compose up -d
```

### **Check Service Status**
```bash
docker compose ps
docker compose logs -f
```

### **Restart Specific Service**
```bash
docker compose restart caddy
docker compose restart portainer
```

### **Stop All Services**
```bash
docker compose down
```

## 📊 Monitoring Ports

### **Health Checks**
```bash
# Check all services
./scripts/health-check.sh

# Check specific service
curl -f http://localhost:3001/health || echo "Uptime Kuma down"
```

### **Port Scanning**
```bash
# Scan open ports
nmap -p 80,443,3000,3001,9000,9090,61208 localhost

# Scan Docker network
nmap -p 80,443,3000,3001,9000,9090,61208 172.20.0.0/16
```

## 🛠️ Troubleshooting

### **Port Already in Use**
1. Find the process: `sudo lsof -i :PORT`
2. Kill the process: `sudo kill -9 PID`
3. Or change the port in docker-compose.yml

### **Service Won't Start**
1. Check logs: `docker compose logs SERVICE_NAME`
2. Check port conflicts: `sudo lsof -i :PORT`
3. Check disk space: `df -h`
4. Check memory: `free -h`

### **Network Issues**
1. Recreate network: `docker network rm web && docker network create web`
2. Restart Docker: `sudo systemctl restart docker`
3. Check firewall: `sudo ufw status`

---

## 📋 Quick Reference

### **Essential Ports**
- **80**: Caddy (HTTP)
- **443**: Caddy (HTTPS)
- **9000**: Portainer
- **3001**: Uptime Kuma
- **3000**: Grafana

### **Application Ports**
- **8000**: Magic Pages API
- **8001**: CapitolScope
- **8002**: SchedShare
- **8003**: Portfolio

### **Monitoring Ports**
- **9090**: Prometheus
- **61208**: Glances
- **8080**: cAdvisor
- **9100**: Node Exporter

---

*Last Updated: $(date)*
*Status: 🟡 Pending Setup*
