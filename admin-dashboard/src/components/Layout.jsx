import { Outlet, Link, useLocation, useNavigate } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'
import { LogOut, LayoutDashboard, Users, Package, ShoppingCart, CreditCard, BarChart3, FolderTree } from 'lucide-react'
import toast from 'react-hot-toast'

export default function Layout() {
  const { logout, user } = useAuth()
  const location = useLocation()
  const navigate = useNavigate()

  const handleLogout = () => {
    logout()
    toast.success('Logged out successfully')
    navigate('/login', { replace: true })
  }

  const menuItems = [
    { path: '/dashboard', label: 'Dashboard', icon: LayoutDashboard },
    { path: '/users', label: 'Users', icon: Users },
    { path: '/products', label: 'Products', icon: Package },
    { path: '/categories', label: 'Categories', icon: FolderTree },
    { path: '/orders', label: 'Orders', icon: ShoppingCart },
    { path: '/transactions', label: 'Transactions', icon: CreditCard },
    { path: '/reports', label: 'Reports', icon: BarChart3 },
  ]

  return (
    <div className="flex h-screen bg-gray-100">
      {/* Sidebar */}
      <aside className="w-64 bg-white shadow-lg relative">
        <div className="p-6 border-b">
          <h1 className="text-2xl font-bold text-indigo-600">Nexus Admin</h1>
          {user && (
            <div className="mt-4">
              <p className="text-sm font-medium text-gray-700">{user.name || user.email}</p>
              <p className="text-xs text-gray-500">{user.email}</p>
            </div>
          )}
        </div>
        <nav className="mt-6">
          {menuItems.map((item) => {
            const Icon = item.icon
            const isActive = location.pathname === item.path
            return (
              <Link
                key={item.path}
                to={item.path}
                className={`flex items-center px-6 py-3 text-gray-700 hover:bg-indigo-50 hover:text-indigo-600 transition ${
                  isActive ? 'bg-indigo-50 text-indigo-600 border-r-2 border-indigo-600' : ''
                }`}
              >
                <Icon className="w-5 h-5 mr-3" />
                {item.label}
              </Link>
            )
          })}
        </nav>
        <div className="absolute bottom-0 w-64 p-6 border-t">
          <button
            onClick={handleLogout}
            className="flex items-center w-full px-6 py-3 text-gray-700 hover:bg-red-50 hover:text-red-600 rounded transition"
          >
            <LogOut className="w-5 h-5 mr-3" />
            Logout
          </button>
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex-1 overflow-y-auto">
        <div className="p-8">
          <Outlet />
        </div>
      </main>
    </div>
  )
}

