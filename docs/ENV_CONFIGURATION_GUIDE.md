# ATS Server Environment Configuration Guide

## 📁 Files Overview

### `.env` 
Main configuration file containing all server settings. Located in the root directory.

### `scripts/load_env.bat`
Utility script that loads environment variables from the `.env` file into batch scripts.

### `scripts/env_manager.bat`
Interactive configuration manager for easily editing and managing environment settings.

## 🚀 Quick Start

1. **First Time Setup**
   ```bash
   # The .env file is automatically created with defaults
   # Run the main server manager:
   scripts\ats_server_manager.bat
   ```

2. **Edit Configuration**
   ```bash
   # Option 1: Use the built-in manager
   scripts\ats_server_manager.bat
   # Then select: E. Environment Configuration Manager
   
   # Option 2: Direct editing
   scripts\env_manager.bat
   
   # Option 3: Manual editing
   notepad .env
   ```

## ⚙️ Key Configuration Sections

### Server Identity
```ini
SERVER_NAME=Freddy's ATS Dedicated Server
SERVER_DESCRIPTION=Enhanced ATS server with curated sound and graphics mods
SERVER_PASSWORD=ruby
```

### Connection Settings
```ini
DEFAULT_SERVER_ID=90271602251410447
SERVER_TOKEN=15AE684920A1694E27BFA8B64F75AD1B
CONNECTION_DEDICATED_PORT=27015
QUERY_DEDICATED_PORT=27016
```

### Mod Management
```ini
COLLECTION_ID=3530633316
COLLECTION_URL=https://steamcommunity.com/sharedfiles/filedetails/?id=3530633316
AUTO_UPDATE_MODS=true
ENABLE_DYNAMIC_DOWNLOADS=true
```

### Game Settings
```ini
MAX_PLAYERS=8
PLAYER_DAMAGE=true
TRAFFIC=true
MODS_OPTIONING=true
```

### Directory Paths
```ini
SERVER_DIR=C:\Program Files (x86)\Steam\steamapps\common\American Truck Simulator Dedicated Server
GAME_DIR=C:\Program Files (x86)\Steam\steamapps\common\American Truck Simulator
WORKSHOP_DIR=C:\Program Files (x86)\Steam\steamapps\workshop\content\270880
```

## 🛠️ Environment Manager Features

### Main Functions
- **View Current Configuration** - See all loaded settings
- **Edit Configuration** - Open in Notepad or VS Code
- **Backup/Restore** - Automatic timestamped backups
- **Validate Configuration** - Check for errors and missing settings
- **Quick Settings Wizard** - Guided configuration for key settings
- **Reset to Defaults** - Restore original configuration

### Advanced Features
- **Export/Import** - Share configurations between setups
- **Configuration Validation** - Ensure all required settings are present
- **Path Verification** - Check if configured directories exist
- **Automatic Backups** - Before any major changes

## 🔧 How It Works

1. **Loading Process**
   - Scripts check for `.env` file in root directory
   - `load_env.bat` parses the file and sets environment variables
   - If no `.env` file exists, fallback defaults are used

2. **Variable Usage**
   - All scripts use environment variables instead of hardcoded values
   - Changes to `.env` file take effect on next script run
   - Environment manager can reload settings without restart

3. **Backup System**
   - Automatic backups before configuration changes
   - Timestamped backup files in `env_backups/` directory
   - Easy restoration from any previous backup

## 📝 Customization Examples

### Change Server Name and Password
```ini
SERVER_NAME=My Custom ATS Server
SERVER_PASSWORD=mypassword123
```

### Use Different Steam Collection
```ini
COLLECTION_ID=1234567890
COLLECTION_URL=https://steamcommunity.com/sharedfiles/filedetails/?id=1234567890
```

### Adjust Server Capacity
```ini
MAX_PLAYERS=16
MAX_VEHICLES_TOTAL=200
MAX_AI_VEHICLES_PLAYER=100
```

### Custom Installation Paths
```ini
SERVER_DIR=D:\ATS_Server
GAME_DIR=D:\Games\ATS
WORKSHOP_DIR=D:\Steam\Workshop\ATS
```

## 🚨 Important Notes

### Required Settings
These settings must be configured for the server to work:
- `SERVER_TOKEN` - Steam server authentication token
- `DEFAULT_SERVER_ID` - Unique server identifier
- `COLLECTION_ID` - Steam Workshop collection for mods

### Path Configuration
- Use full absolute paths for directories
- Paths with spaces should work correctly (already quoted in scripts)
- Verify paths exist before starting server

### Backup Strategy
- Environment manager automatically backs up before changes
- Manual backups recommended before major modifications
- Keep backups of working configurations

## 🎯 Integration with Scripts

### Main Server Manager
- Loads `.env` on startup
- Shows current configuration in header
- Option E opens environment manager
- Automatically reloads config after changes

### Mod Collection Utility
- Uses collection settings from `.env`
- Respects download and path preferences
- Shares configuration with main script

### All Scripts
- Consistent configuration across all tools
- Single source of truth for settings
- Easy maintenance and updates

## 🔍 Troubleshooting

### Configuration Not Loading
1. Check if `.env` file exists in root directory
2. Verify file format (key=value pairs)
3. Check for special characters in values
4. Use environment manager validation feature

### Settings Not Taking Effect
1. Restart the script after changes
2. Check for syntax errors in `.env` file
3. Verify variable names match exactly
4. Use environment manager to validate configuration

### Path Issues
1. Use absolute paths (not relative)
2. Ensure directories exist
3. Check for typos in path names
4. Use environment manager path verification

This system provides centralized, easy-to-manage configuration for all your ATS server scripts! 🎮
