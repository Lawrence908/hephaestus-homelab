# 🏗️ Hephaestus Homelab Structure

## 📁 Directory Organization

### **Current Structure (Recommended)**
```
~/
├── github/
│   └── hephaestus-homelab/              # Infrastructure repository
│       ├── docker-compose-infrastructure.yml
│       ├── docs/
│       ├── data/
│       ├── proxy/
│       ├── scripts/
│       └── grafana-stack/
└── apps/                                # Applications (separate from Git)
    ├── obsidian/                        # Self-hosted Obsidian
    ├── MagicPages/                      # Your Django API
    ├── CapitolScope/                    # Political data app
    ├── chrislawrence-portfolio/         # Portfolio site
    ├── magicpages-frontend/             # Frontend app
    ├── CourseSchedule2Calendar/         # Course scheduler
    ├── daedalOS/                        # OS project
    ├── mongo-events-demo/               # EventSphere demo project
    ├── n8n/                             # n8n automation platform
    ├── minecraft/                       # Minecraft server files/config
    └── meshtastic-mqtt/                 # IoT & Communication services
```

## 🎯 **Why This Structure?**

### **Separation of Concerns**
- **`~/github/hephaestus-homelab/`**: Infrastructure, monitoring, networking
- **`~/apps/`**: Applications, services, and projects

### **Git Repository Management**
- **Infrastructure repo**: Tracks homelab configuration only
- **App directories**: Each can be its own Git repo without conflicts
- **No nested repos**: Avoids Git submodule complexity

### **Deployment Flexibility**
- Apps can reference infrastructure network: `external: true`
- Infrastructure services are centrally managed
- Applications can be deployed independently

## 🐳 **Docker Network Integration**

### **Infrastructure Services**
```yaml
# ~/github/hephaestus-homelab/docker-compose-infrastructure.yml
networks:
  web:
    driver: bridge
```

### **Application Services**
```yaml
# ~/apps/*/docker-compose.yml
networks:
  web:
    external: true  # References infrastructure network
```

## 📊 **Service Categories**

### **Infrastructure** (`~/github/hephaestus-homelab/`)
| Service | Purpose | Port | Status |
|---------|---------|------|--------|
| Caddy | Reverse Proxy | 80 | 🟢 |
| Portainer | Docker Management | 9000 | 🟢 |
| Grafana | Metrics Dashboard | 3000 | 🟢 |
| Prometheus | Metrics Collection | 9090 | 🟢 |
| Uptime Kuma | Uptime Monitoring | 3001 | 🟢 |
| Organizr | Central Dashboard | 8082 | 🟢 |

### **Applications** (`~/apps/`)
| Application | Purpose | Port | Location |
|-------------|---------|------|----------|
| Obsidian | Note-taking | 8060 | `/apps/obsidian/` |
| MagicPages API | Django Backend | 8000 | `/apps/MagicPages/` |
| MagicPages Frontend | React Frontend | 80 | `/apps/magicpages-frontend/` |
| CapitolScope | Political Data | 8020 | `/apps/CapitolScope/` |
| Portfolio | Personal Site | 8010 | `/apps/chrislawrence-portfolio/` |
| EventSphere (mongo-events-demo) | Event stream demo | 8040 | `/apps/mongo-events-demo/` |
| n8n | Automation/workflows | 5678 | `/apps/n8n/` |
| Minecraft Server | Game server (non-HTTP) | 25565 | `/apps/minecraft/` |
| MQTT Broker | Message broker | 8150 | `/apps/meshtastic-mqtt/` |
| Meshtastic | Mesh networking | 8154 | `/apps/meshtastic-mqtt/` |
| Node-RED | IoT automation | 8155 | `/apps/meshtastic-mqtt/` |

## 🔧 **Management Commands**

### **Infrastructure**
```bash
# Start all infrastructure services
cd ~/github/hephaestus-homelab
docker compose -f docker-compose-infrastructure.yml up -d

# Check infrastructure status
docker compose -f docker-compose-infrastructure.yml ps
```

### **Applications**
```bash
# Start individual applications
cd ~/apps/obsidian
docker compose up -d

cd ~/apps/MagicPages
docker compose up -d

# Or use a management script (future enhancement)
~/scripts/manage-apps.sh start obsidian
```

## 🌐 **Port Allocation Strategy**

### **Infrastructure Ports (Fixed)**
- `80`: Caddy HTTP
- `3000`: Grafana
- `3001`: Uptime Kuma
- `8080`: cAdvisor
- `8081`: IT-Tools
- `8082`: Organizr
- `9000`: Portainer
- `9090`: Prometheus
- `61208`: Glances

### **Application Port Ranges**
- `8000-8009`: MagicPages ecosystem
- `8010-8019`: Portfolio & personal projects
- `8020-8029`: CapitolScope & political tools
- `8030-8039`: SchedShare & scheduling tools
- `8040-8049`: EventSphere and future applications
- `8050-8059`: Development/testing
- `8060-8069`: Personal services (Obsidian, etc.)
- `8150-8159`: IoT & Communication (MQTT, Meshtastic, Node-RED)

## 🔄 **Deployment Workflow**

### **Infrastructure Changes**
1. Edit files in `~/github/hephaestus-homelab/`
2. Commit to Git repository
3. Deploy: `docker compose -f docker-compose-infrastructure.yml up -d`

### **Application Changes**
1. Edit files in `~/apps/[app-name]/`
2. Commit to individual app repository (if applicable)
3. Deploy: `cd ~/apps/[app-name] && docker compose up -d`

## 🚀 **Future Enhancements**

### **Centralized Management Script**
```bash
# ~/scripts/homelab.sh
./homelab.sh infrastructure start
./homelab.sh app start obsidian
./homelab.sh app stop magicpages
./homelab.sh status
```

### **CI/CD Integration**
- GitHub Actions for infrastructure deployment
- Watchtower for automatic container updates
- Health checks and rollback capabilities

## 📋 **Best Practices**

### **✅ Do**
- Keep infrastructure and applications separate
- Use external networks for cross-service communication
- Document port allocations
- Use consistent naming conventions
- Regular backups of configuration

### **❌ Don't**
- Mix Git repositories
- Hard-code IP addresses
- Use conflicting port numbers
- Store secrets in Git repositories
- Deploy without testing

## 🔒 **Security Considerations**

### **Network Isolation**
- Infrastructure services on `web` network
- Applications join network as needed
- No direct external access to internal services

### **Access Control**
- Reverse proxy handles external access
- Authentication at proxy level
- Internal services communicate securely

This structure provides a clean separation between infrastructure and applications while maintaining flexibility for growth and deployment! 🎉
