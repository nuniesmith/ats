# Freddy's ATS Complete Manager

## Overview

The **ATS Complete Manager** is a comprehensive Windows batch script launcher that provides unified management for American Truck Simulator (ATS) game, dedicated server, Steam packages, and workshop mods. This tool simplifies the entire ATS ecosystem management from a single interface.

## Features

### 🎮 Game Management
- **Launch ATS Game**: Direct game launcher with fallback to Steam
- **Launch ATS with Mods**: Opens Steam Workshop and launches game with mod support
- **Launch Steam**: Quick access to ATS Steam library page

### 🖥️ Server Management
- **Quick Server Start**: Fast dedicated server launch with pre-configured settings
- **Advanced Server Manager**: Full-featured server management interface
- **Server Status Check**: Real-time monitoring of running ATS processes
- **Stop All Servers**: Safe shutdown of all ATS processes

### 📦 Steam Package Management
- **Install/Update ATS Game**: Automated game installation via SteamCMD
- **Install/Update Dedicated Server**: Server installation and updates
- **Workshop Collection Download**: Automatic mod collection management
- **SteamCMD Management**: Complete SteamCMD installation and management

### 🔧 Utilities
- **Environment Configuration**: Easy configuration file management
- **Desktop Shortcuts**: Automated desktop shortcut creation
- **System Diagnostics**: Comprehensive system health checks
- **Help & Documentation**: Built-in help system

## Quick Start

### Desktop Usage (Recommended)
1. Run `launch_server_manager.bat` from the project root
2. Select option **D** to create desktop shortcuts
3. Use the created desktop shortcuts for daily management:
   - **🚛 ATS Complete Manager** - Main interface
   - **🖥️ ATS Quick Server** - Fast server start
   - **🎮 ATS Game** - Direct game launcher

### First-Time Setup
1. Launch the **ATS Complete Manager**
2. If you don't have ATS installed:
   - Select option **8** to install ATS Game
   - Select option **9** to install ATS Dedicated Server
3. Select option **A** to download workshop mods
4. Select option **D** to create desktop shortcuts
5. Select option **E** to run system diagnostics

## Menu Options

| Option | Function | Description |
|--------|----------|-------------|
| **1** | Launch ATS Game | Start the game directly or via Steam |
| **2** | Launch ATS with Mods | Open workshop and launch with mod support |
| **3** | Launch Steam | Open Steam ATS library page |
| **4** | Quick Server Start | Fast dedicated server launch |
| **5** | Advanced Server Manager | Full server management interface |
| **6** | Check Server Status | Monitor running ATS processes |
| **7** | Stop All Servers | Safe shutdown of all ATS processes |
| **8** | Install/Update ATS Game | Automated game installation |
| **9** | Install/Update Dedicated Server | Server installation and updates |
| **A** | Download Workshop Collection | Mod collection management |
| **B** | Manage SteamCMD | SteamCMD installation and management |
| **C** | Environment Configuration | Edit configuration settings |
| **D** | Create Desktop Shortcuts | Generate desktop shortcuts |
| **E** | System Diagnostics | Comprehensive system check |
| **F** | Help & Documentation | Built-in help system |

## System Requirements

### Minimum Requirements
- **OS**: Windows 10/11
- **Storage**: 50GB+ free space
- **Network**: Internet connection for downloads
- **Software**: PowerShell (usually pre-installed)

### Optional Requirements
- **Steam**: For game launching and workshop mods
- **SteamCMD**: Automatically installed by the launcher
- **ATS Game**: Can be installed via the launcher
- **ATS Dedicated Server**: Can be installed via the launcher

## Installation

### Method 1: Simple Desktop Link
1. Download or clone the repository
2. Right-click `launch_server_manager.bat` → "Create shortcut"
3. Move the shortcut to your desktop
4. Rename to "ATS Complete Manager"
5. Double-click to launch

### Method 2: Full Setup with Shortcuts
1. Run `launch_server_manager.bat`
2. Select option **D** (Create Desktop Shortcuts)
3. Choose to organize shortcuts in a folder (recommended)
4. Use the generated shortcuts for daily management

## Configuration

### Environment Configuration
The launcher uses a `.env` file for configuration. Key settings include:

```env
# Game Paths
GAME_DIR=C:\Program Files (x86)\Steam\steamapps\common\American Truck Simulator
SERVER_DIR=C:\Program Files (x86)\Steam\steamapps\common\American Truck Simulator Dedicated Server
WORKSHOP_DIR=C:\Program Files (x86)\Steam\steamapps\workshop\content\270880

# Steam Configuration
STEAM_EXE=C:\Program Files (x86)\Steam\steam.exe

# Server Configuration
SERVER_NAME=Freddy's ATS Dedicated Server
SERVER_PASSWORD=ruby
COLLECTION_ID=3530633316
```

### Editing Configuration
- Use option **C** in the main menu
- Or manually edit `.env` file in the project root
- Run diagnostics (option **E**) to verify changes

## Troubleshooting

### Common Issues

**"Game not found" Error**
- Install ATS via option **8** or through Steam directly
- Check paths in configuration (option **C**)
- Run diagnostics (option **E**) to identify issues

**"Server won't start" Error**
- Install ATS Dedicated Server via option **9**
- Check if ports are available (27015, 27016)
- Ensure no other servers are running

**"Steam not found" Error**
- Install Steam from https://store.steampowered.com/
- Update Steam path in configuration
- Use direct game launcher instead

**"SteamCMD issues" Error**
- Use option **B** to reinstall SteamCMD
- Check internet connection
- Run as administrator if needed

### Diagnostic Tools
- **Option E**: Comprehensive system diagnostics
- **Option 6**: Check running processes
- Check individual script logs in `/scripts` folder

## Advanced Usage

### Command Line Arguments
The launcher accepts the same arguments as the underlying ATS server manager:
```cmd
launch_server_manager.bat [server_id]
```

### Integration with Other Tools
- Works with existing ATS server scripts
- Compatible with Steam Workshop collections
- Integrates with SteamCMD for package management

### Customization
- Modify individual scripts in `/scripts` folder
- Add custom shortcuts via the shortcut creator
- Extend environment configuration as needed

## File Structure

```
ats-main/
├── launch_server_manager.bat          # Main launcher (THIS FILE)
├── .env                               # Configuration file
└── scripts/
    ├── ats_server_manager.bat         # Advanced server manager
    ├── steam_package_installer.bat    # Steam package installer
    ├── create_desktop_shortcuts.bat   # Shortcut creator
    ├── system_diagnostics.bat         # System diagnostics
    ├── start_ats_dedicated_server.bat # Quick server starter
    ├── env_manager.bat                # Environment manager
    ├── load_env.bat                   # Environment loader
    └── steamcmd/                      # SteamCMD installation
```

## Support

### Getting Help
1. Use option **F** in the main menu for built-in help
2. Run diagnostics (option **E**) to identify issues
3. Check `/docs` folder for detailed documentation
4. Report issues on the project's GitHub repository

### Common Solutions
- **Permissions**: Run as administrator if file access issues occur
- **Paths**: Use absolute paths in configuration files
- **Updates**: Use Steam package installer to update components
- **Mods**: Subscribe to workshop collection via Steam first

## Version History

### v2.0 (Current)
- Complete rewrite with unified interface
- Added Steam package management
- Integrated desktop shortcut creation
- Added comprehensive diagnostics
- Improved error handling and user experience

### v1.0 (Legacy)
- Basic launcher functionality
- Simple server manager integration

## License

This tool is provided as-is for managing American Truck Simulator setups. Please ensure you own legitimate copies of any games or software managed by this tool.

---

**Created by**: Freddy's ATS Team  
**Last Updated**: July 2025  
**Compatible with**: ATS 1.50+, Windows 10/11
