# Hephaestus Homelab - Security Configuration

## Overview

This document outlines the security configuration for the Hephaestus Homelab, including Cloudflare Access, authentication layers, and security policies.

## Security Strategy

### Public Services → Cloudflare Turnstile CAPTCHA
- Portfolio, SchedShare, CapitolScope, etc.
- Protects against bots while allowing legitimate users

### Admin/Internal Services → Cloudflare Access
- Dashboard, Docker, Metrics, Uptime, etc.
- Requires email-based authentication or SSO

## Authentication Layers

### 1. Cloudflare Access (Primary)
- **Purpose**: Primary protection for admin services
- **Scope**: `/dashboard/*`, `/docker/*`, `/uptime/*`, etc.
- **Method**: Email-based authentication

### 2. Caddy Basic Auth (Secondary)
- **Purpose**: Secondary authentication layer
- **Credentials**: `admin:admin123` (configurable)
- **Scope**: All protected services

### 3. Service-level Auth (Tertiary)
- **Purpose**: Individual service authentication
- **Examples**: Grafana, Prometheus, Portainer

## Cloudflare Access Configuration

### Protected Applications

| Service | Path | Description | Access Policy |
|---------|------|-------------|---------------|
| **Dashboard** | `/dashboard/*` | Organizr dashboard | Admin Only |
| **Docker** | `/docker/*` | Portainer | Admin Only |
| **Uptime** | `/uptime/*` | Uptime Kuma | Admin Only |
| **Metrics** | `/metrics/*` | Grafana | Admin Only |
| **Prometheus** | `/prometheus/*` | Prometheus | Admin Only |
| **Containers** | `/containers/*` | cAdvisor | Admin Only |
| **System** | `/system/*` | Glances | Admin Only |
| **Tools** | `/tools/*` | IT-Tools | Admin Only |
| **n8n** | `/n8n/*` | n8n automation | Admin Only |
| **Notes** | `/notes/*` | Obsidian | Admin Only |
| **MQTT** | `/mqtt/*` | MQTT Explorer | Admin Only |
| **Meshtastic** | `/meshtastic/*` | Meshtastic Web | Admin Only |
| **Node-RED** | `/nodered/*` | Node-RED | Admin Only |
| **Grafana IoT** | `/grafana-iot/*` | Grafana IoT | Admin Only |
| **InfluxDB** | `/influxdb/*` | InfluxDB | Admin Only |

### Access Policy Configuration
```yaml
Policy Name: Admin Access
Action: Allow
Rules:
  - Email: your-email@example.com
  - Email domain: @yourdomain.com (optional)
Session Duration: 24 hours
```

## Cloudflare Turnstile CAPTCHA

### Configuration
- **Site Name**: `chrislawrence.ca`
- **Domain**: `chrislawrence.ca`
- **Widget Mode**: `Managed`
- **Pre-clearance**: `Enabled` (optional)

### Protected Public Services
- `portfolio.chrislawrence.ca` - Portfolio app
- `schedshare.chrislawrence.ca` - SchedShare app
- `capitolscope.chrislawrence.ca` - CapitolScope app
- `magicpages.chrislawrence.ca` - Magic Pages frontend

## WAF Rules Configuration

### OWASP Core Ruleset
- **Status**: Enabled
- **Sensitivity**: Medium
- **Scope**: All traffic

### Custom Security Rules

#### Block Admin Paths
```
(http.request.uri.path contains "/admin" and not cf.access.identity.email eq "your-email@example.com")
```

#### Rate Limiting
```
(http.request.uri.path contains "/api" and cf.threat_score gt 10)
```

#### Bot Protection
```
(cf.bot_management.score lt 30 and http.host eq "portfolio.chrislawrence.ca")
```

#### Turnstile Protection
```
(http.host eq "portfolio.chrislawrence.ca" or http.host eq "schedshare.chrislawrence.ca" or http.host eq "capitolscope.chrislawrence.ca")
Action: Managed Challenge
```

## SSL/TLS Configuration

### Cloudflare SSL Settings
- **Encryption Mode**: Full (strict)
- **Always Use HTTPS**: Enabled
- **Automatic HTTPS Rewrites**: Enabled
- **Minimum TLS Version**: 1.2

### Certificate Management
- **SSL/TLS**: Full (strict) mode
- **Edge Certificates**: Universal SSL
- **Origin Certificates**: Not required (tunnel handles encryption)

## DDoS Protection

### HTTP DDoS Attack Protection
- **Status**: Enabled
- **Sensitivity**: High
- **Scope**: All traffic

### Network-layer DDoS Attack Protection
- **Status**: Enabled
- **Scope**: All traffic

## Header Security

### Caddy Security Headers
- **X-Frame-Options**: Removed on 808X proxy ports for iframe embedding
- **Content-Security-Policy**: Set to `frame-ancestors *` on proxy ports
- **HSTS**: Enabled on public domain
- **X-Content-Type-Options**: Set to `nosniff`

### Cloudflare Security Headers
- **Security Level**: Medium
- **Browser Integrity Check**: Enabled
- **Challenge Passage**: 30 minutes

## Monitoring & Alerts

### Cloudflare Analytics
Monitor via Cloudflare Dashboard → Analytics → Security:
- Blocked requests
- Bot score distribution
- Geographic distribution
- Top attack vectors

### Access Logs
Monitor via Zero Trust → Logs → Access:
- Successful logins
- Failed authentication attempts
- Geographic access patterns

### WAF Logs
Monitor via Security → Events:
- Blocked requests
- Challenge completions
- Rate limit triggers

## Security Alerts

### Notification Destinations
Configure alerts for:
- High threat score requests
- Multiple failed access attempts
- DDoS attack detection
- WAF rule triggers

## Testing Security Configuration

### Test Public Services (No Auth Required)
```bash
# Should work without authentication
curl -I https://portfolio.chrislawrence.ca/
curl -I https://schedshare.chrislawrence.ca/
curl -I https://capitolscope.chrislawrence.ca/
```

### Test Protected Services (Auth Required)
```bash
# Should redirect to Cloudflare Access login
curl -I https://dev.chrislawrence.ca/dashboard/
curl -I https://dev.chrislawrence.ca/docker/
curl -I https://dev.chrislawrence.ca/uptime/
```

### Test CAPTCHA Protection
1. Visit `https://portfolio.chrislawrence.ca/` in browser
2. Should see Turnstile CAPTCHA if configured
3. Complete CAPTCHA to access

## Maintenance Tasks

### Regular Tasks
- [ ] Review access logs weekly
- [ ] Update email allowlists monthly
- [ ] Rotate API keys quarterly
- [ ] Review WAF rules quarterly
- [ ] Test backup access methods

### Security Audits
- [ ] Test all protected endpoints
- [ ] Verify CAPTCHA is working
- [ ] Check for unauthorized access attempts
- [ ] Review geographic access patterns
- [ ] Validate SSL/TLS configuration

## Benefits of This Approach

### Better User Experience
- ✅ Professional login flows
- ✅ No browser auth popups
- ✅ Mobile-friendly authentication
- ✅ SSO integration ready

### Enhanced Security
- ✅ Cloudflare's global infrastructure
- ✅ Advanced bot detection
- ✅ Geographic filtering
- ✅ Real-time threat intelligence

### Easier Management
- ✅ Centralized access control
- ✅ Detailed audit logs
- ✅ Easy user management
- ✅ Integration with existing tools

## Related Documentation

- [DNS & Cloudflare Configuration](./dns-cloudflare.md) - Tunnel and DNS setup
- [Network Architecture](./networks.md) - Docker network security
- [Deployment Guide](./deployment.md) - Security deployment procedures

---

**Last Updated**: $(date)
**Security Version**: 1.0
**Compatible With**: Cloudflare Zero Trust, Caddy v2.x



