# Nexus Backend API

Node.js + Express backend for Nexus E-commerce + Wallet + Recharge + Utility Bill Payments application.

## Features

- ✅ User Authentication (JWT)
- ✅ Wallet Management
- ✅ Transaction History
- ✅ Admin APIs
- 🚧 E-commerce APIs (In Progress)
- 🚧 Recharge APIs (In Progress)
- 🚧 Bill Payment APIs (In Progress)
- 🚧 Payment Gateway Integration (In Progress)

## Tech Stack

- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: MongoDB (Mongoose)
- **Authentication**: JWT
- **Validation**: express-validator

## Installation

```bash
npm install
```

## Configuration

1. Copy `.env.example` to `.env`
2. Update the environment variables:

```env
PORT=3000
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/nexus
JWT_SECRET=your_jwt_secret_key_here
JWT_EXPIRES_IN=7d
RAZORPAY_KEY_ID=your_razorpay_key_id
RAZORPAY_KEY_SECRET=your_razorpay_key_secret
```

## Running the Server

### Development
```bash
npm run dev
```

### Production
```bash
npm start
```

## API Structure

```
/api/v1/
├── auth/          # Authentication endpoints
├── users/         # User management
├── products/      # Product management
├── categories/    # Category management
├── orders/        # Order management
├── wallet/        # Wallet operations
├── recharge/      # Recharge services
├── bills/         # Utility bill payments
├── payments/      # Payment gateway
└── admin/         # Admin endpoints
```

## API Documentation

### Authentication Endpoints

- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/verify-otp` - Verify OTP
- `POST /api/v1/auth/forgot-password` - Request password reset
- `POST /api/v1/auth/reset-password` - Reset password
- `GET /api/v1/auth/me` - Get current user profile

### Wallet Endpoints

- `GET /api/v1/wallet/balance` - Get wallet balance
- `POST /api/v1/wallet/add-money` - Add money to wallet
- `GET /api/v1/wallet/transactions` - Get transaction history
- `POST /api/v1/wallet/transfer` - Transfer money to another user

### Admin Endpoints

- `POST /api/v1/admin/auth/login` - Admin login
- `GET /api/v1/admin/auth/me` - Get admin profile
- `GET /api/v1/admin/users` - Get all users
- `GET /api/v1/admin/reports/dashboard` - Get dashboard statistics

## Models

- **User** - User accounts
- **Wallet** - User wallets
- **Transaction** - Wallet transactions
- **Product** - Products (to be implemented)
- **Order** - Orders (to be implemented)
- **Category** - Product categories (to be implemented)

## Middleware

- `authenticate` - JWT authentication
- `adminOnly` - Admin role verification
- `validateRequest` - Request validation

## Error Handling

All errors are returned in the following format:

```json
{
  "success": false,
  "message": "Error message"
}
```

## Success Response Format

```json
{
  "success": true,
  "message": "Success message",
  "data": {}
}
```

## Development

### Project Structure

```
backend/
├── controllers/    # Route controllers
├── models/         # Database models
├── routes/         # API routes
├── middleware/     # Custom middleware
├── services/       # Business logic services
└── server.js       # Entry point
```

## Testing

```bash
npm test
```

## License

Proprietary - All rights reserved

