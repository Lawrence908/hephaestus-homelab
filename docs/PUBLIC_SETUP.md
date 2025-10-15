# Public Service Setup Guide

## Why MagicPages Was So Easy

The MagicPages setup was successful because:

1. **✅ Application was already working locally** - No debugging needed
2. **✅ Database was already configured** - Supabase connection was solid
3. **✅ Container was already running** - Just needed reverse proxy
4. **✅ Caddyfile pattern was established** - SchedShare provided the template
5. **✅ No authentication conflicts** - Clean slate for security

## The MagicPages Success Pattern

### What Made It Work:
- **Working Application**: MagicPages was fully functional locally
- **Established Pattern**: SchedShare configuration provided the template
- **Simple Addition**: Just added one block to Caddyfile
- **No Complex Dependencies**: No database migrations, no auth conflicts
- **Clean Restart**: Caddy reload applied changes immediately

## Public Service Setup Checklist

### Phase 1: Pre-Setup (Critical for Success)
- [ ] **Application works locally** - Test thoroughly before exposing
- [ ] **Database is configured** - No connection issues
- [ ] **Container is healthy** - `docker ps` shows running
- [ ] **No authentication conflicts** - Clean login flow
- [ ] **Environment variables set** - All secrets in `.env`

### Phase 2: Caddy Configuration
```caddyfile
# Service Name (Public) - Port XXXX
@servicename {
    path /service-path/*
}
handle @servicename {
    uri strip_prefix /service-path
    reverse_proxy service-container:port {
        header_up Host {host}
        header_up X-Forwarded-Proto {scheme}
        header_up X-Forwarded-For {remote}
        header_up X-Real-IP {remote}
    }
}
```

### Phase 3: Apply Configuration
```bash
# Reload Caddy
docker exec caddy caddy reload --config /etc/caddy/Caddyfile

# Or restart if reload fails
docker restart caddy
```

### Phase 4: Test Access
```bash
# Test HTTP redirect
curl -I http://chrislawrence.ca/your-service/

# Test HTTPS access
curl -I https://chrislawrence.ca/your-service/
```

## Common Failure Patterns (What to Avoid)

### ❌ Don't Expose Until Ready
- **Problem**: Exposing broken applications
- **Solution**: Fix locally first, then expose

### ❌ Don't Skip Database Setup
- **Problem**: Database connection issues after exposure
- **Solution**: Test database connectivity before exposing

### ❌ Don't Ignore Authentication
- **Problem**: Login loops, session issues
- **Solution**: Verify auth flow works locally

### ❌ Don't Forget Environment Variables
- **Problem**: Missing secrets, wrong database
- **Solution**: Check all env vars are set

## Service-Specific Considerations

### Django Applications
- **Session Cookies**: Ensure `SESSION_COOKIE_SAMESITE = "Lax"`
- **CSRF**: Check `CSRF_TRUSTED_ORIGINS` includes your domain
- **Database**: Use production database, not SQLite
- **Security**: Disable Axes if needed for development

### Node.js Applications
- **Port Binding**: Ensure app binds to `0.0.0.0`, not `localhost`
- **CORS**: Configure for your domain
- **Environment**: Check all required env vars

### Static Sites
- **Build Process**: Ensure production build is complete
- **Asset Paths**: Check for absolute vs relative paths
- **Base URL**: Configure for subdirectory deployment

## Security Options

### Option 1: Basic Auth (Quick)
```caddyfile
# Add to service block
basicauth {
    username $2a$14$hash
}
```

### Option 2: Cloudflare Access (Recommended)
- Configure in Cloudflare dashboard
- Better user experience
- More secure than basic auth
- Supports SSO integration

## Troubleshooting Checklist

### Service Not Accessible
1. Check container is running: `docker ps`
2. Check Caddy logs: `docker logs caddy`
3. Test local access: `curl http://localhost:port`
4. Verify Caddyfile syntax: `docker exec caddy caddy validate`

### Database Issues
1. Check database connection in container
2. Verify environment variables
3. Test database connectivity
4. Check for migration issues

### Authentication Problems
1. Check session cookie settings
2. Verify CSRF configuration
3. Test login flow locally
4. Check for Axes blocking

### Performance Issues
1. Check container resources
2. Monitor database performance
3. Verify reverse proxy configuration
4. Check for memory leaks

## Success Metrics

### ✅ Ready for Public Exposure When:
- [ ] Application loads without errors
- [ ] Database queries work
- [ ] Authentication flows properly
- [ ] No console errors
- [ ] All features functional
- [ ] Performance is acceptable

### ✅ Post-Exposure Verification:
- [ ] HTTPS redirect works
- [ ] Login/logout functions
- [ ] All pages load correctly
- [ ] No security warnings
- [ ] Mobile responsive (if applicable)

## Quick Reference Commands

```bash
# Check container status
docker ps | grep your-service

# View container logs
docker logs your-service-container

# Test local connectivity
curl http://localhost:port

# Reload Caddy
docker exec caddy caddy reload --config /etc/caddy/Caddyfile

# Test public access
curl -I https://chrislawrence.ca/your-service/

# Check Caddyfile syntax
docker exec caddy caddy validate --config /etc/caddy/Caddyfile
```

## Template for New Services

```caddyfile
# Your Service (Public) - Port XXXX
@yourservice {
    path /your-path/*
}
handle @yourservice {
    uri strip_prefix /your-path
    reverse_proxy your-container:port {
        header_up Host {host}
        header_up X-Forwarded-Proto {scheme}
        header_up X-Forwarded-For {remote}
        header_up X-Real-IP {remote}
    }
}
```

## Remember: The MagicPages Success Formula

1. **Working Application** ✅
2. **Established Pattern** ✅  
3. **Simple Addition** ✅
4. **Clean Restart** ✅
5. **Immediate Success** ✅

Follow this pattern, and your next service exposure should be just as smooth!
