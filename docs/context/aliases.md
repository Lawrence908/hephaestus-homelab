## 📁 Files Created/Modified:

1. **`/home/chris/.docker_aliases`** - Complete aliases file with all your services
2. **`/home/chris/.bashrc`** - Updated to source the aliases file

## 🚀 Key Aliases for Your Services:

### **Logging (Follow logs):**
- `clog` - Caddy logs
- `glog` - Grafana logs  
- `plog` - Prometheus logs
- `ulog` - Uptime Kuma logs
- `mplog` - Magic Pages API logs
- `cslog` - CapitolScope logs
- `sslog` - SchedShare logs
- `ptlog` - Portfolio logs

### **Restart Services:**
- `crestart` - Restart Caddy
- `grestart` - Restart Grafana
- `prestart` - Restart Prometheus
- `urestart` - Restart Uptime Kuma
- `mprestart` - Restart Magic Pages API
- `csrestart` - Restart CapitolScope
- `ssrestart` - Restart SchedShare
- `ptrestart` - Restart Portfolio

### **Service Status:**
- `allstatus` - Show all services status
- `healthcheck` - Check service health
- `cstatus`, `gstatus`, `mpstatus` - Individual service status

### **Management:**
- `startall` - Start all services
- `stopall` - Stop all services  
- `restartall` - Restart all services
- `homelab` - Navigate to project directory

## 🔧 To Use:

1. **Reload your shell** to activate the aliases:
   ```bash
   source ~/.bashrc
   ```

2. **Test the aliases:**
   ```bash
   docker-help          # Show all available commands
   show-aliases         # List all aliases
   allstatus           # Check all services
   healthcheck         # Test service health
   ```

3. **Example usage:**
   ```bash
   glog                 # Follow Grafana logs
   grestart            # Restart Grafana
   clog                # Follow Caddy logs
   ```

The aliases are organized by service type (infrastructure, monitoring, applications) and include both individual service management and bulk operations.