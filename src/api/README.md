# ATS Server Management API

A Node.js/Express API server for managing American Truck Simulator dedicated servers with real-time web interface support.

## 🚀 Features

- **Server Management**: Start, stop, restart ATS dedicated server
- **Real-time Monitoring**: WebSocket-based live updates for server status, metrics, and players
- **Steam Workshop Integration**: Browse, install, and manage mods from Steam Workshop
- **Client Package Generation**: Create Windows client packages for easy player connection
- **Authentication**: JWT-based authentication system
- **File Management**: Browse and manage server configuration files
- **Logging**: Comprehensive logging with Winston
- **Security**: Rate limiting, CORS, and helmet security middleware

## 📋 Prerequisites

- **Node.js** 18.0.0 or higher
- **Windows** (for ATS server integration)
- **Steam** (for Workshop integration)
- **American Truck Simulator Dedicated Server**

## 🛠️ Installation

1. **Clone or navigate to the API directory**:
   ```bash
   cd api
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

3. **Configure environment**:
   ```bash
   copy .env.example .env
   # Edit .env file with your configuration
   ```

4. **Start development server**:
   ```bash
   # Using the batch script (Windows)
   start-dev.bat
   
   # Or using npm directly
   npm run dev
   ```

## ⚙️ Configuration

Edit the `.env` file with your specific settings:

```env
# Server Configuration
PORT=3001
NODE_ENV=development
FRONTEND_URL=http://localhost:5173

# JWT Secret (change this!)
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production

# Steam API Key (optional, for Workshop features)
STEAM_API_KEY=your-steam-api-key-here

# ATS Server Paths
ATS_SERVER_PATH=C:\ATS_Server
ATS_CONFIG_PATH=C:\ATS_Server\config
ATS_MODS_PATH=C:\ATS_Server\mods

# Cloudflare (for DNS management)
CLOUDFLARE_API_TOKEN=your-cloudflare-api-token
CLOUDFLARE_ZONE_ID=your-cloudflare-zone-id
```

## 🔌 API Endpoints

### Authentication
- `POST /api/auth/login` - User login
- `GET /api/auth/validate` - Validate JWT token
- `POST /api/auth/logout` - User logout

### Server Management
- `GET /api/server/status` - Get server status
- `GET /api/server/metrics` - Get server performance metrics
- `GET /api/server/players` - Get connected players
- `POST /api/server/start` - Start ATS server
- `POST /api/server/stop` - Stop ATS server
- `POST /api/server/restart` - Restart ATS server
- `POST /api/server/update-mods` - Update server mods
- `GET /api/server/logs` - Get server logs

### Steam Workshop
- `GET /api/steam/mods` - Get installed mods
- `GET /api/steam/workshop/search` - Search Steam Workshop
- `GET /api/steam/workshop/mod/:modId` - Get mod details
- `POST /api/steam/workshop/subscribe/:modId` - Install mod from Workshop
- `PATCH /api/steam/mods/:modId/toggle` - Enable/disable mod
- `DELETE /api/steam/mods/:modId` - Uninstall mod
- `GET /api/steam/collection/export` - Export mod collection

### System Management
- `GET /api/system/info` - Get system information
- `GET /api/system/files` - List files in directory
- `GET /api/system/files/content` - Read file content
- `POST /api/system/package/generate` - Generate client package
- `GET /api/system/package/download/:packageId` - Download client package
- `GET /api/system/config` - Get server configuration
- `PUT /api/system/config` - Update server configuration

## 🔄 WebSocket Events

### Client → Server
- `authenticate` - Authenticate socket connection
- `requestServerStatus` - Request current server status
- `chatMessage` - Send chat message
- `ping` - Heartbeat ping

### Server → Client
- `connectionConfirmed` - Connection established
- `authenticationSuccess` - Socket authenticated
- `serverStatusUpdate` - Server status changed
- `metricsUpdate` - Performance metrics update
- `playersUpdate` - Player list update
- `chatMessage` - Chat message broadcast
- `modUpdateProgress` - Mod update progress
- `pong` - Heartbeat response

## 🔐 Authentication

The API uses JWT tokens for authentication. Default credentials:
- **Username**: `admin` or `freddy`
- **Password**: `admin123` (change this in production!)

Include the JWT token in requests:
```
Authorization: Bearer <your-jwt-token>
```

## 🛡️ Security Features

- **Rate Limiting**: 100 requests per 15 minutes per IP
- **CORS**: Configured for frontend origin
- **Helmet**: Security headers
- **Input Validation**: Request validation with express-validator
- **Error Handling**: Comprehensive error handling middleware

## 📊 Monitoring & Logging

- **Winston Logging**: Structured logging to files and console
- **Health Check**: Available at `/health`
- **Real-time Metrics**: CPU, memory, connections via WebSocket

## 🚀 Production Deployment

1. **Set production environment**:
   ```env
   NODE_ENV=production
   ```

2. **Update security settings**:
   - Change default JWT secret
   - Update CORS origin to production URL
   - Configure proper ATS server paths

3. **Start production server**:
   ```bash
   npm start
   ```

## 🔧 Development

- **Development server with auto-reload**:
  ```bash
  npm run dev
  ```

- **Run tests**:
  ```bash
  npm test
  ```

- **Watch tests**:
  ```bash
  npm run test:watch
  ```

## 📁 Project Structure

```
api/
├── routes/          # API route handlers
│   ├── auth.js      # Authentication routes
│   ├── server.js    # Server management routes
│   ├── steam.js     # Steam Workshop routes
│   └── system.js    # System management routes
├── middleware/      # Express middleware
│   ├── auth.js      # JWT authentication
│   └── errorHandler.js
├── sockets/         # WebSocket handlers
│   └── handlers.js  # Socket.IO event handlers
├── utils/           # Utility functions
│   └── logger.js    # Winston logging configuration
├── logs/            # Log files (created automatically)
├── server.js        # Main server file
├── package.json     # Dependencies and scripts
├── .env.example     # Environment configuration template
└── README.md        # This file
```

## 🤝 Integration with React Frontend

This API is designed to work with the React frontend located in the `../web` directory. The frontend connects via:

- **HTTP API**: For standard CRUD operations
- **WebSocket**: For real-time updates and monitoring
- **Authentication**: Shared JWT tokens

## 🐛 Troubleshooting

### Common Issues

1. **Port already in use**:
   - Change `PORT` in `.env` file
   - Or kill the process using the port

2. **CORS errors**:
   - Verify `FRONTEND_URL` in `.env` matches your React app URL

3. **Authentication fails**:
   - Check JWT secret configuration
   - Verify token format in requests

4. **WebSocket connection fails**:
   - Check firewall settings
   - Verify Socket.IO client configuration

### Logs

Check the log files for detailed error information:
- `logs/error.log` - Error logs only
- `logs/combined.log` - All logs

## 📄 License

MIT License - see LICENSE file for details.

## 👥 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

---

**Author**: Freddy  
**Version**: 1.0.0  
**Last Updated**: January 2024
