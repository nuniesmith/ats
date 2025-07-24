import React, { useEffect, useState } from 'react'
import { Routes, Route } from 'react-router-dom'

// Layout Components
import Layout from './components/Layout/Layout'

// Page Components
import Dashboard from './pages/Dashboard'
import ServerManagement from './pages/ServerManagement'
import ModCollection from './pages/ModCollection'
import PlayerManagement from './pages/PlayerManagement'
import ServerLogs from './pages/ServerLogs'
import Settings from './pages/Settings'
import ClientPackage from './pages/ClientPackage'

// Context Providers
import { ServerProvider } from './contexts/ServerContext'
import { SocketProvider } from './contexts/SocketContext'

// Auth utilities
import { initializeAuth } from './utils/auth'
import LoadingSpinner from './components/Common/LoadingSpinner'

function App() {
  const [authInitialized, setAuthInitialized] = useState(false)
  const [authError, setAuthError] = useState(null)

  useEffect(() => {
    const initAuth = async () => {
      try {
        const success = await initializeAuth()
        if (!success) {
          setAuthError('Failed to authenticate. Please check your connection.')
        }
      } catch (error) {
        setAuthError(`Authentication error: ${error.message}`)
      } finally {
        setAuthInitialized(true)
      }
    }

    initAuth()
  }, [])

  if (!authInitialized) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-gray-900 via-ats-dark to-gray-900 flex items-center justify-center">
        <div className="text-center">
          <LoadingSpinner size="lg" />
          <p className="text-white mt-4 text-lg">Initializing ATS Server Manager...</p>
          <p className="text-gray-400 mt-2">Authenticating and connecting to server</p>
        </div>
      </div>
    )
  }

  if (authError) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-gray-900 via-ats-dark to-gray-900 flex items-center justify-center">
        <div className="text-center max-w-md">
          <div className="w-16 h-16 mx-auto mb-4 bg-red-500 rounded-full flex items-center justify-center">
            <span className="text-white text-2xl">⚠️</span>
          </div>
          <h1 className="text-2xl font-bold text-white mb-2">Authentication Failed</h1>
          <p className="text-gray-400 mb-4">{authError}</p>
          <p className="text-sm text-gray-500">
            Make sure you're connected to Tailscale VPN and the server is running.
          </p>
          <button 
            onClick={() => window.location.reload()} 
            className="mt-4 btn-primary"
          >
            Retry
          </button>
        </div>
      </div>
    )
  }
  return (
    <div className="App min-h-screen bg-gradient-to-br from-gray-900 via-ats-dark to-gray-900">
      <ServerProvider>
        <SocketProvider>
          <Layout>
            <Routes>
              <Route path="/" element={<Dashboard />} />
              <Route path="/dashboard" element={<Dashboard />} />
              <Route path="/server" element={<ServerManagement />} />
              <Route path="/mods" element={<ModCollection />} />
              <Route path="/players" element={<PlayerManagement />} />
              <Route path="/logs" element={<ServerLogs />} />
              <Route path="/settings" element={<Settings />} />
              <Route path="/client-package" element={<ClientPackage />} />
            </Routes>
          </Layout>
        </SocketProvider>
      </ServerProvider>
    </div>
  )
}

export default App
