import express from 'express';
import {
  payElectricityBill,
  payWaterBill,
  payGasBill,
  payBroadbandBill,
  payInsuranceBill,
  getBillHistory,
} from '../controllers/bill.controller.js';
import { authenticate } from '../middleware/auth.middleware.js';

const router = express.Router();

// All bill routes require authentication
router.use(authenticate);

router.post('/electricity', payElectricityBill);
router.post('/water', payWaterBill);
router.post('/gas', payGasBill);
router.post('/broadband', payBroadbandBill);
router.post('/insurance', payInsuranceBill);
router.get('/history', getBillHistory);

export default router;

