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
  createProduct,
  updateProduct,
  deleteProduct,
  getAllOrders,
  getOrderById,
  updateOrderStatus,
  getAllTransactions,
  getSalesReport,
  getRevenueReport,
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
router.post('/products', authenticate, adminOnly, createProduct);
router.put('/products/:id', authenticate, adminOnly, updateProduct);
router.delete('/products/:id', authenticate, adminOnly, deleteProduct);

// Order management
router.get('/orders', authenticate, adminOnly, getAllOrders);
router.get('/orders/:id', authenticate, adminOnly, getOrderById);
router.put('/orders/:id/status', authenticate, adminOnly, updateOrderStatus);

// Transaction management
router.get('/transactions', authenticate, adminOnly, getAllTransactions);

// Reports
router.get('/reports/sales', authenticate, adminOnly, getSalesReport);
router.get('/reports/revenue', authenticate, adminOnly, getRevenueReport);

export default router;

