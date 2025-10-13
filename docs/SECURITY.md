# Security Hardening Guide

Comprehensive security configuration for Hephaestus, following best practices for a Docker-based homelab exposed to the internet.

## Table of Contents

1. [Security Philosophy](#security-philosophy)
2. [Firewall Configuration (UFW)](#firewall-configuration-ufw)
3. [Fail2Ban Setup](#fail2ban-setup)
4. [SSH Hardening](#ssh-hardening)
5. [Docker Security](#docker-security)
6. [Cloudflare Protection](#cloudflare-protection)
7. [Tailscale VPN (Optional)](#tailscale-vpn-optional)
8. [Security Monitoring](#security-monitoring)
9. [Backup Security](#backup-security)

---

## Security Philosophy

### Defense in Depth

Hephaestus uses multiple security layers:

1. **Network**: Firewall (UFW) blocks all unnecessary ports
2. **Perimeter**: Cloudflare Tunnel provides DDoS protection and hides home IP
3. **Access**: SSH key-only authentication, no password auth
4. **Application**: Non-root containers, read-only mounts where possible
5. **Monitoring**: Fail2Ban, Uptime Kuma alerts, log analysis

### Attack Surface Minimization

**Public Internet** → Only Cloudflare Tunnel (no open ports)  
**LAN** → SSH (22), Docker services (selected ports)  
**Containers** → Minimal base images, non-root users

---

## Firewall Configuration (UFW)

### Initial Setup

```bash
# Install UFW (should already be installed)
sudo apt install ufw -y

# Set default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH (CRITICAL - do this first!)
sudo ufw allow OpenSSH
# Or specific port if you changed it:
# sudo ufw allow 2222/tcp

# Allow Docker Swarm ports (if you plan to use it)
# sudo ufw allow 2377/tcp
# sudo ufw allow 7946/tcp
# sudo ufw allow 7946/udp
# sudo ufw allow 4789/udp

# Enable firewall
sudo ufw enable

# Verify status
sudo ufw status verbose
```

### Docker Network Configuration

Docker can bypass UFW rules. Fix this:

**Edit `/etc/ufw/after.rules`**:

```bash
sudo nano /etc/ufw/after.rules
```

**Add at the end**:

```
# BEGIN UFW AND DOCKER
*filter
:ufw-user-forward - [0:0]
:DOCKER-USER - [0:0]

-A DOCKER-USER -j RETURN -s 192.168.50.0/24
-A DOCKER-USER -j RETURN -s 172.16.0.0/12
-A DOCKER-USER -j ufw-user-forward

-A DOCKER-USER -j DROP -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -d 192.168.0.0/16
-A DOCKER-USER -j DROP -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -d 10.0.0.0/8
-A DOCKER-USER -j DROP -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -d 172.16.0.0/12
-A DOCKER-USER -j DROP -p udp -m udp --dport 0:32767 -d 192.168.0.0/16
-A DOCKER-USER -j DROP -p udp -m udp --dport 0:32767 -d 10.0.0.0/8
-A DOCKER-USER -j DROP -p udp -m udp --dport 0:32767 -d 172.16.0.0/12

-A DOCKER-USER -j RETURN
COMMIT
# END UFW AND DOCKER
```

**Restart UFW**:

```bash
sudo systemctl restart ufw
```

### Port Management

**LAN-only services** (no UFW rules needed, Docker handles it):
- Portainer: 9000
- Uptime Kuma: 3001 (via Cloudflare)
- Grafana: 3000 (via Cloudflare)
- Glances: 61208

**No ports 80/443 open to WAN** - Cloudflare Tunnel handles all public traffic.

### Allow LAN Access (Optional)

If you want specific LAN devices to access services:

```bash
# Allow from specific IP
sudo ufw allow from 192.168.50.0/24 to any port 9000
sudo ufw allow from 192.168.50.0/24 to any port 3000

# Or specific device
sudo ufw allow from 192.168.50.100 to any port 9000
```

---

## Fail2Ban Setup

Fail2Ban monitors logs and bans IPs with suspicious activity.

### Installation

```bash
sudo apt install fail2ban -y
```

### Configuration

**Create local config**:

```bash
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo nano /etc/fail2ban/jail.local
```

**Basic configuration**:

```ini
[DEFAULT]
# Ban for 1 hour
bantime = 3600
# Check for attacks in 10 minute window
findtime = 600
# Ban after 5 failed attempts
maxretry = 5
# Email alerts (optional)
destemail = your-email@example.com
sendername = Fail2Ban-Hephaestus
action = %(action_mwl)s

[sshd]
enabled = true
port = ssh
logpath = /var/log/auth.log
maxretry = 3
bantime = 7200
```

### Docker Container Protection

Create custom filter for Docker logs:

**`/etc/fail2ban/filter.d/docker-unauthorized.conf`**:

```ini
[Definition]
failregex = ^.*"(?:GET|POST|HEAD).*" (401|403) .*$
            ^.*Failed password for.* from <HOST>.*$
ignoreregex =
```

**Add to `/etc/fail2ban/jail.local`**:

```ini
[docker-unauthorized]
enabled = true
filter = docker-unauthorized
logpath = /var/log/docker-unauthorized.log
maxretry = 5
bantime = 3600
```

### Start Fail2Ban

```bash
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Check status
sudo fail2ban-client status
sudo fail2ban-client status sshd
```

### Unban an IP

```bash
# List banned IPs
sudo fail2ban-client status sshd

# Unban specific IP
sudo fail2ban-client set sshd unbanip 192.168.50.100
```

---

## SSH Hardening

### 1. Use SSH Keys Only

**Generate key on your main PC** (if not already done):

```bash
ssh-keygen -t ed25519 -f ~/.ssh/hephaestus -C "chris@hephaestus"
```

**Copy to Hephaestus**:

```bash
ssh-copy-id -i ~/.ssh/hephaestus.pub chris@192.168.50.70
```

**Test key authentication**:

```bash
ssh -i ~/.ssh/hephaestus chris@192.168.50.70
```

### 2. Harden SSH Config

**On Hephaestus**, edit SSH config:

```bash
sudo nano /etc/ssh/sshd_config
```

**Recommended settings**:

```
# Disable root login
PermitRootLogin no

# Disable password authentication
PasswordAuthentication no
ChallengeResponseAuthentication no
PubkeyAuthentication yes

# Disable empty passwords
PermitEmptyPasswords no

# Limit authentication attempts
MaxAuthTries 3

# Limit concurrent sessions
MaxSessions 10

# Use strong key exchange algorithms
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org

# Enable public key authentication
AuthorizedKeysFile .ssh/authorized_keys

# Log verbosity
LogLevel VERBOSE

# Disable X11 forwarding (if not needed)
X11Forwarding no

# Optional: Change SSH port (reduces automated attacks)
# Port 2222
```

**Restart SSH**:

```bash
sudo systemctl restart ssh
```

### 3. Configure SSH Client

**On your main PC**, create `~/.ssh/config`:

```
Host hephaestus
    HostName 192.168.50.70
    User chris
    IdentityFile ~/.ssh/hephaestus
    IdentitiesOnly yes
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

**Test**:

```bash
ssh hephaestus
```

---

## Docker Security

### Non-Root Containers

Where possible, run containers as non-root users. Already configured in `docker-compose.yml`:

```yaml
grafana:
  user: "472"  # Grafana UID
  
prometheus:
  user: "nobody"
```

### Read-Only Mounts

Use read-only mounts for configuration files:

```yaml
volumes:
  - ./proxy/Caddyfile:/etc/caddy/Caddyfile:ro
  - ./grafana-stack/prometheus.yml:/etc/prometheus/prometheus.yml:ro
```

### Security Options

Applied to sensitive services:

```yaml
portainer:
  security_opt:
    - no-new-privileges:true
```

### Docker Socket Permissions

The Docker socket is powerful. Limit access:

```bash
# Verify permissions
ls -l /var/run/docker.sock

# Should be owned by docker group
sudo chown root:docker /var/run/docker.sock
```

Containers with socket access (Portainer, Watchtower) have **root-equivalent** permissions. Monitor them carefully.

### Image Security

1. **Use official images** when possible
2. **Pin versions** instead of `latest`:
   ```yaml
   image: caddy:2-alpine  # Good
   # Not: image: caddy:latest
   ```
3. **Scan images** for vulnerabilities:
   ```bash
   docker scan caddy:2-alpine
   ```

### Network Isolation

Services communicate via the `web` network only. No host networking except where required (node-exporter, glances).

---

## Cloudflare Protection

### WAF Rules

In Cloudflare Dashboard:

1. Go to **Security** → **WAF**
2. Enable **OWASP Core Ruleset**
3. Create custom rules:

**Block common attacks**:

```
(http.request.uri.path contains "/admin" and not ip.geoip.country eq "US")
(http.request.uri.path contains "phpMyAdmin")
(http.request.uri.path contains "wp-admin" and not cf.threat_score le 10)
```

### Rate Limiting

1. Go to **Security** → **WAF** → **Rate Limiting Rules**
2. Create rule:
   - **Name**: API Rate Limit
   - **If incoming requests match**: Hostname equals `api.magicpages.yourdomain.com`
   - **Then**: Block for 60 seconds if > 100 requests per minute

### DDoS Protection

Already enabled by default on Cloudflare. Verify:

1. Go to **Security** → **DDoS**
2. Ensure **HTTP DDoS Attack Protection** is enabled
3. Set sensitivity to **High**

### SSL/TLS Settings

1. Go to **SSL/TLS**
2. Set encryption mode: **Full (strict)**
3. Enable **Always Use HTTPS**
4. Enable **Automatic HTTPS Rewrites**
5. **Minimum TLS Version**: 1.2 or higher

---

## Tailscale VPN (Optional)

For secure remote access without exposing services publicly.

### Installation

```bash
# Add Tailscale repository
curl -fsSL https://tailscale.com/install.sh | sh

# Authenticate
sudo tailscale up

# Get Tailscale IP
tailscale ip -4
```

### Use Cases

1. **SSH access** via Tailscale instead of internet
2. **Access Portainer** without Cloudflare Tunnel
3. **Private services** (databases, admin panels)

### Access Services

Once connected to Tailscale:

```bash
# SSH via Tailscale
ssh chris@<tailscale-ip>

# Access Portainer
https://<tailscale-ip>:9000

# Access Grafana
http://<tailscale-ip>:3000
```

### Split Configuration

Public services → Cloudflare Tunnel  
Admin/internal services → Tailscale only

---

## Security Monitoring

### Log Aggregation

**View Docker logs**:

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f caddy

# Last 100 lines
docker compose logs --tail=100 caddy
```

**View Caddy access logs**:

```bash
docker exec caddy tail -f /data/logs/uptime.log
```

**View system logs**:

```bash
# SSH attempts
sudo tail -f /var/log/auth.log

# System messages
sudo journalctl -f
```

### Automated Alerts

**Set up Uptime Kuma monitors** (see MONITORING.md):
- Monitor all public endpoints
- Alert on downtime or slow response
- Send notifications via Discord/Telegram/Email

**Grafana alerts** (optional):
- High CPU usage
- Low disk space
- Container restarts
- Failed authentication attempts

### Security Auditing

**Run regular security checks**:

```bash
# Check for open ports
sudo ss -tulpn

# Check failed SSH attempts
sudo grep "Failed password" /var/log/auth.log | tail -20

# Check Fail2Ban bans
sudo fail2ban-client status sshd

# List running containers
docker ps

# Check for outdated images
docker images --filter "dangling=true"
```

---

## Backup Security

### Encrypted Backups

When using the backup script (see `scripts/backup.sh`):

1. **Encrypt sensitive files**:
   ```bash
   tar -czf - /path/to/backup | gpg --encrypt --recipient your-email@example.com > backup.tar.gz.gpg
   ```

2. **Store `.env` securely**:
   - Never commit to git
   - Backup separately
   - Encrypt before cloud storage

### Backup Verification

Regularly test restores:

```bash
# Test restore
tar -tzf backup.tar.gz
# Extract to test location
tar -xzf backup.tar.gz -C /tmp/restore-test
```

---

## Security Checklist

### Initial Setup
- [ ] UFW firewall enabled with default deny
- [ ] SSH keys configured, password auth disabled
- [ ] Fail2Ban installed and monitoring SSH
- [ ] Root login disabled
- [ ] Docker socket permissions verified

### Ongoing Maintenance
- [ ] Regular system updates (`apt update && apt upgrade`)
- [ ] Monitor Fail2Ban logs weekly
- [ ] Review Cloudflare WAF logs monthly
- [ ] Audit user accounts quarterly
- [ ] Test backup restores quarterly
- [ ] Rotate SSH keys annually

### Container Security
- [ ] All containers using `restart: unless-stopped`
- [ ] Watchtower enabled for automatic updates
- [ ] Non-root users where possible
- [ ] Read-only mounts for configs
- [ ] No hardcoded secrets in compose files

### Network Security
- [ ] No ports 80/443 forwarded on router
- [ ] All public traffic through Cloudflare Tunnel
- [ ] Cloudflare WAF enabled
- [ ] Rate limiting configured
- [ ] SSL/TLS set to Full (strict)

---

## Incident Response

### Compromised Container

```bash
# Stop container immediately
docker compose stop <service>

# Check logs for suspicious activity
docker compose logs <service> > incident-logs.txt

# Remove and recreate
docker compose rm <service>
docker compose up -d --force-recreate <service>

# Review and rotate secrets
```

### Suspicious Activity

```bash
# Check current connections
sudo ss -tunap

# Check for unauthorized users
who
last

# Check for unauthorized processes
ps aux | grep -v root

# Check cron jobs
sudo crontab -l
ls -la /etc/cron.d/
```

### Recovery

1. Disconnect from network (if severe)
2. Analyze logs and identify breach vector
3. Patch vulnerability
4. Rotate all credentials
5. Restore from clean backup
6. Monitor for recurrence

---

## Additional Resources
## Security Rules Cheat Sheet

### Categories for Cloudflare Protections

### 1. Public-Facing Services (Use CAPTCHA)
- **Description:** For anything that’s publicly accessible and you want to add a layer of bot protection or professionalism.
- **Examples:**
  - Contact forms
  - Public login pages
  - Any public-facing demo sites or tools
- **How to Apply:**
  - Enable Cloudflare Turnstile CAPTCHA on these pages.

### 2. Internal or Sensitive Services (Use Cloudflare Access)
- **Description:** For admin dashboards, internal tools, or anything you want to restrict to certain users.
- **Examples:**
  - Admin panels
  - Internal note-taking apps or wikis
  - Any service handling sensitive data or configuration
- **How to Apply:**
  - Use Cloudflare Access to require a one-time code, email-based login, or SSO for these routes.

### 3. Account or Payment-Related Pages
- **Description:** For areas where users might manage accounts or where payment processing occurs.
- **Examples:**
  - Account settings pages
  - Any page right before a Stripe payment form
- **How to Apply:**
  - Typically combine CAPTCHA on public account login and Cloudflare Access for more sensitive account management areas.

---

Feel free to tweak these categories and examples as you see fit, and keep this markdown handy whenever you want to apply those rules!

- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [Cloudflare Security](https://www.cloudflare.com/security/)
- [Ubuntu Server Security](https://ubuntu.com/server/docs/security)
- [CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker)

---

## Quick Commands Reference

```bash
# Firewall
sudo ufw status
sudo ufw allow from 192.168.50.0/24

# Fail2Ban
sudo fail2ban-client status
sudo fail2ban-client status sshd

# SSH
sudo systemctl restart ssh
sudo tail -f /var/log/auth.log

# Docker
docker compose logs -f
docker system prune -a

# System
sudo apt update && sudo apt upgrade
sudo systemctl status
```

