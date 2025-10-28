# Hephaestus Homelab - Setup & Installation

## Overview

Complete installation guide for setting up the Dell OptiPlex 7040 as a Docker-based homelab server.

## Hardware Specifications

### Dell OptiPlex 7040
- **CPU**: Intel Core i5/i7 (6th Gen)
- **RAM**: 32GB DDR4 (4x8GB sticks)
- **Storage**: 
  - OS: Existing SSD (~128GB)
  - Applications/Data: 2TB Lexar SSD
- **Network**: Gigabit Ethernet
- **Hostname**: Hephaestus
- **OS**: Ubuntu Server 24.04 LTS

## BIOS Configuration

1. **Enter BIOS**: Press `F2` during boot
2. **Configure Settings**:
   - Enable **Virtualization Technology (VT-x)**
   - Enable **VT-d** (for IOMMU/PCIe passthrough if needed)
   - Set **Boot Mode**: UEFI
   - Configure **Wake-on-LAN** (optional)
   - Disable **Secure Boot** (if using custom kernels)
3. **Power Management**:
   - Set **AC Recovery**: Power On (auto-restart after power loss)
   - Disable **Deep Sleep** if running 24/7
4. **Save & Exit**

## Ubuntu Server Installation

### Download Ubuntu Server 24.04 LTS

```bash
# From another machine, download the ISO
wget https://releases.ubuntu.com/24.04/ubuntu-24.04-live-server-amd64.iso

# Create bootable USB
dd if=ubuntu-24.04-live-server-amd64.iso of=/dev/sdX bs=4M status=progress
```

### Installation Steps

1. Boot from USB drive
2. Select **Install Ubuntu Server**
3. **Network Configuration**:
   - Configure static IP (see NETWORKING.md)
   - Example: `192.168.50.70/24`
4. **Storage Configuration**:
   - Use entire disk with LVM (recommended)
   - Or custom partitioning:
     - `/boot`: 1GB
     - `/`: 50GB+
     - `/home`: Remaining space
     - `swap`: 8GB (or equal to RAM if using hibernation)
5. **Profile Setup**:
   - Name: Your name
   - Server name: `hephaestus`
   - Username: `chris` (or your preferred username)
   - Password: Strong password
6. **SSH Setup**:
   - ✅ Install OpenSSH server
   - Import SSH keys (optional)
7. **Additional Packages**:
   - Skip for now (we'll install Docker manually)
8. **Complete Installation** and reboot

## Initial System Configuration

### 1. Update System

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git vim htop net-tools
```

### 2. Set Hostname

```bash
sudo hostnamectl set-hostname hephaestus
echo "127.0.0.1 hephaestus" | sudo tee -a /etc/hosts
```

### 3. Configure SSH (Optional)

```bash
# Copy your SSH key
ssh-copy-id chris@hephaestus

# Secure SSH
sudo vim /etc/ssh/sshd_config
# Set: PermitRootLogin no
# Set: PasswordAuthentication no (after SSH key is working)

sudo systemctl restart ssh
```

### 4. Set Timezone

```bash
sudo timedatectl set-timezone America/New_York
```

## Docker Installation

### Install Docker Engine 27.x

```bash
# Remove old versions
sudo apt remove docker docker-engine docker.io containerd runc

# Add Docker's official GPG key
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verify installation
docker --version
docker compose version
```

### Post-Installation Setup

```bash
# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Enable Docker to start on boot
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

# Test Docker
docker run hello-world
```

### Configure Docker Daemon (Optional)

```bash
sudo vim /etc/docker/daemon.json
```

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "metrics-addr": "0.0.0.0:9323",
  "experimental": false
}
```

```bash
sudo systemctl restart docker
```

## Repository Setup

### 1. Clone Hephaestus Repository

```bash
cd ~/github
git clone https://github.com/yourusername/hephaestus-homelab.git
cd hephaestus-homelab
```

### 2. Clone Application Repositories

```bash
mkdir -p ~/apps
cd ~/apps

# Clone your application repositories
git clone https://github.com/yourusername/magic-pages-api.git
git clone https://github.com/yourusername/capitolscope.git
git clone https://github.com/yourusername/schedshare.git
git clone https://github.com/yourusername/portfolio.git
git clone https://github.com/yourusername/magic-pages-frontend.git
```

### 3. Configure Environment Variables

```bash
cd ~/github/hephaestus-homelab
cp .env.example .env
vim .env
```

**Update the following**:
- `DOMAIN`: Your domain name
- `CLOUDFLARE_API_TOKEN`: From Cloudflare dashboard
- `CLOUDFLARE_TUNNEL_TOKEN`: From Cloudflare Tunnel setup
- All `*_SECRET_KEY` variables with random strings
- Database passwords
- Application paths (verify they match your setup)

**Generate secure secrets**:
```bash
# Django secret key
python3 -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'

# Generic random string
openssl rand -base64 32
```

### 4. Create Docker Network

```bash
docker network create homelab-web
```

## Application Deployment

### 1. Start Infrastructure Services First

```bash
cd ~/github/hephaestus-homelab

# Start proxy and monitoring stack
docker compose -f docker-compose-infrastructure.yml up -d caddy cloudflared portainer watchtower
docker compose -f docker-compose-infrastructure.yml up -d prometheus grafana cadvisor glances uptime-kuma

# Check status
docker compose -f docker-compose-infrastructure.yml ps
docker compose -f docker-compose-infrastructure.yml logs -f
```

### 2. Build and Start Applications

**Ensure each app has a Dockerfile**. Example:

**Django (Magic Pages API) Dockerfile**:
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
RUN python manage.py collectstatic --noinput
EXPOSE 8000
CMD ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000"]
```

**Build and start**:
```bash
docker compose up -d --build magic-pages-api capitolscope schedshare portfolio magic-pages-frontend
```

### 3. Initialize Databases

```bash
# Magic Pages API
docker compose exec magic-pages-api python manage.py migrate
docker compose exec magic-pages-api python manage.py createsuperuser

# CapitolScope
docker compose exec capitolscope alembic upgrade head

# SchedShare (if using migrations)
docker compose exec schedshare flask db upgrade
```

## Post-Installation

### 1. Verify All Services

```bash
docker compose ps
```

All services should show "Up" status.

### 2. Access Services

- **Portainer**: https://portainer.yourdomain.com
- **Uptime Kuma**: https://uptime.yourdomain.com
- **Grafana**: https://grafana.yourdomain.com
- **Applications**: Check your configured domains

### 3. Setup Monitoring

See [MONITORING.md](./monitoring.md) for:
- Configuring Uptime Kuma monitors
- Creating Grafana dashboards
- Setting up alerts

### 4. Configure Security

See [SECURITY.md](./security.md) for:
- UFW firewall rules
- Fail2Ban setup
- Tailscale VPN (optional)

### 5. Setup Backups

```bash
# Test backup script
cd ~/github/hephaestus-homelab
./scripts/backup.sh

# Setup cron job
crontab -e
# Add: 0 2 * * * /home/chris/github/hephaestus-homelab/scripts/backup.sh
```

## Troubleshooting

### Docker Permission Denied

```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Container Won't Start

```bash
# Check logs
docker compose logs <service-name>

# Check disk space
df -h

# Check memory
free -h
```

### Network Issues

```bash
# Recreate network
docker network rm homelab-web
docker network create homelab-web
docker compose up -d
```

### Port Already in Use

```bash
# Find process using port
sudo lsof -i :80
sudo lsof -i :443

# Kill process or change port in docker-compose.yml
```

## Setup Checklist

### Phase 1: System Setup
- [ ] Update system packages (`sudo apt update && sudo apt upgrade -y`)
- [ ] Install essential packages (curl, wget, git, vim, htop, net-tools)
- [ ] Set hostname to `hephaestus`
- [ ] Configure timezone
- [ ] Set up SSH keys (if not already done)

### Phase 2: Docker Installation
- [ ] Remove old Docker versions
- [ ] Add Docker GPG key
- [ ] Add Docker repository
- [ ] Install Docker Engine 27.x
- [ ] Install docker-compose plugin
- [ ] Add user to docker group
- [ ] Test Docker installation (`docker run hello-world`)

### Phase 3: Repository Setup
- [ ] Create `~/github` directory
- [ ] Create `~/apps` directory
- [ ] Clone `hephaestus-homelab` repository
- [ ] Clone application repositories
- [ ] Copy `.env.example` to `.env`
- [ ] Configure domain (`chrislawrence.ca`)
- [ ] Generate secret keys
- [ ] Set application paths
- [ ] Configure database passwords

### Phase 4: Docker Network Setup
- [ ] Create Docker network (`docker network create homelab-web`)
- [ ] Verify network creation
- [ ] Test network connectivity

### Phase 5: Infrastructure Services
- [ ] Start Caddy (reverse proxy)
- [ ] Start Portainer (Docker management)
- [ ] Start Watchtower (auto-updates)
- [ ] Verify infrastructure services are running

### Phase 6: Monitoring Stack
- [ ] Start Prometheus (metrics collection)
- [ ] Start Grafana (metrics visualization)
- [ ] Start Uptime Kuma (uptime monitoring)
- [ ] Start cAdvisor (container metrics)
- [ ] Start Node Exporter (host metrics)
- [ ] Start Glances (system monitoring)

### Phase 7: Application Deployment
- [ ] Start Magic Pages API
- [ ] Start CapitolScope
- [ ] Start SchedShare
- [ ] Start Portfolio
- [ ] Start Magic Pages Frontend

### Phase 8: Cloudflare Tunnel
- [ ] Create tunnel in Cloudflare Dashboard
- [ ] Get tunnel token
- [ ] Add tunnel token to `.env`
- [ ] Start cloudflared container
- [ ] Verify tunnel connection

### Phase 9: Security Configuration
- [ ] Enable UFW firewall
- [ ] Configure default policies
- [ ] Allow SSH access
- [ ] Configure Docker network rules
- [ ] Test firewall configuration

### Phase 10: Testing & Verification
- [ ] Test all services locally
- [ ] Verify port accessibility
- [ ] Check Docker network connectivity
- [ ] Test application functionality
- [ ] Test Cloudflare Tunnel connectivity
- [ ] Verify SSL certificates
- [ ] Test public domain access
- [ ] Check monitoring dashboards

## Next Steps

1. ✅ Complete [NETWORKING.md](./networks.md) - Configure networking and Cloudflare
2. ✅ Complete [SECURITY.md](./security.md) - Harden server security
3. ✅ Complete [MONITORING.md](./monitoring.md) - Setup comprehensive monitoring
4. 📚 Document your applications' specific setup in their respective repositories

## Useful Commands

```bash
# View all containers
docker compose ps

# View logs
docker compose logs -f [service]

# Restart service
docker compose restart [service]

# Rebuild and restart
docker compose up -d --build [service]

# Stop all
docker compose down

# Stop and remove volumes (⚠️ DANGER)
docker compose down -v

# Update all containers
docker compose pull
docker compose up -d

# Clean up
docker system prune -a
```

## Related Documentation

- [Server Specifications](./server-specs.md) - Hardware and network details
- [Network Architecture](./networks.md) - Docker network setup
- [Security Configuration](./security.md) - Authentication and access control
- [Monitoring Setup](./monitoring.md) - Comprehensive monitoring
- [Deployment Guide](./deployment.md) - Service deployment procedures

---

**Last Updated**: $(date)
**Setup Version**: 1.0
**Compatible With**: Ubuntu Server 24.04 LTS, Docker Engine 27.x



