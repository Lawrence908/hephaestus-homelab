# Hephaestus Setup Checklist

Step-by-step checklist for setting up Hephaestus homelab.

## ✅ **Phase 1: System Setup**

### **System Configuration**
- [ ] Update system packages (`sudo apt update && sudo apt upgrade -y`)
- [ ] Install essential packages (curl, wget, git, vim, htop, net-tools)
- [ ] Set hostname to `hephaestus`
- [ ] Configure timezone
- [ ] Set up SSH keys (if not already done)

### **Docker Installation**
- [ ] Remove old Docker versions
- [ ] Add Docker GPG key
- [ ] Add Docker repository
- [ ] Install Docker Engine 27.x
- [ ] Install docker-compose plugin
- [ ] Add user to docker group
- [ ] Test Docker installation (`docker run hello-world`)

## ✅ **Phase 2: Repository Setup**

### **Directory Structure**
- [ ] Create `~/github` directory
- [ ] Create `~/apps` directory
- [ ] Clone `hephaestus-homelab` repository
- [ ] Clone application repositories:
  - [ ] `magic-pages-api`
  - [ ] `capitolscope`
  - [ ] `schedshare`
  - [ ] `chrislawrence-portfolio`
  - [ ] `magic-pages-frontend`

### **Environment Configuration**
- [ ] Copy `.env.example` to `.env`
- [ ] Configure domain (`chrislawrence.ca`)
- [ ] Generate secret keys
- [ ] Set application paths
- [ ] Configure database passwords

## ✅ **Phase 3: Docker Network Setup**

### **Network Configuration**
- [ ] Create Docker network (`docker network create web`)
- [ ] Verify network creation
- [ ] Test network connectivity

### **Infrastructure Services**
- [ ] Start Caddy (reverse proxy)
- [ ] Start Portainer (Docker management)
- [ ] Start Watchtower (auto-updates)
- [ ] Verify infrastructure services are running

## ✅ **Phase 4: Monitoring Stack**

### **Monitoring Services**
- [ ] Start Prometheus (metrics collection)
- [ ] Start Grafana (metrics visualization)
- [ ] Start Uptime Kuma (uptime monitoring)
- [ ] Start cAdvisor (container metrics)
- [ ] Start Node Exporter (host metrics)
- [ ] Start Glances (system monitoring)

### **Monitoring Configuration**
- [ ] Configure Grafana data sources
- [ ] Import Hephaestus dashboard
- [ ] Set up Uptime Kuma monitors
- [ ] Configure alerting

## ✅ **Phase 5: Application Deployment**

### **Application Services**
- [ ] Start Magic Pages API
- [ ] Start CapitolScope
- [ ] Start SchedShare
- [ ] Start Portfolio
- [ ] Start Magic Pages Frontend

### **Database Setup**
- [ ] Initialize Magic Pages API database
- [ ] Run migrations
- [ ] Create superuser account
- [ ] Initialize CapitolScope database
- [ ] Run Alembic migrations

## ✅ **Phase 6: Cloudflare Tunnel**

### **Tunnel Configuration**
- [ ] Create tunnel in Cloudflare Dashboard
- [ ] Get tunnel token
- [ ] Add tunnel token to `.env`
- [ ] Start cloudflared container
- [ ] Verify tunnel connection

### **Public Hostnames**
- [ ] Add `hephaestus.chrislawrence.ca` → Portainer
- [ ] Add `portfolio.chrislawrence.ca` → Portfolio
- [ ] Add `api.chrislawrence.ca` → Magic Pages API
- [ ] Add `capitolscope.chrislawrence.ca` → CapitolScope
- [ ] Add `schedshare.chrislawrence.ca` → SchedShare
- [ ] Add `magicpages.chrislawrence.ca` → Frontend
- [ ] Add `uptime.chrislawrence.ca` → Uptime Kuma
- [ ] Add `grafana.chrislawrence.ca` → Grafana

## ✅ **Phase 7: Security Configuration**

### **Firewall Setup**
- [ ] Enable UFW firewall
- [ ] Configure default policies
- [ ] Allow SSH access
- [ ] Configure Docker network rules
- [ ] Test firewall configuration

### **SSH Hardening**
- [ ] Disable password authentication
- [ ] Configure SSH keys
- [ ] Set up Fail2Ban
- [ ] Configure SSH client

## ✅ **Phase 8: Testing & Verification**

### **Internal Testing**
- [ ] Test all services locally
- [ ] Verify port accessibility
- [ ] Check Docker network connectivity
- [ ] Test application functionality

### **External Testing**
- [ ] Test Cloudflare Tunnel connectivity
- [ ] Verify SSL certificates
- [ ] Test public domain access
- [ ] Check monitoring dashboards

### **Performance Testing**
- [ ] Check resource usage
- [ ] Monitor container health
- [ ] Test application performance
- [ ] Verify backup functionality

## ✅ **Phase 9: Documentation & Maintenance**

### **Documentation**
- [ ] Update setup documentation
- [ ] Document custom configurations
- [ ] Create troubleshooting guide
- [ ] Set up monitoring alerts

### **Maintenance Setup**
- [ ] Configure automatic updates
- [ ] Set up backup scripts
- [ ] Configure log rotation
- [ ] Set up monitoring alerts

## 🚨 **Troubleshooting Checklist**

### **Common Issues**
- [ ] Port conflicts resolved
- [ ] Docker permissions fixed
- [ ] Network connectivity verified
- [ ] Service dependencies met
- [ ] Resource limits adequate

### **Health Checks**
- [ ] All containers running
- [ ] Services responding
- [ ] Network connectivity
- [ ] External access working
- [ ] Monitoring data flowing

---

## 📊 **Current Status**

**Overall Progress**: 🟡 In Progress  
**Last Updated**: $(date)  
**Next Steps**: Complete system setup and Docker installation

---

## 🎯 **Quick Commands Reference**

```bash
# Check status
docker compose ps
docker compose logs -f

# Start services
docker compose up -d

# Stop services
docker compose down

# Restart specific service
docker compose restart SERVICE_NAME

# Check network
docker network inspect web

# Check ports
sudo lsof -i :80
sudo lsof -i :443
```

---

*This checklist should be updated as you progress through the setup process.*
