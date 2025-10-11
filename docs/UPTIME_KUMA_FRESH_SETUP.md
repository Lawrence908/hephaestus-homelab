# Uptime Kuma Fresh Setup Guide

## ✅ **Database Reset Complete**

Your Uptime Kuma is now running with a fresh database. The problematic migrated database has been removed.

## 🚀 **Next Steps**

### 1. **Access Uptime Kuma**
- **URL**: http://192.168.50.60:3001
- **Remote**: https://nasty.chrislawrence.ca (via Cloudflare Tunnel)

### 2. **Initial Setup**
1. **Create Admin Account**: Set up your admin username and password
2. **Configure Settings**: Set your timezone and preferences

### 3. **Restore Your Monitors**

You have a backup JSON file with all your monitor configurations:
- **File**: `/home/chris/github/hephaestus-homelab/docs/prompts/Kuma/Uptime_Kuma_Backup_2025_10_11-05_46_09.json`

#### **Monitors to Recreate:**

1. **NASty**
   - URL: `http://192.168.50.50:5000`
   - Interval: 60 seconds
   - Timeout: 48 seconds

2. **Portfolio**
   - URL: `https://chrislawrence.ca`
   - Interval: 367 seconds
   - Timeout: 48 seconds

3. **SchedShare**
   - URL: `https://schedshare.chrislawrence.ca`
   - Interval: 313 seconds
   - Timeout: 48 seconds

4. **CapitolScope**
   - URL: `https://capitolscope.chrislawrence.ca`
   - Interval: 271 seconds
   - Timeout: 48 seconds

5. **Magic Pages**
   - URL: `https://magicpages.com`
   - Interval: 227 seconds
   - Timeout: 48 seconds

6. **Magic Pages API**
   - URL: `https://api.magicpages.com`
   - Interval: 30 seconds
   - Timeout: 12 seconds
   - **Authentication**: Basic Auth
   - **Username**: `admin`
   - **Password**: `h4wReZE49Hc_bzx`

### 4. **Configure Notifications**

Set up Telegram notifications:
- **Bot Token**: `8086325742:AAFkc5DZI6bShSqKVUUY_WYaf__fUJPcy5I`
- **Chat ID**: `7062419334`

## 🔧 **Manual Setup Process**

1. **Login** to Uptime Kuma
2. **Add Monitors** one by one using the details above
3. **Configure Notifications** → Telegram
4. **Test** each monitor to ensure they're working
5. **Verify** Telegram notifications are working

## 📋 **Benefits of Fresh Setup**

- ✅ Clean database without migration issues
- ✅ Proper user authentication
- ✅ All features working correctly
- ✅ Easy to configure and maintain

## 🎯 **Quick Commands**

```bash
# Check Uptime Kuma status
ustatus

# View logs
ulog

# Restart if needed
urestart
```

Your Uptime Kuma is now ready for a fresh, clean setup! 🎉
