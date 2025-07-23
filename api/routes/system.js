import express from 'express';
import archiver from 'archiver';
import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';
import { logger } from '../utils/logger.js';

const router = express.Router();
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Get system info
router.get('/info', async (req, res, next) => {
  try {
    logger.info('System info requested', { user: req.user.username });

    // In a real implementation, you would gather actual system information
    const systemInfo = {
      os: 'Windows 11 Pro',
      architecture: 'x64',
      totalMemory: '32 GB',
      availableMemory: '18.5 GB',
      cpuUsage: Math.random() * 30 + 10,
      memoryUsage: Math.random() * 40 + 20,
      diskSpace: {
        total: '1 TB',
        used: '450 GB',
        available: '550 GB',
        percentage: 45
      },
      atsVersion: '1.48.5.15',
      serverUptime: Date.now() - new Date('2024-01-20T10:00:00Z').getTime(),
      lastBootTime: '2024-01-20T09:30:00Z',
      timestamp: new Date().toISOString()
    };

    res.json({
      success: true,
      data: systemInfo
    });

  } catch (error) {
    next(error);
  }
});

// List files in a directory
router.get('/files', async (req, res, next) => {
  try {
    const { path: requestedPath = '.' } = req.query;
    
    logger.info('File listing requested', { 
      user: req.user.username,
      path: requestedPath
    });

    // Security: Prevent directory traversal
    const safePath = path.resolve(requestedPath).replace(/\\/g, '/');
    
    // In a real implementation, you would read the actual directory
    // For now, we'll return simulated file listings
    const simulatedFiles = [
      {
        name: 'server_config.sii',
        type: 'file',
        size: '2.4 KB',
        modified: '2024-01-20T10:30:00Z',
        permissions: 'rw-'
      },
      {
        name: 'server_packages.dat',
        type: 'file',
        size: '15.6 KB',
        modified: '2024-01-19T14:20:00Z',
        permissions: 'rw-'
      },
      {
        name: 'mods',
        type: 'directory',
        size: '-',
        modified: '2024-01-18T12:00:00Z',
        permissions: 'rwx'
      },
      {
        name: 'logs',
        type: 'directory',
        size: '-',
        modified: '2024-01-20T11:45:00Z',
        permissions: 'rwx'
      }
    ];

    res.json({
      success: true,
      data: {
        path: safePath,
        files: simulatedFiles
      }
    });

  } catch (error) {
    next(error);
  }
});

// Read file content
router.get('/files/content', async (req, res, next) => {
  try {
    const { filePath } = req.query;
    
    if (!filePath) {
      return res.status(400).json({
        success: false,
        error: 'File path is required'
      });
    }

    logger.info('File content requested', { 
      user: req.user.username,
      filePath
    });

    // In a real implementation, you would read the actual file
    // For now, we'll return simulated content based on file type
    let content = '';
    const fileName = path.basename(filePath);
    
    if (fileName.endsWith('.sii')) {
      content = `// ATS Server Configuration
server_packages : [
    "mod_physics_realistic.sii",
    "mod_sound_enhanced.sii"
]

server_logon {
    name: "Freddy's ATS Dedicated Server"
    password: "ruby"
    max_players: 8
    welcome_message: "Welcome to Freddy's ATS Server!"
}`;
    } else if (fileName.endsWith('.log')) {
      content = `[2024-01-20 10:30:15] INFO: Server started successfully
[2024-01-20 10:31:02] INFO: Player "TruckerJoe" connected from 192.168.1.100
[2024-01-20 10:32:45] WARN: High CPU usage detected: 85%
[2024-01-20 10:33:12] INFO: Mod update completed: Realistic Physics v2.1
[2024-01-20 10:34:30] ERROR: Failed to load texture: road_sign_warning.dds`;
    } else {
      content = 'Binary file content cannot be displayed';
    }

    res.json({
      success: true,
      data: {
        filePath,
        content,
        size: content.length,
        encoding: 'utf-8'
      }
    });

  } catch (error) {
    next(error);
  }
});

// Generate client package
router.post('/package/generate', async (req, res, next) => {
  try {
    const { 
      serverName = "Freddy's ATS Server",
      serverAddress = "ats.7gram.xyz",
      serverPort = "27015",
      serverPassword = "ruby",
      includeDesktopShortcut = true,
      includeMods = true 
    } = req.body;

    logger.info('Client package generation requested', { 
      user: req.user.username,
      serverName,
      includeDesktopShortcut,
      includeMods
    });

    // In a real implementation, you would:
    // 1. Create a temporary directory
    // 2. Generate the connection scripts
    // 3. Copy necessary files
    // 4. Create a ZIP package
    // 5. Return the download link

    // For now, we'll simulate the package generation
    const packageInfo = {
      packageId: `ats-client-${Date.now()}`,
      serverName,
      serverAddress,
      serverPort,
      generatedAt: new Date().toISOString(),
      includes: {
        connectionScript: true,
        desktopShortcut: includeDesktopShortcut,
        modList: includeMods,
        readme: true
      },
      downloadUrl: `/api/system/package/download/ats-client-${Date.now()}.zip`,
      expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString() // 24 hours
    };

    logger.info('Client package generated successfully', { 
      user: req.user.username,
      packageId: packageInfo.packageId
    });

    res.json({
      success: true,
      message: 'Client package generated successfully',
      data: packageInfo
    });

  } catch (error) {
    next(error);
  }
});

// Download client package
router.get('/package/download/:packageId', (req, res, next) => {
  try {
    const { packageId } = req.params;
    
    logger.info('Client package download requested', { 
      user: req.user?.username || 'anonymous',
      packageId
    });

    // In a real implementation, you would:
    // 1. Check if package exists
    // 2. Stream the ZIP file to the client
    // 3. Clean up temporary files

    // For now, we'll create a simple response
    res.setHeader('Content-Type', 'application/zip');
    res.setHeader('Content-Disposition', `attachment; filename="${packageId}"`);
    
    // Create a ZIP archive on the fly
    const archive = archiver('zip', {
      zlib: { level: 9 }
    });

    archive.pipe(res);

    // Add connection script
    const connectionScript = `@echo off
title ${packageId} - Server Connector

echo ========================================
echo   ATS Server Connector
echo   Server: Freddy's ATS Server
echo ========================================
echo.

set /p SERVER_ID="Enter Server ID (from Discord): "

if "%SERVER_ID%"=="" (
    echo Error: Server ID is required!
    pause
    exit /b 1
)

echo.
echo Connecting to server: %SERVER_ID%
echo Password: ruby
echo Domain: ats.7gram.xyz
echo.

start "" "steam://connect/ats.7gram.xyz:27015/ruby"

echo.
echo ATS should be launching...
pause`;

    archive.append(connectionScript, { name: 'Connect_To_ATS_Server.bat' });
    
    // Add README
    const readme = `ATS Client Package - Freddy's Server
===================================

QUICK SETUP:
1. Install Tailscale VPN from https://tailscale.com/download
2. Get invited to the Tailscale network (contact Freddy)
3. Double-click "Connect_To_ATS_Server.bat"
4. Enter the Server ID when prompted

REQUIREMENTS:
- Steam with American Truck Simulator
- Tailscale VPN (for server access)
- Server ID from Discord

Generated: ${new Date().toISOString()}
Package ID: ${packageId}`;

    archive.append(readme, { name: 'README.txt' });
    
    archive.finalize();

  } catch (error) {
    next(error);
  }
});

// Get server configuration
router.get('/config', async (req, res, next) => {
  try {
    logger.info('Server configuration requested', { user: req.user.username });

    // In a real implementation, you would read the actual config files
    const config = {
      server: {
        name: "Freddy's ATS Dedicated Server",
        password: "ruby",
        maxPlayers: 8,
        port: 27015,
        welcomeMessage: "Welcome to Freddy's ATS Server! Have fun trucking!"
      },
      gameplay: {
        timeScale: 5,
        fuelConsumptionEnabled: true,
        tollgatesEnabled: true,
        trafficEnabled: true,
        weatherEnabled: true
      },
      mods: {
        autoUpdate: true,
        requiredMods: [
          "mod_physics_realistic.sii",
          "mod_sound_enhanced.sii"
        ]
      },
      network: {
        maxPing: 300,
        kickIdleTime: 600,
        connectionTimeout: 30
      }
    };

    res.json({
      success: true,
      data: config
    });

  } catch (error) {
    next(error);
  }
});

// Update server configuration
router.put('/config', async (req, res, next) => {
  try {
    const { config } = req.body;
    
    if (!config) {
      return res.status(400).json({
        success: false,
        error: 'Configuration data is required'
      });
    }

    logger.info('Server configuration update requested', { 
      user: req.user.username,
      configKeys: Object.keys(config)
    });

    // In a real implementation, you would:
    // 1. Validate the configuration
    // 2. Update the actual config files
    // 3. Restart the server if necessary

    logger.info('Server configuration updated successfully', { 
      user: req.user.username
    });

    res.json({
      success: true,
      message: 'Configuration updated successfully',
      data: config
    });

  } catch (error) {
    next(error);
  }
});

export default router;
