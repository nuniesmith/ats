import express from 'express';
import axios from 'axios';
import xml2js from 'xml2js';
import { logger } from '../utils/logger.js';

const router = express.Router();

// Steam Web API configuration
const STEAM_API_KEY = process.env.STEAM_API_KEY;
const ATS_APP_ID = '270880'; // American Truck Simulator App ID

// Workshop mod details (simulated data for now)
const installedMods = [
  {
    id: '2847492854',
    name: 'Realistic Physics Mod',
    description: 'Enhanced truck physics for more realistic driving experience',
    author: 'PhysicsMaster',
    fileSize: '45.2 MB',
    lastUpdated: '2024-01-15T10:30:00Z',
    subscriptions: 125000,
    rating: 4.8,
    enabled: true
  },
  {
    id: '2756841923',
    name: 'Enhanced Sound Pack',
    description: 'Improved engine sounds and ambient audio',
    author: 'SoundPro',
    fileSize: '180.5 MB',
    lastUpdated: '2024-01-10T14:20:00Z',
    subscriptions: 89000,
    rating: 4.6,
    enabled: true
  },
  {
    id: '2693847521',
    name: 'Realistic Traffic Density',
    description: 'More realistic traffic patterns and density',
    author: 'TrafficGuru',
    fileSize: '12.8 MB',
    lastUpdated: '2024-01-08T09:15:00Z',
    subscriptions: 67000,
    rating: 4.5,
    enabled: false
  }
];

// Get installed mods
router.get('/mods', (req, res) => {
  logger.info('Installed mods requested', { user: req.user.username });
  
  res.json({
    success: true,
    data: {
      totalMods: installedMods.length,
      enabledMods: installedMods.filter(mod => mod.enabled).length,
      mods: installedMods
    }
  });
});

// Search Steam Workshop
router.get('/workshop/search', async (req, res, next) => {
  try {
    const { query, page = 1, limit = 20 } = req.query;
    
    if (!query) {
      return res.status(400).json({
        success: false,
        error: 'Search query is required'
      });
    }

    logger.info('Workshop search requested', { 
      user: req.user.username,
      query,
      page: parseInt(page)
    });

    // In a real implementation, you would use Steam Web API
    // For now, we'll return simulated search results
    const simulatedResults = [
      {
        id: '2951847263',
        name: `${query} Enhancement Mod`,
        description: `Enhanced ${query} functionality for ATS`,
        author: 'ModAuthor1',
        previewImage: 'https://steamuserimages-a.akamaihd.net/ugc/placeholder1.jpg',
        subscriptions: 45000,
        rating: 4.7,
        lastUpdated: '2024-01-20T12:00:00Z',
        fileSize: '67.3 MB'
      },
      {
        id: '2938472856',
        name: `Realistic ${query} Pack`,
        description: `More realistic ${query} behavior and appearance`,
        author: 'ModAuthor2',
        previewImage: 'https://steamuserimages-a.akamaihd.net/ugc/placeholder2.jpg',
        subscriptions: 32000,
        rating: 4.4,
        lastUpdated: '2024-01-18T15:30:00Z',
        fileSize: '89.1 MB'
      }
    ];

    res.json({
      success: true,
      data: {
        query,
        page: parseInt(page),
        totalResults: simulatedResults.length,
        results: simulatedResults
      }
    });

  } catch (error) {
    next(error);
  }
});

// Get mod details from Steam Workshop
router.get('/workshop/mod/:modId', async (req, res, next) => {
  try {
    const { modId } = req.params;
    
    logger.info('Workshop mod details requested', { 
      user: req.user.username,
      modId
    });

    // Check if mod is already installed
    const installedMod = installedMods.find(mod => mod.id === modId);
    
    if (installedMod) {
      return res.json({
        success: true,
        data: {
          ...installedMod,
          installed: true,
          installPath: `C:\\ATS\\mods\\${modId}`
        }
      });
    }

    // In a real implementation, you would fetch from Steam API
    // For now, return simulated data
    const simulatedModDetails = {
      id: modId,
      name: 'Workshop Mod',
      description: 'A great mod from Steam Workshop',
      author: 'WorkshopAuthor',
      previewImage: 'https://steamuserimages-a.akamaihd.net/ugc/placeholder.jpg',
      screenshots: [
        'https://steamuserimages-a.akamaihd.net/ugc/screenshot1.jpg',
        'https://steamuserimages-a.akamaihd.net/ugc/screenshot2.jpg'
      ],
      subscriptions: 25000,
      rating: 4.5,
      lastUpdated: '2024-01-15T10:00:00Z',
      fileSize: '45.2 MB',
      tags: ['Trucks', 'Realistic', 'Graphics'],
      requirements: 'Base game required',
      installed: false
    };

    res.json({
      success: true,
      data: simulatedModDetails
    });

  } catch (error) {
    next(error);
  }
});

// Subscribe to mod (install from Workshop)
router.post('/workshop/subscribe/:modId', async (req, res, next) => {
  try {
    const { modId } = req.params;
    
    logger.info('Workshop mod subscription requested', { 
      user: req.user.username,
      modId
    });

    // Check if already installed
    const existingMod = installedMods.find(mod => mod.id === modId);
    if (existingMod) {
      return res.status(400).json({
        success: false,
        error: 'Mod is already installed'
      });
    }

    // In a real implementation, you would:
    // 1. Download the mod from Steam Workshop
    // 2. Install it to the appropriate directory
    // 3. Update the server configuration

    // Simulate installation
    const newMod = {
      id: modId,
      name: 'New Workshop Mod',
      description: 'Recently installed mod from Steam Workshop',
      author: 'WorkshopAuthor',
      fileSize: '45.2 MB',
      lastUpdated: new Date().toISOString(),
      subscriptions: 25000,
      rating: 4.5,
      enabled: false // Newly installed mods start disabled
    };

    installedMods.push(newMod);

    logger.info('Workshop mod installed successfully', { 
      user: req.user.username,
      modId,
      modName: newMod.name
    });

    res.json({
      success: true,
      message: 'Mod installed successfully',
      data: newMod
    });

  } catch (error) {
    next(error);
  }
});

// Toggle mod enabled/disabled
router.patch('/mods/:modId/toggle', (req, res, next) => {
  try {
    const { modId } = req.params;
    
    const mod = installedMods.find(m => m.id === modId);
    if (!mod) {
      return res.status(404).json({
        success: false,
        error: 'Mod not found'
      });
    }

    mod.enabled = !mod.enabled;

    logger.info('Mod status toggled', { 
      user: req.user.username,
      modId,
      modName: mod.name,
      enabled: mod.enabled
    });

    res.json({
      success: true,
      message: `Mod ${mod.enabled ? 'enabled' : 'disabled'} successfully`,
      data: mod
    });

  } catch (error) {
    next(error);
  }
});

// Uninstall mod
router.delete('/mods/:modId', (req, res, next) => {
  try {
    const { modId } = req.params;
    
    const modIndex = installedMods.findIndex(m => m.id === modId);
    if (modIndex === -1) {
      return res.status(404).json({
        success: false,
        error: 'Mod not found'
      });
    }

    const removedMod = installedMods.splice(modIndex, 1)[0];

    logger.info('Mod uninstalled', { 
      user: req.user.username,
      modId,
      modName: removedMod.name
    });

    res.json({
      success: true,
      message: 'Mod uninstalled successfully',
      data: removedMod
    });

  } catch (error) {
    next(error);
  }
});

// Get mod collection export
router.get('/collection/export', (req, res) => {
  logger.info('Mod collection export requested', { user: req.user.username });
  
  const collection = {
    name: "Freddy's ATS Server Mod Collection",
    description: 'Essential mods for the best ATS multiplayer experience',
    version: '1.0.0',
    gameVersion: '1.48.5.15',
    createdAt: new Date().toISOString(),
    mods: installedMods.filter(mod => mod.enabled).map(mod => ({
      id: mod.id,
      name: mod.name,
      author: mod.author,
      required: true
    }))
  };

  res.json({
    success: true,
    data: collection
  });
});

export default router;
