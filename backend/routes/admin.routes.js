import express from 'express';
import {
  adminLogin,
  getAdminProfile,
  getDashboardStats,
  getAllUsers,
  getUserById,
  updateUser,
  deleteUser,
  getAllProducts,
  getProductById,
  createProduct,
  updateProduct,
  deleteProduct,
  getAllCategories,
  getCategoryById,
  createCategory,
  updateCategory,
  deleteCategory,
  getAllOrders,
  getOrderById,
  updateOrderStatus,
  getAllTransactions,
  getSalesReport,
  getRevenueReport,
  getShopConfig,
  updateShopConfig,
} from '../controllers/admin.controller.js';
import { authenticate } from '../middleware/auth.middleware.js';
import { adminOnly } from '../middleware/admin.middleware.js';

const router = express.Router();

// Admin auth routes
router.post('/auth/login', adminLogin);
router.get('/auth/me', authenticate, adminOnly, getAdminProfile);

// Dashboard
router.get('/reports/dashboard', authenticate, adminOnly, getDashboardStats);

// User management
router.get('/users', authenticate, adminOnly, getAllUsers);
router.get('/users/:id', authenticate, adminOnly, getUserById);
router.put('/users/:id', authenticate, adminOnly, updateUser);
router.delete('/users/:id', authenticate, adminOnly, deleteUser);

// Product management
router.get('/products', authenticate, adminOnly, getAllProducts);
router.get('/products/:id', authenticate, adminOnly, getProductById);
router.post('/products', authenticate, adminOnly, createProduct);
router.put('/products/:id', authenticate, adminOnly, updateProduct);
router.delete('/products/:id', authenticate, adminOnly, deleteProduct);

// Category management
router.get('/categories', authenticate, adminOnly, getAllCategories);
router.get('/categories/:id', authenticate, adminOnly, getCategoryById);
router.post('/categories', authenticate, adminOnly, createCategory);
router.put('/categories/:id', authenticate, adminOnly, updateCategory);
router.delete('/categories/:id', authenticate, adminOnly, deleteCategory);

// Order management
router.get('/orders', authenticate, adminOnly, getAllOrders);
router.get('/orders/:id', authenticate, adminOnly, getOrderById);
router.put('/orders/:id/status', authenticate, adminOnly, updateOrderStatus);

// Transaction management
router.get('/transactions', authenticate, adminOnly, getAllTransactions);

// Reports
router.get('/reports/sales', authenticate, adminOnly, getSalesReport);
router.get('/reports/revenue', authenticate, adminOnly, getRevenueReport);

// Shop Page Config (mobile app)
router.get('/shop-config', authenticate, adminOnly, getShopConfig);
router.put('/shop-config', authenticate, adminOnly, updateShopConfig);

export default router;

