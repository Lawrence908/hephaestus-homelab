# Battlefield 6 Server Setup Prompt (Future)

Use this prompt verbatim when ready to provision a Battlefield 6 dedicated server on a more powerful host. Assumes Ubuntu 24.04 and Docker. Uses `docker compose` as preferred.

---

Goal: Provision a Battlefield 6 dedicated server on Ubuntu 24.04 with Docker.

Context:
- Hostname: Powerful new host (public IP with router control for UDP forwards)
- Current homelab uses Cloudflare Tunnel for HTTP services — game UDP must bypass Cloudflare Tunnel
- Infra repo: `~/github/hephaestus-homelab/` (do not modify infra here)
- Apps live under `~/apps/` — create `~/apps/bf6-server/`
- Align with `docs/PORTS.md`, `docs/ROUTING.md`, `docs/STRUCTURE.md`, `docs/SERVER_CONTEXT.md`

Requirements:
1) Recommend CPU/RAM/disk/network for 32/64/128 player slots; pick sensible defaults for 64 and 128.
2) Reserve and document a UDP port block in `docs/PORTS.md` dedicated to BF6 (20–50 ports).
3) Provide production-ready `docker-compose.yml` at `~/apps/bf6-server/`:
   - Prefer official BF6 server image if released; otherwise SteamCMD/LinuxGSM pattern
   - Host networking for lowest latency, or explicit UDP maps with pros/cons
   - Volumes for configs, logs, and binaries
   - Healthcheck, restart policy, CPU pinning, memory limits
4) OS/network tunings for low-latency UDP:
   - sysctl: `net.core.rmem_max`, `net.core.wmem_max`, `net.ipv4.udp_rmem_min`, `net.ipv4.udp_wmem_min`, `net.core.netdev_max_backlog`
   - Optional: IRQ balance, CPU isolation hints, process priority (`SYS_NICE`)
5) Player slots:
   - Show where to set player cap and tickrate; defaults per hardware tier
   - How to scale slots later without wiping state
6) Networking:
   - List all UDP ports to forward on the router
   - UFW rules to allow only those UDP ports
   - Note NAT hairpin and basic rate-limit guidance
7) Monitoring:
   - Uptime Kuma checks (query/heartbeat if available)
   - Log rotation and paths
8) If no official dedicated server exists:
   - Provide contingency: Windows VM or bare-metal, anti-cheat caveats
   - Keep same directory and port plan for easy migration
9) Output deliverables:
   - Final `docker-compose.yml`
   - Example `.env` (no secrets)
   - One-time setup commands and sysctl snippet
   - Router/UFW rules
   - Documentation update notes for `PORTS.md` and `ROUTING.md` (UDP bypasses Caddy/Cloudflare)

Assumptions to verify:
- Public IP and router port-forward control
- No EAC/BE restrictions forbidding container execution
- Storage is SSD/NVMe
- Host networking is acceptable

Deliverables:
- All files/commands ready to run, minimal manual edits, plus a short runbook for start/stop/update.

---

Recommended specs by slots (guidance):
- 32 players: 4 vCPU (3.5+ GHz), 8–12 GB RAM, SSD, 25 Mbps up
- 64 players: 8 vCPU (high clock), 16–24 GB RAM, NVMe, 50–100 Mbps up
- 128 players: 12–16 vCPU, 32–48 GB RAM, fast NVMe, 150–300+ Mbps up

Docker image guidance (until official release):
- Steam-based: use `cm2network/steamcmd` base with bootstrap to install server
- Or LinuxGSM if supported at release: `gameservermanagers/linuxgsm-docker`
- Avoid unmaintained images; expose UDP ports explicitly if not using host networking

Networking notes:
- Do not place game UDP behind Cloudflare Tunnel; forward UDP directly router → server LAN IP
- Reserve a UDP range (e.g., `27000-27100/udp`) in `docs/PORTS.md`
- Note in `docs/ROUTING.md` that game servers bypass Caddy/Cloudflare


