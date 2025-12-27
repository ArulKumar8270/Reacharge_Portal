# Nexus Admin Dashboard

React-based admin dashboard for managing Nexus E-commerce + Wallet + Recharge + Utility Bill Payments application.

## Features

- ✅ Authentication
- ✅ Dashboard with statistics
- ✅ User management
- 🚧 Product management (In Progress)
- 🚧 Category management (In Progress)
- 🚧 Order management (In Progress)
- 🚧 Transaction management (In Progress)
- 🚧 Reports & Analytics (In Progress)

## Tech Stack

- **Framework**: React 18
- **Build Tool**: Vite
- **Styling**: Tailwind CSS
- **State Management**: React Query
- **Routing**: React Router v6
- **HTTP Client**: Axios
- **Icons**: Lucide React

## Getting Started

### Installation

```bash
npm install
```

### Development

```bash
npm run dev
```

The admin dashboard will run on `http://localhost:3001`

### Build

```bash
npm run build
```

### Preview Production Build

```bash
npm run preview
```

## Configuration

### Environment Variables

Create a `.env` file in the root directory:

```env
# Backend API Configuration
# Backend PORT is configured in backend/.env (default: 3000 from ENV_CONFIG.txt)
VITE_API_URL=http://localhost:3000/api/v1

# Environment
VITE_NODE_ENV=development
```

**Important**: The API URL must match your backend server configuration:
- Default backend PORT: `3000` (configured in `backend/.env` or `backend/ENV_CONFIG.txt`)
- API base path: `/api/v1`
- Full URL: `http://localhost:3000/api/v1`

If your backend runs on a different port, update `VITE_API_URL` accordingly.

### Backend Configuration

The admin dashboard connects to the backend API. Ensure your backend is configured with:
- **PORT**: 3000 (default, can be changed in `backend/.env`)
- **API Base**: `/api/v1`
- **Admin Routes**: `/api/v1/admin/*`

See `backend/ENV_CONFIG.txt` for complete backend environment configuration.

## Project Structure

```
src/
├── components/      # Reusable components
├── contexts/        # React contexts
├── pages/          # Page components
├── services/        # API services
├── App.jsx         # Main app component
└── main.jsx        # Entry point
```

## Features

### Dashboard
- Overview statistics
- Recent activity
- Quick actions

### User Management
- View all users
- User details
- Edit/Delete users

### Product Management
- CRUD operations for products
- Category management
- Bulk operations

### Order Management
- View all orders
- Order details
- Status updates

### Transaction Management
- View all transactions
- Transaction details
- Filtering and search

### Reports & Analytics
- Sales reports
- Revenue reports
- User analytics

## Authentication

Admin login is handled through:
- `AuthContext` - Authentication state
- `authService` - API calls

## API Integration

All API calls are made through services in `src/services/api.js`:
- `authService` - Authentication
- `userService` - User management
- `productService` - Product management
- `orderService` - Order management
- `transactionService` - Transaction management
- `reportService` - Reports and analytics

## Styling

The project uses Tailwind CSS for styling. Custom colors and theme can be configured in `tailwind.config.js`.

## License

Proprietary - All rights reserved

