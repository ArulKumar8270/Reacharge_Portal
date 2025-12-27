import { createContext, useContext, useState, useEffect } from 'react'
import { authService } from '../services/api'

const AuthContext = createContext()

export function useAuth() {
  return useContext(AuthContext)
}

export function AuthProvider({ children }) {
  const [isAuthenticated, setIsAuthenticated] = useState(false)
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const token = localStorage.getItem('admin_token')
    if (token) {
      setIsAuthenticated(true)
      // Fetch user details
      fetchUserDetails()
    } else {
      setLoading(false)
    }
  }, [])

  const fetchUserDetails = async () => {
    try {
      const response = await authService.getProfile()
      if (response.data.success) {
        setUser(response.data.data)
        setIsAuthenticated(true)
      } else {
        throw new Error(response.data.message || 'Failed to fetch profile')
      }
    } catch (error) {
      localStorage.removeItem('admin_token')
      setIsAuthenticated(false)
      setUser(null)
    } finally {
      setLoading(false)
    }
  }

  const login = async (email, password) => {
    try {
      const response = await authService.login(email, password)
      
      if (response.data.success) {
        const { token, user } = response.data.data
        localStorage.setItem('admin_token', token)
        setUser(user)
        setIsAuthenticated(true)
        return { success: true, message: response.data.message || 'Login successful' }
      } else {
        return {
          success: false,
          message: response.data.message || 'Login failed',
        }
      }
    } catch (error) {
      // Handle SSL/connection errors with user-friendly messages
      const errorMessage = error.userMessage || 
                          error.response?.data?.message || 
                          error.message || 
                          'Login failed. Please try again.'
      
      // Log detailed error for debugging
      if (error.message?.includes('SSL') || error.message?.includes('TLS') || error.code === 'ERR_NETWORK') {
        console.error('Connection Error:', {
          message: error.message,
          code: error.code,
          apiUrl: import.meta.env.VITE_API_URL || 'http://localhost:3000/api/v1',
        })
      }
      
      return {
        success: false,
        message: errorMessage,
      }
    }
  }

  const logout = () => {
    localStorage.removeItem('admin_token')
    setUser(null)
    setIsAuthenticated(false)
  }

  const value = {
    isAuthenticated,
    user,
    loading,
    login,
    logout,
  }

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

