import React from 'react'
import { 
  Server, 
  Play, 
  Square, 
  RotateCcw, 
  Settings, 
  Monitor,
  Activity,
  AlertTriangle
} from 'lucide-react'
import { useServer } from '../contexts/ServerContext'
import StatusIndicator from '../components/Common/StatusIndicator'
import LoadingSpinner from '../components/Common/LoadingSpinner'

function ServerManagement() {
  const { server, metrics, isLoading, error, actions } = useServer()

  const handleServerAction = (action) => {
    if (action === 'start') actions.startServer()
    else if (action === 'stop') actions.stopServer()
    else if (action === 'restart') actions.restartServer()
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl lg:text-3xl font-bold text-white">
          Server Management
        </h1>
        <p className="text-gray-400 mt-1">
          Control and monitor your ATS dedicated server
        </p>
      </div>

      {/* Server controls */}
      <div className="card">
        <div className="card-header">
          <h3 className="text-lg font-semibold text-white">Server Controls</h3>
          <Server className="w-5 h-5 text-ats-primary" />
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <h4 className="font-medium text-gray-300 mb-4">Current Status</h4>
            <div className="space-y-3">
              <StatusIndicator status={server.status} showLabel={true} size="lg" />
              <div className="text-sm text-gray-400">
                <div>Server: {server.serverName}</div>
                <div>Players: {server.currentPlayers}/{server.maxPlayers}</div>
                <div>Port: {server.port}</div>
              </div>
            </div>
          </div>
          
          <div>
            <h4 className="font-medium text-gray-300 mb-4">Actions</h4>
            <div className="flex flex-wrap gap-3">
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
        </div>
      </div>

      {/* Server configuration */}
      <div className="card">
        <div className="card-header">
          <h3 className="text-lg font-semibold text-white">Server Configuration</h3>
          <Settings className="w-5 h-5 text-ats-primary" />
        </div>
        
        <div className="text-center py-8 text-gray-500">
          <Settings className="w-12 h-12 mx-auto mb-4 opacity-50" />
          <p>Server configuration interface coming soon</p>
          <p className="text-sm">Edit server settings, ports, and gameplay options</p>
        </div>
      </div>

      {/* System monitoring */}
      <div className="card">
        <div className="card-header">
          <h3 className="text-lg font-semibold text-white">System Monitoring</h3>
          <Monitor className="w-5 h-5 text-ats-primary" />
        </div>
        
        <div className="text-center py-8 text-gray-500">
          <Activity className="w-12 h-12 mx-auto mb-4 opacity-50" />
          <p>Advanced monitoring interface coming soon</p>
          <p className="text-sm">Real-time system metrics and performance graphs</p>
        </div>
      </div>
    </div>
  )
}

export default ServerManagement
