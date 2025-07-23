import React from 'react'
import { Package, Download, RefreshCw, ExternalLink } from 'lucide-react'
import { useServer } from '../contexts/ServerContext'

function ModCollection() {
  const { server, actions } = useServer()

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl lg:text-3xl font-bold text-white">
          Mod Collection
        </h1>
        <p className="text-gray-400 mt-1">
          Manage Steam Workshop mods for your ATS server
        </p>
      </div>

      {/* Collection info */}
      <div className="card">
        <div className="card-header">
          <h3 className="text-lg font-semibold text-white">Current Collection</h3>
          <Package className="w-5 h-5 text-ats-primary" />
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <h4 className="font-medium text-gray-300 mb-3">Collection Details</h4>
            <div className="space-y-2 text-sm">
              <div>
                <span className="text-gray-500">Collection ID:</span>
                <span className="text-white ml-2">{server.collectionId}</span>
              </div>
              <div>
                <span className="text-gray-500">Mod Count:</span>
                <span className="text-white ml-2">{server.modCount}</span>
              </div>
              <div>
                <span className="text-gray-500">Auto Update:</span>
                <span className="text-green-400 ml-2">Enabled</span>
              </div>
              <div>
                <span className="text-gray-500">Optional Mods:</span>
                <span className="text-green-400 ml-2">Enabled</span>
              </div>
            </div>
          </div>
          
          <div>
            <h4 className="font-medium text-gray-300 mb-3">Actions</h4>
            <div className="flex flex-wrap gap-3">
              <button
                onClick={actions.updateMods}
                className="btn-primary flex items-center gap-2"
              >
                <RefreshCw className="w-4 h-4" />
                Update Mods
              </button>
              
              <a
                href={`https://steamcommunity.com/sharedfiles/filedetails/?id=${server.collectionId}`}
                target="_blank"
                rel="noopener noreferrer"
                className="btn-outline flex items-center gap-2"
              >
                <ExternalLink className="w-4 h-4" />
                View on Steam
              </a>
            </div>
          </div>
        </div>
      </div>

      {/* Mod list placeholder */}
      <div className="card">
        <div className="card-header">
          <h3 className="text-lg font-semibold text-white">Installed Mods</h3>
          <Download className="w-5 h-5 text-ats-primary" />
        </div>
        
        <div className="text-center py-8 text-gray-500">
          <Package className="w-12 h-12 mx-auto mb-4 opacity-50" />
          <p>Mod list interface coming soon</p>
          <p className="text-sm">View and manage individual mods from your collection</p>
        </div>
      </div>
    </div>
  )
}

export default ModCollection
