# Nexus Project Setup Guide

This guide will help you set up the Nexus project on your local machine.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js** (v16 or higher) - [Download](https://nodejs.org/)
- **Flutter SDK** (latest stable) - [Download](https://flutter.dev/docs/get-started/install)
- **MongoDB** (v5 or higher) - [Download](https://www.mongodb.com/try/download/community)
- **Git** - [Download](https://git-scm.com/)

## Project Structure

```
Nexus/
├── mobile-app/          # Flutter mobile application
├── admin-dashboard/     # React admin dashboard
├── backend/             # Node.js backend API
└── docs/                # Documentation
```

## Setup Instructions

### 1. Backend Setup

```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Create .env file from .env.example
cp .env.example .env

# Edit .env file with your configuration
# Set MongoDB URI, JWT secret, payment gateway keys, etc.

# Start MongoDB (if not running as a service)
# macOS: brew services start mongodb-community
# Linux: sudo systemctl start mongod
# Windows: net start MongoDB

# Start the backend server
npm run dev
```

The backend will run on `http://localhost:3000`

### 2. Admin Dashboard Setup

```bash
# Navigate to admin dashboard directory
cd admin-dashboard

# Install dependencies
npm install

# Start development server
npm run dev
```

The admin dashboard will run on `http://localhost:3001`

### 3. Mobile App Setup

```bash
# Navigate to mobile app directory
cd mobile-app

# Get Flutter dependencies
flutter pub get

# Run the app
flutter run
```

For iOS:
```bash
cd ios
pod install
cd ..
flutter run
```

## Environment Variables

### Backend (.env)

```env
PORT=3000
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/nexus
JWT_SECRET=your_jwt_secret_key_here
JWT_EXPIRES_IN=7d
RAZORPAY_KEY_ID=your_razorpay_key_id
RAZORPAY_KEY_SECRET=your_razorpay_key_secret
```

### Admin Dashboard

Create a `.env` file in `admin-dashboard/`:

```env
VITE_API_URL=http://localhost:3000/api/v1
```

## Database Setup

1. Make sure MongoDB is running
2. The application will automatically create the database and collections on first run
3. To create an admin user, you can use the MongoDB shell or create a script

## Creating Admin User

You can create an admin user using MongoDB shell:

```javascript
use nexus
db.users.insertOne({
  name: "Admin",
  email: "admin@nexus.com",
  phoneNumber: "1234567890",
  password: "$2a$10$hashed_password_here", // Use bcrypt to hash
  role: "admin",
  isVerified: true
})
```

Or use the registration API and manually update the role in the database.

## API Endpoints

### Authentication
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - Login
- `POST /api/v1/auth/verify-otp` - Verify OTP
- `GET /api/v1/auth/me` - Get current user profile

### Admin
- `POST /api/v1/admin/auth/login` - Admin login
- `GET /api/v1/admin/users` - Get all users
- `GET /api/v1/admin/reports/dashboard` - Get dashboard stats

See the API documentation for complete endpoint list.

## Development Workflow

1. **Start Backend**: `cd backend && npm run dev`
2. **Start Admin Dashboard**: `cd admin-dashboard && npm run dev`
3. **Run Mobile App**: `cd mobile-app && flutter run`

## Testing

### Backend
```bash
cd backend
npm test
```

### Mobile App
```bash
cd mobile-app
flutter test
```

## Troubleshooting

### MongoDB Connection Issues
- Ensure MongoDB is running: `mongod --version`
- Check MongoDB URI in `.env` file
- Verify MongoDB is accessible on the specified port

### Port Already in Use
- Change the port in `.env` file (backend)
- Change the port in `vite.config.js` (admin dashboard)

### Flutter Issues
- Run `flutter doctor` to check for issues
- Run `flutter clean` and `flutter pub get` to reset dependencies

## Next Steps

1. Review the [Phase Plan](./docs/PHASE_PLAN.md) for implementation details
2. Set up payment gateway accounts (Razorpay/Paytm/Cashfree)
3. Set up BBPS API for utility bill payments
4. Configure SMS gateway for OTP
5. Set up production environment

## Support

For issues or questions, refer to the documentation in the `docs/` folder or contact the development team.

