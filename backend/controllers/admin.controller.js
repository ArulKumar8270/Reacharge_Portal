import User from '../models/User.model.js';
import Product from '../models/Product.model.js';
import Category from '../models/Category.model.js';
import Order from '../models/Order.model.js';
import Transaction from '../models/Transaction.model.js';
import ShopPageConfig from '../models/ShopPageConfig.model.js';
import jwt from 'jsonwebtoken';

const generateToken = (userId) => {
  return jwt.sign({ userId }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  });
};

export const adminLogin = async (req, res) => {
  try {
    const { email, password } = req.body;
    const admin = await User.findOne({ email, role: 'admin' });
    if (!admin) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }
    const isPasswordValid = await admin.comparePassword(password);
    if (!isPasswordValid) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }
    const token = generateToken(admin._id);
    res.json({
      success: true,
      message: 'Login successful',
      data: {
        user: { id: admin._id, name: admin.name, email: admin.email, role: admin.role },
        token,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const getAdminProfile = async (req, res) => {
  try {
    const admin = await User.findById(req.user._id).select('-password -otp');
    res.json({ success: true, data: admin });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const getDashboardStats = async (req, res) => {
  try {
    const [totalUsers, totalProducts, totalOrders, revenueResult] = await Promise.all([
      User.countDocuments({ role: 'user' }),
      Product.countDocuments(),
      Order.countDocuments(),
      Order.aggregate([
        { $match: { status: { $in: ['delivered', 'shipped', 'processing', 'confirmed'] }, paymentStatus: { $ne: 'refunded' } } },
        { $group: { _id: null, total: { $sum: '$total' } } },
      ]),
    ]);
    const totalRevenue = revenueResult[0]?.total || 0;
    res.json({
      success: true,
      data: {
        totalUsers,
        totalProducts,
        totalOrders,
        totalRevenue,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// User Management
export const getAllUsers = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;
    const users = await User.find({ role: 'user' }).select('-password -otp').skip(skip).limit(limit);
    const total = await User.countDocuments({ role: 'user' });
    res.json({
      success: true,
      data: { users, pagination: { page, limit, total, pages: Math.ceil(total / limit) } },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const getUserById = async (req, res) => {
  try {
    const user = await User.findById(req.params.id).select('-password -otp');
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    res.json({ success: true, data: user });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const updateUser = async (req, res) => {
  try {
    const user = await User.findByIdAndUpdate(req.params.id, req.body, { new: true, runValidators: true }).select('-password -otp');
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    res.json({ success: true, message: 'User updated successfully', data: user });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const deleteUser = async (req, res) => {
  try {
    const user = await User.findByIdAndDelete(req.params.id);
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    res.json({ success: true, message: 'User deleted successfully' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// Product Management
export const getAllProducts = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const search = req.query.search;
    const category = req.query.category;
    const skip = (page - 1) * limit;
    const filter = {};
    if (category) filter.category = category;
    if (search) {
      filter.$or = [
        { name: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
        { sku: { $regex: search, $options: 'i' } },
      ];
    }
    const products = await Product.find(filter)
      .populate('category', 'name slug')
      .skip(skip)
      .limit(limit)
      .sort({ createdAt: -1 });
    const total = await Product.countDocuments(filter);
    res.json({
      success: true,
      data: products,
      pagination: { page, limit, total, pages: Math.ceil(total / limit) },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const getProductById = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id).populate('category', 'name slug');
    if (!product) return res.status(404).json({ success: false, message: 'Product not found' });
    res.json({ success: true, data: product });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const createProduct = async (req, res) => {
  try {
    const categoryExists = await Category.findById(req.body.category);
    if (!categoryExists) return res.status(400).json({ success: false, message: 'Invalid category' });
    const product = await Product.create(req.body);
    const populated = await Product.findById(product._id).populate('category', 'name slug');
    res.status(201).json({ success: true, message: 'Product created successfully', data: populated });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const updateProduct = async (req, res) => {
  try {
    if (req.body.category) {
      const categoryExists = await Category.findById(req.body.category);
      if (!categoryExists) return res.status(400).json({ success: false, message: 'Invalid category' });
    }
    const product = await Product.findByIdAndUpdate(req.params.id, req.body, { new: true, runValidators: true }).populate('category', 'name slug');
    if (!product) return res.status(404).json({ success: false, message: 'Product not found' });
    res.json({ success: true, message: 'Product updated successfully', data: product });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const deleteProduct = async (req, res) => {
  try {
    const product = await Product.findByIdAndDelete(req.params.id);
    if (!product) return res.status(404).json({ success: false, message: 'Product not found' });
    res.json({ success: true, message: 'Product deleted successfully' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// Category Management (Admin - all categories including inactive)
export const getAllCategories = async (req, res) => {
  try {
    const categories = await Category.find().sort({ name: 1 });
    res.json({ success: true, data: categories });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const getCategoryById = async (req, res) => {
  try {
    const category = await Category.findById(req.params.id);
    if (!category) return res.status(404).json({ success: false, message: 'Category not found' });
    res.json({ success: true, data: category });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const createCategory = async (req, res) => {
  try {
    const { name, slug, description, image, isActive } = req.body;
    const category = await Category.create({
      name,
      slug: slug || name?.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, ''),
      description,
      image,
      isActive: isActive !== false,
    });
    res.status(201).json({ success: true, message: 'Category created successfully', data: category });
  } catch (error) {
    if (error.code === 11000) return res.status(400).json({ success: false, message: 'Category with this slug already exists' });
    res.status(500).json({ success: false, message: error.message });
  }
};

export const updateCategory = async (req, res) => {
  try {
    const category = await Category.findByIdAndUpdate(req.params.id, req.body, { new: true, runValidators: true });
    if (!category) return res.status(404).json({ success: false, message: 'Category not found' });
    res.json({ success: true, message: 'Category updated successfully', data: category });
  } catch (error) {
    if (error.code === 11000) return res.status(400).json({ success: false, message: 'Category with this slug already exists' });
    res.status(500).json({ success: false, message: error.message });
  }
};

export const deleteCategory = async (req, res) => {
  try {
    const category = await Category.findByIdAndDelete(req.params.id);
    if (!category) return res.status(404).json({ success: false, message: 'Category not found' });
    res.json({ success: true, message: 'Category deleted successfully' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// Order Management
const ORDER_STATUSES = ['pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled'];

export const getAllOrders = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const status = req.query.status;
    const skip = (page - 1) * limit;
    const filter = {};
    if (status) filter.status = status;
    const orders = await Order.find(filter)
      .populate('user', 'name email phoneNumber')
      .populate('items.product', 'name image')
      .skip(skip)
      .limit(limit)
      .sort({ createdAt: -1 });
    const total = await Order.countDocuments(filter);
    res.json({
      success: true,
      data: orders,
      pagination: { page, limit, total, pages: Math.ceil(total / limit) },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const getOrderById = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id)
      .populate('user', 'name email phoneNumber')
      .populate('items.product', 'name image price');
    if (!order) return res.status(404).json({ success: false, message: 'Order not found' });
    res.json({ success: true, data: order });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const updateOrderStatus = async (req, res) => {
  try {
    const { status } = req.body;
    if (!ORDER_STATUSES.includes(status)) {
      return res.status(400).json({ success: false, message: `Invalid status. Allowed: ${ORDER_STATUSES.join(', ')}` });
    }
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ success: false, message: 'Order not found' });
    if (order.status === 'cancelled') {
      return res.status(400).json({ success: false, message: 'Cannot update cancelled order' });
    }
    if (status === 'cancelled') {
      for (const item of order.items) {
        await Product.findByIdAndUpdate(item.product, { $inc: { stock: item.quantity } });
      }
    }
    order.status = status;
    await order.save();
    const populated = await Order.findById(order._id)
      .populate('user', 'name email phoneNumber')
      .populate('items.product', 'name image');
    res.json({ success: true, message: 'Order status updated', data: populated });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// Transaction Management
export const getAllTransactions = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;
    const transactions = await Transaction.find()
      .populate('userId', 'name email')
      .skip(skip)
      .limit(limit)
      .sort({ createdAt: -1 });
    const total = await Transaction.countDocuments();
    res.json({
      success: true,
      data: transactions,
      pagination: { page, limit, total, pages: Math.ceil(total / limit) },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// Reports
export const getSalesReport = async (req, res) => {
  try {
    const startDate = req.query.startDate ? new Date(req.query.startDate) : new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
    const endDate = req.query.endDate ? new Date(req.query.endDate) : new Date();
    const result = await Order.aggregate([
      { $match: { createdAt: { $gte: startDate, $lte: endDate }, status: { $ne: 'cancelled' } } },
      { $group: { _id: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } }, count: { $sum: 1 }, revenue: { $sum: '$total' } } },
      { $sort: { _id: 1 } },
    ]);
    res.json({ success: true, data: result });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const getRevenueReport = async (req, res) => {
  try {
    const startDate = req.query.startDate ? new Date(req.query.startDate) : new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
    const endDate = req.query.endDate ? new Date(req.query.endDate) : new Date();
    const result = await Order.aggregate([
      { $match: { createdAt: { $gte: startDate, $lte: endDate }, status: { $in: ['delivered', 'shipped', 'processing', 'confirmed'] }, paymentStatus: { $ne: 'refunded' } } },
      { $group: { _id: null, totalRevenue: { $sum: '$total' }, orderCount: { $sum: 1 } } },
    ]);
    res.json({
      success: true,
      data: {
        totalRevenue: result[0]?.totalRevenue || 0,
        orderCount: result[0]?.orderCount || 0,
        startDate,
        endDate,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// Shop Page Config (mobile app home/shop sections)
export const getShopConfig = async (req, res) => {
  try {
    let config = await ShopPageConfig.findOne();
    if (!config) config = await ShopPageConfig.create({});
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

export const updateShopConfig = async (req, res) => {
  try {
    const body = req.body;
    let config = await ShopPageConfig.findOne();
    if (!config) config = new ShopPageConfig({});
    if (body.welcomeText != null) config.welcomeText = body.welcomeText;
    if (body.heroBanners != null) config.heroBanners = body.heroBanners;
    if (body.features != null) config.features = body.features;
    if (body.sections != null) config.sections = body.sections;
    if (body.imageStripUrls != null) config.imageStripUrls = body.imageStripUrls;
    if (body.videoUrl != null) config.videoUrl = body.videoUrl;
    if (body.videoTitle != null) config.videoTitle = body.videoTitle;
    if (body.reviews != null) config.reviews = body.reviews;
    await config.save();
    const data = config.toObject();
    res.json({ success: true, message: 'Shop config updated', data });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
