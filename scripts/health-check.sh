#!/bin/bash
cd /home/chris/github/hephaestus-infra

echo "=== Hephaestus Health Check ==="
echo "Date: $(date)"
echo "Uptime: $(uptime)"

# Check Docker services
echo -e "\n=== Docker Services ==="
docker compose ps

# Check specific services
echo -e "\n=== Service Health ==="
curl -s http://localhost:3001/health && echo "✅ Uptime Kuma: OK" || echo "❌ Uptime Kuma: DOWN"
curl -s http://localhost:9000 && echo "✅ Portainer: OK" || echo "❌ Portainer: DOWN"
curl -s http://localhost:3000 && echo "✅ Grafana: OK" || echo "❌ Grafana: DOWN"

# System resources
echo -e "\n=== System Resources ==="
df -h / | tail -1
free -h | grep Mem
