import ShopPageConfig from '../models/ShopPageConfig.model.js';

const DEFAULT_CONFIG = {
  welcomeText: 'Welcome to our store',
  heroBanners: [
    { title: 'From Our Farm to Your Kitchen.', subtitle: '', imageUrl: '', promoCode: 'Get 5% Off | Use code - NEXUS5', ctaText: 'Try Now', ctaLink: '', order: 0 },
  ],
  features: [
    { title: 'Wood-Pressed Tradition', iconName: 'agriculture', order: 0 },
    { title: 'Small-Batch Pressed', iconName: 'water_drop', order: 1 },
    { title: 'Pure & Unrefined', iconName: 'eco', order: 2 },
    { title: 'Five-Generation Craft', iconName: 'workspace_premium', order: 3 },
  ],
  sections: [
    { key: 'bestsellers', title: "Bestsellers You'll Love", type: 'latest', limit: 10, order: 0 },
    { key: 'family_pack', title: 'Family Pack Collection', type: 'latest', limit: 10, order: 1 },
    { key: 'favourites', title: 'All-Time Favourite Collection', type: 'latest', limit: 8, order: 2 },
  ],
  imageStripUrls: [],
  videoUrl: '',
  videoTitle: '',
  reviews: [
    { authorName: 'Nandan S', authorInitials: 'NS', text: 'We have been using Nexus Wood Pressed Oil and it is exceptionally pure and hygienic. The aroma is natural and pleasant making it perfect for everyday cooking. Highly recommended.', date: 'Jan 15, 2024', rating: 5, order: 0 },
    { authorName: 'Karthika S', authorInitials: 'KS', text: 'The aroma of their groundnut oils adds a rich flavour to all my dishes. My family loves the taste. Thank you for maintaining such good standards.', date: 'Aug 10, 2023', rating: 5, order: 1 },
  ],
};

export const getShopConfig = async (req, res) => {
  try {
    let config = await ShopPageConfig.findOne();
    if (!config) {
      config = await ShopPageConfig.create(DEFAULT_CONFIG);
    }
    const data = config.toObject();
    if (data.heroBanners) data.heroBanners.sort((a, b) => (a.order ?? 0) - (b.order ?? 0));
    if (data.features) data.features.sort((a, b) => (a.order ?? 0) - (b.order ?? 0));
    if (data.sections) data.sections.sort((a, b) => (a.order ?? 0) - (b.order ?? 0));
    if (data.reviews) data.reviews.sort((a, b) => (a.order ?? 0) - (b.order ?? 0));
    res.json({ success: true, data });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
