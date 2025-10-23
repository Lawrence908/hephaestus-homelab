**SERVICE CONFIGURATION:**
- **Domain**: {{ $json.DOMAIN }}
- **Path**: {{ $json.PATH }}
- **Service Name**: {{ $json.SERVICE_NAME }}
- **Container**: {{ $json.CONTAINER_NAME }}
- **Internal Port**: {{ $json.INTERNAL_PORT }}
- **External Port**: {{ $json.EXTERNAL_PORT }}
- **Critical**: {{ $json.CRITICAL }}

**APPROVED REPAIR COMMANDS:**
{{ $json.APPROVED_COMMANDS }}

**REPAIR EXECUTION:**
```bash
# Execute approved commands
{{ $json.APPROVED_COMMANDS }}

# Wait for services to stabilize
sleep 30

# Verify container is running
docker ps | grep {{ $json.CONTAINER_NAME }}

# Test internal connectivity
docker exec {{ $json.CONTAINER_NAME }} curl -f http://localhost:{{ $json.INTERNAL_PORT }}/ || echo "❌ Internal service still unhealthy"
```

**FINAL VERIFICATION:**
```bash
# Test public accessibility
curl -I https://{{ $json.DOMAIN }}{{ $json.PATH }} -w "Time: %{time_total}s\n"

# Test local accessibility
curl -I http://localhost:80{{ $json.PATH }} -H "Host: {{ $json.DOMAIN }}"

# Verify content is served
curl -s https://{{ $json.DOMAIN }}{{ $json.PATH }} | grep -q "{{ $json.EXPECTED_CONTENT }}" && echo "✅ Content verified" || echo "❌ Content missing"
```

Please execute the approved repair commands and verify that https://{{ $json.DOMAIN }}{{ $json.PATH }} is now operational.