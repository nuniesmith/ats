import React from 'react'
import { Settings, Server, Users, Package, Shield, Database } from 'lucide-react'

function SettingsPage() {
  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl lg:text-3xl font-bold text-white">
          Settings
        </h1>
        <p className="text-gray-400 mt-1">
          Configure your ATS server and management interface
        </p>
      </div>

      {/* Settings categories */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {/* Server Settings */}
        <div className="card">
          <div className="card-header">
            <h3 className="text-lg font-semibold text-white">Server Settings</h3>
            <Server className="w-5 h-5 text-ats-primary" />
          </div>
          <div className="text-center py-8 text-gray-500">
            <Server className="w-12 h-12 mx-auto mb-4 opacity-50" />
            <p>Server configuration</p>
            <p className="text-sm">Name, password, ports, gameplay settings</p>
          </div>
        </div>

        {/* Player Settings */}
        <div className="card">
          <div className="card-header">
            <h3 className="text-lg font-semibold text-white">Player Settings</h3>
            <Users className="w-5 h-5 text-ats-secondary" />
          </div>
          <div className="text-center py-8 text-gray-500">
            <Users className="w-12 h-12 mx-auto mb-4 opacity-50" />
            <p>Player management</p>
            <p className="text-sm">Max players, damage, traffic settings</p>
          </div>
        </div>

        {/* Mod Settings */}
        <div className="card">
          <div className="card-header">
            <h3 className="text-lg font-semibold text-white">Mod Settings</h3>
            <Package className="w-5 h-5 text-ats-accent" />
          </div>
          <div className="text-center py-8 text-gray-500">
            <Package className="w-12 h-12 mx-auto mb-4 opacity-50" />
            <p>Mod configuration</p>
            <p className="text-sm">Collection ID, auto-update, optional mods</p>
          </div>
        </div>

        {/* Security Settings */}
        <div className="card">
          <div className="card-header">
            <h3 className="text-lg font-semibold text-white">Security</h3>
            <Shield className="w-5 h-5 text-ats-success" />
          </div>
          <div className="text-center py-8 text-gray-500">
            <Shield className="w-12 h-12 mx-auto mb-4 opacity-50" />
            <p>Security settings</p>
            <p className="text-sm">Authentication, access control, VPN</p>
          </div>
        </div>

        {/* Backup Settings */}
        <div className="card">
          <div className="card-header">
            <h3 className="text-lg font-semibold text-white">Backup & Restore</h3>
            <Database className="w-5 h-5 text-ats-warning" />
          </div>
          <div className="text-center py-8 text-gray-500">
            <Database className="w-12 h-12 mx-auto mb-4 opacity-50" />
            <p>Backup management</p>
            <p className="text-sm">Auto-backup, restore points, exports</p>
          </div>
        </div>

        {/* Interface Settings */}
        <div className="card">
          <div className="card-header">
            <h3 className="text-lg font-semibold text-white">Interface</h3>
            <Settings className="w-5 h-5 text-ats-primary" />
          </div>
          <div className="text-center py-8 text-gray-500">
            <Settings className="w-12 h-12 mx-auto mb-4 opacity-50" />
            <p>Interface settings</p>
            <p className="text-sm">Theme, notifications, preferences</p>
          </div>
        </div>
      </div>

      {/* Environment configuration info */}
      <div className="card">
        <div className="card-header">
          <h3 className="text-lg font-semibold text-white">Environment Configuration</h3>
          <Settings className="w-5 h-5 text-ats-primary" />
        </div>
        
        <div className="bg-blue-900/20 border border-blue-700 rounded-lg p-4">
          <h4 className="font-medium text-blue-300 mb-2">Configuration Files</h4>
          <p className="text-sm text-blue-200 mb-3">
            Server settings are managed through environment configuration files:
          </p>
          <ul className="space-y-1 text-sm text-blue-200">
            <li>• <code className="bg-blue-800/30 px-1 rounded">.env</code> - Main configuration file</li>
            <li>• <code className="bg-blue-800/30 px-1 rounded">config/server_config.sii</code> - Server-specific settings</li>
            <li>• <code className="bg-blue-800/30 px-1 rounded">scripts/env_manager.bat</code> - Configuration management tool</li>
          </ul>
          <p className="text-xs text-blue-300 mt-3">
            Use the existing batch scripts for configuration management until the web interface is fully implemented.
          </p>
        </div>
      </div>
    </div>
  )
}

export default SettingsPage
