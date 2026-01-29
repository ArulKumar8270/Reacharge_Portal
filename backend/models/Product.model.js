import mongoose from 'mongoose';

const productSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },
    description: {
      type: String,
    },
    price: {
      type: Number,
      required: true,
      min: 0,
    },
    compareAtPrice: {
      type: Number,
      min: 0,
    },
    category: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Category',
      required: true,
    },
    image: {
      type: String,
    },
    images: [{
      type: String,
    }],
    sku: {
      type: String,
      trim: true,
    },
    stock: {
      type: Number,
      required: true,
      min: 0,
      default: 0,
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    // Show in shop sections: bestsellers, family_pack, favourites
    sections: [{
      type: String,
      enum: ['bestsellers', 'family_pack', 'favourites'],
    }],
  },
  { timestamps: true }
);

// Index for search and filtering
productSchema.index({ name: 'text', description: 'text' });
productSchema.index({ category: 1, isActive: 1 });

export default mongoose.model('Product', productSchema);
