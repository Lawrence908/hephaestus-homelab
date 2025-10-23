**SERVICE CONFIGURATION:**
- **Domain**: {{ $json.DOMAIN }}
- **Path**: {{ $json.PATH }}
- **Service Name**: {{ $json.SERVICE_NAME }}
- **Container**: {{ $json.CONTAINER_NAME }}
- **Internal Port**: {{ $json.INTERNAL_PORT }}
- **External Port**: {{ $json.EXTERNAL_PORT }}
- **Critical**: {{ $json.CRITICAL }}

**COMPREHENSIVE DIAGNOSTICS:**
```bash
# Container diagnostics
docker ps | grep {{ $json.CONTAINER_NAME }}
docker logs {{ $json.CONTAINER_NAME }} --tail=20 --since="5m"
docker stats {{ $json.CONTAINER_NAME }} --no-stream
docker inspect {{ $json.CONTAINER_NAME }}

# Internal service test
docker exec {{ $json.CONTAINER_NAME }} curl -f http://localhost:{{ $json.INTERNAL_PORT }}/ || echo "❌ Internal service unhealthy"

# Network diagnostics
docker network ls | grep {{ $json.NETWORK }}
docker network inspect {{ $json.NETWORK }}
docker exec {{ $json.CONTAINER_NAME }} ping -c 3 caddy

# Infrastructure dependencies
sudo systemctl status cloudflared
sudo systemctl status docker
docker ps | grep caddy
docker logs caddy --tail=20 --since="5m"

# Port connectivity
netstat -tlnp | grep :{{ $json.EXTERNAL_PORT }}
docker port {{ $json.CONTAINER_NAME }}
```

**SERVICE-SPECIFIC DIAGNOSTICS:**
```bash
# Check service health endpoint (if available)
curl -f http://localhost:{{ $json.EXTERNAL_PORT }}/health || echo "❌ Health endpoint failed"

# Check service metrics (if available)
curl -f http://localhost:{{ $json.EXTERNAL_PORT }}/metrics || echo "❌ Metrics endpoint failed"

# Check service logs for errors
docker logs {{ $json.CONTAINER_NAME }} --tail=50 | grep -i error
docker logs {{ $json.CONTAINER_NAME }} --tail=50 | grep -i exception
```

The service https://{{ $json.DOMAIN }}{{ $json.PATH }} is down. Please run comprehensive diagnostics to identify the root cause and recommend specific repair actions.