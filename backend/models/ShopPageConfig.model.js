import mongoose from 'mongoose';

const heroBannerSchema = new mongoose.Schema({
  title: { type: String, default: '' },
  subtitle: { type: String, default: '' },
  imageUrl: { type: String, default: '' },
  promoCode: { type: String, default: '' },
  ctaText: { type: String, default: 'Try Now' },
  ctaLink: { type: String, default: '' },
  order: { type: Number, default: 0 },
}, { _id: false });

const featureSchema = new mongoose.Schema({
  title: { type: String, required: true },
  iconName: { type: String, default: 'eco' }, // material icon name
  order: { type: Number, default: 0 },
}, { _id: false });

const sectionSchema = new mongoose.Schema({
  key: { type: String, required: true }, // bestsellers, family_pack, favourites
  title: { type: String, required: true },
  type: { type: String, enum: ['latest', 'category', 'product_ids'], default: 'latest' },
  categoryId: { type: mongoose.Schema.Types.ObjectId, ref: 'Category' },
  productIds: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Product' }],
  limit: { type: Number, default: 10 },
  order: { type: Number, default: 0 },
}, { _id: false });

const reviewSchema = new mongoose.Schema({
  authorName: { type: String, required: true },
  authorInitials: { type: String, default: '' },
  text: { type: String, required: true },
  date: { type: String, default: '' },
  rating: { type: Number, default: 5, min: 1, max: 5 },
  order: { type: Number, default: 0 },
}, { _id: false });

const shopPageConfigSchema = new mongoose.Schema({
  welcomeText: { type: String, default: 'Welcome to our store' },
  heroBanners: [heroBannerSchema],
  features: [featureSchema],
  sections: [sectionSchema],
  imageStripUrls: [String],
  videoUrl: { type: String, default: '' },
  videoTitle: { type: String, default: '' },
  reviews: [reviewSchema],
}, { timestamps: true });

// Single document - use findOne
shopPageConfigSchema.index({ _id: 1 });

export default mongoose.model('ShopPageConfig', shopPageConfigSchema);
