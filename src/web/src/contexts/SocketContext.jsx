import React, { createContext, useContext, useEffect, useState, useRef } from 'react'
import { io } from 'socket.io-client'
import { useServer } from './ServerContext'
// Note: react-hot-toast will be replaced with a simpler toast system
const toast = {
  loading: (msg, opts) => console.log('Loading:', msg),
  success: (msg, opts) => console.log('Success:', msg),
  error: (msg, opts) => console.log('Error:', msg),
}

const SocketContext = createContext()

export function SocketProvider({ children }) {
  const [socket, setSocket] = useState(null)
  const [connected, setConnected] = useState(false)
  const [logs, setLogs] = useState([])
  const { actions } = useServer()
  const reconnectAttempts = useRef(0)
  const maxReconnectAttempts = 5

  useEffect(() => {
    // Initialize socket connection
    const newSocket = io(process.env.NODE_ENV === 'production' 
      ? 'https://ats.7gram.xyz' 
      : 'http://localhost:4000', {
      transports: ['websocket', 'polling'],
      timeout: 20000,
      reconnection: true,
      reconnectionDelay: 1000,
      reconnectionDelayMax: 5000,
      reconnectionAttempts: maxReconnectAttempts,
    })

    // Connection event handlers
    newSocket.on('connect', () => {
      console.log('✅ Socket connected:', newSocket.id)
      setConnected(true)
      reconnectAttempts.current = 0
      toast.success('Connected to server', { id: 'socket-connection' })
    })

    newSocket.on('disconnect', (reason) => {
      console.log('❌ Socket disconnected:', reason)
      setConnected(false)
      
      if (reason === 'io server disconnect') {
        // Server initiated disconnect, don't auto-reconnect
        toast.error('Server disconnected', { id: 'socket-connection' })
      } else {
        // Client-side disconnect, will auto-reconnect
        toast.loading('Reconnecting...', { id: 'socket-connection' })
      }
    })

    newSocket.on('connect_error', (error) => {
      console.error('Socket connection error:', error)
      reconnectAttempts.current += 1
      
      if (reconnectAttempts.current >= maxReconnectAttempts) {
        toast.error('Failed to connect to server', { id: 'socket-connection' })
      }
    })

    newSocket.on('reconnect', (attemptNumber) => {
      console.log(`🔄 Socket reconnected after ${attemptNumber} attempts`)
      toast.success('Reconnected to server', { id: 'socket-connection' })
    })

    newSocket.on('reconnect_failed', () => {
      console.error('❌ Socket reconnection failed')
      toast.error('Failed to reconnect to server', { id: 'socket-connection' })
    })

    // Server status events
    newSocket.on('server:status', (data) => {
      console.log('📊 Server status update:', data)
      // The ServerContext will handle this via queries
    })

    newSocket.on('server:started', () => {
      console.log('🟢 Server started')
      toast.success('Server is now online!')
    })

    newSocket.on('server:stopped', () => {
      console.log('🔴 Server stopped')
      toast.error('Server is now offline')
    })

    newSocket.on('server:error', (error) => {
      console.error('❌ Server error:', error)
      toast.error(`Server error: ${error.message}`)
    })

    // Player events
    newSocket.on('player:joined', (player) => {
      console.log('👤 Player joined:', player)
      toast.success(`${player.name} joined the server`)
      setLogs(prev => [...prev, {
        id: Date.now(),
        timestamp: new Date(),
        type: 'player',
        level: 'info',
        message: `Player ${player.name} joined the server`,
        data: player
      }])
    })

    newSocket.on('player:left', (player) => {
      console.log('👋 Player left:', player)
      toast(`${player.name} left the server`, { icon: '👋' })
      setLogs(prev => [...prev, {
        id: Date.now() + 1,
        timestamp: new Date(),
        type: 'player',
        level: 'info',
        message: `Player ${player.name} left the server`,
        data: player
      }])
    })

    // Mod events
    newSocket.on('mods:updating', () => {
      console.log('🔄 Mods updating...')
      toast.loading('Updating mods...', { id: 'mods-update' })
    })

    newSocket.on('mods:updated', (modData) => {
      console.log('✅ Mods updated:', modData)
      toast.success('Mods updated successfully!', { id: 'mods-update' })
    })

    newSocket.on('mods:error', (error) => {
      console.error('❌ Mod update error:', error)
      toast.error(`Mod update failed: ${error.message}`, { id: 'mods-update' })
    })

    // Log events
    newSocket.on('log:entry', (logEntry) => {
      setLogs(prev => {
        const newLogs = [...prev, {
          id: logEntry.id || Date.now(),
          timestamp: new Date(logEntry.timestamp),
          type: logEntry.type || 'server',
          level: logEntry.level || 'info',
          message: logEntry.message,
          data: logEntry.data
        }]
        
        // Keep only last 1000 log entries
        return newLogs.slice(-1000)
      })
    })

    // System events
    newSocket.on('system:metrics', (metrics) => {
      // Handle system metrics updates
      console.log('📈 System metrics:', metrics)
    })

    newSocket.on('system:alert', (alert) => {
      console.warn('⚠️ System alert:', alert)
      
      switch (alert.level) {
        case 'error':
          toast.error(alert.message)
          break
        case 'warning':
          toast(alert.message, { icon: '⚠️' })
          break
        case 'info':
          toast(alert.message, { icon: 'ℹ️' })
          break
        default:
          toast(alert.message)
      }
    })

    setSocket(newSocket)

    // Cleanup on unmount
    return () => {
      console.log('🧹 Cleaning up socket connection')
      newSocket.close()
    }
  }, [])

  // Socket methods
  const emit = (event, data) => {
    if (socket && connected) {
      socket.emit(event, data)
    } else {
      console.warn('Socket not connected, cannot emit event:', event)
      toast.error('Not connected to server')
    }
  }

  const emitWithCallback = (event, data) => {
    return new Promise((resolve, reject) => {
      if (socket && connected) {
        socket.emit(event, data, (response) => {
          if (response.success) {
            resolve(response.data)
          } else {
            reject(new Error(response.error))
          }
        })
      } else {
        reject(new Error('Socket not connected'))
      }
    })
  }

  // Clear logs
  const clearLogs = () => {
    setLogs([])
  }

  // Filter logs
  const getLogsByType = (type) => {
    return logs.filter(log => log.type === type)
  }

  const getLogsByLevel = (level) => {
    return logs.filter(log => log.level === level)
  }

  const value = {
    socket,
    connected,
    logs,
    emit,
    emitWithCallback,
    clearLogs,
    getLogsByType,
    getLogsByLevel,
  }

  return (
    <SocketContext.Provider value={value}>
      {children}
    </SocketContext.Provider>
  )
}

export function useSocket() {
  const context = useContext(SocketContext)
  if (!context) {
    throw new Error('useSocket must be used within a SocketProvider')
  }
  return context
}

export default SocketContext
