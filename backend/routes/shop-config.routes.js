import express from 'express';
import { getShopConfig } from '../controllers/shop-config.controller.js';

const router = express.Router();

router.get('/', getShopConfig);

export default router;
