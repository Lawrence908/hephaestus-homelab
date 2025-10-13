# 🔒 Cloudflare Security Configuration

This guide aligns with your SECURITY.md to implement proper Cloudflare security instead of basic auth.

## 🎯 Security Strategy

### **Public Services** → Cloudflare Turnstile CAPTCHA
- Portfolio, SchedShare, CapitolScope, etc.
- Protects against bots while allowing legitimate users

### **Admin/Internal Services** → Cloudflare Access
- Dashboard, Docker, Metrics, Uptime, etc.
- Requires email-based authentication or SSO

## 🚀 Implementation Steps

### 1. **Cloudflare Access Setup**

#### **Step 1: Enable Cloudflare Access**
1. Go to **Cloudflare Dashboard** → **Zero Trust** → **Access**
2. Click **"Get started"** if not already enabled

#### **Step 2: Create Application**
1. Go to **Access** → **Applications**
2. Click **"Add an application"** → **"Self-hosted"**
3. Configure:

**Application Name:** `Hephaestus Admin Panel`  
**Subdomain:** `chrislawrence.ca`  
**Path:** `/dashboard/*`  
**Domain:** `chrislawrence.ca`  

#### **Step 3: Authentication Policy**
1. **Policy Name:** `Admin Access`
2. **Action:** `Allow`
3. **Rules:**
   - **Email:** `your-email@example.com` (add your email)
   - **Email domain:** `@yourdomain.com` (optional)
4. **Session Duration:** `24 hours`

#### **Step 4: Additional Applications**
Repeat for each protected service:

| Service | Path | Description |
|---------|------|-------------|
| **Dashboard** | `/dashboard/*` | Organizr dashboard |
| **Docker** | `/docker/*` | Portainer |
| **Uptime** | `/uptime/*` | Uptime Kuma |
| **Metrics** | `/metrics/*` | Grafana |
| **Prometheus** | `/prometheus/*` | Prometheus |
| **Containers** | `/containers/*` | cAdvisor |
| **System** | `/system/*` | Glances |
| **Tools** | `/tools/*` | IT-Tools |
| **n8n** | `/n8n/*` | n8n automation |
| **Notes** | `/notes/*` | Obsidian |
| **MQTT** | `/mqtt/*` | MQTT Explorer |
| **Meshtastic** | `/meshtastic/*` | Meshtastic Web |
| **Node-RED** | `/nodered/*` | Node-RED |
| **Grafana IoT** | `/grafana-iot/*` | Grafana IoT |
| **InfluxDB** | `/influxdb/*` | InfluxDB |

### 2. **Cloudflare Turnstile CAPTCHA Setup**

#### **Step 1: Enable Turnstile**
1. Go to **Security** → **Turnstile**
2. Click **"Get started"**

#### **Step 2: Create Site Key**
1. **Site Name:** `chrislawrence.ca`
2. **Domain:** `chrislawrence.ca`
3. **Widget Mode:** `Managed`
4. **Pre-clearance:** `Enabled` (optional)

#### **Step 3: Configure Rules**
1. Go to **Security** → **WAF** → **Custom Rules**
2. Create rule:

**Rule Name:** `Turnstile Protection`  
**Expression:** `(http.request.uri.path contains "/portfolio" or http.request.uri.path contains "/schedshare" or http.request.uri.path contains "/capitolscope")`  
**Action:** `Managed Challenge`  

### 3. **WAF Rules Configuration**

#### **Step 1: Enable OWASP Core Ruleset**
1. Go to **Security** → **WAF**
2. Enable **OWASP Core Ruleset**
3. Set sensitivity to **Medium**

#### **Step 2: Custom Security Rules**

**Block Admin Paths:**
```
(http.request.uri.path contains "/admin" and not cf.access.identity.email eq "your-email@example.com")
```

**Rate Limiting:**
```
(http.request.uri.path contains "/api" and cf.threat_score gt 10)
```

**Bot Protection:**
```
(cf.bot_management.score lt 30 and http.request.uri.path contains "/portfolio")
```

### 4. **SSL/TLS Configuration**

1. Go to **SSL/TLS** → **Overview**
2. Set encryption mode: **Full (strict)**
3. Enable **Always Use HTTPS**
4. Enable **Automatic HTTPS Rewrites**
5. **Minimum TLS Version:** 1.2

### 5. **DDoS Protection**

1. Go to **Security** → **DDoS**
2. Enable **HTTP DDoS Attack Protection**
3. Set sensitivity to **High**
4. Enable **Network-layer DDoS Attack Protection**

## 🔧 Testing Your Setup

### **Test Public Services (No Auth Required)**
```bash
# Should work without authentication
curl -I https://chrislawrence.ca/portfolio/
curl -I https://chrislawrence.ca/schedshare/
curl -I https://chrislawrence.ca/capitolscope/
```

### **Test Protected Services (Auth Required)**
```bash
# Should redirect to Cloudflare Access login
curl -I https://chrislawrence.ca/dashboard/
curl -I https://chrislawrence.ca/docker/
curl -I https://chrislawrence.ca/uptime/
```

### **Test CAPTCHA Protection**
1. Visit `https://chrislawrence.ca/portfolio/` in browser
2. Should see Turnstile CAPTCHA if configured
3. Complete CAPTCHA to access

## 📊 Monitoring & Alerts

### **Cloudflare Analytics**
1. Go to **Analytics** → **Security**
2. Monitor:
   - Blocked requests
   - Bot score distribution
   - Geographic distribution
   - Top attack vectors

### **Access Logs**
1. Go to **Zero Trust** → **Logs** → **Access**
2. Monitor:
   - Successful logins
   - Failed authentication attempts
   - Geographic access patterns

### **WAF Logs**
1. Go to **Security** → **Events**
2. Monitor:
   - Blocked requests
   - Challenge completions
   - Rate limit triggers

## 🚨 Security Alerts

### **Set Up Notifications**
1. Go to **Notifications** → **Destinations**
2. Add email/webhook for:
   - High threat score requests
   - Multiple failed access attempts
   - DDoS attack detection
   - WAF rule triggers

## 🔄 Maintenance

### **Regular Tasks**
- [ ] Review access logs weekly
- [ ] Update email allowlists monthly
- [ ] Rotate API keys quarterly
- [ ] Review WAF rules quarterly
- [ ] Test backup access methods

### **Security Audits**
- [ ] Test all protected endpoints
- [ ] Verify CAPTCHA is working
- [ ] Check for unauthorized access attempts
- [ ] Review geographic access patterns
- [ ] Validate SSL/TLS configuration

## 🎯 Benefits of This Approach

### **Better User Experience**
- ✅ Professional login flows
- ✅ No browser auth popups
- ✅ Mobile-friendly authentication
- ✅ SSO integration ready

### **Enhanced Security**
- ✅ Cloudflare's global infrastructure
- ✅ Advanced bot detection
- ✅ Geographic filtering
- ✅ Real-time threat intelligence

### **Easier Management**
- ✅ Centralized access control
- ✅ Detailed audit logs
- ✅ Easy user management
- ✅ Integration with existing tools

---

## 🚀 Quick Start Commands

```bash
# Test your setup
curl -I https://chrislawrence.ca/portfolio/  # Should work
curl -I https://chrislawrence.ca/dashboard/ # Should redirect to login

# Check Cloudflare status
dig chrislawrence.ca
nslookup chrislawrence.ca
```

**Next Steps:**
1. Configure Cloudflare Access for admin services
2. Set up Turnstile CAPTCHA for public services  
3. Test all endpoints
4. Set up monitoring and alerts
5. Document access procedures for team members

---

*This configuration provides enterprise-grade security while maintaining excellent user experience! 🚀*
