import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { productService, categoryService } from '../services/api'
import toast from 'react-hot-toast'
import { Edit, Trash2, Plus, X } from 'lucide-react'

const SECTION_OPTIONS = [
  { value: 'bestsellers', label: "Bestseller section" },
  { value: 'family_pack', label: 'Family pack section' },
  { value: 'favourites', label: 'All-time Favourite section' },
]

const initialForm = {
  name: '',
  description: '',
  price: '',
  compareAtPrice: '',
  category: '',
  image: '',
  sku: '',
  stock: '',
  isActive: true,
  sections: [],
}

export default function Products() {
  const [page, setPage] = useState(1)
  const [search, setSearch] = useState('')
  const [categoryFilter, setCategoryFilter] = useState('')
  const [modalOpen, setModalOpen] = useState(false)
  const [editingProduct, setEditingProduct] = useState(null)
  const [form, setForm] = useState(initialForm)
  const queryClient = useQueryClient()

  const { data: categoriesData } = useQuery({
    queryKey: ['categories'],
    queryFn: async () => {
      const res = await categoryService.getAll()
      if (res.data.success) return res.data.data
      throw new Error(res.data.message)
    },
  })
  const categories = categoriesData || []

  const { data, isLoading, error } = useQuery({
    queryKey: ['products', page, search, categoryFilter],
    queryFn: async () => {
      const params = { page, limit: 10 }
      if (search) params.search = search
      if (categoryFilter) params.category = categoryFilter
      const res = await productService.getAll(params)
      if (res.data.success) return { products: res.data.data, pagination: res.data.pagination }
      throw new Error(res.data.message)
    },
  })

  const createMutation = useMutation({
    mutationFn: (body) => productService.create(body),
    onSuccess: () => {
      queryClient.invalidateQueries(['products'])
      toast.success('Product created successfully')
      closeModal()
    },
    onError: (e) => toast.error(e.response?.data?.message || 'Failed to create product'),
  })

  const updateMutation = useMutation({
    mutationFn: ({ id, body }) => productService.update(id, body),
    onSuccess: () => {
      queryClient.invalidateQueries(['products'])
      toast.success('Product updated successfully')
      closeModal()
    },
    onError: (e) => toast.error(e.response?.data?.message || 'Failed to update product'),
  })

  const deleteMutation = useMutation({
    mutationFn: (id) => productService.delete(id),
    onSuccess: () => {
      queryClient.invalidateQueries(['products'])
      toast.success('Product deleted successfully')
    },
    onError: (e) => toast.error(e.response?.data?.message || 'Failed to delete product'),
  })

  const openAddModal = () => {
    setEditingProduct(null)
    setForm(initialForm)
    setModalOpen(true)
  }

  const openEditModal = (product) => {
    setEditingProduct(product)
    setForm({
      name: product.name || '',
      description: product.description || '',
      price: product.price ?? '',
      compareAtPrice: product.compareAtPrice ?? '',
      category: product.category?._id || product.category || '',
      image: product.image || '',
      sku: product.sku || '',
      stock: product.stock ?? '',
      isActive: product.isActive !== false,
      sections: Array.isArray(product.sections) ? [...product.sections] : [],
    })
    setModalOpen(true)
  }

  const closeModal = () => {
    setModalOpen(false)
    setEditingProduct(null)
    setForm(initialForm)
  }

  const handleSubmit = (e) => {
    e.preventDefault()
    const payload = {
      name: form.name.trim(),
      description: form.description.trim() || undefined,
      price: Number(form.price) || 0,
      compareAtPrice: form.compareAtPrice ? Number(form.compareAtPrice) : undefined,
      category: form.category || undefined,
      image: form.image.trim() || undefined,
      sku: form.sku.trim() || undefined,
      stock: Number(form.stock) ?? 0,
      isActive: form.isActive,
      sections: Array.isArray(form.sections) ? form.sections : [],
    }
    if (!payload.name || payload.price < 0 || !payload.category) {
      toast.error('Name, price and category are required')
      return
    }
    if (editingProduct) {
      updateMutation.mutate({ id: editingProduct._id, body: payload })
    } else {
      createMutation.mutate(payload)
    }
  }

  const handleDelete = (id, name) => {
    if (window.confirm(`Delete product "${name}"?`)) deleteMutation.mutate(id)
  }

  const products = data?.products || []
  const pagination = data?.pagination || {}

  return (
    <div>
      <div className="flex justify-between items-center mb-6 flex-wrap gap-4">
        <h1 className="text-3xl font-bold text-gray-900">Products</h1>
        <button
          onClick={openAddModal}
          className="bg-primary-600 text-white px-4 py-2 rounded-lg hover:bg-primary-700 flex items-center gap-2"
        >
          <Plus className="w-4 h-4" /> Add Product
        </button>
      </div>

      <div className="bg-white rounded-lg shadow p-4 mb-6 flex flex-wrap gap-4">
        <input
          type="text"
          placeholder="Search products..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="border border-gray-300 rounded-lg px-3 py-2 flex-1 min-w-[200px]"
        />
        <select
          value={categoryFilter}
          onChange={(e) => setCategoryFilter(e.target.value)}
          className="border border-gray-300 rounded-lg px-3 py-2"
        >
          <option value="">All categories</option>
          {categories.map((c) => (
            <option key={c._id} value={c._id}>{c.name}</option>
          ))}
        </select>
      </div>

      {isLoading ? (
        <div className="bg-white rounded-lg shadow p-12 text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto" />
          <p className="mt-4 text-gray-600">Loading products...</p>
        </div>
      ) : error ? (
        <div className="bg-red-50 border border-red-200 rounded-lg p-4 text-center">
          <p className="text-red-800">{error.message}</p>
        </div>
      ) : products.length === 0 ? (
        <div className="bg-white rounded-lg shadow p-12 text-center">
          <p className="text-gray-500 text-lg">No products found. Add your first product.</p>
          <button onClick={openAddModal} className="mt-4 text-primary-600 hover:underline">Add Product</button>
        </div>
      ) : (
        <>
          <div className="bg-white rounded-lg shadow overflow-hidden">
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Image</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Category</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Price</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Stock</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {products.map((p) => (
                    <tr key={p._id} className="hover:bg-gray-50">
                      <td className="px-6 py-4">
                        {p.image ? (
                          <img src={p.image} alt="" className="w-12 h-12 object-cover rounded" />
                        ) : (
                          <div className="w-12 h-12 bg-gray-200 rounded flex items-center justify-center text-gray-400 text-xs">No img</div>
                        )}
                      </td>
                      <td className="px-6 py-4">
                        <div className="text-sm font-medium text-gray-900">{p.name}</div>
                        {p.sku && <div className="text-xs text-gray-500">SKU: {p.sku}</div>}
                      </td>
                      <td className="px-6 py-4 text-sm text-gray-600">{p.category?.name || '-'}</td>
                      <td className="px-6 py-4 text-sm">₹{Number(p.price).toLocaleString()}</td>
                      <td className="px-6 py-4 text-sm">{p.stock}</td>
                      <td className="px-6 py-4">
                        <span className={`px-2 py-1 text-xs rounded-full ${p.isActive ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-600'}`}>
                          {p.isActive ? 'Active' : 'Inactive'}
                        </span>
                      </td>
                      <td className="px-6 py-4">
                        <div className="flex gap-2">
                          <button onClick={() => openEditModal(p)} className="text-primary-600 hover:text-primary-800" title="Edit">
                            <Edit className="w-4 h-4" />
                          </button>
                          <button onClick={() => handleDelete(p._id, p.name)} disabled={deleteMutation.isLoading} className="text-red-600 hover:text-red-800" title="Delete">
                            <Trash2 className="w-4 h-4" />
                          </button>
                        </div>
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

      {modalOpen && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-xl shadow-xl max-w-lg w-full max-h-[90vh] overflow-y-auto">
            <div className="flex justify-between items-center p-4 border-b">
              <h2 className="text-xl font-semibold">{editingProduct ? 'Edit Product' : 'Add Product'}</h2>
              <button onClick={closeModal} className="p-1 hover:bg-gray-100 rounded"><X className="w-5 h-5" /></button>
            </div>
            <form onSubmit={handleSubmit} className="p-4 space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Name *</label>
                <input
                  type="text"
                  value={form.name}
                  onChange={(e) => setForm((f) => ({ ...f, name: e.target.value }))}
                  className="w-full border border-gray-300 rounded-lg px-3 py-2"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                <textarea
                  value={form.description}
                  onChange={(e) => setForm((f) => ({ ...f, description: e.target.value }))}
                  className="w-full border border-gray-300 rounded-lg px-3 py-2"
                  rows={2}
                />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Price (₹) *</label>
                  <input
                    type="number"
                    min="0"
                    step="0.01"
                    value={form.price}
                    onChange={(e) => setForm((f) => ({ ...f, price: e.target.value }))}
                    className="w-full border border-gray-300 rounded-lg px-3 py-2"
                    required
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Compare at (₹)</label>
                  <input
                    type="number"
                    min="0"
                    step="0.01"
                    value={form.compareAtPrice}
                    onChange={(e) => setForm((f) => ({ ...f, compareAtPrice: e.target.value }))}
                    className="w-full border border-gray-300 rounded-lg px-3 py-2"
                  />
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Category *</label>
                <select
                  value={form.category}
                  onChange={(e) => setForm((f) => ({ ...f, category: e.target.value }))}
                  className="w-full border border-gray-300 rounded-lg px-3 py-2"
                  required
                >
                  <option value="">Select category</option>
                  {categories.map((c) => (
                    <option key={c._id} value={c._id}>{c.name}</option>
                  ))}
                </select>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">SKU</label>
                  <input
                    type="text"
                    value={form.sku}
                    onChange={(e) => setForm((f) => ({ ...f, sku: e.target.value }))}
                    className="w-full border border-gray-300 rounded-lg px-3 py-2"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Stock *</label>
                  <input
                    type="number"
                    min="0"
                    value={form.stock}
                    onChange={(e) => setForm((f) => ({ ...f, stock: e.target.value }))}
                    className="w-full border border-gray-300 rounded-lg px-3 py-2"
                    required
                  />
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Image URL</label>
                <input
                  type="url"
                  value={form.image}
                  onChange={(e) => setForm((f) => ({ ...f, image: e.target.value }))}
                  className="w-full border border-gray-300 rounded-lg px-3 py-2"
                  placeholder="https://..."
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Show in section(s)</label>
                <div className="space-y-2">
                  {SECTION_OPTIONS.map((opt) => (
                    <label key={opt.value} className="flex items-center gap-2 cursor-pointer">
                      <input
                        type="checkbox"
                        checked={form.sections?.includes(opt.value) ?? false}
                        onChange={(e) => {
                          const next = e.target.checked
                            ? [...(form.sections || []), opt.value]
                            : (form.sections || []).filter((s) => s !== opt.value)
                          setForm((f) => ({ ...f, sections: next }))
                        }}
                        className="rounded"
                      />
                      <span className="text-sm text-gray-700">{opt.label}</span>
                    </label>
                  ))}
                </div>
              </div>
              <div className="flex items-center gap-2">
                <input
                  type="checkbox"
                  id="isActive"
                  checked={form.isActive}
                  onChange={(e) => setForm((f) => ({ ...f, isActive: e.target.checked }))}
                  className="rounded"
                />
                <label htmlFor="isActive" className="text-sm text-gray-700">Active (visible in store)</label>
              </div>
              <div className="flex justify-end gap-2 pt-4 border-t">
                <button type="button" onClick={closeModal} className="px-4 py-2 border rounded-lg hover:bg-gray-50">Cancel</button>
                <button
                  type="submit"
                  disabled={createMutation.isLoading || updateMutation.isLoading}
                  className="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 disabled:opacity-50"
                >
                  {editingProduct ? 'Update' : 'Create'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}
