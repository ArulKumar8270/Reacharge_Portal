import axios from 'axios'

/**
 * API Configuration
 * 
 * Backend API Base URL configuration:
 * - Default: http://localhost:3000/api/v1
 * - Backend PORT is configured in backend/.env (default: 3000 from ENV_CONFIG.txt)
 * - Override with VITE_API_URL environment variable in .env file
 * 
 * Example .env file:
 * VITE_API_URL=http://localhost:3000/api/v1
 */
const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000/api/v1'

// Ensure API URL is HTTP (not HTTPS) for local development to avoid SSL errors
const normalizedApiUrl = API_BASE_URL.replace(/^https:/, 'http:')

// Log API URL in development
if (import.meta.env.DEV) {
  console.log('🔗 API Base URL:', normalizedApiUrl)
  if (API_BASE_URL !== normalizedApiUrl) {
    console.warn('⚠️  HTTPS detected in API URL, converted to HTTP:', API_BASE_URL, '→', normalizedApiUrl)
  }
}

const api = axios.create({
  baseURL: normalizedApiUrl,
  headers: {
    'Content-Type': 'application/json',
  },
  // Timeout for requests
  timeout: 30000,
})

// Request interceptor to add auth token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('admin_token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// Response interceptor to handle errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    // Handle SSL/TLS errors
    if (error.code === 'ERR_BAD_REQUEST' || 
        error.message?.includes('SSL') || 
        error.message?.includes('TLS') ||
        error.code === 'ECONNRESET' ||
        (error.response?.data?.message?.includes('SSL'))) {
      console.error('SSL/TLS Error detected')
      console.error('Error details:', {
        code: error.code,
        message: error.message,
        apiUrl: normalizedApiUrl,
      })
      return Promise.reject({
        ...error,
        message: 'SSL/TLS connection error. Ensure API URL uses HTTP (not HTTPS) for local development.',
        userMessage: 'Connection error. Please check your API configuration and ensure the backend is running on HTTP.',
      })
    }

    // Handle network errors
    if (error.code === 'ERR_NETWORK' || error.code === 'ECONNREFUSED') {
      return Promise.reject({
        ...error,
        message: 'Network error. Please ensure the backend server is running.',
        userMessage: 'Cannot connect to server. Please check if the backend is running on port 3000.',
      })
    }

    // Handle 401 Unauthorized
    if (error.response?.status === 401) {
      localStorage.removeItem('admin_token')
      window.location.href = '/login'
    }

    return Promise.reject(error)
  }
)

export const authService = {
  login: (email, password) => api.post('/admin/auth/login', { email, password }),
  getProfile: () => api.get('/admin/auth/me'),
}

export const userService = {
  getAll: (params) => api.get('/admin/users', { params }),
  getById: (id) => api.get(`/admin/users/${id}`),
  update: (id, data) => api.put(`/admin/users/${id}`, data),
  delete: (id) => api.delete(`/admin/users/${id}`),
}

export const productService = {
  getAll: (params) => api.get('/admin/products', { params }),
  getById: (id) => api.get(`/admin/products/${id}`),
  create: (data) => api.post('/admin/products', data),
  update: (id, data) => api.put(`/admin/products/${id}`, data),
  delete: (id) => api.delete(`/admin/products/${id}`),
}

export const categoryService = {
  getAll: () => api.get('/admin/categories'),
  getById: (id) => api.get(`/admin/categories/${id}`),
  create: (data) => api.post('/admin/categories', data),
  update: (id, data) => api.put(`/admin/categories/${id}`, data),
  delete: (id) => api.delete(`/admin/categories/${id}`),
}

export const orderService = {
  getAll: (params) => api.get('/admin/orders', { params }),
  getById: (id) => api.get(`/admin/orders/${id}`),
  updateStatus: (id, status) => api.put(`/admin/orders/${id}/status`, { status }),
}

export const transactionService = {
  getAll: (params) => api.get('/admin/transactions', { params }),
  getById: (id) => api.get(`/admin/transactions/${id}`),
}

export const reportService = {
  getDashboardStats: () => api.get('/admin/reports/dashboard'),
  getSalesReport: (params) => api.get('/admin/reports/sales', { params }),
  getRevenueReport: (params) => api.get('/admin/reports/revenue', { params }),
}

export default api

