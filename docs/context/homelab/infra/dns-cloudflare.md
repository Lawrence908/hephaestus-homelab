# Hephaestus Homelab - DNS & Cloudflare Configuration

## Overview

This document outlines the DNS and Cloudflare tunnel configuration for the Hephaestus Homelab, providing secure public access to services through subpath routing.

## Current Configuration

### Tunnel Details
- **Tunnel ID**: `de5fbdaa-4497-4a7e-828f-7dba6d7b0c90`
- **Tunnel Name**: `hephaestus`
- **Main Domain**: `chrislawrence.ca`
- **Strategy**: Subdomain routing with Cloudflare Access protection

### Current DNS Records (as of 2025-01-27)
All DNS records are managed through Cloudflare Zero Trust Published Application Routes:

#### Published Application Routes (13 routes)
- `chrislawrence.ca` → `http://caddy:80` (Public)
- `www.chrislawrence.ca` → `http://caddy:80` (Public)
- `portfolio.chrislawrence.ca` → `http://caddy:80` (Public)
- `schedshare.chrislawrence.ca` → `http://caddy:80` (Public)
- `capitolscope.chrislawrence.ca` → `http://caddy:80` (Public)
- `magicpages.chrislawrence.ca` → `http://caddy:80` (Public)
- `api.magicpages.chrislawrence.ca` → `http://caddy:80` (Public)
- `eventsphere.chrislawrence.ca` → `http://caddy:80` (Public)
- `dev.chrislawrence.ca` → `http://caddy:80` (Protected - Cloudflare Access)
- `monitor.chrislawrence.ca` → `http://caddy:80` (Protected - Cloudflare Access)
- `iot.chrislawrence.ca` → `http://caddy:80` (Protected - Cloudflare Access)
- `minecraft.chrislawrence.ca` → `http://caddy:80` (Protected - Cloudflare Access)
- `ai.chrislawrence.ca` → `http://caddy:80` (Protected - Cloudflare Access)

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
tunnel: de5fbdaa-4497-4a7e-828f-7dba6d7b0c90
token: eyJhIjoiOWU2MjZkY2FmZmIxZDE0YmNmZDc0YzM3NGQ5MDRjZmUiLCJ0IjoiZGU1ZmJkYWEtNDQ5Ny00YTdlLTgyOGYtN2RiYTZkN2IwYzkwIiwicyI6Ik9HUmpZVEJrTm1JdFltUTVaQzAwTkRFM0xUa3laR1V0WW1VME5qSXlNV1V6TTJJdyJ9

ingress:
  # Main domain - Landing page
  - hostname: chrislawrence.ca
    service: http://caddy:80

  # www subdomain - redirect to main domain
  - hostname: www.chrislawrence.ca
    service: http://caddy:80

  # PUBLIC SUBDOMAINS (No Authentication Required)
  # Portfolio subdomain
  - hostname: portfolio.chrislawrence.ca
    service: http://caddy:80

  # SchedShare subdomain
  - hostname: schedshare.chrislawrence.ca
    service: http://caddy:80

  # CapitolScope subdomain
  - hostname: capitolscope.chrislawrence.ca
    service: http://caddy:80

  # MagicPages subdomain
  - hostname: magicpages.chrislawrence.ca
    service: http://caddy:80

  # MagicPages API subdomain
  - hostname: api.magicpages.chrislawrence.ca
    service: http://caddy:80

  # EventSphere subdomain
  - hostname: eventsphere.chrislawrence.ca
    service: http://caddy:80

  # PROTECTED SUBDOMAINS (Cloudflare Access Required)
  # Dev environment subdomain
  - hostname: dev.chrislawrence.ca
    service: http://caddy:80

  # Monitor subdomain
  - hostname: monitor.chrislawrence.ca
    service: http://caddy:80

  # IoT subdomain
  - hostname: iot.chrislawrence.ca
    service: http://caddy:80

  # Minecraft subdomain
  - hostname: minecraft.chrislawrence.ca
    service: http://caddy:80

  # AI subdomain
  - hostname: ai.chrislawrence.ca
    service: http://caddy:80

  # Catch-all for 404s
  - service: http_status:404
```

## Public Access URLs

### Public Services (No Authentication Required)
- `https://chrislawrence.ca` → Landing page
- `https://portfolio.chrislawrence.ca` → Portfolio website
- `https://schedshare.chrislawrence.ca` → Schedule sharing application
- `https://capitolscope.chrislawrence.ca` → Political data platform
- `https://magicpages.chrislawrence.ca` → Content management system
- `https://api.magicpages.chrislawrence.ca` → MagicPages API
- `https://eventsphere.chrislawrence.ca` → Event management system

### Protected Services (Cloudflare Access Required)
- `https://dev.chrislawrence.ca` → Development environment
- `https://monitor.chrislawrence.ca` → Monitoring dashboard
- `https://iot.chrislawrence.ca` → IoT device management
- `https://minecraft.chrislawrence.ca` → Minecraft server
- `https://ai.chrislawrence.ca` → AI services

## Service Management

### Tunnel Commands
```bash
# Check tunnel status
docker compose -f proxy/docker-compose.yml ps cloudflared

# Restart tunnel
docker compose -f proxy/docker-compose.yml restart cloudflared

# View tunnel logs
docker compose -f proxy/docker-compose.yml logs cloudflared

# Test tunnel connectivity
cloudflared tunnel info de5fbdaa-4497-4a7e-828f-7dba6d7b0c90
```

### DNS Management
```bash
# Test DNS resolution
dig chrislawrence.ca
nslookup chrislawrence.ca

# Test public access
curl -I https://chrislawrence.ca
curl -I https://portfolio.chrislawrence.ca
curl -I https://schedshare.chrislawrence.ca
curl -I https://capitolscope.chrislawrence.ca
curl -I https://magicpages.chrislawrence.ca
curl -I https://eventsphere.chrislawrence.ca

# Test protected access (should redirect to Cloudflare Access)
curl -I https://dev.chrislawrence.ca
curl -I https://monitor.chrislawrence.ca
curl -I https://iot.chrislawrence.ca
curl -I https://minecraft.chrislawrence.ca
curl -I https://ai.chrislawrence.ca
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
