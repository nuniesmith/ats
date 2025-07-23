import axios from 'axios'

// Create axios instance with base configuration
const api = axios.create({
  baseURL: process.env.NODE_ENV === 'production' 
    ? 'https://ats.7gram.xyz/api' 
    : 'http://localhost:4000/api',
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
  },
})

// Request interceptor for adding auth headers if needed
api.interceptors.request.use(
  (config) => {
    // Add auth token if available
    const token = localStorage.getItem('ats_auth_token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// Response interceptor for error handling
api.interceptors.response.use(
  (response) => response.data,
  (error) => {
    console.error('API Error:', error)
    
    if (error.response) {
      // Server responded with error status
      const message = error.response.data?.message || error.response.statusText
      throw new Error(message)
    } else if (error.request) {
      // Request was made but no response received
      throw new Error('No response from server. Please check your connection.')
    } else {
      // Something else happened
      throw new Error(error.message)
    }
  }
)

// Server API endpoints
export const serverAPI = {
  // Server status and control
  getStatus: () => api.get('/server/status'),
  startServer: () => api.post('/server/start'),
  stopServer: () => api.post('/server/stop'),
  restartServer: () => api.post('/server/restart'),
  
  // Server metrics
  getMetrics: () => api.get('/server/metrics'),
  getSystemInfo: () => api.get('/server/system-info'),
  
  // Player management
  getPlayers: () => api.get('/players'),
  kickPlayer: (playerId) => api.post(`/players/${playerId}/kick`),
  banPlayer: (playerId) => api.post(`/players/${playerId}/ban`),
  unbanPlayer: (playerId) => api.post(`/players/${playerId}/unban`),
  getBannedPlayers: () => api.get('/players/banned'),
  
  // Mod management
  getMods: () => api.get('/mods'),
  updateMods: () => api.post('/mods/update'),
  getModCollectionInfo: () => api.get('/mods/collection'),
  syncModCollection: () => api.post('/mods/sync'),
  
  // Configuration
  getConfig: () => api.get('/config'),
  updateConfig: (config) => api.put('/config', config),
  resetConfig: () => api.post('/config/reset'),
  
  // Logs
  getLogs: (params = {}) => api.get('/logs', { params }),
  clearLogs: () => api.delete('/logs'),
  
  // Backup & Restore
  createBackup: () => api.post('/backup'),
  getBackups: () => api.get('/backup'),
  restoreBackup: (backupId) => api.post(`/backup/${backupId}/restore`),
  deleteBackup: (backupId) => api.delete(`/backup/${backupId}`),
}

// Steam API endpoints
export const steamAPI = {
  // Workshop collection
  getCollectionDetails: (collectionId) => api.get(`/steam/collection/${collectionId}`),
  getModDetails: (modId) => api.get(`/steam/mod/${modId}`),
  searchMods: (query) => api.get('/steam/search', { params: { q: query } }),
  
  // Server list
  getServerList: () => api.get('/steam/servers'),
  registerServer: (serverData) => api.post('/steam/servers/register', serverData),
}

// System API endpoints
export const systemAPI = {
  // System information
  getSystemInfo: () => api.get('/system/info'),
  getSystemMetrics: () => api.get('/system/metrics'),
  
  // File operations
  uploadFile: (file, type) => {
    const formData = new FormData()
    formData.append('file', file)
    formData.append('type', type)
    
    return api.post('/system/upload', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    })
  },
  
  downloadFile: (filename) => api.get(`/system/download/${filename}`, {
    responseType: 'blob',
  }),
  
  // Package generation
  generateClientPackage: (config) => api.post('/system/generate-package', config),
  getPackageStatus: (packageId) => api.get(`/system/package/${packageId}/status`),
  downloadPackage: (packageId) => api.get(`/system/package/${packageId}/download`, {
    responseType: 'blob',
  }),
}

// Authentication API (if needed)
export const authAPI = {
  login: (credentials) => api.post('/auth/login', credentials),
  logout: () => api.post('/auth/logout'),
  getProfile: () => api.get('/auth/profile'),
  refreshToken: () => api.post('/auth/refresh'),
}

// Utility functions
export const apiUtils = {
  // Download file helper
  downloadBlob: (blob, filename) => {
    const url = window.URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = filename
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    window.URL.revokeObjectURL(url)
  },
  
  // Format file size
  formatFileSize: (bytes) => {
    if (bytes === 0) return '0 Bytes'
    const k = 1024
    const sizes = ['Bytes', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
  },
  
  // Format uptime
  formatUptime: (seconds) => {
    const days = Math.floor(seconds / 86400)
    const hours = Math.floor((seconds % 86400) / 3600)
    const minutes = Math.floor((seconds % 3600) / 60)
    const secs = seconds % 60
    
    if (days > 0) {
      return `${days}d ${hours}h ${minutes}m`
    } else if (hours > 0) {
      return `${hours}h ${minutes}m`
    } else if (minutes > 0) {
      return `${minutes}m ${secs}s`
    } else {
      return `${secs}s`
    }
  },
  
  // Validate server ID
  validateServerId: (serverId) => {
    return /^\d{17}$/.test(serverId)
  },
  
  // Generate random server ID (for testing)
  generateTestServerId: () => {
    return Math.floor(Math.random() * 900000000000000000) + 100000000000000000
  }
}

export default api
