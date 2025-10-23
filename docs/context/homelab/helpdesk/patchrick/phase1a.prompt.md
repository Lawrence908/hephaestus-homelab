**SERVICE CONFIGURATION:**
- **Domain**: {{ $json.DOMAIN }}
- **Path**: {{ $json.PATH }}
- **Service Name**: {{ $json.SERVICE_NAME }}
- **Container**: {{ $json.CONTAINER_NAME }}
- **Internal Port**: {{ $json.INTERNAL_PORT }}
- **External Port**: {{ $json.EXTERNAL_PORT }}
- **Expected Content**: {{ $json.EXPECTED_CONTENT }}
- **Critical**: {{ $json.CRITICAL }}
- **Timeout**: {{ $json.TIMEOUT }} seconds
- **Retries**: {{ $json.RETRIES }}

**QUICK HEALTH CHECKS:**
```bash
# Public accessibility test
curl -I -w "Time: %{time_total}s\n" https://{{ $json.DOMAIN }}{{ $json.PATH }}

# Local accessibility test
curl -I http://localhost:80{{ $json.PATH }} -H "Host: {{ $json.DOMAIN }}"

# Container status check
docker ps | grep {{ $json.CONTAINER_NAME }}

# Direct port test (if accessible)
curl -I http://localhost:{{ $json.EXTERNAL_PORT }}/ -w "Time: %{time_total}s\n" 2>/dev/null || echo "Direct port not accessible"
```

**CONTENT VERIFICATION:**
```bash
# Check for expected content
curl -s https://{{ $json.DOMAIN }}{{ $json.PATH }} | grep -q "{{ $json.EXPECTED_CONTENT }}" && echo "✅ Content verified" || echo "❌ Content missing"
```

Please perform a quick health check on https://{{ $json.DOMAIN }}{{ $json.PATH }} and determine if the service is operational.
```