import React from 'react'
import { Users, UserCheck, UserX, Shield } from 'lucide-react'
import { useServer } from '../contexts/ServerContext'

function PlayerManagement() {
  const { server } = useServer()

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl lg:text-3xl font-bold text-white">
          Player Management
        </h1>
        <p className="text-gray-400 mt-1">
          Monitor and manage players on your ATS server
        </p>
      </div>

      {/* Player stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="card">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold text-white">Online Players</h3>
            <Users className="w-5 h-5 text-ats-success" />
          </div>
          <div className="text-3xl font-bold text-white">
            {server.currentPlayers}
          </div>
          <div className="text-sm text-gray-400">
            of {server.maxPlayers} max players
          </div>
        </div>

        <div className="card">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold text-white">Total Joins</h3>
            <UserCheck className="w-5 h-5 text-ats-primary" />
          </div>
          <div className="text-3xl font-bold text-white">--</div>
          <div className="text-sm text-gray-400">Since server start</div>
        </div>

        <div className="card">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold text-white">Banned Players</h3>
            <UserX className="w-5 h-5 text-ats-error" />
          </div>
          <div className="text-3xl font-bold text-white">--</div>
          <div className="text-sm text-gray-400">Total banned</div>
        </div>
      </div>

      {/* Online players */}
      <div className="card">
        <div className="card-header">
          <h3 className="text-lg font-semibold text-white">Online Players</h3>
          <Users className="w-5 h-5 text-ats-primary" />
        </div>
        
        <div className="text-center py-8 text-gray-500">
          <Users className="w-12 h-12 mx-auto mb-4 opacity-50" />
          <p>Player list interface coming soon</p>
          <p className="text-sm">View online players, kick/ban options, and player statistics</p>
        </div>
      </div>

      {/* Player management */}
      <div className="card">
        <div className="card-header">
          <h3 className="text-lg font-semibold text-white">Player Administration</h3>
          <Shield className="w-5 h-5 text-ats-primary" />
        </div>
        
        <div className="text-center py-8 text-gray-500">
          <Shield className="w-12 h-12 mx-auto mb-4 opacity-50" />
          <p>Admin tools coming soon</p>
          <p className="text-sm">Kick, ban, and manage player permissions</p>
        </div>
      </div>
    </div>
  )
}

export default PlayerManagement
