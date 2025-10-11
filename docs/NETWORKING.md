# Networking Configuration

Complete networking guide for Hephaestus, including LAN setup, static IP, Cloudflare Tunnel, and domain routing.

## Table of Contents

1. [Network Overview](#network-overview)
2. [Static IP Configuration](#static-ip-configuration)
3. [Cloudflare Tunnel Setup](#cloudflare-tunnel-setup)
4. [DNS Configuration](#dns-configuration)
5. [Caddy Reverse Proxy](#caddy-reverse-proxy)
6. [Troubleshooting](#troubleshooting)

---

## Network Overview

### Network Topology

```
Internet
    ↓
Router (192.168.50.1)
    ↓
Hephaestus (192.168.50.70) ←→ LAN devices
    ↓
Docker Network: web (bridge)
    ↓
Containers (caddy, apps, monitoring)
```

### Port Mapping

| Service | Internal Port | External Port | Access |
|---------|--------------|---------------|---------|
| Caddy HTTP | 80 | 80 | LAN only |
| Caddy HTTPS | 443 | 443 | LAN only |
| Portainer | 9000 | 9000 | LAN only |
| Uptime Kuma | 3001 | 3001 | Via Caddy/Tunnel |
| Grafana | 3000 | 3000 | Via Caddy/Tunnel |
| Prometheus | 9090 | 9090 | Via Caddy/Tunnel |
| Glances | 61208 | 61208 | LAN only |
| cAdvisor | 8080 | 8080 | LAN only |

**Public Access**: All public traffic routes through **Cloudflare Tunnel** → **Caddy** → **Containers**

---

## Static IP Configuration

### Method 1: Netplan (Ubuntu Server)

Edit netplan configuration:

```bash
sudo nano /etc/netplan/01-netcfg.yaml
```

**Configuration**:

```yaml
network:
  version: 2
  ethernets:
    enp0s31f6:  # Use 'ip link show' to find your interface name
      dhcp4: no
      addresses:
        - 192.168.50.70/24
      routes:
        - to: default
          via: 192.168.50.1
      nameservers:
        addresses:
          - 1.1.1.1
          - 8.8.8.8
```

**Apply changes**:

```bash
sudo netplan apply
```

**Verify**:

```bash
ip addr show
ping google.com
```

### Method 2: Router DHCP Reservation

Alternative approach (if you prefer DHCP):

1. Log into your router (typically http://192.168.50.1)
2. Find **DHCP Reservations** or **Static Leases**
3. Add reservation:
   - **MAC Address**: Find with `ip link show` on Hephaestus
   - **IP Address**: 192.168.50.70
   - **Hostname**: hephaestus

This gives you the benefits of DHCP with a consistent IP.

---

## Cloudflare Tunnel Setup

### Why Cloudflare Tunnel?

- ✅ No port forwarding on your router
- ✅ Free SSL/TLS certificates
- ✅ DDoS protection
- ✅ Access your homelab from anywhere
- ✅ Hide your home IP address

### 1. Create Tunnel

1. Log into [Cloudflare Dashboard](https://dash.cloudflare.com)
2. Navigate to **Zero Trust** → **Networks** → **Tunnels**
3. Click **Create a tunnel**
4. Name it: `hephaestus-tunnel`
5. Choose **Docker** as the connector
6. Copy the **Tunnel Token** (looks like: `eyJhIjoi...`)

### 2. Configure Tunnel Token

Add to your `.env` file:

```bash
CLOUDFLARE_TUNNEL_TOKEN=eyJhIjoiYWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXoxMjM0NTY3ODkwIn0
```

### 3. Create Public Hostnames

In Cloudflare Tunnel settings, add public hostnames:

| Public Hostname | Service | URL |
|----------------|---------|-----|
| `uptime.yourdomain.com` | HTTP | `http://caddy:80` |
| `portainer.yourdomain.com` | HTTP | `http://caddy:80` |
| `grafana.yourdomain.com` | HTTP | `http://caddy:80` |
| `api.magicpages.yourdomain.com` | HTTP | `http://caddy:80` |
| `capitolscope.yourdomain.com` | HTTP | `http://caddy:80` |
| `schedshare.yourdomain.com` | HTTP | `http://caddy:80` |
| `portfolio.yourdomain.com` | HTTP | `http://caddy:80` |
| `magicpages.yourdomain.com` | HTTP | `http://caddy:80` |

**Important**: All public hostnames point to `http://caddy:80` because:
- Cloudflare Tunnel is on the same `web` network as Caddy
- Caddy handles internal routing based on hostname
- Cloudflare Tunnel → Caddy handles HTTPS

### 4. Start Cloudflared

```bash
docker compose up -d cloudflared
docker compose logs -f cloudflared
```

Look for: `Connection registered` or `Started Tunneling`

---

## DNS Configuration

### Add DNS Records (Cloudflare)

For each public hostname, ensure you have DNS records:

1. Go to **DNS** → **Records** in Cloudflare
2. The records should be **auto-created** when you set up tunnel hostnames
3. Verify they exist and are **Proxied** (orange cloud icon)

Example records:

```
Type: CNAME
Name: uptime
Content: <tunnel-id>.cfargotunnel.com
Proxy: Enabled (orange cloud)
```

### Local DNS (Optional)

For LAN access without going through Cloudflare, add to your main PC's hosts file:

**Linux/Mac**: `/etc/hosts`  
**Windows**: `C:\Windows\System32\drivers\etc\hosts`

```
192.168.50.70  hephaestus
192.168.50.70  portainer.local
192.168.50.70  uptime.local
192.168.50.70  grafana.local
```

---

## Caddy Reverse Proxy

### How Caddy Routes Traffic

1. **External Request**: `https://uptime.yourdomain.com`
2. **Cloudflare Tunnel** forwards to `http://caddy:80`
3. **Caddy** reads the `Host` header: `uptime.yourdomain.com`
4. **Caddy** matches Caddyfile route and forwards to `uptime-kuma:3001`
5. **Response** flows back through the chain

### Caddyfile Structure

Already configured in `/proxy/Caddyfile`. Key sections:

```caddy
uptime.{$DOMAIN} {
    reverse_proxy uptime-kuma:3001
}
```

The `{$DOMAIN}` is replaced with your `DOMAIN` env var from `.env`.

### Add New Routes

To add a new service:

1. Edit `proxy/Caddyfile`:

```caddy
myservice.{$DOMAIN} {
    reverse_proxy myservice:8000
    
    log {
        output file /data/logs/myservice.log {
            roll_size 10mb
            roll_keep 5
        }
    }
}
```

2. Add to Cloudflare Tunnel public hostnames
3. Reload Caddy:

```bash
docker compose restart caddy
```

---

## Network Troubleshooting

### Can't Access Services

**Check Docker Network**:

```bash
docker network inspect web
```

Verify all containers are on the `web` network.

**Check Container Connectivity**:

```bash
# From within Caddy container
docker exec -it caddy ping uptime-kuma
docker exec -it caddy wget -O- http://uptime-kuma:3001
```

**Check Caddy Logs**:

```bash
docker compose logs caddy
```

### Cloudflare Tunnel Issues

**Verify Tunnel Status**:

```bash
docker compose logs cloudflared
```

Look for errors or connection issues.

**Check Cloudflare Dashboard**:
- Go to **Zero Trust** → **Networks** → **Tunnels**
- Verify tunnel shows as **HEALTHY**

**Test Tunnel Connectivity**:

```bash
# From Hephaestus
curl -I http://caddy:80 -H "Host: uptime.yourdomain.com"
```

### DNS Not Resolving

**Clear DNS Cache** (on client machine):

```bash
# Linux
sudo systemd-resolve --flush-caches

# Mac
sudo dscacheutil -flushcache

# Windows (as admin)
ipconfig /flushdns
```

**Test DNS Resolution**:

```bash
nslookup uptime.yourdomain.com
dig uptime.yourdomain.com
```

### Port Conflicts

If ports 80/443 are already in use:

```bash
# Find what's using the port
sudo lsof -i :80
sudo lsof -i :443

# Stop the service or change Caddy ports in docker-compose.yml
```

---

## Advanced Configuration

### Split Tunnel (VPN Compatibility)

If using Tailscale or another VPN, you may want split-tunnel access:

1. Keep public services through Cloudflare Tunnel
2. Access internal services (Portainer, Prometheus) via VPN only
3. Remove Caddyfile routes for internal services
4. Access directly: `http://192.168.50.70:9000` (Portainer)

### Custom Domain per App

You can use different domains for different apps:

```caddy
magicpages.com {
    reverse_proxy magic-pages-frontend:80
}

api.example.net {
    reverse_proxy magic-pages-api:8000
}
```

Just ensure DNS records point to your tunnel.

### Rate Limiting

Add rate limiting to Caddyfile:

```caddy
api.magicpages.{$DOMAIN} {
    rate_limit {
        zone api_limit {
            key {remote_host}
            events 100
            window 1m
        }
    }
    
    reverse_proxy magic-pages-api:8000
}
```

---

## Security Checklist

- [ ] Static IP configured
- [ ] Cloudflare Tunnel active and healthy
- [ ] No port forwarding on router (80/443 closed)
- [ ] All public services behind Cloudflare proxy
- [ ] Internal services (Portainer, Prometheus) not publicly exposed
- [ ] Caddy logs being written
- [ ] DNS records properly configured
- [ ] SSL/TLS certificates valid (via Cloudflare)

---

## Quick Reference

### Restart Networking

```bash
# Restart Caddy
docker compose restart caddy

# Restart Cloudflared
docker compose restart cloudflared

# Restart host networking
sudo systemctl restart systemd-networkd
sudo netplan apply
```

### View Logs

```bash
# Caddy access logs
docker exec caddy cat /data/logs/uptime.log

# Cloudflared connection logs
docker compose logs cloudflared

# System networking logs
journalctl -u systemd-networkd -f
```

### Test Connectivity

```bash
# Test from Hephaestus to internet
ping 1.1.1.1
curl https://cloudflare.com

# Test internal Docker networking
docker exec caddy ping uptime-kuma

# Test public access (from external machine)
curl -I https://uptime.yourdomain.com
```

---

## Next Steps

1. ✅ Configure static IP
2. ✅ Set up Cloudflare Tunnel
3. ✅ Add DNS records
4. ✅ Configure Caddyfile routes
5. ✅ Test internal connectivity
6. ✅ Test public access
7. 📚 See [SECURITY.md](./SECURITY.md) for firewall configuration
8. 📚 See [MONITORING.md](./MONITORING.md) for uptime checks

