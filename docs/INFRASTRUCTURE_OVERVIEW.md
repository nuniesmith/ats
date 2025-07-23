# ATS Server Infrastructure Overview
# ===================================

## 🏗️ **Infrastructure Architecture**

```
GitHub Actions (Self-hosted) ←→ Linode Server (Public IP) ←→ Tailscale Network
     ↓                              ↓                           ↓
  Build & Deploy                ATS Dedicated Server        Private Access Only
  Public IP Access              Windows/Linux Server        Cloudflare DNS → Tailscale IP
  Uses Secrets for Auth         SSH via Public IP           Web Interface via VPN
```

## 🔐 **Access Strategy**

### **GitHub Actions → Server**
- **Connection**: Public IP (required for GitHub hosted runners)
- **Authentication**: SSH with `ACTIONS_USER_PASSWORD`
- **Purpose**: Deploy code, update server, manage services

### **Cloudflare DNS → Server**
- **Points to**: Tailscale IP (private network)
- **Purpose**: Route `ats.7gram.xyz` to server via VPN
- **Access**: Requires Tailscale VPN connection

### **Users → Server**
- **Connection**: Via `ats.7gram.xyz` (resolves to Tailscale IP)
- **Requirement**: Must be connected to Tailscale VPN
- **Security**: Server only accessible through private network

## 🌐 **DNS Configuration**

```
Domain: ats.7gram.xyz
├── Public DNS (Cloudflare): Points to Tailscale IP
├── Tailscale Network: 100.x.x.x IP range
└── Server Access: Only via VPN tunnel
```

## 🚀 **Deployment Process**

1. **GitHub Actions Workflow Triggers**
2. **Check for Existing Linode Server** (via `LINODE_TOKEN`)
3. **If Server Exists**:
   - Connect to server via **Public IP** (SSH access)
   - Deploy web application files
   - Connect to **Tailscale Network**
   - Get server's **Tailscale IP**
   - Update **Cloudflare DNS** → Point `ats.7gram.xyz` to Tailscale IP
4. **Result**: Web interface accessible only via VPN

## 📋 **Secret Usage Mapping**

| Secret | Usage | Access Method |
|--------|-------|---------------|
| `LINODE_TOKEN` | Check/manage servers | Linode CLI API |
| `ATS_ROOT_PASSWORD` | Server root access | SSH to public IP |
| `ACTIONS_USER_PASSWORD` | Deploy user access | SSH to public IP |
| `TAILSCALE_AUTH_KEY` | Join private network | Tailscale connect |
| `CLOUDFLARE_API_TOKEN` | Update DNS records | Cloudflare API |
| `CLOUDFLARE_ZONE_ID` | DNS zone management | Cloudflare API |
| `DOMAIN_NAME` | Target domain | DNS update |
| `ATS_SERVER_TOKEN` | Steam server auth | ATS server config |
| `ATS_DEFAULT_PASSWORD` | ATS server password | Player connections |
| `STEAM_COLLECTION_ID` | Workshop mods | Steam API |
| `DISCORD_WEBHOOK_URL` | Deployment notifications | Discord API |
| `DISCORD_BOT_TOKEN` | Advanced Discord features | Discord Bot API |
| `NETDATA_CLAIM_TOKEN` | Server monitoring | Netdata service |
| `NETDATA_CLAIM_ROOM` | Monitoring dashboard | Netdata service |

## 🔧 **Server Configuration**

### **User Accounts**
- `root` - Server administration (password: `ATS_ROOT_PASSWORD`)
- `actions` - GitHub Actions deployment (password: `ACTIONS_USER_PASSWORD`)

### **Network Setup**
- **Public IP**: For GitHub Actions SSH access
- **Tailscale IP**: For user web interface access  
- **DNS**: `ats.7gram.xyz` → Tailscale IP

### **Services Running**
- ATS Dedicated Server (Steam)
- Web Interface (React + Node.js API)
- Nginx (Web server)
- Tailscale (VPN client)
- Netdata (Monitoring)

## 🎯 **Security Model**

```
Public Internet
    ↓
GitHub Actions (Deploy) → Public IP → Server
    ↓
Tailscale VPN Network
    ↓
Users → ats.7gram.xyz → Tailscale IP → Web Interface
```

**Key Security Features**:
- ✅ Web interface only accessible via VPN
- ✅ GitHub Actions uses dedicated user account
- ✅ All passwords stored as GitHub Secrets
- ✅ DNS points to private IP range
- ✅ Server monitoring with Netdata

## 🚀 **Getting Started**

1. **All secrets are configured** ✅
2. **GitHub Actions will**:
   - Check for existing server
   - Deploy if server exists
   - Update DNS to point to VPN IP
3. **Users need**:
   - Tailscale VPN invitation
   - Access to `ats.7gram.xyz` domain

Your infrastructure is **ready to deploy**! 🎉
