import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { transactionService } from '../services/api'

export default function Transactions() {
  const [page, setPage] = useState(1)

  const { data, isLoading, error } = useQuery({
    queryKey: ['transactions', page],
    queryFn: async () => {
      const res = await transactionService.getAll({ page, limit: 20 })
      if (res.data.success) return { transactions: res.data.data, pagination: res.data.pagination }
      throw new Error(res.data.message)
    },
  })

  const transactions = data?.transactions || []
  const pagination = data?.pagination || {}

  const formatDate = (d) => (d ? new Date(d).toLocaleString('en-IN', { dateStyle: 'short', timeStyle: 'short' }) : '–')
  const getStatusColor = (s) => ({ completed: 'bg-green-100 text-green-800', pending: 'bg-yellow-100 text-yellow-800', failed: 'bg-red-100 text-red-800', cancelled: 'bg-gray-100 text-gray-600' }[s] || 'bg-gray-100')

  return (
    <div>
      <h1 className="text-3xl font-bold text-gray-900 mb-6">Transactions</h1>
      {isLoading ? (
        <div className="bg-white rounded-lg shadow p-12 text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto" />
          <p className="mt-4 text-gray-600">Loading...</p>
        </div>
      ) : error ? (
        <div className="bg-red-50 border border-red-200 rounded-lg p-4 text-center">
          <p className="text-red-800">{error.message}</p>
        </div>
      ) : transactions.length === 0 ? (
        <div className="bg-white rounded-lg shadow p-12 text-center text-gray-500">No transactions found.</div>
      ) : (
        <>
          <div className="bg-white rounded-lg shadow overflow-hidden">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">User</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Type</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Amount</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Description</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Date</th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {transactions.map((t) => (
                  <tr key={t._id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 text-sm text-gray-900">{t.userId?.name || t.userId?.email || t.userId?._id || '–'}</td>
                    <td className="px-6 py-4 text-sm">{t.type}</td>
                    <td className="px-6 py-4 text-sm font-medium">{t.type === 'credit' ? '+' : '-'}₹{Number(t.amount).toLocaleString()}</td>
                    <td className="px-6 py-4"><span className={`px-2 py-1 text-xs rounded-full ${getStatusColor(t.status)}`}>{t.status}</span></td>
                    <td className="px-6 py-4 text-sm text-gray-600">{t.description || '–'}</td>
                    <td className="px-6 py-4 text-sm text-gray-500">{formatDate(t.createdAt)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          {pagination.pages > 1 && (
            <div className="mt-6 flex justify-between items-center">
              <p className="text-sm text-gray-600">Page {pagination.page} of {pagination.pages}</p>
              <div className="flex gap-2">
                <button onClick={() => setPage((p) => Math.max(1, p - 1))} disabled={page === 1} className="px-4 py-2 border rounded-lg disabled:opacity-50">Previous</button>
                <button onClick={() => setPage((p) => p + 1)} disabled={page === pagination.pages} className="px-4 py-2 border rounded-lg disabled:opacity-50">Next</button>
              </div>
            </div>
          )}
        </>
      )}
    </div>
  )
}
