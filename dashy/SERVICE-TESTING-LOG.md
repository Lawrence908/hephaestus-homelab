# Dashy Multi-Access Dashboard Testing Log

**Date Started**: 2025-01-27
**Date Completed**: _______________

---

## Testing Legend
- ✅ = Working correctly
- ❌ = Failed/Not working
- ⚠️ = Partial/Issues found
- ⬜ = Not tested yet
- 🔧 = Needs fix
- ✓ = Verified fixed

---

## Infrastructure & Monitoring Services

### Caddy
| Access Method | URL | Status | Connectivity | Favicon | Path/Subdomain | Notes |
|--------------|-----|--------|--------------|---------|----------------|-------|
| Local | `http://192.168.50.70:80` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Tailscale | `http://hephaestus.tailaa3ef2.ts.net` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Public | N/A | - | - | - | - | Not in public config |

### Portainer
| Access Method | URL | Status | Connectivity | Favicon | Path/Subdomain | Notes |
|--------------|-----|--------|--------------|---------|----------------|-------|
| Local | `http://192.168.50.70:9000` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Tailscale | `http://hephaestus.tailaa3ef2.ts.net:9000` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Public | `https://dev.chrislawrence.ca/docker` | ✅ | ✅ HTTP 302 | ⬜ | ⬜ | Redirect detected |

### Uptime Kuma
| Access Method | URL | Status | Connectivity | Favicon | Path/Subdomain | Notes |
|--------------|-----|--------|--------------|---------|----------------|-------|
| Local | `http://192.168.50.70:3001` | ✅ | ✅ HTTP 302 | ⬜ | ⬜ | Redirect detected |
| Tailscale | `http://hephaestus.tailaa3ef2.ts.net:3001` | ✅ | ✅ HTTP 302 | ⬜ | ⬜ | Redirect detected |
| Public | `https://uptime.chrislawrence.ca` | ✅ | ✅ HTTP 302 | ⬜ | ⬜ | Redirect detected |
| Public (Monitor) | `https://monitor.chrislawrence.ca/uptime` | ✅ | ✅ HTTP 302 | ⬜ | ⬜ | Redirect detected |
| Public (Dev) | `https://dev.chrislawrence.ca/uptime` | ✅ | ✅ HTTP 302 | ⬜ | ⬜ | Redirect detected |

### Dashy
| Access Method | URL | Status | Connectivity | Favicon | Path/Subdomain | Notes |
|--------------|-----|--------|--------------|---------|----------------|-------|
| Local | `http://192.168.50.70:8082` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Tailscale | `http://hephaestus.tailaa3ef2.ts.net:8082` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Public | `https://dev.chrislawrence.ca` | ✅ | ✅ HTTP 302 | ⬜ | ⬜ | Redirect detected |

### Organizr
| Access Method | URL | Status | Connectivity | Favicon | Path/Subdomain | Notes |
|--------------|-----|--------|--------------|---------|----------------|-------|
| Local | `http://192.168.50.70:8086` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Tailscale | `http://hephaestus.tailaa3ef2.ts.net:8086` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Public | `https://dev.chrislawrence.ca/organizr` | ✅ | ✅ HTTP 302 | ⬜ | ⬜ | Redirect detected |

### IT-Tools
| Access Method | URL | Status | Connectivity | Favicon | Path/Subdomain | Notes |
|--------------|-----|--------|--------------|---------|----------------|-------|
| Local | `http://192.168.50.70:8081` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Tailscale | `http://hephaestus.tailaa3ef2.ts.net:8081` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Public | `https://dev.chrislawrence.ca/tools` | ✅ | ✅ HTTP 302 | ⬜ | ⬜ | Redirect detected |

### Glances
| Access Method | URL | Status | Connectivity | Favicon | Path/Subdomain | Notes |
|--------------|-----|--------|--------------|---------|----------------|-------|
| Local | `http://192.168.50.70:61208` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Tailscale | `http://hephaestus.tailaa3ef2.ts.net:61208` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Public | `https://dev.chrislawrence.ca/system` | ✅ | ✅ HTTP 302 | ⬜ | ⬜ | Redirect detected |

### Grafana
| Access Method | URL | Status | Connectivity | Favicon | Path/Subdomain | Notes |
|--------------|-----|--------|--------------|---------|----------------|-------|
| Local | `http://192.168.50.70:3000` | ✅ | ✅ HTTP 302 | ⬜ | ⬜ | Redirect detected |
| Tailscale | `http://hephaestus.tailaa3ef2.ts.net:3000` | ✅ | ✅ HTTP 302 | ⬜ | ⬜ | Redirect detected |
| Public | `https://dev.chrislawrence.ca/metrics` | ✅ | ✅ HTTP 302 | ⬜ | ⬜ | Redirect detected |
| Public (Monitor) | `https://monitor.chrislawrence.ca/grafana` | ✅ | ✅ HTTP 302 | ⬜ | ⬜ | Redirect detected |
| Public (IoT) | `https://iot.chrislawrence.ca/grafana` | ✅ | ✅ HTTP 302 | ⬜ | ⬜ | Redirect detected |

### Prometheus
| Access Method | URL | Status | Connectivity | Favicon | Path/Subdomain | Notes |
|--------------|-----|--------|--------------|---------|----------------|-------|
| Local | `http://192.168.50.70:9090` | ✅ | ✅ HTTP 302 | ⬜ | ⬜ | Redirect detected |
| Tailscale | `http://hephaestus.tailaa3ef2.ts.net:9090` | ✅ | ✅ HTTP 302 | ⬜ | ⬜ | Redirect detected |
| Public | `https://dev.chrislawrence.ca/prometheus` | ✅ | ✅ HTTP 302 | ⬜ | ⬜ | Redirect detected |
| Public (Monitor) | `https://monitor.chrislawrence.ca/prometheus` | ✅ | ✅ HTTP 302 | ⬜ | ⬜ | Redirect detected |

### cAdvisor
| Access Method | URL | Status | Connectivity | Favicon | Path/Subdomain | Notes |
|--------------|-----|--------|--------------|---------|----------------|-------|
| Local | `http://192.168.50.70:8080` | ✅ | ✅ HTTP 307 | ⬜ | ⬜ | Redirect detected |
| Tailscale | `http://hephaestus.tailaa3ef2.ts.net:8080` | ✅ | ✅ HTTP 307 | ⬜ | ⬜ | Redirect detected |
| Public | `https://dev.chrislawrence.ca/containers` | ✅ | ✅ HTTP 302 | ⬜ | ⬜ | Redirect detected |

### Node Exporter
| Access Method | URL | Status | Connectivity | Favicon | Path/Subdomain | Notes |
|--------------|-----|--------|--------------|---------|----------------|-------|
| Local | `http://192.168.50.70:9100` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Tailscale | `http://hephaestus.tailaa3ef2.ts.net:9100` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Public | N/A | - | - | - | - | Not in public config |

---

## Applications

### Portfolio
| Access Method | URL | Status | Connectivity | Favicon | Path/Subdomain | Notes |
|--------------|-----|--------|--------------|---------|----------------|-------|
| Local | `http://192.168.50.70:8110` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Tailscale | `http://hephaestus.tailaa3ef2.ts.net:8110` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Public | `https://portfolio.chrislawrence.ca` | ❌ | ❌ HTTP 502 | ⬜ | ⬜ | Bad Gateway - Service may be down |

### SchedShare
| Access Method | URL | Status | Connectivity | Favicon | Path/Subdomain | Notes |
|--------------|-----|--------|--------------|---------|----------------|-------|
| Local | `http://192.168.50.70:8130` | ✅ | ✅ HTTP 301 | ⬜ | ⬜ | Redirect detected |
| Tailscale | `http://hephaestus.tailaa3ef2.ts.net:8130` | ✅ | ✅ HTTP 301 | ⬜ | ⬜ | Redirect detected |
| Public | `https://schedshare.chrislawrence.ca` | ❌ | ❌ HTTP 502 | ⬜ | ⬜ | Bad Gateway - Service may be down |

### CapitolScope API
| Access Method | URL | Status | Connectivity | Favicon | Path/Subdomain | Notes |
|--------------|-----|--------|--------------|---------|----------------|-------|
| Local | `http://192.168.50.70:8120` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Tailscale | `http://hephaestus.tailaa3ef2.ts.net:8120` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Public | N/A | - | - | - | - | API only in local/tailscale |

### CapitolScope Frontend
| Access Method | URL | Status | Connectivity | Favicon | Path/Subdomain | Notes |
|--------------|-----|--------|--------------|---------|----------------|-------|
| Local | `http://192.168.50.70:8121` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Tailscale | `http://hephaestus.tailaa3ef2.ts.net:8121` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Public | `https://capitolscope.chrislawrence.ca` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |

### MagicPages Frontend
| Access Method | URL | Status | Connectivity | Favicon | Path/Subdomain | Notes |
|--------------|-----|--------|--------------|---------|----------------|-------|
| Local | `http://192.168.50.70:8101` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Tailscale | `http://hephaestus.tailaa3ef2.ts.net:8101` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Public | `https://magicpages.chrislawrence.ca` | ✅ | ✅ HTTP 302 | ⬜ | ⬜ | Redirect detected |

### MagicPages API
| Access Method | URL | Status | Connectivity | Favicon | Path/Subdomain | Notes |
|--------------|-----|--------|--------------|---------|----------------|-------|
| Local | `http://192.168.50.70:8100` | ✅ | ✅ HTTP 302 | ⬜ | ⬜ | Redirect detected |
| Tailscale | `http://hephaestus.tailaa3ef2.ts.net:8100` | ✅ | ✅ HTTP 302 | ⬜ | ⬜ | Redirect detected |
| Public | `https://magicpages-api.chrislawrence.ca` | ✅ | ✅ HTTP 302 | ⬜ | ⬜ | Redirect detected |

### EventSphere
| Access Method | URL | Status | Connectivity | Favicon | Path/Subdomain | Notes |
|--------------|-----|--------|--------------|---------|----------------|-------|
| Local | `http://192.168.50.70:8140` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Tailscale | `http://hephaestus.tailaa3ef2.ts.net:8140` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Public | `https://eventsphere.chrislawrence.ca` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |

---

## Development Tools

### n8n
| Access Method | URL | Status | Connectivity | Favicon | Path/Subdomain | Notes |
|--------------|-----|--------|--------------|---------|----------------|-------|
| Local | `http://192.168.50.70:5678` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Tailscale | `http://hephaestus.tailaa3ef2.ts.net:5678` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Public | `https://n8n.chrislawrence.ca` | ✅ | ✅ HTTP 302 | ⬜ | ⬜ | Redirect detected |

### Obsidian
| Access Method | URL | Status | Connectivity | Favicon | Path/Subdomain | Notes |
|--------------|-----|--------|--------------|---------|----------------|-------|
| Local | `http://192.168.50.70:8060` | ⚠️ | ✅ HTTP 401 | ⬜ | ⬜ | Requires authentication |
| Tailscale | `http://hephaestus.tailaa3ef2.ts.net:8060` | ⚠️ | ✅ HTTP 401 | ⬜ | ⬜ | Requires authentication |
| Public | `https://dev.chrislawrence.ca/notes` | ✅ | ✅ HTTP 302 | ⬜ | ⬜ | Redirect detected |

---

## Specialized Services

### Home Assistant
| Access Method | URL | Status | Connectivity | Favicon | Path/Subdomain | Notes |
|--------------|-----|--------|--------------|---------|----------------|-------|
| Local | `http://192.168.50.70:8154` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Tailscale | `http://hephaestus.tailaa3ef2.ts.net:8154` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Public | `https://iot.chrislawrence.ca/homeassistant` | ✅ | ✅ HTTP 302 | ⬜ | ⬜ | Redirect detected |

### MQTT Explorer
| Access Method | URL | Status | Connectivity | Favicon | Path/Subdomain | Notes |
|--------------|-----|--------|--------------|---------|----------------|-------|
| Local | `http://192.168.50.70:8152` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Tailscale | `http://hephaestus.tailaa3ef2.ts.net:8152` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Public | `https://iot.chrislawrence.ca/mqtt` | ✅ | ✅ HTTP 302 | ⬜ | ⬜ | Redirect detected |

### Node-RED
| Access Method | URL | Status | Connectivity | Favicon | Path/Subdomain | Notes |
|--------------|-----|--------|--------------|---------|----------------|-------|
| Local | `http://192.168.50.70:8155` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Tailscale | `http://hephaestus.tailaa3ef2.ts.net:8155` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Public | `https://iot.chrislawrence.ca/nodered` | ✅ | ✅ HTTP 302 | ⬜ | ⬜ | Redirect detected |

### InfluxDB
| Access Method | URL | Status | Connectivity | Favicon | Path/Subdomain | Notes |
|--------------|-----|--------|--------------|---------|----------------|-------|
| Local | `http://192.168.50.70:8157` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Tailscale | `http://hephaestus.tailaa3ef2.ts.net:8157` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Public | `https://iot.chrislawrence.ca/influxdb` | ✅ | ✅ HTTP 302 | ⬜ | ⬜ | Redirect detected |

### Open WebUI
| Access Method | URL | Status | Connectivity | Favicon | Path/Subdomain | Notes |
|--------------|-----|--------|--------------|---------|----------------|-------|
| Local | `http://192.168.50.70:8189` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Tailscale | `http://hephaestus.tailaa3ef2.ts.net:8189` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Public | `https://ai.chrislawrence.ca/webui` | ✅ | ✅ HTTP 302 | ⬜ | ⬜ | Redirect detected |

### OpenRouter Proxy
| Access Method | URL | Status | Connectivity | Favicon | Path/Subdomain | Notes |
|--------------|-----|--------|--------------|---------|----------------|-------|
| Local | `http://192.168.50.70:8190` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Tailscale | `http://hephaestus.tailaa3ef2.ts.net:8190` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Public | `https://ai.chrislawrence.ca/openrouter` | ✅ | ✅ HTTP 302 | ⬜ | ⬜ | Redirect detected |

### Minecraft Map
| Access Method | URL | Status | Connectivity | Favicon | Path/Subdomain | Notes |
|--------------|-----|--------|--------------|---------|----------------|-------|
| Local | `http://192.168.50.70:8159` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Tailscale | `http://hephaestus.tailaa3ef2.ts.net:8159` | ✅ | ✅ HTTP 200 | ⬜ | ⬜ | |
| Public | `https://minecraft-map.chrislawrence.ca` | ✅ | ✅ HTTP 302 | ⬜ | ⬜ | Redirect detected |
| Public (Alt) | `https://minecraft.chrislawrence.ca/map` | ✅ | ✅ HTTP 302 | ⬜ | ⬜ | Redirect detected |

### ComfyUI
| Access Method | URL | Status | Connectivity | Favicon | Path/Subdomain | Notes |
|--------------|-----|--------|--------------|---------|----------------|-------|
| Local | N/A | - | - | - | - | Not in local config |
| Tailscale | N/A | - | - | - | - | Not in tailscale config |
| Public | `https://ai.chrislawrence.ca/comfyui` | ✅ | ✅ HTTP 302 | ⬜ | ⬜ | Redirect detected |

### Model Manager
| Access Method | URL | Status | Connectivity | Favicon | Path/Subdomain | Notes |
|--------------|-----|--------|--------------|---------|----------------|-------|
| Local | N/A | - | - | - | - | Not in local config |
| Tailscale | N/A | - | - | - | - | Not in tailscale config |
| Public | `https://ai.chrislawrence.ca/models` | ✅ | ✅ HTTP 302 | ⬜ | ⬜ | Redirect detected |

---

## Issues Summary

### Connectivity Issues
- **Portfolio (Public)**: HTTP 502 Bad Gateway - Service may be down or not configured
- **SchedShare (Public)**: HTTP 502 Bad Gateway - Service may be down or not configured

### Favicon Issues
- All services need favicon verification (marked as ⬜)

### Path/Subdomain Issues
- All services need path/subdomain verification (marked as ⬜)

### Other Issues
- **Obsidian (Local/Tailscale)**: HTTP 401 - Requires authentication (expected behavior)
- Many services return HTTP 302/307 redirects - This is normal for login pages or HTTPS redirects 

---

## Fixes Applied

### Date: _______________
- 

### Date: _______________
- 

---

## Final Status

**Overall Completion**: ___ / ___ services tested

**Status Breakdown**:
- ✅ Fully Working: ___
- ⚠️ Partial/Issues: ___
- ❌ Not Working: ___
- ⬜ Not Tested: ___

**Dashboard Ready**: ⬜ Yes | ⬜ No | ⬜ Needs Review

---

