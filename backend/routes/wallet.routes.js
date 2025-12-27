import express from 'express';
import { body } from 'express-validator';
import {
  getWalletBalance,
  addMoney,
  getTransactions,
  transferMoney,
} from '../controllers/wallet.controller.js';
import { authenticate } from '../middleware/auth.middleware.js';
import { validateRequest } from '../middleware/validation.middleware.js';

const router = express.Router();

// All wallet routes require authentication
router.use(authenticate);

// Get wallet balance
router.get('/balance', getWalletBalance);

// Add money to wallet
router.post(
  '/add-money',
  [
    body('amount').isFloat({ min: 1 }).withMessage('Amount must be greater than 0'),
    body('paymentMethod').notEmpty().withMessage('Payment method is required'),
  ],
  validateRequest,
  addMoney
);

// Get transaction history
router.get('/transactions', getTransactions);

// Transfer money to another user
router.post(
  '/transfer',
  [
    body('toUserId').notEmpty().withMessage('Recipient user ID is required'),
    body('amount').isFloat({ min: 1 }).withMessage('Amount must be greater than 0'),
  ],
  validateRequest,
  transferMoney
);

export default router;

