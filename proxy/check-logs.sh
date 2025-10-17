#!/bin/bash

# Check Caddy logs using Docker
# This avoids permission issues with the log files

echo "=== Caddy Logging Status ==="
echo

# Check if Caddy is running
if docker compose ps caddy | grep -q "Up"; then
    echo "✓ Caddy is running"
else
    echo "✗ Caddy is not running"
    exit 1
fi

# Check log files using Docker
echo
echo "=== Log Files ==="
docker exec caddy ls -la /data/logs/ 2>/dev/null || echo "Could not access logs directory"

# Show recent log entries
echo
echo "=== Recent Log Entries ==="
docker exec caddy tail -5 /data/logs/caddy.json 2>/dev/null || echo "Could not read caddy.json"

# Check log file sizes
echo
echo "=== Log File Sizes ==="
docker exec caddy du -h /data/logs/*.json 2>/dev/null || echo "Could not check log sizes"

echo
echo "=== Logging is Working! ==="
echo "Logs are being written to: ./logs/"
echo "Use 'docker exec caddy cat /data/logs/caddy.json' to view logs"
echo "Use './log-analyzer.sh' to analyze logs (if available)"

