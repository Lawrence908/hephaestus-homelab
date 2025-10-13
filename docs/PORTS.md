# Hephaestus Port Management

Complete port mapping and connectivity guide for Hephaestus homelab.

## 🌐 Network Architecture

```
Internet → Cloudflare Tunnel → Docker Services (Direct)
```

**Note**: Services are accessed directly via Cloudflare Tunnel, bypassing Caddy for simplified routing.

## 📊 Port Mapping Table

| Service | Internal Port | External Access | Purpose | Status |
|---------|--------------|-----------------|---------|--------|
| **Portainer** | 9000 | Via Cloudflare Tunnel | Docker Management | 🟢 Running |
| **Uptime Kuma** | 3001 | Via Cloudflare Tunnel | Monitoring | 🟢 Running |
| **Grafana** | 3000 | Via Cloudflare Tunnel | Metrics Dashboard | 🟢 Running |
| **Prometheus** | 9090 | Via Cloudflare Tunnel | Metrics Collection | 🟢 Running |
| **Glances** | 61208 | LAN Only | System Monitor | 🟢 Running |
| **cAdvisor** | 8080 | LAN Only | Container Metrics | 🟢 Running |
| **Node Exporter** | 9100 | LAN Only | Host Metrics | 🟡 Pending |
| **IT-Tools** | 8081 | LAN Only | IT Utilities | 🟢 Running |
| **Organizr** | 8082 | Via Cloudflare Tunnel | Central Dashboard | 🟡 Pending |

Local on X2Go:
Portainer (Docker management) - http://192.168.50.70:9000
Grafana (Metrics dashboard) - http://192.168.50.70:3000
Uptime Kuma (Uptime monitoring) - http://192.168.50.70:3001
Prometheus (Metrics collection) - http://192.168.50.70:9090
cAdvisor (Container metrics) - http://192.168.50.70:8080
Glances (System monitoring) - http://192.168.50.70:61208
IT-Tools (IT utilities) - http://192.168.50.70:8081
Organizr (Central dashboard) - http://192.168.50.70:8082

## 🚀 Application Ports

| Application | Port | Public URL | Purpose | Status |
|-------------|------|------------|---------|--------|
| **Magic Pages API** | 8100 | `chrislawrence.ca/magicpages-api` | Django API (Testing) | 🟡 Pending |
| **Magic Pages Frontend** | 8101 | `chrislawrence.ca/pages` | Static Site (Testing) | 🟡 Pending |
| **Portfolio** | 8110 | `chrislawrence.ca/portfolio` | Flask App (Home Page) | 🟡 Pending |
| **CapitolScope** | 8120 | `chrislawrence.ca/capitolscope` | FastAPI App | 🟡 Pending |
| **SchedShare** | 8130 | `chrislawrence.ca/schedshare` | Flask App | 🟡 Pending |
| **EventSphere (mongo-events-demo)** | 8140 | `chrislawrence.ca/eventsphere` | Event stream demo | 🟡 Pending |
| **n8n** | 8141 | `chrislawrence.ca/n8n` | Automation/workflows | 🟡 Pending |
| **Minecraft Server** | 25565 (TCP/UDP) | N/A (non-HTTP) | Game server | 🟡 Pending |

## 🔌 IoT & Communication Services

| Service | Port | Public URL | Purpose | Status |
|---------|------|------------|---------|--------|
| **MQTT Broker** | 8150 | N/A (TCP) | Message broker | 🟡 Pending |
| **MQTT WebSocket** | 8151 | N/A (WebSocket) | MQTT over WebSocket | 🟡 Pending |
| **MQTT Explorer** | 8152 | `chrislawrence.ca/mqtt` | Web MQTT client | 🟡 Pending |
| **Meshtastic MQTT** | 8153 | N/A (TCP) | Meshtastic bridge | 🟡 Pending |
| **Home Assistant** | 8154 | `chrislawrence.ca/homeassistant` | IoT Hub | 🟢 Running |
| **Node-RED** | 8155 | `chrislawrence.ca/nodered` | IoT automation | 🟡 Pending |
| **Grafana IoT** | 8156 | `chrislawrence.ca/grafana-iot` | IoT metrics dashboard | 🟡 Pending |
| **InfluxDB** | 8157 | `chrislawrence.ca/influxdb` | Time series database | 🟡 Pending |

## 🔄 Organizr Proxy Ports

| Service | Direct Port | Proxy Port | Public URL | Purpose | Status |
|---------|-------------|------------|------------|---------|--------|
| **Uptime Kuma** | 3001 | 8083 | `chrislawrence.ca/uptime` | Service Monitoring | ✅ Working |
| **Portainer** | 9000 | 8084 | `chrislawrence.ca/docker` | Container Management | ✅ Working |
| **Grafana** | 3000 | 8085 | `chrislawrence.ca/metrics` | Metrics Dashboard | 🟡 Pending |
| **Prometheus** | 9090 | 8086 | `chrislawrence.ca/prometheus` | Metrics Collection | 🟡 Pending |
| **cAdvisor** | 8080 | 8087 | `chrislawrence.ca/containers` | Container Metrics | 🟡 Pending |
| **Glances** | 61208 | 8088 | `chrislawrence.ca/system` | System Monitoring | 🟡 Pending |
| **IT-Tools** | 8081 | 8089 | `chrislawrence.ca/tools` | Network Utilities | 🟡 Pending |
| **MQTT Explorer** | 8152 | 8093 | `chrislawrence.ca/mqtt` | MQTT Web Client | 🟡 Pending |
| **Home Assistant** | 8154 | 8094 | `chrislawrence.ca/homeassistant` | IoT Hub | 🟢 Running |
| **Node-RED** | 8155 | 8095 | `chrislawrence.ca/nodered` | IoT Automation | 🟡 Pending |
| **Grafana IoT** | 8156 | 8096 | `chrislawrence.ca/grafana-iot` | IoT Metrics Dashboard | 🟡 Pending |

### 📋 Port Range Organization

```
8100-8109: Magic Pages ecosystem
8110-8119: Portfolio & personal projects  
8120-8129: CapitolScope & political tools
8130-8139: SchedShare & scheduling tools
8140-8149: EventSphere, n8n and automation
8150-8159: IoT & Communication (MQTT, Meshtastic, Node-RED)
```

## 🔒 Security Zones

### **Public Access (via Cloudflare Tunnel)**
- All web applications
- Monitoring dashboards (Grafana, Uptime Kuma, Prometheus)
- API endpoints
- Portainer (Docker management)

### **LAN Only Access**
- Glances (system monitoring)
- cAdvisor (container metrics)
- Node Exporter (host metrics)
- IT-Tools (IT utilities)

### **No External Access**
- Database ports (Postgres, Redis)
- Internal service communication

## 🌍 Domain Mapping

| Domain | Service | Internal Target | Port |
|--------|---------|----------------|------|
| `hephaestus.chrislawrence.ca` | Admin Panel | Portainer | 9000 |
| `uptime.chrislawrence.ca` | Monitoring | Uptime Kuma | 3001 |
| `grafana.chrislawrence.ca` | Metrics | Grafana | 3000 |
| `api.magicpages.chrislawrence.ca` | API | Magic Pages API | 8000 |
| `magicpages.chrislawrence.ca` | Frontend | Magic Pages Frontend | 80 |
| `portfolio.chrislawrence.ca` | Portfolio | Portfolio App | 8010 |
| `capitolscope.chrislawrence.ca` | CapitolScope | CapitolScope App | 8020 |
| `schedshare.chrislawrence.ca` | SchedShare | SchedShare App | 8030 |
| `dashboard.chrislawrence.ca` | Dashboard | Organizr | 8082 |

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
curl -I https://uptime.chrislawrence.ca
curl -I https://grafana.chrislawrence.ca

# Test application endpoints (when deployed)
curl -I https://portfolio.chrislawrence.ca
curl -I https://api.magicpages.chrislawrence.ca/health
curl -I https://capitolscope.chrislawrence.ca
curl -I https://schedshare.chrislawrence.ca
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
- **9000**: Portainer
- **3001**: Uptime Kuma
- **3000**: Grafana
- **9090**: Prometheus

### **Application Ports**
- **8000**: Magic Pages API
- **80**: Magic Pages Frontend
- **8010**: Portfolio
- **8020**: CapitolScope
- **8030**: SchedShare

### **Monitoring Ports**
- **9090**: Prometheus
- **61208**: Glances
- **8080**: cAdvisor
- **9100**: Node Exporter
- **8081**: IT-Tools

---

## 🔧 Cloudflare Tunnel Configuration

### **Tunnel Details**
- **Tunnel ID**: `7bbb8d12-6cf4-4556-8c5f-006fb7bab126`
- **Tunnel Name**: `hephaestus-homelab`
- **Config File**: `~/.cloudflared/config.yml`
- **Credentials**: `~/.cloudflared/7bbb8d12-6cf4-4556-8c5f-006fb7bab126.json`

### **Tunnel Management**
```bash
# Start tunnel manually (for testing)
cloudflared tunnel run hephaestus-homelab

# Install as system service
sudo cloudflared service install
sudo systemctl enable cloudflared
sudo systemctl start cloudflared

# Check tunnel status
sudo systemctl status cloudflared
```

---

*Last Updated: October 12, 2025*
*Status: 🟢 Cloudflare Tunnel Active*
