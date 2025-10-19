# Hephaestus Homelab - DNS & Cloudflare Configuration

## Overview

This document outlines the DNS and Cloudflare tunnel configuration for the Hephaestus Homelab, providing secure public access to services through subpath routing.

## Current Configuration

### Tunnel Details
- **Tunnel ID**: `3a9f1023-0d6c-49ff-900d-32403e4309f8`
- **Tunnel Name**: `hephaestus-tunnel`
- **Main Domain**: `chrislawrence.ca`
- **Strategy**: Subpath routing through main domain

### Current DNS Records (as of 2025-01-17)
Based on Cloudflare DNS management interface:

#### CNAME Records (11 records)
- `api.capitol...` → `ghs.googlehos...` (Proxied, Auto TTL) ⚠️ Warning
- `autodiscover` → `autodiscover.o...` (Proxied, Auto TTL)
- `capitolscope` → `ghs.googlehos...` (Proxied, Auto TTL)
- `chrislawre...` → `3a9f1023-0d6...` (Proxied, Auto TTL) ✅ Main domain
- `_domainco...` → `_domainconne...` (Proxied, Auto TTL)
- `email` → `email.secures...` (Proxied, Auto TTL)
- `list` → `3a9f1023-0d6...` (Proxied, Auto TTL)
- `lyncdiscover` → `webdir.online.l...` (Proxied, Auto TTL)
- `msoid` → `clientconfig.mi...` (Proxied, Auto TTL)
- `sip` → `sipdir.online.ly...` (Proxied, Auto TTL)
- `www` → `chrislawrence....` (Proxied, Auto TTL) ⚠️ **NEEDS FIXING**

#### MX Records (3 records) - Email routing
- `route3.mx....` (Priority 38, DNS only)
- `route2.mx....` (Priority 36, DNS only)  
- `route1.mx.c...` (Priority 45, DNS only)

#### NS Records (2 records) - Nameservers
- `ns78.domainc...` (DNS only)
- `ns77.domainc...` (DNS only)

#### SRV Records (2 records)
- `_sipfederat...` (DNS only)
- `_sip._tls` (DNS only) ⚠️ Warning

#### TXT Records (7 records) - Email authentication & verification
- `cf2024-1._...` (DKIM record, DNS only)
- `chrislawre...` (SPF record, DNS only)
- `chrislawre...` (Google site verification, DNS only)
- `chrislawre...` (Domain verification, DNS only)
- `chrislawre...` (Google site verification, DNS only)
- `_dmarc` (DMARC policy, DNS only)
- `schedshare` (Google site verification, 1 hr TTL)

### DNS Records

#### Core Infrastructure (Required)
```
Type: CNAME
Name: chrislawrence.ca
Content: 3a9f1023-0d6c-49ff-900d-32403e4309f8.cfargotunnel.com
Proxy: ✅ Proxied (Orange Cloud)
TTL: Auto
```

#### WWW Subdomain (Required)
```
Type: CNAME
Name: www
Content: 3a9f1023-0d6c-49ff-900d-32403e4309f8.cfargotunnel.com
Proxy: ✅ Proxied (Orange Cloud)
TTL: Auto
```

#### Individual Service Subdomains (Optional)
```
hephaestus.chrislawrence.ca
portainer.hephaestus.chrislawrence.ca
grafana.hephaestus.chrislawrence.ca
uptime.hephaestus.chrislawrence.ca
prometheus.hephaestus.chrislawrence.ca
cadvisor.hephaestus.chrislawrence.ca
glances.hephaestus.chrislawrence.ca
dashboard.hephaestus.chrislawrence.ca
organizr.hephaestus.chrislawrence.ca
```

#### Public Application Domains (Future)
```
portfolio.chrislawrence.ca
capitolscope.chrislawrence.ca
schedshare.chrislawrence.ca
api.magicpages.chrislawrence.ca
magicpages.chrislawrence.ca
```

## Cloudflare Tunnel Configuration

### Local Config File: `~/.cloudflared/config.yml`

```yaml
tunnel: 3a9f1023-0d6c-49ff-900d-32403e4309f8
token: eyJhIjoiOWU2MjZkY2FmZmIxZDE0YmNmZDc0YzM3NGQ5MDRjZmUiLCJzIjoiTnpaak9UZGpPR1V0TldJMU1pMDBZamt6TFRnNE5ERXROMlZrTkROalpUaGlaakUxIiwidCI6IjNhOWYxMDIzLTBkNmMtNDlmZi05MDBkLTMyNDAzZTQzMDlmOCJ9

ingress:
  # Main domain with subpath routing
  - hostname: chrislawrence.ca
    service: http://localhost:80

  # Individual service subdomains (for direct access)
  - hostname: hephaestus.chrislawrence.ca
    service: http://localhost:80
  - hostname: portainer.hephaestus.chrislawrence.ca
    service: http://localhost:80
  - hostname: grafana.hephaestus.chrislawrence.ca
    service: http://localhost:80
  - hostname: uptime.hephaestus.chrislawrence.ca
    service: http://localhost:80
  - hostname: prometheus.hephaestus.chrislawrence.ca
    service: http://localhost:80
  - hostname: cadvisor.hephaestus.chrislawrence.ca
    service: http://localhost:80
  - hostname: glances.hephaestus.chrislawrence.ca
    service: http://localhost:80
  - hostname: dashboard.hephaestus.chrislawrence.ca
    service: http://localhost:80
  - hostname: organizr.hephaestus.chrislawrence.ca
    service: http://localhost:80

  # Public application domains (when ready)
  - hostname: portfolio.chrislawrence.ca
    service: http://localhost:80
  - hostname: capitolscope.chrislawrence.ca
    service: http://localhost:80
  - hostname: schedshare.chrislawrence.ca
    service: http://localhost:80
  - hostname: api.magicpages.chrislawrence.ca
    service: http://localhost:80
  - hostname: magicpages.chrislawrence.ca
    service: http://localhost:80

  # Catch-all for 404s
  - service: http_status:404
```

## Public Access URLs

### Infrastructure Services (Protected)
- `https://chrislawrence.ca/dashboard` → Organizr (Main entry point)
- `https://chrislawrence.ca/uptime` → Uptime Kuma
- `https://chrislawrence.ca/docker` → Portainer
- `https://chrislawrence.ca/metrics` → Grafana
- `https://chrislawrence.ca/prometheus` → Prometheus
- `https://chrislawrence.ca/containers` → cAdvisor
- `https://chrislawrence.ca/system` → Glances
- `https://chrislawrence.ca/tools` → IT-Tools

### Public Services (Future)
- `https://chrislawrence.ca/portfolio` → Portfolio App
- `https://chrislawrence.ca/capitolscope` → CapitolScope
- `https://chrislawrence.ca/schedshare` → SchedShare
- `https://chrislawrence.ca/magicpages` → Magic Pages Frontend
- `https://chrislawrence.ca/magicpages-api` → Magic Pages API

## Service Management

### Tunnel Commands
```bash
# Check tunnel status
sudo systemctl status cloudflared

# Restart tunnel
sudo systemctl restart cloudflared

# View tunnel logs
sudo journalctl -u cloudflared -f

# Test tunnel connectivity
cloudflared tunnel info 3a9f1023-0d6c-49ff-900d-32403e4309f8
```

### DNS Management
```bash
# Test DNS resolution
dig chrislawrence.ca
nslookup chrislawrence.ca

# Test public access
curl -I https://chrislawrence.ca
curl -I https://chrislawrence.ca/dashboard
```

## DNS Records to Remove

### Old Records (Remove These)
```
❌ hephaestus (A record → 100.64.0.1)
❌ nasty (A record → 24.69.104.19)
❌ www.nasty (A record → 24.69.104.19)
❌ schedshare (A record → 34.11.192.218)
❌ www.schedshare (A record → 34.11.192.218)
```

### Keep These Records
```
✅ chrislawrence.ca (A record - main domain)
✅ www (CNAME to chrislawrence.ca)
✅ All MX records (email)
✅ All TXT records (SPF, DKIM, DMARC, verification)
✅ All NS records (nameservers)
✅ All SRV records (if needed for services)
```

## Implementation Phases

### Phase 1: Core Setup
1. Add main CNAME for `chrislawrence.ca`
2. Remove old A records pointing to IPs
3. Update tunnel config with main domain

### Phase 2: Infrastructure Services
1. Add individual service subdomains
2. Update tunnel config with service routes
3. Test all infrastructure services

### Phase 3: Public Applications
1. Add public application subdomains
2. Deploy applications
3. Test public access

## Troubleshooting

### Common Issues

#### "This site can't be reached"
- Check DNS propagation: https://dnschecker.org/
- Verify tunnel is running: `sudo systemctl status cloudflared`
- Check tunnel logs: `sudo journalctl -u cloudflared -f`

#### "502 Bad Gateway"
- Caddy might be down: `docker compose ps caddy`
- Check Caddy logs: `docker compose logs caddy`
- Verify port 80 is accessible: `curl -I http://localhost:80`

#### Authentication Issues
- Verify basic auth credentials in Caddyfile
- Check if Cloudflare Access is blocking requests
- Test local access first: `curl -I http://192.168.50.70:80/dashboard -u admin:admin123`

### Verification Checklist
- [ ] DNS record points to tunnel
- [ ] Tunnel is running and healthy
- [ ] Caddy is running with correct configuration
- [ ] Local subpath routing works
- [ ] Public access works through tunnel
- [ ] Authentication is working
- [ ] All services are accessible via subpaths

## Related Documentation

- [Network Architecture](./networks.md) - Docker network setup
- [Security Configuration](./security.md) - Authentication and access control
- [Deployment Guide](./deployment.md) - Service deployment procedures

---

**Last Updated**: $(date)
**Tunnel Version**: 1.0
**Compatible With**: Cloudflare Tunnel v2023.x, Docker Compose v2.0+
