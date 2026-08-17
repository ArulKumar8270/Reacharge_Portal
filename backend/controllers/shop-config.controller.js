import ShopPageConfig from '../models/ShopPageConfig.model.js';

const DEFAULT_CONFIG = {
  welcomeText: 'Welcome to ASV Annai Sathya Catering',
  heroBanners: [
    { title: 'Authentic Dum Biryani & Catering.', subtitle: '', imageUrl: '', promoCode: 'Get 10% Off | Use code - ASV10', ctaText: 'Order Now', ctaLink: '', order: 0 },
  ],
  features: [
    { title: 'Fresh ingredients', iconName: 'spa', order: 0 },
    { title: 'Slow cooked dum', iconName: 'eco', order: 1 },
    { title: 'Homemade masala', iconName: 'agriculture', order: 2 },
    { title: 'Event catering', iconName: 'workspace_premium', order: 3 },
  ],
  sections: [
    { key: 'bestsellers', title: "Today's Specials", type: 'latest', limit: 10, order: 0 },
    { key: 'family_pack', title: 'Family Pack Collection', type: 'latest', limit: 10, order: 1 },
    { key: 'favourites', title: 'All-Time Favourites', type: 'latest', limit: 8, order: 2 },
  ],
  imageStripUrls: [],
  videoUrl: '',
  videoTitle: '',
  reviews: [
    { authorName: 'Rajesh K', authorInitials: 'RK', text: 'ASV Annai Sathya Catering made our family function perfect. The dum biryani was authentic and everyone loved it.', date: 'Jan 15, 2024', rating: 5, order: 0 },
    { authorName: 'Karthika S', authorInitials: 'KS', text: 'Excellent catering for our wedding. Fresh, flavourful, and served on time. Highly recommended.', date: 'Aug 10, 2023', rating: 5, order: 1 },
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
