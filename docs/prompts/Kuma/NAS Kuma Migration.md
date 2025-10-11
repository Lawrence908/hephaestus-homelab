You are an expert in Proxmox, Docker, and homelab infrastructure design. 
I am migrating my Uptime Kuma monitoring setup from a Synology DS218+ NAS to a Dell OptiPlex 7040 tower (Intel i5-6500, 16 GB RAM, 250 GB SSD), which will serve as my main homelab and testing server.

Here’s my current environment:
- Previous host: Synology DS218+ running Docker natively (with Uptime Kuma)
- Current host: OptiPlex 7040 running Proxmox VE
- Planned virtualization layout:
    • LXC container for Uptime Kuma
    • LXC or VM for Docker Compose services (Portainer, Watchtower, etc.)
    • Optional future VMs for web servers, API backends, and ML projects
- Network: Static IP planned (192.168.50.60)
- Local access example: http://192.168.50.60:3001/
- SSH access from workstation using key-based auth
- Remote access domain: nasty.chrislawrence.ca (current DNS record)
- Will later migrate additional projects:
    • Magic Pages API
    • CapitolScope
    • Portfolio + SchedShare sites

Please help me plan and configure this migration by analyzing the following:
1. How to securely deploy Uptime Kuma in an LXC (vs Docker directly) on Proxmox.
2. Best practices for Proxmox network configuration and firewall rules (to isolate services and avoid exposing port 3001 publicly).
3. Recommended secure remote access approach (Tailscale, Cloudflare Tunnel, or Nginx reverse proxy with SSL).
4. How to integrate logging and monitoring (Grafana, Prometheus, Loki, or simpler alternatives) to track uptime, CPU, RAM, and disk usage across all containers.
5. Suggestions for automating Docker image updates and backups.
6. Recommendations for organizing future websites and APIs under consistent DNS, reverse proxy, and SSL management.
7. Optional: how to use the OptiPlex GPU slot for ML or inference workloads (I may repurpose an RTX 3080 from my main PC later).

Goal: Transition from a simple NAS Docker host to a modular, maintainable, and secure Proxmox-based environment capable of hosting multiple web apps and monitoring tools efficiently — while minimizing attack surface and maintenance complexity.
