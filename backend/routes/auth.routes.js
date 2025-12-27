import express from 'express';
import { body } from 'express-validator';
import {
  register,
  login,
  verifyOtp,
  forgotPassword,
  resetPassword,
  getProfile,
} from '../controllers/auth.controller.js';
import { authenticate } from '../middleware/auth.middleware.js';
import { validateRequest } from '../middleware/validation.middleware.js';

const router = express.Router();

// Register
router.post(
  '/register',
  [
    body('name').trim().notEmpty().withMessage('Name is required'),
    body('email').isEmail().withMessage('Valid email is required'),
    body('phoneNumber')
      .isMobilePhone('en-IN')
      .withMessage('Valid phone number is required'),
    body('password')
      .isLength({ min: 6 })
      .withMessage('Password must be at least 6 characters'),
  ],
  validateRequest,
  register
);

// Login
router.post(
  '/login',
  [
    body('phoneNumber')
      .isMobilePhone('en-IN')
      .withMessage('Valid phone number is required'),
    body('password').notEmpty().withMessage('Password is required'),
  ],
  validateRequest,
  login
);

// Verify OTP
router.post(
  '/verify-otp',
  [
    body('phoneNumber')
      .isMobilePhone('en-IN')
      .withMessage('Valid phone number is required'),
    body('otp').isLength({ min: 4, max: 6 }).withMessage('Valid OTP is required'),
  ],
  validateRequest,
  verifyOtp
);

// Forgot Password
router.post(
  '/forgot-password',
  [
    body('phoneNumber')
      .isMobilePhone('en-IN')
      .withMessage('Valid phone number is required'),
  ],
  validateRequest,
  forgotPassword
);

// Reset Password
router.post(
  '/reset-password',
  [
    body('token').notEmpty().withMessage('Token is required'),
    body('newPassword')
      .isLength({ min: 6 })
      .withMessage('Password must be at least 6 characters'),
  ],
  validateRequest,
  resetPassword
);

// Get Profile
router.get('/me', authenticate, getProfile);

export default router;

