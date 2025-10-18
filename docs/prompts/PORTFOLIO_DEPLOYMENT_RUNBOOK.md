# Portfolio Deployment Runbook: chrislawrence.ca/portfolio

## Goal
Deploy the `chrislawrence-portfolio` application to be publicly accessible at `https://chrislawrence.ca/portfolio/`

## Current Architecture
- **Portfolio App**: FastAPI/uvicorn running on port 5000 (container) / 8110 (host)
- **Reverse Proxy**: Caddy on port 80
- **Tunnel**: Cloudflare Tunnel via cloudflared
- **Network**: All services on `homelab-web` Docker network

## Prerequisites Checklist
- [ ] Portfolio app running locally and accessible
- [ ] Caddy proxy configured and running
- [ ] Cloudflare tunnel token available
- [ ] All services on `homelab-web` network
- [ ] Cloudflare Access policies configured

## Step 1: Verify Portfolio App
```bash
# Check if portfolio is running
cd /home/chris/apps/chrislawrence-portfolio
docker compose ps

# Test locally
curl -I http://localhost:8110/
# Should return 200 OK
```

## Step 2: Verify Caddy Configuration
```bash
# Check Caddy is running
docker ps | grep caddy

# Test Caddy can reach portfolio
docker exec -it caddy sh -lc 'curl -I http://portfolio:5000/'
# Should return 200 OK

# Check Caddyfile has portfolio route
grep -A 5 "portfolio" /home/chris/github/hephaestus-homelab/proxy/Caddyfile
```

## Step 3: Configure Cloudflare Tunnel
### Option A: Using Tunnel Token (Recommended)
```bash
# Set environment variable
export CLOUDFLARE_TUNNEL_TOKEN="your_tunnel_token_here"

# Update docker-compose.yml
cd /home/chris/github/hephaestus-homelab/proxy
# Ensure command is: tunnel --no-autoupdate run --token ${CLOUDFLARE_TUNNEL_TOKEN}
```

### Option B: Using Config File
```bash
# Create ~/.cloudflared/config.yml
cat > ~/.cloudflared/config.yml << EOF
tunnel: your-tunnel-id
credentials-file: /home/chris/.cloudflared/your-tunnel-id.json

ingress:
  - hostname: chrislawrence.ca
    service: http://localhost:80
  - service: http_status:404
EOF
```

## Step 4: Start Proxy Stack
```bash
cd /home/chris/github/hephaestus-homelab/proxy
docker compose down
docker compose up -d

# Check logs
docker compose logs -f
```

## Step 5: Configure Cloudflare Access
1. Go to Cloudflare Dashboard → Zero Trust → Access → Applications
2. Create new application for `chrislawrence.ca/portfolio`
3. Set policy to "Allow" (public access)
4. Save and test

## Step 6: Test End-to-End
```bash
# Test external access
curl -I https://chrislawrence.ca/portfolio/
# Should return 200 OK

# Test in browser
open https://chrislawrence.ca/portfolio/
```

## Troubleshooting

### Caddy can't resolve portfolio
```bash
# Check network connectivity
docker exec -it caddy sh -lc 'nslookup portfolio'
docker exec -it caddy sh -lc 'ping -c 1 portfolio'

# Verify both services on same network
docker network inspect homelab-web | grep -E "(caddy|portfolio)"
```

### Cloudflare tunnel issues
```bash
# Check tunnel status
docker compose logs cloudflared

# Common errors:
# - "flag needs an argument: -token" → Environment variable not set
# - "tunnel credentials file not found" → Need to use token approach
# - "Cannot determine default origin certificate" → Use token instead of config
```

### 503 Service Unavailable
```bash
# Check Caddy logs
docker logs caddy | grep -E "(portfolio|503|502)"

# Check if portfolio is healthy
docker exec -it portfolio curl -I http://localhost:5000/
```

### Cloudflare Access blocking
- Check Cloudflare Dashboard → Zero Trust → Access → Applications
- Ensure `/portfolio/` path is allowed
- Check for conflicting policies

## Expected Flow
1. User visits `https://chrislawrence.ca/portfolio/`
2. Cloudflare Tunnel receives request
3. Tunnel forwards to Caddy on `localhost:80`
4. Caddy matches `@portfolio_public` matcher
5. Caddy proxies to `portfolio:5000` with `uri strip_prefix /portfolio`
6. Portfolio app serves the page
7. Response flows back through the chain

## Success Criteria
- [ ] `curl -I https://chrislawrence.ca/portfolio/` returns 200 OK
- [ ] Browser shows portfolio page correctly
- [ ] All static assets load (CSS, JS, images)
- [ ] No 503/502 errors in logs
- [ ] Consistent performance (not intermittent)

## Common Issues & Solutions

### Intermittent 503s
- **Cause**: Docker DNS resolution failures
- **Solution**: Ensure all services on `homelab-web` network
- **Check**: `docker network inspect homelab-web`

### Cloudflare Access redirects
- **Cause**: Missing or incorrect Access policy
- **Solution**: Add `/portfolio/` to public access policy
- **Check**: Cloudflare Dashboard → Zero Trust → Access

### Caddy routing issues
- **Cause**: Incorrect matcher or upstream configuration
- **Solution**: Verify `@portfolio_public` matcher and `portfolio:5000` upstream
- **Check**: `docker exec -it caddy sh -lc 'curl -I http://portfolio:5000/'`

## Files to Check
- `/home/chris/github/hephaestus-homelab/proxy/Caddyfile` - Caddy routing
- `/home/chris/github/hephaestus-homelab/proxy/docker-compose.yml` - Service configuration
- `/home/chris/apps/chrislawrence-portfolio/docker-compose.yml` - Portfolio app
- `~/.cloudflared/config.yml` - Tunnel configuration (if using config approach)
- Environment variables: `CLOUDFLARE_TUNNEL_TOKEN`

## Next Steps After Success
1. Document the working configuration
2. Set up monitoring for the portfolio service
3. Configure automated deployments
4. Add SSL/TLS optimizations
5. Set up backup procedures
