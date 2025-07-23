import React, { useState } from 'react'
import { Link, useLocation } from 'react-router-dom'
import { 
  Truck, 
  Settings, 
  Users, 
  Package, 
  Activity, 
  FileText, 
  Home,
  Download,
  Menu,
  X,
  Wifi,
  WifiOff
} from 'lucide-react'
import { useServer } from '../../contexts/ServerContext'
import { useSocket } from '../../contexts/SocketContext'
import StatusIndicator from '../Common/StatusIndicator'

const navigation = [
  { name: 'Dashboard', href: '/dashboard', icon: Home },
  { name: 'Server Management', href: '/server', icon: Truck },
  { name: 'Mod Collection', href: '/mods', icon: Package },
  { name: 'Player Management', href: '/players', icon: Users },
  { name: 'Server Logs', href: '/logs', icon: FileText },
  { name: 'Client Package', href: '/client-package', icon: Download },
  { name: 'Settings', href: '/settings', icon: Settings },
]

function Layout({ children }) {
  const [sidebarOpen, setSidebarOpen] = useState(false)
  const location = useLocation()
  const { server, isLoading } = useServer()
  const { connected } = useSocket()

  const currentPage = navigation.find(item => item.href === location.pathname)?.name || 'ATS Server Manager'

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-ats-dark to-gray-900">
      {/* Mobile sidebar backdrop */}
      {sidebarOpen && (
        <div 
          className="fixed inset-0 z-40 bg-black bg-opacity-50 lg:hidden"
          onClick={() => setSidebarOpen(false)}
        />
      )}

      {/* Sidebar */}
      <div className={`
        fixed inset-y-0 left-0 z-50 w-64 bg-gray-900 border-r border-gray-700 transform transition-transform duration-300 ease-in-out lg:translate-x-0 lg:static lg:inset-0
        ${sidebarOpen ? 'translate-x-0' : '-translate-x-full'}
      `}>
        <div className="flex flex-col h-full">
          {/* Logo and header */}
          <div className="flex items-center justify-between p-6 border-b border-gray-700">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-gradient-to-br from-ats-primary to-ats-accent rounded-lg flex items-center justify-center">
                <Truck className="w-6 h-6 text-white" />
              </div>
              <div>
                <h1 className="text-xl font-bold text-white">ATS Manager</h1>
                <p className="text-sm text-gray-400">Freddy's Server</p>
              </div>
            </div>
            <button
              onClick={() => setSidebarOpen(false)}
              className="lg:hidden text-gray-400 hover:text-white"
            >
              <X className="w-6 h-6" />
            </button>
          </div>

          {/* Server status card */}
          <div className="p-4 border-b border-gray-700">
            <div className="bg-gray-800 rounded-lg p-4">
              <div className="flex items-center justify-between mb-2">
                <span className="text-sm font-medium text-gray-300">Server Status</span>
                <StatusIndicator status={server.status} />
              </div>
              <div className="text-lg font-bold text-white mb-1">
                {server.serverName}
              </div>
              <div className="text-sm text-gray-400">
                {server.currentPlayers}/{server.maxPlayers} players
              </div>
              {server.status === 'online' && (
                <div className="text-xs text-green-400 mt-1">
                  Port: {server.port}
                </div>
              )}
            </div>
          </div>

          {/* Navigation */}
          <nav className="flex-1 px-4 py-4 space-y-2 overflow-y-auto">
            {navigation.map((item) => {
              const isActive = location.pathname === item.href
              const Icon = item.icon
              
              return (
                <Link
                  key={item.name}
                  to={item.href}
                  onClick={() => setSidebarOpen(false)}
                  className={`
                    nav-link group
                    ${isActive ? 'active' : ''}
                  `}
                >
                  <Icon className="w-5 h-5 mr-3 transition-colors" />
                  <span className="font-medium">{item.name}</span>
                </Link>
              )
            })}
          </nav>

          {/* Connection status */}
          <div className="p-4 border-t border-gray-700">
            <div className="flex items-center space-x-2 text-sm">
              {connected ? (
                <>
                  <Wifi className="w-4 h-4 text-green-400" />
                  <span className="text-green-400">Connected</span>
                </>
              ) : (
                <>
                  <WifiOff className="w-4 h-4 text-red-400" />
                  <span className="text-red-400">Disconnected</span>
                </>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Main content */}
      <div className="lg:ml-64 flex flex-col min-h-screen">
        {/* Top bar */}
        <header className="bg-gray-800 border-b border-gray-700 px-4 py-4 lg:px-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <button
                onClick={() => setSidebarOpen(true)}
                className="lg:hidden text-gray-400 hover:text-white"
              >
                <Menu className="w-6 h-6" />
              </button>
              
              <div>
                <h2 className="text-xl font-semibold text-white">{currentPage}</h2>
                <p className="text-sm text-gray-400">
                  Manage your American Truck Simulator dedicated server
                </p>
              </div>
            </div>

            <div className="flex items-center space-x-4">
              {/* Quick status indicators */}
              <div className="hidden md:flex items-center space-x-4 text-sm">
                <div className="flex items-center space-x-2">
                  <div className={`w-2 h-2 rounded-full ${
                    server.status === 'online' ? 'bg-green-400' : 
                    server.status === 'starting' || server.status === 'stopping' ? 'bg-yellow-400' : 
                    'bg-red-400'
                  }`} />
                  <span className="text-gray-300 capitalize">{server.status}</span>
                </div>
                
                {server.status === 'online' && (
                  <div className="text-gray-400">
                    {server.currentPlayers}/{server.maxPlayers} players
                  </div>
                )}
                
                <div className="flex items-center space-x-1">
                  {connected ? (
                    <Wifi className="w-4 h-4 text-green-400" />
                  ) : (
                    <WifiOff className="w-4 h-4 text-red-400" />
                  )}
                </div>
              </div>
            </div>
          </div>
        </header>

        {/* Page content */}
        <main className="flex-1 p-4 lg:p-6">
          <div className="max-w-7xl mx-auto">
            {children}
          </div>
        </main>

        {/* Footer */}
        <footer className="bg-gray-800 border-t border-gray-700 px-4 py-4 lg:px-6">
          <div className="flex items-center justify-between text-sm text-gray-400">
            <div>
              © 2025 Freddy's ATS Server Manager - Built with ❤️ for the trucking community
            </div>
            <div className="flex items-center space-x-4">
              <span>v1.0.0</span>
              <span>•</span>
              <span>Domain: ats.7gram.xyz</span>
              <span>•</span>
              <span>VPN Required: Tailscale</span>
            </div>
          </div>
        </footer>
      </div>
    </div>
  )
}

export default Layout
