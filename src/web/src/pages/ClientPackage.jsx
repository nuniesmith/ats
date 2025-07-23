import React, { useState } from 'react'
import { 
  Download, 
  Package, 
  Monitor, 
  Settings, 
  Copy,
  Check,
  ExternalLink,
  Info,
  AlertCircle,
  FileDown
} from 'lucide-react'
import { useServer } from '../contexts/ServerContext'
import { systemAPI, apiUtils } from '../services/api'
import LoadingSpinner from '../components/Common/LoadingSpinner'

function ClientPackage() {
  const { server } = useServer()
  const [packageConfig, setPackageConfig] = useState({
    includeShortcut: true,
    includeInstructions: true,
    includeModInfo: true,
    serverName: server.serverName,
    serverPassword: server.password,
    serverDomain: 'ats.7gram.xyz',
    serverPort: server.port,
  })
  const [generating, setGenerating] = useState(false)
  const [packageReady, setPackageReady] = useState(false)
  const [packageId, setPackageId] = useState(null)
  const [copied, setCopied] = useState(false)

  const handleGeneratePackage = async () => {
    setGenerating(true)
    try {
      const response = await systemAPI.generateClientPackage(packageConfig)
      setPackageId(response.packageId)
      setPackageReady(true)
    } catch (error) {
      console.error('Failed to generate package:', error)
    } finally {
      setGenerating(false)
    }
  }

  const handleDownloadPackage = async () => {
    if (!packageId) return
    
    try {
      const blob = await systemAPI.downloadPackage(packageId)
      apiUtils.downloadBlob(blob, 'ATS_Client_Package.zip')
    } catch (error) {
      console.error('Failed to download package:', error)
    }
  }

  const copyToClipboard = async (text) => {
    try {
      await navigator.clipboard.writeText(text)
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
    } catch (error) {
      console.error('Failed to copy to clipboard:', error)
    }
  }

  const serverConnectCommand = `steam://connect/${packageConfig.serverDomain}:${packageConfig.serverPort}/${packageConfig.serverPassword}`

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl lg:text-3xl font-bold text-white">
          Client Package Generator
        </h1>
        <p className="text-gray-400 mt-1">
          Generate Windows client packages for your players to easily connect to the server
        </p>
      </div>

      {/* Information card */}
      <div className="card">
        <div className="card-header">
          <h3 className="text-lg font-semibold text-white">About Client Packages</h3>
          <Info className="w-5 h-5 text-ats-primary" />
        </div>
        
        <div className="space-y-4">
          <div className="bg-blue-900/20 border border-blue-700 rounded-lg p-4">
            <h4 className="font-medium text-blue-300 mb-2">What's included in the package:</h4>
            <ul className="space-y-1 text-sm text-blue-200">
              <li>• Windows batch script for easy server connection</li>
              <li>• Desktop shortcut creation tool</li>
              <li>• Complete setup instructions</li>
              <li>• Tailscale VPN setup guide</li>
              <li>• Troubleshooting information</li>
            </ul>
          </div>
          
          <div className="bg-yellow-900/20 border border-yellow-700 rounded-lg p-4">
            <h4 className="font-medium text-yellow-300 mb-2">Requirements for players:</h4>
            <ul className="space-y-1 text-sm text-yellow-200">
              <li>• Steam with American Truck Simulator installed</li>
              <li>• Tailscale VPN client (for server access)</li>
              <li>• Windows operating system</li>
            </ul>
          </div>
        </div>
      </div>

      {/* Configuration */}
      <div className="card">
        <div className="card-header">
          <h3 className="text-lg font-semibold text-white">Package Configuration</h3>
          <Settings className="w-5 h-5 text-ats-primary" />
        </div>
        
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Server settings */}
          <div className="space-y-4">
            <h4 className="font-medium text-gray-300">Server Settings</h4>
            
            <div>
              <label className="block text-sm font-medium text-gray-400 mb-2">
                Server Name
              </label>
              <input
                type="text"
                value={packageConfig.serverName}
                onChange={(e) => setPackageConfig(prev => ({ ...prev, serverName: e.target.value }))}
                className="input-field"
                placeholder="Enter server name"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-400 mb-2">
                Server Password
              </label>
              <input
                type="text"
                value={packageConfig.serverPassword}
                onChange={(e) => setPackageConfig(prev => ({ ...prev, serverPassword: e.target.value }))}
                className="input-field"
                placeholder="Enter server password"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-400 mb-2">
                Server Domain
              </label>
              <input
                type="text"
                value={packageConfig.serverDomain}
                onChange={(e) => setPackageConfig(prev => ({ ...prev, serverDomain: e.target.value }))}
                className="input-field"
                placeholder="Enter server domain"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-400 mb-2">
                Server Port
              </label>
              <input
                type="number"
                value={packageConfig.serverPort}
                onChange={(e) => setPackageConfig(prev => ({ ...prev, serverPort: parseInt(e.target.value) }))}
                className="input-field"
                placeholder="27015"
              />
            </div>
          </div>
          
          {/* Package options */}
          <div className="space-y-4">
            <h4 className="font-medium text-gray-300">Package Options</h4>
            
            <div className="space-y-3">
              <label className="flex items-center space-x-3">
                <input
                  type="checkbox"
                  checked={packageConfig.includeShortcut}
                  onChange={(e) => setPackageConfig(prev => ({ ...prev, includeShortcut: e.target.checked }))}
                  className="w-4 h-4 text-ats-primary bg-gray-700 border-gray-600 rounded focus:ring-ats-primary focus:ring-2"
                />
                <span className="text-gray-300">Include desktop shortcut creator</span>
              </label>
              
              <label className="flex items-center space-x-3">
                <input
                  type="checkbox"
                  checked={packageConfig.includeInstructions}
                  onChange={(e) => setPackageConfig(prev => ({ ...prev, includeInstructions: e.target.checked }))}
                  className="w-4 h-4 text-ats-primary bg-gray-700 border-gray-600 rounded focus:ring-ats-primary focus:ring-2"
                />
                <span className="text-gray-300">Include setup instructions</span>
              </label>
              
              <label className="flex items-center space-x-3">
                <input
                  type="checkbox"
                  checked={packageConfig.includeModInfo}
                  onChange={(e) => setPackageConfig(prev => ({ ...prev, includeModInfo: e.target.checked }))}
                  className="w-4 h-4 text-ats-primary bg-gray-700 border-gray-600 rounded focus:ring-ats-primary focus:ring-2"
                />
                <span className="text-gray-300">Include mod collection information</span>
              </label>
            </div>
            
            {/* Preview */}
            <div className="mt-6">
              <h5 className="font-medium text-gray-300 mb-2">Steam Connect URL Preview</h5>
              <div className="bg-gray-800 rounded-lg p-3 font-mono text-sm text-gray-300 break-all">
                {serverConnectCommand}
              </div>
              <button
                onClick={() => copyToClipboard(serverConnectCommand)}
                className="mt-2 btn-outline text-xs flex items-center gap-2"
              >
                {copied ? <Check className="w-3 h-3" /> : <Copy className="w-3 h-3" />}
                {copied ? 'Copied!' : 'Copy URL'}
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Generate package */}
      <div className="card">
        <div className="card-header">
          <h3 className="text-lg font-semibold text-white">Generate Package</h3>
          <Package className="w-5 h-5 text-ats-primary" />
        </div>
        
        <div className="space-y-4">
          {!packageReady ? (
            <div className="text-center py-8">
              <Monitor className="w-16 h-16 mx-auto mb-4 text-ats-primary opacity-50" />
              <h4 className="text-lg font-medium text-white mb-2">
                Ready to generate Windows client package
              </h4>
              <p className="text-gray-400 mb-6">
                This will create a ZIP file containing everything players need to connect to your server
              </p>
              
              <button
                onClick={handleGeneratePackage}
                disabled={generating}
                className="btn-primary disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2 mx-auto"
              >
                {generating ? (
                  <>
                    <LoadingSpinner size="sm" />
                    Generating Package...
                  </>
                ) : (
                  <>
                    <Package className="w-4 h-4" />
                    Generate Client Package
                  </>
                )}
              </button>
            </div>
          ) : (
            <div className="text-center py-8">
              <div className="w-16 h-16 mx-auto mb-4 bg-green-500 rounded-full flex items-center justify-center">
                <Check className="w-8 h-8 text-white" />
              </div>
              <h4 className="text-lg font-medium text-white mb-2">
                Package Generated Successfully!
              </h4>
              <p className="text-gray-400 mb-6">
                Your Windows client package is ready for download
              </p>
              
              <div className="flex items-center justify-center gap-3">
                <button
                  onClick={handleDownloadPackage}
                  className="btn-success flex items-center gap-2"
                >
                  <Download className="w-4 h-4" />
                  Download Package
                </button>
                
                <button
                  onClick={() => {
                    setPackageReady(false)
                    setPackageId(null)
                  }}
                  className="btn-outline"
                >
                  Generate New Package
                </button>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Distribution instructions */}
      <div className="card">
        <div className="card-header">
          <h3 className="text-lg font-semibold text-white">Distribution Instructions</h3>
          <ExternalLink className="w-5 h-5 text-ats-primary" />
        </div>
        
        <div className="space-y-4">
          <div className="bg-gray-800/50 rounded-lg p-4">
            <h4 className="font-medium text-gray-300 mb-3">How to distribute the package to players:</h4>
            
            <ol className="space-y-2 text-sm text-gray-400 list-decimal list-inside">
              <li>Download the generated ZIP file</li>
              <li>Share the ZIP file via Discord, email, or file sharing service</li>
              <li>Provide players with the Server ID (they'll need this to connect)</li>
              <li>Ensure players have Tailscale installed and are connected to your VPN</li>
              <li>Players extract the ZIP and follow the included instructions</li>
            </ol>
          </div>
          
          <div className="bg-blue-900/20 border border-blue-700 rounded-lg p-4">
            <div className="flex items-start gap-3">
              <AlertCircle className="w-5 h-5 text-blue-400 mt-0.5 flex-shrink-0" />
              <div>
                <h5 className="font-medium text-blue-300 mb-1">Important Notes:</h5>
                <ul className="space-y-1 text-sm text-blue-200">
                  <li>• Players must be connected to Tailscale VPN to access the server</li>
                  <li>• The Server ID changes each time you create a new server instance</li>
                  <li>• Share the current Server ID via Discord when players need to connect</li>
                  <li>• The package includes troubleshooting steps for common issues</li>
                </ul>
              </div>
            </div>
          </div>
          
          <div className="bg-gray-800/50 rounded-lg p-4">
            <h4 className="font-medium text-gray-300 mb-2">Current Server Information:</h4>
            <div className="grid grid-cols-2 gap-4 text-sm">
              <div>
                <span className="text-gray-500">Server Name:</span>
                <span className="text-white ml-2">{server.serverName}</span>
              </div>
              <div>
                <span className="text-gray-500">Password:</span>
                <span className="text-white ml-2">{server.password}</span>
              </div>
              <div>
                <span className="text-gray-500">Domain:</span>
                <span className="text-white ml-2">ats.7gram.xyz</span>
              </div>
              <div>
                <span className="text-gray-500">Port:</span>
                <span className="text-white ml-2">{server.port}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default ClientPackage
