# Organizr Central Dashboard Setup Guide

Complete setup guide for Organizr as your central homelab dashboard.

## 🎯 Overview

Organizr provides a unified dashboard where you can access all your homelab services through a single interface with tabs, authentication, and beautiful theming.

## 📋 Features

- **Unified Interface**: Access all services through one dashboard
- **Tab Management**: Organize services into logical tabs
- **User Management**: Multi-user support with different access levels
- **Theming**: Beautiful, customizable themes
- **SSO Integration**: Single sign-on with supported services
- **Mobile Responsive**: Works great on mobile devices
- **Health Monitoring**: Built-in service health checks

## 🚀 Quick Start

### 1. Deploy Organizr

The service is already configured in your `docker-compose-infrastructure.yml`. To deploy:

```bash
cd ~/github/hephaestus-homelab
docker compose -f docker-compose-infrastructure.yml up -d organizr
```

### 2. Access Organizr

**Local Access (LAN):**
```
http://192.168.50.70:8082
```

**Public Access (via Cloudflare Tunnel):**
```
https://dashboard.hephaestus.chrislawrence.ca
https://organizr.hephaestus.chrislawrence.ca
```

**Authentication:**
- Username: `admin`
- Password: `admin123` (same as your Caddy basic auth)

### 3. Initial Setup Wizard

1. **Access Organizr** using one of the URLs above
2. **Complete Setup Wizard:**
   - Set admin username/password
   - Configure database (SQLite is fine for homelab)
   - Set timezone and basic settings
3. **Skip** advanced features for now (can configure later)

## 🔧 Configuration

### Adding Your Services

After initial setup, add your homelab services as tabs:

#### Core Infrastructure Services

**Portainer (Docker Management)**
- **Tab Name**: Portainer
- **Tab URL**: `https://hephaestus.chrislawrence.ca`
- **Category**: Admin
- **Icon**: `mdi mdi-docker`

**Uptime Kuma (Monitoring)**
- **Tab Name**: Uptime Kuma
- **Tab URL**: `https://uptime.hephaestus.chrislawrence.ca`
- **Category**: Monitoring
- **Icon**: `mdi mdi-heart-pulse`

**Grafana (Metrics)**
- **Tab Name**: Grafana
- **Tab URL**: `https://grafana.hephaestus.chrislawrence.ca`
- **Category**: Monitoring
- **Icon**: `mdi mdi-chart-line`

**Prometheus (Metrics Collection)**
- **Tab Name**: Prometheus
- **Tab URL**: `https://prometheus.hephaestus.chrislawrence.ca`
- **Category**: Monitoring
- **Icon**: `mdi mdi-database`

#### LAN-Only Services (Internal URLs)

**Glances (System Monitor)**
- **Tab Name**: Glances
- **Tab URL**: `http://192.168.50.70:61208`
- **Category**: Monitoring
- **Icon**: `mdi mdi-monitor-dashboard`

**cAdvisor (Container Metrics)**
- **Tab Name**: cAdvisor
- **Tab URL**: `http://192.168.50.70:8080`
- **Category**: Monitoring
- **Icon**: `mdi mdi-docker`

**IT-Tools (Utilities)**
- **Tab Name**: IT-Tools
- **Tab URL**: `http://192.168.50.70:8081`
- **Category**: Tools
- **Icon**: `mdi mdi-tools`

### Categories Setup

Organize your services into logical categories:

1. **Admin** - Portainer, system management
2. **Monitoring** - Uptime Kuma, Grafana, Prometheus, Glances, cAdvisor
3. **Applications** - Your web apps (Magic Pages, Portfolio, etc.)
4. **Tools** - IT-Tools, utilities
5. **Media** - Future media services (Plex, etc.)

### Authentication Configuration

#### Option 1: Use Organizr Authentication (Recommended)
- Create users in Organizr
- Set different access levels per user
- Configure which tabs each user can see

#### Option 2: Bypass Organizr Auth (Use Caddy Auth)
- Disable Organizr authentication
- Rely on Caddy's basic auth for security
- Simpler but less granular control

### Theming

Popular themes for homelab:
- **Dark Theme**: Better for monitoring dashboards
- **Hotline**: Retro cyberpunk theme
- **Aquamarine**: Clean blue theme
- **Custom**: Create your own CSS

## 📱 Mobile Configuration

Organizr works great on mobile devices:

1. **Enable Mobile View** in settings
2. **Configure Touch-Friendly Navigation**
3. **Set Mobile-Specific Tabs** (hide complex interfaces)
4. **Test Responsive Layout**

## 🔒 Security Best Practices

### Network Security
- ✅ Organizr is behind Caddy reverse proxy
- ✅ Protected by Cloudflare Tunnel
- ✅ Basic authentication enabled
- ✅ No direct port exposure to internet

### Application Security
1. **Change Default Credentials** immediately
2. **Enable 2FA** if available
3. **Regular Updates** via Watchtower
4. **Limit User Access** to necessary services only
5. **Use HTTPS** for all external links

### Access Control
```
Admin Users: Full access to all tabs
Standard Users: Limited to applications only
Guest Users: Read-only access to status pages
```

## 🛠️ Advanced Configuration

### Custom CSS Theming

Add custom CSS in Organizr settings:

```css
/* Dark theme customizations */
.bg-dark {
    background-color: #1a1a1a !important;
}

/* Custom tab colors */
.nav-tabs .nav-link.active {
    background-color: #007bff;
    border-color: #007bff;
}

/* Responsive improvements */
@media (max-width: 768px) {
    .tab-content {
        padding: 10px;
    }
}
```

### Health Check Integration

Configure health checks for your services:

1. **Enable Health Checks** in Organizr settings
2. **Add Health Check URLs** for each service:
   - Portainer: `https://hephaestus.chrislawrence.ca/api/status`
   - Uptime Kuma: `https://uptime.hephaestus.chrislawrence.ca/api/status-page/heartbeat`
   - Grafana: `https://grafana.hephaestus.chrislawrence.ca/api/health`

3. **Configure Check Intervals** (every 5 minutes recommended)

### SSO Integration

For advanced setups, integrate with:
- **Authelia** (authentication server)
- **Keycloak** (identity management)
- **LDAP/Active Directory**

## 📊 Monitoring Organizr

### Health Checks

Add Organizr to your monitoring:

**Uptime Kuma Monitor:**
- **Name**: Organizr Dashboard
- **URL**: `https://dashboard.hephaestus.chrislawrence.ca`
- **Interval**: 60 seconds

**Prometheus Monitoring:**
```yaml
# Add to prometheus.yml
- job_name: 'organizr'
  static_configs:
    - targets: ['organizr:80']
```

### Log Monitoring

Organizr logs are available:
```bash
# View Organizr logs
docker logs organizr

# View Caddy access logs for Organizr
docker exec caddy cat /data/logs/organizr.log
```

## 🚨 Troubleshooting

### Common Issues

**Can't Access Organizr**
```bash
# Check container status
docker ps | grep organizr

# Check logs
docker logs organizr

# Test internal connectivity
docker exec caddy ping organizr
```

**Setup Wizard Not Loading**
```bash
# Reset Organizr configuration
sudo rm -rf /home/chris/github/hephaestus-homelab/data/organizr/*
docker restart organizr
```

**Services Not Loading in Tabs**
1. Check if service URLs are accessible
2. Verify CORS settings in target services
3. Check for mixed content (HTTP/HTTPS) issues
4. Test direct access to service URLs

**Authentication Issues**
1. Clear browser cache and cookies
2. Check Organizr user permissions
3. Verify Caddy basic auth is working
4. Test with incognito/private browsing

### Performance Optimization

**Speed Up Loading:**
```bash
# Increase PHP memory limit in Organizr
# Add to docker-compose.yml environment:
- PHP_MEMORY_LIMIT=512M
- PHP_MAX_EXECUTION_TIME=300
```

**Database Optimization:**
- Use SQLite for small setups (default)
- Consider MySQL/PostgreSQL for heavy usage
- Regular database cleanup

## 📋 Maintenance

### Regular Tasks

**Weekly:**
- Check Organizr logs for errors
- Verify all tabs are loading correctly
- Test mobile interface

**Monthly:**
- Update Organizr container (handled by Watchtower)
- Review user access permissions
- Backup Organizr configuration

**Backup Configuration:**
```bash
# Backup Organizr data
sudo tar -czf organizr-backup-$(date +%Y%m%d).tar.gz \
  /home/chris/github/hephaestus-homelab/data/organizr/

# Restore from backup
sudo tar -xzf organizr-backup-YYYYMMDD.tar.gz -C /
```

## 🎨 Customization Ideas

### Dashboard Layouts

**Monitoring-Focused Layout:**
- Tab 1: Organizr Home (overview)
- Tab 2: Uptime Kuma (service status)
- Tab 3: Grafana (detailed metrics)
- Tab 4: Glances (system resources)

**Admin-Focused Layout:**
- Tab 1: Portainer (container management)
- Tab 2: Organizr Settings
- Tab 3: System Monitoring
- Tab 4: Application Management

### Widget Integration

Add useful widgets to Organizr home page:
- **System Stats** (CPU, RAM, disk usage)
- **Service Status** (up/down indicators)
- **Recent Logs** (error summaries)
- **Weather** (if desired)
- **Calendar** (maintenance schedules)

## 🔗 Integration with Existing Services

### Cloudflare Tunnel

Organizr is already configured to work with your Cloudflare Tunnel:
- Public access via `dashboard.hephaestus.chrislawrence.ca`
- SSL/TLS handled by Cloudflare
- DDoS protection enabled

### Caddy Reverse Proxy

Organizr integrates seamlessly with your Caddy setup:
- Basic authentication protection
- Logging enabled
- Health checks configured

### Monitoring Stack

Organizr complements your monitoring stack:
- **Uptime Kuma**: Service availability
- **Grafana**: Detailed metrics and dashboards
- **Prometheus**: Data collection
- **Organizr**: Unified access point

## 📚 Next Steps

1. **Deploy Organizr** using the provided configuration
2. **Complete Initial Setup** wizard
3. **Add Your Services** as tabs
4. **Configure Authentication** and user access
5. **Customize Theme** to match your preferences
6. **Set Up Health Checks** for service monitoring
7. **Test Mobile Access** and responsive layout
8. **Add to Monitoring** (Uptime Kuma, Prometheus)

## 🆘 Support Resources

- **Organizr Documentation**: https://docs.organizr.app/
- **Community Forum**: https://organizr.app/
- **GitHub Issues**: https://github.com/causefx/Organizr
- **Discord Community**: Available via Organizr website

---

**Last Updated**: October 12, 2025  
**Status**: 🟡 Ready for Deployment  
**Access**: https://dashboard.hephaestus.chrislawrence.ca

