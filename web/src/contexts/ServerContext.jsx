import React, { createContext, useContext, useReducer, useEffect } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { serverAPI } from '../services/api'
// Note: react-hot-toast will be replaced with a simpler toast system
const toast = {
  loading: (msg, opts) => console.log('Loading:', msg),
  success: (msg, opts) => console.log('Success:', msg),
  error: (msg, opts) => console.log('Error:', msg),
}

// Initial state
const initialState = {
  server: {
    status: 'offline',
    players: [],
    maxPlayers: 8,
    currentPlayers: 0,
    serverName: "Freddy's ATS Dedicated Server",
    password: 'ruby',
    ip: '',
    tailscaleIp: '',
    port: 27015,
    uptime: 0,
    version: '',
    mods: [],
    modCount: 0,
    collectionId: '3530633316',
  },
  metrics: {
    cpu: 0,
    memory: 0,
    disk: 0,
    network: { in: 0, out: 0 },
  },
  loading: false,
  error: null,
}

// Action types
const actionTypes = {
  SET_LOADING: 'SET_LOADING',
  SET_ERROR: 'SET_ERROR',
  SET_SERVER_STATUS: 'SET_SERVER_STATUS',
  UPDATE_SERVER_INFO: 'UPDATE_SERVER_INFO',
  UPDATE_PLAYERS: 'UPDATE_PLAYERS',
  UPDATE_METRICS: 'UPDATE_METRICS',
  UPDATE_MODS: 'UPDATE_MODS',
  CLEAR_ERROR: 'CLEAR_ERROR',
}

// Reducer
function serverReducer(state, action) {
  switch (action.type) {
    case actionTypes.SET_LOADING:
      return { ...state, loading: action.payload }
    
    case actionTypes.SET_ERROR:
      return { ...state, error: action.payload, loading: false }
    
    case actionTypes.CLEAR_ERROR:
      return { ...state, error: null }
    
    case actionTypes.SET_SERVER_STATUS:
      return {
        ...state,
        server: { ...state.server, status: action.payload },
        loading: false
      }
    
    case actionTypes.UPDATE_SERVER_INFO:
      return {
        ...state,
        server: { ...state.server, ...action.payload },
        loading: false
      }
    
    case actionTypes.UPDATE_PLAYERS:
      return {
        ...state,
        server: {
          ...state.server,
          players: action.payload,
          currentPlayers: action.payload.length
        }
      }
    
    case actionTypes.UPDATE_METRICS:
      return {
        ...state,
        metrics: { ...state.metrics, ...action.payload }
      }
    
    case actionTypes.UPDATE_MODS:
      return {
        ...state,
        server: {
          ...state.server,
          mods: action.payload,
          modCount: action.payload.length
        }
      }
    
    default:
      return state
  }
}

// Create context
const ServerContext = createContext()

// Provider component
export function ServerProvider({ children }) {
  const [state, dispatch] = useReducer(serverReducer, initialState)
  const queryClient = useQueryClient()

  // Query for server status
  const { data: serverStatus, isLoading: statusLoading } = useQuery({
    queryKey: ['serverStatus'],
    queryFn: serverAPI.getStatus,
    refetchInterval: 5000, // Refetch every 5 seconds
    onSuccess: (data) => {
      dispatch({ type: actionTypes.UPDATE_SERVER_INFO, payload: data })
    },
    onError: (error) => {
      dispatch({ type: actionTypes.SET_ERROR, payload: error.message })
    }
  })

  // Query for server metrics
  const { data: serverMetrics } = useQuery({
    queryKey: ['serverMetrics'],
    queryFn: serverAPI.getMetrics,
    refetchInterval: 10000, // Refetch every 10 seconds
    onSuccess: (data) => {
      dispatch({ type: actionTypes.UPDATE_METRICS, payload: data })
    }
  })

  // Query for players
  const { data: players } = useQuery({
    queryKey: ['players'],
    queryFn: serverAPI.getPlayers,
    refetchInterval: 15000, // Refetch every 15 seconds
    onSuccess: (data) => {
      dispatch({ type: actionTypes.UPDATE_PLAYERS, payload: data })
    }
  })

  // Query for mods
  const { data: mods } = useQuery({
    queryKey: ['mods'],
    queryFn: serverAPI.getMods,
    refetchInterval: 60000, // Refetch every minute
    onSuccess: (data) => {
      dispatch({ type: actionTypes.UPDATE_MODS, payload: data })
    }
  })

  // Mutations
  const startServerMutation = useMutation({
    mutationFn: serverAPI.startServer,
    onMutate: () => {
      dispatch({ type: actionTypes.SET_LOADING, payload: true })
      toast.loading('Starting server...', { id: 'server-start' })
    },
    onSuccess: () => {
      toast.success('Server started successfully!', { id: 'server-start' })
      queryClient.invalidateQueries(['serverStatus'])
    },
    onError: (error) => {
      toast.error(`Failed to start server: ${error.message}`, { id: 'server-start' })
      dispatch({ type: actionTypes.SET_ERROR, payload: error.message })
    }
  })

  const stopServerMutation = useMutation({
    mutationFn: serverAPI.stopServer,
    onMutate: () => {
      dispatch({ type: actionTypes.SET_LOADING, payload: true })
      toast.loading('Stopping server...', { id: 'server-stop' })
    },
    onSuccess: () => {
      toast.success('Server stopped successfully!', { id: 'server-stop' })
      queryClient.invalidateQueries(['serverStatus'])
    },
    onError: (error) => {
      toast.error(`Failed to stop server: ${error.message}`, { id: 'server-stop' })
      dispatch({ type: actionTypes.SET_ERROR, payload: error.message })
    }
  })

  const restartServerMutation = useMutation({
    mutationFn: serverAPI.restartServer,
    onMutate: () => {
      dispatch({ type: actionTypes.SET_LOADING, payload: true })
      toast.loading('Restarting server...', { id: 'server-restart' })
    },
    onSuccess: () => {
      toast.success('Server restarted successfully!', { id: 'server-restart' })
      queryClient.invalidateQueries(['serverStatus'])
    },
    onError: (error) => {
      toast.error(`Failed to restart server: ${error.message}`, { id: 'server-restart' })
      dispatch({ type: actionTypes.SET_ERROR, payload: error.message })
    }
  })

  const updateModsMutation = useMutation({
    mutationFn: serverAPI.updateMods,
    onMutate: () => {
      toast.loading('Updating mods...', { id: 'mods-update' })
    },
    onSuccess: () => {
      toast.success('Mods updated successfully!', { id: 'mods-update' })
      queryClient.invalidateQueries(['mods'])
    },
    onError: (error) => {
      toast.error(`Failed to update mods: ${error.message}`, { id: 'mods-update' })
    }
  })

  // Actions
  const actions = {
    startServer: startServerMutation.mutate,
    stopServer: stopServerMutation.mutate,
    restartServer: restartServerMutation.mutate,
    updateMods: updateModsMutation.mutate,
    clearError: () => dispatch({ type: actionTypes.CLEAR_ERROR }),
  }

  // Context value
  const value = {
    ...state,
    actions,
    isLoading: statusLoading || state.loading,
    mutations: {
      startServer: startServerMutation,
      stopServer: stopServerMutation,
      restartServer: restartServerMutation,
      updateMods: updateModsMutation,
    }
  }

  return (
    <ServerContext.Provider value={value}>
      {children}
    </ServerContext.Provider>
  )
}

// Hook to use server context
export function useServer() {
  const context = useContext(ServerContext)
  if (!context) {
    throw new Error('useServer must be used within a ServerProvider')
  }
  return context
}

export default ServerContext
