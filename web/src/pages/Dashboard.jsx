import React from 'react'
import { 
  Activity, 
  Users, 
  Package, 
  Server, 
  Clock, 
  Gauge,
  HardDrive,
  Cpu,
  MemoryStick,
  Network,
  Play,
  Square,
  RotateCcw,
  AlertTriangle
} from 'lucide-react'
import { useServer } from '../contexts/ServerContext'
import { useSocket } from '../contexts/SocketContext'
import StatusIndicator from '../components/Common/StatusIndicator'
import LoadingSpinner from '../components/Common/LoadingSpinner'
import { apiUtils } from '../services/api'

function Dashboard() {
  const { server, metrics, isLoading, error, actions } = useServer()
  const { connected, logs } = useSocket()

  // Get recent logs (last 10 entries)
  const recentLogs = logs.slice(-10).reverse()

  const handleServerAction = (action) => {
    if (action === 'start') actions.startServer()
    else if (action === 'stop') actions.stopServer()
    else if (action === 'restart') actions.restartServer()
  }

  if (isLoading && !server.status) {
    return (
      <div className="flex items-center justify-center min-h-96">
        <LoadingSpinner size="lg" text="Loading server status..." />
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header with quick actions */}
      <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
        <div>
          <h1 className="text-2xl lg:text-3xl font-bold text-white">
            Dashboard
          </h1>
          <p className="text-gray-400 mt-1">
            Monitor and control your ATS dedicated server
          </p>
        </div>
        
        <div className="flex items-center gap-3">
          <button
            onClick={() => handleServerAction('start')}
            disabled={server.status === 'online' || isLoading}
            className="btn-success disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
          >
            <Play className="w-4 h-4" />
            Start Server
          </button>
          
          <button
            onClick={() => handleServerAction('stop')}
            disabled={server.status === 'offline' || isLoading}
            className="btn-error disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
          >
            <Square className="w-4 h-4" />
            Stop Server
          </button>
          
          <button
            onClick={() => handleServerAction('restart')}
            disabled={server.status === 'offline' || isLoading}
            className="btn-warning disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
          >
            <RotateCcw className="w-4 h-4" />
            Restart
          </button>
        </div>
      </div>

      {/* Error display */}
      {error && (
        <div className="bg-red-900/20 border border-red-700 rounded-lg p-4 flex items-center gap-3">
          <AlertTriangle className="w-5 h-5 text-red-400" />
          <div>
            <p className="text-red-400 font-medium">Server Error</p>
            <p className="text-red-300 text-sm">{error}</p>
          </div>
          <button
            onClick={actions.clearError}
            className="ml-auto text-red-400 hover:text-red-300"
          >
            ×
          </button>
        </div>
      )}

      {/* Status overview cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {/* Server Status */}
        <div className="card">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold text-white">Server Status</h3>
            <Server className="w-5 h-5 text-ats-primary" />
          </div>
          <div className="space-y-3">
            <StatusIndicator status={server.status} showLabel={true} size="md" />
            <div className="text-sm text-gray-400">
              <div>Name: {server.serverName}</div>
              <div>Port: {server.port}</div>
              {server.uptime > 0 && (
                <div>Uptime: {apiUtils.formatUptime(server.uptime)}</div>
              )}
            </div>
          </div>
        </div>

        {/* Players */}
        <div className="card">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold text-white">Players</h3>
            <Users className="w-5 h-5 text-ats-secondary" />
          </div>
          <div className="space-y-3">
            <div className="text-3xl font-bold text-white">
              {server.currentPlayers}/{server.maxPlayers}
            </div>
            <div className="text-sm text-gray-400">
              {server.status === 'online' ? 'Players online' : 'Server offline'}
            </div>
            <div className="w-full bg-gray-700 rounded-full h-2">
              <div 
                className="bg-ats-secondary h-2 rounded-full transition-all duration-300"
                style={{ 
                  width: `${(server.currentPlayers / server.maxPlayers) * 100}%` 
                }}
              />
            </div>
          </div>
        </div>

        {/* Mods */}
        <div className="card">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold text-white">Mods</h3>
            <Package className="w-5 h-5 text-ats-accent" />
          </div>
          <div className="space-y-3">
            <div className="text-3xl font-bold text-white">
              {server.modCount}
            </div>
            <div className="text-sm text-gray-400">
              Active mods
            </div>
            <div className="text-xs text-gray-500">
              Collection: {server.collectionId}
            </div>
          </div>
        </div>

        {/* Connection */}
        <div className="card">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold text-white">Connection</h3>
            <Network className="w-5 h-5 text-ats-success" />
          </div>
          <div className="space-y-3">
            <StatusIndicator 
              status={connected ? 'online' : 'offline'} 
              showLabel={true} 
              size="md" 
            />
            <div className="text-sm text-gray-400">
              <div>Domain: ats.7gram.xyz</div>
              <div>VPN: Tailscale required</div>
            </div>
          </div>
        </div>
      </div>

      {/* System metrics */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Performance metrics */}
        <div className="card">
          <div className="card-header">
            <h3 className="text-lg font-semibold text-white">System Performance</h3>
            <Activity className="w-5 h-5 text-ats-primary" />
          </div>
          
          <div className="space-y-4">
            {/* CPU */}
            <div className="metric-card">
              <div className="flex items-center justify-between mb-2">
                <div className="flex items-center gap-2">
                  <Cpu className="w-4 h-4 text-blue-400" />
                  <span className="text-sm font-medium text-gray-300">CPU Usage</span>
                </div>
                <span className="text-sm font-bold text-white">{metrics.cpu}%</span>
              </div>
              <div className="w-full bg-gray-700 rounded-full h-2">
                <div 
                  className="bg-blue-400 h-2 rounded-full transition-all duration-300"
                  style={{ width: `${metrics.cpu}%` }}
                />
              </div>
            </div>

            {/* Memory */}
            <div className="metric-card">
              <div className="flex items-center justify-between mb-2">
                <div className="flex items-center gap-2">
                  <MemoryStick className="w-4 h-4 text-green-400" />
                  <span className="text-sm font-medium text-gray-300">Memory Usage</span>
                </div>
                <span className="text-sm font-bold text-white">{metrics.memory}%</span>
              </div>
              <div className="w-full bg-gray-700 rounded-full h-2">
                <div 
                  className="bg-green-400 h-2 rounded-full transition-all duration-300"
                  style={{ width: `${metrics.memory}%` }}
                />
              </div>
            </div>

            {/* Disk */}
            <div className="metric-card">
              <div className="flex items-center justify-between mb-2">
                <div className="flex items-center gap-2">
                  <HardDrive className="w-4 h-4 text-yellow-400" />
                  <span className="text-sm font-medium text-gray-300">Disk Usage</span>
                </div>
                <span className="text-sm font-bold text-white">{metrics.disk}%</span>
              </div>
              <div className="w-full bg-gray-700 rounded-full h-2">
                <div 
                  className="bg-yellow-400 h-2 rounded-full transition-all duration-300"
                  style={{ width: `${metrics.disk}%` }}
                />
              </div>
            </div>

            {/* Network */}
            <div className="metric-card">
              <div className="flex items-center justify-between mb-2">
                <div className="flex items-center gap-2">
                  <Network className="w-4 h-4 text-purple-400" />
                  <span className="text-sm font-medium text-gray-300">Network</span>
                </div>
                <span className="text-sm font-bold text-white">
                  ↓{metrics.network.in} ↑{metrics.network.out}
                </span>
              </div>
              <div className="text-xs text-gray-500">
                MB/s in/out
              </div>
            </div>
          </div>
        </div>

        {/* Recent activity log */}
        <div className="card">
          <div className="card-header">
            <h3 className="text-lg font-semibold text-white">Recent Activity</h3>
            <Clock className="w-5 h-5 text-ats-primary" />
          </div>
          
          <div className="space-y-2 max-h-80 overflow-y-auto">
            {recentLogs.length > 0 ? (
              recentLogs.map((log) => (
                <div key={log.id} className="flex items-start gap-3 p-3 bg-gray-800/50 rounded-lg">
                  <div className={`w-2 h-2 rounded-full mt-2 flex-shrink-0 ${
                    log.level === 'error' ? 'bg-red-400' :
                    log.level === 'warning' ? 'bg-yellow-400' :
                    log.level === 'info' ? 'bg-blue-400' :
                    'bg-gray-400'
                  }`} />
                  <div className="flex-1 min-w-0">
                    <p className="text-sm text-gray-300 break-words">{log.message}</p>
                    <p className="text-xs text-gray-500 mt-1">
                      {log.timestamp.toLocaleTimeString()}
                    </p>
                  </div>
                </div>
              ))
            ) : (
              <div className="text-center py-8 text-gray-500">
                <Activity className="w-8 h-8 mx-auto mb-2 opacity-50" />
                <p>No recent activity</p>
                <p className="text-xs">Server logs will appear here</p>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Server information */}
      <div className="card">
        <div className="card-header">
          <h3 className="text-lg font-semibold text-white">Server Information</h3>
          <Gauge className="w-5 h-5 text-ats-primary" />
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <div>
            <h4 className="text-sm font-medium text-gray-400 mb-2">Server Details</h4>
            <div className="space-y-1 text-sm">
              <div className="text-gray-300">Name: {server.serverName}</div>
              <div className="text-gray-300">Password: {server.password}</div>
              <div className="text-gray-300">Port: {server.port}</div>
              <div className="text-gray-300">Max Players: {server.maxPlayers}</div>
            </div>
          </div>
          
          <div>
            <h4 className="text-sm font-medium text-gray-400 mb-2">Network</h4>
            <div className="space-y-1 text-sm">
              <div className="text-gray-300">Public IP: {server.ip || 'Loading...'}</div>
              <div className="text-gray-300">Tailscale IP: {server.tailscaleIp || 'Loading...'}</div>
              <div className="text-gray-300">Domain: ats.7gram.xyz</div>
              <div className="text-gray-300">VPN: Required</div>
            </div>
          </div>
          
          <div>
            <h4 className="text-sm font-medium text-gray-400 mb-2">Mods</h4>
            <div className="space-y-1 text-sm">
              <div className="text-gray-300">Collection ID: {server.collectionId}</div>
              <div className="text-gray-300">Mod Count: {server.modCount}</div>
              <div className="text-gray-300">Auto Update: Enabled</div>
              <div className="text-gray-300">Optional Mods: Enabled</div>
            </div>
          </div>
          
          <div>
            <h4 className="text-sm font-medium text-gray-400 mb-2">Status</h4>
            <div className="space-y-1 text-sm">
              <div className="text-gray-300">
                Status: <StatusIndicator status={server.status} showLabel={false} size="sm" className="inline-block ml-1" />
              </div>
              <div className="text-gray-300">Version: {server.version || 'Unknown'}</div>
              <div className="text-gray-300">
                Connection: <StatusIndicator status={connected ? 'online' : 'offline'} showLabel={false} size="sm" className="inline-block ml-1" />
              </div>
              {server.uptime > 0 && (
                <div className="text-gray-300">Uptime: {apiUtils.formatUptime(server.uptime)}</div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default Dashboard
