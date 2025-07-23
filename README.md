# Freddy's ATS Server Manager v1.0.0

## Overview
**🎉 NEW UNIFIED VERSION! 🎉**

All previous batch files have been consolidated into a single, powerful server manager located in the `scripts/` directory. This unified solution simplifies running and managing your American Truck Simulator dedicated server with Steam Workshop mod integration.

## Server Details
- **Server Name**: Freddy's ATS Dedicated Server  
- **Password**: ruby
- **Max Players**: 8
- **Optional Mods**: Enabled
- **Server Token**: 15AE684920A1694E27BFA8B64F75AD1B
- **Workshop Collection**: [Steam Collection](https://steamcommunity.com/sharedfiles/filedetails/?id=3530633316)

## Quick Start Guide

### 🚀 **One-Command Setup**
1. Navigate to: `scripts/ats_server_manager.bat`
2. **Double-click** or run the script
3. **Choose Option 1** - Quick Start (Setup + Update + Start)
4. Done! Your server will be fully configured and running

### 📋 **Manual Setup (if needed)**
1. **Choose Option 2** - Setup Server Environment (first time only)
2. **Export Server Packages**: 
   - Start ATS game
   - Press `~` for console
   - Type: `export_server_packages`
   - Close game
3. **Choose Option 3** - Update Workshop Mods
4. **Choose Option 4** - Start Server

## 🎛️ **Available Options**

### **Main Menu**
1. **Quick Start** - Complete automated setup
2. **Setup Server Environment** - Initialize server configuration
3. **Update Workshop Mods** - Sync from Steam Workshop collection
4. **Start Server Only** - Launch dedicated server
5. **Start Server + Game Client** - Launch server and auto-connect game
6. **Server Status & Diagnostics** - Comprehensive health check
7. **Stop All Servers** - Clean shutdown
8. **Workshop Collection Manager** - Manage Steam mods
9. **Advanced Configuration** - Edit settings, tokens, etc.
A. **Archive Old Scripts & Cleanup** - Maintain clean workspace
0. **Exit**

### **🔧 Diagnostics & Troubleshooting**
The built-in diagnostic system checks:
- ✅ Server installation and files
- ✅ Configuration format and settings
- ✅ Mod directory and file integrity
- ✅ Workshop collection status
- ✅ Server packages availability

### **🛠️ Quick Fixes Available**
- **Fix Server Configuration** - Recreate config with proper format
- **Test Server Without Mods** - Isolate mod-related issues
- **View Current Config** - Inspect configuration file
- **Backup Current Config** - Save configurations with timestamps

## 📁 **New Clean File Structure**
```
ats/
├── scripts/
│   ├── ats_server_manager.bat    # 🎯 MAIN UNIFIED SCRIPT
│   └── deployment/               # Deployment tools
├── archive/                      # 📦 Old batch files (safely stored)
├── config/                       # Server configuration backups
├── docs/                         # Documentation
└── README.md                     # This file
```

## 🏆 **Key Improvements in v1.0.0**

### **🎯 Unified Experience**
- **Single script** replaces 15+ individual batch files
- **Consistent interface** with clear menu navigation
- **Integrated diagnostics** and troubleshooting

### **🔧 Enhanced Reliability**
- **Better error handling** and status checking
- **Automatic backup** of configurations
- **Multi-approach testing** for compatibility issues

### **🚀 Streamlined Workflow**
- **Quick Start option** for immediate setup
- **Smart detection** of existing configurations
- **Automated cleanup** and workspace organization

## 🎮 **Workshop Collection Mods**
Your curated collection includes:
- **Sound Fixes Pack v25.31** - Enhanced immersive sounds
- **Cummins N14 Sound & Engine Pack** - Realistic engine sounds  
- **Air Brake Sound Mod** - Authentic air brake sounds
- **JC Amateur Sound Effects Pack** - Additional truck sounds
- **Real companies, gas stations & billboards** - Realistic branding
- **Real Eaton Fuller Transmissions** - Authentic transmission options
- **Realistic Graphics & Weather** - Enhanced visuals
- **SiSL's Mega Pack** - 400+ cabin accessories
- **Physics & Lighting Improvements** - Enhanced realism
- And many more enhancement mods!

## 🆘 **Troubleshooting**

### **Server Won't Start**
1. **Run Diagnostics** (Option 6) to identify issues
2. **Check server packages** - Export from game if missing
3. **Verify Steam Workshop** mods are downloaded

### **Mods Not Loading**
1. **Use Quick Fix** (F option in Diagnostics)
2. **Test without mods** (T option in Diagnostics) to isolate issues
3. **Check mod file integrity** in diagnostics

### **Connection Issues**
1. **Verify server is running** (Option 6)
2. **Check firewall** settings for ports 27015-27016
3. **Confirm password** is "ruby"

## ⚡ **Advanced Usage**

### **Custom Server ID**
Run with custom server ID: 
```bash
ats_server_manager.bat YOUR_SERVER_ID
```

### **Configuration Management**
- **Edit configs manually** (Option 9 → 1)
- **Change server token** (Option 9 → 2)
- **Create timestamped backups** (Option 9 → 5)

### **Automation**
The script supports silent operation for automation:
- Functions can be called with `SILENT` variable set
- Exit codes indicate success/failure status
- Logging available for automated deployments

## 📋 **Migration from Old Scripts**
All your previous batch files have been safely moved to the `archive/` directory:
- ✅ **Preserved** - Nothing was deleted
- ✅ **Organized** - Clean workspace maintained  
- ✅ **Accessible** - Archive available if needed

## 🎉 **What's Next?**
1. **Run the new unified script**: `scripts/ats_server_manager.bat`
2. **Try Quick Start** for immediate results
3. **Explore the diagnostics** to understand your server health
4. **Enjoy your enhanced ATS multiplayer experience!**

---

*Happy trucking with your enhanced server setup! 🚛*
