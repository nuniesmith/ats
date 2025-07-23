import React from 'react'
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

function App() {
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
