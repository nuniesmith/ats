import express from 'express';
import { spawn, exec } from 'child_process';
import path from 'path';
import fs from 'fs/promises';
import { fileURLToPath } from 'url';
import { logger } from '../utils/logger.js';
import { io } from '../server.js';

const router = express.Router();
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Server status tracking
let serverStatus = {
  running: false,
  players: [],
  serverInfo: {
    name: "Freddy's ATS Dedicated Server",
    maxPlayers: 8,
    password: "ruby",
    port: 27015,
    version: "1.48.5.15"
  },
  metrics: {
    cpu: 0,
    memory: 0,
    uptime: 0,
    connections: 0
  },
  lastUpdate: new Date().toISOString()
};

// Get server status
router.get('/status', (req, res) => {
  logger.info('Server status requested', { user: req.user.username });
  
  res.json({
    success: true,
    data: serverStatus
  });
});

// Get server metrics
router.get('/metrics', async (req, res, next) => {
  try {
    // In a real implementation, you would gather actual metrics
    // For now, we'll simulate some realistic data
    const metrics = {
      cpu: Math.random() * 30 + 10, // 10-40% CPU usage
      memory: Math.random() * 40 + 20, // 20-60% memory usage
      uptime: serverStatus.running ? Date.now() - new Date(serverStatus.lastUpdate).getTime() : 0,
      connections: serverStatus.players.length,
      networkIn: Math.random() * 1000, // KB/s
      networkOut: Math.random() * 500, // KB/s
      diskUsage: 45.2, // Static for now
      timestamp: new Date().toISOString()
    };

    serverStatus.metrics = metrics;

    logger.info('Server metrics collected', { 
      user: req.user.username,
      cpu: metrics.cpu.toFixed(1),
      memory: metrics.memory.toFixed(1)
    });

    res.json({
      success: true,
      data: metrics
    });

  } catch (error) {
    next(error);
  }
});

// Get connected players
router.get('/players', (req, res) => {
  logger.info('Player list requested', { user: req.user.username });
  
  res.json({
    success: true,
    data: serverStatus.players
  });
});

// Start server
router.post('/start', async (req, res, next) => {
  try {
    if (serverStatus.running) {
      return res.status(400).json({
        success: false,
        error: 'Server is already running'
      });
    }

    logger.info('Starting ATS server', { user: req.user.username });

    // In a real implementation, you would start the actual ATS server
    // For now, we'll simulate the server start
    serverStatus.running = true;
    serverStatus.lastUpdate = new Date().toISOString();
    serverStatus.metrics.uptime = 0;

    // Simulate server startup delay
    setTimeout(() => {
      // Emit server status update to connected clients
      io.emit('serverStatusUpdate', {
        type: 'serverStarted',
        status: serverStatus
      });
    }, 2000);

    logger.info('ATS server started successfully', { 
      user: req.user.username 
    });

    res.json({
      success: true,
      message: 'Server start initiated',
      data: serverStatus
    });

  } catch (error) {
    next(error);
  }
});

// Stop server
router.post('/stop', async (req, res, next) => {
  try {
    if (!serverStatus.running) {
      return res.status(400).json({
        success: false,
        error: 'Server is not running'
      });
    }

    logger.info('Stopping ATS server', { user: req.user.username });

    // In a real implementation, you would stop the actual ATS server
    serverStatus.running = false;
    serverStatus.players = [];
    serverStatus.lastUpdate = new Date().toISOString();

    // Emit server status update to connected clients
    io.emit('serverStatusUpdate', {
      type: 'serverStopped',
      status: serverStatus
    });

    logger.info('ATS server stopped successfully', { 
      user: req.user.username 
    });

    res.json({
      success: true,
      message: 'Server stopped successfully',
      data: serverStatus
    });

  } catch (error) {
    next(error);
  }
});

// Restart server
router.post('/restart', async (req, res, next) => {
  try {
    logger.info('Restarting ATS server', { user: req.user.username });

    // Stop the server first
    if (serverStatus.running) {
      serverStatus.running = false;
      serverStatus.players = [];
      
      // Emit stop event
      io.emit('serverStatusUpdate', {
        type: 'serverStopped',
        status: serverStatus
      });

      // Wait a bit before starting
      await new Promise(resolve => setTimeout(resolve, 3000));
    }

    // Start the server
    serverStatus.running = true;
    serverStatus.lastUpdate = new Date().toISOString();
    serverStatus.metrics.uptime = 0;

    // Emit start event
    setTimeout(() => {
      io.emit('serverStatusUpdate', {
        type: 'serverStarted',
        status: serverStatus
      });
    }, 2000);

    logger.info('ATS server restarted successfully', { 
      user: req.user.username 
    });

    res.json({
      success: true,
      message: 'Server restart initiated',
      data: serverStatus
    });

  } catch (error) {
    next(error);
  }
});

// Update server mods
router.post('/update-mods', async (req, res, next) => {
  try {
    logger.info('Updating server mods', { user: req.user.username });

    // In a real implementation, you would run the mod update scripts
    // For now, we'll simulate the process

    // Emit progress updates
    io.emit('modUpdateProgress', {
      type: 'started',
      message: 'Starting mod update process...'
    });

    setTimeout(() => {
      io.emit('modUpdateProgress', {
        type: 'progress',
        message: 'Downloading mod updates...',
        progress: 30
      });
    }, 1000);

    setTimeout(() => {
      io.emit('modUpdateProgress', {
        type: 'progress',
        message: 'Installing mod updates...',
        progress: 70
      });
    }, 3000);

    setTimeout(() => {
      io.emit('modUpdateProgress', {
        type: 'completed',
        message: 'Mod update completed successfully!',
        progress: 100
      });
    }, 5000);

    logger.info('Mod update process initiated', { 
      user: req.user.username 
    });

    res.json({
      success: true,
      message: 'Mod update process started'
    });

  } catch (error) {
    next(error);
  }
});

// Get server logs
router.get('/logs', async (req, res, next) => {
  try {
    const { lines = 100 } = req.query;
    
    logger.info('Server logs requested', { 
      user: req.user.username,
      lines: parseInt(lines)
    });

    // In a real implementation, you would read actual ATS server logs
    // For now, we'll return simulated log entries
    const simulatedLogs = [
      { timestamp: new Date().toISOString(), level: 'INFO', message: 'Server started successfully' },
      { timestamp: new Date(Date.now() - 60000).toISOString(), level: 'INFO', message: 'Player "TruckerJoe" connected' },
      { timestamp: new Date(Date.now() - 120000).toISOString(), level: 'WARN', message: 'High CPU usage detected' },
      { timestamp: new Date(Date.now() - 180000).toISOString(), level: 'INFO', message: 'Mod update completed' },
      { timestamp: new Date(Date.now() - 240000).toISOString(), level: 'ERROR', message: 'Failed to load texture: road_sign_01.dds' }
    ];

    res.json({
      success: true,
      data: simulatedLogs.slice(0, parseInt(lines))
    });

  } catch (error) {
    next(error);
  }
});

export default router;
