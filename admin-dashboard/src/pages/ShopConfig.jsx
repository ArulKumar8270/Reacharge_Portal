import { useState, useEffect } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { shopConfigService, categoryService } from '../services/api'
import toast from 'react-hot-toast'
import { Plus, Trash2, X } from 'lucide-react'

const emptyHero = () => ({ title: '', subtitle: '', imageUrl: '', promoCode: '', ctaText: 'Try Now', ctaLink: '', order: 0 })
const emptyFeature = () => ({ title: '', iconName: 'eco', order: 0 })
const emptySection = () => ({ key: '', title: '', type: 'latest', categoryId: '', limit: 10, order: 0 })
const emptyReview = () => ({ authorName: '', authorInitials: '', text: '', date: '', rating: 5, order: 0 })

export default function ShopConfig() {
  const queryClient = useQueryClient()
  const [form, setForm] = useState({
    welcomeText: 'Welcome to our store',
    heroBanners: [emptyHero()],
    features: [emptyFeature()],
    sections: [emptySection()],
    imageStripUrls: ['', '', ''],
    videoUrl: '',
    videoTitle: '',
    reviews: [emptyReview()],
  })

  const { data: categories = [] } = useQuery({
    queryKey: ['categories'],
    queryFn: async () => {
      const res = await categoryService.getAll()
      return res.data?.success ? res.data.data : []
    },
  })

  const { data, isLoading, error } = useQuery({
    queryKey: ['shopConfig'],
    queryFn: async () => {
      const res = await shopConfigService.get()
      if (!res.data?.success) throw new Error(res.data?.message)
      return res.data.data
    },
  })

  useEffect(() => {
    if (data) {
      setForm({
        welcomeText: data.welcomeText ?? 'Welcome to our store',
        heroBanners: Array.isArray(data.heroBanners) && data.heroBanners.length ? data.heroBanners : [emptyHero()],
        features: Array.isArray(data.features) && data.features.length ? data.features : [emptyFeature()],
        sections: Array.isArray(data.sections) && data.sections.length ? data.sections : [emptySection()],
        imageStripUrls: Array.isArray(data.imageStripUrls) && data.imageStripUrls.length ? data.imageStripUrls : ['', '', ''],
        videoUrl: data.videoUrl ?? '',
        videoTitle: data.videoTitle ?? '',
        reviews: Array.isArray(data.reviews) && data.reviews.length ? data.reviews : [emptyReview()],
      })
    }
  }, [data])

  const updateMutation = useMutation({
    mutationFn: (body) => shopConfigService.update(body),
    onSuccess: () => {
      queryClient.invalidateQueries(['shopConfig'])
      toast.success('Shop page config saved')
    },
    onError: (e) => toast.error(e.response?.data?.message || 'Failed to save'),
  })

  const handleSave = () => {
    const payload = {
      welcomeText: form.welcomeText,
      heroBanners: form.heroBanners.map((h, i) => ({ ...h, order: i })),
      features: form.features.map((f, i) => ({ ...f, order: i })),
      sections: form.sections.map((s, i) => ({ ...s, order: i, categoryId: s.categoryId || undefined })),
      imageStripUrls: form.imageStripUrls.filter(Boolean),
      videoUrl: form.videoUrl,
      videoTitle: form.videoTitle,
      reviews: form.reviews.map((r, i) => ({ ...r, order: i })),
    }
    updateMutation.mutate(payload)
  }

  const update = (key, value) => setForm((f) => ({ ...f, [key]: value }))
  const updateList = (key, index, field, value) => {
    setForm((f) => {
      const list = [...(f[key] || [])]
      list[index] = { ...list[index], [field]: value }
      return { ...f, [key]: list }
    })
  }
  const addToList = (key, empty) => setForm((f) => ({ ...f, [key]: [...(f[key] || []), empty()] }))
  const removeFromList = (key, index) => setForm((f) => ({ ...f, [key]: f[key].filter((_, i) => i !== index) }))

  if (isLoading) return <div className="p-8 text-center">Loading...</div>
  if (error) return <div className="p-8 text-red-600">Error: {error.message}</div>

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-3xl font-bold text-gray-900">Shop Page (Mobile App)</h1>
        <button onClick={handleSave} disabled={updateMutation.isLoading} className="bg-primary-600 text-white px-4 py-2 rounded-lg hover:bg-primary-700 disabled:opacity-50">
          Save Config
        </button>
      </div>

      <div className="space-y-8 max-w-4xl">
        <section className="bg-white rounded-lg shadow p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Welcome bar</h2>
          <input type="text" value={form.welcomeText} onChange={(e) => update('welcomeText', e.target.value)} className="w-full border rounded-lg px-3 py-2" placeholder="Welcome to our store" />
        </section>

        <section className="bg-white rounded-lg shadow p-6">
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-lg font-semibold text-gray-900">Hero banners</h2>
            <button type="button" onClick={() => addToList('heroBanners', emptyHero)} className="text-primary-600 flex items-center gap-1"><Plus className="w-4 h-4" /> Add</button>
          </div>
          {form.heroBanners.map((h, i) => (
            <div key={i} className="border rounded-lg p-4 mb-4 space-y-2">
              <div className="flex justify-end"><button type="button" onClick={() => removeFromList('heroBanners', i)} className="text-red-600"><Trash2 className="w-4 h-4" /></button></div>
              <input placeholder="Title" value={h.title} onChange={(e) => updateList('heroBanners', i, 'title', e.target.value)} className="w-full border rounded px-3 py-2" />
              <input placeholder="Subtitle" value={h.subtitle} onChange={(e) => updateList('heroBanners', i, 'subtitle', e.target.value)} className="w-full border rounded px-3 py-2" />
              <input placeholder="Image URL" value={h.imageUrl} onChange={(e) => updateList('heroBanners', i, 'imageUrl', e.target.value)} className="w-full border rounded px-3 py-2" />
              <input placeholder="Promo code text (e.g. Get 5% Off | NEXUS5)" value={h.promoCode} onChange={(e) => updateList('heroBanners', i, 'promoCode', e.target.value)} className="w-full border rounded px-3 py-2" />
              <input placeholder="CTA text" value={h.ctaText} onChange={(e) => updateList('heroBanners', i, 'ctaText', e.target.value)} className="w-full border rounded px-3 py-2" />
            </div>
          ))}
        </section>

        <section className="bg-white rounded-lg shadow p-6">
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-lg font-semibold text-gray-900">Features (4 icons)</h2>
            <button type="button" onClick={() => addToList('features', emptyFeature)} className="text-primary-600 flex items-center gap-1"><Plus className="w-4 h-4" /> Add</button>
          </div>
          {form.features.map((f, i) => (
            <div key={i} className="flex gap-2 mb-2 items-center">
              <input placeholder="Title" value={f.title} onChange={(e) => updateList('features', i, 'title', e.target.value)} className="flex-1 border rounded px-3 py-2" />
              <input placeholder="Icon (e.g. eco, agriculture)" value={f.iconName} onChange={(e) => updateList('features', i, 'iconName', e.target.value)} className="w-32 border rounded px-3 py-2" />
              <button type="button" onClick={() => removeFromList('features', i)} className="text-red-600"><Trash2 className="w-4 h-4" /></button>
            </div>
          ))}
        </section>

        <section className="bg-white rounded-lg shadow p-6">
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-lg font-semibold text-gray-900">Product sections</h2>
            <button type="button" onClick={() => addToList('sections', emptySection)} className="text-primary-600 flex items-center gap-1"><Plus className="w-4 h-4" /> Add</button>
          </div>
          <p className="text-sm text-gray-500 mb-2">key: bestsellers, family_pack, favourites. type: latest or category.</p>
          {form.sections.map((s, i) => (
            <div key={i} className="border rounded-lg p-4 mb-4 grid grid-cols-2 gap-2">
              <input placeholder="Key" value={s.key} onChange={(e) => updateList('sections', i, 'key', e.target.value)} className="border rounded px-3 py-2" />
              <input placeholder="Title" value={s.title} onChange={(e) => updateList('sections', i, 'title', e.target.value)} className="border rounded px-3 py-2" />
              <select value={s.type} onChange={(e) => updateList('sections', i, 'type', e.target.value)} className="border rounded px-3 py-2">
                <option value="latest">Latest</option>
                <option value="category">By category</option>
              </select>
              {s.type === 'category' && (
                <select value={s.categoryId || ''} onChange={(e) => updateList('sections', i, 'categoryId', e.target.value)} className="border rounded px-3 py-2">
                  <option value="">Select category</option>
                  {categories.map((c) => <option key={c._id} value={c._id}>{c.name}</option>)}
                </select>
              )}
              <input type="number" placeholder="Limit" value={s.limit} onChange={(e) => updateList('sections', i, 'limit', parseInt(e.target.value) || 10)} className="border rounded px-3 py-2" />
              <button type="button" onClick={() => removeFromList('sections', i)} className="text-red-600 flex items-center"><Trash2 className="w-4 h-4" /> Remove</button>
            </div>
          ))}
        </section>

        <section className="bg-white rounded-lg shadow p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Image strip URLs (carousel)</h2>
          {[0, 1, 2].map((i) => (
            <input key={i} placeholder={`Image ${i + 1} URL`} value={form.imageStripUrls[i] ?? ''} onChange={(e) => {
              const urls = [...form.imageStripUrls]
              urls[i] = e.target.value
              update('imageStripUrls', urls)
            }} className="w-full border rounded px-3 py-2 mb-2" />
          ))}
        </section>

        <section className="bg-white rounded-lg shadow p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Video section</h2>
          <input placeholder="Video URL" value={form.videoUrl} onChange={(e) => update('videoUrl', e.target.value)} className="w-full border rounded px-3 py-2 mb-2" />
          <input placeholder="Video title" value={form.videoTitle} onChange={(e) => update('videoTitle', e.target.value)} className="w-full border rounded px-3 py-2" />
        </section>

        <section className="bg-white rounded-lg shadow p-6">
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-lg font-semibold text-gray-900">Customer reviews</h2>
            <button type="button" onClick={() => addToList('reviews', emptyReview)} className="text-primary-600 flex items-center gap-1"><Plus className="w-4 h-4" /> Add</button>
          </div>
          {form.reviews.map((r, i) => (
            <div key={i} className="border rounded-lg p-4 mb-4 space-y-2">
              <div className="flex justify-end"><button type="button" onClick={() => removeFromList('reviews', i)} className="text-red-600"><Trash2 className="w-4 h-4" /></button></div>
              <input placeholder="Author name" value={r.authorName} onChange={(e) => updateList('reviews', i, 'authorName', e.target.value)} className="w-full border rounded px-3 py-2" />
              <input placeholder="Initials (e.g. NS)" value={r.authorInitials} onChange={(e) => updateList('reviews', i, 'authorInitials', e.target.value)} className="w-full border rounded px-3 py-2" />
              <textarea placeholder="Review text" value={r.text} onChange={(e) => updateList('reviews', i, 'text', e.target.value)} className="w-full border rounded px-3 py-2" rows={3} />
              <input placeholder="Date" value={r.date} onChange={(e) => updateList('reviews', i, 'date', e.target.value)} className="w-full border rounded px-3 py-2" />
              <input type="number" min="1" max="5" placeholder="Rating" value={r.rating} onChange={(e) => updateList('reviews', i, 'rating', parseInt(e.target.value) || 5)} className="w-full border rounded px-3 py-2" />
            </div>
          ))}
        </section>
      </div>
    </div>
  )
}
