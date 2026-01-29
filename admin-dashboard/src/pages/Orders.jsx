import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { orderService } from '../services/api'
import toast from 'react-hot-toast'
import { Eye, X } from 'lucide-react'

const STATUS_OPTIONS = ['pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled']

export default function Orders() {
  const [page, setPage] = useState(1)
  const [statusFilter, setStatusFilter] = useState('')
  const [detailOrderId, setDetailOrderId] = useState(null)
  const queryClient = useQueryClient()

  const { data, isLoading, error } = useQuery({
    queryKey: ['orders', page, statusFilter],
    queryFn: async () => {
      const params = { page, limit: 10 }
      if (statusFilter) params.status = statusFilter
      const res = await orderService.getAll(params)
      if (res.data.success) return { orders: res.data.data, pagination: res.data.pagination }
      throw new Error(res.data.message)
    },
  })

  const { data: orderDetail, isLoading: detailLoading } = useQuery({
    queryKey: ['order', detailOrderId],
    queryFn: async () => {
      const res = await orderService.getById(detailOrderId)
      if (res.data.success) return res.data.data
      throw new Error(res.data.message)
    },
    enabled: !!detailOrderId,
  })

  const updateStatusMutation = useMutation({
    mutationFn: ({ id, status }) => orderService.updateStatus(id, status),
    onSuccess: () => {
      queryClient.invalidateQueries(['orders'])
      if (detailOrderId) queryClient.invalidateQueries(['order', detailOrderId])
      toast.success('Order status updated')
      setDetailOrderId(null)
    },
    onError: (e) => toast.error(e.response?.data?.message || 'Failed to update status'),
  })

  const formatDate = (d) => (d ? new Date(d).toLocaleString('en-IN', { dateStyle: 'short', timeStyle: 'short' }) : '–')
  const formatMoney = (n) => `₹${Number(n).toLocaleString()}`

  const orders = data?.orders || []
  const pagination = data?.pagination || {}

  const getStatusColor = (status) => {
    const map = {
      pending: 'bg-yellow-100 text-yellow-800',
      confirmed: 'bg-blue-100 text-blue-800',
      processing: 'bg-indigo-100 text-indigo-800',
      shipped: 'bg-purple-100 text-purple-800',
      delivered: 'bg-green-100 text-green-800',
      cancelled: 'bg-red-100 text-red-800',
    }
    return map[status] || 'bg-gray-100 text-gray-800'
  }

  return (
    <div>
      <div className="flex justify-between items-center mb-6 flex-wrap gap-4">
        <h1 className="text-3xl font-bold text-gray-900">Orders</h1>
        <select
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value)}
          className="border border-gray-300 rounded-lg px-3 py-2"
        >
          <option value="">All statuses</option>
          {STATUS_OPTIONS.map((s) => (
            <option key={s} value={s}>{s}</option>
          ))}
        </select>
      </div>

      {isLoading ? (
        <div className="bg-white rounded-lg shadow p-12 text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto" />
          <p className="mt-4 text-gray-600">Loading orders...</p>
        </div>
      ) : error ? (
        <div className="bg-red-50 border border-red-200 rounded-lg p-4 text-center">
          <p className="text-red-800">{error.message}</p>
        </div>
      ) : orders.length === 0 ? (
        <div className="bg-white rounded-lg shadow p-12 text-center">
          <p className="text-gray-500 text-lg">No orders found.</p>
        </div>
      ) : (
        <>
          <div className="bg-white rounded-lg shadow overflow-hidden">
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Order #</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Customer</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Total</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Date</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {orders.map((order) => (
                    <tr key={order._id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 text-sm font-medium text-gray-900">{order.orderNumber}</td>
                      <td className="px-6 py-4 text-sm text-gray-600">
                        {order.user?.name || '–'}<br />
                        <span className="text-xs text-gray-500">{order.user?.email}</span>
                      </td>
                      <td className="px-6 py-4 text-sm font-medium">{formatMoney(order.total)}</td>
                      <td className="px-6 py-4">
                        <span className={`px-2 py-1 text-xs rounded-full ${getStatusColor(order.status)}`}>
                          {order.status}
                        </span>
                      </td>
                      <td className="px-6 py-4 text-sm text-gray-500">{formatDate(order.createdAt)}</td>
                      <td className="px-6 py-4">
                        <button
                          onClick={() => setDetailOrderId(order._id)}
                          className="text-primary-600 hover:text-primary-800 flex items-center gap-1"
                          title="View details"
                        >
                          <Eye className="w-4 h-4" /> View
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
          {pagination.pages > 1 && (
            <div className="mt-6 flex justify-between items-center">
              <p className="text-sm text-gray-600">Page {pagination.page} of {pagination.pages} ({pagination.total} total)</p>
              <div className="flex gap-2">
                <button
                  onClick={() => setPage((p) => Math.max(1, p - 1))}
                  disabled={page === 1}
                  className="px-4 py-2 border rounded-lg disabled:opacity-50"
                >Previous</button>
                <button
                  onClick={() => setPage((p) => Math.min(pagination.pages, p + 1))}
                  disabled={page === pagination.pages}
                  className="px-4 py-2 border rounded-lg disabled:opacity-50"
                >Next</button>
              </div>
            </div>
          )}
        </>
      )}

      {detailOrderId && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-xl shadow-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <div className="flex justify-between items-center p-4 border-b sticky top-0 bg-white">
              <h2 className="text-xl font-semibold">Order details</h2>
              <button onClick={() => setDetailOrderId(null)} className="p-1 hover:bg-gray-100 rounded"><X className="w-5 h-5" /></button>
            </div>
            <div className="p-4">
              {detailLoading ? (
                <p className="text-gray-500">Loading...</p>
              ) : orderDetail ? (
                <div className="space-y-4">
                  <div className="grid grid-cols-2 gap-4 text-sm">
                    <div><span className="text-gray-500">Order #</span> {orderDetail.orderNumber}</div>
                    <div><span className="text-gray-500">Date</span> {formatDate(orderDetail.createdAt)}</div>
                    <div><span className="text-gray-500">Status</span>
                      <span className={`ml-2 px-2 py-0.5 text-xs rounded-full ${getStatusColor(orderDetail.status)}`}>{orderDetail.status}</span>
                    </div>
                    <div><span className="text-gray-500">Payment</span> {orderDetail.paymentStatus} / {orderDetail.paymentMethod}</div>
                  </div>
                  <div>
                    <h3 className="font-medium text-gray-900 mb-2">Customer</h3>
                    <p>{orderDetail.user?.name} – {orderDetail.user?.email} – {orderDetail.user?.phoneNumber}</p>
                  </div>
                  {orderDetail.shippingAddress && (
                    <div>
                      <h3 className="font-medium text-gray-900 mb-2">Shipping address</h3>
                      <p className="text-sm text-gray-600">
                        {orderDetail.shippingAddress.name}, {orderDetail.shippingAddress.phone}<br />
                        {orderDetail.shippingAddress.addressLine1}<br />
                        {orderDetail.shippingAddress.addressLine2 && <>{orderDetail.shippingAddress.addressLine2}<br /></>}
                        {orderDetail.shippingAddress.city}, {orderDetail.shippingAddress.state} {orderDetail.shippingAddress.pincode}
                      </p>
                    </div>
                  )}
                  <div>
                    <h3 className="font-medium text-gray-900 mb-2">Items</h3>
                    <ul className="border rounded-lg divide-y">
                      {orderDetail.items?.map((item, i) => (
                        <li key={i} className="px-4 py-3 flex justify-between text-sm">
                          <span>{item.name} × {item.quantity}</span>
                          <span>{formatMoney(item.total)}</span>
                        </li>
                      ))}
                    </ul>
                  </div>
                  <div className="text-right font-medium">
                    Subtotal: {formatMoney(orderDetail.subtotal)}<br />
                    {orderDetail.shippingCost > 0 && <>Shipping: {formatMoney(orderDetail.shippingCost)}<br /></>}
                    Total: {formatMoney(orderDetail.total)}
                  </div>
                  {orderDetail.status !== 'cancelled' && orderDetail.status !== 'delivered' && (
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">Update status</label>
                      <div className="flex gap-2 flex-wrap">
                        {STATUS_OPTIONS.filter((s) => s !== orderDetail.status).map((status) => (
                          <button
                            key={status}
                            onClick={() => updateStatusMutation.mutate({ id: orderDetail._id, status })}
                            disabled={updateStatusMutation.isLoading}
                            className="px-3 py-1.5 border rounded-lg text-sm hover:bg-gray-50 disabled:opacity-50"
                          >
                            Set {status}
                          </button>
                        ))}
                      </div>
                    </div>
                  )}
                </div>
              ) : (
                <p className="text-gray-500">Could not load order.</p>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
