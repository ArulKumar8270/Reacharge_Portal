import express from 'express';
import {
  mobileRecharge,
  dthRecharge,
  fastagRecharge,
  getRechargeHistory,
} from '../controllers/recharge.controller.js';
import { authenticate } from '../middleware/auth.middleware.js';

const router = express.Router();

// All recharge routes require authentication
router.use(authenticate);

router.post('/mobile', mobileRecharge);
router.post('/dth', dthRecharge);
router.post('/fastag', fastagRecharge);
router.get('/history', getRechargeHistory);

export default router;

