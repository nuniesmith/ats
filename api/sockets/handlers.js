import { logger } from '../utils/logger.js';

let connectedClients = new Map();
let serverMetrics = {
  cpu: 0,
  memory: 0,
  connections: 0,
  lastUpdate: Date.now()
};

export const initializeSocketHandlers = (io) => {
  logger.info('🔌 Initializing Socket.IO handlers');

  io.on('connection', (socket) => {
    logger.info('Client connected', { 
      socketId: socket.id,
      clientIP: socket.request.connection.remoteAddress
    });

    // Store client connection
    connectedClients.set(socket.id, {
      connectedAt: Date.now(),
      lastSeen: Date.now(),
      userAgent: socket.request.headers['user-agent']
    });

    // Send initial connection confirmation
    socket.emit('connectionConfirmed', {
      message: 'Connected to ATS Server Management API',
      timestamp: new Date().toISOString(),
      socketId: socket.id
    });

    // Join server monitoring room
    socket.join('serverMonitoring');

    // Handle authentication
    socket.on('authenticate', (data) => {
      try {
        // In a real implementation, you would verify the JWT token
        const { token } = data;
        
        if (token) {
          logger.info('Socket authentication successful', { 
            socketId: socket.id 
          });
          
          socket.emit('authenticationSuccess', {
            message: 'Socket authenticated successfully'
          });
          
          // Join authenticated room for privileged updates
          socket.join('authenticated');
        } else {
          throw new Error('No token provided');
        }
      } catch (error) {
        logger.warn('Socket authentication failed', {
          socketId: socket.id,
          error: error.message
        });
        
        socket.emit('authenticationError', {
          error: 'Authentication failed'
        });
      }
    });

    // Handle server status requests
    socket.on('requestServerStatus', () => {
      // Emit current server status
      socket.emit('serverStatusUpdate', {
        type: 'statusResponse',
        status: {
          running: Math.random() > 0.5,
          players: generateRandomPlayers(),
          metrics: serverMetrics,
          lastUpdate: new Date().toISOString()
        }
      });
    });

    // Handle real-time chat (if implemented)
    socket.on('chatMessage', (data) => {
      try {
        const { message, username } = data;
        
        if (!message || !username) {
          throw new Error('Message and username are required');
        }

        logger.info('Chat message received', {
          socketId: socket.id,
          username,
          messageLength: message.length
        });

        // Broadcast to all authenticated clients
        io.to('authenticated').emit('chatMessage', {
          id: Date.now().toString(),
          username,
          message,
          timestamp: new Date().toISOString(),
          type: 'user'
        });

      } catch (error) {
        logger.warn('Chat message error', {
          socketId: socket.id,
          error: error.message
        });
        
        socket.emit('chatError', {
          error: 'Failed to send message'
        });
      }
    });

    // Handle heartbeat/ping
    socket.on('ping', (data) => {
      // Update last seen time
      if (connectedClients.has(socket.id)) {
        connectedClients.get(socket.id).lastSeen = Date.now();
      }
      
      // Respond with pong and server metrics
      socket.emit('pong', {
        timestamp: Date.now(),
        serverMetrics: serverMetrics,
        connections: connectedClients.size
      });
    });

    // Handle client disconnect
    socket.on('disconnect', (reason) => {
      logger.info('Client disconnected', {
        socketId: socket.id,
        reason,
        duration: connectedClients.has(socket.id) 
          ? Date.now() - connectedClients.get(socket.id).connectedAt 
          : 0
      });

      // Remove from connected clients
      connectedClients.delete(socket.id);
      
      // Update connection count
      updateServerMetrics();
    });

    // Update connection count
    updateServerMetrics();
  });

  // Start periodic updates
  startPeriodicUpdates(io);
};

// Generate random player data for demonstration
function generateRandomPlayers() {
  const playerNames = [
    'TruckerJoe', 'HighwayKing', 'FreightMaster', 'RoadWarrior', 
    'BigRigBob', 'CargoQueen', 'DieselDan', 'TruckingPro'
  ];
  
  const numPlayers = Math.floor(Math.random() * 5);
  const players = [];
  
  for (let i = 0; i < numPlayers; i++) {
    players.push({
      id: i + 1,
      name: playerNames[Math.floor(Math.random() * playerNames.length)],
      location: getRandomLocation(),
      truck: getRandomTruck(),
      connectedAt: new Date(Date.now() - Math.random() * 3600000).toISOString(),
      ping: Math.floor(Math.random() * 100 + 20)
    });
  }
  
  return players;
}

function getRandomLocation() {
  const cities = [
    'Los Angeles', 'San Francisco', 'Las Vegas', 'Phoenix', 
    'Denver', 'Salt Lake City', 'Portland', 'Seattle'
  ];
  return cities[Math.floor(Math.random() * cities.length)];
}

function getRandomTruck() {
  const trucks = [
    'Peterbilt 389', 'Kenworth W900', 'Freightliner Cascadia',
    'Volvo VNL', 'Mack Anthem', 'International LT'
  ];
  return trucks[Math.floor(Math.random() * trucks.length)];
}

function updateServerMetrics() {
  serverMetrics = {
    cpu: Math.random() * 30 + 10,
    memory: Math.random() * 40 + 20,
    connections: connectedClients.size,
    lastUpdate: Date.now()
  };
}

function startPeriodicUpdates(io) {
  // Send server metrics updates every 5 seconds
  setInterval(() => {
    updateServerMetrics();
    
    io.to('authenticated').emit('metricsUpdate', {
      type: 'serverMetrics',
      data: serverMetrics,
      timestamp: new Date().toISOString()
    });
  }, 5000);

  // Send player updates every 10 seconds
  setInterval(() => {
    const players = generateRandomPlayers();
    
    io.to('authenticated').emit('playersUpdate', {
      type: 'playerList',
      data: players,
      timestamp: new Date().toISOString()
    });
  }, 10000);

  // Clean up stale connections every minute
  setInterval(() => {
    const now = Date.now();
    const staleThreshold = 5 * 60 * 1000; // 5 minutes
    
    for (const [socketId, clientInfo] of connectedClients.entries()) {
      if (now - clientInfo.lastSeen > staleThreshold) {
        logger.warn('Removing stale connection', { socketId });
        connectedClients.delete(socketId);
      }
    }
  }, 60000);

  logger.info('✅ Socket.IO periodic updates started');
}
