import express from 'express';
import {
  createPayment,
  verifyPayment,
  getPaymentStatus,
} from '../controllers/payment.controller.js';
import { authenticate } from '../middleware/auth.middleware.js';

const router = express.Router();

// All payment routes require authentication
router.use(authenticate);

router.post('/create', createPayment);
router.post('/verify', verifyPayment);
router.get('/:id/status', getPaymentStatus);

export default router;

