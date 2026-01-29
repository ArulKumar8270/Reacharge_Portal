import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { reportService } from '../services/api'
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid } from 'recharts'

export default function Reports() {
  const [salesDays, setSalesDays] = useState(30)
  const endDate = new Date()
  const startDate = new Date()
  startDate.setDate(startDate.getDate() - salesDays)

  const { data: salesData, isLoading: salesLoading } = useQuery({
    queryKey: ['salesReport', salesDays],
    queryFn: async () => {
      const res = await reportService.getSalesReport({
        startDate: startDate.toISOString().split('T')[0],
        endDate: endDate.toISOString().split('T')[0],
      })
      if (res.data.success) return res.data.data
      throw new Error(res.data.message)
    },
  })

  const { data: revenueData } = useQuery({
    queryKey: ['revenueReport', salesDays],
    queryFn: async () => {
      const res = await reportService.getRevenueReport({
        startDate: startDate.toISOString().split('T')[0],
        endDate: endDate.toISOString().split('T')[0],
      })
      if (res.data.success) return res.data.data
      throw new Error(res.data.message)
    },
  })

  const chartData = Array.isArray(salesData) ? salesData.map((d) => ({ date: d._id, orders: d.count, revenue: d.revenue || 0 })) : []

  return (
    <div>
      <div className="flex justify-between items-center mb-6 flex-wrap gap-4">
        <h1 className="text-3xl font-bold text-gray-900">Reports & Analytics</h1>
        <select
          value={salesDays}
          onChange={(e) => setSalesDays(Number(e.target.value))}
          className="border border-gray-300 rounded-lg px-3 py-2"
        >
          <option value={7}>Last 7 days</option>
          <option value={30}>Last 30 days</option>
          <option value={90}>Last 90 days</option>
        </select>
      </div>

      {revenueData && (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-sm font-medium text-gray-500">Total Revenue (period)</h3>
            <p className="text-2xl font-bold text-gray-900 mt-1">₹{Number(revenueData.totalRevenue || 0).toLocaleString()}</p>
          </div>
          <div className="bg-white rounded-lg shadow p-6">
            <h3 className="text-sm font-medium text-gray-500">Orders (period)</h3>
            <p className="text-2xl font-bold text-gray-900 mt-1">{revenueData.orderCount || 0}</p>
          </div>
        </div>
      )}

      <div className="bg-white rounded-lg shadow p-6">
        <h2 className="text-xl font-semibold text-gray-900 mb-4">Sales & Revenue by Day</h2>
        {salesLoading ? (
          <div className="h-64 flex items-center justify-center text-gray-500">Loading chart...</div>
        ) : chartData.length === 0 ? (
          <div className="h-64 flex items-center justify-center text-gray-500">No data for this period.</div>
        ) : (
          <div className="h-80">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={chartData} margin={{ top: 10, right: 10, left: 0, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
                <XAxis dataKey="date" tick={{ fontSize: 12 }} />
                <YAxis yAxisId="left" tick={{ fontSize: 12 }} />
                <YAxis yAxisId="right" orientation="right" tick={{ fontSize: 12 }} tickFormatter={(v) => `₹${(v / 1000).toFixed(0)}k`} />
                <Tooltip formatter={(value, name) => [name === 'revenue' ? `₹${Number(value).toLocaleString()}` : value, name === 'revenue' ? 'Revenue' : 'Orders']} />
                <Bar yAxisId="left" dataKey="orders" fill="#6366f1" name="Orders" radius={[4, 4, 0, 0]} />
                <Bar yAxisId="right" dataKey="revenue" fill="#10b981" name="Revenue" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        )}
      </div>
    </div>
  )
}
